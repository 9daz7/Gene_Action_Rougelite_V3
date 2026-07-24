extends Resource
class_name AnimalResource


# ---------------------------------------
# Identity
# ---------------------------------------

@export var animal_name:String = "Dog"
#@export var animal_name:String
#@export var description:String
#@export var icon:Texture2D

# ---------------------------------------
# Base Stats
# ---------------------------------------

@export var base_hp:int = 100
@export var base_attack:int = 8
@export var base_defense := 5
@export var base_speed:int = 12
#@export var base_hp := 100
#@export var base_attack := 8
#@export var base_speed := 10


# ---------------------------------------
# Starting Moves
# ---------------------------------------

@export var starter_moves:Array[MoveResource] = []

# Every animal starts with these
#
#@export var basic_attack:MoveResource
#@export var protect:MoveResource
