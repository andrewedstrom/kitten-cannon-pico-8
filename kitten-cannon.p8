pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- kitten cannon
-- by andrew edstrom

-- todo
-- kitten comes out of barrel
-- barrel angle determines initial kitten angle
-- hit x at right time to determine initial velocity
-- trampolines
-- tnt
-- fly traps
-- score when you come to a stop
-- explosion

-- obstacle ideas:
-- yarn
-- ball pit
-- shiny objects?
-- swimming pool full of milk
-- just a gap in the map a la mario

local player
local gravity = 0.4
local camera_pos
local feet_traveled
local cannon
local game_state --  "aiming", "flying", "landed"
local obstacles
local ground_y = 104

function _init()
    cannon = make_cannon()
    game_state = "aiming"
    obstacles = {
        make_trampoline(74),
        make_trampoline(110),
        make_trampoline(210),
        make_trampoline(310),
        make_trampoline(410),
        make_trampoline(510),
        make_trampoline(610),
    }
end

function _update60()
    if game_state ~= "aiming" then
        player:update()
    end
    cannon:update()
    for obj in all(obstacles) do
        obj:update()
    end
end

function _draw()
    cls()

    if game_state ~= "aiming" then
        camera_follow()
    end

    map(0, 0, 0, 0, 128, 16)
    cannon:draw()
    if game_state ~= "aiming" then
        player:draw()
    end

    for obj in all(obstacles) do
        obj:draw()
    end

    -- hud
    camera(0,0)
    if game_state ~= "aiming" then
        print(flr(player.feet_traveled) .. "ft", 8, 8, 7)
    end
end

function camera_follow()
    local cam_x=max(0,player.x-60)
    camera(cam_x,0)
end

function make_trampoline(x)
    return {
        x=x,
        y=ground_y-7,
        w=22,
        h=6,
        sh=10,
        bounce_multiplier=1.25,
        boost_multiplier=1.05,
        draw=function(self)
            palt(0, false)
            palt(12, true)
            sspr(40,17,self.w,self.sh,self.x,self.y)
            -- rect(self.x,self.y,self.x+self.w,self.y+self.h,7)
            pal()
        end,
        update=function(self)
        end
    }
end

function make_cannon()
    return {
        x=13,
        y=94,
        w=62,
        h=11,
        length=37,
        angle=0,
        draw=function(self)
            -- todo don't draw if offscreen
            spr_r(0, 6, self.x, self.y, 4.75, 1.25, false, false, 0, 6, self.angle, 12)
        end,
        update=function(self)
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
                local shot_power=13
                player=make_player(self.angle, self.x, self.y, self.length, shot_power)
            end
        end
    }
end

function make_player(angle, cannon_x, cannon_y, cannon_length, power)
    -- precompute trig
    local ca=cos(angle)
    local sa=sin(angle)

    return {
        feet_traveled=0,
        x=cannon_x+cannon_length*ca,
        y=cannon_y+cannon_length*sa-20,
        dx=power*ca,
        dy=power*sa,
        w=27,
        h=22,
        bounce=0.65,
        on_ground=false,
        angle=angle,
        update=function(self)
            -- gravity
            self.dy = self.dy + gravity

            if hit_ground(self.x, self.y, self.w-1, self.h) then
                self.dy = self.dy * -self.bounce
                if abs(self.dy) < 1.5 then
                    self.on_ground=true
                    game_state = "landed"
                end

                self.dx = self.dx*0.7
            end

            -- check for collisions
            local hitbox = self:hitbox()
            for obstacle in all(obstacles) do
                if rects_overlapping(obstacle.x, obstacle.y, obstacle.x + obstacle.w, obstacle.y + obstacle.h, hitbox.x, hitbox.y, hitbox.x + hitbox.w, hitbox.y + hitbox.h) then
                    self.dy = -abs(self.dy*obstacle.bounce_multiplier)
                    self.dx = self.dx*obstacle.boost_multiplier
                end
            end

            -- update x and y
            if not self.on_ground then
                self.y = self.y + self.dy
                self.x = self.x + self.dx
                self.feet_traveled += self.dx / 8
            end

            -- kitten cannot go below ground
            self.y = min(ground_y-self.h, self.y)

            -- infinite scrolling
            local halfway_through_second_to_last_map_screen = 104
            if self.x >= halfway_through_second_to_last_map_screen*8 then
                -- teleport to second map screen
                local how_far_over = self.x-(halfway_through_second_to_last_map_screen*8)
                self.x = 24 * 8 + how_far_over
            end
        end,
        draw=function(self)
            palt(0, false)
            palt(15, true)
            sspr(8, 0, self.w+1, self.h+1, self.x, self.y)
            local hitbox = self:hitbox()
            -- rect(hitbox.x,hitbox.y,hitbox.x+hitbox.w,hitbox.y+hitbox.h,9)
            -- spr_r(1, 0, self.x, self.y, self.w / 8, self.h/8, false, false, 0, self.h/2, self.angle, 15)
            pal()
        end,
        hitbox=function(self)
            return {
                x=self.x+4,
                y=self.y+3,
                w=self.w-7,
                h=self.h-3
            }
        end
    }
