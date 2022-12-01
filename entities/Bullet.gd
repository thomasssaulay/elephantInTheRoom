extends Area2D

var velocity = Vector2.ZERO

func _physics_process(delta):
	position += transform.x * Globals.BULLET_SPEED * delta
	
func _on_Bullet_body_entered(body):
	if body.is_in_group("npc"):
		body.kill()
	queue_free()
