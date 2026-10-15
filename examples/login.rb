# frozen_string_literal: true

###############################################################################
#
# Lua Virtualizer — login
#
# Version        : v1.0.0
# Language       : Ruby
# Author         : Bartosz Wójcik
# Web page       : https://www.pelock.com
#
###############################################################################

$LOAD_PATH.unshift(File.expand_path("../lib", __dir__))
require "lua-virtualizer"

p LuaVirtualizer.new("YOUR-WEB-API-KEY").login

# A missing or invalid key is limited to 1000 bytes and the server applies only flat code virtualization (code_virtualization=flat), ignoring every other strategy field.
