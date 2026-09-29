extends CanvasLayer
class_name ActionBattleUI


# ==================================================
# References
# ==================================================

var deebo: PlayerAnimal
var player_character: ActionPlayerCharacter

var player_controller: ActionPlayerController

# ==================================================
# UI
# ==================================================

@onready var deebo_hp: ProgressBar = $UI/DeeboHP
@onready var player_hp: ProgressBar = $UI/PlayerHP

@onready var move_1_name: Label = $UI/Move1/MarginContainer/VBoxContainer/Name
@onready var move_2_name: Label = $UI/Move2/MarginContainer/VBoxContainer/Name
@onready var move_3_name: Label = $UI/Move3/MarginContainer/VBoxContainer/Name

@onready var move_1_cooldown: Label = $UI/Move1/MarginContainer/VBoxContainer/Cooldown
@onready var move_2_cooldown: Label = $UI/Move2/MarginContainer/VBoxContainer/Cooldown
@onready var move_3_cooldown: Label = $UI/Move3/MarginContainer/VBoxContainer/Cooldown


# ==================================================
# Setup
# ==================================================

func setup(
	deebo_ref: PlayerAnimal,
	player_ref: ActionPlayerCharacter,
	player_controller_ref: ActionPlayerController
) -> void:

	deebo = deebo_ref
	player_character = player_ref
	player_controller = player_controller_ref

	_connect_health_signals()

	if not player_controller.move_cooldown_changed.is_connected(
		_on_move_cooldown_changed
	):
		player_controller.move_cooldown_changed.connect(
			_on_move_cooldown_changed
	)

	update_move_names()

	deebo_hp.max_value = deebo.get_max_hp()
	deebo_hp.value = deebo.get_current_hp()

	player_hp.max_value = player_character.max_health
	player_hp.value = player_character.health


# ==================================================
# Health Connections
# ==================================================

func _ready() -> void:

	GameEvents.animal_hp_changed.connect(
		_on_animal_hp_changed
	)


func _connect_health_signals() -> void:

	if player_character != null:
		if not player_character.health_changed.is_connected(
			_on_player_health_changed
		):
			player_character.health_changed.connect(
				_on_player_health_changed
			)


# ==================================================
# Health Updates
# ==================================================

func _on_player_health_changed(
	current_health: float,
	maximum_health: float
) -> void:

	player_hp.max_value = maximum_health
	player_hp.value = current_health


func _on_animal_hp_changed(
	animal: AnimalBase,
	current_hp: int,
	maximum_hp: int
) -> void:

	if animal != deebo:
		return

	deebo_hp.max_value = maximum_hp
	deebo_hp.value = current_hp


# ==================================================
# Move Names
# ==================================================

func update_move_names() -> void:

	if deebo == null:
		return

	if not deebo.has_method("get_battle_moves"):
		return

	var moves = deebo.get_battle_moves()

	var name_labels = [
		move_1_name,
		move_2_name,
		move_3_name
	]

	for i in range(name_labels.size()):

		if i < moves.size() and moves[i] != null:

			name_labels[i].text = moves[i].move_name.to_upper()

		else:

			name_labels[i].text = ""


func _on_move_cooldown_changed(
	move: MoveResource,
	remaining: float
) -> void:

	var moves = deebo.get_battle_moves()

	var cooldown_labels = [
		move_1_cooldown,
		move_2_cooldown,
		move_3_cooldown
	]

	for i in range(moves.size()):

		if moves[i] != move:
			continue

		if remaining > 0.0:

			cooldown_labels[i].text = "%.1f" % remaining
			cooldown_labels[i].visible = true

		else:

			cooldown_labels[i].text = ""
			cooldown_labels[i].visible = false

		return
