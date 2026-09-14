---@class Testy.Test
---@field name     string
---@field params   string
---@field expected string
local Test = {}

---@param name   string
---@param params string
---@param expected string
---@return Testy.Test
function Test.init(name, params, expected)
    local obj = {
        name = name,
        params = params,
        expected = expected,
    }

    return setmetatable(obj, { __index = Test })
end

---@param exec string
---@return boolean
function Test:run(exec)
    print("Running test '"..self.name.."'")

    local cmd = exec.." "..self.params
    local proc = io.popen(cmd, "r")
    if not proc then
        print("Failed to execute '"..cmd.."'")
        return false
    end

    local output = proc:read("*a")

    if output == self.expected then
        return true
    end

    print("\tExpected '"..self.expected.."' received '"..output.."'")
    return false
end

return Test
