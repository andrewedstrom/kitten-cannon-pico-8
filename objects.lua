-->8
-- objects

function new_set_of_objects()
    objects = {}
    local min_x = 384
    local max_x = 704

    local x
    for x = min_x, max_x, 100 do
        -- don't want them evenly spaced
        local offset = flr(rnd(30))
        local random_number = rnd()
        local obstacle_x = x + offset
        -- if random_number > 0.66 then
            -- make_trampoline(obstacle_x)
        -- elseif random_number > 0.33 then
            -- make_tnt(obstacle_x)
        -- elseif random_number > 0.16 then
            -- make_slime_block(obstacle_x)
        -- else
            make_swimming_pool(obstacle_x)
        -- end
    end

    for x = 1, 5 do
        local coin_x = flr(rnd(max_x - min_x) + min_x)
        local coin_y = flr(rnd(ground_y - 40)) + 15
        make_coin(coin_x, coin_y)
    end
end

function make_trampoline(x)
    make_object(
        "obstacle",
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

function make_swimming_pool(x)
    make_object(
        "obstacle",
        x,
        ground_y - 10,
        26,
        6,
        26,
        17,
        {
            contains_cat = false,
            bounce_multiplier = 1.25,
            draw = function(self)
                palt(0, false)
                palt(12, true)
                local sprite_x = 96
                local sprite_y = 48
                if self.contains_cat then
                    sprite_x = 0
                    sprite_y = 64
                end
                sspr(sprite_x, sprite_y, self.sw, self.sh, self.x, self.y - 2)
                pal()
            end,
            collide = function(self, kitten)
                if not self.contains_cat then
                    kitten.dy = 0
                    kitten.dx = 0
                    if kitten.last_y < ground_y - kitten.h - 2 then
                        kitten.hide = true
                        self.contains_cat = true
                        local x = self.x + self.w / 2
                        local y = self.y - 2
                        local i
                        for i = -2, 2, 0.2 do
                            make_particle(x, y, i)
                        end
                    end
                end
            end
        }
    )
end

function make_tnt(x)
    make_object(
        "obstacle",
        x,
        ground_y - 14,
        16,
        16,
        16,
        16,
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

function make_slime_block(x)
    make_object(
        "obstacle",
        x,
        ground_y - 14,
        16,
        16,
        16,
        16,
        {
            bounce_multiplier = 1.55,
            draw = function(self)
                palt(0, false)
                sspr(96, 16, self.sw, self.sh, self.x, self.y)
                pal()
            end,
            collide = function(self, kitten)
                kitten.dy = -abs(kitten.dy * self.bounce_multiplier)
                kitten.y = min(ground_y - kitten.h + self.h / 3, kitten.y)
            end
        }
    )
end

function make_coin(x, y)
    make_object(
        "obstacle",
        x,
        y,
        6,
        6,
        6,
        6,
        {
            collected = false,
            draw = function(self)
                if not self.collected then
                    palt(12, true)
                    spr(69, self.x, self.y)
                    pal()
                end
            end,
            collide = function(self, kitten)
                if not self.collected then
                    self.collected = true
                    coins_collected = coins_collected + 1
                    sfx(0)
                end
            end
        }
    )
end

function make_particle(x, y, x_speed)
    make_object(
        "particle",
        x,
        y,
        1,
        1,
        1,
        1,
        {
            c = y,
            x_speed = x_speed,
            y_speed = rnd(4) * 0.1,
            lifetime = 0,
            speed = rnd(3) * 0.5,
            draw = function(self)
                pset(self.x, self.y, 7)
            end,
            update = function(self)
                if self.x_speed == 0 then
                    self.y = self.y - 2.5
                else
                    self.x = self.x + self.x_speed * self.speed
                    self.y = self.c - (self.lifetime * self.lifetime) * self.y_speed
                end

                self.lifetime = self.lifetime + 1
            end,
            is_expired = function(self)
                return self.lifetime >= 10
            end
        }
    )
end

function make_object(kind, x, y, w, h, sw, sh, props)
    local ob = {
        kind = kind,
        x = x,
        y = y,
        w = w,
        h = h,
        sh = sh,
        sw = sw,
        draw = function(self)
        end,
        update = function(self)
        end,
        collide = function(self, kitten)
        end,
        is_expired = function(self)
            return false
        end
    }

    -- add aditional object properties
    for k, v in pairs(props) do
        ob[k] = v
    end

    add(objects, ob)
    return obj
end

function foreach_object_of_kind(kind, callback)
    local obj
    for obj in all(objects) do
        if obj.kind == kind then
            callback(obj)
        end
    end
end
