extends Resource
class_name MoveResource


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

@export var target_type = TargetType.SINGLE_ENEMY

# ==================================================
# Basic Move Info
# ==================================================-

@export var move_name: String = "Unnamed Move"
@export var description: String = ""

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
):

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

		execute_on_target(
			user,
			current_target
		)


func execute_on_target(
	user:AnimalBase,
	target:AnimalBase
):

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
					"target":target
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
					"target":target
				}
			)

			execute_damage(
				user,
				target,
				true
			)


func get_targets(
	user:AnimalBase,
	target:AnimalBase
)->Array:


	match target_type:


		TargetType.SINGLE_ENEMY:

			return [target]


		TargetType.SELF:

			return [user]


		TargetType.ALL_ENEMIES:

			var targets = user.get_all_enemies()

			return targets


		TargetType.SINGLE_ALLY:

			return [target]


		TargetType.ALL_ALLIES:

			return user.get_all_allies()


	return []


# ==================================================
# Effects
# ==================================================


func execute_damage(
	user: AnimalBase,
	target: AnimalBase,
	apply_status: bool
):

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
				"target": target
			}
		)

		return


	var damage = user.calculate_move_damage(self)

	if randi_range(1,100) <= critical_chance:

		damage *= 2

		BattleLog.add_message(
			"Critical hit!"
		)

		user.trigger_passive_event(
			"critical_hit",
			{
				"target":target,
				"damage":damage
			}
		)

	target.take_damage(
		damage,
		user
	)


	if target.hp <= 0:

		user.trigger_passive_event(
			"kill",
			{
				"target":target
			}
		)

	user.trigger_passive_event(
		"after_attack",
		{
			"target":target,
			"damage":damage
		}
	)

	if apply_status:
		apply_effects(user,target)


func apply_effects(
	user: AnimalBase,
	target: AnimalBase
):

	for effect in effects:

		if effect == null:
			continue

		match effect_target:

			EffectTarget.SELF:

				user.apply_status_effect(effect)

				user.trigger_passive_event(
					"status_applied",
					{
						"status":effect,
						"target":target
					}
				)

			EffectTarget.TARGET:

				target.apply_status_effect(effect)

				target.trigger_passive_event(
					"status_received",
					{
						"status":effect,
						"source":user
					}
				)
