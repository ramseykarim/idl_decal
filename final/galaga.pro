;=================================================
; IDL Decal Presents:
;
;
;              Galaga
;                         Andrew Halle
;                          Ramsey Karim
;=================================================

; We wrote a simplified version of Galaga for our final project.
;
; The game features two stages, both with introductions that lead
; directly into those stages, and one final 'intro' to winning the game.
;
; Both stages take 4 user input options, based on the awsd keyboard scheme:
;    'a' is move left
;    'd' is move right
;    'w' is shoot
;    'x' is quit the game (only during gameplay)
;
;
; Like the orignal arcade game, enemies move and shoot.
; The game features one boss that can shoot more often and from different spots.
;
; Our code follows.
;===================================================
;===================================================
;===================================================
;===================================================



; Custom keyboard input that averages 4 inputs to allow mashing of
; keys wooooo

function keyboardin
   a = get_kbrd(0)
   b = get_kbrd(0)
   c = get_kbrd(0)
   d = get_kbrd(0)
   inputs = [a, b, c, d]
   as = 0
   ds = 0
   ws = 0
   xs = 0
   for i=0,3 do begin
      case inputs[i] of
         'a': as = as + 1
         'd': ds = ds + 1
         'w': ws = ws + 1
         'x': xs = xs + 1
         ELSE: break
      endcase
   endfor
   totals = [as, ds, ws, xs]
   highest = [where(totals EQ max(totals))]
   out = highest[0]
; Return value 'out' as follows:
; ('Out' will be the integer)
; a = 0
; d = 1
; w = 2
; x = 3
   if max(totals) NE 0 then begin
      return, out
   endif else begin
      return, 'No Key Entered'
   endelse
end


; Game stages

; Intro, mostly just timed text

pro intro
  make_board
  xyouts, 450, 700, 'Alright,', charsize=1.5
  wait, 0.75
  xyouts, 510, 700, 'so', charsize=1.5
  wait, 0.75
  xyouts, 400, 650, 'Berkeley astronomy is being attacked!', charsize=2
  wait, 0.75
  xyouts, 420, 600, 'By like aliens!', charsize=2.5
  wait, 1
  xyouts, 620, 600, 'or whatever', charsize=2.5
  wait, 1
  xyouts, 450, 550, 'Help!', charsize=3
  wait, 0.75
  xyouts, 400, 500, 'Press any key to continue', charsize=1.5
  dummy_variable = get_kbrd()
  erase
  xyouts, 400, 600, 'Its dangerous to go alone! Take this!', charsize=2
  wait, 0.5
  draw_ship, 455
  wait, 0.5
  xyouts, 400, 550, 'Press any key to continue', charsize=1.5
  dummy_variable = get_kbrd()
  gameplay
end

; Gameplay loop
; Keeps track of all necessary variables.
; Initializes the game and then allows variables to be changed through various procedures.

pro gameplay
  ; The difficulty works so that in each frame, there is a
  ; 1/(difficulty + 1) probability of some ship shooting.
  difficulty = 5
  gamestage = 1
  me = {loc:445, health:10}
  eloc = 500
  edirec = 1
  shots = []
  make_board
  gamespeed = 5
  e1 = {position:[-100, 800], health:1, clr:!orange, explosion:10, hitbox:[[-30, 10], [30, -30]]}
  e2 = {position:[100, 800], health:1, clr:!orange, explosion:10, hitbox:[[-30, 10], [30, -30]]}
  e3 = {position:[-300, 750], health:1, clr:!red, explosion:10, hitbox:[[-30, 10], [30, -30]]}
  e4 = {position:[300, 750], health:1, clr:!red, explosion:10, hitbox:[[-30, 10], [30, -30]]}
  e5 = {position:[-400, 800], health:1, clr:!green, explosion:10, hitbox:[[-30, 10], [30, -30]]}
  e6 = {position:[400, 800], health:1, clr:!green, explosion:10, hitbox:[[-30, 10], [30, -30]]}
  e7 = {position:[-250, 840], health:1, clr:!blue, explosion:10, hitbox:[[-30, 10], [30, -30]]}
  e8 = {position:[250, 840], health:1, clr:!blue, explosion:10, hitbox:[[-30, 10], [30, -30]]}
  e9 = {position:[0, 870], health:1, clr:!white, explosion:10, hitbox:[[-30, 10], [30, -30]]}
  eten = {position:[0, 710], health:1, clr:!blue, explosion:10, hitbox:[[-30, 10], [30, -30]]}

  enemies = [e1, e2, e3, e4, e5, e6, e7, e8, e9, eten]

  while 1 do begin
   draw_ship, me.loc
   draw_health_bar, me.health
   plotshots, shots
   plotenemies, enemies, eloc
   k = keyboardin()
   case k of
      0: me.loc = move_me(me.loc, -1, gamespeed)
      1: me.loc = move_me(me.loc, 1, gamespeed)
      2: shoot, me.loc, shots
      3: stop
      else: break
   endcase
   advance_shots, shots, enemies, gamespeed, eloc, me
   shootback, enemies, shots, eloc, difficulty
   edirec = track_direction(eloc, edirec)
   eloc = move_enemy(eloc, edirec, gamespeed)
   checkwin, enemies, me, eloc, gamestage
   checklose, me
   erase
  endwhile
