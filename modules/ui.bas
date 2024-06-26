sub drawPlayer1Lives()
    for l = 1 to 5
        RemoveSprite(player_lives_ids(1, l), 0)
    next l
    if player_lives(1) = 0 then return
    for l = 1 to player_lives(1) - 1
        UpdateSprite(240, 160-l*16, player_lives_ids(1, l), 6, sprite_xm, 0)
    next l
end sub

sub drawPlayer2Lives()
    for l = 1 to 5
        RemoveSprite(player_lives_ids(2, l), 0)
    next l
    if player_lives(2) = 0 then return
    for l = 1 to player_lives(2) - 1
        UpdateSprite(48, 160-l*16, player_lives_ids(2, l), 2, sprite_no_mask, 0)
    next l
end sub

sub drawPlayer1Score(x_offset as ubyte, y_offset as ubyte)
    L2Text(22 + x_offset,16 + y_offset,"!######&",yellow_font,0)
    L2Text(22 + x_offset,18 + y_offset,"$%%%%%%(",yellow_font,0)
    updatePlayer1Score(x_offset, y_offset)
end sub

sub updatePlayer1Score(x_offset as ubyte, y_offset as ubyte)
    dim score_str as string = STR(player_score(1))
    if player_score(1) > 0 then 
        score_str = score_str + "00"
    end if
    L2Text(22 + x_offset, 17 + y_offset, "'" + lpad(score_str, 5, " ") + score_str + "'", yellow_font, 0)
end sub

sub drawPlayer2Score(x_offset as ubyte, y_offset as ubyte)
    L2Text(0 + x_offset,16 + y_offset,"!######&",light_blue_font,0)
    L2Text(0 + x_offset,18 + y_offset,"$%%%%%%(",light_blue_font,0)
    updatePlayer2Score(x_offset, y_offset)
end sub

sub updatePlayer2Score(x_offset as ubyte, y_offset as ubyte)
    dim score_str as string = STR(player_score(2))
    if player_score(2) > 0 then 
        score_str = score_str + "00"
    end if
    L2Text(0 + x_offset, 17 + y_offset, "'" + lpad(score_str, 5, " ") + score_str + "'", light_blue_font, 0)
end sub

sub drawRadar(game_level as ubyte)
    dim message as string
    if game_level = 1 then
        message = "###RADAR###"
    elseif game_level = 4 then
        message = "#THE ARENA#"
    elseif game_level >= 13 and (game_level - 13) mod 6 = 0 then
        message = "##THE PIT##"
    else
        message = "DUNGEON " + STR(game_level)
        'message = "DUNGEON" + lpad(STR(game_level), 4, " ")
    end if
    L2Text(8, 14, "!" + message + "&", light_blue_font, 0)
    'updateRadar()
end sub

sub updateRadar()
    ' Build radar from monster grid positions
    dim row as string = ""
    dim hit as ubyte = FALSE
    dim tx as ubyte = 0
    dim ty as ubyte = 0
    dim font as ubyte = light_blue_font

    ' Clear the whole radar
    for y = 1 to 6
        L2Text(8, 14 + y, "'           '", light_blue_font, 0)
    next y

    for npc = 1 to 6
        if npc_state(npc) = ALIVE OR npc_state(npc) = INVISIBLE then
            tx = CAST(ubyte, (npc_x(npc) - 48) / 16)
            ty = CAST(ubyte, (npc_y(npc) - 48) / 16)
            if npc_type(npc) = BURWOR then
                font = light_blue_font
            elseif npc_type(npc) = GARWOR then
                font = yellow_font
            elseif npc_type(npc) = THORWOR then
                font = light_red_font
            end if
            L2Text(8 + tx, 15 + ty, ")", font, 0)
        end if    
    next npc
end sub

sub flipTitleScreens()
    if title_state = 0 then
        title_state = 1
        drawScoringScreen()    
    elseif title_state = 1 then
        title_state = 0
        drawTitleScreen() 
    endif
end sub

sub drawTitleScreen()
    hideAllSprites()
    CLS256(0)
    L2Text(6,1,"/1980 MIDWAY MFG. CO.",light_blue_font,0)
    L2Text(9,2,"/1983 COMMODORE",light_blue_font,0)
    drawHighScores()
    L2Text(11,22,"PRESS FIRE",light_red_font,0)
end sub

