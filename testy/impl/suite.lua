---@module "testy.impl.test"

---@class Testy.Suite
---@field name string
---@field exec string
---@field tests Map<string, Testy.Test>
local Suite = { }

---@param name string
---@param exec string
---@return Testy.Suite
function Suite.init(name, exec)
    local obj = {
        name = name,
        exec = exec,
        tests = {}
    }

    return setmetatable(obj, { __index = Suite })
end

---@param self Testy.Suite|string
---@param test Testy.Test
function Suite.test(self, test)
    if type(self) == "string" then
        return self
    elseif self.tests[test.name] then
        return "In suite '"..self.name.."', a test with name '"..test.name.."' already exists."
    else
        self.tests[test.name] = test
        return self
    end
end

---@param self Testy.Suite|string
---@return boolean
function Suite.run(self)
    local success, fail = 0, 0

    if type(self) == "string" then
        print(self.."\nFailde to initialize suit")
        return false
    end

    print("Running suite: "..self.name)

    for _, test in pairs(self.tests) do
        if test:run(self) then
            success = success + 1
        else
            fail = fail + 1
        end
    end

    if fail ~= 0 then
        print(string.format(
            "%d tests succeeded\n%d tests failed\n%d total tests\n",
            success,
            fail,
            success + fail
        ))
        return false
    else
        print("All tests succeeded\n")
        return true
    end
end

function Suite:record()
    if not os.execute("mkdir -p .testy/"..self.name) then
        print("Failed to create Testy record dir.")
        return
    end

    print("Recording suite '"..self.name.."'")

    for _, test in pairs(self.tests) do
        test:record(self)
    end
end

return Suite
