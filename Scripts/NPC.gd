extends KinematicBody2D

const GRAVITY = 10
const FLOOR = Vector2(0,-1)

enum states {IDLE,FOLLOWING,ATTACKING,WANDERING,DEAD}

func set_dead_state():
	self.state = states.DEAD
func set_idle_state():self.state = states.IDLE
func set_attacking_state():self.state = states.ATTACKING
func set_wandering_state():self.state = states.WANDERING
func set_following_state():self.state = states.FOLLOWING
#Movement
func move(var motion, var dir, var speed):
	#print("Move")
	if dir == Vector2.UP:
		motion.y = -speed
	elif dir == Vector2.DOWN:
		motion.y = speed
	elif dir == Vector2.LEFT:
		motion.x = -speed
	elif dir == Vector2.RIGHT:
		motion.x = speed
	return motion

#My movement direction
func movementDirection():
	if self.motion.x < 0:
		return Vector2.LEFT
	elif self.motion.x > 0:
		return Vector2.RIGHT

#If I can jump this or nah..
func can_jump(var object):
	var object_height = object.get_child(0).get_shape().extents.y
	var self_height = self.get_node("CollisionShape2D").get_shape().height
	if object_height < self_height:
		return true
	else:
		return false

#Jumping
func jump(var motion,var power):
	power *= 20
	if self.is_on_floor():
		motion = move(motion,Vector2.UP,power)
		return motion
	return motion

#Turning
func turn(var direction):
	########### Flipping the character to Left  ##
		if direction == Vector2.RIGHT:   		##
			self.apply_scale(Vector2(-1,1)) 
			direction = Vector2.LEFT            ##
	##############################################
	
	########### Flipping the character to Right   ##
		elif direction == Vector2.LEFT:           ##
			self.apply_scale(Vector2(-1,1))       ##
			direction = Vector2.RIGHT             ##
	################################################
		return direction
#Meele attacking
func meele_attack():
	self.anim_running = true
	$AnimationPlayer.play("Attack",-1,2)

func DamageAnimation(var dir):
	self.anim_running = true
	if dir == Vector2.LEFT:
		$AnimationPlayer.play("StutterL")
	elif dir == Vector2.RIGHT:
		$AnimationPlayer.play("StutterR")
#Shooting
func shoot():
	pass


# Aiming
func aim(var object):
	
	if object.position < self.position:
		if self.dir == Vector2.RIGHT:
			self.dir = turn(self.dir)
	elif object.position > self.position:
		if self.dir == Vector2.LEFT:
			self.dir = turn(self.dir)
	var Theangle = rad2deg(get_node("Textures/UpperParts/Torso/HeadLRhands/LH/LFA/BulletSpawn2").global_position.angle_to(object.position))
	self.HeadHands.rotation_degrees = -Theangle * 3

#Following
func follow(var motion , var object , var speed,var dir):
	
	var obj_pos = object.position.x
	var my_pos = self.position.x
	var diff = obj_pos - my_pos
	
	#If the player is on the right
	if sign(diff) == 1:
		#Change direction
		if self.dir == Vector2.LEFT:
			self.dir = turn(self.dir)
		#Movement
		motion = move(motion,Vector2.RIGHT,speed*2)
	
	#If the player is on the left
	elif sign(diff) == -1:
		#Change direction
		if self.dir == Vector2.RIGHT:
			self.dir = turn(self.dir)
		#Movement
		motion = move(motion,Vector2.LEFT,speed*2)
	
	#If position are the same
	if diff < 8 && diff > -8:
		if self.dir == Vector2.LEFT:
			self.dir = turn(self.dir)
			self.dir = turn(self.dir)
		elif self.dir == Vector2.RIGHT:
			self.dir = turn(self.dir)
			self.dir = turn(self.dir)
		motion = Vector2(0,0)
	
	#If i encounter a wall in front
	if get_node("RayCast2D").is_colliding() and !get_node("RayCast2DOverHead").is_colliding():
		if "StaticBody2D" in get_node("RayCast2D").get_collider().name:
			if can_jump(get_node("RayCast2D").get_collider()):
				motion = jump(motion,self.jump_height)
				#Thurst in jump
				if movementDirection() == Vector2.RIGHT:
					motion.x += move(motion,Vector2.RIGHT,speed*20).x
				elif movementDirection() == Vector2.LEFT:
					motion.x -= move(motion,Vector2.RIGHT,speed*20).x
	return motion
	
#Taking damage
func damage(var amount,var dir):
	DamageAnimation(dir)
	alert_around()
	if self.health > 0:
		self.health -= amount
		if self.health <= 0:
			set_dead_state()
			die()


#DIE
func die():
	self.anim_running = true
	$AnimationPlayer.play("Death")
	
func printtype():
	print(self.enemy_type)
#Wandering around
func wanderAround(var motion,var mainchar):
	if self.get_node("Textures/UpperParts/Torso/HeadLRhands/Head/RayCast2DSpotter").get_collider() == mainchar:
		if self.enemy_type == "soldier":
			motion = follow(motion,mainchar,self.speed,self.dir)
			set_following_state()
		elif self.enemy_type == "sniper":
			set_attacking_state()
	
	else:
		if self.dir == Vector2.LEFT:
			motion = move(motion,Vector2.LEFT,self.speed/2)
		if self.dir == Vector2.RIGHT:
			motion = move(motion,Vector2.RIGHT,self.speed/2)
		
		# For snipers..for them not to fall
		if self.enemy_type == "sniper":
			if !get_node("FallDetector").is_colliding():
				self.dir = turn(self.dir)
				if self.dir == Vector2.LEFT:
					motion = move(motion,Vector2.LEFT,self.speed)
				elif self.dir == Vector2.RIGHT:
					motion = move(motion,Vector2.RIGHT,self.speed)
		
		# When they encounter a wall
		if self.get_node("RayCast2D").is_colliding():
			if "StaticBody2D" in get_node("RayCast2D").get_collider().name:
				self.dir = turn(self.dir)
				if self.dir == Vector2.LEFT:
					motion = move(motion,Vector2.LEFT,self.speed)
				elif self.dir == Vector2.RIGHT:
					motion = move(motion,Vector2.RIGHT,self.speed)
	return motion

#For alerting enemies near by
func alert_around():
	if get_node("RayCast2DAlerter").is_colliding():
		if "Soldier" in get_node("RayCast2DAlerter").get_collider().name or "Sniper" in get_node("RayCast2DAlerter").get_collider().name:
			get_node("RayCast2DAlerter").get_collider().set_following_state()
	if get_node("RayCast2DSpotter").is_colliding():
		if "Soldier" in get_node("RayCast2DSpotter").get_collider().name or "Sniper" in get_node("RayCast2DSpotter").get_collider().name:
			get_node("RayCast2DSpotter").get_collider().set_following_state()