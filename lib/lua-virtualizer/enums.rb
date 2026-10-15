# frozen_string_literal: true

class LuaVirtualizer
  module CodeVirtualization
    VM = "vm"
    FSA = "fsa"
    FLAT = "flat"
  end

  module Target
    AUTO = "auto"
    LUA_51 = "5.1"
    LUA_52 = "5.2"
    LUA_53 = "5.3"
    LUA_54 = "5.4"
    LUA_55 = "5.5"
    LUAJIT = "luajit"
    LUAU = "luau"
  end

  module RenameStyle
    IL = "il"
    O0 = "o0"
    HEX = "hex"
    MANGLED = "mangled"
  end
end
