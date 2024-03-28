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
#include "modules/doors.bas"

asm 
    ; setting registers in an asm block means you can use the global equs for register names 
    nextreg TURBO_CONTROL_NR_07, %11         ; 28 mhz 
    nextreg GLOBAL_TRANSPARENCY_NR_14, $e3
    nextreg SPRITE_CONTROL_NR_15, %00000001
    nextreg LAYER2_CONTROL_NR_70, %00000000
    nextreg $12,9					; ensure L2 bank starts at 16kb bank 9 (so bank 18 in 8kb) 
    nextreg $13,12					; ensure shadow L2 bank starts at 16kb bank 12 (so bank 24 in 8kb) 
end asm 

asm
playmusicnl:
end asm

BORDER 0
ShowLayer2(1)

RANDOMIZE
setup()
titleLoop()
'gameLoop()

' Unknowns
' * Playing music

' TODO
' * Improve bullet collision
' * Collision check efficient - add "near" list
' * Killing worluk and wizard
' * Player collisions
' * Shooting other player
' * Starting in cage
' * Leaving cage
' * Monster shooting
' * Redrawing player lives upon death or extra man
' * Giving extra man
' * 22 more dungeons + Pit + Arena

sub titleLoop
    do
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
            player_lives(2) = 0
            hideAllSprites()
            gameLoop()
        elseif joystick(2) & BIN 00010000 = 16 then
            num_players = 2
            game_state = GAME_STATE_INITIAL_GET_READY
            hideAllSprites()
            gameLoop()
        end if
    loop
end sub

