#include "campaign_lock.hpp"
#include <cstdio>
#include <cstdlib>
#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/variant/string.hpp>

using namespace godot;

class SaveLockLab : public RefCounted {
    GDCLASS(SaveLockLab, RefCounted)
    CampaignLock lock;
    bool held = false;
protected:
    static void _bind_methods() {
        ClassDB::bind_method(D_METHOD("try_acquire", "absolute_path"), &SaveLockLab::try_acquire);
        ClassDB::bind_method(D_METHOD("release"), &SaveLockLab::release);
        ClassDB::bind_method(D_METHOD("is_held"), &SaveLockLab::is_held);
    }
public:
    bool try_acquire(const String &absolute_path) {
        if (held) return false;
        auto utf8 = absolute_path.utf8();
        auto path = std::filesystem::u8path(utf8.get_data());
        if (!path.is_absolute() || path.filename() != "campaign.lock") return false;
        // Reject lexical traversal and redirected parents in the laboratory.
        // This is a preflight check, not race-proof confinement: the caller must
        // own and protect the directory against concurrent replacement.
        std::error_code ec;
        const auto parent = path.parent_path();
        if (parent != parent.lexically_normal()) return false;
        const auto canonical_parent = std::filesystem::canonical(parent, ec);
        if (ec || canonical_parent != parent) return false;
        if (!std::filesystem::is_directory(canonical_parent, ec) || ec) return false;
        held = lock.acquire(path);
        return held;
    }
    void release() { lock.release(); held = false; }
    bool is_held() const { return held; }
};

static void initialize(ModuleInitializationLevel level) {
    std::fprintf(stderr, "SAVE_LOCK_INIT_LEVEL=%d\n", static_cast<int>(level));
    std::fflush(stderr);
    if (level == MODULE_INITIALIZATION_LEVEL_SCENE && !std::getenv("LITD_LOCK_INIT_ONLY")) GDREGISTER_RUNTIME_CLASS(SaveLockLab);
}
static void terminate(ModuleInitializationLevel level) {
    std::fprintf(stderr, "SAVE_LOCK_TERMINATE_LEVEL=%d\n", static_cast<int>(level));
    std::fflush(stderr);
}

extern "C" GDExtensionBool GDE_EXPORT save_lock_lab_init(
    GDExtensionInterfaceGetProcAddress address,
    GDExtensionClassLibraryPtr library,
    GDExtensionInitialization *initialization) {
    GDExtensionBinding::InitObject init(address, library, initialization);
    init.register_initializer(initialize);
    init.register_terminator(terminate);
    init.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);
    return init.init();
}
