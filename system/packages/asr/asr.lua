local function ASR_FUNC()
    local prefix = "asr_";

    local function Set(parentProgram, objName, key, value)
        F.programData.set(prefix .. parentProgram, objName, key, value)
    end
    local function Get(parentProgram, objName, key)
        return F.programData.getOrCreate(prefix .. parentProgram, objName, key, nil)
    end

    return {
        createObject = function(parentProgram, srcObj, name)
            local e = {}

            local clone = srcObj;
            clone.asrName = name;

            for key, value in pairs(clone) do
                e[key] = function(val)
                    if val == nil then
                        return Get(parentProgram, name, key)
                    end
                    Set(parentProgram, name, key, val)
                    return val;
                end
                e[key](value);
            end

            return e;
        end,
        loadAll = function(parentProgram)
            local groups = F.programData.getGroups(prefix .. parentProgram);

            local objects = {};

            for key, value in pairs(groups) do
                local srcObj = F.programData.getFullObject(prefix .. parentProgram, value);
                if srcObj then
                    table.insert(objects, ASR.createObject(parentProgram, srcObj, srcObj.asrName));
                end
            end

            return table.unpack(objects);
        end,
        whipeAll = function (parentProgram)
            local groups = F.programData.getGroups(prefix .. parentProgram);
            
            for key, value in pairs(groups) do
                F.programData.delete(prefix .. parentProgram, value);
            end
        end
    }
end

ASR = ASR_FUNC();
