-->8
-- cannon

function make_cannon()
    return {
        x = 13,
        y = 94,
        w = 62,
        h = 11,
        power = 0,
        timer = 0,
        shot_timer_cycle_time = 40,
        length = 37,
        angle = 0,
        draw = function(self)
            -- don't bother drawing if offscreen
            if player and player.x > 188 then
                return
            end
            spr_r(0, 6, self.x, self.y, 4.75, 1.25, 0, 6, self.angle, 12)
        end,
        draw_power_bar = function(self)
            local max_bar_w = self.shot_timer_cycle_time / 2
            local label_x = 8
            local bar_x = label_x + 6 * 4+1
            local bar_w = self.power
            local bar_h = 4
            local  y = 8
            print("power:", label_x, y, 7)
            rect(bar_x-1, y-1, bar_x + max_bar_w + 1, y + bar_h + 1, 0)

            rectfill(bar_x, y, bar_x + bar_w, y + bar_h, 8)
        end,
        update = function(self)
            if btn(3) then
                self.angle = self.angle - 0.005
            end
            if btn(2) then
                self.angle = self.angle + 0.005
            end
            -- limit cannon angle
            self.angle = mid(0, self.angle, 0.2)

            if btn(4) or btn(5) then
                game_state = "flying"
                local shot_power = self.power
                player = make_player(self.angle, self.x, self.y, self.length, shot_power)
            else
                self.timer = (self.timer + 1) % self.shot_timer_cycle_time
                self.power = self:calculate_current_power()
            end
        end,
        calculate_current_power = function(self)
            local max_power = self.shot_timer_cycle_time / 2
            local power_bar_rising = self.timer <= self.shot_timer_cycle_time / 2
            local power = self.timer % (self.shot_timer_cycle_time/2 + 1)
            if power_bar_rising then
                return power
            end
            return max_power - power
        end
    }
end