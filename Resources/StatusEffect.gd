extends Resource
class_name StatusEffect


enum Type
{
	POISON,
	BLEED,
	BURN,
	HEAL,
	SPEED_UP,
	SPEED_DOWN,
	ATTACK_UP,
	ATTACK_DOWN,
	DEFENSE_UP,
	DEFENSE_DOWN
}

@export var effect_name:String
@export var type:Type
@export var power:int = 5
@export var duration:int = 3
@export var stat_modifier := ""

@export var can_stack := true
@export var max_stacks := 3
@export var refresh_duration := true
@export var stack_power := true

var stacks:int = 1


func get_display_text() -> String:

	if stacks > 1:
		return effect_name + " x" + str(stacks) + " (" + str(duration) + ")"

	return effect_name + " (" + str(duration) + ")"


func apply(target: AnimalBase):

	if target == null:
		return

	print(
		effect_name,
		" applied to ",
		target.name
	)

	match type:

		Type.POISON:
			target.take_damage(
				get_total_power(),
				null,
				true
			)

			BattleLog.add_message(
				"%s took %d poison damage!" % [
					target.name,
					get_total_power()
				]
			)

		Type.BLEED:
			target.take_damage(
				get_total_power(),
				null,
				true
			)

			BattleLog.add_message(
				"%s took %d bleed damage!" % [
					target.name,
					get_total_power()
				]
			)

		Type.BURN:
			target.take_damage(
				get_total_power(),
				null,
				true
			)

			BattleLog.add_message(
				"%s took %d burn damage!" % [
					target.name,
					get_total_power()
				]
			)

		Type.HEAL:
			target.heal(
				get_total_power()
			)

		Type.SPEED_UP:
			target.modify_speed(get_total_power())

			print(
				target.name,
				" speed increased by ",
				get_total_power()
			)

		Type.SPEED_DOWN:
			target.modify_speed(-get_total_power())

			print(
				target.name,
				" speed decreased by ",
				get_total_power()
			)

		Type.ATTACK_UP:
			target.modify_attack(get_total_power())

			print(
				target.name,
				" attack increased by ",
				get_total_power()
			)

		Type.ATTACK_DOWN:
			target.modify_attack(-get_total_power())

			print(
				target.name,
				" sttack decreased by ",
				get_total_power()
			)

		Type.DEFENSE_UP:
			target.modify_defense(get_total_power())

			print(
				target.name,
				" defense increased by ",
				get_total_power()
			)

		Type.DEFENSE_DOWN:
			target.modify_defense(-get_total_power())

			print(
				target.name,
				" defense decreased by ",
				get_total_power()
			)


func remove(target: AnimalBase) -> void:

	if target == null:
		return

	var total_power := get_total_power()

	match type:

		Type.SPEED_UP:
			target.modify_speed(-total_power)

		Type.SPEED_DOWN:
			target.modify_speed(total_power)

		Type.ATTACK_UP:
			target.modify_attack(-total_power)

		Type.ATTACK_DOWN:
			target.modify_attack(total_power)

		Type.DEFENSE_UP:
			target.modify_defense(-total_power)

		Type.DEFENSE_DOWN:
			target.modify_defense(total_power)


	print(
		effect_name,
		" removed from ",
		target.name
	)


func get_total_power() -> int:

	if stack_power:
		return power * stacks

	return power


# ==================================================
# Turn Processing
# ==================================================

func process_turn(target: AnimalBase):

	if target == null:
		return

	if not is_instance_valid(target):
		return

	if not target.is_alive():
		return

	match type:

		Type.POISON:

			var damage := get_total_power()

			BattleLog.add_message(
				"%s took %d poison damage!" % [
					target.name,
					damage
				]
			)

			target.take_status_damage(
				damage
			)


		Type.BLEED:

			var damage := get_total_power()

			BattleLog.add_message(
				"%s took %d bleed damage!" % [
					target.name,
					damage
				]
			)

			target.take_status_damage(
				damage
			)


		Type.BURN:

			var damage := get_total_power()

			BattleLog.add_message(
				"%s took %d burn damage!" % [
					target.name,
					damage
				]
			)

			target.take_status_damage(
				damage,
			)

		Type.HEAL:

			var healing := get_total_power()

			target.heal(
				healing
			)

			BattleLog.add_message(
				"%s recovered %d HP!" % [
					target.name,
					healing
				]
			)

func apply_stack(
	target: AnimalBase,
	amount:int
) -> void:

	if target == null:
		return

	if amount <= 0:
		return

	var stack_amount := power * amount

	match type:

		Type.SPEED_UP:
			target.modify_speed(
				stack_amount
			)

		Type.SPEED_DOWN:
			target.modify_speed(
				-stack_amount
			)

		Type.ATTACK_UP:
			target.modify_attack(
				stack_amount
			)

		Type.ATTACK_DOWN:
			target.modify_attack(
				-stack_amount
			)

		Type.DEFENSE_UP:
			target.modify_defense(
				stack_amount
			)

		Type.DEFENSE_DOWN:
			target.modify_defense(
				-stack_amount
			)

	print(
		effect_name,
		" applied ",
		amount,
		" stack(s) to ",
		target.name
	)
