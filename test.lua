#!/usr/bin/lua


local X = require( "bitexpr" )
print( X" 1 | 2 "() )  --> prints 3

print( X" 123 "() )       --> prints 123
print( X" 0xFE "() )      --> prints 254
print( X" 0b1010 "() )    --> prints 10
print( X" a "{ a = 3 } )  --> prints 3

print( X" +1 "() )    --> unary plus; prints 1
print( X" -1 "() )    --> unary minus, prints 4294967295
print( X" ~0 "() )    --> bitwise not, prints 4294967295
print( X" 1+1 "() )   --> plus, prints 2
print( X" 2-1 "() )   --> minus, prints 1
print( X" 2*3 "() )   --> multiplication, prints 6
print( X" 9/2 "() )   --> integer division, prints 4
print( X" 9%2 "() )   --> modulo division, prints 1
print( X" 7^3 "() )   --> exclusive or, prints 4
print( X" 6&3 "() )   --> bitwise and, prints 2
print( X" 5|3 "() )   --> bitwise or, prints 7
print( X" 9>>2 "() )  --> right shift, prints 2
print( X" 5<<1 "() )  --> left shift, prints 10

print( X" 1+2*3 "() )    --> prints 7
print( X" (1+2)*3 "() )  --> prints 9


local function test( s, exp, ... )
  local v = nil
  if select( '#', ... ) > 0 then
    v, exp = exp, (...)
  end
  local r = X( s )( v )
  print( s, "=", r )
  assert( r == exp, "`"..s.."' is not "..tostring( exp ) )
end

--test( "1 -", nil )
--test( "4294967297", nil )
test( "123", 123 )
test( "0xFF", 255 )
test( "0b01110111", 119 )
test( " +1 ", 1 )
test( "a", { a = 5 }, 5 )
test( "~0", 4294967295 )
test( "-2", 4294967294 )
test( "-0", 0 )
test( "+1", 1 )
test( "1+2*3", 7 )
test( "(1+2)*3", 9 )
test( "-1 + 1", 0 )
test( "2 - 3", 4294967295 )
test( "5 / 2", 2 )
test( "5 % 2", 1 )
test( "0xFFFFFFFF * 0xfffffffe", 2 )
test( "1 | 2", 3 )
test( "5 ^ 7", 2 )
test( "1 & 3", 1 )
test( "1 << 2", 4 )
test( "4 >> 1", 2 )
test( "7 & ~3", 4 )
test( "(a << 24) | 0x10000000 | (((d & 0xF) >> 4) << 8) | " ..
      "(((d & 0xF0) >> 8) << 16) | (s + 0x100000)",
      { a = 34567, d = 19876, s = 12345 }, 386936889 )

