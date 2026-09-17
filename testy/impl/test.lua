---@module "testy.impl.suite"

---@class Testy.Test
---@field name     string
---@field command   string
local Test = {}

---@param name   string
---@param command string
---@return Testy.Test
function Test.init(name, command)
    local obj = {
        name = name,
        command = command,
    }

    return setmetatable(obj, { __index = Test })
end

---@param parent Testy.Suite
---@return boolean
function Test:run(parent)
    print("Running test '"..self.name.."'")

    local expected_path = ".testy/"..parent.name.."/"..self.name..".record"

    local proc = io.popen(self.command, "r")
    if not proc then
        print("Failed to execute '"..self.command.."'")
        return false
    end

    local output = proc:read("*a")
    proc:close()

    proc = io.open(expected_path, "r")
    if not proc then
        print("Failed to read expected file '"..expected_path.."'")
        return false
    end
    local expected = proc:read("*a")

    if output == expected then
        return true
    end

    local result_file = ".testy/.cache/"..parent.name.."/"..self.name..".result"
    local file = io.open(result_file, "w");
    if not file then
        print("Failed to write result file '"..result_file.."'")
        return false
    end

    if not file:write(output) then
        print("Failed to write result file '"..result_file.."'")
        return false
    end
    file:close()

    print("\tDiffering Outputs")
    if not os.execute("diff -y "..expected_path.." "..result_file) then
        print("Failed to get output diff")
    end
    return false
end

---@param parent Testy.Suite
function Test:record(parent)
    print("Recording test '"..self.name.."'")

    local expected_path = ".testy/"..parent.name.."/"..self.name..".record"

    local proc = io.popen(self.command, "r")
    if not proc then
        print("Failed to execute '"..self.command.."'")
        return false
    end

    local output = proc:read("*a")
    proc:close()

    proc = io.open(expected_path, "w+")
    if not proc then
        print("Failed to write record file '"..expected_path.."'")
        return
    end

    if not proc:write(output) then
        print("Failed to record test.")
    end
end

return Test
