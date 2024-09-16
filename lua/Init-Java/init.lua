local M = {}

local top_left_corner = '┌'
local straight_horizontal_line = '─'
local top_right_corner = '┐'
local straight_vertical_line = '│'
local bottom_left_corner =  '└'
local bottom_right_corner = '┘'

--create the java project 
function M.createJavaProject(ProjectPath,ProjectName)
    --concat ProjectPath with project name to get full path that is needed in the commands
    local fullPath = ProjectPath..ProjectName
    --command to create bin and src folder
    local commandBinSrc = "mkdir -p "..fullPath.."/bin".." "..fullPath.."/src"
    --command to create the main java file inside the src folder
    local commandMainFile = "touch "..fullPath.."/src/Main.java"
    --execute the commandBinSrc
    os.execute(commandBinSrc)
    --execute the commandMainFile
    os.execute(commandMainFile)
end


function M.updateIndexLine(indexLine)
    indexLine[1] = indexLine[1]+1
    indexLine[2] = indexLine[2]+1
end

function M.writeTextField(fieldWidth,fieldHeight,indexLine,buf)
     local topFieldPart = M.getTopField(fieldWidth)
     local middleFieldPart = M.getMiddleField(fieldWidth)
     local bottomFieldPart = M.getbottomField(fieldWidth)

    vim.api.nvim_buf_set_lines(buf, indexLine[1], indexLine[2], false, { topFieldPart })
    M.updateIndexLine(indexLine)
    for i = 1,fieldHeight, 1 do
    vim.api.nvim_buf_set_lines(buf, indexLine[1], indexLine[2], false, { middleFieldPart })
    M.updateIndexLine(indexLine)
    end

    vim.api.nvim_buf_set_lines(buf, indexLine[1], indexLine[2], false, { bottomFieldPart })
    M.updateIndexLine(indexLine)


end

function M.getMiddleField(fieldWidth)
    local middlefield = straight_vertical_line..string.rep(" ",fieldWidth)..straight_vertical_line 
    return middlefield
end

function M.getTopField(fieldWidth)
    local topFieldPart = top_left_corner..string.rep(straight_horizontal_line, fieldWidth)..top_right_corner
    return topFieldPart

end


function M.getbottomField(fieldWidth)
    local bottomFieldPart = bottom_left_corner..string.rep(straight_horizontal_line, fieldWidth)..bottom_right_corner
    return bottomFieldPart
end


function M.setTextField(label,fieldWidth,fieldHeight,buf)
    local nbField = #label
    local indexLine = {0,1}
    for i = 1, nbField, 1 do
        M.writeTextField(fieldWidth,fieldHeight,indexLine,buf)
    end

end


function M.setTitle(title)
    -- Set the terminal window title on Neovim start
    vim.cmd('set title')
    vim.cmd('let &titlestring = "' .. title .. '"')
end

function M.setWindow(buf,height,width,x,y)
  local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = x,
        row = y,
        border = 'single',
    })
 return win

end

function M.initBuf()
 local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')  -- Set buffer type to nofile
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')   -- Buffer is wiped when no longer visible
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)     -- Disable swap file for this buffer
 return buf
end


--create the floating window GUI
function M.createFloatingWindow ()
--create new buffer
local buf = M.initBuf()
--get the neovim width
local vimWidth = vim.o.columns
--get the neovim height
local vimHeight = vim.o.lines
--set the width of the floating window
local winWidth = 40
--set the height of the floating window
local winHeight = 20

--calculate the coordinate x , y of the floating window to be in center of the neovim window
local x = math.floor((vimWidth-winWidth)/2)
local y = math.floor((vimHeight-winHeight)/2)
--set title of the floating window
local title = "Init Java Project"
--set string table of labels
local labels = {
  "ProjectPath",
  "ProjectName"
}
local fieldWidth = 10
local fieldHeight = 3
M.setWindow(buf,winHeight,winWidth,x,y)
M.setTextField(labels,fieldWidth,fieldHeight,buf)
M.setTitle(title)
end

return M
