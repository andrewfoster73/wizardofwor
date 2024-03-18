function canMoveRight(actor_id as ubyte, x as ubyte, y as ubyte, max_x as ubyte, x_offset as ubyte) as ubyte
    if x >= max_x then return 0
    if y mod 16 <> 0 then return 0

    dim tile_mask as ubyte = tile_masks(actor_tile(actor_id))
    if tile_mask & right_mask = right_mask then
        return 1
    else
        if x mod 16 < x_offset then return 1
    end if
    return 0
end function

function canMoveLeft(actor_id as ubyte, x as ubyte, y as ubyte, min_x as ubyte, x_offset as ubyte) as ubyte
    if x <= min_x then return 0
    if y mod 16 <> 0 then return 0

    dim tile_mask as ubyte = tile_masks(actor_tile(actor_id))
    if tile_mask & left_mask = left_mask then
        return 1
    else
        if x mod 16 > x_offset then return 1
    end if
    return 0
end function

function canMoveDown(actor_id as ubyte, x as ubyte, y as ubyte, max_y as ubyte, y_offset as ubyte) as ubyte
    if y >= max_y then return 0
    if x mod 16 <> 0 then return 0

    dim tile_mask as ubyte = tile_masks(actor_tile(actor_id))
    if tile_mask & down_mask = down_mask then
        return 1
    else
        if y mod 16 < y_offset then return 1
    end if
    return 0
end function

function canMoveUp(actor_id as ubyte, x as ubyte, y as ubyte, min_y as ubyte, y_offset as ubyte) as ubyte
    if y <= min_y then return 0
    if x mod 16 <> 0 then return 0

    dim tile_mask as ubyte = tile_masks(actor_tile(actor_id))
    if tile_mask & up_mask = up_mask then
        return 1
    else
        if y mod 16 > y_offset then return 1
    end if
    return 0
end function