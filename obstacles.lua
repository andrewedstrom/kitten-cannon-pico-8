-->8
-- obstacles

function make_trampoline(x)
    make_obstacle(
        x,
        ground_y - 9,
        20,
        6,
        26,
        12,
        {
            bounce_multiplier = 1.25,
            draw = function(self)
                palt(0, false)
                palt(12, true)
                sspr(37, 16, self.sw, self.sh, self.x - 4, self.y - 1)
                pal()
            end,
            collide = function(self, kitten)
                kitten.dy = -abs(kitten.dy * self.bounce_multiplier)
                kitten.y = min(ground_y - kitten.h + self.h / 3, kitten.y)
            end
        }
    )
end

function make_tnt(x)
    make_obstacle(
        x,
        ground_y - 14,
        15,
        15,
        15,
        15,
        {
            vertical_explosion_force = 13,
            horizontal_explosion_force = 1.75,
            draw = function(self)
                palt(0, false)
                -- palt(12, true)
                sspr(96, 0, self.sw, self.sh, self.x, self.y)
                pal()
            end,
            collide = function(self, kitten)
                kitten.dy = -abs(kitten.dy) - self.vertical_explosion_force
                kitten.dx = kitten.dx + self.horizontal_explosion_force
                kitten.y = min(ground_y - kitten.h + self.h / 3, kitten.y)
            end
        }
    )
end

function make_obstacle(x, y, w, h, sw, sh, props)
    local ob = {
        x = x,
        y = y,
        w = w,
        h = h,
        sh = sh,
        sw = sw,
        draw = function(self)
        end,
        collide = function(self, kitten)
        end
    }

    -- add aditional object properties
    for k, v in pairs(props) do
        ob[k] = v
    end

    add(obstacles, ob)
    return obj
end
