sub addExtraMan()
    for p = 1 to num_players
        if player_lives(p) <> 0 then
            player_lives(p) = player_lives(p) + 1
        end if
    next p    
end sub

sub movePlayer(p as ubyte)
    ' If the player is still in the cage only accept UP
    if player_hiding(p) = TRUE then
        if joystick(p) <> JOY_UP then
            return
        else
            player_leaving(p) = TRUE
        end if
    end if
    ' Work out which tile they are currently on as this determines the direction they can go
    dim x_offset as ubyte = 0
    dim y_offset as ubyte = 0
    if player_direction(p) = MOVING_LEFT then
        ' Need the back of the worrior
        x_offset = 15
    end if
    if player_direction(p) = MOVING_UP then
        ' Need the back of the worrior
        y_offset = 15
    end if
    actor_tile(p) = getTile(player_x(p),player_y(p),x_offset,y_offset, dungeon_id)

    ' Update player direction
    if joystick(p) = JOY_RIGHT then
        ' RIGHT
        if canMoveRight(p, player_x(p), player_y(p), max_x, 0) then
            player_direction(p) = MOVING_RIGHT
        end if    
        movePlayerDirection(player_direction(p), p)
    elseif joystick(p) = JOY_LEFT then
        ' LEFT 
        if canMoveLeft(p, player_x(p), player_y(p), min_x, 0) then
            player_direction(p) = MOVING_LEFT
        end if
        movePlayerDirection(player_direction(p), p)
    elseif joystick(p) = JOY_DOWN then
        ' DOWN
        if canMoveDown(p, player_x(p), player_y(p), max_y, 0) then
            player_direction(p) = MOVING_DOWN
        end if    
        movePlayerDirection(player_direction(p), p)
    elseif joystick(p) = JOY_UP then
        ' UP
        if canMoveUp(p, player_x(p), player_y(p), min_y, 0) then
            player_direction(p) = MOVING_UP
        end if    
        movePlayerDirection(player_direction(p), p)
    else
        ' maintain current direction but do not move
    end if
end sub

sub movePlayerBullet(p as ubyte)
    dim x_offset as ubyte = 0
    dim y_offset as ubyte = 0
    if player_bullet_direction(p) = MOVING_RIGHT then
        x_offset = -5
    end if
    if player_bullet_direction(p) = MOVING_LEFT then
        x_offset = 21
    end if
    if player_bullet_direction(p) = MOVING_DOWN then
        y_offset = -5
    end if
    if player_bullet_direction(p) = MOVING_UP then
        y_offset = 21
    end if
    actor_tile(p + 10) = getTile(player_bullet_x(p), player_bullet_y(p), x_offset, y_offset, dungeon_id)

    if player_bullet_direction(p) = MOVING_RIGHT
        movePlayerBulletRight(p)
    elseif player_bullet_direction(p) = MOVING_LEFT
        movePlayerBulletLeft(p)
    elseif player_bullet_direction(p) = MOVING_DOWN
        movePlayerBulletDown(p)
    elseif player_bullet_direction(p) = MOVING_UP
        movePlayerBulletUp(p)
    end if    
end sub

sub playerFiring(p as ubyte)
    if player_hiding(p) = TRUE then return

    if joystick(p) & BIN 00010000 = 16 and player_firing(p) = 0 then
        PlaySFX(0)
        player_firing(p) = FIRING
        ' TODO add extra pixels so it comes out of the gun and middle of the corridor
        player_bullet_x(p) = player_x(p)
        player_bullet_y(p) = player_y(p)
        player_bullet_direction(p) = player_direction(p)
        player_firing_animation_timer(p) = player_firing_animation_frames
    end if
end sub

sub movePlayerDirection(d as ubyte, p as ubyte)
    if d = MOVING_RIGHT then
        moveRight(p)
    elseif d = MOVING_LEFT then
        moveLeft(p)
    elseif d = MOVING_DOWN then
        moveDown(p)
    elseif d = MOVING_UP then
        moveUp(p)
    end if
end sub

sub moveRight(p as ubyte)
    if canMoveRight(p, player_x(p), player_y(p), max_x, 0) then
        if player_y(p) = 80 AND doors_closed = FALSE then
            traverseDoorRight()
            player_x(p) = 64
        end if
        player_x(p) = player_x(p) + player_pixel_speed
        updatePlayerFrame(p)
        checkPlayerCollision(p)
    end if
