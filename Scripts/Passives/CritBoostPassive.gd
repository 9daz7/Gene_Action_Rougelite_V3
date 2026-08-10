extends PassiveEffect
class_name CritBoostPassive


@export var critical_bonus := 20

func modify_critical_chance(owner, chance: int) -> int:

	return chance + critical_bonus
