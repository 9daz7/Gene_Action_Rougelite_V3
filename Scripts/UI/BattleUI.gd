extends CanvasLayer


signal move_selected(move_index)


@onready var attack_button = $MoveButtons/AttackButton
@onready var protect_button = $MoveButtons/ProtectButton
@onready var move3_button = $MoveButtons/Move3Button
@onready var move4_button = $MoveButtons/Move4Button

@onready var player_name_label = $PlayerPanel/PlayerNameLabel
@onready var enemy_name_label = $EnemyPanel/EnemyNameLabel

@onready var player_status_label = $PlayerPanel/PlayerStatusLabel
@onready var enemy_status_label = $EnemyPanel/EnemyStatusLabel

var move_buttons:Array[Button]


func _ready():
	print("BattleUI ready")
	
	move_buttons = [
		attack_button,
		protect_button,
		move3_button,
		move4_button
		]

	attack_button.pressed.connect(
		func():
			move_selected.emit(0)
	)

	protect_button.pressed.connect(
		func():
			move_selected.emit(1)
	)
	
	move3_button.pressed.connect(
		func():
			move_selected.emit(2)
	)

	move4_button.pressed.connect(
		func():
			move_selected.emit(3)
	)

	move3_button.disabled = true
	move4_button.disabled = true
	

func setup_names(player, enemy):

	player_name_label.text = player.name
	
	enemy_name_label.text = enemy.name
	
	
func update_status_labels(player:AnimalBase, enemy:AnimalBase):

	player_status_label.text = get_status_text(player)
	
	if enemy != null:
		enemy_status_label.text = get_status_text(enemy)
	else:
		enemy_status_label.text = ""
	
	
func get_status_text(animal:AnimalBase) -> String:

	var text := ""

	for effect in animal.status_effects:

		text += effect.effect_name
		text += " (" + str(effect.duration) + ")\n"

	return text
	
	
func setup_moves(player):

	var moves = player.get_battle_moves()

	move3_button.text = "Empty"
	move4_button.text = "Empty"
	
	move3_button.disabled = true
	move4_button.disabled = true


	if moves.size() > 2:
		move3_button.text = moves[2].move_name
		move3_button.disabled = false


	if moves.size() > 3:
		move4_button.text = moves[3].move_name
		move4_button.disabled = false
		
		
func enable_moves():

	for button in move_buttons:
		button.disabled = false


func disable_moves():

	for button in move_buttons:
		button.disabled = true
