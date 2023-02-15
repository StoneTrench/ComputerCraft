local function luaGL_FUNC()
    require(F.PATHS.DIR.packages .. "amath.amath")

    return {
        createRenderer = function(wind)
            local mainBuffer = luaGL.createRenderBuffer(wind.getSize())

            local e = {}

            e = {

            }

            local map = {
                "ABCD",
                "EFGH",
                "IJKL",
                "MNOP"
            }

            mainBuffer.drawTriangle({ 8, 8 }, { 1, 1 }, { 1, 8 }, function(u, v)
                local _u, _v = math.floor(u * 4) + 1, math.floor(v * 4) + 1

                return map[_u]:sub(_v, _v), "black", "white"
            end)
            mainBuffer.drawBuffer(wind, 8, 8)

            read()

            return e
        end,
        createRenderBuffer = function(width, height)
            local buffer = {}

            for x = 1, width, 1 do
                buffer[x] = {}
                for y = 1, height, 1 do
                    buffer[x][y] = { " ", "black", "white" }
                end
            end

            local function SetPixel(x, y, char, bkg, fgr)
                buffer[x][y] = { char, bkg, fgr };
            end

            return {
                drawTriangle = function(p1, p2, p3, uvFunc)
                    local v2_a = {
                        math.min(p1[1], p3[1]),
                        math.min(p1[2], p3[2])
                    }
                    local v2_c = {
                        math.max(p1[1], p3[1]),
                        math.max(p1[2], p3[2])
                    }
                    local v2_b = p2


                    -- calculate vectors for two sides of the triangle
                    local v1 = AMATH.VecXU.Sub(v2_b, v2_a)
                    local v2 = AMATH.VecXU.Sub(v2_c, v2_a)

                    -- calculate the normal vector of the triangle
                    local normal = { -v1[2], v1[1] }

                    if AMATH.VecXU.Length(normal) == 0 then
                        error("Triangle is degenerate.")
                    end

                    -- calculate the dot products of the normal vector with the two vectors
                    local dot1 = AMATH.VecXU.Dot(normal, v1)
                    local dot2 = AMATH.VecXU.Dot(normal, v2)

                    -- calculate the barycentric coordinates of each pixel within the triangle
                    for x = math.ceil(math.min(v2_a[1], v2_b[1], v2_c[1])), math.floor(math.max(v2_a[1], v2_b[1], v2_c[1])) do
                        for y = math.ceil(math.min(v2_a[2], v2_b[2], v2_c[2])), math.floor(math.max(v2_a[2], v2_b[2], v2_c[2])) do
                            local barycentric = { x - v2_a[1], y - v2_a[2] }
                            local u = AMATH.VecXU.Dot(barycentric, v2) / dot1
                            local v = AMATH.VecXU.Dot(barycentric, v1) / dot2

                            if dot1 == 0 then
                                u = 0;
                            end
                            if dot2 == 0 then
                                v = 0;
                            end

                            -- check if the pixel is inside the triangle
                            if u >= 0 and v >= 0 and u + v <= 1 then
                                -- call the function with the UV coordinates and set the pixel to the result
                                SetPixel(x, y, uvFunc(u, v))
                            end
                        end
                    end
                end,
                drawBuffer = function(wind, dx, dy)
                    if dx == nil then dx = 0 end
                    if dy == nil then dy = 0 end

                    util.fs.writeFile("debug.txt", textutils.serialize(buffer))

                    for x = 1, width, 1 do
                        for y = 1, height, 1 do
                            local char, bkg, fgr = table.unpack(buffer[x][y])
                            wind.setBackgroundColor(colors[bkg])
                            wind.setTextColor(colors[fgr])
                            wind.setCursorPos(x + dx, y + dy)
                            wind.write(char)
                        end
                    end
                end
            }
        end
    }
end

luaGL = luaGL_FUNC()
