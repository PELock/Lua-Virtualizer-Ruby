# frozen_string_literal: true

require "base64"
require "json"
require "zlib"

class LuaVirtualizer
  API_URL = "https://www.pelock.com/api/lua-virtualizer/v1"
  ERROR_SUCCESS = 0
  ERROR_INPUT_SIZE = 1
  ERROR_INPUT = 2
  ERROR_PARSING = 3
  ERROR_OBFUSCATION = 4
  ERROR_OUTPUT = 5
  USER_AGENT = "PELock Lua Virtualizer"

  FLAG_PARAMS = {
    self_defending: "self_defending",
    protection_linker: "protection_linker",
    rename_variables: "rename_variables",
    rename_parameters: "rename_parameters",
    rename_functions: "rename_functions",
    rename_function_calls: "rename_function_calls",
    shuffle_functions: "shuffle_functions",
    resolve_constants: "resolve_constants",
    split_strings: "split_strings",
    modify_strings: "modify_strings",
    encrypt_strings: "encrypt_strings",
    string_char_array_vault: "string_char_array_vault",
    encrypt_integers: "encrypt_integers",
    encrypt_floating: "encrypt_floating",
    mba_binops: "mba_binops",
    integers_to_floating: "integers_to_floating",
    integers_to_arrays: "integers_to_arrays",
    floats_to_arrays: "floats_to_arrays",
    affine_integer_mask: "affine_integer_mask",
    array_int_crypt: "array_int_crypt",
    array_char_crypt: "array_char_crypt",
    array_double_crypt: "array_double_crypt",
    array_string_crypt: "array_string_crypt",
    insert_random_value_bucket: "insert_random_value_bucket",
    random_bucket_integers: "random_bucket_integers",
    random_bucket_arrays: "random_bucket_arrays",
    random_bucket_functions: "random_bucket_functions",
    random_bucket_characters: "random_bucket_characters",
    random_bucket_anti_regex: "random_bucket_anti_regex",
    random_bucket_autostart: "random_bucket_autostart",
    insert_ternary_operators: "insert_ternary_operators",
    complexify_booleans: "complexify_booleans",
    opaque_branches: "opaque_branches",
    opaque_mixer_chain: "opaque_mixer_chain",
    insert_dead_code: "insert_dead_code",
    try_finally_noise: "try_finally_noise",
    decoy_functions: "decoy_functions",
    lambda_decoys: "lambda_decoys",
    literal_padding: "literal_padding",
    fake_import_markers: "fake_import_markers",
    dynamic_getattr_calls: "dynamic_getattr_calls",
    obfuscate_imports: "obfuscate_imports",
    callback_registration_stubs: "callback_registration_stubs",
    detect_debugger: "detect_debugger",
    anti_vm: "anti_vm",
    anti_sandbox: "anti_sandbox",
    anti_emulator: "anti_emulator",
    remove_comments: "remove_comments"
  }.freeze

  attr_accessor :enable_compression, :seed, :randomization_density, :rename_style, :code_virtualization, :target,
                *FLAG_PARAMS.keys

  def initialize(api_key = nil)
    @api_key = api_key
    @enable_compression = false
    @seed = nil
    @randomization_density = nil
    @rename_style = nil
    @target = "auto"
    @code_virtualization = CodeVirtualization::VM
    FLAG_PARAMS.each_key { |name| instance_variable_set("@#{name}", true) }
    @self_defending = false
    @protection_linker = false
    @detect_debugger = false
    @anti_vm = false
    @anti_sandbox = false
    @anti_emulator = false
  end

  def login(return_as_object = true)
    post_request({ "command" => "login" }, return_as_object)
  end

  def obfuscate_script_file(script_file_path, return_as_object = true)
    source = File.read(script_file_path, encoding: "UTF-8")
    return nil if source.nil? || source.empty?

    obfuscate_script_source(source, return_as_object)
  rescue StandardError
    nil
  end

  def obfuscate_script_source(script_source, return_as_object = true)
    post_request({ "command" => "obfuscate", "source" => script_source }, return_as_object)
  end

  private

  def post_request(params_array, return_as_object)
    params = params_array.dup
    params["key"] = @api_key unless @api_key.nil? || @api_key.to_s.empty?

    params["seed"] = @seed.to_s unless @seed.nil?
    params["randomization_density"] = @randomization_density.to_s unless @randomization_density.nil?
    params["rename_style"] = @rename_style if @rename_style
    params["code_virtualization"] = @code_virtualization if @code_virtualization
    if @target && !@target.to_s.empty? && @target.to_s.downcase != "auto"
      params["target"] = @target.to_s
    end

    FLAG_PARAMS.each do |name, key|
      params[key] = "1" if instance_variable_get("@#{name}")
    end

    if @enable_compression && params["source"]
      params["source"] = Base64.strict_encode64(Zlib::Deflate.deflate(params["source"], 9))
      params["compression"] = "1"
    end

    body = Http.post_multipart(API_URL, params, user_agent: USER_AGENT)
    return nil if body.nil? || body.empty?

    result = Http.parse_json(body)
    return nil if result.nil?

    depacked = false
    if @enable_compression && result["error"] == ERROR_SUCCESS && result["output"]
      begin
        result["output"] = Zlib::Inflate.inflate(Base64.decode64(result["output"]))
        depacked = true
      rescue StandardError
        return nil
      end
    end

    return result if return_as_object
    return JSON.generate(result) if depacked

    body
  end
end
