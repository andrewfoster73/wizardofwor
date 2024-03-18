
dim t1 as uinteger              ' First read of time
dim t2 as uinteger              ' Second read of time
dim time as uinteger            ' Accepted time
dim frame as ulong              ' Current frame
dim fps as fixed                ' Frames per second
dim keypress as uinteger        ' Last key press
dim joystick(1 to 2) as ubyte   ' Last joystick input for player 1 (port 31) and player 2 (port 55)

dim hi_scores(4) as uinteger    ' Top 5 scores
dim dungeon_drawn as ubyte = 0  ' Has the dungeon been drawn yet? If so, do not draw again
dim title_state as ubyte = 0    ' 0 - First title screen, 1 - Scoring screen
dim tile_masks(11) as ubyte = {tile_0,tile_1,tile_2,tile_3,tile_4,tile_5,tile_6,tile_7,tile_8,tile_9,tile_10,tile_11}

dim scoring_sprite_ids(6) as ubyte => {100,101,102,103,104,105,106}
dim player_sprite_ids(1 to 2) as ubyte => {1,2}
dim player_bullet_ids(1 to 2) as ubyte => {3,4}
dim player_dying_ids(1 to 2) as ubyte => {13,14}
dim player_lives_ids(1 to 2, 1 to 4) as ubyte => {{31,32,33,34},{35,36,37,38}}
dim monster_sprite_ids(1 to 8) as ubyte => {5,6,7,8,9,10,11,12}
dim monster_bullet_ids(1 to 8) as ubyte => {15,16,17,18,19,20,21,22}
dim monster_dying_ids(1 to 8) as ubyte => {23,24,25,26,27,28,29,30}

dim player_frame_images(1 to 2, 1 to 3) as ubyte = {{0,1,2},{4,5,6}}
dim player_bullet_image as ubyte = 8
dim player_firing_image(1 to 2) as ubyte = {3,7} 
dim monster_frame_images(1 to 5, 1 to 3) as ubyte => {{12,13,14},{16,17,18},{20,21,22},{24,25,26},{28,29,30}}
dim monster_bullet_image as ubyte = 9
dim explosion_images(1 to 8) as ubyte = {32,33,34,35,36,37,38,39}
dim frame_pattern(1 to 12) as ubyte = {1,1,1,2,2,2,3,3,3,2,2,2}
dim npc_frame_pattern(1 to 1, 1 to 48) as ubyte => {{1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2}}
dim explosion_pattern(1 to 24) as ubyte = {1,1,1,2,2,2,3,3,3,4,4,4,5,5,5,6,6,6,7,7,7,8,8,8}

' Timers
dim awaiting_timer as ubyte = 0
dim flip_title_timer as uinteger = FLIP_TITLE_TIME ' Countdown until flipping between title screens
dim get_ready_timer as uinteger = GET_READY_TIME
dim eject_player_timer as uinteger = EJECT_PLAYER_TIME
dim door_open_timer as uinteger = DOOR_OPEN_TIME
dim door_close_timer as uinteger = DOOR_CLOSE_TIME

' Game variables
dim num_players as ubyte = 1
dim p1_score as uinteger = 0
dim p2_score as uinteger = 0
dim game_state as ubyte
' 0-title
' 1-initial-get-ready
' 2-playing-ssd
' 3-playing-dsd
' 4-complete-get-ready
' 5-splash-dsd
' 6-splash-dsd-extra-man
' 7-splash-extra-man
' 8-playing-worluk
' 9-worluk-escaped
' 10-playing-wizard
' 11-game-over
dim game_speed as ubyte = 1                     ' 1 - normal, 2 - fast, 3 - faster, 4 - fastest
dim game_level as ubyte = 1
dim playing_state as ubyte = 0                  ' 0 - not playing, 1 - playing
dim sprite_collision as ubyte = 0
dim sprite_slot as ubyte = 0
dim current_level as ubyte = 1
dim dungeon_id as ubyte = 1                     ' Current dungeon being displayed
dim player_lives(1 to 2) as ubyte = {3,3}       ' Lives remaining for each player
dim player_hiding(1 to 2) as ubyte = {1,1}      ' 1 - in cage, 0 - left cage
dim player_x(1 to 2) as uinteger = {64,0}       ' x pixel coordinate for each player
dim player_y(1 to 2) as uinteger = {48,0}       ' y pixel coordinate for each player
dim player_firing(1 to 2) as uinteger           ' is the player firing for each player
dim player_firing_animation_timer(1 to 2) as uinteger = {0,0} ' show firing animation until timer reaches 0
dim player_bullet_x(1 to 2) as uinteger         ' bullet x pixel coordinate for each player
dim player_bullet_y(1 to 2) as uinteger         ' bullet y pixel coordinate for each player
dim player_bullet_direction(1 to 2) as uinteger ' 0 - right, 4 - left, 1 - down, 3 - up
dim player_frame(1 to 2) as ubyte = {1,1}       ' which animation frame to show for each player    
dim player_direction(1 to 2) as ubyte = {4,0}   ' 0 - right, 4 - left, 1 - down, 3 - up
dim player_state(1 to 2) as ubyte = {0,0}       ' 0 - alive, 1 - dying, 2 - dead

dim npc_x(1 to 8) as uinteger                   ' x pixel coordinate for 6 monsters, 1 worluk and 1 wizard - 0 = dead
dim npc_y(1 to 8) as uinteger                   ' y pixel coordinate for 6 monsters, 1 worluk and 1 wizard - 0 = dead
dim npc_firing(1 to 8) as uinteger              ' is the NPC firing for 6 monsters, 1 worluk and 1 wizard
dim npc_bullet_x(1 to 8) as uinteger            ' bullet x pixel coordinate for each NPC
dim npc_bullet_y(1 to 8) as uinteger            ' bullet y pixel coordinate for each NPC
dim npc_frame(1 to 8) as ubyte                  ' which animation frame to show for each NPC 
dim npc_direction(1 to 8) as ubyte              ' 0 - right, 4 - left, 1 - down, 3 - up
dim npc_state(1 to 8) as ubyte                  ' 0 - alive, 1 - dying, 2 - dead
dim npc_type(1 to 8) as ubyte                   ' 1 - burwor, 2 - garwor, 3 - thurwor, 4 - worluk, 5 - wizard
dim npc_distance(1 to 8) as ubyte => {0,0,0,0,0,0,0,0} ' how many pixels the NPC has moved in the current direction
dim npc_frame_counter as ubyte = 4              ' how many frames between NPC actions, decreases as game speed increases
dim directions(1 to 4) as ubyte => {left_mask, right_mask, down_mask, up_mask}

dim actor_tile(1 to 20) as ubyte                ' 1-2 - players, 3-10 - 6 monsters, 1 worluk, 1 wizard, 11-12 - player bullets, 13-20 - npc bullets
