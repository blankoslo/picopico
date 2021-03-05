monster_sprite = {x = 0, y = 0, w = 8, h = 8}
sprites = {monster_sprite}
player = {x = 1, y = 1, color = 11}
entities = {{x = 1, y = 1, sprite = monster_sprite}, player}

function intersect_box(b1, b2)
    return not ((b1.x >= b2.x + b2.w) or (b1.x + b1.w <= b2.x) or
               (b1.y >= b2.y + b2.h) or (b1.y + b1.h <= b2.y))
end

function intersect_pixels(e1, e2)
    local pixels = {}
    local sp1 = (e1.sprite and e1.sprite.pixels) or {{x = e1.x, y = e1.y}}
    local sp2 = (e2.sprite and e2.sprite.pixels) or {{x = e2.x, y = e2.y}}
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

function _init()
    for s in all(sprites) do
        local pixels = {}
        for x = s.x, s.x + s.w - 1 do
            for y = s.y, s.y + s.h - 1 do
                if sget(x, y) ~= 0 then
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

function _draw()
    cls(0)
    for entity in all(entities) do draw_entity(entity) end
    local intersecting_pixels = intersect(entities[1], entities[2])
    for p in all(intersecting_pixels) do pset(p.x, p.y, 8) end
end
