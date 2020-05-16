
# --------------------------------------------------------------------------------------------------

.include "convenience.asm"
.include "display.asm"

.eqv GAME_TICK_MS      	16
.eqv MAX_BULLETS	13

.data

# --------------------------------------------------------------------------------------------------
# @description	used by the waiting method

last_frame_time:  		.word 0
frame_counter:    		.word 0
next_available_frame:		.word 0
next_available_enemy_frame:	.word 0
next_frame_to_shoot:		.word 0
next_frame_for_enemy_shot:	.word 0
end_invincible_frame:		.word 0


# --------------------------------------------------------------------------------------------------
# @description	any ship related variables go here
#		this includes:
#			- x value of a ship
#			- y value of a ship
#			- color array for a ship

ship_x:		.word 2
ship_y:		.word 46
ship_image:	.byte COLOR_BLACK, COLOR_BLACK, COLOR_WHITE, COLOR_BLACK, COLOR_BLACK, 
		      COLOR_BLACK, COLOR_RED, COLOR_WHITE, COLOR_RED, COLOR_BLACK,
		      COLOR_RED, COLOR_BLUE, COLOR_WHITE, COLOR_BLUE, COLOR_RED,
		      COLOR_RED, COLOR_BLUE, COLOR_BLACK, COLOR_BLUE, COLOR_RED,
		      COLOR_WHITE, COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, COLOR_WHITE
invincible_image:	.byte COLOR_BLACK, COLOR_BLACK, COLOR_ORANGE, COLOR_BLACK, COLOR_BLACK, 
		      	      COLOR_BLACK, COLOR_RED, COLOR_ORANGE, COLOR_RED, COLOR_BLACK,
		              COLOR_RED, COLOR_BLUE, COLOR_ORANGE, COLOR_BLUE, COLOR_RED,
		              COLOR_RED, COLOR_BLUE, COLOR_BLACK, COLOR_BLUE, COLOR_RED,
		              COLOR_ORANGE, COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, COLOR_ORANGE
		      
		      
# --------------------------------------------------------------------------------------------------
# @description	any player related variables go here
#		this includes:
#			- a count of the player's lives
#			- a count of the player's remaining bullets

lives:		.word 3
shots:		.word 50
did_win:	.word 0
game_won_text:	.asciiz "YOU WON!"
game_lost_text:	.asciiz "YOU LOST"


# --------------------------------------------------------------------------------------------------
# @description	any bullet related variables go here
#		this includes:
#			- x value of every bullet
#			- y value of every bullet
#			- the activeness of every bullet

bullet_x:      .byte 0:MAX_BULLETS
bullet_y:      .byte 0:MAX_BULLETS
bullet_dir:    .byte 0:MAX_BULLETS
bullet_active: .byte 0:MAX_BULLETS


# --------------------------------------------------------------------------------------------------
# @description	any enemy related variables go here
#		this includes:
#			- x value of enemies
#			- y value of enemies
#			- direction of the enemies (0 = right, 1 = left)
#			- status of the enemies
#			- an image of the enemy ship

enemy_x:	.word 2
enemy_y:	.word 2
enemy_direction:.word 0
enemy_status:	.byte 1, 1, 1, 1, 1, 
		      1, 1, 1, 1, 1, 
		      1, 1, 1, 1, 1, 
		      1, 1, 1, 1, 1, 
		      1, 1, 1, 1, 1
enemy_image:	.byte COLOR_GREEN, COLOR_BLACK, COLOR_BLACK, COLOR_BLACK, COLOR_GREEN,
		      COLOR_BLUE, COLOR_BLUE, COLOR_BLACK, COLOR_BLUE, COLOR_BLUE,
		      COLOR_BLUE, COLOR_GREEN, COLOR_MAGENTA, COLOR_GREEN, COLOR_BLUE,
		      COLOR_BLACK, COLOR_BLUE, COLOR_MAGENTA, COLOR_BLUE, COLOR_BLACK,
		      COLOR_BLACK, COLOR_BLACK, COLOR_MAGENTA, COLOR_BLACK, COLOR_BLACK
