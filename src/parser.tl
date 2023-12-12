local utilities = require("utilities")
utilities.assert_module_exists("lpeg")
local lpeg = require("lpeg")
local S, C, P, V, R = lpeg.S, lpeg.C, lpeg.P, lpeg.V, lpeg.R
local whitespace = S" \t\n"^0

local record Node
    record Patterns
        number: lpeg.Pattern
        multiplication_division: lpeg.Pattern
        addition_subtraction: lpeg.Pattern
        expression: lpeg.Pattern
        term: lpeg.Pattern
        factor: lpeg.Pattern
        group: lpeg.Pattern
    end
    type Value = Node | number
    left: Value
    operator: string
    right: Value

    metamethod __tostring: function(self: Node): string
end

function Node.create(pattern: lpeg.Pattern): lpeg.Pattern
    return pattern/function(left: Node.Value, operator: string, right: Node.Value): Node
        return setmetatable({ left = left, operator = operator, right = right }, {
            __tostring = function (self: Node): string
                return string.format("(%s %s %s)", tostring(self.left), self.operator, tostring(self.right))
            end
        })
    end
end

local digit = R"09"
Node.Patterns.number = whitespace *C(S"-+"^-1 * (digit^1 * (P"." * digit^0 + P"") + P"." * digit^1))/tonumber
local number = Node.Patterns.number
Node.Patterns.multiplication_division = whitespace * C(S"*/") * whitespace
local multiplication_division = Node.Patterns.multiplication_division
Node.Patterns.addition_subtraction = whitespace * C(S"+-")  * whitespace
local addition_subtraction = Node.Patterns.addition_subtraction
Node.Patterns.expression = V"term" + V"factor" + V"group" + number
Node.Patterns.term = Node.create((V"factor" + V"group" + number) * addition_subtraction * V"expression")
Node.Patterns.factor = Node.create((V"group" + number) * multiplication_division * (V"factor" + V"group" + number))
Node.Patterns.group = P"(" * whitespace * V"expression" * whitespace * P")"

local expression = P {
    "expression",
    expression = Node.Patterns.expression,
    term = Node.Patterns.term,
    factor = Node.Patterns.factor,
    group = Node.Patterns.group
}

function Node.parse(str: string): Node
    return expression:match(str) as Node
end

return Node
