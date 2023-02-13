local function ASR_FUNC()
    local prefix <const> = "asr_";

    local function Set(parentProgram, objName, key, value)
        F.programData.set(prefix .. parentProgram, objName, key, value)
    end
    local function Get(parentProgram, objName, key)
        return F.programData.getOrCreate(prefix .. parentProgram, objName, key, nil)
    end

    return {
        createObject = function(parentProgram, srcObj)
            local e = {}
            local objName = ""

            for key, value in pairs(srcObj) do
                e[key] = function(val)
                    if val == nil then
                        return Get(parentProgram, objName, key)
                    end
                    Set(parentProgram, objName, key, val)
                    return val;
                end
                e[key](value);
                objName = objName .. key:sub(1, 1);
            end

            e.asrName = objName;
            return e;
        end,
        loadAll = function(parentProgram)
            local groups = F.programData.getGroups(prefix .. parentProgram);

            local objects = {};

            for key, value in pairs(groups) do
                table.insert(objects,
                    ASR.createObject(parentProgram, F.programData.getFullObject(prefix .. parentProgram, value)));
            end

            return objects;
        end
    }
end

ASR = ASR_FUNC();