enemies_left:	.word 20
		      
.text

# --------------------------------------------------------------------------------------------------
# @name		main
# @description	the beginning of everything
#		handles the main game loop

.globl main
main:	
	jal	shift_enemy
	jal	draw_screen
	jal	wait_for_next_frame
_intro_loop:
	jal	input_get_keys
	beq	v0, 0, _intro_loop
	lw	t0, frame_counter
	sw	t0, next_available_frame
	sw	t0, next_available_enemy_frame
	sw	t0, next_frame_to_shoot
	sw	t0, end_invincible_frame
	add	t0, t0, 30
	sw	t0, next_frame_for_enemy_shot
_main_loop:
	lw	t0, lives
	beq	t0, 0, _game_lost
	lw	t0, shots
	beq	t0, 0, _game_lost
	lw	t0, enemies_left
	beq	t0, 0, _game_won
	jal	move_ship			# model updates
	jal	shoot_bullets			# .
	jal	shift_enemy			# .
	jal	find_collisions			# .
	jal	draw_screen			# view updates
	jal	wait_for_next_frame		# wait for next frame
	b	_main_loop
_game_won:
	jal	draw_game_won
	exit
_game_lost:
	jal	draw_game_lost
	exit
	
	
# --------------------------------------------------------------------------------------------------
# @name		move_ship
# @description	handles interpreting arrow key inputs and
#		moving the ship accordingly

move_ship:
	push	ra
	jal	input_get_keys
	lw	t0, ship_x
	lw	t1, ship_y
	and	t2, v0, KEY_L			# left conditions
	bne	t2, KEY_L, _end_move_left	# .
	beq	t0, 2, _end_move_left		# .
	sub	t0, t0, 1			# move left
_end_move_left:
	and	t2, v0, KEY_R			# right conditions
	bne	t2, KEY_R, _end_move_right	# .
	beq	t0, 57, _end_move_right		# .
	add	t0, t0, 1			# move right
_end_move_right:
	and	t2, v0, KEY_U			# up conditions
	bne	t2, KEY_U, _end_move_up		# .
	beq	t1, 46, _end_move_up		# .
	sub	t1, t1, 1			# move up
_end_move_up:
	and	t2, v0, KEY_D			# down conditions
	bne	t2, KEY_D, _end_move_down	# .
	beq	t1, 52, _end_move_down		# .
	add	t1, t1, 1			# move down
_end_move_down:
	sw	t0, ship_x			# save ship_x & ship_y
	sw	t1, ship_y			# .
	pop	ra
	jr	ra

# --------------------------------------------------------------------------------------------------
# @name		gam_enemy_bullets
# @description	handles shooting at the user randomly

shoot_enemy_bullets:
	enter
	
	
	
	leave

# --------------------------------------------------------------------------------------------------
# @name		move_ship
# @description	handles interpreting arrow key inputs and
#		moving the ship accordingly

shoot_bullets:
	push	ra
	lw	t0, frame_counter
	lw	t1, next_frame_for_enemy_shot
	li	s5, 0
	beq	t1, t0, _load_enemy_bullet
	b	_shoot_bullets_setup
_load_enemy_bullet:
_find_active_enemy:
	li	v0, 42
	li	a1, 19
	syscall
	lb	t0, enemy_status(a0)
	beq	t0, 0, _find_active_enemy
	div	s4, a0, 5
	mul	t0, s4, 5
	sub	s3, a0, t0
	lw	t1, enemy_x
	lw	t2, enemy_y
	mul	s3, s3, 10				# calculate x & y value of an arbitrary enemy ship
	add	s3, s3, t1				# .
	mul	s4, s4, 7				# .
	add	s4, s4, t2
	add	s3, s3, 2
	add	s4, s4, 5
	li	s5, 1
