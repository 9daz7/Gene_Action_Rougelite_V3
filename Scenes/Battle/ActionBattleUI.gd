extends CanvasLayer
class_name ActionBattleUI


# ==================================================
# References
# ==================================================

var deebo: PlayerAnimal
var player_character: ActionPlayerCharacter


# ==================================================
# UI
# ==================================================

@onready var deebo_hp: ProgressBar = $UI/DeeboHP
@onready var player_hp: ProgressBar = $UI/PlayerHP


# ==================================================
# Setup
# ==================================================

func setup(
	deebo_ref: PlayerAnimal,
	player_ref: ActionPlayerCharacter
) -> void:

	deebo = deebo_ref
	player_character = player_ref

	_connect_health_signals()

	# Initialize the bars immediately.
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
