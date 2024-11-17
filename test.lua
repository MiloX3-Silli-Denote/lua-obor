local Obor = require("obor");

local Math = Obor:extend(); -- class container

local Vec = Math:extend();      -- object
local Mat = Math:extend();      -- object
local Triangle = Math:extend(); -- object

function Vec:new(x, y)
    self[1] = x or 0;
    self[2] = y or x or 0;
end

function Vec:__index(key)
    if key == "x" then
        return self[1];
    elseif key == "y" then
        return self[2];
    end

    if Vec[key] then
        return Vec[key];
    end

    error("couldnt index Vec with \"" .. key .. "\"");
end

function Vec:__add(a)
    assert(is(a, Vec), "tried to add non vec");

    return Vec(self.x + a.x, self.y + a.y);
end

local Vec3 = Vec:pull();

function Vec3:new(x, y, z)
    self[1] = x or 0;
    self[2] = y or x or 0;
    self[3] = z or y or x or 0;
end

function Mat:new(a, b, c, d)
    self.a = a or 0;
    self.b = b or 0;
    self.c = c or 0;
    self.d = d or 0;
end

function Mat:__mul(a)
    assert(is(a, Math), "tried to mul mat by non vec/mat");

    if is(a, Vec) then
        return Vec(self.a * a.x + self.b * a.y, self.c * a.x + self.d * a.y);
    elseif is(a, Mat) then
        return Mat(self.a * a.a + self.b * a.c, self.a * a.b + self.b * a.d, self.c * a.a + self.d * a.c, self.c * a.b + self.d * a.d);
    end

    error("couldnt mul mat by math object");
end

local vec_a = Vec(5, 5);
local vec_b = Vec(10, 5);

local vec_c = vec_a + vec_b; -- should be 15, 10
print(vec_c.x, vec_c.y);

local mat_a = Mat(2, 0, 0, 2); -- scale vec by 2

local vec_d = mat_a * vec_c; -- should be 30, 20
print(vec_d.x, vec_d.y);

local mat_b = Mat(0, 1, 1, 0);
local mat_c = mat_a * mat_b; -- should be : 0, 2, 2, 0
print(mat_c.a, mat_c.b, mat_c.c, mat_c.d);

local vec_3 = Vec3(2, 2, 2);
local vec_e = vec_3 + vec_3; -- should be 4, 4
print(vec_e.x, vec_e.y);


--local err_1 = vec_d + mat_a; -- tried to add non vec
--local err_2 = mat_a * Triangle(); -- couldnt mul mat by math object