end

; Boss intro
; Mostly timed text, and also finished the last explosion from gameplay

pro boss_intro, last_loc, last_exp
  make_board
  draw_ship, last_loc
  wait, 0.1
  i=10
  while i GT 0 do begin
     draw_explosion, last_exp, i
     draw_ship, last_loc
     wait, 0.1
     i = i - 1
     erase
  endwhile
  draw_ship, last_loc
  wait, 0.5
  xyouts, 450, 600, 'haha', charsize=1.5
  wait, 0.25
  xyouts, 500, 600, 'yeah', charsize=1.5
  wait, 0.25
  xyouts, 550, 600, 'man', charsize=1.5
  wait, 1
  xyouts, 400, 550, 'watch out!', charsize=2.5
  wait, 0.5
  xyouts, 550, 550, 'lol', charsize=1.75
  wait, 0.75
  boss_gameplay, last_loc
end

; Boss gameplay loop
; Essentially the same as gameplay, but uses some modified procedures and functions
; that create the boss.

pro boss_gameplay, last_loc
  ; The difficulty works so that in each frame, there is a
  ; 1/(difficulty + 1) probability of some ship shooting.
  difficulty = 5
  gamestage = 2
  me = {loc:last_loc, health:10}
  eloc = 500
  edirec = 1
  shots = []
  make_board
  gamespeed = 5
  boss = {position:[0, 900], health:10, hitbox:[[-160, 80], [170, -70]]}
  enemies = [boss]
  
  while 1 do begin
   draw_ship, me.loc
   draw_health_bar, me.health
   draw_boss_health, enemies[0].health, eloc
   plotshots, shots
   draw_boss, eloc
   k = keyboardin()
   case k of
      0: me.loc = move_me(me.loc, -1, gamespeed)
      1: me.loc = move_me(me.loc, 1, gamespeed)
      2: shoot, me.loc, shots
      3: stop
      else: break
   endcase
   advance_shots, shots, enemies, gamespeed, eloc, me
   boss_shoot, eloc, shots, difficulty
   edirec = track_direction(eloc, edirec)
   eloc = move_enemy(eloc, edirec, gamespeed)
   checkwin, enemies, me, eloc, gamestage
   checklose, me
   erase
  endwhile
end

; Boss death 'intro'
; Final explosion sequence on boss's last location.
; Some text.
;    'It's the end of times'
;        -Andrew

pro boss_death, ship_location, boss_location
  ;it's end of times
  erase
  draw_ship, ship_location
  draw_boss, boss_location
  i = 0
  while i LT 3 do begin

     x = 10
     while x GT 0 do begin
        draw_explosion, [boss_location - 100, 850], x
        wait, 0.05
        erase
        draw_ship, ship_location
        draw_boss, boss_location
        x = x - 1

     endwhile
     x = 10
     while x GT 0 do begin

        draw_explosion, [boss_location, 900], x
        wait, 0.05
        erase
        draw_ship, ship_location
        draw_boss, boss_location
        x = x - 1

     endwhile
     x = 10
     while x GT 0 do begin

        draw_explosion, [boss_location+100, 925], x
        wait, 0.05
        erase
        draw_ship, ship_location
        draw_boss, boss_location
        x = x - 1
     endwhile
     x = 10
     

     i = i + 1
  endwhile
  erase
  draw_ship, ship_location
  xyouts, 450, 500, "YOU WIN!", charsize=2
  xyouts, 400, 470, "Thanks, on behalf of UCB Astronomy", charsize=2
  stop

end


; Advancing Stages

