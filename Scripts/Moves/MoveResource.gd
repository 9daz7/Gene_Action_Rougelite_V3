extends Resource
class_name MoveResource


# ==================================================
# Enums
# ==================================================
enum MoveCategory {
	BIOLOGICAL,
	GENETIC
}

enum MoveEffectType {
	DAMAGE,
	PROTECT,
	STATUS,
	HYBRID
}

enum DamageType {
	PHYSICAL,
	SPECIAL,
	TRUE
}

enum EffectTarget {
	SELF,
	TARGET
}

enum TargetType {
	SINGLE_ENEMY,
	ALL_ENEMIES,
	SELF,
	SINGLE_ALLY,
	ALL_ALLIES
}

enum HitboxType {
	NONE,
	CIRCLE,
	RECTANGLE,
	CONE
}


# ==================================================
# Targeting
# ==================================================

@export var target_type: TargetType = TargetType.SINGLE_ENEMY


# ==================================================
# Hitbox
# ==================================================

@export var hitbox_type: HitboxType = HitboxType.NONE
@export var hitbox_size: Vector2 = Vector2(60.0, 40.0)
@export var hitbox_radius: float = 60.0
@export var hitbox_offset: float = 40.0
@export var hitbox_angle: float = 90.0
@export var hitbox_duration: float = 0.15

@export var action_lunge_distance: float = 70.0
@export var action_lunge_duration: float = 0.12
@export var action_recovery_duration: float = 0.0

@export_range(0.0, 1.0, 0.01)
var attack_hit_point: float = 1.0


# ==================================================
# Basic Move Info
# ==================================================-

@export var move_name: String = "Unnamed Move"
@export_multiline var description: String = ""

@export var effect_type: MoveEffectType = MoveEffectType.DAMAGE
@export var category: MoveCategory = MoveCategory.BIOLOGICAL


# ==================================================
# Damage
# ==================================================

@export var power := 0
@export var damage_type: DamageType = DamageType.PHYSICAL
@export var damage_multiplier := 1.0


# ==================================================
# Combat
# ==================================================

@export var priority := 0
@export var accuracy := 100
@export var critical_chance := 0
@export var cooldown: float = 0.0


# ==================================================
# Effects
# ==================================================

@export var effects: Array[StatusEffect] = []
@export var effect_target: EffectTarget = EffectTarget.TARGET


func calculate_action_damage(
	user: AnimalBase,
	target: AnimalBase
) -> Dictionary:

	if target == null:
		return {
			"hit": false,
			"damage": 0.0
		}

	if not is_instance_valid(target):
		return {
			"hit": false,
			"damage": 0.0
		}

	# ==========================================
	# Accuracy
	# ==========================================

	var final_accuracy := (
		accuracy
		+ user.get_mutagen_accuracy_bonus(self)
	)

	var hit_chance = user.calculate_hit_chance(
		target,
		final_accuracy
	)

	var roll = randi_range(1, 100)

	if roll > hit_chance:

		BattleLog.add_message(
			"But it missed!"
		)

		user.trigger_passive_event(
			"attack_missed",
			{
				"target": target,
				"move": self
			}
		)

		return {
			"hit": false,
			"damage": 0.0
		}

	# ==========================================
	# Damage
	# ==========================================

	var damage = user.calculate_move_damage(
		self
	)

	damage += user.get_mutagen_damage_bonus(
		self
	)

	damage += user.get_mutagen_conditional_damage_bonus(
		self,
		target
	)

	# ==========================================
	# Critical Hit
	# ==========================================

	var user_critical_chance := user.get_critical_chance()

	var mutagen_move_critical := (
		user.get_mutagen_critical_bonus(self)
	)

	var final_critical_chance: int = clamp(
		critical_chance
		+ user_critical_chance
		+ mutagen_move_critical,
		0,
		100
	)

	var is_critical := false

	if randi_range(1, 100) <= final_critical_chance:

		damage *= 2
		is_critical = true

		BattleLog.add_message(
			"Critical hit!"
		)

		user.trigger_passive_event(
			"critical_hit",
			{
				"target": target,
				"move": self,
				"damage": damage,
				"is_critical": true
			}
		)

	return {
		"hit": true,
		"damage": damage,
		"is_critical": is_critical
	}


# ==================================================
# Status Effects
# ==================================================


func apply_effects(
	user: AnimalBase,
	target: AnimalBase
) -> void:

	for effect in effects:

		if effect == null:
			continue

		match effect_target:

			EffectTarget.SELF:

				user.apply_status_effect(
					effect
				)

			EffectTarget.TARGET:

				if target == null:
					continue

				target.apply_status_effect(
					effect
				)