_shoot_bullets_setup:
	li	s1, 0				# inactiveBulletIsFound = false
	li	s2, 0				# shouldSearchForInactiveBullet = false
	jal	input_get_keys
	and	t0, v0, KEY_B			# "b" pressed conditions
	beq	t0, KEY_B, _yes_shot		# .
	b	_bullet_active_loop_setup
_yes_shot:
	lw	t0, frame_counter
	lw	t1, next_available_frame
	bgt	t1, t0, _bullet_active_loop_setup
	li	s2, 1					# shouldSearchForInactiveBullet = true
_bullet_active_loop_setup:
	li	s0, 0					# int i = 0
_bullet_active_loop:
	lb	t0, bullet_active(s0)
	beq	t0, 1, _active_bullet_found		# if bullet active (true), shift active bullet
	beq	s5, 1, _inactive_bullet_found
	beq	s1, 1, _bullet_active_loop_condition	# if inactiveBulletIsFound == true (true), increase i and repeat
	beq	s2, 0, _bullet_active_loop_condition	# if shouldSearchForInactiveBullet == false (true), increase i and repeat
	b	_inactive_bullet_found			# otherwise, conclude an inactive bullet has been found and should be shot
_active_bullet_found:
	lb	t0, bullet_y(s0)			# move bullet up
	lb	t1, bullet_dir(s0)
	beq	t1, 1, _move_bullet_up
	sub	t0, t0, 1
	beq	t0, -1, _invalidate_bullet
	b	_end_move_bullet
_move_bullet_up:
	add	t0, t0, 1			
	beq	t0, 56, _invalidate_bullet		# .
_end_move_bullet:
	sb	t0, bullet_y(s0)			# .
	b	_bullet_active_loop_condition
_invalidate_bullet:
	li	t0, 0					# set the activeness of a bullet to 0
	sb	t0, bullet_active(s0)			# .
	b	_bullet_active_loop_condition
_inactive_bullet_found:
	li	t0, 1
	sb	t0, bullet_active(s0)
	bne	s5, 1, _shoot_regular_bullet
	li	t0, 1
	sb	t0, bullet_dir(s0)
	li	s5, 0
	sb	s3, bullet_x(s0)			# .
	sb	s4, bullet_y(s0)
	lw	t0, frame_counter
	add	t0, t0, 30
	sw	t0, next_frame_for_enemy_shot
	b	_bullet_active_loop_condition
_shoot_regular_bullet:
	li	t0, 0
	sb	t0, bullet_dir(s0)
	li	s1, 1					# inactiveBulletIsFound = true
	lw	t0, ship_x				# calculate the starting point of the bullet
	lw	t1, ship_y				# .
	add	t0, t0, 2				# .
	sub	t1, t1, 1				# .
	sb	t0, bullet_x(s0)			# .
	sb	t1, bullet_y(s0)			# .
	lw	t0, shots				# descrease shots left
	sub	t0, t0, 1				# .
	sw	t0, shots				# .
	lw	t0, frame_counter			# calculate next available frame
	add	t0, t0, 30				# .
	sw	t0, next_available_frame		# .
_bullet_active_loop_condition:
	add	s0, s0, 1
	blt	s0, MAX_BULLETS, _bullet_active_loop
	b	_end_bullet_active_loop			# ends when i >= MAX_BULLETS
_end_bullet_active_loop:
	pop	ra
	jr	ra
	

# --------------------------------------------------------------------------------------------------
# @name		shift_enemy
# @description	calculates the new starting coordinates of the enemy ships

shift_enemy:
	push ra
	lw	s0, enemy_x
	lw	s1, enemy_y
	lw	s2, enemy_direction
	lw	t0, frame_counter			# check if a shift is necessary
	lw	t1, next_available_enemy_frame		# .
	ble	t1, t0, _shift_enemy_coordinates	# .
	pop	ra					# if no shift is necessary, just return
	jr	ra					# .
