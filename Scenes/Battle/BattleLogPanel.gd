extends Control


@onready var log_text: RichTextLabel = $LogText


func _ready():

	BattleLog.message_added.connect(
		update_battle_log
	)


func update_battle_log(_message):

	var text := ""

	for message in BattleLog.messages:
		text += message + "\n"

	log_text.text = text
