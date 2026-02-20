extends StaticBody2D

@onready var timer = $Timer
@export var health:float = 500
@onready var health_bar = $HealthBar
var bullet_scene = preload("res://scenes/game_scene/begin/bullet-green/greenbullet.tscn")

func _ready():
	health_bar.value = health
	timer.start()
	print(timer, "timer.start")

func shoot_bullet():
	var new_bullet = bullet_scene.instantiate()
	# 将子弹添加到父节点（Level1）而不是塔本身
	get_parent().add_child(new_bullet)
	# 设置子弹的初始位置为塔的位置
	new_bullet.global_position = Vector2(0, 0)

func _on_timer_timeout():
	shoot_bullet()

func take_damage(damage: float):
	health -= damage
	health_bar.value = health
	
	if health <= 0:
		queue_free()
	print()
