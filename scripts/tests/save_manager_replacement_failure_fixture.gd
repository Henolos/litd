extends "res://scripts/core/save_manager.gd"

# Test-only subclass: exercise recovery without relying on a filesystem race.
var fail_replacement := false
var fail_backup_replacement := false
var remove_destination_before_failure := false

func _replace_save_file(from_path: String, to_path: String) -> Error:
    var is_backup := to_path.ends_with(".bak")
    if (is_backup and not fail_backup_replacement) or (not is_backup and not fail_replacement):
        return super._replace_save_file(from_path, to_path)
    if remove_destination_before_failure and FileAccess.file_exists(to_path):
        var removal := DirAccess.remove_absolute(to_path)
        if removal != OK:
            return removal
    return ERR_CANT_CREATE
