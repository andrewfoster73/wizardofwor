' Returns number of seconds since computer was turned on
' Uses the frame counter ports, 23672-23674
function getTime() as uinteger
    return (65536 * PEEK 23674 + 256 * PEEK 23673 + PEEK 23672)/50
end function

' Pad with spaces on left until to_length is reached
function lpad(target as string, to_length as ubyte, char as string) as string
    dim target_len as ubyte = LEN(target)
    dim padding as string = ""
    for i = to_length to target_len step - 1
        padding = padding + char
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

function getTile(x as ubyte, y as ubyte, x_offset as ubyte, y_offset as ubyte, dungeon_id as ubyte) as ubyte
   dim tx as ubyte = CAST(ubyte,(x - 48 + x_offset) / 16)
   dim ty as ubyte = CAST(ubyte,(y - 48 + y_offset) / 16)
   dim dungeon_offset as uinteger = (dungeon_id - 1) * 91
   return peek(57344 + dungeon_offset + tx + (ty * 13))
end function

function rndRange(first As ubyte, last As ubyte) as ubyte
    return CAST(ubyte, RND * (last - first) + first)
end function