_shift_enemy_coordinates:
	beq	s2, 0, _shift_enemy_right		# if direction is 0, shift right
	sub	s0, s0, 1				# else, shift left
	b	_shift_enemy_check_down
_shift_enemy_right:
	add	s0, s0, 1				# shift right
	b	_shift_enemy_check_down
_shift_enemy_check_down:
	beq	s0, 18, _shift_enemy_down		# if the enemies are too far to the right or
	beq	s0, 1, _shift_enemy_down		# if the enemies are too far to the left shift down
	b	_shift_enemy_commit
_shift_enemy_down:
	beq	s2, 0, _shift_enemy_right_undo		# if the enemies came from the left, move them back to the left
	add	s0, s0, 1				# else, move them back to the right
	b	_shift_enemy_down_continue
_shift_enemy_right_undo:
	sub	s0, s0, 1				# move them back to the left
_shift_enemy_down_continue:
	not	s2, s2					# invert the direction
	add	s1, s1, 1				# shift down vertically
	beq	s1, 15, _shift_enemy_down_undo		# if we have gone down far enough ...
	b	_shift_enemy_commit
_shift_enemy_down_undo:
	sub	t1, t1, 15
	sub	s1, s1, 1				# ... shift back up one so there is no visible vertical movement
_shift_enemy_commit:
	add	t1, t1, 15				# wait 15 more frames for another shift
	sw	t1, next_available_enemy_frame		# .
	sw	s0, enemy_x				# commit all positional changes
	sw	s1, enemy_y				# .
	sw	s2, enemy_direction			# .
	pop	ra
	jr	ra
	

# --------------------------------------------------------------------------------------------------
# @name		find_collisions
# @description	finds any collisions and disposes of the enemies properly

find_collisions:
	push 	ra
	lw	s0, enemy_x
	lw	s1, enemy_y
	li	s2, 0					# int i = 0
	li	s3, 0					# int column = 0
	li	s4, 0					# int row = 0
_enemies_loop:
	lb	t0, enemy_status(s2)
	beq	t0, 0, _enemies_loop_conditions
	mul	a0, s3, 10				# calculate x & y value of an arbitrary enemy ship
	add	a0, a0, s0				# .
	mul	a1, s4, 7				# .
	add	a1, a1, s1				# .
	li	s5, 0					# int j = 0
_bullets_loop:
	lb	t0, bullet_active(s5)			# go through every scenario in which the bullet doesn't hit the enemy
	beq	t0, 0, _bullets_loop_conditions		# .
	lb	t0, bullet_dir(s5)
	beq	t0, 1, _bullets_loop_conditions
	lb	t0, bullet_x(s5)			# .
	blt	t0, a0, _bullets_loop_conditions	# .
	add	t1, a0, 4				# .
	bgt	t0, t1, _bullets_loop_conditions	# .
	lb	t0, bullet_y(s5)
	blt	t0, a1, _bullets_loop_conditions	# .
	add	t1, a1, 4				# .
	bgt	t0, t1, _bullets_loop_conditions	# .
	li	t0, 0					# at this point, the bullet is gonna knock out the enemy, so we
	sb	t0, bullet_active(s5)			# invalidate the bullet that hit the enemy and
	move 	a0, s2
	sb	t0, enemy_status(s2)			# invalidate the enemy itself
	lw	t0, enemies_left
	sub	t0, t0, 1
	sw	t0, enemies_left
_bullets_loop_conditions:
	add	s5, s5, 1
	blt	s5, MAX_BULLETS, _bullets_loop
_enemies_loop_conditions:
	add	s2, s2, 1
	add	s3, s3, 1
	blt	s3, 5, _enemies_no_column_reset	# if column == 5
	li	s3, 0					# reset the column
	add	s4, s4, 1				# and increase the row
	beq	s4, 4, _enemies_loop_end		# if rows == 4, then all the enemies are drawn
_enemies_no_column_reset:
	b	_enemies_loop
