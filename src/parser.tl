local utilities = require("utilities")
utilities.depends_on("lpeg")
local lpeg = require("lpeg")
local S, C, P, V, R, Cc = lpeg.S, lpeg.C, lpeg.P, lpeg.V, lpeg.R, lpeg.Cc
local whitespace = S" \t\n"^0

local record Node
    enum Operator
        "+"
        "-"
        "*"
        "/"
        "^"
    end

    record Patterns
        number: lpeg.Pattern
        exponentiation: lpeg.Pattern
        multiplication_division: lpeg.Pattern
        addition_subtraction: lpeg.Pattern
        implicit_multiplication: lpeg.Pattern
        expression: lpeg.Pattern
        term: lpeg.Pattern
        factor: lpeg.Pattern
        exponent: lpeg.Pattern
        group: lpeg.Pattern
    end
    type Value = Node | number
    left: Value
    operator: Operator
    right: Value

    metamethod __tostring: function(self: Node): string
end

function Node.create(pattern: lpeg.Pattern): lpeg.Pattern
    return pattern/function(left: Node.Value, operator: Node.Operator, right: Node.Value): Node
        return setmetatable({ left = left, operator = operator, right = right } as Node, {
            __tostring = function (self: Node): string
                return string.format("(%s %s %s)", tostring(self.left), self.operator, tostring(self.right))
            end
        })
    end
end


local digit = R"09"
Node.Patterns.number = whitespace * C(S"-+"^-1 * (digit^1 * (P"." * digit^0 + P"") + P"." * digit^1))/tonumber
local number = Node.Patterns.number
Node.Patterns.exponentiation = whitespace * C(P"^") * whitespace
Node.Patterns.multiplication_division = whitespace * C(S"*/") * whitespace
Node.Patterns.addition_subtraction = whitespace * C(S"+-")  * whitespace
Node.Patterns.implicit_multiplication = #P"(" * Cc"*"
Node.Patterns.group = P"(" * whitespace * V"expression" * whitespace * P")"

Node.Patterns.exponent = Node.create((V"factor" + V"group" + number) * Node.Patterns.exponentiation * (V"exponent" + V"group" + number))
Node.Patterns.factor = Node.create((V"group" + number) * (Node.Patterns.multiplication_division + Node.Patterns.implicit_multiplication) * (V"factor" + V"group" + number))
Node.Patterns.term = Node.create((V"factor" + V"group" + number) * (Node.Patterns.addition_subtraction + Node.Patterns.implicit_multiplication) * V"expression")

Node.Patterns.expression = V"term" + V"factor" + V"exponent" + V"group" + number

local expression = P {
    "expression",
    expression = Node.Patterns.expression,
    term = Node.Patterns.term,
    factor = Node.Patterns.factor,
    exponent = Node.Patterns.exponent,
    group = Node.Patterns.group
}

function Node.parse(str: string): Node
    return expression:match(str) as Node
end

return Node
