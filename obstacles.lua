-->8
-- obstacles

function make_trampoline(x)
    return {
        x = x,
        y = ground_y - 7,
        w = 18,
        h = 6,
        sh = 10,
        bounce_multiplier = 1.25,
        boost_multiplier = 1,
        draw = function(self)
            palt(0, false)
            palt(12, true)
            sspr(38, 17, self.w + 6, self.sh, self.x - 3, self.y)
            -- rect(self.x,self.y,self.x+self.w,self.y+self.h,7)
            pal()
        end,
        update = function(self)
        end
    }
end
