local record export end
local req = require

function export.depends_on(module: string)
    local ok = pcall(req, module)
    if not ok then
        error("Module "..module.." not found, did you forget to install it (such as with luarocks)?")
    end
end

return export
