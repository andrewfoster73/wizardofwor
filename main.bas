'!org=24576
' NextBuild Layer2 Template 

#define NEX 
#define IM2 

#include <nextlib.bas>
#include <keys.bas>

declare function getTime() as uinteger
declare function lpad(target as string, to_length as ubyte) as string
declare function getJoystick(player as ubyte) as ubyte
declare function getTile(x as ubyte, y as ubyte, x_offset as ubyte, y_offset as ubyte) as ubyte
declare function canMoveRight(actor_id as ubyte, x as ubyte, y as ubyte, max_x as ubyte) as ubyte
declare function canMoveLeft(actor_id as ubyte, x as ubyte, y as ubyte, min_x as ubyte) as ubyte
declare function canMoveDown(actor_id as ubyte, x as ubyte, y as ubyte, max_y as ubyte) as ubyte
declare function canMoveUp(actor_id as ubyte, x as ubyte, y as ubyte, min_y as ubyte) as ubyte

asm 
    ; setting registers in an asm block means you can use the global equs for register names 
    nextreg TURBO_CONTROL_NR_07,%11         ; 28 mhz 
    nextreg GLOBAL_TRANSPARENCY_NR_14,$e3    ; default 
    nextreg SPRITE_CONTROL_NR_15,%00000001		; Sprites on, bits 4-2  %100 ULA on top of Sprites on top of Layer2
    ; nextreg SPRITE_CONTROL_NR_15,%00000000  ;  Display Layer Order, ULA SPRITES LAYER 2 
    nextreg LAYER2_CONTROL_NR_70,%00000000  ; 5-4 %01 = 320x256x8bpp
    NextReg $12,9					; ensure L2 bank starts at 16kb bank 9 (so bank 18 in 8kb) 
    NextReg $13,12					; ensure shadow L2 bank starts at 16kb bank 12 (so bank 24 in 8kb) 
end asm 

asm
playmusicnl:
end asm

ShowLayer2(1)

' Memory Banks
const yellow_font as ubyte = 38        ' Bank holding yellow font sprites
const light_red_font as ubyte = 39     ' Bank holding light red font sprites
const light_blue_font as ubyte = 40    ' Bank holding light blue font sprites
const actor_sprites as ubyte = 42      ' Bank holding actor sprites

' Configuration
const show_debug as ubyte = 1           ' Turn on debugging display
const calculate_fps as ubyte = 0        ' Enable/disable calculation of FPS  
const flip_title_time as uinteger = 400 ' Number of frames until flipping title <-> scoring
const player_firing_animation_frames as ubyte = 4   ' Number of frames to show firing animation
const player_pixel_speed as ubyte = 1   ' How many pixels to move the player
const player_bullet_pixel_speed as ubyte = 3
const npc_pixel_speed as ubyte = 1
const npc_bullet_pixel_speed as ubyte = 3

' Sprite Masks
const sprite_no_mask as ubyte = %00000000 ' No flags set
const sprite_xm as ubyte = %00001000      ' Horizontal mirror 
const sprite_ym as ubyte = %00000100      ' Vertical mirror

' Playing area
const min_x as ubyte = 64
const max_x as ubyte = 224
const min_y as ubyte = 48
const max_y as ubyte = 128

' Tile movement rules
const left_mask as ubyte =  %00001000
const right_mask as ubyte = %00000100
const up_mask as ubyte =    %00000010
const down_mask as ubyte =  %00000001
const tile_0 as ubyte = left_mask | down_mask
const tile_1 as ubyte = down_mask | right_mask
const tile_2 as ubyte = up_mask | right_mask
const tile_3 as ubyte = left_mask | up_mask
const tile_4 as ubyte = left_mask | up_mask | right_mask
const tile_5 as ubyte = left_mask | down_mask | right_mask
const tile_6 as ubyte = up_mask | down_mask | right_mask
const tile_7 as ubyte = left_mask | down_mask | up_mask
const tile_8 as ubyte = down_mask | up_mask
const tile_9 as ubyte = left_mask | right_mask
const tile_10 as ubyte = left_mask | down_mask | right_mask | up_mask

