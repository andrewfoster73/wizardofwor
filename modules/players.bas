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
    actor_tile(p) = getTile(player_x(p),player_y(p),x_offset,y_offset, dungeon_id)

    ' Update player direction
    if joystick(p) = 1 then
        ' RIGHT
        if canMoveRight(p, player_x(p), player_y(p), max_x, 0) then
            player_direction(p) = MOVING_RIGHT
        end if    
        movePlayerDirection(player_direction(p), p)
    elseif joystick(p) = 2 then
        ' LEFT 
        if canMoveLeft(p, player_x(p), player_y(p), min_x, 0) then
            player_direction(p) = MOVING_LEFT
        end if
        movePlayerDirection(player_direction(p), p)
    elseif joystick(p) = 4 then
        ' DOWN
        if canMoveDown(p, player_x(p), player_y(p), max_y, 0) then
            player_direction(p) = MOVING_DOWN
        end if    
        movePlayerDirection(player_direction(p), p)
    elseif joystick(p) = 8 then
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
    if player_bullet_direction(p) = 4 then
        ' Need the back of the bullet
        x_offset = 10
    end if
    if player_bullet_direction(p) = 3 then
        ' Need the back of the bullet
        y_offset = 10
    end if
    actor_tile(p + 10) = getTile(player_bullet_x(p),player_bullet_y(p),x_offset,y_offset, dungeon_id)

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
        player_x(p) = player_x(p) + player_pixel_speed
        updatePlayerFrame(p)
    end if
end sub

sub moveLeft(p as ubyte)
    if canMoveLeft(p, player_x(p), player_y(p), min_x, 0) then
        player_x(p) = player_x(p) - player_pixel_speed
        updatePlayerFrame(p)
    end if
end sub

sub moveDown(p as ubyte)
    if canMoveDown(p, player_x(p), player_y(p), max_y, 0) then
        player_y(p) = player_y(p) + player_pixel_speed
        updatePlayerFrame(p)
    end if
end sub

sub moveUp(p as ubyte)
    if canMoveUp(p, player_x(p), player_y(p), min_y, 0) then
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
    if canMoveRight(p + 10, player_bullet_x(p), player_bullet_y(p), max_bullet_x, 4) then 
        ' Check collision with monsters

        ' Check collision with other bullets
        player_bullet_x(p) = player_bullet_x(p) + player_bullet_pixel_speed
    else
        ' Player no longer firing
        player_firing(p) = 0
        ' Hide bullet sprite
        'RemoveSprite(player_bullet_ids(p), 0)
        return
    end if
end sub

sub movePlayerBulletLeft(p as ubyte)
    if canMoveLeft(p + 10,player_bullet_x(p),player_bullet_y(p), min_bullet_x, 4) then 
        ' Check collision with monsters

        ' Check collision with other bullets

        player_bullet_x(p) = player_bullet_x(p) - player_bullet_pixel_speed
    else
        ' Player no longer firing
        player_firing(p) = 0
        ' Hide bullet sprite
        'RemoveSprite(player_bullet_ids(p), 0)
        return
    end if
end sub

sub movePlayerBulletDown(p as ubyte)
    if canMoveDown(p + 10,player_bullet_x(p),player_bullet_y(p), max_bullet_y, 4) then 
        ' Check collision with monsters

        ' Check collision with other bullets
        player_bullet_y(p) = player_bullet_y(p) + player_bullet_pixel_speed
    else
        ' Player no longer firing
        player_firing(p) = 0
        ' Hide bullet sprite
        'RemoveSprite(player_bullet_ids(p), 0)
        return
    end if
end sub

sub movePlayerBulletUp(p as ubyte)
    if canMoveUp(p + 10,player_bullet_x(p),player_bullet_y(p), min_bullet_y, 4) then 
        ' Check collision with monsters

        ' Check collision with other bullets
        player_bullet_y(p) = player_bullet_y(p) - player_bullet_pixel_speed
    else
        ' Player no longer firing
        player_firing(p) = 0
        ' Hide bullet sprite
        'RemoveSprite(player_bullet_ids(p), 0)
        return
    end if
end sub

sub drawBullet(p as ubyte)
    if player_firing(p) = 0 return

    dim a3_flag as ubyte = player_bullet_direction(p) << 1
    UpdateSprite(player_bullet_x(p),player_bullet_y(p),player_bullet_ids(p),player_bullet_image,a3_flag,0)
end sub

sub drawDying(p as ubyte)
    RemoveSprite(p,0)
    dim image as ubyte = explosion_images(explosion_pattern(player_frame(p)))
    UpdateSprite(player_x(p),player_y(p),player_dying_ids(p),image,0,0)
    player_frame(p) = player_frame(p) + 1
    if player_frame(p) > 24 then
        player_frame(p) = 1
        'player_state(p) = 2
    end if
end sub