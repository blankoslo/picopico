-- TODOs:
-- - add bullet with direction
-- - hit detect bullet
-- - blood splat on bullet hit in direction
-- - monster ai
-- - rotate sprites
-- - world map 
-- - map entity: cactus, mountain, hay balls (? you know... ?)
-- - collection detection on map entities
--
monster_sprite = {x = 0, y = 16, w = 16, h = 16}
player_sprite = {x = 0, y = 0, w = 16, h = 16}
sprites = {monster_sprite, player_sprite}
blood_sprites = {x = 16, y = 0, w = 8, h = 8, frames = 8}
particle_sprites = {blood_sprites}
monster = {x = 1, y = 10, type = "monster", sprite = monster_sprite}
player = {x = 1, y = 30, type = "player", sprite = player_sprite}
bullet = {x = 1, y = 40, type = "bullet", color = 5, angle = 60}
entities = {monster, player}
angles = {right = 270, left = 90, down = 180, up = 0}
function print_coords(x, y) print("x:" .. x .. ";y:" .. y) end

function intersect_box(b1, b2)
    return not ((b1.x >= b2.x + b2.w) or (b1.x + b1.w <= b2.x) or
               (b1.y >= b2.y + b2.h) or (b1.y + b1.h <= b2.y))
end

function intersect_pixels(e1, e2)
    local pixels = {}
    local sp1 = (e1.sprite and e1.sprite.pixels) or {{x = 0, y = 0}}
    local sp2 = (e2.sprite and e2.sprite.pixels) or {{x = 0, y = 0}}
    for p1 in all(sp1) do
        local x1 = p1.x + e1.x
        local y1 = p1.y + e1.y
        for p2 in all(sp2) do
            local x2 = p2.x + e2.x
            local y2 = p2.y + e2.y
            if (x1 == x2 and y1 == y2) then
                add(pixels, {x = x1, y = y1})
            end
        end
    end
    return pixels
end

function entity_as_box(e)
    local w = 1
    local h = 1
    if e.sprite then
        w = e.sprite.w
        h = e.sprite.h
    end
    return {x = e.x, y = e.y, w = w, h = h}
end

function intersect(e1, e2)
    if (intersect_box(entity_as_box(e1), entity_as_box(e2))) then
        return intersect_pixels(e1, e2)
    end
    return {}
end

function draw_entity(entity)
    if (entity.sprite) then
        sspr(entity.sprite.x, entity.sprite.y, entity.sprite.w, entity.sprite.h,
             entity.x, entity.y)
    else
        pset(entity.x, entity.y, entity.color)
    end
end

function draw_splatter(x, y, angle, frame_percent)
    for f = 0, flr(frame_percent) % blood_sprites.frames do
        rectfill(x, y, x + 8, y + 8, 0)
        sspr(blood_sprites.x + blood_sprites.w * f, blood_sprites.y,
             blood_sprites.w, blood_sprites.h, x, y)
    end

end

function _init()
    for s in all(sprites) do
        local pixels = {}
        for x = 0, s.w - 1 do
            for y = 0, s.h - 1 do
                if sget(x + s.x, y + s.y) ~= 0 then
                    add(pixels, {x = x, y = y})
                end
            end
        end
        s.pixels = pixels
    end
end

function _update60()
    local left = btn(0)
    local right = btn(1)
    local up = btn(2)
    local down = btn(3)
    local action1 = btn(4)

    if left then
        player.x = player.x - 1
    elseif right then
        player.x = player.x + 1
    elseif up then
        player.y = player.y - 1
    elseif down then
        player.y = player.y + 1
    end

end

splatter_frame = 0
function _draw()
    cls(0)
    for entity in all(entities) do draw_entity(entity) end
    local intersecting_pixels = intersect(entities[1], entities[2])
    for p in all(intersecting_pixels) do pset(p.x, p.y, 8) end

    -- splatter test
    splatter_frame = splatter_frame + 0.1
    draw_splatter(10, 5, angles.up, splatter_frame)
end