' Shooting area
const min_bullet_x as ubyte = 60
const max_bullet_x as ubyte = 228
const min_bullet_y as ubyte = 43
const max_bullet_y as ubyte = 133

dim t1 as uinteger              ' First read of time
dim t2 as uinteger              ' Second read of time
dim time as uinteger            ' Accepted time
dim frame as ulong              ' Current frame
dim fps as fixed                ' Frames per second
dim keypress as uinteger        ' Last key press
dim joystick(1 to 2) as ubyte   ' Last joystick input for player 1 (port 31) and player 2 (port 55)

dim hi_scores(4) as uinteger    ' Top 5 scores
dim dungeon_drawn as ubyte = 0  ' Has the dungeon been drawn yet? If so, do not draw again
dim flip_title_timer as uinteger = flip_title_time ' Countdown until flipping between title screens
dim tile_masks(10) as ubyte = {tile_0,tile_1,tile_2,tile_3,tile_4,tile_5,tile_6,tile_7,tile_8,tile_9,tile_10}

dim scoring_sprite_ids(6) as ubyte => {100,101,102,103,104,105,106}
dim player_sprite_ids(1 to 2) as ubyte => {1,2}
dim player_bullet_ids(1 to 2) as ubyte => {3,4}
dim player_dying_ids(1 to 2) as ubyte => {13,14}
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
dim explosion_pattern(1 to 24) as ubyte = {32,32,32,33,33,33,34,34,34,35,35,35,36,36,36,37,37,37,38,38,38,39,39,39}

' Game variables
dim num_players as ubyte = 1
dim p1_score as uinteger = 0
dim p2_score as uinteger = 0
dim game_state as ubyte
' 0-title
' 1-scoring
' 2-initial-get-ready
' 3-playing-ssd
' 4-playing-dsd
' 5-complete-get-ready
' 6-splash-dsd
' 7-splash-dsd-extra-man
' 8-splash-extra-man
' 9-worluk
' 10-worluk-escaped'
' 11-wizard
' 12-game-over
dim game_speed as ubyte = 1
' 1-normal, 2-fast, 3-faster, 4-fastest
dim sprite_collision as ubyte = 0
dim sprite_slot as ubyte = 0
dim dungeon_id as ubyte = 1                     ' Current dungeon being displayed
dim player_x(1 to 2) as uinteger = {64,0}       ' x pixel coordinate for each player
dim player_y(1 to 2) as uinteger = {48,0}       ' y pixel coordinate for each player
dim player_firing(1 to 2) as uinteger           ' is the player firing for each player
dim player_firing_animation_timer(1 to 2) as uinteger = {0,0} ' show firing animation until timer reaches 0
dim player_bullet_x(1 to 2) as uinteger         ' bullet x pixel coordinate for each player
dim player_bullet_y(1 to 2) as uinteger         ' bullet y pixel coordinate for each player
dim player_bullet_direction(1 to 2) as uinteger ' 0 - right, 4 - left, 1 - down, 3 - up
dim player_frame(1 to 2) as ubyte = {1,1}       ' which animation frame to show for each player    
dim player_direction(1 to 2) as ubyte = {4,0}   ' 0 - right, 4 - left, 1 - down, 3 - up
dim player_dying(1 to 2) as ubyte = {0,0}       ' 0 - alive, 1 - dying

