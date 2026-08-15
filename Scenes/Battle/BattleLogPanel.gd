extends PanelContainer


# ==================================================
# Onready Variables
# ==================================================

@onready var log_text: RichTextLabel = $ScrollContainer/LogText
#@onready var scroll_container: ScrollContainer = $ScrollContainer


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	if not BattleLog.message_added.is_connected(
		update_battle_log
	):

		BattleLog.message_added.connect(
			update_battle_log
		)

	update_battle_log("")


# ==================================================
# Public Functions
# ==================================================


func update_battle_log(_message) -> void:

	print(
		"BATTLE LOG MESSAGE COUNT:",
		BattleLog.messages.size()
	)

	var text := ""

	for message in BattleLog.messages:
		text += message + "\n"

	log_text.text = text

	await get_tree().process_frame

	$ScrollContainer.scroll_vertical = (
		$ScrollContainer.get_v_scroll_bar().max_value
	)
#func update_battle_log(_message) -> void:
#
	#var text := ""
#
	#for message in BattleLog.messages:
		#text += message + "\n"
#
	#log_text.text = text
#
	#await get_tree().process_frame
#
	#log_text.custom_minimum_size.y = max(
		#250.0,
		#log_text.get_content_height()
	#)
#
	#scroll_container.scroll_vertical = (
		#scroll_container.get_v_scroll_bar().max_value
	#)

# ==================================================
# Cleanup
# ==================================================

func _exit_tree() -> void:

	if BattleLog.message_added.is_connected(
		update_battle_log
	):

		BattleLog.message_added.disconnect(
			update_battle_log
	)
