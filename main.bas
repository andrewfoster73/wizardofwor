'!org=24576
' NextBuild Layer2 Template 

#define NEX 
#define IM2 

#include <nextlib.bas>
#include <keys.bas>

declare function getTime() as uinteger
declare function lpad(target as string, to_length as ubyte) as string
declare function getJoystick(player as ubyte) as ubyte

asm 
    ; setting registers in an asm block means you can use the global equs for register names 
    ; 28mhz, black transparency,sprites on over border,320x256
    nextreg TURBO_CONTROL_NR_07,%11         ; 28 mhz 
    nextreg GLOBAL_TRANSPARENCY_NR_14,$e3    ; default 
    nextreg SPRITE_CONTROL_NR_15,%00000001		; Sprites on, bits 4-2  %100 ULA on top of Sprites on top of Layer2
    ; nextreg SPRITE_CONTROL_NR_15,%00000000  ;  Display Layer Order, ULA SPRITES LAYER 2 
    nextreg LAYER2_CONTROL_NR_70,%00000000  ; 5-4 %01 = 320x256x8bpp
end asm 

ShowLayer2(1)

' Memory Banks
const yellow_font as ubyte = 38        ' Bank holding yellow font sprites
const light_red_font as ubyte = 39     ' Bank holding light red font sprites
const light_blue_font as ubyte = 40    ' Bank holding light blue font sprites
const actor_sprites as ubyte = 42      ' Bank holding actor sprites

' Configuration
const show_debug as ubyte = 1           ' Turn on debugging display
const calculate_fps as ubyte = 1        ' Enable/disable calculation of FPS  
const flip_title_time as uinteger = 400 ' Number of frames until flipping title <-> scoring
const player_pixel_speed as ubyte = 1   ' How many pixels to move the player

' Sprite Masks
const sprite_no_mask as ubyte = %00000000 ' No flags set
const sprite_xm as ubyte = %00001000      ' Horizontal mirror 
const sprite_ym as ubyte = %00000100      ' Vertical mirror

dim t1 as uinteger      ' First read of time
dim t2 as uinteger      ' Second read of time
dim time as uinteger    ' Accepted time
dim frame as ulong      ' Current frame
dim fps as fixed        ' Frames per second
dim scoring_sprite_ids(6) as ubyte => {100,101,102,103,104,105,106}
dim player_sprite_ids(1 to 2) as ubyte => {1,2}
dim player_frame_images(1 to 2, 1 to 3) as ubyte = {{0,1,2},{4,5,6}} 
dim player_frame_pattern(1 to 12) as ubyte = {1,1,1,2,2,2,3,3,3,2,2,2}

' Game variables
dim num_players as ubyte = 1
dim p1_score as uinteger = 0
dim p2_score as uinteger = 0
dim hi_scores(4) as uinteger
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
dim dungeon_id as ubyte = 1
dim dungeon_drawn as ubyte = 0
dim flip_title_timer as uinteger = flip_title_time
dim keypress as uinteger
dim joystick(1 to 2) as ubyte
dim player_x(1 to 2) as uinteger = {50,0}
dim player_y(1 to 2) as uinteger = {50,0}
dim player_firing(1 to 2) as uinteger
dim player_bullet_x(1 to 2) as uinteger
dim player_bullet_y(1 to 2) as uinteger
dim player_frame(1 to 2) as ubyte = {1,1}
dim player_direction(1 to 2) as ubyte = {4,0}   ' 0 - right, 4 - left, 1 - down, 3 - up

setup()

do
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
        joystick(p) = getJoystick(p)
        movePlayer(p)
        drawPlayer(p)
        ' Force leave start box
        ' Read input
        ' Move player
        ' Handle firing
        ' Handle collisions
        ' Handle death
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
        L2Text(0,0, "DBG " + STR(fps) + "       ",light_red_font,0)
    endif
loop

sub movePlayer(p as ubyte)
    ' Update player direction
    if joystick(p) = 1 then
        ' RIGHT
        player_direction(p) = 0
        moveRight(p)
    elseif joystick(p) = 2 then
        ' LEFT 
        player_direction(p) = 4
        moveLeft(p)
    elseif joystick(p) = 4 then
        ' DOWN
        player_direction(p) = 1
        moveDown(p)
    elseif joystick(p) = 8 then
        ' UP
        player_direction(p) = 3
        moveUp(p)
    else
        ' maintain current direction but do not move
    end if
end sub

sub moveRight(p as ubyte)
    player_x(p) = player_x(p) + player_pixel_speed
    updatePlayerFrame(p)
end sub

sub moveLeft(p as ubyte)
    player_x(p) = player_x(p) - player_pixel_speed
    updatePlayerFrame(p)
end sub

sub moveDown(p as ubyte)
    player_y(p) = player_y(p) + player_pixel_speed
    updatePlayerFrame(p)
end sub

sub moveUp(p as ubyte)
    player_y(p) = player_y(p) - player_pixel_speed
    updatePlayerFrame(p)
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
    dim image as ubyte = player_frame_images(p, player_frame_pattern(player_frame(p)))
    dim a3_flag as ubyte = player_direction(p) << 1
    UpdateSprite(player_x(p),player_y(p),player_sprite_ids(p),image,a3_flag,0)
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
    ' LoadSD("sprites/actors.spr",57344,10240,0)  ' 40 sprites
    LoadSDBank("sprites/dungeon.spr",0,0,0,41)    ' 12 sprites
    LoadSDBank("sprites/actors.spr",0,0,0,42)
    
    ' Load dungeon maps
    LoadSDBank("dungeons/dungeon1.map",0,0,0,44)
    'LoadSDBank("dungeons/dungeon2.map",0,0,0,44)

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
        action = in(31)
    else
        action = in(55)
    end if
    return action
end function
