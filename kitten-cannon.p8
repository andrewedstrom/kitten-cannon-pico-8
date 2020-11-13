pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- kitten cannon
-- by andrew edstrom

-- todo
-- print angle
-- tnt
-- fly traps
-- score when you come to a stop
-- explosion
-- loop obstacles
-- randomly generate obstacles

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
        make_trampoline(384),
        make_trampoline(480),
        make_trampoline(550),
        make_trampoline(650),
        make_trampoline(704),
    }
end

function _update60()
    if player then
        player:update()
    end
    if game_state == "aiming" then
        cannon:update()
    end
    for obj in all(obstacles) do
        obj:update()
    end

    if player then
        infinitely_scroll()
    end
end

function _draw()
    cls()
    if game_state == "aiming" then
        map(0, 0, 0, 0, 128, 16)
        cannon:draw()
        for obj in all(obstacles) do
            obj:draw()
        end
    else
        camera_follow()
        map(0, 0, 0, 0, 128, 16)
        cannon:draw()
        player:draw()
        for obj in all(obstacles) do
            obj:draw()
        end
        camera(0, 0)
        print(flr(player.feet_traveled) .. "ft", 8, 16, 7)
    end
    cannon:draw_power_bar()
    -- print("fps:" .. stat(7), 8, 24, 7)
    -- print("cpu:" .. stat(1), 8, 32, 7)
end

function camera_follow()
    local cam_x = max(0, player.x - 60)
    camera(cam_x, 0)
end

function infinitely_scroll()
    local halfway_through_second_to_last_map_screen = 104
    if player.x >= halfway_through_second_to_last_map_screen * 8 then
        -- teleport to second map screen
        local how_far_over = player.x -(halfway_through_second_to_last_map_screen * 8)
        player.x = 24 * 8 + how_far_over
    end
end



function lines_overlapping(min1, max1, min2, max2)
	return max1 > min2 and max2 > min1
end

function rects_overlapping(left1, top1, right1, bottom1, left2, top2, right2, bottom2)
	return lines_overlapping(left1, right1, left2, right2) and lines_overlapping(top1, bottom1, top2, bottom2)
end

#include obstacles.lua
#include player.lua
#include cannon.lua
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
00000000fffffffffffffffffffffffffffffccc66660000000000006666cccccccccccccccccccccccbcccccccccccccccccccccccccccccccccccccccccccc
00000000ffdd6ffffffffffffffffffffffffcccd5c66666666666666c5dcccccccccccccccccccccccbcccccccccccccccccccccccccccccccccccccccccccc
00000000fd666ffffffffffffffffffffffcccccd5cccccccccccccccc5dcccccccccccc4444444444444444cccccccccccccccccccccccccccccccccccccccc
00000000fd666ffffffffffffffffffffffcccccdccccccccccccccccccdcccccccccccc4466444444d66444cccccccccccccccccccccccccccccccccccccccc
00000000d666fffffffffffffffffffffffcccccdccccccccccccccccccdcccccccccccc42d6744442dd6744cccccccccccccccccccccccccccccccccccccccc
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
