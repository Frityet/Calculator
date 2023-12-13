local Node = require("parser")

local OPERATIONS<const>: { Node.Operator: function(a: number, b: number): number } = {
    ["+"] = function(a: number, b: number): number return a + b end,
    ["-"] = function(a: number, b: number): number return a - b end,
    ["*"] = function(a: number, b: number): number return a * b end,
    ["/"] = function(a: number, b: number): number return a / b end,
    ["^"] = function(a: number, b: number): number return a ^ b end,
}

local function eval(node: Node.Value): number
    if node is number then return node end

    local left = eval(node.left)
    local operator = node.operator
    local right = eval(node.right)

    return OPERATIONS[operator](left, right)
end

return eval
