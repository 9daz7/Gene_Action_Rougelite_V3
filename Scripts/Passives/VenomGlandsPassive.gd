extends PassiveEffect
class_name VenomGlandsPassive


@export var poison_chance := 25
@export var poison_power := 5
@export var poison_duration := 3


func on_after_attack(owner, target, damage):

	var roll = randi_range(1,100)

	if roll <= poison_chance:

		var poison = StatusEffect.new()

		poison.effect_name = "Venom"
		poison.type = StatusEffect.Type.POISON
		poison.power = poison_power
		poison.duration = poison_duration

		target.apply_status_effect(poison)

		print(
			target.name,
			" poisoned"
		)