dim npc_x(1 to 8) as uinteger                   ' x pixel coordinate for 6 monsters, 1 worluk and 1 wizard
dim npc_y(1 to 8) as uinteger                   ' y pixel coordinate for 6 monsters, 1 worluk and 1 wizard
dim npc_firing(1 to 8) as uinteger              ' is the NPC firing for 6 monsters, 1 worluk and 1 wizard
dim npc_bullet_x(1 to 8) as uinteger            ' bullet x pixel coordinate for each NPC
dim npc_bullet_y(1 to 8) as uinteger            ' bullet y pixel coordinate for each NPC
dim npc_frame(1 to 8) as ubyte                  ' which animation frame to show for each NPC 
dim npc_direction(1 to 2) as ubyte              ' 0 - right, 4 - left, 1 - down, 3 - up

dim actor_tile(1 to 20) as ubyte                ' 1-2 - players, 3-10 - 6 monsters, 1 worluk, 1 wizard, 11-12 - player bullets, 13-20 - npc bullets

setup()

' Unknowns
' * Playing music
' * Playing sound fx
' * Sprite Over equivalent?

do
    'sprite_slot = in(12347)
    frame = frame + 1
    WaitRetrace(1)

    ' Calculate FPS if enabled
    if calculate_fps = 1
        ' Need to read this twice due to how the spectrum frame counter works
        t1 = getTime()
        t2 = getTime()
        if t2 > t1 then 
            time = t2 
        else 
            time = t1 
        end if
        ' Calculate frames per second
        fps = frame / time
    end if

    ' Temporary testing key handling
    keypress = GetKeyScanCode()
    if keypress = KEY1 then
        game_state = 0
        drawTitleScreen()
    elseif keypress = KEY3 then
        dungeon_drawn = 0
        game_state = 3
    elseif keypress = KEYD then
        player_dying(1) = 1
    end if

    ' If on the title screens check if we need to flip them
    if game_state = 0 or game_state = 1 then
        flip_title_timer = flip_title_timer - 1
        if flip_title_timer = 0 then
            flipTitleScreens()
            flip_title_timer = flip_title_time
        end if
    end if

    if game_state = 3 or game_state = 4 then
        ' Draw Dungeon if not already done
        if dungeon_drawn = 0 then
            drawDungeon(dungeon_id)
        end if
    end if    

    if game_state <> 1 then
        drawPlayer1Score()
        drawPlayer2Score()
    end if

    for p = 1 to num_players
        ' Force leave start box
        joystick(p) = getJoystick(p)
        movePlayer(p)
        drawPlayer(p)
        playerFiring(p)
        movePlayerBullet(p)
        drawBullet(p)
        ' Handle collisions
        ' drawDying(p)
    next p

    ' Draw Get Ready Go + Play music
    ' Draw DSD message + Play music
    ' Draw the doors

    ' Music
    '------
    ' Check music speed

    ' Monsters
    '----------
    ' Update speed
    ' Move monster
    'drawMonster(1)
    ' Handle firing
    ' Handle collisions
    ' Update Radar

    ' End Of Level
    '-----------
    ' Check monsters dead
    ' Check if worluk appears
    ' Handle worluk kill
    ' Check if wizard appears

    ' Game Over
    '----------
    ' Draw message
    ' Check high score
    ' Draw title

    if show_debug = 1 then
        L2Text(0,0, "DBG " + STR(actor_tile(1)) + ":" + STR(tile_masks(actor_tile(1))) + ":" + STR(player_x(1)) + ":" + STR(player_y(1)) + "       ",light_red_font,0)
    end if
    ' if in(SPRITE_STATUS_SLOT_SELECT_P_303B) & BIN 00000001 = 1 then
    '     sprite_collision = 1
    ' else
    '     sprite_collision = 0
    ' end if
loop

