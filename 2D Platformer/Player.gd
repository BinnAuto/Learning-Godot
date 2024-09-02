extends CharacterBody2D

var moveSpeed:float = 50.0;
var jumpForce:float = 450.0;
var gravity:float = 500.0;
var gameOverThreshold:float = 100;

var grounded:bool = false;
var facingRight:bool = true;
var crouchPressed:bool = false;
var jumpPressed:bool = false;
var jumpHeld:bool = false;
var leftPressed:bool = false;
var rightPressed:bool = false;
var runPressed:bool = false;
var escPressed:bool = false;

## This serves as the main game loop
func _physics_process(delta: float):
	storeInputs();
	processInput(delta);
	$AnimatedSprite.animation = getAnimation();
	move_and_slide(); ## Apply character movement from processInput() to engine
	if (global_position.y > gameOverThreshold):
		gameOver();

## Stores current input status for use in other functions
func storeInputs():
	grounded = is_on_floor();
	crouchPressed = Input.is_key_pressed(KEY_DOWN);
	jumpPressed = Input.is_key_pressed(KEY_UP) || Input.is_key_pressed(KEY_SPACE); ## TODO: Check for just pressed, not held
	jumpHeld = Input.is_key_pressed(KEY_UP) || Input.is_key_pressed(KEY_SPACE);
	leftPressed = Input.is_key_pressed(KEY_LEFT);
	rightPressed = Input.is_key_pressed(KEY_RIGHT);
	runPressed = Input.is_key_pressed(KEY_SHIFT);
	escPressed = Input.is_key_pressed(KEY_ESCAPE);
		
## Processes input status and calculates character movement
func processInput(delta: float):
	if(escPressed):
		gameOver();
		
	velocity.x /= 1.5;
	if(velocity.y < 0):
		velocity.y /= 1.1 if jumpHeld else 1.4;
	
	if (!grounded):
		velocity.y += gravity * delta;
		
	if(abs(velocity.x) < 0.1):
		velocity.x = 0;
		
	if (crouchPressed): # Crouching
		return;
		
	var deltaX:float = moveSpeed;
	if (runPressed):
		deltaX *= 1.3;
	if (leftPressed): # Walk left
		velocity.x -= deltaX;
	if (rightPressed): # Walk right
		velocity.x += deltaX;
		
	if (grounded && jumpPressed): # Jump
		velocity.y = -jumpForce;
	
## Determines which animation to play
func getAnimation():
	if(velocity.x < 0):
		facingRight = false;
	facingRight = facingRight || velocity.x > 0;
	var suffix:String = ("_R" if facingRight else "_L");
	
	if(!grounded):
		if(velocity.y > 0):
			return "jump_fall" + suffix;
		else:
			return "jump_rise" + suffix;
			
	if(crouchPressed):
		return "crouch" + suffix;
			
	if(velocity.x == 0):
		return "stand" + suffix;
		
	if(leftPressed != rightPressed):
		return "walk" + suffix;
		
	return "stand" + suffix;
	
	
func gameOver():
	get_tree().reload_current_scene();
