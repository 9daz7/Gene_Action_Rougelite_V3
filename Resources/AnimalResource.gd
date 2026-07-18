extends Resource
class_name AnimalResource


@export var animal_name:String
@export var description:String
@export var icon:Texture2D
@export var base_hp := 100
@export var base_attack := 10
@export var base_speed := 10
@export var base_defense := 0

# Every animal starts with these

@export var basic_attack:MoveResource
@export var protect:MoveResource
