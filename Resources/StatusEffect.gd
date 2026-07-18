extends Resource
class_name StatusEffect


enum Type
{
	POISON,
	BLEED,
	BURN,
}

@export var effect_name:String
@export var type:Type
@export var power:int = 5
@export var duration:int = 3


func apply(target):
	target.status_effects.append(self)

	print(
		effect_name,
		" applied to ",
		target.name
	)