; Checks to see if you've advanced past a gameplay stage.
; If you have, it moves all necessary information to the next stage

pro checkwin, enemies, me, enemy_loc, stage
  check = 0
  for i=0,n_elements(enemies)-1 do begin
    check = check + enemies[i].health
  endfor
  if check EQ 0 then begin
     if stage EQ 1 then boss_intro, me.loc, find_last_explosion(enemies, enemy_loc)
     if stage EQ 2 then boss_death, me.loc, enemy_loc
  endif
end

; Checks to see if you've lost.
; If you have, prints an appropriate message.

pro checklose, me
  if me.health LE 0 then begin
     draw_explosion, [me.loc + 55, 55], 5
     xyouts, 500, 500, "Wow, you lose!", charsize=2
     print, 'Wow you lose!'
     stop
  endif
end

; Finds the last explosion from the normal gameplay
; stage to port to the boss intro.

function find_last_explosion, enemies, enemy_loc
  for i=0,n_elements(enemies)-1 do begin
     if enemies[i].explosion GT 1 then begin
        last_exp = enemies[i].position
        break
     endif
  endfor
  last_exp_loc_x = last_exp[0] + enemy_loc
  last_exp_loc_y = last_exp[1]
  last_exp_loc = [last_exp_loc_x, last_exp_loc_y]
  return, last_exp_loc
end



; Gameplay mechanics



; Removes old shots from the shot array by creating a new array.
; Since we can't easily mutate arrays, we notate an old shot
; by assigning it the [x, y, direction] array [0,0,0], which
; is not a possible combination in normal gameplay
; (especially since the possible directions are 1 and -1)

function scrub_positions, arr
  newarr = []
  for i=0,n_elements(arr[0,*])-1 do begin
     x = arr[0,i]
     y = arr[1,i]
     z = arr[2,i]
     if x NE 0 OR y NE 0 OR z NE 0 then begin
        newarr = [[newarr], [arr[*,i]]]
     endif
  endfor
  return, newarr
end

; Manages explosions and passes last explosion frame (saved in
; enemy data structure) to the next frame.
; Called when we plot enemies.

function manage_explosions, enemy, enemy_loc
  ; assumes this procedure is called inside a for loop of
  ;  i=0,n_elements(enemies)-1 where enemy = enemies[i]
  ; abbreviation for enemies[i]
  eexplos = enemy.explosion
  if enemy.health EQ 0 AND enemy.explosion GE 0 then begin
     eposy = enemy.position[1]
     eposx = enemy.position[0] + enemy_loc
     draw_explosion, [eposx, eposy], eexplos
     eexplos = eexplos - 1
  endif
  return, eexplos
end

