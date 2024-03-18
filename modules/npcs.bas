function getStartingX() as ubyte
    return rndRange(4, 14) * 16
end function

function getStartingY() as ubyte
    return rndRange(3, 9) * 16
end function


sub shuffleDirections()
    dim d1 as ubyte
    dim d2 as ubyte
    dim random_index as ubyte

    for i = 1 to 4
        random_index = rndRange(1, 5)
        d1 = directions(i)
        d2 = directions(random_index)
        ' Swap them
        directions(random_index) = d1
        directions(i) = d2
    next i
end sub

function randomDirection(tile_mask as ubyte) as ubyte
    dim chosen_direction as ubyte = 0

    shuffleDirections()
    for i = 1 to 4
        if tile_mask & directions(i) = directions(i) then
            chosen_direction = directions(i)
            exit for
        end if
    next i 
    
    if chosen_direction = left_mask then
        return MOVING_LEFT
    elseif chosen_direction = right_mask then
        return MOVING_RIGHT
    elseif chosen_direction = down_mask then
        return MOVING_DOWN
    elseif chosen_direction = up_mask then 
        return MOVING_UP
    end if
end function

sub spawnMonsters()
    for npc = 1 to 6
        spawnMonster(npc, 1)
    next npc
end sub

sub spawnMonster(npc as ubyte, type as ubyte)
    npc_x(npc) = getStartingX()
    npc_y(npc) = getStartingY()
    npc_direction(npc) = MOVING_RIGHT
    npc_type(npc) = type
    npc_frame(npc) = 1
    drawMonster(npc, npc_type(npc), npc_x(npc), npc_y(npc))
end sub

sub moveNPC(npc as ubyte)
    ' Work out which tile they are currently on as this determines the direction they can go
    dim x_offset as ubyte = 0
    dim y_offset as ubyte = 0
    if npc_direction(npc) = 4 then
        ' Need the back of the npc
        x_offset = 15
    end if
    if npc_direction(npc) = 3 then
        ' Need the back of the npc
        y_offset = 15
    end if
    dim actor_id as ubyte = 2 + npc
    actor_tile(actor_id) = getTile(npc_x(npc), npc_y(npc), x_offset, y_offset, dungeon_id)
    dim current_tile as ubyte = actor_tile(actor_id)

    ' Update NPC direction semi-randomly
    if npc_direction(npc) = MOVING_RIGHT then
        if npc_distance(npc) > 48 then
            ' Maybe change direction
            if rndRange(1, 6) = 1 then
                npc_direction(npc) = randomDirection(tile_masks(current_tile))
                npc_distance(npc) = 0
            end if
        elseif canMoveRight(actor_id, npc_x(npc), npc_y(npc), max_x, 0) = 0 then
            npc_direction(npc) = randomDirection(tile_masks(current_tile))
        else
            if canMoveDown(actor_id, npc_x(npc), npc_y(npc), max_y, 0) then
                npc_direction(npc) = MOVING_DOWN
            elseif canMoveUp(actor_id, npc_x(npc), npc_y(npc), min_y, 0)
                npc_direction(npc) = MOVING_UP
            end if
        end if
    elseif npc_direction(npc) = MOVING_LEFT then
        if npc_distance(npc) > 48 then
            ' Maybe change direction
            if rndRange(1, 6) = 1 then
                npc_direction(npc) = randomDirection(tile_masks(current_tile))
                npc_distance(npc) = 0
            end if
        elseif canMoveLeft(actor_id, npc_x(npc), npc_y(npc), min_x, 0) = 0 then
            npc_direction(npc) = randomDirection(tile_masks(current_tile))
        else 
            if canMoveDown(actor_id, npc_x(npc), npc_y(npc), max_y, 0) then
                npc_direction(npc) = MOVING_DOWN
            elseif canMoveUp(actor_id, npc_x(npc), npc_y(npc), min_y, 0)
                npc_direction(npc) = MOVING_UP
            end if
        end if
    elseif npc_direction(npc) = MOVING_DOWN then
        if npc_distance(npc) > 48 then
            ' Maybe change direction
            if rndRange(1, 6) = 1 then
                npc_direction(npc) = randomDirection(tile_masks(current_tile))
                npc_distance(npc) = 0
            end if
        elseif canMoveDown(actor_id, npc_x(npc), npc_y(npc), max_y, 0) = 0 then
            npc_direction(npc) = randomDirection(tile_masks(current_tile))
        else
            if canMoveRight(actor_id, npc_x(npc), npc_y(npc), max_x, 0)
                npc_direction(npc) = MOVING_RIGHT
            elseif canMoveLeft(actor_id, npc_x(npc), npc_y(npc), min_x, 0) then
                npc_direction(npc) = MOVING_LEFT
            end if    
        end if
    elseif npc_direction(npc) = MOVING_UP then
        if npc_distance(npc) > 48 then
            ' Maybe change direction
            if rndRange(1, 6) = 1 then
                npc_direction(npc) = randomDirection(tile_masks(current_tile))
                npc_distance(npc) = 0
            end if
        elseif canMoveUp(actor_id, npc_x(npc), npc_y(npc), min_y, 0) = 0 then
            npc_direction(npc) = randomDirection(tile_masks(current_tile))
        else
            if canMoveRight(actor_id, npc_x(npc), npc_y(npc), max_x, 0)
                npc_direction(npc) = MOVING_RIGHT
            elseif canMoveLeft(actor_id, npc_x(npc), npc_y(npc), min_x, 0) then
                npc_direction(npc) = MOVING_LEFT
            end if               
        end if
    end if
    moveNPCDirection(npc_direction(npc), npc)
    checkNPCCollision(npc)
