extends KinematicBody2D

var velocity = Vector2.ZERO
var initial_speed = 3.0

func _ready():
	velocity = Vector2(0,initial_speed*randf()).rotated(PI*2*randf())

func _physics_process(_delta):
	position = position + velocity
	position.x = wrapf(position.x, 0, 1024)
	position.y = wrapf(position.y, 0, 600)
