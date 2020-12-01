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
        if random_number > 0.66 then
            make_trampoline(obstacle_x)
        elseif random_number > 0.33 then
            make_tnt(obstacle_x)
        elseif random_number > 0.16 then
            make_slime_block(obstacle_x)
        else
            make_swimming_pool(obstacle_x)
        end
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
                sfx(3)
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
                local sprite_y = 46
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
                        kitten:land()
                        self.contains_cat = true
                        local x = self.x + self.w / 2
                        local y = self.y - 2
                        local i
                        for i = 1, 20 do
                            make_particle(x, y)
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
            triggered = false,
            draw = function(self)
                if not self.triggered then
                    palt(0, false)
                    sspr(96, 0, self.sw, self.sh, self.x, self.y)
                    pal()
                end
            end,
            collide = function(self, kitten)
                if not self.triggered then
                    self.triggered = true
                    kitten.dy = -abs(kitten.dy) - self.vertical_explosion_force
                    kitten.dx = kitten.dx + self.horizontal_explosion_force
                    kitten.y = min(ground_y - kitten.h + self.h / 3, kitten.y)
                    make_explosion(self.x, self.y)
                end
            end
        }
    )
end

function make_explosion(x, y)
    sfx(1)
    shake = shake + 1

    local explo = emitter.create(x, y, 0, 30)
    ps_set_size(explo, 4, 0, 3, 0)
    ps_set_speed(explo, 0)
    ps_set_life(explo, 1)
    ps_set_colours(explo, {7, 6, 5})
    ps_set_area(explo, 30, 30)
    ps_set_burst(explo, true, 10)
    add(particle_emitters, explo)
    local spray = emitter.create(x, y, 0, 80)
    ps_set_size(spray, 0)
    ps_set_speed(spray, 20, 10, 20, 10)
    ps_set_colours(spray, {7, 6, 5})
    ps_set_life(spray, 0, 1.3)
    ps_set_burst(spray, true, 30)
    add(particle_emitters, spray)
    local anim = emitter.create(x, y, 0, 18)
    ps_set_speed(anim, 0)
    ps_set_life(anim, 1)
    ps_set_sprites(anim, {132, 135, 136, 137, 138, 139, 140, 140, 140, 141, 141, 141})
    ps_set_area(anim, 30, 30)
    ps_set_burst(anim, true, 6)
    add(particle_emitters, anim)
    for e in all(particle_emitters) do
        e.start_emit(e)
    end
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
                sfx(3)
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

-- these particles are used for the milk splash
function make_particle(x, y)
    make_object(
        "particle",
        x,
        y,
        1,
        1,
        1,
        1,
        {
            dx = rnd(2) - 1,
            dy = rnd(2) - 3,
            life = 15,
            orig_life = 15,
            speed = rnd(3) * 0.5,
            radius = rnd(6) + 2,
            gravity = 0.3,
            fade = 7,
            color = 7,
            draw = function(self)
                pal()
                palt()
                circfill(self.x, self.y, self.radius, self.color)
            end,
            update = function(self)
                self.x = self.x + self.dx
                self.y = self.y + self.dy

                self.dy = self.dy + self.gravity
                self.radius = self.radius * 0.9

                self.life = self.life - 1

                --set the color
                if type(self.fade) == "table" then
                    --assign color from fade
                    --this code works out how
                    --far through the lifespan
                    --the particle is and then
                    --selects the color from the
                    --table
                    self.col = self.fade[flr(#self.fade * (self.life / self.orig_life)) + 1]
                else
                    --just use a fixed color
                    self.color = self.fade
                end
            end,
            is_expired = function(self)
                return self.life < 0
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
