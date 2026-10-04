extends Node3D

# Reuse the authored map's room geometry, without generating new dimensions.
const BUILDER := preload("res://scripts/world/first_accord_dungeon_map_builder.gd")
@export var authored_room_id := ""
@export var module_id := ""

func _ready() -> void:
    set_meta("module_id", module_id)
    var map := BUILDER._load_json(BUILDER.MAP_PATH)
    for floor_data in map.get("floors", []):
        for room in floor_data.get("rooms", []):
            if str(room.get("id", "")) == authored_room_id:
                var template: Dictionary = room.duplicate(true)
                template["center"] = [0, 0, 0]
                BUILDER._build_room(self, template)
                return
    push_error("Missing authored room: " + authored_room_id)
