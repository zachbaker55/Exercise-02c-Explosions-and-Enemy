# Exercise-02c-Explosions-and-Enemy

Exercise for MSCH-C220

A demonstration of this exercise is available at [https://youtu.be/wsiN_nkF3Nw](https://youtu.be/wsiN_nkF3Nw).

Fork the repository. When that process has completed, make sure that the top of the repository reads `[your username]/Exercise-02c-Explosions-and-Enemy`. Edit the LICENSE and replace BL-MSCH-C220-F22 with your full name. Commit your changes.

Press the green "Code" button and select "Open in GitHub Desktop". Allow the browser to open (or install) GitHub Desktop. Once GitHub Desktop has loaded, you should see a window labeled "Clone a Repository" asking you for a Local Path on your computer where the project should be copied. Choose a location; make sure the Local Path ends with "Exercise-02c-Explosions-and-Enemy" and then press the "Clone" button. GitHub Desktop will now download a copy of the repository to the location you indicated.

Open Godot. In the Project Manager, tap the "Import" button. Tap "Browse" and navigate to the repository folder. Select the project.godot file and tap "Open".

You will now see where we left off in Exercise-02b: Your ship and two asteroids should occupy the playing area. The ship should be able to maneuver and shoot.

This is what you will need to accomplish as part of this exercise:

Explosion:
  - Create a new Explosion scene. The root of the scene should be an AnimatedSprite node named Explosion. In the Inspector Panel->Frames, select new SpriteFrames, and then edit the new SpriteFrames. In the AnimationFrames section of the bottom panel, choose Add Frames from a Sprite Sheet. Select all 64 frames from res://Assets/Explosion.png (8 horizontal and 8 vertical). Set the speed to 100 FPS and make sure Loop is off. Back in the Inspector, set the Offset to (0,-30).
  - Add a script to the Explosion node. In the `_ready()` callback, play the "default" animation
  - Add an `animation_finished` signal to the Explosion node. When the animation has completed, it should `queue_free()`
  - Save the scene as res://Effects/Explosion.tscn

In res://Player/Bullet.gd
  - Create variables for Effects (which can be initialized to null) and Explosion. Load the res://Effects/Explosion.tscn scene into the Explosion variable
  - Update the `_on_Area2d_Body_Entered(body)` callback to the following:
  ```
  func _on_Area2D_body_entered(body):
	if body.has_method("damage"):
		body.damage(damage)
	Effects = get_node_or_null("/root/Game/Effects")
	if Effects != null:
		var explosion = Explosion.instance()
		Effects.add_child(explosion)
		explosion.global_position = global_position
	queue_free()
  ```

In res://Player/Player.gd
  - Create a variable for Explosion. Load the res://Effects/Explosion.tscn scene into the Explosion variable
  - Create a variable health. Initialize health to 10
  - Create a new function called damage (it should accept a parameter d):
  ```
func damage(d):
	health -= d
	if health <= 0:
		Effects = get_node_or_null("/root/Game/Effects")
		if Effects != null:
			var explosion = Explosion.instance()
			Effects.add_child(explosion)
			explosion.global_position = global_position
			hide()
			yield(explosion, "animation_finished")
		queue_free()
  ```
  
In the res://Player/Player.tscn scene:
  - Add an Area2D node as child of Player
  - Add a CollisionPolygon2D as a child of Area2D. In the Viewport, add points of the polygon until you have a shape slightly larger than the sprite.
  - Attach a `body_entered(body)` Signal to the Area2D node (it should connect back to res://Player/Player.gd). If any body (other than body.name == "Player") enters the Area2D, it should generate 100 damage to the player.

Asteroid_Small:
  - Create a new scene (you will ultimately save it as res://Asteroid/Asteroid_Small.tscn). Make it identical to res://Asteroid/Asteroid.tscn, except use the res://Assets/Asteroid_Small.png texture for the sprite (with a corresponding CollisionPolygon2D)
  - Add a script to the Asteroid_Small KinematicBody2D node. The script should be as follows:
  ```
extends KinematicBody2D

var health = 1
var velocity = Vector2.ZERO

var Effects = null
onready var Explosion = load("res://Effects/Explosion.tscn")

func _physics_process(_delta):
	position += velocity
	position.x = wrapf(position.x,0,Global.VP.x)
	position.y = wrapf(position.y,0,Global.VP.y)

func damage(d):
	health -= d
	if health <= 0:
		Effects = get_node_or_null("/root/Game/Effects")
		if Effects != null:
			var explosion = Explosion.instance()
			Effects.add_child(explosion)
			explosion.global_position = global_position
		queue_free()
  ```
  - Save the scene as res://Asteroid/Asteroid_Small.tscn


Now, we should edit res://Asteroid/Asteroid.gd:
  - Add the following variables:
  ```
onready var Asteroid_small = load("res://Asteroid/Asteroid_small.tscn")
var small_asteroids = [Vector2(0, -30), Vector2(30,30), Vector2(-30,30)]
var health = 1
  ```
  - Now, add a new `damage(d)` function:
  ```
func damage(d):
	health -= d
	if health <= 0:
		collision_layer = 0
		var Asteroid_Container = get_node_or_null("/root/Game/Asteroid_Container")
		if Asteroid_Container != null:
			for s in small_asteroids:
				var asteroid_small = Asteroid_small.instance()
				var dir = randf()*2*PI
				var i = Vector2(0,randf()*small_speed).rotated(dir)
				Asteroid_Container.call_deferred("add_child", asteroid_small)
				asteroid_small.position = position + s.rotated(dir)
				asteroid_small.velocity = i
		queue_free()
  ```

Next, we need a bullet for the enemy to shoot:
  - Create a scene, indentical (for now) to the res://Player/Bullet.tscn, but save it in res://Enemy/Bullet.tscn. It should have a separate script: res://Enemy/Bullet.gd

Finally, we need to create the enemy:
  - Create a new KinematicBody2D scene. Name the root node Enemy
  - Add a Sprite child node. Its texture should be res://Assets/Enemy.png
  - Create a CollisionPolygon2D Sibling for the Sprite
  - Add a Timer child node to Enemy, set the Wait Time to 2.0 and set Autostart to on
  - Add an Area2D child node to Enemy. As a child of the Area2D node, add a CollisionShape2D (CircleShape2D) with a radius of 40.
  - Add a script (res://Enemy/Enemy.gd) to the Enemy node
  - Attach a `timeout()` Signal to the Timer. The resulting callback (in Enemy.gd) should be as follows:
  ```
func _on_Timer_timeout():
  var Player = get_node_or_null("/root/Game/Player_Container/Player")
  Effects = get_node_or_null("/root/Game/Effects")
  if Player != null and Effects != null:
    var bullet = Bullet.instance()
    var d = global_position.angle_to_point(Player.global_position) - PI/2
    bullet.rotation = d
    bullet.position = global_position + Vector2(0, -40).rotated(d)
    Effects.add_child(bullet)
  ```
  - Then Attach a `body_entered(body)` Signal to the Area2D node. The resulting callback (in Enemy.gd) should be as follows:
  ```
  func _on_Area2D_body_entered(body):
	if body.name == "Player":
		body.damage(100)
		damage(100)
  ```
  - The variables for the Enemy should be as follows:
  ```
var y_positions = [100,150,200,500,550]
var initial_position = Vector2.ZERO
var direction = Vector2(1.5,0)
var wobble = 30.0

var health = 1

var Effects = null
onready var Bullet = load("res://Enemy/Bullet.tscn")
onready var Explosion = load("res://Effects/Explosion.tscn")
  ```
  - The `_ready()` and `_physics_process(_delta)` callbacks should be as follows:
  ```
func _ready():
	initial_position.x = -100
  initial_position.y = y_positions[randi() % y_positions.size()]
	position = initial_position

func _physics_process(_delta):
	position += direction
	position.y = initial_position.y + sin(position.x/20)*wobble
	if position.x > 1200:
		queue_free()
  ```
  - The Enemy should have a damage function, similar to the small asteroid

In res://Game.tscn
  - As a child of the Game node, add a Node2D. Rename it Enemy_Container. As a child of Enemy_Container, Add Child Instance: res://Enemy/Enemy.tscn
  - Right-click on the Player node. Choose "Save Branch as Scene": res://Player/Player.tscn. Delete the Player node and all of its children
  - As a child of the Game node, add a Node2D. Rename it Player_Container. Add a script to Player_Container: res://Player/Player_Container.gd
  - The contents of res://Player/Player_Container.gd should be as follows:
  ```
extends Node2D

onready var Player = load("res://Player/Player.tscn")

func _physics_process(_delta):
	if get_child_count() == 0:
		var player = Player.instance()
		player.position = Vector2(512,300)
		add_child(player)
  ```


Test it and make sure this is working correctly. You should see an enemy ship oscillate across the screen, shooting at the player every two seconds. The bullets should now break up the big asteroids into smaller ones, and the smaller asteroids and the enemy should be killed by the bullets. There should be explosions everywhere. If the player is hit, the ship should blow up and then respawn.

Quit Godot. In GitHub desktop, you should now see the updated files listed in the left panel. In the bottom of that panel, type a Summary message (something like "Completes the exercise") and press the "Commit to master" button. On the right side of the top, black panel, you should see a button labeled "Push origin". Press that now.

If you return to and refresh your GitHub repository page, you should now see your updated files with an indication of when they were changed.

Now edit the README.md file. When you have finished editing, commit your changes, and then turn in the URL of the main repository page (`https://github.com/[username]/Exercise-Explosions-and-Enemy`) on Canvas.

The final state of the file should be as follows (replacing my information with yours):
```
# Exercise-02c-Explosions-and-Enemy

Exercise for MSCH-C220

A user-controlled ship in a space-shooter game. Explosions! Asteroids! Smaller asteroids! An alien ship!. Created in Godot.

## Implementation

Created using [Godot 3.5](https://godotengine.org/download)

Assets are provided by [Kenney.nl](https://kenney.nl/assets/space-shooter-extension), provided under a [CC0 1.0 Public Domain License](https://creativecommons.org/publicdomain/zero/1.0/).

The explosion spritesheet was released into the public domain by [StumpyStrust](https://opengameart.org/content/explosion-sheet)

## References
None

## Future Development
Score, lives, game-start and game-end screens. In-game menu.

## Created by
Jason Francis
```
