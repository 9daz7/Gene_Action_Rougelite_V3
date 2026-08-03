extends PassiveEffect
class_name PoisonFangsPassive


@export var poison_chance := 30
@export var poison_duration := 3
@export var poison_damage := 5

func on_after_attack(
	owner,
	target,
	damage
):

	var roll = randi_range(
		1,
		100
	)

	if roll <= poison_chance:

		print(
			target.name,
			" was poisoned!"
		)

		var poison = StatusEffect.new()

		poison.type = StatusEffect.Type.POISON
		poison.power = poison_damage
		poison.duration = poison_duration
		poison.effect_name = "Venom"

		target.apply_status_effect(
			poison
		)
