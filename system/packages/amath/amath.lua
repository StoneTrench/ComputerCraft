local function AMATH_FUNC()
    return {
        PerspectiveMatrix = function(width, height, near, far, fov)
            return {
                (height / width) / math.tan(fov * 0.5), 0, 0, 0,
                0, 1 / (math.tan(fov * 0.5)), 0, 0,
                0, 0, -far / (far - near), -1,
                0, 0, -far * near / (far - near), -1
            }
        end,
        TransformMatrix = function(position, rotation, scale)
            return {
                (height / width) / math.tan(fov * 0.5), 0, 0, 0,
                0, 1 / (math.tan(fov * 0.5)), 0, 0,
                0, 0, -far / (far - near), -1,
                0, 0, -far * near / (far - near), -1
            }
        end,
        VecXU = {
            Add = function(vecX_a, vecX_b)
                return util.table.map(vecX_a, function(e, i)
                        return e + vecX_b[i];
                    end)
            end,
            Sub = function(vecX_a, vecX_b)
                return util.table.map(vecX_a, function(e, i)
                        return e - vecX_b[i];
                    end)
            end,
            Dot = function(vecX_a, vecX_b)
                return util.table.reduce(util.table.map(vecX_a, function(e, i)
                        return e * vecX_b[i];
                    end), function(a, b)
                        return a + b
                    end)
            end,
            Scale = function(vecX, scalar)
                return util.table.map(vecX, function(e, i)
                        return e * scalar;
                    end)
            end,
            Length = function(vecX)
                return math.sqrt(util.table.reduce(util.table.map(vecX, function(e, i)
                        return e * e;
                    end), function(a, b)
                        return a + b
                    end))
            end,
            Normalize = function(vecX)
                return AMATH.VecXU.Scale(vecX, 1 / AMATH.VecXU.Length(vecX));
            end,
            Cross = function(vecX_a, vecX_b)
                if #vecX_a == 3 and #vecX_b == 3 then
                    return AMATH.Vec3U.Cross(vecX_a, vecX_b);
                end
                return nil
            end
        },
        Vec3U = {
            MultiplyMatrix = function(vec3, matrix3x3)
                local x, y, z = table.unpack(vec3)

                return {
                    x * matrix3x3[1] + y * matrix3x3[4] + z * matrix3x3[7],
                    x * matrix3x3[2] + y * matrix3x3[5] + z * matrix3x3[8],
                    x * matrix3x3[3] + y * matrix3x3[6] + z * matrix3x3[9]
                }
            end,
            Cross = function(vec3_a, vec3_b)
                return {
                    vec3_a[2] * vec3_b[3] - vec3_a[3] * vec3_b[2],
                    vec3_a[3] * vec3_b[1] - vec3_a[1] * vec3_b[3],
                    vec3_a[1] * vec3_b[2] - vec3_a[2] * vec3_b[1]
                }
            end,
            Dot = function(vec3_a, vec3_b)
                return vec3_a[1] * vec3_b[1] + vec3_a[2] * vec3_b[2] + vec3_a[3] * vec3_b[3]
            end,
            Length = function(vec3)
                return math.sqrt(vec3[1] * vec3[1] + vec3[2] * vec3[2] + vec3[3] * vec3[3])
            end,
            Scale = function(vec3, number)
                return { vec3[1] * number, vec3[2] * number, vec3[3] * number }
            end,
            Normalize = function(vec3)
                return AMATH.Vec3U.Scale(vec3, 1 / AMATH.Vec3U.Length(vec3));
            end,
            Offset = function(vec3, x, y, z)
                return { vec3[1] + x, vec3[2] + y, vec3[3] + z }
            end
        },
        Vec4U = {
            MultiplyMatrix = function(vec4, matrix4x4)
                local x, y, z, w = table.unpack(vec4)

                return {
                    x * matrix4x4[1] + y * matrix4x4[5] + z * matrix4x4[9] + w * matrix4x4[13],
                    x * matrix4x4[2] + y * matrix4x4[6] + z * matrix4x4[10] + w * matrix4x4[14],
                    x * matrix4x4[3] + y * matrix4x4[7] + z * matrix4x4[11] + w * matrix4x4[15],
                    x * matrix4x4[4] + y * matrix4x4[8] + z * matrix4x4[12] + w * matrix4x4[16]
                }
            end,
            Dot = function(vec4_a, vec4_b)
                return vec4_a[1] * vec4_b[1] + vec4_a[2] * vec4_b[2] + vec4_a[3] * vec4_b[3] + vec4_a[4] * vec4_b[4]
            end,
            Length = function(vec4)
                return math.sqrt(vec4[1] * vec4[1] + vec4[2] * vec4[2] + vec4[3] * vec4[3] + vec4[4] * vec4[4])
            end,
            Scale = function(vec4, number)
                return { vec4[1] * number, vec4[2] * number, vec4[3] * number, vec4[4] * number }
            end,
            Normalize = function(vec4)
                return AMATH.Vec4U.Scale(vec4, 1 / AMATH.Vec4U.Length(vec4));
            end,
            Offset = function(vec4, x, y, z, w)
                return { vec4[1] + x, vec4[2] + y, vec4[3] + z, vec4[4] + w }
            end
        }
    }
end

AMATH = AMATH_FUNC();
