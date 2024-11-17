# lua-obor
object orriented programming for lua, designed with love2d in mind but applicable in any lua usage

## Usage
download obor.lua and place it into your project (license is in lua file aswell)
and place ```Obor = require("obor");``` in your main script
### Basic class
```lua
Obor = require("obor"); -- include

local Vector2 = Obor:extend(); -- define Vector2 as an Obor class

-- this shouldnt be called directly, but is automatically called every time a new instance of the object is created
function Vector2:new(x, y) -- define the class creation function
  self.x = x or 0;
  self.y = y or x or 0;
end

local vec = Vector2(13, 6); -- call the class as a function with the wanted inputs to create a new instance of it
```

### Inheritance
you can copy functions from one object to another with the :inherit() function
calling :pull() will extend and inherit in a single function
```lua
local Vector = Obor:extend();

function Vector.add(a, b)
  local small = #a < #b and a or b;

  local packed = {};

  for i = 1, #small do
    packed[i] = a[i] + b[i];
  end

  return small(unpack(packed));
end

function Vector:getStr()
  local str = "";

  for i = 1, #self do
    str = str .. tostring(self[i]);

    if i ~= #self then
      str = str .. ", ";
    end
  end

  return str;
end

local Vector2 = Vector:extend():inherit(Vector); -- same as line bellow
local Vector3 = Vector:pull();                   -- same as line above

function Vector2:new(x, y)
  self[1] = x or 0;
  self[2] = y or x or 0;
end

function Vector3:new(x, y, z)
  self[1] = x or 0;
  self[2] = y or x or 0;
  self[3] = z or y or x or 0;
end

local vec_a = Vector2(1, 2);
local vec_b = Vector2(3, 4);

local vec_c = Vector3(5, 6, 7);
local vec_d = Vector3(8, 9, 10);

print(vec_a:add(vec_b):getStr()); -- 4, 6
print(vec_a:add(vec_c):getStr()); -- 6, 8
print(vec_c:add(vec_d):getStr()); -- 13, 15, 17
```
when extending from an object, the is() function returns true when called comparing objects extended from the inputed object
```lua
local Vector = Obor:extend();

local Vector2 = Vector:extend(); -- extend Vector2 from the parent Vector class
local Vector3 = Vector:extend(); -- extend Vector3 from the parent Vector class

function Vector2:new(x, y) -- define Vector2 creation
  self.x = x or 0;
  self.y = y or x or 0;
end

function Vector3:new(x, y, z) -- define Vector3 creation
  self.x = x or 0;
  self.y = y or x or 0;
  self.z = z or y or x or 0;
end

local vec2 = Vector2(13, 6);
local vec3 = Vector3(13, 6, 2);

print(is(vec2, Vector)); -- TRUE
print(is(vec3, Vector)); -- TRUE

print(is(vec2, Vector2)); -- TRUE
print(is(vec2, Vector3)); -- FALSE
```

### Metamethods
metamethods can always be redefined with varying repercussions (except for __call(), this metamathod is to never be redefined else you lose the ability to create new instances of the object)
for example:
__index can be redefined but if you dont include a check for the key to be in the parent object then it will crash at object creation

__metatable can be redefined but unless it is set to a similar Obor object then the object will lose the ability to correctly be used in 'is(a, b)' function calls
```lua
local Vector2 = Obor:extend();

function Vector2:new(x, y)
  self[1] = x or 0;
  self[2] = y or x or 0;
end
```
incorrect:
```lua
--! CRASHES WHEN CREATING NEW INSTANCE OF Vector2
function Vector2:__index(key)
  -- primitive example of swizzling
  if key == "x" then
    return self[1];
  elseif key == "y" then
    return self[2];
  elseif key == "yx" then
    return Vector2(self.y, self.x);
  end

  error("tried to index \"" .. key .. "\" which is outside of Vector2 bounds"
end

local vec = Vector2(13, 6); -- CRASH
```
correct:
```lua
function Vector2:__index(key)
  -- primitive example of swizzling
  if key == "x" then
    return self[1];
  elseif key == "y" then
    return self[2];
  elseif key == "yx" then
    return Vector2(self.y, self.x);
  end

  if Vector2[key] then
    return Vector2[key];
  end

  error("tried to index \"" .. key .. "\" which is outside of Vector2 bounds"
end
```
__metatable will overwrite visible object types of the modified object
```lua
local vec2 = Vector2(13, 6);

print(is(vec2, Vector2)); -- TRUE
print(is(vec2, Obor)); -- TRUE

Vector2.__metatable = {}; -- hide the objects real metatable

print(is(vec2, Vector2)); -- FALSE
print(is(vec2, Obor)); -- FALSE
```
every other metamethod works as intended (except for __call() which should not be overwritten as previously mentioned)
```lua
function Vector2.__add(a, b)
  assert(is(a, Vector2) and is(b, Vector2), "cannot add non-vector2 to vector2");

  return Vector2(a.x + b.x, a.y + b.y);
end

function Vector2.__len()
  return 2;
end

function Vector2.__eq(a, b)
  return a.x == b.x and a.y == b.y;
end

...
```
