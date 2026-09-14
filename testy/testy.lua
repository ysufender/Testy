---@module "testy.impl.test"
---@module "testy.impl.suite"

---@class Map<K ,V>: { [K]: V }

---@class Testy
---@field Suite  Testy.Suite
---@field Test   Testy.Test
---@field suites Map<string, Testy.Suite>
---@field name string
local Testy = {
    Suite = require "testy.impl.suite",
    Test = require "testy.impl.test",
}

---@param name string
---@return Testy
function Testy.init(name)
    local obj = {
        name = name,
        suites = { },
    }

    return setmetatable(obj, { __index = Testy })
end

---@param self Testy|string
---@param suite Testy.Suite|string
---@return Testy|string
function Testy.suite(self, suite)
    if type(self) == "string" then
        return self
    elseif type(suite) == "string" then
        return suite
    elseif self.suites[suite.name] then
        return "A suite with the name '"..suite.name.."' already exists."
    else
        self.suites[suite.name] = suite
        return self
    end
end

---@param self Testy|string
---@return { success: integer, fail: integer, total: integer }|nil
function Testy.run(self)
    if type(self) == "string" then
        print(self.."\nFailed to initialize Testy.")
        return
    end

    local success_count, fail_count = 0, 0;

    for _, suite in pairs(self.suites) do
        if suite:run() then
            success_count = success_count + 1
        else
            fail_count = fail_count + 1
        end
    end

    if fail_count ~= 0 then
        print(string.format(
            "%d suites succeeded\n%d suites failed\n%d total suits",
            success_count,
            fail_count,
            success_count + fail_count
        ))
    else
        print("All suites succeeded.")
    end

    return {
        success = success_count,
        fail = fail_count,
        total = success_count + fail_count,
    }
end

---@param self Testy|string
function Testy.record(self)
    if type(self) == "string" then
        print(self.."\nFailed to initialize Testy.")
        return
    end

    if not os.execute("mkdir -p .testy/") then
        print("Failed to create Testy record dir.")
        return
    end


    print("Recording...")
    for _, suite in pairs(self.suites) do
        suite:record()
    end
end

return Testy