sub movePlayer(p as ubyte)
    ' Work out which tile they are currently on as this determines the direction they can go
    dim x_offset as ubyte = 0
    dim y_offset as ubyte = 0
    if player_direction(p) = 4 then
        ' Need the back of the worrior
        x_offset = 15
    end if
    if player_direction(p) = 3 then
        ' Need the back of the worrior
        y_offset = 15
    end if
    actor_tile(p) = getTile(player_x(p),player_y(p),x_offset,y_offset)

    ' Update player direction
    if joystick(p) = 1 then
        ' RIGHT
        if canMoveRight(p, player_x(p), player_y(p), max_x) then
            player_direction(p) = 0
        end if    
        moveDirection(player_direction(p), p)
    elseif joystick(p) = 2 then
        ' LEFT 
        if canMoveLeft(p, player_x(p), player_y(p), min_x) then
            player_direction(p) = 4
        end if
        moveDirection(player_direction(p), p)
    elseif joystick(p) = 4 then
        ' DOWN
        if canMoveDown(p, player_x(p), player_y(p), max_y) then
            player_direction(p) = 1
        end if    
        moveDirection(player_direction(p), p)
    elseif joystick(p) = 8 then
        ' UP
        if canMoveUp(p, player_x(p), player_y(p), min_y) then
            player_direction(p) = 3
        end if    
        moveDirection(player_direction(p), p)
    else
        ' maintain current direction but do not move
    end if
end sub

sub movePlayerBullet(p as ubyte)
    dim x_offset as ubyte = 5
    dim y_offset as ubyte = 5
    if player_bullet_direction(p) = 4 then
        ' Need the back of the bullet
        x_offset = 10
    end if
    if player_bullet_direction(p) = 3 then
        ' Need the back of the bullet
        y_offset = 10
    end if
    actor_tile(p + 10) = getTile(player_bullet_x(p),player_bullet_y(p),x_offset,y_offset)

    if player_bullet_direction(p) = 0
        movePlayerBulletRight(p)
    elseif player_bullet_direction(p) = 4
        movePlayerBulletLeft(p)
    elseif player_bullet_direction(p) = 1
        movePlayerBulletDown(p)
    elseif player_bullet_direction(p) = 3
        movePlayerBulletUp(p)
    end if    
end sub

sub playerFiring(p as ubyte)
    if joystick(p) & BIN 00010000 = 16 and player_firing(p) = 0 then
        PlaySFX(0)
        player_firing(p) = 1
        ' TODO add extra pixels so it comes out of the gun and middle of the corridor
        player_bullet_x(p) = player_x(p)
        player_bullet_y(p) = player_y(p)
        player_bullet_direction(p) = player_direction(p)
        player_firing_animation_timer(p) = player_firing_animation_frames
    end if
end sub

sub moveDirection(d as ubyte, p as ubyte)
    if d = 0 then
        moveRight(p)
    elseif d = 4 then
        moveLeft(p)
    elseif d = 1 then
        moveDown(p)
    elseif d = 3 then
        moveUp(p)
    end if
end sub

function canMoveRight(actor_id as ubyte, x as ubyte, y as ubyte, max_x as ubyte) as ubyte
    if x >= max_x then return 0
    if y mod 16 <> 0 then return 0

    dim tile_mask as ubyte = tile_masks(actor_tile(actor_id))
    if tile_mask & right_mask = right_mask then
        return 1
    end if
    return 0
end function

function canMoveLeft(actor_id as ubyte, x as ubyte, y as ubyte, min_x as ubyte) as ubyte
    if x <= min_x then return 0
    if y mod 16 <> 0 then return 0

    dim tile_mask as ubyte = tile_masks(actor_tile(actor_id))
    if tile_mask & left_mask = left_mask then
        return 1
    end if
    return 0
end function

function canMoveDown(actor_id as ubyte, x as ubyte, y as ubyte, max_y as ubyte) as ubyte
    if y >= max_y then return 0
    if x mod 16 <> 0 then return 0

    dim tile_mask as ubyte = tile_masks(actor_tile(actor_id))
    if tile_mask & down_mask = down_mask then
        return 1
    end if
    return 0
end function

