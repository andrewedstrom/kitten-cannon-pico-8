-->8
-- obstacles

function make_trampoline(x)
    return {
        x = x,
        y = ground_y - 9,
        w = 20,
        h = 6,
        sh = 12,
        sw = 26,
        bounce_multiplier = 1.25,
        boost_multiplier = 1,
        draw = function(self)
            palt(0, false)
            palt(12, true)
            sspr(37, 16, self.sw, self.sh, self.x - 4, self.y-1)
            pal()
        end,
        collide = function(self, kitten)
            kitten.dy = -abs(kitten.dy * self.bounce_multiplier)
            kitten.dx = kitten.dx * self.boost_multiplier

            kitten.y = min(ground_y - kitten.h + self.h / 2, kitten.y)
        end,
        update = function(self) end
    }
end

function make_tnt(x)
    return {
        x = x,
        y = ground_y - 14,
        w = 15,
        h = 15,
        sh = 15,
        sw = 15,
        -- todo should tnt cause bounce? Or should it apply a consistent amount of force
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
        end,
        update = function(self) end
    }
end
