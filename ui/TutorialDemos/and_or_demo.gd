extends Node2D


@onready var demo_player: AnimationPlayer = $DemoPlayer


func _ready() -> void:
	demo_player.play("RESET")
	demo_player.play("demo")
