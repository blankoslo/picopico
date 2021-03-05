bullet = {name = "bullet", x = 0, y = 0, color = 8}
entities = {
    {name = "monster", x = 1, y = 1, sprite = {x = 0, y = 0, w = 8, h = 8}},
    bullet
}

function intersect_box(b1, b2)
    return not ((b1.x >= b2.x + b2.w) or (b1.x + b1.w <= b2.x) or
               (b1.y >= b2.y + b2.h) or (b1.y + b1.h <= b2.y))
end

function intersect_pixels(e1, e2) return true end

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
    return false
end

function draw_entity(entity)
    if (entity.sprite) then
        sspr(entity.sprite.x, entity.sprite.y, entity.sprite.w, entity.sprite.h,
             entity.x, entity.y)
    else
        pset(entity.x, entity.y, entity.color)
    end
end

function _init() end

function _update60()
    local left = btn(0)
    local right = btn(1)
    local up = btn(2)
    local down = btn(3)

    if left then
        bullet.x = bullet.x - 1
    elseif right then
        bullet.x = bullet.x + 1
    elseif up then
        bullet.y = bullet.y - 1
    elseif down then
        bullet.y = bullet.y + 1
    end
end

function _draw()
    cls(0)
    for entity in all(entities) do draw_entity(entity) end

    if intersect(entities[1], entities[2]) then
        print("yeah yeah yeah", 20, 20)
    else
        print("non non non!", 20, 20)
    end
end