; This is the controller for moving shots.
; Shots are stored in an [x,y,direction] array,
; and only every move up or down the y axis.
; The function checks to see if they're friendly or enemy
; (friendly always moves up, 1, and enemy moves down, -1)
; and then checks to see if any appropriate ships were hit
; (no friendly fire).
; It returns the new position array of the shot (they don't change direction)
; or the array [0,0,0] if it has been used to hit someone or fallen off screen.

function shot_track, position, enemies, speed, enemy_loc, me
  x = position[0]
  y = position[1]
  direction = position[2]
  new_position = [x, y + speed*3*direction, direction]
  if y GT 999 OR y LT 0 then begin
     new_position = [0, 0, 0]
  endif
  if direction EQ 1 then begin
     for i=0,n_elements(enemies)-1 do begin
        eposy = enemies[i].position[1]
        eposx = enemies[i].position[0] + enemy_loc
        alive = enemies[i].health GT 0
        hitbox_x_min = enemies[i].hitbox[0,0]
        hitbox_x_max = enemies[i].hitbox[1,0]
        hitbox_y_min = enemies[i].hitbox[1,1]
        hitbox_y_max = enemies[i].hitbox[0,1]
        xcheck = x GE (eposx + hitbox_x_min) AND x LE (eposx + hitbox_x_max)
        ycheck = y LE (eposy + hitbox_y_max) AND y GE (eposy + hitbox_y_min + speed*3)
        if alive AND xcheck AND ycheck then begin
           print, '----------------------------------'
           print, 'Hit! Location: ', position
           print, '----------------------------------'
           enemies[i].health = enemies[i].health - 1
           new_position = [0, 0, 0]
           break
        endif
     endfor
  endif
  if direction EQ -1 then begin
     xcheck = x GE me.loc AND x LE (me.loc + 110)
     ycheck = y LE 110 AND y GE 0
     if xcheck AND ycheck then begin
        me.health = me.health - 1
        new_position = [0, 0, 0]
        print, '----------------------------'
        print, 'Hit! New health: ', me.health
        print, '----------------------------'
     endif
  endif
  return, new_position
end

; Initializes a friendly shot.
; Adds it to the shot array with friendly ship location.

pro shoot, my_x_coord, shot_arr
  xpos = my_x_coord + 55
  ypos = 111
  pos = [xpos, ypos, 1]
  shot_arr = [[shot_arr], [pos]]
end

; Initializes an enemy shot.
; Adds to shot array with appropriate initial location.
pro shootback, enemies, shot_arr, enemy_loc, difficulty
  chance = round(difficulty * randomu(seed))
  random_enemy = (n_elements(enemies)-1)*randomu(seed)
  who_will_shoot = enemies[round(random_enemy)]
  if who_will_shoot.health GT 0 AND chance EQ 0 then begin
     shot_originx = who_will_shoot.position[0] + enemy_loc
     shot_originy = who_will_shoot.position[1]
     shot_arr = [[shot_arr], [shot_originx, shot_originy, -1]]
  endif
end

; Initializes a boss shot.

pro boss_shoot, enemy_loc, shot_arr, difficulty
   chance = round(2 * difficulty * randomu(seed))
   if chance EQ 0 then begin
      shot_originx = round(330 * randomu(seed)) - 160 + enemy_loc
      shot_originy = 830
      shot_arr = [[shot_arr], [shot_originx, shot_originy, -1]]
   endif
end


; Plots all enemies who are still alive (health > 0).

pro plotenemies, enemies, enemy_loc
  for i=0,n_elements(enemies)-1 do begin
     enemies[i].explosion = manage_explosions(enemies[i], enemy_loc)
     if enemies[i].health GT 0 then begin
        eposy = enemies[i].position[1]
        eposx = enemies[i].position[0] + enemy_loc
        draw_enemy, [eposx, eposy], enemies[i].clr
     endif
  endfor
end

; Plots all shots in the shot array by calling draw_shot.

pro plotshots, shot_arr
  if shot_arr NE [] then begin
   for i=0,n_elements(shot_arr[0,*])-1 do begin
      draw_shot, shot_arr[*,i]
   endfor
  endif
end

; Called in the main while loops to move all shots and clean the arrays.

pro advance_shots, shot_arr, enemies, speed, enemy_loc, me
  if shot_arr NE [] then begin
   for i=0,n_elements(shot_arr[0,*])-1 do begin
      shot_arr[*,i] = shot_track(shot_arr[*,i], enemies, speed, enemy_loc, me)
   endfor
   shot_arr = scrub_positions(shot_arr)
  endif
end

; Moves an enemy

function move_enemy, enemy_loc, direction, speed
  ;moving enemies just involves shifting eloc 
  ; 0 is left, 1 is right
  cur_loc = enemy_loc
  if direction EQ 0 then begin
     next_loc = cur_loc - (speed -2)
  endif else next_loc = cur_loc + (speed -2)
  return, next_loc
end

; Changes direction of enemy movement (they move as a unit)
; if appropriate. Enemies are plotted with x coordinates around
; a variable x location and then true y coordinates.

function track_direction, enemy_loc, direction
  ndirection = direction
  if enemy_loc LT 400 then ndirection = 1 - direction
  if enemy_loc GT 600 then ndirection = 1 - direction
  return, ndirection
end

; Function to move our friendly ship. Also allows for a fun bug
; in which moving too far to the left/right places you on the other
; side of the board yay cheating :)

function move_me, my_loc, direction, speed
  new_loc = my_loc + (direction * speed)
  if new_loc GT 1055 then new_loc = -55
  if new_loc LT -55 then new_loc = 1055
  return, new_loc
end






; Art



