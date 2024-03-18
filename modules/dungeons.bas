function getDungeonId(current_level as ubyte) as ubyte
    ' Level 4 is always The Arena
    if current_level = 4 then return ARENA_DUNGEON_ID

    ' Level 13 and every 6th dungeon after that is always The Pit
    if current_level >= 13 and (current_level - 13) mod 6 = 0 then return PIT_DUNGEON_ID

    ' Level 1 to 7 is a random dungeon from ids 1 to 15
    if current_level < 8 then return rndRange(1, 2)

    ' Level 8 onwards is a random dungeon from ids 16 to 25
    if current_level > 7 then return rndRange(16, 26)
end function

sub drawDungeon(dungeon_id as ubyte)
    CLS256(0)
    MMU8new(7, 44) ' Load map bank into $e000 (57344)
    
    dim offset as uinteger
    dim dungeon_offset as uinteger = (dungeon_id - 1) * 91
    
    for y = 0 to 6
        for x = 0 to 12
            offset = y * 13 + x
            DoTileBank16(x + 1, y + 1, peek(57344 + dungeon_offset + offset), 41)
        next x
    next y
    dungeon_drawn = 1
end sub