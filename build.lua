local Efile = require "efile"

local AMALG      = "amalg.lua "
local AMALGFLAGS = "-o "
                   .."build/testy_bundle.lua "
                   .."-s "
                    .."testy/testy.lua "
                    .."testy.impl.test "
                    .."testy.impl.suite "

local CC     = "gcc "
local CFLAGS = "-I/usr/include/lua5.4 "
               .."-Ibuild/ "
               .."-O2 -Wall -Wextra "

---@type fun(): nil
local to_header do
    to_header = function ()
        local f = io.open("build/testy_bundle.lua", "rb")
        if not f then return "Failed to open build/testy_bundle.lua" end
        local data = f:read("*a")
        f:close()
        local out = io.open("build/testy_bundle.h", "w")
        if not out then return "Failed to write testy_bundle.h" end
        out:write("/* Auto-generated */\nunsigned char testy_bundle[] = {\n  ")
        for i = 1, #data do
            out:write(string.format("0x%02x, ", data:byte(i)))
            if i % 12 == 0 then out:write("\n  ") end
        end
        out:write("\n};\nunsigned int testy_bundle_len = " .. #data .. ";\n")
        out:close()
    end
end

local project = Efile.Project
    .init("Efile")

    :step(Efile.Step
        .init("bundle")
        :dependOnFiles({
            "build.lua",
            "testy/testy.lua",
            "testy/impl/test.lua",
            "testy/impl/suite.lua",
        })
        :action(AMALG..AMALGFLAGS)
        :action(to_header))

    :step(Efile.Step
        .init("build")
        :dependOnFile("testy/testy.c")
        :dependOnStep("bundle")
        -- :action(CC..CFLAGS.."testy/testy.c -o build/testy -l\"lua5.4\" -lm -ldl"))
        :action(CC..CFLAGS.."testy/testy.c -o build/testy -llua -lm -ldl")) -- try this if above doesn't work

    :step(Efile.Step
        .init("install")
        :dependOnStep("build")
        :action("sudo install -m 755 build/testy /usr/local/bin/testy"))

    :step(Efile.Step
        .init("help")
        :action(function ()
            print("Usage:\n\tlua build.lua <target>\n\ttesty <target>")
            print("\nTargets:")
            print("    bundle : bundle testy sources")
            print("    build  : build testy executable")
            print("    install: install testy on system")
            print("    help   : print this help text")
            print("    clean  : clean")
            return false
        end))

    :step(Efile.Step
        .init("clean")
        :action("rm -rf build"))

local result = Efile.Project.build(project, arg[1] or "build") or "Success"
print(result)
