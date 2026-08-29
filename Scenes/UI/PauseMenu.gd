extends Control
class_name PauseMenu


# ==================================================
# Managers
# ==================================================

@onready var run_manager: RunManager = get_node(
	"../../Managers/RunManager"
)

@onready var run_mutagen_manager: RunMutagenManager = get_node(
	"../../Managers/RunMutagenManager"
)


# ==================================================
# Options
# ==================================================

@onready var resume_button: Button = (
	$MainPanel/MarginContainer/MainContainer/OptionsPanel/
		MarginContainer/OptionsColumn/ResumeButton
)

@onready var settings_button: Button = (
	$MainPanel/MarginContainer/MainContainer/OptionsPanel/
		MarginContainer/OptionsColumn/SettingsButton
)

@onready var return_home_button: Button = (
	$MainPanel/MarginContainer/MainContainer/OptionsPanel/
		MarginContainer/OptionsColumn/ReturnHomeButton
)

@onready var return_menu_button: Button = (
	$MainPanel/MarginContainer/MainContainer/OptionsPanel/
		MarginContainer/OptionsColumn/ReturnMenuButton
)


# ==================================================
# Build Display
# ==================================================

@onready var animal_name_label: Label = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/AnimalSection/AnimalName
)

@onready var animal_sprite: TextureRect = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/AnimalSection/AnimalSprite
)


# ==================================================
# Stats
# ==================================================

@onready var hp_label: Label = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/AnimalSection/StatsSection/HPLabel
)

@onready var attack_label: Label = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/AnimalSection/StatsSection/AttackLabel
)

@onready var speed_label: Label = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/AnimalSection/StatsSection/SpeedLabel
)

@onready var armor_label: Label = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/AnimalSection/StatsSection/ArmorLabel
)

@onready var accuracy_label: Label = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/AnimalSection/StatsSection/AccuracyLabel
)

@onready var evasion_label: Label = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/AnimalSection/StatsSection/EvasionLabel
)

@onready var critical_label: Label = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/AnimalSection/StatsSection/CriticalLabel
)


# ==================================================
# Gene Slots
# ==================================================

@onready var mouth_slot_1: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/GeneSection/GeneColumn/MouthSlot1
)

@onready var mouth_slot_2: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/GeneSection/GeneColumn/MouthSlot2
)

@onready var skin_slot_1: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/GeneSection/GeneColumn/SkinSlot1
)

@onready var skin_slot_2: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/GeneSection/GeneColumn/SkinSlot2
)

@onready var muscle_slot_1: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/GeneSection/GeneColumn/MuscleSlot1
)

@onready var muscle_slot_2: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/GeneSection/GeneColumn/MuscleSlot2
)

@onready var claws_slot_1: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/GeneSection/GeneColumn/ClawsSlot1
)

@onready var claws_slot_2: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/GeneSection/GeneColumn/ClawsSlot2
)

@onready var limbs_slot_1: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/GeneSection/GeneColumn/LimbsSlot1
)

@onready var limbs_slot_2: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/GeneSection/GeneColumn/LimbsSlot2
)

@onready var glands_slot_1: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/GeneSection/GeneColumn/GlandsSlot1
)

@onready var glands_slot_2: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/GeneSection/GeneColumn/GlandsSlot2
)


# ==================================================
# Mutagen Slots
# ==================================================

@onready var mutagen_1: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/MutagenSection/Mutagen1
)

@onready var mutagen_2: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/MutagenSection/Mutagen2
)

@onready var mutagen_3: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/MutagenSection/Mutagen3
)

@onready var mutagen_4: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/MutagenSection/Mutagen4
)

@onready var mutagen_5: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/MutagenSection/Mutagen5
)

@onready var mutagen_6: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/MutagenSection/Mutagen6
)

@onready var reserve_mutagen: PanelContainer = (
	$MainPanel/MarginContainer/MainContainer/BuildPanel/
		MarginContainer/BuildContainer/MutagenSection/
		ReserveRow/ReserveMutagen
)


# ==================================================
# State
# ==================================================

var is_open: bool = false


# ==================================================
# Initialization
# ==================================================

func _ready() -> void:

	hide()

	process_mode = Node.PROCESS_MODE_ALWAYS

	resume_button.pressed.connect(
		_on_resume_pressed
	)

	settings_button.pressed.connect(
		_on_settings_pressed
	)

	return_home_button.pressed.connect(
		_on_return_home_pressed
	)

	return_menu_button.pressed.connect(
		_on_return_menu_pressed
	)


