extends CharacterBody2D

@export var speed:float = 200
@export var health:float = 100
@onready var progress_bar = $ProgressBar


func _ready() -> void:
	progress_bar.max_value = health
	progress_bar.value = health

func _physics_process(delta: float) -> void:
	velocity = Vector2(-speed, 0)
	move_and_slide()
	#global_position += Vector2(-speed * delta, 0)
	return 

func take_damage(damage: float):
	health -= damage
	progress_bar.value = health
	
	if health <= 0:
		queue_free()
	print()