sub gameLoop
    do
        'sprite_slot = in(12347)
        WaitRetrace(1)

        ' Temporary testing key handling
        testHarness()

        if playing_state = FALSE then
            if game_state = GAME_STATE_INITIAL_GET_READY then
                if awaiting_timer = FALSE then
                    CLS256(0)
                    drawGetReady(31, 39)
                    drawGo(101, 77)
                    awaiting_timer = TRUE
                end if
            end if
            if game_state = GAME_STATE_SPLASH_DSD then
                if awaiting_timer = FALSE then
                    CLS256(0)
                    drawDoubleScoreDungeon(0, 20)
                    awaiting_timer = TRUE
                end if
            end if
            if game_state = GAME_STATE_SPLASH_DSD_EXTRA_MAN then
                if awaiting_timer = FALSE then
                    CLS256(0)
                    drawDoubleScoreDungeon(0, 20)
                    addExtraMan()
                    drawExtraMan()
                    awaiting_timer = TRUE
                end if
            end if
            if game_state = GAME_STATE_SPLASH_EXTRA_MAN then
                if awaiting_timer = FALSE then
                    CLS256(0)
                    addExtraMan()
                    drawExtraMan()
                    awaiting_timer = TRUE
                end if
            end if

            if awaiting_timer and get_ready_timer <> 0 then
                get_ready_timer = get_ready_timer - 1
                if get_ready_timer = 0 then
                    if double_score_dungeon = TRUE then
                        game_state = GAME_STATE_PLAYING_DSD
                    else
                        game_state = GAME_STATE_PLAYING_SSD
                    end if
                    playing_state = TRUE
                    awaiting_timer = FALSE
                    get_ready_timer = GET_READY_TIME
                end if
            end if
        end if

        if playing_state = TRUE then 
            ' Draw Dungeon if not already done
            if dungeon_drawn = FALSE then
                dungeon_id = getDungeonId(game_level)
                drawDungeon(dungeon_id, 0)
                drawRadar(game_level)
                drawPlayer1Lives()
                drawPlayer2Lives()
                drawPlayer1Score(0, 0)
                drawPlayer2Score(0, 0)
                for npc = 1 to 8
                    npc_state(npc) = ALIVE
                next npc
                spawnMonsters()
                npc_frame_counter = 4
                burwors_dead = 0
                player_x(1) = cage1_x
                player_y(1) = cage1_y
                player_x(2) = cage2_x
                player_y(2) = cage2_y
                player_hiding(1) = TRUE
                player_hiding(2) = TRUE
                closeDoors()
            end if

            ' Players
            ' -------
            for p = 1 to num_players
                if player_hiding(p) = TRUE then
                    eject_player_timer = eject_player_timer - 1
                    ' Force leaving the start cage
                    if eject_player_timer = 0 then
                        eject_player_timer = EJECT_PLAYER_TIME
                        player_leaving(p) = TRUE
                        player_leaving_timer(p) = 2
                    end if
                end if

                if player_leaving(p) = TRUE then
                    player_hiding(p) = FALSE
                    if player_leaving_timer(p) = 0 then
                        player_leaving_timer(p) = 2
                        player_y(p) = player_y(p) - player_pixel_speed
                        drawPlayer(p)
                        if player_y(p) = 128 then
                            player_leaving(p) = FALSE
                        end if
                    else
                        player_leaving_timer(p) = player_leaving_timer(p) - 1
                    end if
                else
                    joystick(p) = getJoystick(p)
                    movePlayer(p)
                    drawPlayer(p)
                    playerFiring(p)
                    movePlayerBullet(p)
                    drawBullet(p)
                    ' Handle collisions
                    if player_state(p) = DYING then
                        player_frame(p) = 1
                        drawPlayerDying(p)
                    end if
                end if
            next p
            

            ' Draw the doors
            if doors_closed = TRUE then
                if door_open_timer = 0 then
                    openDoors()
                    door_close_timer = DOOR_CLOSE_TIME
                    door_open_timer = DOOR_OPEN_TIME
                else
                    door_open_timer = door_open_timer - 1
                end if
            end if
            if doors_closed = FALSE then
                if door_close_timer = 0 then
                    closeDoors()
                    door_close_timer = DOOR_CLOSE_TIME
                    door_open_timer = DOOR_OPEN_TIME
                else
                    door_close_timer = door_close_timer - 1
                end if
            end if    

            ' Music
            '------
            ' Check music speed

            ' Monsters
            '----------
            npc_frame_counter = npc_frame_counter - 1
            if npc_frame_counter = 0 then
                ' updateSpeed
                if game_state = GAME_STATE_PLAYING_WORLUK then
                    moveNPC(7)
                    drawMonster(7, npc_type(7), npc_x(7), npc_y(7))
                    if npc_state(7) = DYING then
                        drawNPCDying(7)
                    end if
                elseif game_state = GAME_STATE_PLAYING_WIZARD then
                    ' TODO - wizard teleports every 160th frame
                    moveNPC(8)
                    drawMonster(8, npc_type(8), npc_x(8), npc_y(8))
                    if npc_state(8) = DYING then
                        drawNPCDying(8)
                    end if
                    ' monsterFire
                else
                    for npc = 1 to 6
                        if npc_state(npc) = ALIVE OR npc_state(npc) = INVISIBLE then
                            moveNPC(npc)

                            if npc_type(npc) = GARWOR OR npc_type(npc) = THORWOR then
                                ' Garwors and Thorwors may go invisible
                                if npc_state(npc) <> INVISIBLE then
                                    dim flip_invisible as ubyte = rndRange(1, 100)
                                    if flip_invisible = 1 then
                                        npc_state(npc) = INVISIBLE
                                        RemoveSprite(monster_sprite_ids(npc), 0)
                                    end if
                                elseif npc_state(npc) = INVISIBLE then
                                    ' If on the same x or y as a player become visible again
                                    dim tx as ubyte = CAST(ubyte, (npc_x(npc) - 48) / 16)
                                    dim ty as ubyte = CAST(ubyte, (npc_y(npc) - 48) / 16)
                                    for p = 1 to num_players
                                        dim px as ubyte = CAST(ubyte, (player_x(p) - 48) / 16)
                                        dim py as ubyte = CAST(ubyte, (player_y(p) - 48) / 16)
                                        if px = tx OR py = ty then
                                            npc_state(npc) = ALIVE ' i.e. not invisible
                                        end if
                                    next p
                                end if
                            end if
                            

                            if npc_state(npc) <> INVISIBLE then
                                drawMonster(npc, npc_type(npc), npc_x(npc), npc_y(npc))
                            end if
                            
                            ' monsterFire                       
                        end if
                        if npc_state(npc) = DYING then
                            drawNPCDying(npc)
                        end if
                    next npc
                end if    
                if radar_update_timer = 0 then
                    updateRadar()
                    radar_update_timer = RADAR_UPDATE_TIME
                else
                    radar_update_timer = radar_update_timer - 1
                end if
                npc_frame_counter = 4 - game_speed
            end if

            ' End Of Level
            '-----------      
            ' Are all the wors (burwor, garwor, thorwor) dead 
            if game_state = GAME_STATE_PLAYING_SSD OR game_state = GAME_STATE_PLAYING_DSD then
                wors_all_dead = TRUE    
                for npc = 1 to 6
                    if npc_state(npc) <> DEAD then
                        wors_all_dead = FALSE
                    end if
                next npc
                ' Check if worluk appears
                if wors_all_dead = TRUE then
                    spawnMonster(7, WORLUK)
                    game_state = GAME_STATE_PLAYING_WORLUK
                end if
            end if    

            if game_state = GAME_STATE_PLAYING_WORLUK then
                ' Redraw map
                drawDungeon(dungeon_id, 12)
                ' Is Worluk dead or escaped?
                if npc_state(7) = DEAD then
                    double_score_dungeon = TRUE
                    ' Will a wizard appear? 25% if worluk died, 12.5% if escaped
                    if rndRange(1, 5) = 1 then
                        game_state = GAME_STATE_PLAYING_WIZARD
                    else
                        game_state = GAME_STATE_PLAYING_DUNGEON_COMPLETE
                        playing_state = FALSE
                    end if
                elseif npc_state(7) = ESCAPED then
                    ' Will a wizard appear? 25% if worluk died, 12.5% if escaped
                    if rndRange(1, 9) = 1 then
                        game_state = GAME_STATE_PLAYING_WIZARD
                    else
                        game_state = GAME_STATE_PLAYING_DUNGEON_COMPLETE
                        game_level = game_level + 1
                        double_score_dungeon = FALSE
                        playing_state = FALSE
                        ' Draw ESCAPED to Radar
                    end if
                end if
            end if

            if game_state = GAME_STATE_PLAYING_DUNGEON_COMPLETE then
                game_level = game_level + 1
                playing_state = FALSE
            end if

            if game_state = GAME_STATE_GAME_OVER then
                playing_state = 0
                drawGameOver(31,39)
                titleLoop()
            end if
        end if

        if show_debug = 1 then
            L2Text(0,0, "DBG "  + STR(door_close_timer) + ":" + STR(player_x(p)) + ":" + STR(player_y(p)) + ":" + STR(player_bullet_y(1)) + "       ",light_red_font,0)
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
    LoadSDBank("dungeons/dungeon2.map",91,91,0,44)
    LoadSDBank("dungeons/dungeon3.map",182,91,0,44)
    LoadSDBank("dungeons/dungeon4.map",273,91,0,44)
    LoadSDBank("dungeons/dungeon5.map",364,91,0,44)
    LoadSDBank("dungeons/the_arena.map",2275,91,0,44)
    LoadSDBank("dungeons/the_pit.map",2366,91,0,44)

    ' Load SFX
    LoadSDBank("vt24000.bin",0,0,0,50) 				' load the music replayer into bank 
    LoadSDBank("music/shoes.pt3",0,0,0,51) 				' load music.pt3 into bank 
    LoadSDBank("sfx/player_sfx.afb",0,0,0,52)

    ' Initialise players
    num_players = 1
    player_score(1) = 0
    player_score(2) = 0
    player_lives(1) = 3
    player_lives(2) = 0

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
        game_level = game_level + 1
        dungeon_drawn = 0
    elseif keypress = KEYF then
        game_level = game_level - 1
        dungeon_drawn = 0
    elseif keypress = KEYG then
        drawGetReady(31, 39)
        drawGo(101, 77)
    elseif keypress = KEYM
        cls256(0)
        drawDoubleScoreDungeon(0,20)
        drawExtraMan()
    elseif keypress = KEYO
        game_state = GAME_STATE_PLAYING_WORLUK
    end if
end sub
