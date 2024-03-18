'!org=24576
' NextBuild Layer2 Template 

#define NEX 
#define IM2 

#include <nextlib.bas>
#include <keys.bas>
#include "modules/constants.bas"
#include "modules/utilities.bas"
#include "modules/globals.bas"
#include "modules/collisions.bas"
#include "modules/movement.bas"
#include "modules/players.bas"
#include "modules/npcs.bas"
#include "modules/dungeons.bas"
#include "modules/ui.bas"

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

BORDER 0
ShowLayer2(1)

RANDOMIZE
setup()
'titleLoop()
gameLoop()

' Unknowns
' * Playing music

sub titleLoop
    do
        frame = frame + 1
        WaitRetrace(1)

        ' Temporary testing key handling
        testHarness()

        ' If on the title screens check if we need to flip them
        flip_title_timer = flip_title_timer - 1
        if flip_title_timer = 0 then
            flipTitleScreens()
            flip_title_timer = FLIP_TITLE_TIME
        end if

        if title_state = 0 then
            ' TODO only do this once
            drawPlayer1Score(0,4)
            drawPlayer2Score(2,4)
        end if

        joystick(1) = getJoystick(1)
        joystick(2) = getJoystick(2)

        if joystick(1) & BIN 00010000 = 16 then
            num_players = 1
            game_state = GAME_STATE_INITIAL_GET_READY
            removeScoringSprites()
            gameLoop()
        elseif joystick(2) & BIN 00010000 = 16 then
            num_players = 2
            game_state = GAME_STATE_INITIAL_GET_READY
            removeScoringSprites()
            gameLoop()
        end if
    loop
end sub

sub gameLoop
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
        testHarness()

        if playing_state = 0 then
            if game_state = GAME_STATE_INITIAL_GET_READY then
                if awaiting_timer = 0 then
                    CLS256(0)
                    drawGetReady(31, 39)
                    drawGo(101, 77)
                    awaiting_timer = 1
                end if
                if awaiting_timer and get_ready_timer <> 0 then
                    get_ready_timer = get_ready_timer - 1
                    if get_ready_timer = 0 then
                        game_state = GAME_STATE_PLAYING_SSD
                        playing_state = 1
                        awaiting_timer = 0
                        get_ready_timer = GET_READY_TIME
                    end if
                end if
            end if
        end if

        if playing_state = 1 then 
            ' Draw Dungeon if not already done
            if dungeon_drawn = 0 then
                dungeon_id = getDungeonId(current_level)
                drawDungeon(dungeon_id)
                drawRadar(current_level)
                drawPlayer1Lives()
                drawPlayer2Lives()
                drawPlayer1Score(0,0)
                drawPlayer2Score(0,0)
                spawnMonsters()
                npc_frame_counter = 4
            end if

            ' Players
            ' -------
            for p = 1 to num_players
                if player_hiding(p) = 1 then
                    eject_player_timer = eject_player_timer - 1
                    ' Force leave start box
                    if eject_player_timer = 0 then
                        eject_player_timer = EJECT_PLAYER_TIME
                        player_hiding(p) = 0
                        ' TODO player move up
                    end if
                end if
                
                joystick(p) = getJoystick(p)
                movePlayer(p)
                drawPlayer(p)
                playerFiring(p)
                movePlayerBullet(p)
                drawBullet(p)
                ' Handle collisions
                if player_state(p) = 1 then
                    player_frame(p) = 1
                    drawPlayerDying(p)
                end if
            next p
            

            ' Draw the doors

            ' Music
            '------
            ' Check music speed

            ' Monsters
            '----------
            npc_frame_counter = npc_frame_counter - 1
            if npc_frame_counter = 0 then
                ' updateSpeed
                for npc = 1 to 6
                    if npc_state(npc) = 0 then
                        moveNPC(npc)
                        drawMonster(npc, npc_type(npc), npc_x(npc), npc_y(npc))
                        ' monsterFire
                        ' updateRadar()
                    end if
                    if npc_state(npc) = 1 then
                        drawNPCDying(npc)
                    end if
                next npc
                npc_frame_counter = 4 - game_speed
            end if

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
        end if

        if show_debug = 1 then
            L2Text(0,0, "DBG "  + STR(player_score(1))+ ":" + STR(actor_tile(11)) + ":" + STR(player_bullet_x(1)) + ":" + STR(player_bullet_y(1)) + "       ",light_red_font,0)
        end if
        ' if in(SPRITE_STATUS_SLOT_SELECT_P_303B) & BIN 00000001 = 1 then
        '     sprite_collision = 1
        ' else
        '     sprite_collision = 0
        ' end if
    loop
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
    LoadSDBank("dungeons/dungeon1.map",0,91,0,44)
    LoadSDBank("dungeons/dungeon2.map",91,0,0,44)

    ' Load SFX
    LoadSDBank("vt24000.bin",0,0,0,50) 				' load the music replayer into bank 
    LoadSDBank("music/shoes.pt3",0,0,0,51) 				' load music.pt3 into bank 
    LoadSDBank("sfx/player_sfx.afb",0,0,0,52)

    ' Initialise FPS and frame counters
    time = getTime()
    frame = 0
    fps = 0

    ' Initialise players
    player_score(1) = 0
    player_score(2) = 0

    ' Reset high scores
    dim a as uinteger
    for a = 0 to 4
        hi_scores(a) = 0
    next a

    ' Initial draw of title screen
    drawTitleScreen()

    ' Initialise state
    game_state = GAME_STATE_PLAYING_SSD
    playing_state = 1

    ' Initialise sprites to sprite ram
    InitSprites2(40,0,42)

    ' Initialise SFX
    InitSFX(52)
    'InitMusic(50,51,0000)				            ' init the music engine 50 has the player, 51 the pt3, 0000 the offset in bank 51
    SetUpIM()							            ' init the IM2 code 
    EnableSFX							            ' Enables the AYFX, use DisableSFX to top
    'EnableMusic 						            ' Enables Music, use DisableMusic to stop 
end sub

sub testHarness()
    ' Temporary testing key handling
    keypress = GetKeyScanCode()
    if keypress = KEY1 then
        game_state = 0
        drawTitleScreen()
    elseif keypress = KEY3 then
        dungeon_drawn = 0
        game_state = 3
    elseif keypress = KEYD then
        player_state(1) = 1
    elseif keypress = KEYE then
        current_level = current_level + 1
        dungeon_drawn = 0
    elseif keypress = KEYG then
        drawGetReady(31, 39)
        drawGo(101, 77)
    elseif keypress = KEYM
        drawDoubleScoreDungeon(0,20)
    elseif keypress = KEYO
        drawGameOver(31,39)
    elseif keypress = KEYR
        L2Text(0,1, "DBG " + STR(rndRange(1, 5)) + ":" + "       ",light_red_font,0)
    end if
end sub