function canMoveUp(actor_id as ubyte, x as ubyte, y as ubyte, min_y as ubyte) as ubyte
    if y <= min_y then return 0
    if x mod 16 <> 0 then return 0

    dim tile_mask as ubyte = tile_masks(actor_tile(actor_id))
    if tile_mask & up_mask = up_mask then
        return 1
    end if
    return 0
end function

sub moveRight(p as ubyte)
    if canMoveRight(p, player_x(p), player_y(p), max_x) then
        player_x(p) = player_x(p) + player_pixel_speed
        updatePlayerFrame(p)
    end if
end sub

sub moveLeft(p as ubyte)
    if canMoveLeft(p, player_x(p), player_y(p), min_x) then
        player_x(p) = player_x(p) - player_pixel_speed
        updatePlayerFrame(p)
    end if
end sub

sub moveDown(p as ubyte)
    if canMoveDown(p, player_x(p), player_y(p), max_y) then
        player_y(p) = player_y(p) + player_pixel_speed
        updatePlayerFrame(p)
    end if
end sub

sub moveUp(p as ubyte)
    if canMoveUp(p, player_x(p), player_y(p), min_y) then
        player_y(p) = player_y(p) - player_pixel_speed
        updatePlayerFrame(p)
    end if
end sub

sub updatePlayerFrame(p as ubyte)
    player_frame(p) = player_frame(p) + 1
    if player_frame(p) > 12 then
        player_frame(p) = 1
    end if
end sub

sub drawPlayer(p as ubyte)
    ' %00000000 - Right
    ' %00001000 - Left
    ' %00001110 - Up
    ' %00001010 - Down
    dim image as ubyte
    if player_firing_animation_timer(p) > 0 then
        image = player_firing_image(p)
        player_firing_animation_timer(p) = player_firing_animation_timer(p) - 1
    else
        image = player_frame_images(p, frame_pattern(player_frame(p)))
    end if

    dim a3_flag as ubyte = player_direction(p) << 1
    UpdateSprite(player_x(p),player_y(p),player_sprite_ids(p),image,a3_flag,0)
end sub

sub movePlayerBulletRight(p as ubyte)
    if canMoveRight(p + 10,player_bullet_x(p),player_bullet_y(p), max_bullet_x) then 
        ' Check collision with monsters

        ' Check collision with other bullets
        player_bullet_x(p) = player_bullet_x(p) + player_bullet_pixel_speed
    else
        ' Player no longer firing
        player_firing(p) = 0
        ' Hide bullet sprite
        RemoveSprite(player_bullet_ids(p), 0)
        return
    end if
end sub

sub movePlayerBulletLeft(p as ubyte)
    if canMoveLeft(p + 10,player_bullet_x(p),player_bullet_y(p), min_bullet_x) then 
        ' Check collision with monsters

        ' Check collision with other bullets

        player_bullet_x(p) = player_bullet_x(p) - player_bullet_pixel_speed
    else
        ' Player no longer firing
        player_firing(p) = 0
        ' Hide bullet sprite
        UpdateSprite(player_bullet_x(p),player_bullet_y(p),player_bullet_ids(p),player_bullet_image,0,1)
        return
    end if
end sub

sub movePlayerBulletDown(p as ubyte)
    if canMoveDown(p + 10,player_bullet_x(p),player_bullet_y(p), max_bullet_y) then 
        ' Check collision with monsters

        ' Check collision with other bullets
        player_bullet_y(p) = player_bullet_y(p) + player_bullet_pixel_speed
    else
        ' Player no longer firing
        player_firing(p) = 0
        ' Hide bullet sprite
        RemoveSprite(player_bullet_ids(p), 0)
        return
    end if
end sub

sub movePlayerBulletUp(p as ubyte)
    if canMoveUp(p + 10,player_bullet_x(p),player_bullet_y(p), min_bullet_y) then 
        ' Check collision with monsters

        ' Check collision with other bullets
        player_bullet_y(p) = player_bullet_y(p) - player_bullet_pixel_speed
    else
        ' Player no longer firing
        player_firing(p) = 0
        ' Hide bullet sprite
        RemoveSprite(player_bullet_ids(p), 0)
        return
    end if
