local M = {}

local floating = require('guihua.floating')
local input = require('guihua.input')

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

function  M.setWindow(x,y,width,height,title)
    local win = floating.floating_buf({
    title = title,
    rect = {
      height = height,
      width = width,
      row = y,
      col = x
    },
    enter = true,
    border = true
  })
  return win
end

--create the floating window GUI
function M.createFoaltingWidow ()
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
local win = M.setWindow(x,y,winWidth,winHeight,title)
end

return M