end sub

sub moveNPCDirection(d as ubyte, npc as ubyte)
    if d = MOVING_RIGHT then
        moveNPCRight(npc)
    elseif d = MOVING_LEFT then
        moveNPCLeft(npc)
    elseif d = MOVING_DOWN then
        moveNPCDown(npc)
    elseif d = MOVING_UP then
        moveNPCUp(npc)
    end if
end sub

sub moveNPCRight(npc as ubyte)
    if canMoveRight(2 + npc, npc_x(npc), npc_y(npc), max_x, 0) then
        ' TODO - consider game speed here?
        npc_x(npc) = npc_x(npc) + npc_pixel_speed
        npc_distance(npc) = npc_distance(npc) + npc_pixel_speed
        updateNPCFrame(npc)
    end if
end sub

sub moveNPCLeft(npc as ubyte)
    if canMoveLeft(2 + npc, npc_x(npc), npc_y(npc), min_x, 0) then
        ' TODO - consider game speed here?
        npc_x(npc) = npc_x(npc) - npc_pixel_speed
        npc_distance(npc) = npc_distance(npc) + npc_pixel_speed
        updateNPCFrame(npc)
    end if
end sub

sub moveNPCDown(npc as ubyte)
    if canMoveDown(2 + npc, npc_x(npc), npc_y(npc), max_y, 0) then
        ' TODO - consider game speed here?
        npc_y(npc) = npc_y(npc) + npc_pixel_speed
        npc_distance(npc) = npc_distance(npc) + npc_pixel_speed
        updateNPCFrame(npc)
    end if
end sub

sub moveNPCUp(npc as ubyte)
    if canMoveUp(2 + npc, npc_x(npc), npc_y(npc), min_y, 0) then
        ' TODO - consider game speed here?
        npc_y(npc) = npc_y(npc) - npc_pixel_speed
        npc_distance(npc) = npc_distance(npc) + npc_pixel_speed
        updateNPCFrame(npc)
    end if
end sub

sub drawMonster(npc as ubyte, type as ubyte, x as ubyte, y as ubyte)
    ' %00000000 - Right
    ' %00001000 - Left
    ' %00001110 - Up
    ' %00001010 - Down
    dim image as ubyte = monster_frame_images(type, npc_frame_pattern(game_speed, npc_frame(npc)))
    dim a3_flag as ubyte = npc_direction(npc) << 1
    UpdateSprite(x,y,monster_sprite_ids(npc),image,a3_flag,0)
end sub

sub drawNPCDying(npc as ubyte)
    RemoveSprite(monster_sprite_ids(npc), 0)
    dim image as ubyte = explosion_images(explosion_pattern(npc_frame(npc)))
    UpdateSprite(npc_x(npc), npc_y(npc), monster_dying_ids(npc), image, 0, 0)
    npc_frame(npc) = npc_frame(npc) + 1
    if npc_frame(npc) > 24 then
        npc_frame(npc) = 1
        if npc_type(npc) = 1 then
            npc_type(npc) = 2
            npc_state(npc) = 0
            spawnMonster(npc, npc_type(npc))
        elseif npc_type(npc) = 2 then
            npc_type(npc) = 3
            npc_state(npc) = 0
            spawnMonster(npc, npc_type(npc))
        else
            npc_state(npc) = 2
        end if
        RemoveSprite(monster_dying_ids(npc), 0)
    end if
end sub

sub updateNPCFrame(npc as ubyte)
    npc_frame(npc) = npc_frame(npc) + 1
    if npc_frame(npc) > 48 then
        npc_frame(npc) = 1
    end if
end sub
