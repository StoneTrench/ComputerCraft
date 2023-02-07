error(arg[0] .. " is deprecated!")

local function ARRAY_FUNC()
    local function create(iterator)
        local array = {
            data = {},
            length = function()
                return #self.data;
            end,
            push = function(any)
                self.insert(self.length, any)
            end,
            remove = function(any)
                return self.removeAt(self.indexOf(any))
            end,
            removeAt = function(index)
                return table.remove(self.table, index)
            end,
            insert = function(index, any)
                table.insert(self.data, index + 1, any)
            end,
            indexOf = function(any)
                for i = 0, self.length, 1 do
                    if self.data[i] == any then
                        return i;
                    end
                end

                return -1;
            end,
            map = function(func)
                for i = 0, self.length, 1 do
                    func(self.data[i], i, self.data);
                end

                return self;
            end,
            filter = function(func)
                for i = 0, self.length, 1 do
                    if not func(self.data[i], i, self.data) then
                        self.removeAt(i)
                    end
                end

                return self;
            end,
            reduce = function(func)
                local result = self.data[0];

                for i = 1, self.length, 1 do
                    result = func(result, self.data[i], i, self.data)
                end

                return result;
            end,
            toString = function()
                return self.reduce(function(a, b)
                    return tostring(a) .. tostring(b)
                end)
            end
        }

        if iterator ~= nil then
            for i, value in iterator do
                array.push(iterator)
            end
        end

        return array;
    end

    return {
        create = create
    }
end

ARRAY = ARRAY_FUNC()