sub hideAllSprites()
    for i = 0 to 6
        RemoveSprite(scoring_sprite_ids(i), 0)
    next i
    for p = 1 to 2
        for i = 1 to 5
            RemoveSprite(player_lives_ids(p, i), 0)
        next i
    next p
end sub

sub drawScoringScreen()
    CLS256(0)
    L2Text(1,1, "       BURWOR     100  POINTS",light_blue_font,0)
    L2Text(1,4, "       GARWOR     200  POINTS",yellow_font,0)
    L2Text(1,7, "      THORWOR     500  POINTS",light_red_font,0)
    L2Text(1,10,"      WORRIOR    1000  POINTS",light_blue_font,0)
    L2Text(1,13,"      WORRIOR    1000  POINTS",yellow_font,0)
    L2Text(1,16,"       WORLUK    1000  POINTS",light_red_font,0)
    L2Text(1,18,"                 DOUBLE SCORE",light_red_font,0)
    L2Text(1,20,"WIZARD OF WOR    2500  POINTS",yellow_font,0)

    UpdateSprite(150,35,100,14,sprite_xm,0)
    UpdateSprite(150,59,101,18,sprite_xm,0)
    UpdateSprite(150,83,102,22,sprite_xm,0)
    UpdateSprite(150,107,103,2,sprite_xm,0)
    UpdateSprite(150,131,104,6,sprite_xm,0)
    UpdateSprite(150,155,105,28,sprite_no_mask,0)
    UpdateSprite(150,189,106,26,sprite_xm,0)
end sub

sub drawHighScores()
    L2Text(11,5,"HIGH SCORES",light_red_font,0)
    dim score as string
    dim i as uinteger
    dim x as ubyte = 13
    dim y as ubyte = 0
    
    for i = 0 to 4
        y = 7 + i * 2
        if hi_scores(i) > 0 then
            score = lpad(STR(hi_scores(i)), 3, " ") + STR(hi_scores(i)) + "00"
        else
            score = lpad(STR(hi_scores(i)), 5, " ") + STR(hi_scores(i))
        end if
        L2Text(x,y,score,light_blue_font,0)
    next i
end sub 

sub drawGetReady(x_offset as ubyte, y_offset as ubyte)
    drawLargeChar(@large_g, x_offset, y_offset, YELLOW_COLOUR)
    drawLargeChar(@large_e, x_offset + 22, y_offset, YELLOW_COLOUR)
    drawLargeChar(@large_t, x_offset + 44, y_offset, YELLOW_COLOUR)

    drawLargeChar(@large_r, x_offset + 74, y_offset, YELLOW_COLOUR)
    drawLargeChar(@large_e, x_offset + 96, y_offset, YELLOW_COLOUR)
    drawLargeChar(@large_a, x_offset + 118, y_offset, YELLOW_COLOUR)
    drawLargeChar(@large_d, x_offset + 140, y_offset, YELLOW_COLOUR)
    drawLargeChar(@large_y, x_offset + 162, y_offset, YELLOW_COLOUR)
end sub

sub drawGo(x_offset as ubyte, y_offset as ubyte)
    drawLargeChar(@large_g, x_offset, y_offset, YELLOW_COLOUR)
    drawLargeChar(@large_o, x_offset + 22, y_offset, YELLOW_COLOUR)
end sub

sub drawDoubleScoreDungeon(x_offset as ubyte, y_offset as ubyte)
    cls256(0)
    drawLargeChar(@large_d, x_offset + 60, y_offset, LIGHT_BLUE_COLOUR)
    drawLargeChar(@large_o, x_offset + 82, y_offset, LIGHT_BLUE_COLOUR)
    drawLargeChar(@large_u, x_offset + 104, y_offset, LIGHT_BLUE_COLOUR)
    drawLargeChar(@large_b, x_offset + 126, y_offset, LIGHT_BLUE_COLOUR)
    drawLargeChar(@large_l, x_offset + 148, y_offset, LIGHT_BLUE_COLOUR)
    drawLargeChar(@large_e, x_offset + 170, y_offset, LIGHT_BLUE_COLOUR)

    drawLargeChar(@large_s, x_offset + 73, y_offset + 34, YELLOW_COLOUR)
    drawLargeChar(@large_c, x_offset + 95, y_offset + 34, YELLOW_COLOUR)
    drawLargeChar(@large_o, x_offset + 117, y_offset + 34, YELLOW_COLOUR)
    drawLargeChar(@large_r, x_offset + 139, y_offset + 34, YELLOW_COLOUR)
    drawLargeChar(@large_e, x_offset + 161, y_offset + 34, YELLOW_COLOUR)

    drawLargeChar(@large_d, x_offset + 50, y_offset + 70, LIGHT_RED_COLOUR)
    drawLargeChar(@large_u, x_offset + 72, y_offset + 70, LIGHT_RED_COLOUR)
    drawLargeChar(@large_n, x_offset + 94, y_offset + 70, LIGHT_RED_COLOUR)
    drawLargeChar(@large_g, x_offset + 116, y_offset + 70, LIGHT_RED_COLOUR)
    drawLargeChar(@large_e, x_offset + 138, y_offset + 70, LIGHT_RED_COLOUR)
    drawLargeChar(@large_o, x_offset + 160, y_offset + 70, LIGHT_RED_COLOUR)
    drawLargeChar(@large_n, x_offset + 182, y_offset + 70, LIGHT_RED_COLOUR)
