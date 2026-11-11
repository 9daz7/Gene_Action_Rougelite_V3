extends CharacterBody3D

@export var target: CharacterBody3D
@export var follow_distance: float = 1.5
@export var move_speed: float = 4.0


# --------------------------------------------------
# Health
# --------------------------------------------------

signal health_changed(current_health: float, max_health: float)
signal died

@export var max_health: float = 100.0

var current_health: float = -1.0
var is_dead: bool = false
var combat_disabled: bool = false

var protect_timer: float = 0.0
var protect_reduction: float = 0.6


# --------------------------------------------------
# Basic Attack
# --------------------------------------------------

@export var attack_damage: float = 10.0
@export var attack_range: float = 2.0
@export var attack_cooldown: float = 0.8

var can_attack: bool = true


func _ready() -> void:

	if current_health < 0.0:
		current_health = max_health

	health_changed.emit(current_health, max_health)


func _physics_process(delta: float) -> void:

	if protect_timer > 0.0:
		protect_timer = maxf(protect_timer - delta, 0.0)

	if is_dead:
		velocity = Vector3.ZERO

#func _physics_process(_delta: float) -> void:
#
	#if is_dead:
		#velocity = Vector3.ZERO
		#move_and_slide()
		#return
#
	#if target == null:
		#return
#
	#var offset := target.global_position - global_position
	#offset.y = 0.0
#
	#var distance := offset.length()
#
	#if distance > follow_distance:
		#var direction := offset.normalized()
#
		#velocity.x = direction.x * move_speed
		#velocity.z = direction.z * move_speed
	#else:
		#velocity.x = 0.0
		#velocity.z = 0.0
#
	#move_and_slide()


func heal(amount: float) -> void:

	if is_dead or amount <= 0.0:
		return

	var previous_health := current_health
	current_health = minf(current_health + amount, max_health)

	if current_health != previous_health:
		health_changed.emit(current_health, max_health)
		print("DEEBO HEALED: ", current_health, "/", max_health)


func take_damage(amount: float, attacker: Node3D = null) -> void:

	if combat_disabled or is_dead or amount <= 0.0:
		return

	var final_damage := amount

	if protect_timer > 0.0:
		final_damage *= (1.0 - protect_reduction)

	current_health = maxf(current_health - final_damage, 0.0)
	health_changed.emit(current_health, max_health)

	print("Deebo health: ", current_health, "/", max_health)

	if current_health <= 0.0:
		_die()


func _die() -> void:

	if is_dead:
		return

	is_dead = true
	velocity = Vector3.ZERO
	died.emit()

	print("Deebo has been defeated.")
