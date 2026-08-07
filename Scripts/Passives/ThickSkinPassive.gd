extends PassiveEffect
class_name ThickSkinPassive


@export var damage_reduction := 0.20


func on_before_damage(
	owner,
	damage_data: Dictionary
):

	var original_damage = damage_data.amount


	var reduced_damage = original_damage * (
		1.0 - damage_reduction
	)


	print(
		owner.name,
		" Thick Hide reduced damage:",
		original_damage,
		"->",
		reduced_damage
	)


	damage_data.amount = int(reduced_damage)


	if not damage_data.has("messages"):

		damage_data["messages"] = []


	damage_data.messages.append(
		"%s's Thick Hide reduced damage!" % owner.name
	)
