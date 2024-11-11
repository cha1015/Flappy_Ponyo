extends CollisionShape2D

signal hit

func _on_trunk_body_entered(body):
	hit.emit()