end sub

sub drawBullet(p as ubyte)
    if player_firing(p) = 0 return

    dim a3_flag as ubyte = player_bullet_direction(p) << 1
    UpdateSprite(player_bullet_x(p),player_bullet_y(p),player_bullet_ids(p),player_bullet_image,a3_flag,0)
end sub

sub drawDying(p as ubyte)
    if player_dying(p) = 0 return

    dim image as ubyte = player_frame_images(p, frame_pattern(player_frame(p)))
    UpdateSprite(player_x(p),player_y(p),player_dying_ids(p),image,0,0)
end sub

sub drawMonster(p as ubyte)
    UpdateSprite(50,50,3,14,0,0)
end sub

sub drawPlayer1Score()
    dim score_str as string = STR(p1_score)
    if p1_score > 0 then 
        score_str = score_str + "00"
    end if
    L2Text(24,21,"!######&",yellow_font,0)
    L2Text(24,22,"'" + lpad(score_str, 5) + score_str + "'",yellow_font,0)
    L2Text(24,23,"$%%%%%%(",yellow_font,0)
end sub

sub drawPlayer2Score()
    dim score_str as string = STR(p2_score)
    if p2_score > 0 then 
        score_str = score_str + "00"
    end if
    L2Text(0,21,"!######&",light_blue_font,0)
    L2Text(0,22,"'" + lpad(score_str, 5) + score_str + "'",light_blue_font,0)
    L2Text(0,23,"$%%%%%%(",light_blue_font,0)
end sub

sub setup()    
    ' Load font sprites
    LoadSDBank("fonts/yellow.spr",0,0,0,38)
    LoadSDBank("fonts/light_red.spr",0,0,0,39)
    LoadSDBank("fonts/light_blue.spr",0,0,0,40)

    ' Dungeon sprites
    LoadSDBank("sprites/dungeon.spr",0,0,0,41)

    ' Player, monster, bullets and door sprites
    LoadSDBank("sprites/actors.spr",0,0,0,42)
    
    ' Load dungeon maps
    LoadSDBank("dungeons/dungeon1.map",0,0,0,44)
    'LoadSDBank("dungeons/dungeon2.map",0,0,0,44)

    ' Load SFX
    LoadSDBank("vt24000.bin",0,0,0,50) 				' load the music replayer into bank 
    LoadSDBank("music/shoes.pt3",0,0,0,51) 				' load music.pt3 into bank 
    LoadSDBank("sfx/player_sfx.afb",0,0,0,52)

    ' Initialise FPS and frame counters
    time = getTime()
    frame = 0
    fps = 0

    ' Initialise players
    p1_score = 10
    p2_score = 0

    ' Reset high scores
    dim a as uinteger
    for a = 0 to 4
        hi_scores(a) = 0
    next a

    ' Initial draw of title screen
    drawTitleScreen()

    ' Initialise state
    game_state = 0

    ' Initialise sprites to sprite ram
    InitSprites2(40,0,42)

    ' Initialise SFX
    InitSFX(52)
    'InitMusic(50,51,0000)				            ' init the music engine 37 has the player, 56 the pt3, 0000 the offset in bank 34
    SetUpIM()							            ' init the IM2 code 
    EnableSFX							            ' Enables the AYFX, use DisableSFX to top
    'DisableMusic 						            ' Enables Music, use DisableMusic to stop 
end sub

sub flipTitleScreens()
    if game_state = 0 then
        game_state = 1
        drawScoringScreen()    
    elseif game_state = 1 then
        game_state = 0
        drawTitleScreen() 
    endif
end sub

