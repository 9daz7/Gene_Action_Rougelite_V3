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

	print(
		"Executing move:",
		move_name,
		" Priority:",
		priority
	)

	match effect_type:

		MoveEffectType.STATUS:

			print(
				user.name,
				" uses ",
				move_name
			)

			apply_effects(user, target)


		MoveEffectType.PROTECT:

			print(
				user.name,
				" uses ",
				move_name
			)

			user.activate_protect()

			apply_effects(user, target)


		MoveEffectType.DAMAGE:
			execute_damage(user, target, false)

		
		MoveEffectType.HYBRID:
			execute_damage(user, target, true)
			
			var hit_chance = user.calculate_hit_chance(
				target,
				accuracy
			)

			var roll = randi_range(1, 100)

			if roll > hit_chance:

				print(
					user.name,
					" missed"
				)

				return

			var damage = user.calculate_move_damage(self)

			damage = target.calculate_damage_taken(damage)

			print(
				user.name,
				" deals ",
				damage,
				" damage"
			)

			target.take_damage(damage)

			if effect_type == MoveEffectType.HYBRID:
				apply_effects(user, target)


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

		print(
			user.name,
			" missed"
		)

		return

	var damage = user.calculate_move_damage(self)

	damage = target.calculate_damage_taken(damage)

	print(
		user.name,
		" deals ",
		damage,
		" damage"
	)

	target.take_damage(
		damage,
		user
	)

	if apply_status:
		apply_effects(user, target)


func apply_effects(
	user: AnimalBase,
	target: AnimalBase
):

	for effect in effects:

		if effect == null:
			continue

		match effect_target:

			EffectTarget.SELF:
				effect.apply(user)

			EffectTarget.TARGET:
				effect.apply(target)
