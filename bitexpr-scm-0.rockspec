package = "bitexpr"
version = "scm-0"
source = {
  url = "git://github.com/siffiejoe/lua-bitexpr.git",
}
description = {
  summary = "C-like bit expressions for Lua",
  detailed = [[
    A function for compiling and evaluating expressions in a
    C-like language (including bitwise operators).
  ]],
  homepage = "https://github.com/siffiejoe/lua-bitexpr/",
  license = "MIT"
}
dependencies = {
  "lua >= 5.1, < 5.3",
  "lpeg >= 0.9",
  "bit32"
}
build = {
  type = "builtin",
  modules = {
    bitexpr = "bitexpr.lua"
  }
}

