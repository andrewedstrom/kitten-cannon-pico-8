-->8
-- obstacles

function make_trampoline(x)
    return {
        x = x,
        y = ground_y - 9,
        w = 18,
        h = 6,
        sh = 12,
        sw = 26,
        bounce_multiplier = 1.25,
        boost_multiplier = 1,
        draw = function(self)
            palt(0, false)
            palt(12, true)
            sspr(37, 16, self.sw, self.sh, self.x - 4, self.y-1)
            -- rect(self.x,self.y,self.x+self.w,self.y+self.h,7)
            pal()
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
        bounce_multiplier = 3,
        boost_multiplier = 1.5,
        draw = function(self)
            palt(0, false)
            -- palt(12, true)
            sspr(96, 0, self.sw, self.sh, self.x, self.y)
            pal()
        end,
        update = function(self) end
    }
end
