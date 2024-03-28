' x, y - coordinates of actor under test
' tx, ty - coordinates of target
' size - size of actor under test
' tsize - size of target
function collision(x as ubyte, y as ubyte, size as ubyte, tx as ubyte, ty as ubyte, tsize as ubyte) as ubyte
    if x < tx + tsize AND x + size > tx AND y < ty + tsize AND y + size > ty then
        return 1
    else
        return 0
    end if
end function

function getKillScore(npc_type as ubyte) as uinteger
    dim score as uinteger = 0
    if npc_type = BURWOR then
        score = 1
    elseif npc_type = GARWOR then
        score = 2
    elseif npc_type = THORWOR then
        score = 5
    elseif npc_type = WORLUK then
        score = 10
    elseif npc_type = WIZARD then
        score = 25
    end if
    if game_state = GAME_STATE_PLAYING_DSD then
        score = score * 2
    end if
    return score
end function


sub checkBulletCollision(p as ubyte)
    for npc = 1 to 8
        if npc_state(npc) = ALIVE OR npc_state(npc) = INVISIBLE then
            if collision(player_bullet_x(p), player_bullet_y(p), 16, npc_x(npc), npc_y(npc), 16) then
                npc_state(npc) = DYING
                npc_frame(npc) = 1
                player_firing(p) = NOT_FIRING
                player_score(p) = player_score(p) + getKillScore(npc_type(npc))
                if p = 1 then 
                    updatePlayer1Score(0, 0)
                elseif p = 2 then
                    updatePlayer2Score(0, 0)
                end if
            end if
        end if
    next npc
end sub

sub checkPlayerCollision(p as ubyte)
    for npc = 1 to 8
        if npc_state(npc) = 0 then
            if collision(player_x(p), player_y(p), 16, npc_x(npc), npc_y(npc), 16) then
                ' player_state(p) = DYING
            end if
        end if
    next npc
end sub

sub checkNPCCollision(npc as ubyte)
    for p = 1 to 2
        if collision(npc_x(npc), npc_y(npc), 16, player_x(p), player_y(p), 16) then
        end if
        if player_firing(p) = 1 then
            if collision(npc_x(npc), npc_y(npc), 16, player_bullet_x(p), player_bullet_y(p), 5) then
            end if
        end if
    next p
end sub