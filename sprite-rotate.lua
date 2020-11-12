-->8
-- sprite rotate

-- I did not write this, nor did I write the comments
-- source: https://github.com/hsandt/pico-boots/blob/master/src/engine/render/sprite.lua
--
-- Draw a rotated sprite:
--  located at tile (i ,j) in spritesheet, at (x, y) px on screen,
--  spanning on w tiles to the right, h tiles to the bottom
--  (like spr, w and h may be fractional to allow partial sprites, although not tested),
--  optionally flipped on X and Y with flags flip_x and flip_y,
--  offset by -(pivot_x, pivot_y) and rotated by angle around this pivot,
--  ignoring transparent_color.
-- Unlike spr() though, it takes sprite location coords i, j as first arguments
--  instead of sprite ID n, but conversion is trivial.
-- must be called with all arguments
function spr_r(i, j, x, y, w, h, pivot_x, pivot_y, angle, transparent_color)
    -- precompute pixel values from tile indices: sprite source top-left, sprite size
    local tile_size = 8

    local sx = tile_size * i
    local sy = tile_size * j
    local sw = tile_size * w
    local sh = tile_size * h

    -- precompute angle trigonometry
    local sinOfAngle = sin(angle)
    local cosOfAngle = cos(angle)

    -- in the operations below, we work "inside" pixels as much as possible (offset 0.5 from top-left corner)
    --  then floor coordinates (or let PICO-8 functions auto-floor) at the last moment for more symmetrical results
    -- if we work with integers directly, pivot used for rotation and flipping is
    --  inside a pixel not at the cross between 4 pixels (what PICO-8 spr flip uses),
    --  causing a slight offset
    -- typical example: flipping a square sprite of span (1, 1) i.e. size (8, 8) and pivot (4, 4)
    --  will preserve its bounding box; same for a 90-degrees rotation

    -- precompute "target disc": where we must draw pixels of the rotated sprite (relative to (x, y))
    -- the image of a rectangle rotated by any angle from 0 to 1 is a disc
    -- when rotating around its center, the disc has radius equal to rectangle half-diagonal
    -- when rotating around an excentered pivot, the disc has a bigger radius, equal to
    --  the distance between the pivot and the farthest corner of the sprite rectangle
    --  i.e. the magnitude of a vector of width: the biggest horizontal distance between pivot and rectangle left or right
    --                                    height: the biggest vertical distance between pivot and rectangle top or bottom
    -- (if pivot is a corner, it is the full diagonal length)
    -- we need to compute this disc radius so we can properly draw the rotated sprite wherever it will "land" on the screen
    -- (if we just draw on the rectangle area where the sprite originally is, we observe rectangle clipping)
    -- actually measure distance between pivot and edge pixel center, so pivot vs 0.5 (start) or sw - 0.5 (end)
    local max_dx = max(pivot_x, sw - pivot_x) - 0.5 -- actually (pivot_x - 0.5, sw - 0.5 - pivot_x) i.e. max horizontal distance from pivot to corner
    local max_dy = max(pivot_y, sh - pivot_y) - 0.5 -- actually (pivot_y - 0.5, sh - 0.5 - pivot_y) i.e. max vertical distance from pivot to corner
    local max_sqr_dist = max_dx * max_dx + max_dy * max_dy
    -- ceil to be sure we reach enough pixels while avoiding fractions
    -- subtract half for symmetrical operations, it's very important as it will affect
    --  the values of dx and dy during the whole iteration
    local max_dist_minus_half = ceil(sqrt(max_sqr_dist)) - 0.5

    -- backward rendering: cover the whole target disc,
    --  and determine which pixel of the source sprite should be represented
    -- it's not trivial to iterate over a disc (you'd need trigonometry)
    --  so instead, iterate over the target disc's bounding box
    -- we work with relative offsets
    for dx = -max_dist_minus_half, max_dist_minus_half do
        for dy = -max_dist_minus_half, max_dist_minus_half do
            -- optimization: we know that nothing should be drawn outside the target disc contained in the bounding box
            --  so only consider pixels inside the target disc
            -- the final source range check more below is the most important
            if dx * dx + dy * dy <= max_sqr_dist then
                -- compute pixel location on source sprite in spritesheet
                -- this basically a reverse rotation matrix to find which pixel
                --  on the original sprite should be represented
                local rotated_dx = cosOfAngle * dx + sinOfAngle * dy
                local rotated_dy = -sinOfAngle * dx + cosOfAngle * dy

                -- spare a few tokens by not flooring xx and yy
                --  we should semantically, but fortunately sget does auto-floor arguments
                local xx = pivot_x + rotated_dx
                local yy = pivot_y + rotated_dy

                -- make sure to never draw pixels from the spritesheet
                --  that are outside the source sprite
                -- simply check if the source pixel is located in the source sprite rectangle
                if xx >= 0 and xx < sw and yy >= 0 and yy < sh then
                    local c = sget(sx + xx, sy + yy)
                    -- ignore if transparent color
                    if c ~= transparent_color then
                        -- set target pixel color to source pixel color
                        -- spare a few tokens by not flooring dx and dy, as pset also auto-floors arguments
                        pset(x + dx, y + dy, c)
                    end
                end
            end
        end
    end
end
