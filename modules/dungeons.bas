function getDungeonId(game_level as ubyte) as ubyte
    ' Level 4 is always The Arena
    if game_level = 4 then return ARENA_DUNGEON_ID

    ' Level 13 and every 6th dungeon after that is always The Pit
    if game_level >= 13 and (game_level - 13) mod 6 = 0 then return PIT_DUNGEON_ID

    ' Level 1 to 7 is a random dungeon from ids 1 to 15
    if game_level < 8 then return rndRange(1, 6)

    ' Level 8 onwards is a random dungeon from ids 16 to 25
    if game_level > 7 then return rndRange(16, 26)
end function

sub drawDungeon(dungeon_id as ubyte, palette_offset as ubyte)
    CLS256(0)
    MMU8new(7, 44) ' Load map bank into $e000 (57344)
    
    dim offset as uinteger
    dim map_bytes as uinteger = 91
    dim dungeon_offset as uinteger = cast(uinteger,(dungeon_id - 1) * map_bytes)
    
    for y = 0 to 6
        for x = 0 to 12
            offset = cast(uinteger, y * 13 + x)
            DoTileBank16(x + 1, y + 1, peek(cast(uinteger, 57344 + dungeon_offset + offset)) + palette_offset, 41)
        next x
    next y
    dungeon_drawn = 1
end sub