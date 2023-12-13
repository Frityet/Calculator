local Node = require("parser")
local eval = require("evaluator")

local function print_ast(node: Node.Value, indent: integer | nil)
    indent = indent or 0
    local function make_indent(level: integer): string
        return string.rep("  ", level)
    end

    if node is Node then
          io.write(indent > 0 and '\n' or '', make_indent(indent)..node.operator..":")

          if node.left then
              io.write('\n', make_indent(indent + 1).."- Left: ")
              print_ast(node.left, indent + 2)
          end

          if node.right then
              io.write('\n', make_indent(indent + 1).."- Right: ")
              print_ast(node.right, indent + 2)
          end
    elseif node is number then
        io.write(node)
    end
end

local function calculate(input: string): number
    local ast = Node.parse(input)
    return eval(ast)
end

local done = false
repeat
    io.write("> ")
    local input = io.read("*l")
    if input:sub(1, 1) == "q" then
        done = true
    elseif input:sub(1, 1) == "!" then
        print_ast(Node.parse(input:sub(2)))
        print()
    else
        print(calculate(input))
    end
until done
