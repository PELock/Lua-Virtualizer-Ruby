# frozen_string_literal: true

###############################################################################
#
# Lua Virtualizer — default options
#
# Version        : v1.0.0
# Language       : Ruby
# Author         : Bartosz Wójcik
# Web page       : https://www.pelock.com
#
###############################################################################

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "lua-virtualizer"

client = LuaVirtualizer.new("YOUR-WEB-API-KEY")
source = <<~PY
  local function greet(name)
    print("Hello, " .. name)
  end
  greet("Lua")
PY

result = client.obfuscate_script_source(source)
if result && result["error"] == LuaVirtualizer::ERROR_SUCCESS
  puts result["output"]
else
  warn "Error: #{result.inspect}"
end
