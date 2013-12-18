local assert = assert
local tonumber = assert( tonumber )
local loadstring = assert( loadstring or load )
local require = assert( require )
local L = require( "lpeg" )
local bit32 = require( "bit32" )
local extract = assert( bit32.extract )
local band = assert( bit32.band )
local lshift = assert( bit32.lshift )

-- unary operations
local function codegen_unop( op, v1 )
  if op == "+" then return v1
  elseif op == "-" then return "((N("..v1..")+1)%4294967296)"
  elseif op == "~" then return "N("..v1..")"
  end
end

-- binary operations
local function codegen_binop( v1, op, v2 )
  if op == "+" then return "(("..v1.."+"..v2..")%4294967296)"
  elseif op == "-" then return "(("..v1.."+N("..v2..")+1)%4294967296)"
  elseif op == "*" then return "unsigned_multiply("..v1..","..v2..")"
  elseif op == "/" then return "unsigned_div("..v1..","..v2..")"
  elseif op == "%" then return "("..v1.."%"..v2..")"
  elseif op == "^" then return "X("..v1..","..v2..")"
  elseif op == "&" then return "A("..v1..","..v2..")"
  elseif op == "|" then return "O("..v1..","..v2..")"
  elseif op == ">>" then return "R("..v1..","..v2..")"
  elseif op == "<<" then return "L("..v1..","..v2..")"
  end
end

local function chknum( s, b )
  local n = tonumber( s, b )
  assert( n ~= nil and  n < 4294967296,
          "invalid bitexpr number literal (too large for 32bit?)" )
  return n
end

-- lpeg parser/evaluator
local P,S,R,V,C,Cf,Cg,Cc = L.P,L.S,L.R,L.V,L.C,L.Cf,L.Cg,L.Cc
local Space = S" \n\t"^0
local Number = C( R"19" * R"09"^0 + P"0" ) * Space
local HexNumber = P"0" * S"xX" * C( R( "09", "AF", "af" )^1 ) * Space
local BinNumber = P"0" * S"bB" * C( S"01"^1 ) * Space
local Ident = C( (R( "az", "AZ" ) + P"_") * (R( "az", "AZ", "09" ) + P"_")^0 ) * Space
local BinOp1 = C( P"|" ) * Space
local BinOp2 = C( P"^" ) * Space
local BinOp3 = C( P"&" ) * Space
local BinOp4 = C( P"<<" + P">>" ) * Space
local BinOp5 = C( S"+-" ) * Space
local BinOp6 = C( S"*/%" ) * Space
local Open = "(" * Space
local Close = ")" * Space
local UnOp = C( S"+-~" ) * Space

local G = Space * P{
  "Exp0",
  Exp0 = Cf( V"Exp1" * Cg( BinOp1 * V"Exp1" )^0, codegen_binop ),
  Exp1 = Cf( V"Exp2" * Cg( BinOp2 * V"Exp2" )^0, codegen_binop ),
  Exp2 = Cf( V"Exp3" * Cg( BinOp3 * V"Exp3" )^0, codegen_binop ),
  Exp3 = Cf( V"Exp4" * Cg( BinOp4 * V"Exp4" )^0, codegen_binop ),
  Exp4 = Cf( V"Exp5" * Cg( BinOp5 * V"Exp5" )^0, codegen_binop ),
  Exp5 = Cf( V"Atom" * Cg( BinOp6 * V"Atom" )^0, codegen_binop ),
  Atom = HexNumber * Cc( 16 ) / chknum +
         BinNumber * Cc( 2 ) / chknum +
         Number / chknum +
         Ident / function( n ) return "O(V['"..n.."'])" end +
         UnOp * V"Atom" / codegen_unop +
         Open * V"Exp0" * Close
} * P( -1 )


local max_int = 2^51

local function umul( v1, v2 )
  local vm = v1 * v2
  if vm >= max_int then
    local mask = 4294967295
    vm = 0
    for i = 0, 31 do
      vm = vm + lshift( band( extract( v1, i )*mask, v2 ), i )
    end
  end
  return vm % 4294967296
end

local function udiv( v1, v2 )
  return (v1 - (v1 % v2)) / v2
end


local codecache = {}

local function bitexpr( s )
  if not codecache[ s ] then
    local code = [[
local bit32, unsigned_multiply, unsigned_div = ...
local O = bit32.bor
local A = bit32.band
local N = bit32.bnot
local X = bit32.bxor
local L = bit32.lshift
local R = bit32.rshift
return function( V ) return ]] ..
    assert( L.match( G, s ), "invalid bit operator expression" ) ..
    " end"
    local f = assert( loadstring( code, "[bitexpr]" ) )
    codecache[ s ] = f( bit32, umul, udiv )
  end
  return codecache[ s ]
end

return bitexpr