_enemies_loop_end:
	lw	t0, frame_counter
	lw	t1, end_invincible_frame
	bgt	t1, t0, _end_collisions_check
	lw	a0, ship_x
	lw	a1, ship_y
	li	s5, 0
_enemy_bullets_loop:
	lb	t0, bullet_active(s5)			# go through every scenario in which the bullet doesn't hit the enemy
	beq	t0, 0, _enemy_bullets_loop_conditions		# .
	lb	t0, bullet_dir(s5)
	beq	t0, 0, _enemy_bullets_loop_conditions
	lb	t0, bullet_x(s5)			# .
	blt	t0, a0, _enemy_bullets_loop_conditions	# .
	add	t1, a0, 4				# .
	bgt	t0, t1, _enemy_bullets_loop_conditions	# .
	lb	t0, bullet_y(s5)
	blt	t0, a1, _enemy_bullets_loop_conditions	# .
	add	t1, a1, 4				# .
	bgt	t0, t1, _enemy_bullets_loop_conditions	# .
	li	t0, 0					# at this point, the bullet is gonna knock out the enemy, so we
	sb	t0, bullet_active(s5)			# invalidate the bullet that hit the enemy and
	lw	t0, lives
	sub	t0, t0, 1
	sb	t0, lives
	lw	t0, frame_counter
	add	t0, t0, 120
	sw	t0, end_invincible_frame
	b	_end_collisions_check
_enemy_bullets_loop_conditions:
	add	s5, s5, 1
	blt	s5, MAX_BULLETS, _enemy_bullets_loop
_end_collisions_check:
	pop	ra
	jr	ra


# --------------------------------------------------------------------------------------------------
# @name		draw_screen
# @description	main method for drawing anything necessary
#		any drawing that occurs should be called 
#		from this function

draw_screen:
	push ra
	li	a0, 0
	li	a1, 0
	li	a2, 64
	li	a3, 64
	li	v1, COLOR_BLACK
	jal	display_fill_rect_fast
	lw	a0, ship_x			# draw the ship
	lw	a1, ship_y			# .
	lw	t0, frame_counter
	lw	t1, end_invincible_frame
	bgt	t1, t0, _load_invincible_ship
	la	a2, ship_image			# .
	b	_draw_ship
_load_invincible_ship:
	la	a2, invincible_image
_draw_ship:
	jal	draw_ship			# .
	jal	draw_enemies			# draw the enemies
	jal	draw_bullets			# draw the bullets
	li	a0, 2				# draw shots left
	li	a1, 58				# .
	lw	a2, shots			# .
	jal	display_draw_int		# .
	li	s0, 2				# draw lives	
	lw	t0, lives
	sub	t0, t0, 1
	sub	s2, s0, t0
	lw	t0, frame_counter
	lw	t1, end_invincible_frame
	bgt	t1, t0, _load_invincible_ship_image
	la	s1, ship_image
	b	_lives_body
_load_invincible_ship_image:
	la	s1, invincible_image
_lives_body:					# @todo: abstract this
	mul	t2, s0, 6
	add	a0, t2, 45
	li	a1, 58
	move	a2, s1
	push	s0
	push	s1
	jal	draw_ship
	pop	s1
	pop	s0
	sub	s0, s0, 1
	bge	s0, s2, _lives_body
	jal	display_update
	pop	ra
	jr	ra


# --------------------------------------------------------------------------------------------------
# @name		draw_ship
# @description	draws the ship using coordinates and the array of pixel data
# @param 	a0 - x value of ship
# @param 	a1 - y value of ship
# @param	a2 - pointer to the array of colors for ship

draw_ship:
	push	ra
	jal	display_blit_5x5
	pop	ra
	jr	ra
	
	
# --------------------------------------------------------------------------------------------------
# @name		draw_bullets
# @description	draws the bullets using the coordinate arrays

draw_bullets:
	push	ra
	li	s0, 0
