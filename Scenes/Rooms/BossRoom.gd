extends RoomWorld
class_name BossRoom


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	super._ready()

	print(
		"BossRoom ready"
	)

#extends RoomWorld
#class_name BossRoom
#
#
## ==================================================
## Managers
## ==================================================
#
#@onready var run_manager: RunManager = get_node(
	#"../Managers/RunManager"
#)
#
#@onready var battle_manager: BattleManager = get_node(
	#"../Managers/BattleManager"
#)
#
#
## ==================================================
## Room Initialization
## ==================================================
#
#func _ready() -> void:
#
	#super._ready()
#
	#print(
		#"BossRoom ready"
	#)
#
#
## ==================================================
## Room Start
## ==================================================
#
#func start_room() -> void:
#
	#print(
		#"Starting Boss Room"
	#)
#
	## Temporary boss battle
	#battle_manager.start_battle()
#
#
## ==================================================
## Room Completion
## ==================================================
#
#func complete_room() -> void:
#
	#print(
		#"Boss Room completed"
	#)
#
	#super.complete_room()