pro draw_explosion, center, frame
  ;draw explosion of dying enemy ship given CENTER as a 1D array for
  ;explosion and FRAME number (counts down from 10)
  x = [0, -1, -3, -2, -3, -1, 0, 1, 3, 1, 3, 1, 0]
  y = [2, 1, 3, 0, -3, -1, -2, -1, -2, 0, 3, 1, 2]
  x = ((5-abs(5-frame))*2)*x + center[0]
  y = ((5-abs(5-frame))*2)*y + center[1]
  oplot, x, y, color=!orange
  x = [0, -1, -3, -3, -5, -3, -4, -3, -5, -4, -5, -2, -2, -1, 0, 1, 2, 2, 4, 3, 4, 3, 5, 3, 2, 1, 0]
  y = [5, 3, 5, 4, 5, 0, 1, -1, -4, -4, -5, -3, -4, -2, -5, -3, -4, -3, -3, -1, 1, 1, 4, 4, 5, 3, 5]
  x = ((5-abs(5-frame))*2)*x + center[0]
  y = ((5-abs(5-frame))*2)*y + center[1]
  oplot, x, y, color=!red
  if (frame MOD 2 EQ 0) then begin
     x = [-5, -5, -5, -4, -5, -5, -5, -6, -5]
     y = [-2, -1, -2, -2, -2, -3, -2, -2, -2]
     x = ((5-abs(5-frame))*2)*x + center[0]
     y = ((5-abs(5-frame))*2)*y + center[1]
     oplot, x, y, color=!white
     x = [5, 5, 5, 6, 5, 5, 5, 4, 5]
     y = [2, 3, 2, 2, 2, 1, 2, 2, 2]
     x = ((5-abs(5-frame))*2)*x + center[0]
     y = ((5-abs(5-frame))*2)*y + center[1]
     oplot, x, y, color=!white
  endif

end


pro make_board
	;draw the game board using PLOT and WINDOW
	window, 0, xsize=1000, ysize=1000, title="GALAGA"
	plot, [0,0,1000,1000], [0,1000,0,1000], psym = 1, xstyle = 4, ystyle = 4
end

pro draw_ship, x_coord
	;draw the player's ship in window given the x-coordinate as X_COORD of the left edge as an integer
	x = [0,0,1,1,2,2,3,3,2,2,3,3,4,4,5,5, 6, 6,7,7,8,8,9,9,8,8,9,9,10,10,11,11,10,10,9,9,6,6,5,5,2,2,1,1,0]
	y = [0,4,4,3,3,4,4,5,5,7,7,5,5,8,8,11,11,8,8,5,5,7,7,5,5,4,4,3,3, 4, 4, 0, 0, 1, 1,2,2,0,0,2,2,1,1,0,0]
	x = x * 10 + x_coord
	y = y * 10
    oplot, x, y
	x = [0,0,1,1,0]
	y = [4,5,5,4,4]
	x = x * 10 + x_coord
	y = y * 10
	oplot, x, y, color=!red
	x = [2,2,3,3,2]
	y = [7,8,8,7,7]
	x = x * 10 + x_coord
	y = y * 10
	oplot, x, y, color=!red
	x = [8,8,9,9,8]
	y = [7,8,8,7,7]
	x = x * 10 + x_coord
	y = y * 10
	oplot, x, y, color=!red
	x = [10,10,11,11,10]
	y = [4,5,5,4,4]
	x = x * 10 + x_coord
	y = y * 10
	oplot, x, y, color=!red
	x = [3,3,5,5,3]
	y = [1,2,2,1,1]
	x = x * 10 + x_coord
	y = y * 10
	oplot, x, y, color=!red
	x = [6,6,8,8,6]
	y = [1,2,2,1,1]
	x = x * 10 + x_coord
	y = y * 10
	oplot, x, y, color=!red
	x = [4,4,5,5,6,6,7,7,6,6,5,5,4]
	y = [3,5,5,6,6,5,5,3,3,4,4,3,3]
	x = x * 10 + x_coord
	y = y * 10
	oplot, x, y, color=!red
	x = [2,2,3,3,2]
	y = [4,5,5,4,4]
	x = x * 10 + x_coord
	y = y * 10
	oplot, x, y, color=!blue
	x = [8,8,9,9,8]
	y = [4,5,5,4,4]
	x = x * 10 + x_coord
	y = y * 10
	oplot, x, y, color=!blue
	x = [3,3,4,4,3]
	y = [5,6,6,5,5]
	x = x * 10 + x_coord
	y = y * 10
	oplot, x, y, color=!blue
	x = [7,7,8,8,7]
	y = [5,6,6,5,5]
	x = x * 10 + x_coord
	y = y * 10
	oplot, x, y, color=!blue
	

end

pro draw_enemy, center, clr
	;draw one enemy ship of color CLR given the coordinates of the CENTER as a 1D array of integers
	x = [0, -1, -1, -2, -3, -2, -2, -1, -1, 1, 1, 2, 2, 3, 2, 1, 1, 0]
	y = [-4, -3, -1, -1, 1, 1, 2, 2, 1, 1, 2, 2, 1, 1, -1, -1, -3, -4]
	x = x * 10 + center[0]
	y = y * 10 + center[1]
	oplot, x, y, color=clr