_bullet_loop:
	lb	t0, bullet_active(s0)
	beq	t0, 0, _bullet_loop_check	# if the bullet isn't active, skip it
	lb	a0, bullet_x(s0)
	lb	a1, bullet_y(s0)
	lb	t0, bullet_dir(s0)
	beq	t0, 1, _color_enemy_bullet
	li	a2, COLOR_WHITE
	b	_show_bullet
_color_enemy_bullet:
	li	a2, COLOR_GREEN
_show_bullet:
	push	s0
	jal	display_set_pixel
	pop	s0
_bullet_loop_check:
	add	s0, s0, 1
	blt	s0, MAX_BULLETS, _bullet_loop
	pop	ra
	jr	ra
	
	
# --------------------------------------------------------------------------------------------------
# @name		draw_enemies
# @description	draws the enemies using the starting locations

draw_enemies:
	enter	s2, s3, s4, s5
	lw	t0, frame_counter			# check if a shift is necessary
	lw	t1, next_available_enemy_frame		# .
	beq	t1, t0, _draw_enemies_loop_end
	li	s2, 0					# int i = 0
	li	s3, 0					# int column = 0
	li	s4, 0					# int row = 0
	la	s5, enemy_image
_draw_enemies_loop:
	lb	t0, enemy_status(s2)
	beq	t0, 0, _draw_enemies_loop_conditions
	lw	t1, enemy_x
	lw	t2, enemy_y
	mul	a0, s3, 10				# calculate x & y value of an arbitrary enemy ship
	add	a0, a0, t1				# .
	mul	a1, s4, 7				# .
	add	a1, a1, t2				# .
	move	a2, s5
	jal	display_blit_5x5
_draw_enemies_loop_conditions:
	add	s2, s2, 1
	add	s3, s3, 1
	blt	s3, 5, _draw_enemies_no_column_reset	# if column == 5
	li	s3, 0					# reset the column
	add	s4, s4, 1				# and increase the row
	beq	s4, 4, _draw_enemies_loop_end		# if rows == 4, then all the enemies are drawn
_draw_enemies_no_column_reset:
	b	_draw_enemies_loop
_draw_enemies_loop_end:
	leave	s2, s3, s4, s5
	
	
# --------------------------------------------------------------------------------------------------
# @name		draw_game_won
# @description	draws "you won!" on the screen

draw_game_won:
	enter
	li	a0, 0
	li	a1, 0
	li	a2, 64
	li	a3, 64
	li	v1, COLOR_BLACK
	jal	display_fill_rect_fast
	li	a0, 9
	li	a1, 28
	la	a2, game_won_text
	jal	display_draw_text
	jal	display_update
	leave
	

# --------------------------------------------------------------------------------------------------
# @name		draw_game_won
# @description	draws "you won!" on the screen

draw_game_lost:
	enter
	li	a0, 0
	li	a1, 0
	li	a2, 64
	li	a3, 64
	li	v1, COLOR_BLACK
	jal	display_fill_rect_fast
	li	a0, 9
	li	a1, 28
	la	a2, game_lost_text
	jal	display_draw_text
	jal	display_update
	leave
	
	
# --------------------------------------------------------------------------------------------------
# @name		wait_for_next_frame
# @description	call once per main loop to keep the game running at 60FPS
# 		if your code is too slow (longer than 16ms per frame), the framerate will drop.
# 		otherwise, this will account for different lengths of processing per frame.

wait_for_next_frame:
enter	s0
	lw	s0, last_frame_time
_wait_next_frame_loop:
	# while (sys_time() - last_frame_time) < GAME_TICK_MS {}
	li	v0, 30
	syscall # why does this return a value in a0 instead of v0????????????
	sub	t1, a0, s0
	bltu	t1, GAME_TICK_MS, _wait_next_frame_loop

	# save the time
	sw	a0, last_frame_time

	# frame_counter++
	lw	t0, frame_counter
	inc	t0
	sw	t0, frame_counter
leave	s0

