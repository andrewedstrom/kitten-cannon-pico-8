-->8
-- kitten

function make_kitten(angle, cannon_x, cannon_y, cannon_length, power)
    local ca = cos(angle)
    local sa = sin(angle)
    local spawn_x = cannon_x + cannon_length * ca
    local spawn_y = cannon_y + cannon_length * sa - 20
    make_explosion(spawn_x, spawn_y)
    return {
        feet_traveled = 0,
        x = spawn_x,
        y = spawn_y,
        dx = power * ca,
        dy = power * sa,
        w = 27,
        h = 22,
        bounce = 0.65,
        on_ground = false,
        angle = angle,
        hide = false,
        last_y = cannon_y + cannon_length * sa - 20,
        update = function(self)
            self.last_y = self.y
            -- gravity
            self.dy = self.dy + gravity

            if hit_ground(self.x, self.y, self.w - 1, self.h) then
                self.dy = -abs(self.dy * self.bounce)
                if abs(self.dy) < 1.5 then
                    self.on_ground = true
                    game_state = "landed"
                    high_score = max(high_score, flr(player.feet_traveled))
                    max_coins_collected = max(max_coins_collected, coins_collected)
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

            foreach_object_of_kind(
                "obstacle",
                function(obj)
                    if
                        rects_overlapping(
                            obj.x,
                            obj.y,
                            obj.x + obj.w,
                            obj.y + obj.h,
                            hitbox.x,
                            hitbox.y,
                            hitbox.x + hitbox.w,
                            hitbox.y + hitbox.h
                        )
                     then
                        obj:collide(self)
                    end
                end
            )
        end,
        draw = function(self)
            if not self.hide then
                if self.y < 0 - self.h then
                    local x = self.x + 13
                    local distance_from_ground = ceil((ground_y - self.y) / one_foot_in_pixels)
                    print("\x8f", x, 0, 7) -- we use the top half of the diamond symbol as the pointy part of the height box
                    print_in_box(distance_from_ground .. "ft", x + 4, 6, 7, 0)
                else
                    palt(0, false)
                    palt(15, true)
                    sspr(8, 0, self.w + 1, self.h + 1, self.x, self.y)
                    pal()
                end
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
