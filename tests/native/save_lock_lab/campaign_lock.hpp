#pragma once
#include <filesystem>
#ifdef _WIN32
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#else
#include <fcntl.h>
#include <sys/file.h>
#include <unistd.h>
#endif

// Laboratory core. Stable lock path required; never unlink a lock file.
class CampaignLock {
#ifdef _WIN32
    HANDLE handle = INVALID_HANDLE_VALUE;
#else
    int fd = -1;
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
            FILE_ATTRIBUTE_NORMAL, nullptr);
        if (h == INVALID_HANDLE_VALUE) return false;
        OVERLAPPED ov{};
        if (!LockFileEx(h, LOCKFILE_EXCLUSIVE_LOCK | LOCKFILE_FAIL_IMMEDIATELY, 0, 1, 0, &ov)) {
            CloseHandle(h); return false;
        }
        handle = h;
#else
        if (fd != -1) return false;
        int h = open(path.c_str(), O_CREAT | O_RDWR | O_CLOEXEC | O_NOFOLLOW, 0600);
        if (h < 0) return false;
        if (flock(h, LOCK_EX | LOCK_NB) != 0) { close(h); return false; }
        fd = h;
#endif
        return true;
    }
    void release() noexcept {
#ifdef _WIN32
        if (handle != INVALID_HANDLE_VALUE) { CloseHandle(handle); handle = INVALID_HANDLE_VALUE; }
#else
        if (fd != -1) { close(fd); fd = -1; }
#endif
    }
};
