' Booleans
const TRUE as ubyte = 1
const FALSE as ubyte = 0

' Memory Banks
const yellow_font as ubyte = 38        ' Bank holding yellow font sprites
const light_red_font as ubyte = 39     ' Bank holding light red font sprites
const light_blue_font as ubyte = 40    ' Bank holding light blue font sprites
const actor_sprites as ubyte = 42      ' Bank holding actor sprites

' Palette colours
const YELLOW_COLOUR as ubyte = 253
const LIGHT_RED_COLOUR as ubyte = 205
const LIGHT_BLUE_COLOUR as ubyte = 111

' Configuration
const show_debug as ubyte = 1           ' Turn on debugging display
const FLIP_TITLE_TIME as uinteger = 400 ' Number of frames until flipping title <-> scoring
const GET_READY_TIME as uinteger = 100
const GAME_OVER_TIME as uinteger = 100
const EJECT_PLAYER_TIME as uinteger = 500
const DOOR_OPEN_TIME as uinteger = 500
const DOOR_CLOSE_TIME as uinteger = 500
const RADAR_UPDATE_TIME as uinteger = 16
const WIZARD_TELEPORT_TIME as uinteger = 160
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
const cage1_x as ubyte = 224
const cage1_y as ubyte = 144
const cage2_x as ubyte = 160
const cage2_y as ubyte = 144

' Tile movement rules
const left_mask as ubyte =  %00001000   ' 8 -> 4
const right_mask as ubyte = %00000100   ' 4 -> 0
const up_mask as ubyte =    %00000010   ' 2 -> 3
const down_mask as ubyte =  %00000001   ' 1 -> 1
const tile_0 as ubyte = left_mask | down_mask                           ' %00001001 - 9
const tile_1 as ubyte = down_mask | right_mask                          ' %00000101 - 5
const tile_2 as ubyte = up_mask | right_mask                            ' %00000110 - 6
const tile_3 as ubyte = left_mask | up_mask                             ' %00001010 - 10
const tile_4 as ubyte = left_mask | up_mask | right_mask                ' %00001110 - 14
const tile_5 as ubyte = left_mask | down_mask | right_mask              ' %00001101 - 13 
const tile_6 as ubyte = up_mask | down_mask | right_mask                ' %00000111 - 7
const tile_7 as ubyte = left_mask | down_mask | up_mask                 ' %00001011 - 11
const tile_8 as ubyte = down_mask | up_mask                             ' %00000011 - 3
const tile_9 as ubyte = left_mask | right_mask                          ' %00001100 - 12
const tile_10 as ubyte = left_mask | down_mask | right_mask | up_mask   ' %00001111 - 15
const tile_11 as ubyte = up_mask                                        ' %00000010 - 2

' Shooting area
const min_bullet_x as ubyte = 60
const max_bullet_x as ubyte = 228
const min_bullet_y as ubyte = 43
const max_bullet_y as ubyte = 133

' Dungeons
const ARENA_DUNGEON_ID as ubyte = 26
const PIT_DUNGEON_ID as ubyte = 27

' Game states
const GAME_STATE_TITLE as ubyte = 0
const GAME_STATE_INITIAL_GET_READY as ubyte = 1
const GAME_STATE_PLAYING_SSD as ubyte = 2
const GAME_STATE_PLAYING_DSD as ubyte = 3
const GAME_STATE_PLAYING_DUNGEON_COMPLETE as ubyte = 4
const GAME_STATE_SPLASH_DSD as ubyte = 5
const GAME_STATE_SPLASH_DSD_EXTRA_MAN as ubyte = 6
const GAME_STATE_SPLASH_EXTRA_MAN as ubyte = 7
const GAME_STATE_PLAYING_WORLUK as ubyte = 8
const GAME_STATE_PLAYING_WORLUK_ESCAPED as ubyte = 9
const GAME_STATE_PLAYING_WIZARD as ubyte = 10
const GAME_STATE_GAME_OVER as ubyte = 11

' Actor states
const ALIVE as ubyte = 0
const DYING as ubyte = 1
const DEAD as ubyte = 2
const ESCAPED as ubyte = 3
const INVISIBLE as ubyte = 5

' Firing states
const NOT_FIRING as ubyte = 0
const FIRING as ubyte = 1

' Movement
const MOVING_RIGHT as ubyte = 0
const MOVING_LEFT as ubyte = 4
const MOVING_DOWN as ubyte = 1
const MOVING_UP as ubyte = 3

' Joystick
const JOY_RIGHT as ubyte = 1
const JOY_LEFT as ubyte = 2
const JOY_DOWN as ubyte = 4
const JOY_UP as ubyte = 8

' Monster types
const BURWOR as ubyte = 1
const GARWOR as ubyte = 2
const THORWOR as ubyte = 3
const WORLUK as ubyte = 4
const WIZARD as ubyte = 5