end sub

sub drawExtraMan()
    L2Text(10, 18, "BONUS PLAYER", yellow_font, 0)
    UpdateSprite(210, 170, player_lives_ids(1, 1), 6, sprite_xm, 0)
    if player_lives(2) > 0 then
        UpdateSprite(90, 170, player_lives_ids(2, 1), 2, sprite_no_mask, 0)
    end if    
end sub

sub drawGameOver(x_offset as ubyte, y_offset as ubyte)
    drawLargeChar(@large_g, x_offset, y_offset, LIGHT_RED_COLOUR)
    drawLargeChar(@large_a, x_offset + 22, y_offset, LIGHT_RED_COLOUR)
    drawLargeChar(@large_m, x_offset + 44, y_offset, LIGHT_RED_COLOUR)
    drawLargeChar(@large_e, x_offset + 66, y_offset, LIGHT_RED_COLOUR)

    drawLargeChar(@large_o, x_offset + 96, y_offset, LIGHT_RED_COLOUR)
    drawLargeChar(@large_v, x_offset + 118, y_offset, LIGHT_RED_COLOUR)
    drawLargeChar(@large_e, x_offset + 140, y_offset, LIGHT_RED_COLOUR)
    drawLargeChar(@large_r, x_offset + 162, y_offset, LIGHT_RED_COLOUR)
end sub

sub drawLargeChar(address as uinteger, x_offset as ubyte, y_offset as ubyte, colour as ubyte)
    dim c as ubyte      ' colour to plot
    dim p as ubyte      ' 0 - black, 1 - use colour, 2 - don't draw
    dim y as uinteger
    dim x as uinteger
    for y = 0 to 28
        for x = 0 to 15
            p = peek(address + (y * 16) + x)
            if p = 0 then
                c = 0
            else
                c = colour
            end if 
            if p <> 2 then
                PlotL2(x_offset + x,y_offset + y,c)
            end if
        next x
    next y
end sub

large_a:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
end asm

large_b:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0
end asm

large_c:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
end asm

large_d:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0
end asm

large_e:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
end asm

large_g:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
end asm

large_l:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
end asm

large_m:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,0,0,0,0,1,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,0,0,1,1,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,0,1,1,1,1,0,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,0,0,1,1,0,0,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
end asm

large_n:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,1,1,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
end asm

large_o:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
end asm

large_r:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,2,1,1,1,1,1,1,0,0,0,0
db 0,0,0,0,0,2,2,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,2,2,2,0,0,0,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,1,1,1,1,1,0,0
db 0,0,0,0,0,2,2,2,2,2,0,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
end asm

large_s:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2
db 0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1
db 2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0
db 2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0
db 2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1
db 2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0
db 2,2,2,2,2,2,2,2,2,2,2,0,0,0,0,0
db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
end asm

large_t:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
end asm

large_u:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0
end asm

large_v:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 2,2,2,1,1,1,1,1,1,1,1,1,1,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
end asm

large_y:
asm
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 1,1,1,1,1,2,2,2,2,2,2,1,1,1,1,1
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,0,0,0,0,2,2,2,2,2,2,0,0,0,0,0
db 0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
db 2,2,2,1,1,1,1,1,1,1,1,1,1,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,0,0,0,0,0,0,2,2,2,2,2
db 2,2,2,2,2,1,1,1,1,1,1,2,2,2,2,2
end asm