sub drawTitleScreen()
    removeScoringSprites()
    CLS256(0)
    L2Text(6,1,"/1980 MIDWAY MFG. CO.",light_blue_font,0)
    L2Text(9,2,"/1983 COMMODORE",light_blue_font,0)
    drawHighScores()
    L2Text(11,22,"PRESS FIRE",light_red_font,0)
end sub

sub removeScoringSprites()
    dim i as uinteger
    for i = 0 to 6
        RemoveSprite(scoring_sprite_ids(i),0)
    next i
end sub

sub drawScoringScreen()
    CLS256(0)
    L2Text(1,1, "       BURWOR     100  POINTS",light_blue_font,0)
    L2Text(1,4, "       GARWOR     200  POINTS",yellow_font,0)
    L2Text(1,7, "      THORWOR     500  POINTS",light_red_font,0)
    L2Text(1,10,"      WORRIOR    1000  POINTS",light_blue_font,0)
    L2Text(1,13,"      WORRIOR    1000  POINTS",yellow_font,0)
    L2Text(1,16,"       WORLUK    1000  POINTS",light_red_font,0)
    L2Text(1,18,"                 DOUBLE SCORE",light_red_font,0)
    L2Text(1,20,"WIZARD OF WOR    2500  POINTS",yellow_font,0)

    UpdateSprite(150,35,100,14,sprite_xm,0)
    UpdateSprite(150,59,101,18,sprite_xm,0)
    UpdateSprite(150,83,102,22,sprite_xm,0)
    UpdateSprite(150,107,103,2,sprite_xm,0)
    UpdateSprite(150,131,104,6,sprite_xm,0)
    UpdateSprite(150,155,105,28,sprite_no_mask,0)
    UpdateSprite(150,189,106,26,sprite_xm,0)
end sub

sub drawHighScores()
    L2Text(11,5,"HIGH SCORES",light_red_font,0)
    dim score as string
    dim i as uinteger
    dim x as ubyte = 13
    dim y as ubyte = 0
    
    for i = 0 to 4
        y = 7 + i * 2
        if hi_scores(i) > 0 then
            score = lpad(STR(hi_scores(i)), 3) + STR(hi_scores(i)) + "00"
        else
            score = lpad(STR(hi_scores(i)), 5) + STR(hi_scores(i))
        end if
        L2Text(x,y,score,light_blue_font,0)
    next i
end sub 

sub drawDungeon(dungeon_id as ubyte)
    CLS256(0)
    MMU8new(5, 44) ' Load map bank into $a000 (40960)
    
    dim offset as uinteger
    
    for y = 0 to 6
        for x = 0 to 12
            offset = y * 13 + x
            DoTileBank16(x + 1, y + 1, peek(40960 + offset), 41)
        next x
    next y
    dungeon_drawn = 1
end sub


' Returns number of seconds since computer was turned on
' Uses the frame counter ports, 23672-23674
function getTime() as uinteger
    return (65536 * PEEK 23674 + 256 * PEEK 23673 + PEEK 23672)/50
end function

' Pad with spaces on left until to_length is reached
function lpad(target as string, to_length as ubyte) as string
    dim target_len as ubyte = LEN(target)
    dim padding as string = ""
    for i = to_length to target_len step - 1
        padding = padding + " "
    next i
    return padding
end function

' Returns joystick port value
function getJoystick(player as ubyte) as ubyte
    dim action as ubyte = 0
    if player = 1 then
        action = in(31) 'KEMPSTON_JOY1_P_1F
    else
        action = in(55) 'KEMPSTON_JOY2_P_37 
    end if
    return action
end function

function getTile(x as ubyte, y as ubyte, x_offset as ubyte, y_offset as ubyte) as ubyte
   dim tx as ubyte = CAST(ubyte,(x - 48 + x_offset) / 16)
   dim ty as ubyte = CAST(ubyte,(y - 48 + y_offset) / 16)
   return peek(40960 + tx + (ty * 13))
end function