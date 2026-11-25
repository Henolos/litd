#pragma once
#include <filesystem>
#include <cstdint>
#include <cstdio>
#include <cstddef>
#include <cstring>
#ifdef _WIN32
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#else
#include <fcntl.h>
#include <sys/file.h>
#include <sys/stat.h>
#include <unistd.h>
#ifdef __linux__
#include <sys/socket.h>
#include <sys/un.h>
#endif
#endif

// Laboratory core. Stable lock path required; never unlink a lock file.
class CampaignLock {
#ifdef _WIN32
    HANDLE handle = INVALID_HANDLE_VALUE;
#else
    int fd = -1;
#ifdef __linux__
    int namespace_fd = -1;
#endif
#endif
public:
    CampaignLock() = default;
    CampaignLock(const CampaignLock&) = delete;
    CampaignLock& operator=(const CampaignLock&) = delete;
    ~CampaignLock() { release(); }
    bool acquire(const std::filesystem::path& path) {
#ifdef _WIN32
        if (handle != INVALID_HANDLE_VALUE) return false;
        HANDLE h = CreateFileW(path.c_str(), GENERIC_READ | GENERIC_WRITE,
            FILE_SHARE_READ | FILE_SHARE_WRITE, nullptr, OPEN_ALWAYS,
            FILE_ATTRIBUTE_NORMAL | FILE_FLAG_OPEN_REPARSE_POINT, nullptr);
        if (h == INVALID_HANDLE_VALUE) return false;
        BY_HANDLE_FILE_INFORMATION info{};
        if (GetFileType(h) != FILE_TYPE_DISK || !GetFileInformationByHandle(h, &info) ||
            (info.dwFileAttributes & (FILE_ATTRIBUTE_REPARSE_POINT | FILE_ATTRIBUTE_DIRECTORY)) || info.nNumberOfLinks != 1) {
            CloseHandle(h); return false;
        }
        OVERLAPPED ov{};
        if (!LockFileEx(h, LOCKFILE_EXCLUSIVE_LOCK | LOCKFILE_FAIL_IMMEDIATELY, 0, 1, 0, &ov)) {
            CloseHandle(h); return false;
        }
        handle = h;
#else
        if (fd != -1) return false;
        // Reject redirected parent paths at the native boundary as well.
        // Preflight only: not a guarantee against concurrent directory changes.
        std::error_code parent_ec;
        const auto parent = path.parent_path();
        if (!path.is_absolute() || parent != parent.lexically_normal()) return false;
        const auto canonical_parent = std::filesystem::canonical(parent, parent_ec);
        if (parent_ec || canonical_parent != parent) return false;
        int h = open(path.c_str(), O_CREAT | O_RDWR | O_CLOEXEC | O_NOFOLLOW | O_NONBLOCK, 0600);
        if (h < 0) return false;
        struct stat info{};
        if (fstat(h, &info) != 0 || !S_ISREG(info.st_mode) || info.st_nlink != 1) { close(h); return false; }
        if (flock(h, LOCK_EX | LOCK_NB) != 0) { close(h); return false; }
#ifdef __linux__
        // Abstract Unix sockets have kernel-owned names, independent of file
        // deletion/rename. Scope: cooperating processes in one network namespace.
        // Hash collisions deny acquisition rather than allow concurrent ownership.
        std::error_code ec;
        const auto absolute = std::filesystem::absolute(path, ec).lexically_normal();
        if (ec) { close(h); return false; }
        std::uint64_t hash = 14695981039346656037ULL;
        for (unsigned char c : absolute.native()) { hash ^= c; hash *= 1099511628211ULL; }
        sockaddr_un address{};
        address.sun_family = AF_UNIX;
        const int length = std::snprintf(address.sun_path + 1, sizeof(address.sun_path) - 1,
            "litd-save-lock-v1-%016llx", static_cast<unsigned long long>(hash));
        if (length < 0 || static_cast<std::size_t>(length) >= sizeof(address.sun_path) - 1) {
            close(h); return false;
        }
        int guard = socket(AF_UNIX, SOCK_STREAM | SOCK_CLOEXEC, 0);
        if (guard < 0) { close(h); return false; }
        if (bind(guard, reinterpret_cast<const sockaddr*>(&address),
                 static_cast<socklen_t>(offsetof(sockaddr_un, sun_path) + 1 + length)) != 0) {
            close(guard); close(h); return false;
        }
        namespace_fd = guard;
#endif
        fd = h;
#endif
        return true;
    }
    void release() noexcept {
#ifdef _WIN32
        if (handle != INVALID_HANDLE_VALUE) { CloseHandle(handle); handle = INVALID_HANDLE_VALUE; }
#else
        if (fd != -1) { close(fd); fd = -1; }
#ifdef __linux__
        if (namespace_fd != -1) { close(namespace_fd); namespace_fd = -1; }
#endif
#endif
    }
};
