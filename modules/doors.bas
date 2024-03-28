sub openDoors()
    doors_closed = FALSE
    UpdateSprite(48, 80, door_ids(1), door_open_image, sprite_no_mask, 0)
    UpdateSprite(240, 80, door_ids(2), door_open_image, sprite_xm, 0)
end sub

sub closeDoors()
    doors_closed = TRUE
    UpdateSprite(48, 80, door_ids(1), door_closed_image, sprite_no_mask, 0)
    UpdateSprite(240, 80, door_ids(2), door_closed_image, sprite_xm, 0)
end sub

sub traverseDoorLeft()
    closeDoors()
    door_close_timer = DOOR_CLOSE_TIME
    door_open_timer = DOOR_OPEN_TIME
end sub

sub traverseDoorRight()
    closeDoors()
    door_close_timer = DOOR_CLOSE_TIME
    door_open_timer = DOOR_OPEN_TIME
end sub