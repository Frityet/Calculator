local Node = require("parser")

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

if #arg < 1 then
    print("Usage: lua "..arg[0].." <expression>")
    os.exit(1)
end

local input = table.concat(arg, " ")

local ast = Node.parse(input)
print_ast(ast)
