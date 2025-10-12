# hamache's flexible love2d vectors.
## logic notes:
- operators +, *, -, /, ^ and negation (unary minus) are mapped through all components
- comparisons ( <, >, <=, >= ) are comparing vectors by their length
- comparison ( ==, ~= ) are comparing every component of the vector, if one is different then stops and returns the result
- operations between vectors with different axes stretch the result to the biggest vector

## functions:
### `vec.random(axes, from, to)`
fills a vector using love.math.random (or math.random if used outside love2d)
### `vec:dot(b)`
dot product for vecA and vecB
### `vec:len()`
returns vector's length
### `vec:cross(b)`
cross product, supports only vec3
### `vec:norm()`
returns a normalized vector
### `vec:map(func, b, ...)`
maps a function for every vector's component. can be used along with vector b and other args
### `vec:lerp(b, t)`
linear interpolation between vecA and vecB at t fraction

## examples and explanations:
### `vec(x) -> {x,x,x}` automatically fills up to vec3
### `vec(x,y) -> {x,x,x,x}` there is not much need in vec2 in love2d, so i replaced it with axis filling 
### `vec{x,y} -> {x,y}` but you can still do vec2 if you want using curly brackets
### `print(vec(1/3, 5, 10)) >> vec(3.33, 5.00, 10.00)`string conversion
### `vec(10,4)*10 -> vec(100, 100, 100)` supports any operators for  vec x num  and  vec x vec
### `vec(x,y,z,w,...) -> {x,y,z,w,...}`

## big example:
```lua
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
```
