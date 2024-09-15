local M = {}


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


function M.setTitle(title)

 -- Set the terminal window title on Neovim start
 vim.cmd('set title')
 vim.cmd('let &titlestring ='"..title..'"')

end

function M.setWindow(buf,height,width,x,y)
  local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,  -- Width of the window
        height = height,  -- Height of the window (single line + border)
        col = y,
        row = x,
        border = 'single',
    })
 return win

end

function M.initBuf()
 local buf = vim.api.nvim_create_buf(false, true)
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
M.setWindow(buf,winHeight,winWidth,x,y)
M.setTitle(title)
end

return M
