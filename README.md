#              bitexpr -- C-like Bit Expressions for Lua             #

##                           Introduction                           ##

Starting from version 5.2 Lua has support for bitwise operations on
32 bit unsigned integer values by means of the built-in `bit32`
module (there is also a [backport][1] of `bit32` for Lua 5.1). Still,
some people have complained about the lack of actual operators for
bitwise operations. The `bitexpr` module provides a domain specific
language for C-like expressions including bitwise operators and 32-bit
unsigned overflow/wrap-around.

  [1]:  http://luarocks.org/repositories/rocks/#bit32


##                          Getting Started                         ##

The `bitexpr` module exports a single function that compiles a string
containing a mathematical expression into a Lua function. The compiled
function is cached, so another call with the same expression will
reuse the compiled function. 

```lua
local X = require( "bitexpr" )
print( X" 1 | 2 "() )  --> prints 3
```

The domain specific expression language supports 32 bit unsigned
integers in decimal, hexadecimal, and binary format. Literal numbers
larger than `2^32-1` will raise an error during parsing. You can also
pass variables to the expression using a table.

```lua
print( X" 123 "() )       --> prints 123
print( X" 0xFE "() )      --> prints 254
print( X" 0b1010 "() )    --> prints 10
print( X" a "{ a = 3 } )  --> prints 3
```

The usual arithmetic and bitwise operators are available:

```lua
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
```

Operator preference is the same as in C, and you can use parentheses
for grouping.

```lua
print( X" 1+2*3 "() )    --> prints 7
print( X" (1+2)*3 "() )  --> prints 9
```

That's basically it. Have fun!


##                              Contact                             ##

Philipp Janda, siffiejoe(a)gmx.net

Comments and feedback are always welcome.


##                              License                             ##

`bitexpr` is *copyrighted free software* distributed under the MIT
license (the same license as Lua 5.1). The full license text follows:

    bitexpr (c) 2013 Philipp Janda

    Permission is hereby granted, free of charge, to any person obtaining
    a copy of this software and associated documentation files (the
    "Software"), to deal in the Software without restriction, including
    without limitation the rights to use, copy, modify, merge, publish,
    distribute, sublicense, and/or sell copies of the Software, and to
    permit persons to whom the Software is furnished to do so, subject to
    the following conditions:

    The above copyright notice and this permission notice shall be
    included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
    EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
    MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
    IN NO EVENT SHALL THE AUTHOR OR COPYRIGHT HOLDER BE LIABLE FOR ANY
    CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
    TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
    SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

