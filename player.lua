-->8
-- player

function make_player(angle, cannon_x, cannon_y, cannon_length, power)
    local ca = cos(angle)
    local sa = sin(angle)

    return {
        feet_traveled = 0,
        x = cannon_x + cannon_length * ca,
        y = cannon_y + cannon_length * sa - 20,
        dx = power * ca,
        dy = power * sa,
        w = 27,
        h = 22,
        bounce = 0.65,
        on_ground = false,
        angle = angle,
        update = function(self)
            -- gravity
            self.dy = self.dy + gravity

            if hit_ground(self.x, self.y, self.w - 1, self.h) then
                self.dy = -abs(self.dy * self.bounce)
                if abs(self.dy) < 1.5 then
                    self.on_ground = true
                    game_state = "landed"
                end

                self.dx = self.dx * 0.7
            end

            if not self.on_ground then
                self.y = self.y + self.dy
                self.x = self.x + self.dx
                self.feet_traveled = self.feet_traveled + self.dx / one_foot_in_pixels
            end

            -- kitten cannot go below ground
            self.y = min(ground_y - self.h, self.y)

            -- check for collisions
            local hitbox = self:hitbox()
            for obstacle in all(obstacles) do
                if rects_overlapping(obstacle.x, obstacle.y,
                                     obstacle.x + obstacle.w,
                                     obstacle.y + obstacle.h, hitbox.x,
                                     hitbox.y, hitbox.x + hitbox.w,
                                     hitbox.y + hitbox.h) then
                    self.dy = -abs(self.dy * obstacle.bounce_multiplier)
                    self.dx = self.dx * obstacle.boost_multiplier
                end
            end
        end,
        draw = function(self)
            if self.y < 0 - self.h then
                local x = self.x + 13
                local distance_from_ground =
                    ceil((ground_y - self.y) / one_foot_in_pixels)
                print("\x8f", x, 0, 7) -- we use the top half of the diamond symbol as the pointy part of the height box
                print_in_box(distance_from_ground .. "ft", x + 4, 6, 7, 0)
            else
                palt(0, false)
                palt(15, true)
                sspr(8, 0, self.w + 1, self.h + 1, self.x, self.y)
                pal()
            end
        end,
        hitbox = function(self)
            return {
                x = self.x + 4,
                y = self.y + 3,
                w = self.w - 7,
                h = self.h - 3
            }
        end
    }
end

function hit_ground(x, y, w, h)
    local i
    for i = x, x + w do
        local top_edge_cell = mget(i / 8, y / 8)
        local bottom_edge_cell = mget(i / 8, (y + h) / 8)
        if fget(top_edge_cell, 1) or fget(bottom_edge_cell, 1) then
            return true
        end
    end

    for i = y, y + h do
        local left_edge_cell = mget(x / 8, i / 8)
        local right_edge_cell = mget((x + w) / 8, i / 8)
        if fget(left_edge_cell, 1) or fget(right_edge_cell, 1) then
            return true
        end
    end

    return false
end
