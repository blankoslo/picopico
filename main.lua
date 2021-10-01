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
monster_sprite = {x = 0, y = 16, r = 270, w = 16, h = 16}
monster_dead_sprite = {x = 64, y = 8, r = 270, w = 16, h = 24}
player_sprite = {x = 0, y = 0, r = 90, w = 16, h = 16}
sprites = {monster_sprite, player_sprite}
blood_sprites = {
    x = 16,
    y = 0,
    w = 8,
    h = 8,
    enabled = false,
    frame_percent = 0,
    frames = 8
}
shooting_sprites = {
    x = 16,
    y = 8,
    w = 8,
    h = 8,
    enabled = false,
    frame_percent = 0,
    frames = 5
}
bullet_hit = {x = 0, y = 0, r = 0, did_hit = false}
particle_sprites = {blood_sprites, shooting_sprites}
monsters = {
    {
        x = 59,
        y = 30,
        r = 270,
        hp = 20,
        type = "monster",
        sprite = monster_sprite,
        target = {x = 0, y = 0, timeout = 0}
    }, {
        x = 0,
        y = 90,
        r = 0,
        hp = 20,
        type = "monster",
        sprite = monster_sprite,
        target = {x = 0, y = 0, timeout = 0}
    }
}
player = {x = 58, y = 58, r = 90, type = "player", sprite = player_sprite}
entities = {player}
for monster in all(monsters) do add(entities, monster) end
angles = {right = 270, left = 90, down = 180, up = 0}

function print_coords(x, y) print("x:" .. x .. ";y:" .. y) end

function intersect_box(b1, b2)
    return not ((flr(b1.x) >= flr(b2.x) + b2.w) or
               (flr(b1.x) + b1.w <= flr(b2.x)) or
               (flr(b1.y) >= flr(b2.y) + b2.h) or
               (flr(b1.y) + b1.h <= flr(b2.y)))
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
            if (flr(x1) == flr(x2) and flr(y1) == flr(y2)) then
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
        spr_r(entity.sprite.x, entity.sprite.y, entity.x, entity.y,
              entity.r - entity.sprite.r, entity.sprite.w / 8,
              entity.sprite.h / 8)
    else
        pset(entity.x, entity.y, entity.color)
    end
end

function draw_particle(sprite, x, y, angle, clear)
    if sprite.enabled then
        local f = flr(sprite.frame_percent) % sprite.frames
        if clear then rectfill(x, y, x + 8, y + 8, 0) end
        spr_r(sprite.x + sprite.w * f, sprite.y, x, y, angle, sprite.w / 8,
              sprite.h / 8)
        sprite.frame_percent = sprite.frame_percent + 0.5
        if f == sprite.frames - 1 then
            sprite.enabled = false
            sprite.frame_percent = 0
        end
    end
end

function draw_hit_scan_debug_line(x, y, r)
    dx = -cos(r / 360)
    dy = sin(r / 360)

    while true do
        x = x + dx
        y = y + dy
        pset(flr(x), flr(y), 8)
        if x < 0 or x > 128 or y < 0 or y > 128 then break end
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

-- function calculate_bullet_hit_2()
--     local bullet_relative_pixels = {}
--     local MAX_HEIGHT = player.y
--     for y = 0, MAX_HEIGHT do add(bullet_relative_pixels, {x = 0, y = y}) end
--     local bullet_entity = {
--         x = player.x + 12, -- gun is 12 from
--         y = 0,
--         h = MAX_HEIGHT,
--         w = 1,
--         sprite = {h = MAX_HEIGHT, w = 1, pixels = bullet_relative_pixels}
--     }
--     local intersecting_pixels = intersect(entities[1], bullet_entity)
--     local min_hit_y = 128
--     local did_hit = false
--     for p in all(intersecting_pixels) do
--         did_hit = true
--         if p.y < min_hit_y then min_hit_y = p.y end
--     end
--     return {did_hit = did_hit, x = player.x, y = min_hit_y}
-- end