end sub

sub moveLeft(p as ubyte)
    if canMoveLeft(p, player_x(p), player_y(p), min_x, 0) then
        if player_y(p) = 80 AND doors_closed = FALSE then
            traverseDoorLeft()
            player_x(p) = 224
        end if
        player_x(p) = player_x(p) - player_pixel_speed
        updatePlayerFrame(p)
        checkPlayerCollision(p)
    end if
end sub

sub moveDown(p as ubyte)
    if canMoveDown(p, player_x(p), player_y(p), max_y, 0) then
        player_y(p) = player_y(p) + player_pixel_speed
        updatePlayerFrame(p)
        checkPlayerCollision(p)
    end if
end sub

sub moveUp(p as ubyte)
    if canMoveUp(p, player_x(p), player_y(p), min_y, 0) then
        player_y(p) = player_y(p) - player_pixel_speed
        updatePlayerFrame(p)
        checkPlayerCollision(p)
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
    UpdateSprite(player_x(p), player_y(p), player_sprite_ids(p), image, a3_flag, 0)
end sub

sub movePlayerBulletRight(p as ubyte)
    if canMoveRight(p + 10, player_bullet_x(p), player_bullet_y(p), max_bullet_x, 4) then 
        ' Check collision with monsters
        checkBulletCollision(p)

        ' Check collision with other bullets
        player_bullet_x(p) = player_bullet_x(p) + player_bullet_pixel_speed
    else
        ' Player no longer firing
        player_firing(p) = NOT_FIRING

        ' Hide bullet sprite
        RemoveSprite(player_bullet_ids(p), 0)
    end if
end sub

sub movePlayerBulletLeft(p as ubyte)
    if canMoveLeft(p + 10, player_bullet_x(p), player_bullet_y(p), min_bullet_x, 4) then 
        ' Check collision with monsters
        checkBulletCollision(p)

        ' Check collision with other bullets

        player_bullet_x(p) = player_bullet_x(p) - player_bullet_pixel_speed
    else
        ' Player no longer firing
        player_firing(p) = NOT_FIRING

        ' Hide bullet sprite
        RemoveSprite(player_bullet_ids(p), 0)
    end if
end sub

sub movePlayerBulletDown(p as ubyte)
    if canMoveDown(p + 10, player_bullet_x(p), player_bullet_y(p), max_bullet_y, 4) then 
        ' Check collision with monsters
        checkBulletCollision(p)

        ' Check collision with other bullets
        player_bullet_y(p) = player_bullet_y(p) + player_bullet_pixel_speed
    else
        ' Player no longer firing
        player_firing(p) = NOT_FIRING

        ' Hide bullet sprite
        RemoveSprite(player_bullet_ids(p), 0)
    end if
end sub

sub movePlayerBulletUp(p as ubyte)
    if canMoveUp(p + 10, player_bullet_x(p), player_bullet_y(p), min_bullet_y, 4) then 
        ' Check collision with monsters
        checkBulletCollision(p)

        ' Check collision with other bullets
        player_bullet_y(p) = player_bullet_y(p) - player_bullet_pixel_speed
    else
        ' Player no longer firing
        player_firing(p) = NOT_FIRING

        ' Hide bullet sprite
        RemoveSprite(player_bullet_ids(p), 0)
    end if
end sub

sub drawBullet(p as ubyte)
    if player_firing(p) = NOT_FIRING return

    dim a3_flag as ubyte = player_bullet_direction(p) << 1
    UpdateSprite(player_bullet_x(p), player_bullet_y(p), player_bullet_ids(p), player_bullet_image, a3_flag, 0)
end sub

sub drawPlayerDying(p as ubyte)
    RemoveSprite(p, 0)
    dim image as ubyte = explosion_images(explosion_pattern(player_frame(p)))
    UpdateSprite(player_x(p), player_y(p), player_dying_ids(p), image, 0, 0)
    player_frame(p) = player_frame(p) + 1
    if player_frame(p) > 24 then
        player_frame(p) = 1
        player_state(p) = DEAD
        ' Reduce number of lives
        player_lives(p) = player_lives(p) - 1
        if player_lives(1) = 0 AND player_lives(2) = 0 then
            ' If no lives left for both players go to GAME_OVER state
            game_state = GAME_STATE_GAME_OVER
        end if
    end if
end sub