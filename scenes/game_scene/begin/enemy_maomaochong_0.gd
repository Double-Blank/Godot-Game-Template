extends CharacterBody2D

@export var speed:float = 200
@export var health:float = 100
@onready var health_bar = $ProgressBar
@export var impact_damage:float = 5

func _ready() -> void:
	health_bar.max_value = health
	health_bar.value = health

func _physics_process(delta: float) -> void:
	velocity = Vector2(-speed, 0)
	move_and_slide()
	
	#碰撞检测
	var collection_count = get_slide_collision_count()
	for i in collection_count:
		var collision_info = get_slide_collision(i)
		var collider = collision_info.get_collider()
		if collider.has_method("take_damage"):
			collider.take_damage(impact_damage)
			queue_free()
	#global_position += Vector2(-speed * delta, 0)
	return 

func take_damage(damage: float):
	health -= damage
	health_bar.value = health
	
	if health <= 0:
		queue_free()
	print()
