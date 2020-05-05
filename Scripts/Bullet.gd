extends RigidBody2D

func _ready():
	pass

func fire(pos, dir):
	position = pos
	set_linear_velocity(Vector2(dir.x * 8000,dir.y * 8000))

func _process(delta):
	pass


func _on_Timer_timeout():
	queue_free()

func _on_Bullet_body_entered(body):
	if "Soldier" in body.name:
		var bp = body.position
		if bp > self.position:
			body.damage(20,Vector2.LEFT)
			body.set_following_state()
		elif bp < self.position:
			body.damage(20,Vector2.RIGHT)
			body.set_following_state()