function calculate_bullet_hit()
    local player_entity = player

    local gun_offset_x = 8
    local gun_offset_y = -4
    local rotated_init_coords = offset_rotation(gun_offset_x, gun_offset_y,
                                                player_entity)
    local r = player_entity.r
    local x = rotated_init_coords.x
    local y = rotated_init_coords.y

    local dx = -cos(r / 360)
    local dy = sin(r / 360)

    while true do
        x = x + dx
        y = y + dy
        for entity in all(entities) do
            if entity.type == "monster" then
                local monster = entity
                local intersecting_pixels =
                    intersect(monster, {
                        x = flr(x),
                        y = flr(y),
                        h = 1,
                        w = 1,
                        r = 0,
                        sprite = {
                            h = 1,
                            w = 1,
                            pixels = {{x = 0, y = 0, r = 0}}
                        }
                    })
                if count(intersecting_pixels) > 0 then
                    local intersected_pixel = intersecting_pixels[1]
                    monster.hp = monster.hp - 1
                    if monster.hp <= 0 then
                        del(entities, entity)
                        add(entities, {
                            x = entity.x,
                            y = entity.y,
                            r = entity.r,
                            type = "monster_dead",
                            sprite = monster_dead_sprite
                        })
                    end
                    return {
                        did_hit = true,
                        x = intersected_pixel.x,
                        y = intersected_pixel.y,
                        r = r
                    }
                end
            end
        end
        if x < 0 or x > 128 or y < 0 or y > 128 then break end
    end
    return {did_hit = false, x = 0, y = 0}

end

function _update60()
    local left = btn(0)
    local right = btn(1)
    local up = btn(2)
    local down = btn(3)
    local action1 = btn(4)
    local crab_mode = btn(5)

    if left and not crab_mode then player.r = player.r - 10 end
    if right and not crab_mode then player.r = player.r + 10 end
    if left and crab_mode then -- vi elsker crab mode
        player.x = player.x - 1
    end
    if right and crab_mode then player.x = player.x + 1 end
    if up then player.y = player.y - 1 end
    if down then player.y = player.y + 1 end
    if action1 then
        sfx(0)
        bullet_hit = calculate_bullet_hit()
        if bullet_hit.did_hit then
            blood_sprites.enabled = true
            sfx(13)
        end
    end

    for entity in all(entities) do
        if entity.type == "monster" then
            monster = entity
            monster.target.timeout = monster.target.timeout - 1
            if monster.target.timeout <= 0 then
                monster.target.timeout = 30
                monster.target.x = player.x + flr(rnd() * 10) - 5
                monster.target.y = player.y + flr(rnd() * 10) - 5
            end
            local target_x = monster.target.x
            local target_y = monster.target.y
            local angle = atan2(target_y - monster.y, target_x - monster.x)
            monster.r = angle * 360 + monster.sprite.r
            monster.x = cos(monster.r / 360 + 0.5) * 0.1 + monster.x
            monster.y = -sin(monster.r / 360 + 0.5) * 0.1 + monster.y
        end
    end
end

function offset_rotation(offset_x, offset_y, entity)
    -- RTFMØ LOlzzz
    local x = entity.x - offset_x * cos(entity.r / 360) + offset_y *
                  sin(entity.r / 360) + entity.sprite.w / 2
    local y = entity.y + offset_y * cos(entity.r / 360) + offset_x *
                  sin(entity.r / 360) + entity.sprite.h / 2
    return {x = x, y = y}
end

function _draw()
    cls(0)
    for entity in all(entities) do
        draw_entity(entity)
        if entity.type == "player" then
            gun_offset_x = 8
            gun_offset_y = -4
            local rotated_init_coords = offset_rotation(gun_offset_x,
                                                        gun_offset_y, entity)
            draw_hit_scan_debug_line(rotated_init_coords.x,
                                     rotated_init_coords.y, entity.r)
        elseif entity.type == "monster" then
            print(entity.hp)
        elseif entity.type == "monster_dead" then
            print(entity.x)
        end
    end
    if bullet_hit.did_hit then print("MOTA") end
    draw_particle(blood_sprites, bullet_hit.x - 7, bullet_hit.y - 8,
                  bullet_hit.r)
    draw_particle(shooting_sprites, player.x + 8, player.y - 8, angles.up)
end

-- not our shit
-- addendum dario: delevis our shit
function spr_r(sx, sy, x, y, a, w, h)
    sw = (w or 1) * 8
    sh = (h or 1) * 8
    x0 = flr(0.5 * sw)
    y0 = flr(0.5 * sh)
    a = (a or 0) / 360
    sa = sin(a)
    ca = cos(a)
    for ix = 0, sw - 1 do
        for iy = 0, sh - 1 do
            dx = ix - x0
            dy = iy - y0
            xx = flr(dx * ca - dy * sa + x0)
            yy = flr(dx * sa + dy * ca + y0)
            if (xx >= 0 and xx < sw and yy >= 0 and yy <= sh) then
                color = sget(sx + xx, sy + yy)
                if color ~= 0 then pset(x + ix, y + iy, color) end
            end
        end
    end
end
