--[[
  This is a very simple module for accessing logging methods in the Test Service.

  Usage example:

    local Console = require(game.Workspace.Console)

    Console:Log("Hello, World!") -- Prints blue text to the output.
    Console:Warn("There's a problem!") -- Prints yellow text to the output.

  The warn function can optionally be used with a bool value to only warn if
  the condition is false:

    local bool = true

    console.warn("A descriptive warning message", bool) -- No output.
--]]

local TestService = game:GetService("TestService")

local Console = {}

function Console:Log(description)
  TestService:Message(description)
end

function Console:Warn(description, condition)
  local condition = condition or false

  TestService:Warn(condition, description)
end

return Console
