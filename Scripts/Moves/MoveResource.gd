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


# ==================================================
# Targeting
# ==================================================

@export var target_type: TargetType = TargetType.SINGLE_ENEMY

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


# ==================================================
# Effects
# ==================================================

@export var effects: Array[StatusEffect] = []
@export var effect_target: EffectTarget = EffectTarget.TARGET


# ==================================================
# Execution
# ==================================================


func execute(
	user: AnimalBase,
	target: AnimalBase
) -> void:

	BattleLog.add_message(
		""
	)

	BattleLog.add_message(
		"%s used %s!" % [
			user.name,
			move_name
		]
	)

	print(
		"Executing move:",
		move_name,
		" Priority:",
		priority
	)

	var targets = get_targets(
		user,
		target
	)

	for current_target in targets:
		
		if current_target == null:
			continue

		await execute_on_target(
			user,
			current_target
		)


func execute_on_target(
	user:AnimalBase,
	target:AnimalBase
) -> void:

	match effect_type:

		MoveEffectType.STATUS:

			apply_effects(
				user,
				target
			)


		MoveEffectType.PROTECT:

			user.activate_protect()

			apply_effects(
				user,
				user
			)


		MoveEffectType.DAMAGE:

			user.trigger_passive_event(
				"before_attack",
				{
					"target": target,
					"move": self
				}
			)

			execute_damage(
				user,
				target,
				false
			)


		MoveEffectType.HYBRID:

			user.trigger_passive_event(
				"before_attack",
				{
					"target": target,
					"move": self
				}
			)

			execute_damage(
				user,
				target,
				true
			)


# ==================================================
# Targeting
# ==================================================


func get_targets(
	user:AnimalBase,
	target:AnimalBase
)->Array:


	match target_type:

		TargetType.SINGLE_ENEMY:

			if target:
				return [target]


		TargetType.SELF:

			return [user]


		TargetType.ALL_ENEMIES:

			return user.get_opponents()


		TargetType.SINGLE_ALLY:

			if target:
				return [target]


		TargetType.ALL_ALLIES:

			return user.get_all_allies()


	return []


# ==================================================
# Damage Execution
# ==================================================


func execute_damage(
	user: AnimalBase,
	target: AnimalBase,
	apply_status: bool
) -> void:

	if target == null:
		return

	if not is_instance_valid(target):
		return

	print(
		"TARGET VALID:",
		is_instance_valid(target)
	)

	print(
		"TARGET HP:",
		target.hp
	)

	# ==========================================
	# Accuracy
	# ==========================================

	var hit_chance = user.calculate_hit_chance(
		target,
		accuracy
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

		return

	# ==========================================
	# Damage
	# ==========================================
	
	var damage = user.calculate_move_damage(
		self
	)

	# ==========================================
	# Critical Hit
	# ==========================================

	var user_critical_chance := user.get_critical_chance()

	var final_critical_chance: int = clamp(
		critical_chance + user.get_critical_chance(),
		0,
		100
	)
	#var final_critical_chance: int = (
		#critical_chance
		#+ user.get_critical_chance()
	#)

	print(
		"CRITICAL DEBUG | Move:",
		move_name,
		" | Move Crit:",
		critical_chance,
		" | User Crit:",
		user.get_critical_chance(),
		" | Final Crit:",
		final_critical_chance
	)

	if randi_range(1, 100) <= final_critical_chance:

		damage *= 2

		BattleLog.add_message(
			"Critical hit!"
		)

		user.trigger_passive_event(
			"critical_hit",
			{
				"target": target,
				"move": self,
				"damage": damage
			}
		)

	# ==========================================
	# Attack Information
	# ==========================================

	print("")
	print("ATTACK")
	print("Attacker:", user.name)
	print("Attacker ID:", user.get_instance_id())
	print("Target:", target.name)
	print("Target ID:", target.get_instance_id())
	print("Target HP BEFORE:", target.hp)
	print("Damage:", damage)

	# ==========================================
	# Apply Damage
	# ==========================================

	target.take_damage(
		damage,
		user
	)

	# ==========================================
	# Kill
	# ==========================================

	if target.hp <= 0:

		user.trigger_passive_event(
			"kill",
			{
				"target": target,
				"move": self
			}
		)

	# ==========================================
	# After Attack
	# ==========================================

	user.trigger_passive_event(
		"after_attack",
		{
			"target": target,
			"move": self,
			"damage": damage
		}
	)

	# ==========================================
	# Status Effects
	# ==========================================

	if apply_status:
		apply_effects(
			user,
			target
		)


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
