local Testy = require "testy.testy"

local test = Testy
    .init("Simple Test")

    :suite(Testy.Suite
        .init("simple_suite", "echo")
        :test(Testy.Test
            .init("simple_test",
                  "Hello World",
                  "Hello World"))

        :test(Testy.Test
            .init("simple_test_2",
                  "Hello World",
                  "Hello World\n")))

if type(test) == "string" then
    print(test)
else
    test:run()
end