# ==================================================
# Input
# ==================================================

func _unhandled_input(
	event: InputEvent
) -> void:

	if not event.is_action_pressed("pause"):
		return

	toggle_pause()

	get_viewport().set_input_as_handled()


# ==================================================
# Pause
# ==================================================

func toggle_pause() -> void:

	if is_open:

		close_pause()

	else:

		open_pause()


func open_pause() -> void:

	if run_manager == null:
		return

	if not run_manager.run_active:
		return

	_refresh_build_display()

	is_open = true

	show()

	get_tree().paused = true


func close_pause() -> void:

	is_open = false

	hide()

	get_tree().paused = false


# ==================================================
# Build Display
# ==================================================

func _refresh_build_display() -> void:

	var build: AnimalBuildResource = (
		run_manager.current_animal_build
	)

	if build == null:

		push_error(
			"PauseMenu: No current animal build."
		)

		return


	# ==================================================
	# Animal
	# ==================================================

	animal_name_label.text = (
		build.animal_name
	)


	# ==================================================
	# Current Stats
	# ==================================================

	_refresh_stats(
		build
	)


	# ==================================================
	# Genes
	# ==================================================

	_refresh_genes(
		build
	)


	# ==================================================
	# Mutagens
	# ==================================================

	_refresh_mutagens()


# ==================================================
# Stats
# ==================================================

func _refresh_stats(
	build: AnimalBuildResource
) -> void:

	var animal := build.animal

	if animal == null:

		hp_label.text = "HP: --"
		attack_label.text = "Attack: --"
		speed_label.text = "Speed: --"
		armor_label.text = "Armor: --"
		accuracy_label.text = "Accuracy: --"
		evasion_label.text = "Evasion: --"
		critical_label.text = "Critical: --"

		return


	var max_hp: int = animal.base_hp
	var attack: int = animal.base_attack
	var speed: int = animal.base_speed

	var accuracy: int = 100
	var evasion: int = 0
	var armor: int = 0
	var critical: int = 0

	# ==================================================
	# Gene Bonuses
	# ==================================================

	for gene in build.genes:

		if gene == null:
			continue

		max_hp += gene.hp_bonus
		attack += gene.attack_bonus
		speed += gene.speed_bonus
		accuracy += gene.accuracy_bonus
		evasion += gene.evasion_bonus
		armor += gene.armor_bonus
		critical += gene.critical_bonus


	# ==================================================
	# Mutagen Bonuses
	# ==================================================

	if run_mutagen_manager != null:

		for mutagen in (
			run_mutagen_manager.equipped_mutagens
		):

			if mutagen == null:
				continue

			max_hp += mutagen.hp_bonus
			attack += mutagen.attack_bonus
			speed += mutagen.speed_bonus
			accuracy += mutagen.accuracy_bonus
			evasion += mutagen.evasion_bonus
			armor += mutagen.armor_bonus
			critical += mutagen.crit_bonus

	# ==================================================
	# Display
	# ==================================================

	hp_label.text = (
		"HP: %d / %d"
		% [
			run_manager.player_hp,
			max_hp
		]
	)

	attack_label.text = (
		"Attack: %d"
		% attack
	)

	speed_label.text = (
		"Speed: %d"
		% speed
	)

	armor_label.text = (
		"Armor: %d"
		% armor
	)

	accuracy_label.text = (
		"Accuracy: %d"
		% accuracy
	)

	evasion_label.text = (
		"Evasion: %d"
		% evasion
	)

	critical_label.text = (
		"Critical: %d%%"
		% critical
	)


# ==================================================
# Genes
# ==================================================

func _refresh_genes(
	build: AnimalBuildResource
) -> void:

	var slot_map := {
		GeneResource.SlotType.MOUTH:
			[mouth_slot_1, mouth_slot_2],

		GeneResource.SlotType.SKIN:
			[skin_slot_1, skin_slot_2],

		GeneResource.SlotType.MUSCLE:
			[muscle_slot_1, muscle_slot_2],

		GeneResource.SlotType.CLAWS:
			[claws_slot_1, claws_slot_2],

		GeneResource.SlotType.LIMBS:
			[limbs_slot_1, limbs_slot_2],

		GeneResource.SlotType.GLANDS:
			[glands_slot_1, glands_slot_2]
	}

	for slots in slot_map.values():

		for slot in slots:

			_clear_slot(
				slot
			)

	for gene in build.genes:

		if gene == null:
			continue

		if not slot_map.has(
			gene.slot_type
		):

			continue

		var slots: Array = (
			slot_map[gene.slot_type]
		)

		for slot in slots:

			if slot.get_meta(
				"filled",
				false
			):

				continue

			_set_gene_slot(
				slot,
				gene
			)

			break


