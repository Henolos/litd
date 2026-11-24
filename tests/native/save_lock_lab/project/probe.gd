extends SceneTree

func _initialize() -> void:
    var args := OS.get_cmdline_user_args()
    if args.size() != 2 or not ClassDB.class_exists("SaveLockLab"):
        quit(2)
        return
    var lock = ClassDB.instantiate("SaveLockLab")
    if not lock.try_acquire(args[0]):
        quit(23)
        return
    if not lock.is_held() or lock.try_acquire(args[0]):
        quit(3)
        return
    print("GODOT_LOCK_ACQUIRED")
    if args[1] == "hold":
        await create_timer(120.0).timeout
    lock.release()
    quit(0)