end

--todo just move to player
function hit_ground(x,y,w,h)
    local i

    for i=x, x+w do
        local top_edge_cell = mget(i/8, y/8)
        local bottom_edge_cell = mget(i/8, (y+h)/8)
        if fget(top_edge_cell, 1) or fget(bottom_edge_cell, 1) then
            return true
        end
    end

    for i=y, y+h do
        local left_edge_cell = mget(x/8, i/8)
        local right_edge_cell = mget((x+w)/8, i/8)
        if fget(left_edge_cell, 1) or fget(right_edge_cell, 1) then
            return true
        end
    end

    return false
end

function lines_overlapping(min1,max1,min2,max2)
	return max1>min2 and max2>min1
end

function rects_overlapping(left1,top1,right1,bottom1,left2,top2,right2,bottom2)
	return lines_overlapping(left1,right1,left2,right2) and lines_overlapping(top1,bottom1,top2,bottom2)
end

#include sprite-rotate.lua

__gfx__
00000000ffdd6fffffffffffffffffffffffffffccccccccccccccccccccccccccccccccbbbbbbbbcccccccccccccccccccccccccccccccccccccccccccccccc
00000000fd666fffffffffffffffffffffffffffcccbcccccccccccccccccccccccccccc33333333cccccccccccccccccccccccccccccccccccccccccccccccc
00700700fd666fffffffffffffffffffffffffffcccbcccccccccc3bcbcccccccccccccc33333333cccccccccccccccccccccccccccccccccccccccccccccccc
00077000d666ffffffffffffffffffffffffffffcc3b3cb3ccb3cb3bcb3cccbccccbcc3c33333333cccccccccccccccccccccccccccccccccccccccccccccccc
00077000d6ffffffffffffffdfffffdfffffffffbc3b3c3bc3b3cbbb3b3cccb3cbccbc3b33323322cccccccccccccccccccccccccccccccccccccccccccccccc
00700700d6fffffffffffffd5ddffd5dffffffffb33b3b3bbbb3bbbbbb3cccb3cbccb33b33223222cccccccccccccccccccccccccccccccccccccccccccccccc
00000000d6fffffffffffffd5666666dffffffffb3bb3b3bbbbbbbbbbbbcc3bbbbb3b33b32422442cccccccccccccccccccccccccccccccccccccccccccccccc
00000000d6ffffffffffffd666666666ffffffffbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb24444442cccccccccccccccccccccccccccccccccccccccccccccccc
00000000d666ffffffff000666066606600fffffccccccccccccccccccccccccbbbbbbbb444444444444444444444444cccccccccccccccccccccccccccccccc
00000000fd66ffffffffffd6660666066fffffffccccccccccccccccccccccccbbbbbbbb444444444444444442464424cccccccccccccccccccccccccccccccc
00000000fd66ffffffff000666660666600fffffcbccccccccccccccccccccccbbbbbbbb444444444424424444666d44cccccccccccccccccccccccccccccccc
00000000fd666fffffffffd66660e0666fffffffcb3cccbccccbcc3cccccccccbbbbbbbb4444444442442444444d66d4cccccccccccccccccccccccccccccccc
00000000ffdd66666666666d666666666fffffff3b3cccb3cbccbc3bccccccccbbbbbbbb44444444444244444424d644cccccccccccccccccccccccccccccccc
00000000ffffd66666666666d6666666ffffffffbb3cccb3cbccb33bccccccccbbbbbbbb444444444424444444444444cccccccccccccccccccccccccccccccc
00000000fffffd66666666666666666fffffffffbbbcc3bbbbb3b33bccccccccbbbbbbbb444444444444444444444424cccccccccccccccccccccccccccccccc
00000000fffffd66666666666666766fffffffffbbbbbbbbbbbbbbbbccccccccbbbbbbbb444444444444444444444444cccccccccccccccccccccccccccccccc
00000000fffffd66666666666667776ffffffcccccccccccccccccccccccccccccccccccccccccccbb0bcccccccccccccccccccccccccccccccccccccccccccc
00000000ffffd666666666666777775ffffffcccccc66666666666666ccccccccccccccccccccccccb3bcccccccccccccccccccccccccccccccccccccccccccc
00000000ffffd66666666666677775fffffffccc66660000000000006666cccccccccccccccccccccc3bcccccccccccccccccccccccccccccccccccccccccccc
00000000ffffd66dddddddd6655556fffffffc666000000000000000000666cccccccccccccccccccccbcbbccccccccccccccccccccccccccccccccccccccccc
00000000ffffd6f55ffffffd6fffd6fffffffc666000000000000000000666cccccccccccccccccccccb3bcccccccccccccccccccccccccccccccccccccccccc
00000000ffffdff5ffffffff6fffdffffffffc666000000000000000000666cccccccccccccccccccccb3ccccccccccccccccccccccccccccccccccccccccccc
00000000fffffffffffffffffffffffffffffcc5666600000000000066665ccccccccccccccccccccccbcccccccccccccccccccccccccccccccccccccccccccc
00000000ffdd6ffffffffffffffffffffffffcc5ccd66666666666666dcc5ccccccccccccccccccccccbcccccccccccccccccccccccccccccccccccccccccccc
00000000fd666ffffffffffffffffffffffcccccccdccccccccccccccdcccccccccccccc4444444444444444cccccccccccccccccccccccccccccccccccccccc
00000000fd666ffffffffffffffffffffffcccccccdccccccccccccccdcccccccccccccc4466444444d66444cccccccccccccccccccccccccccccccccccccccc
00000000d666fffffffffffffffffffffffcccccccdccccccccccccccdcccccccccccccc42d6744442dd6744cccccccccccccccccccccccccccccccccccccccc
00000000d6ffffffffffffffdfffffdffffccccccccccccccccccccccccccccccccccccc22dd664422dd6644cccccccccccccccccccccccccccccccccccccccc
00000000d6fffffffffffffd5ddffd5dfffccccccccccccccccccccccccccccccccccccc22ddd66422dd6644cccccccccccccccccccccccccccccccccccccccc
00000000d6fffffffffffffd5666666dfffccccccccccccccccccccccccccccccccccccc22dddd6422dddd44cccccccccccccccccccccccccccccccccccccccc
00000000d6ffffffffffffd666666666fffccccccccccccccccccccccccccccccccccccc2222224442222244cccccccccccccccccccccccccccccccccccccccc
00000000d666ffffffff000666066606600ccccccccccccccccccccccccccccccccccccc4444444444444444cccccccccccccccccccccccccccccccccccccccc
00000000fd66ffffffffffd6660666066ffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000fd66ffffffff000666660666600ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000fd666fffffffffd66660e0666ffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000ffdd66666666666d666666666ffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000ffffd66666666666d6666666fffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000fffffd66666666666666666ffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000fffffd66666666666666766ffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000fffffd66666666666667776ffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000ffffd666666666666777775ffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000ffffd66666666666677775fffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000ffffd66dddddddd6655556fffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000ffffd6f55ffffffd6fffd6fffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
00000000ffffdff5ffffffff6fffdffffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0000000ffffffffffffffffffffffffffffccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
0000000fffffffffffffffffffffcccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
55555555555555555550cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
dddddddddddddddddddd05555555555555550ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
666666666666666666660dddddddddddddddd0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
66666666666666666666066666666666666660cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
66666666666666666666066666666666666660cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
66666666666666666666066666666666666660cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
66666666666666666666066666666666666660cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
666666666666666666660dddddddddddddddd0cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
dddddddddddddddddddd05555555555555550ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
55555555555555555550cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
__gff__
0000000000000000000200000000000000000000000000000002020200000000000000000000000000020000000000000000000000000000000202000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
1717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717171717
0909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909090909
1a1b191919193a1919391919191a19191a19191a19193a1919391919191a19191a3919191a193a1919391919191a19191a1b191919193a1919391919191a1a1b191919193a1919391919191a1b1919191a1b191919193a1919391919191a19191a19191a19193a1919391919191a19191a3919191a193a1919391919191a1919
19193a191a19191919191a191939191a19193a191a19191919191a191939191919193a191a19191919191a191939191919193a191a19191919191a19193919193a191a19191919191a191919193a191a19193a191a19191919191a191939191a19193a191a19191919191a191939191919193a191a19191919191a1919391919
