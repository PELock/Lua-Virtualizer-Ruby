# frozen_string_literal: true

###############################################################################
#
# Lua Virtualizer — every public option
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
client.enable_compression = false
client.rename_style = LuaVirtualizer::RenameStyle::IL
# auto omits the POST field. Explicit: 5.1, 5.2, 5.3, 5.4, 5.5, luajit, luau.
client.target = LuaVirtualizer::Target::AUTO
client.code_virtualization = LuaVirtualizer::CodeVirtualization::VM
client.self_defending = true
client.protection_linker = true
client.detect_debugger = true
client.anti_vm = true
client.anti_sandbox = true
client.anti_emulator = true
client.rename_variables = true
client.rename_parameters = true
client.rename_functions = true
client.rename_function_calls = true
client.shuffle_functions = true
client.resolve_constants = true
client.split_strings = true
client.modify_strings = true
client.encrypt_strings = true
client.string_char_array_vault = true
client.encrypt_integers = true
client.encrypt_floating = true
client.mba_binops = true
client.integers_to_floating = true
client.integers_to_arrays = true
client.floats_to_arrays = true
client.affine_integer_mask = true
client.array_int_crypt = true
client.array_char_crypt = true
client.array_double_crypt = true
client.array_string_crypt = true
client.insert_random_value_bucket = true
client.random_bucket_integers = true
client.random_bucket_arrays = true
client.random_bucket_functions = true
client.random_bucket_characters = true
client.random_bucket_anti_regex = true
client.random_bucket_autostart = true
client.insert_ternary_operators = true
client.complexify_booleans = true
client.opaque_branches = true
client.opaque_mixer_chain = true
client.insert_dead_code = true
client.try_finally_noise = true
client.decoy_functions = true
client.lambda_decoys = true
client.literal_padding = true
client.fake_import_markers = true
client.dynamic_getattr_calls = true
client.obfuscate_imports = true
client.callback_registration_stubs = true
client.remove_comments = true

source = <<~LUA
  local function greet(name)
    print("Hello, " .. name)
  end
  greet("Lua")
LUA

result = client.obfuscate_script_source(source)
if result && result["error"] == LuaVirtualizer::ERROR_SUCCESS
  puts result["output"]
  puts result["target"]
else
  warn "Error: #{result.inspect}"
end

# Per-function marker (source syntax, not a library import). The marker is the
# first statement of a function. The engine reads it and strips it.
#
# local function f()
#   LUAVIRTUALIZER(VM(FSA), OBFUSCATION(encrypt_strings, NUMBERS))
#   return 1
# end
#
# VM(VM|FSA|FLAT|NONE) selects the dispatcher; NONE stays native Lua.
# OBFUSCATION(...) is a blacklist: NONE, ALL, group names NAMES, STRINGS,
# NUMBERS, BOOLEANS, SHAPE, BUCKET, CALLS, COMMENTS, PROTECT, or a specific
# snake_case strategy flag.
