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

@export var effect_type : MoveEffectType = MoveEffectType.DAMAGE

# --------------------------------------------------
# Basic Move Info
# --------------------------------------------------

@export var move_name: String = "Unnamed Move"
@export var power: int = 0
@export var description: String = ""

# --------------------------------------------------
# Combat
# --------------------------------------------------

@export var priority: int = 0
@export var accuracy: int = 100

# Type of move
@export var category: MoveCategory = MoveCategory.BIOLOGICAL

# Future critical hit system
@export var critical_chance: int = 0

# --------------------------------------------------
# Status Effects
# --------------------------------------------------

@export var effects: Array[StatusEffect] = []

enum EffectTarget {
	SELF,
	TARGET
}

@export var effect_target: EffectTarget = EffectTarget.TARGET
@export var effect_target_self := false


func execute(user, target):
	
	print(
		"Executing move:",
		move_name,
		" Priority:",
		priority
	)


	# -----------------------------
	# STATUS ONLY MOVE
	# -----------------------------

	if effect_type == MoveEffectType.STATUS:

		print(
			user.name,
			" uses ",
			move_name
		)

		for effect in effects:
			if effect_target_self:
				effect.apply(user)
			else:
				effect.apply(target)

		return
	
	
	# -----------------------------
	# PROTECT
	# -----------------------------

	if effect_type == MoveEffectType.PROTECT:

		print(
			user.name,
			" uses Protect"
		)

		user.activate_protect()
		return


	# -----------------------------
	# DAMAGE MOVE
	# -----------------------------

	var hit_chance = user.calculate_hit_chance(
		target,
		accuracy
	)

	var roll = randi_range(1,100)

	if roll > hit_chance:

		print(
			user.name,
			" missed"
		)

		return


	var damage = user.get_attack() + power

	damage = target.calculate_damage_taken(damage)

	print(
		user.name,
		" deals ",
		damage,
		" damage"
	)

	target.take_damage(damage)


	# Apply extra effects after damage
	for effect in effects:
		effect.apply(target)
		
	
#func execute(user, target):
	#print(
		#"Executing move:",
		#move_name,
		#" Priority:",
		#priority
	#)
	#
	## -----------------------------------------
	## Protect
	## -----------------------------------------
	#
	#if effect_type == MoveEffectType.PROTECT:
		#user.activate_protect()
		#
		#print(user.name, " uses protect")
		#
		#return
#
#
	## -----------------------------------------
	## Damage
	## -----------------------------------------
	#
	#
	#if effect_type == MoveEffectType.DAMAGE:
		#
		#var hit_chance = user.calculate_hit_chance(target, accuracy)
		#
		#var roll = randi_range(1,100)
		#
		#if roll > hit_chance:
			#print(user.name," missed")
			#return
			#
	#var damage = user.get_attack() + power
#
	#damage = target.calculate_damage_taken(damage)
#
	#target.take_damage(damage)
	#
	## -----------------------------------------
	## Status effects
	## -----------------------------------------
	#
	#for effect in effects:
	#
		#if effect_target == EffectTarget.SELF:
			#effect.apply(user)
			#
		#else:
			#effect.apply(target)
