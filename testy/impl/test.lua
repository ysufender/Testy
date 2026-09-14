---@module "testy.impl.suite"

---@class Testy.Test
---@field name     string
---@field params   string
local Test = {}

---@param name   string
---@param params string
---@return Testy.Test
function Test.init(name, params)
    local obj = {
        name = name,
        params = params,
    }

    return setmetatable(obj, { __index = Test })
end

---@param parent Testy.Suite
---@return boolean
function Test:run(parent)
    print("Running test '"..self.name.."'")

    local expected_path = ".testy/"..parent.name.."/"..self.name..".record"

    local cmd = parent.exec.." "..self.params
    local proc = io.popen(cmd, "r")
    if not proc then
        print("Failed to execute '"..cmd.."'")
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

    print("\tExpected\n\t"..expected.."received\n\t"..output.."'")
    return false
end

---@param parent Testy.Suite
function Test:record(parent)
    print("Recording test '"..self.name.."'")

    local expected_path = ".testy/"..parent.name.."/"..self.name..".record"

    local cmd = parent.exec.." "..self.params
    local proc = io.popen(cmd, "r")
    if not proc then
        print("Failed to execute '"..cmd.."'")
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