# ==================================================
# Gene Slot
# ==================================================

func _set_gene_slot(
	slot: PanelContainer,
	gene: GeneResource
) -> void:

	slot.set_meta(
		"filled",
		true
	)

	slot.mouse_filter = Control.MOUSE_FILTER_STOP

	var label := slot.get_node_or_null(
		"Label"
	)

	if label == null:

		label = Label.new()

		slot.add_child(
			label
		)

	label.text = gene.gene_name

	label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	slot.tooltip_text = _get_gene_tooltip(
		gene
	)


# ==================================================
# Gene Tooltip
# ==================================================

func _get_gene_tooltip(
	gene: GeneResource
) -> String:

	var text := gene.gene_name

	if not gene.description.is_empty():

		text += "\n\n"
		text += gene.description

	return text


# ==================================================
# Mutagens
# ==================================================

func _refresh_mutagens() -> void:

	var slots := [
		mutagen_1,
		mutagen_2,
		mutagen_3,
		mutagen_4,
		mutagen_5,
		mutagen_6
	]


	for slot in slots:

		_clear_slot(
			slot
		)


	_clear_slot(
		reserve_mutagen
	)


	if run_mutagen_manager == null:
		return


	# ==================================================
	# Equipped
	# ==================================================

	var equipped := (
		run_mutagen_manager.equipped_mutagens
	)

	for i in range(
		min(
			equipped.size(),
			slots.size()
		)
	):

		var mutagen: MutagenResource = (
			equipped[i]
		)

		if mutagen == null:
			continue

		_set_mutagen_slot(
			slots[i],
			mutagen
		)


	# ==================================================
	# Reserve
	# ==================================================

	if run_mutagen_manager.reserve_mutagen != null:

		_set_mutagen_slot(
			reserve_mutagen,
			run_mutagen_manager.reserve_mutagen
		)


# ==================================================
# Mutagen Slot
# ==================================================

func _set_mutagen_slot(
	slot: PanelContainer,
	mutagen: MutagenResource
) -> void:

	slot.set_meta(
		"filled",
		true
	)

	slot.mouse_filter = Control.MOUSE_FILTER_STOP

	var label := slot.get_node_or_null(
		"Label"
	)

	if label == null:

		label = Label.new()

		slot.add_child(
			label
		)

	label.text = mutagen.mutagen_name

	label.horizontal_alignment = (
		HORIZONTAL_ALIGNMENT_CENTER
	)

	label.vertical_alignment = (
		VERTICAL_ALIGNMENT_CENTER
	)

	label.autowrap_mode = (
		TextServer.AUTOWRAP_WORD_SMART
	)

	slot.tooltip_text = _get_mutagen_tooltip(
		mutagen
	)


# ==================================================
# Mutagen Tooltip
# ==================================================

func _get_mutagen_tooltip(
	mutagen: MutagenResource
) -> String:

	var text := (
		mutagen.mutagen_name
	)

	text += "\n"
	text += (
		"Family: "
		+ mutagen.get_family_name()
	)

	text += "\n"
	text += (
		"Tier: "
		+ str(
			int(mutagen.tier)
		)
	)

	if not mutagen.description.is_empty():

		text += "\n\n"
		text += mutagen.description

	return text


# ==================================================
# Clear Slot
# ==================================================

func _clear_slot(
	slot: PanelContainer
) -> void:

	if slot == null:
		return

	slot.set_meta(
		"filled",
		false
	)

	slot.tooltip_text = ""

	var label := slot.get_node_or_null(
		"Label"
	)

	if label != null:

		label.text = ""


# ==================================================
# Buttons
# ==================================================

func _on_resume_pressed() -> void:

	close_pause()


func _on_settings_pressed() -> void:

	print(
		"PauseMenu: Settings selected."
	)


func _on_return_home_pressed() -> void:

	print(
		"PauseMenu: Return Home selected."
	)


func _on_return_menu_pressed() -> void:

	print(
		"PauseMenu: Return to Menu selected."
	)
