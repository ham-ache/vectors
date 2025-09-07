-- hamache's (GitHub: @hamache) vectors for Love2D
-- supports any amount of axes

--[[

local vec = require 'vec' -- or whatever the filename for this library is

/////          /////     vec(x) -> {x,x,x}            | automatically fills up to vec3
/////          /////     vec(x,y) -> {x,x,x,x}        | there is not much need in vec2 in love2d, so i replaced it with axis filling 
////////////////////     vec{x,y} -> {x,y}            | but you can still do vec2 if you want using curly brackets
////////////////////     print(vec(1/3, 5, 10)) >> vec(3.33, 5.00, 10.00) | string conversion
/////          /////     vec(10,4)*10 -> vec(100, 100, 100)               | supports any operators for  vec x num  and  vec x vec
/////          /////     vec(x,y,z,w,...) -> {x,y,z,w,...}

functions:
vec.random(axes, from, to)      | fills a vector using love.math.random (or math.random if used outside love2d)
vec:dot(b)                      | dot product for vecA and vecB
vec:len()                       | returns vector's length
vec:cross(b)                    | cross product, supports only vec3
vec:norm()                      | returns a normalized vector
vec:map(func, b, ...)           | maps a function for every vector's component. can be used along with vector b and other args
vec:lerp(b, t)                  | linear interpolation between vecA and vecB at t fraction

logic:
operators +, *, -, /, ^ and negation (unary minus) are mapped through all components
comparisons ( <, >, <=, >= ) are comparing vectors by their length
comparison ( ==, ~= ) are comparing every component of the vector, if one is different then stops and returns the result

operations between vectors with different amount of axes are done so the result vector size will be equal to first (A vector)
// actually, it depends. TODO tomorrow: think about this sh*t, stretch out the shortest vec

    EXAMPLE (enable console):

    vec = require 'vec'
    local function println(...)
        for x, s in ipairs({...}) do
            print(s)
        end
    end
    function love.load()
        println(
            vec{1,4}, -- vec(1, 4), raw vec2
            vec(1,4), -- vec(1, 1, 1, 1), axes filling
            vec(1), -- vec(1, 1, 1)
            vec(1,2,3), -- vec(1, 2, 3)
            vec(1,2,5,2,3,2),
            '',
            'operations:',
            vec(5)*vec(1.6), -- vec3(8)
            vec(5)/vec(2), -- vec3(2.5)
            vec(1.5,4)*vec(2,5), -- vec(3, 3, 3, 3, 2)
            vec(5)/vec(1,2), -- vec(5, 5)
            vec(1,2)/vec(5), -- vec(0.2, 0.2, 0.2)
            10/vec(10)*10, -- vec(10)
            vec(10)*vec(1,1,1,0,0,0), -- vec(10, 10, 10, 0, 0, 0)
            vec(1,6)*vec(10), -- vec(10, 10, 10)
            vec{10,12}^2, -- vec(100, 144)
            vec(5):norm(), -- vec(1, 1, 1)
            vec(1)<vec(2), -- true
            vec(2)<vec(1), -- false
            vec(1)==vec(1), -- true
            vec(1)==vec(2), -- false
            -vec(1), -- vec(-1.00, -1.00, -1.00)
            vec(), -- vec()
            vec.random(), -- random vector
            vec.random(4, 1, 10), -- random vector 2
            (vec.random(3, -100, 100)/10):map(math.abs), -- negative random turned to positive using math.abs
            vec(1):lerp(vec(2), 0.5) -- vec(1.50, 1.50, 1.50)
        )
    end

]]--

-- this sucks but slightly improves performance (https://www.lua.org/gems/sample.pdf page 17)
local ipairs = ipairs
local type = type
local setmetatable = setmetatable
local getmetatable = getmetatable

local rand = love.math.random or math.random

local function lerp(a,b,t) return (1-t)*a + t*b end
local function len1(v)
    local res = 0
    for _, val in ipairs(v) do
        res = res + val^2
    end
    return res^0.5
end
local function vconv(a, b)
    if type(a) == 'number' then
        local t = {}
        for x = 1, #b do
            t[x] = a
        end
        a = t
        return a, true
    end
    return a, false
end
local function map(a, b, applied, nilTo)
    local nilTo = (nilTo ~= nil) and nilTo or 0
    local new = {}
    a, _ = vconv(a, b)
    b, bc = vconv(b, a)
    for axis, val in ipairs(b) do
        a[axis] = (a[axis] ~= nil) and a[axis] or nilTo
        val = (val ~= nil) and val or nilTo
        
        new[axis] = applied(a[axis], val)
    end
    return setmetatable(new, getmetatable(bc and a or b))
end

local vec = {
    __add = function(a, b) return map(a, b, function(aa, bb) return aa + bb end) end,
    __mul = function(a, b) return map(a, b, function(aa, bb) return aa * bb end, 1) end,
    __sub = function(a, b) return map(a, b, function(aa, bb) return aa - bb end) end,
    __div = function(a, b) return map(a, b, function(aa, bb) return aa / bb end, 1) end,
    __pow = function(a, b) return map(a, b, function(aa, bb) return aa ^ bb end) end,
    __unm = function(a)    return map(a, -1, function(aa, bb) return aa * bb end) end,
    
    __le =  function(a, b) return len1(a) <= len1(b) end,
    __lt =  function(a, b) return len1(a) <  len1(b) end,
    __eq =  function(a, b)
        for axis, val in ipairs(b) do
            if a[axis] ~= val then
                return false
            end
        end
        return true
    end,
    __tostring = function(t)
        local str = 'vec('
        for x, v in ipairs(t) do
            str = str..string.format('%.2f', v)
            if x < #t then str = str .. ', ' end
        end
        return str..')'
    end
}
vec.__index = function(t, key)
    if key == 'x' then
        return t[1]
    elseif key == 'y' then
        return t[2]
    elseif key == 'z' then
        return t[3]
    elseif key == 'w' then
        return t[4]
    end
    return vec[key]
end
function vec:dot(b)
    local res = 0
    for x, val in ipairs(self) do
        res = res + val*b[x]
    end
    return res
end
function vec:len()
    return len1(self)
end
function vec:cross(b) -- currently supports vec3 only
    local a = self
    return vec(
        a.y*b.z - a.z*b.y,
        a.z*b.x - a.x*b.z,
        a.x*b.y - a.y*b.x
    )
end
function vec:norm()
    return self / self:len()
end
function vec:map(func, b, ...)
    local new = setmetatable({}, vec)
    for x, val in ipairs(self) do
        if b then
            new[x] = func(val, b[x], ...)
        else
            new[x] = func(val, ...)
        end
    end
    return new
end
function vec:lerp(b, t)
    return self:map(lerp, b, t)
end

return setmetatable({
    random = function(axes, a, b)
        local axes = axes or 3
        local res = {}
        for x = 1, axes do
            table.insert(res, rand(a, b))
        end
        return setmetatable(res, vec)
    end
}, { __call = function(_, ...)
    local args = {...}
    local fval = args[1]
    if type(fval) == 'table' then
        return setmetatable(fval, vec)
    end
    if #args == 1 then
        args = {fval, fval, fval}
    end
    if #args == 2 then
        local sval = args[2]
        args = {}
        for x = 1, sval do 
            table.insert(args, fval)
        end
    end
    return setmetatable(args, vec)
end})