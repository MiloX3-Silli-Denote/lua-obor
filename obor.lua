--[[

________________________________________________________________________________________________________________________

?   https://github.com/MiloX3-Silli-Denote/lua-obor

?   MIT License

?   Copyright (c) 2024 Milo:3 Silli Denote

*   Permission is hereby granted, free of charge, to any person obtaining a copy
*   of this software and associated documentation files (the "Software"), to deal
*   in the Software without restriction, including without limitation the rights
*   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
*   copies of the Software, and to permit persons to whom the Software is
*   furnished to do so, subject to the following conditions:
*
*   The above copyright notice and this permission notice shall be included in all
*   copies or substantial portions of the Software.
*
*   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
*   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
*   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
*   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
*   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
*   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
*   SOFTWARE.

________________________________________________________________________________________________________________________

]]

local Obor = {};

Obor.__index = Obor;

--? check if object is a userdata or a table
local function isData(obj)
    local tp = type(obj);

    return tp == "userdata" or tp == "table";
end

--? determine if a is (sub)object of b
function is(a, b)
    if not isData(a) or not isData(b) then
        return false; -- comparing to a non object
    end

    local meta_b = b.__super and b or getmetatable(b); -- check if b is a super, if not then get its super

    if not meta_b or not meta_b.__super then
        return false; -- b is not a an obor
    end

    local meta_a = a.__super and a or getmetatable(a);

    while meta_a do
        if meta_a == meta_b then
            return true; -- a was a subobject of b
        end

        meta_a = getmetatable(meta_a);
    end

    return false; -- a was not a subobject of b
end

--! NOT TO BE OVERWRITTEN
function Obor:__call(...) -- metamethod
    if not self.__super then
        self = getmetatable(self);

        assert(self.__super, "tried to create instance of non object");
    end

    local instance = setmetatable({__super = false}, self);
    instance:new(...);

    return instance;
end

-- default :new() function to prevent crashing when not redefined
function Obor:new() -- meant to be overwritten
end

--? create a new object that returns true when is() is called comparing new object to current
function Obor:extend()
    local class = setmetatable({}, self);

    class.__index = class;
    class.__super = true;

    class.__call = self.__call;

    return class;
end

--? inherit functions from given object
function Obor:inherit(obj)
    if not obj.__super then
        obj = getmetatable(obj);

        assert(obj and obj.__super, "tried to inherit from non-object");
    end

    local tempPairs = obj.__pairs; -- prevent shenanigans
    obj.__pairs = pairs;

    for k, v in pairs(obj) do
        if type(v) == "function" then
            self[k] = v;
        end
    end

    self.__pairs = tempPairs;
    obj.__pairs = tempPairs; -- allow shenanigans

    return self;
end

--? quick function for extending and inheriting
function Obor:pull()
    return self:extend():inherit(self);
end

return Obor;