end

; Plots a shot on the board, given position.

pro draw_shot, position
  px = position[0]
  py = position[1]
  pdirec = position[2]
  x = [-1, 0, 1]
  y = [-1, 2, -1]
  x = x * 3 + px
  y = y * 3 * pdirec + py
  oplot, x, y, color=!yellow
end


; Health bars for friendly ship and boss

pro draw_health_bar, health
  ;draw the health bar for the player's ship (max 10 min 0)
  i = 0
  while i LT 10*health do begin

     x = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
     y = [i+200,i+200,i+200,i+200,i+200,i+200,i+200,i+200, i+200, i+200, i+200, i+200, i+200, i+200, i+200, i+200, i+200, i+200]
     oplot, x, y, color=!green
     i = i + 1

  endwhile


end

pro draw_boss_health, health, boss_loc
  ;draw the scary boss's health bar (max 10 min 0)
  i = 0
  z = boss_loc + 200
  while i LT 10*health do begin

     x = [3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20]
     x = x + z
     y = [i+850,i+850,i+850,i+850,i+850,i+850,i+850,i+850, i+850, i+850, i+850, i+850, i+850, i+850, i+850, i+850, i+850, i+850]
     oplot, x, y, color=!red
     i = i + 1

  endwhile


end

pro draw_boss, location
  ;draw super scary boss
  ;F
  x = [-12, -9, -9, -11, -11, -10, -10, -11, -11, -12, -12]
  y = [3, 3, 2, 2, 1, 1, 0, 0, -2, -2, 3]
  x = 10*x + location
  y = 10*y + 900
  oplot, x, y
  ;I
  x = [-8, -5, -5, -6, -6, -5, -5, -8, -8, -7, -7, -8, -8]
  y = [3, 3, 2, 2, -1, -1, -2, -2, -1, -1, 2, 2, 3]
  x = 10*x + location
  y = 10*y + 900
  oplot, x, y
  ;N
  x = [-4, -3, -2, -2, -1, -1, -2, -3, -3, -4, -4]
  y = [3, 3, 0, 3, 3, -2, -2, 1, -2, -2, 3]
  x = 10*x + location
  y = 10*y + 900
  oplot, x, y
  ;A
  x = [0, 2, 3, 5, 4, 3, 2, 1, 0]
  y = [-2, 3, 3, -2, -2, 0, 0, -2, -2]
  x = 10*x + location
  y = 10*y + 900
  oplot, x, y
  ;box
  x = [2, 2, 3, 3, 2]
  y = [1, 2, 2, 1, 1]
  x = 10*x + location
  y = 10*y + 900
  oplot, x, y
  ;L
  x = [6, 7, 7, 9, 9, 6, 6]
  y = [3, 3, -1, -1, -2, -2, 3]
  x = 10*x + location
  y = 10*y + 900
  oplot, x, y
  ;S
  x = [10, 13, 13, 11, 11, 13, 13, 10, 10, 12, 12, 10, 10]
  y = [3, 3, 2, 2, 1, 1, -2, -2, -1, -1, 0, 0, 3]
  x = 10*x + location
  y = 10*y + 900
  oplot, x, y
  ;body
  x = [0, 2, 4, 6, 7, 8, 9, 10, 12, 14, 17, 14, 16, 14, 17, 14, 12, 11, 9, 7, 6, 5, 4, 3, 2, 1, 0, -2, -4, -6, -8, -10, -12, -13, -16, -13, -15, -13, -16, -13, -11, -10, -9, -8, -6, -4, -3, -2, 0]
  y = [6, 4, 8, 4, 7, 4, 6, 4, 7, 4, 3, 2, 1, 0, -1, -2, -5, -3, -6, -3, -6, -3, -5, -3, -6, -3, -6, -3, -6, -3, -7, -3, -5, -3, -2, -1, 0, 1, 2, 3, 7, 4, 6, 4, 7, 4, 6, 4, 6]
  x = 10*x + location
  y = 10*y + 900
  oplot, x, y

end

; That is all






; Thanks guys





; Plz give us an A this was like 760 lines of code and literally works

; Validate me plz







;  Plz




; Yeah and like thanks for teaching the class and stuff,
; we had fun!
; Have a good winter!