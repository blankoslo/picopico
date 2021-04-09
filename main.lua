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
blood_sprites = {
    x = 16,
    y = 0,
    w = 8,
    h = 8,
    enabled = true,
    frame_percent = 0,
    frames = 8
}
shooting_sprites = {
    x = 16,
    y = 16,
    w = 8,
    h = 8,
    enabled = false,
    frame_percent = 0,
    frames = 5
}
bullet_hit = {x = 0, y = 0, did_hit = false}
particle_sprites = {blood_sprites, shooting_sprites}
monster = {x = 1, y = 30, type = "monster", sprite = monster_sprite}
player = {x = -3, y = 50, type = "player", sprite = player_sprite}
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

function draw_particle(sprite, x, y, angle, clear)
    if sprite.enabled then
        local f = flr(sprite.frame_percent) % sprite.frames
        if clear then rectfill(x, y, x + 8, y + 8, 0) end
        sspr(sprite.x + sprite.w * f, sprite.y, sprite.w, sprite.h, x, y)
        sprite.frame_percent = sprite.frame_percent + 0.5
        if f == sprite.frames - 1 then
            sprite.enabled = false
            sprite.frame_percent = 0
        end
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

function calculate_bullet_hit()
    local bullet_relative_pixels = {}
    local MAX_HEIGHT = player.y
    for y = 0, MAX_HEIGHT do add(bullet_relative_pixels, {x = 0, y = y}) end
    local bullet_entity = {
        x = player.x + 12, -- gun is 12 from
        y = 0,
        h = MAX_HEIGHT,
        w = 1,
        sprite = {h = MAX_HEIGHT, w = 1, pixels = bullet_relative_pixels}
    }
    local intersecting_pixels = intersect(entities[1], bullet_entity)
    local min_hit_y = 128
    local did_hit = false
    for p in all(intersecting_pixels) do
        did_hit = true
        if p.y < min_hit_y then min_hit_y = p.y end
    end
    return {did_hit = did_hit, x = player.x, y = min_hit_y}
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
    elseif action1 then
        shooting_sprites.enabled = true
        bullet_hit = calculate_bullet_hit()
        if bullet_hit.did_hit then blood_sprites.enabled = true end
    end

end

function _draw()
    cls(0)
    for entity in all(entities) do draw_entity(entity) end

    if shooting_sprites.enabled then sfx(0) end
    draw_particle(blood_sprites, bullet_hit.x + 9, bullet_hit.y - 8, angles.up)
    draw_particle(shooting_sprites, player.x + 8, player.y - 8, angles.up)
end
