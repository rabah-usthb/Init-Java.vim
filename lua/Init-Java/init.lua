local M = {}

local guihua = require('guihua')
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

--set the floating wibdow
function  M.setWindow(x,y,winWidth,winHeight,title)
    local win = floating.floating_buf({
    title = title,
    rect = {
      height = winHeight,
      width = winWidth,
      row = y,
      col = x
    },
    enter = true,
    border = true
  })
  return win
end

--create the textfields table from the labels table 
function M.setTextFields(labels)
 local textFields={}
    for index, label in ipairs(labels) do
          textFields[index] = input.input({
            prompt = label,
            default = ""
        })
    end
return textFields
end


--Add the labels and textFields to the floating window
function M.setTextField_Labels(win,labels)
local textFields = M.setTextFields(labels)
--XCoordinate for the label
local X = 2
--YCoordinate for both the label and textfield
local Y = 2
--Gap between label and textfield
local XGap = 18
--Gap between each line of lable textfield
local YGap = 2

--foreach loop to add the labels and textFields to the floating window
  for _, textfield in ipairs(textFields) do
     guihua.add(win, {
        {type = 'label', text = textfield.prompt, x = X, y = Y},
        {type = 'text', input = textfield, x = X+XGap, y = Y},
      })
      --updating the YCoordinate
      Y = Y+YGap
 end

end


--create the floating window GUI
function M.createFloatingWindow ()
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

--set string table of labels
local labels = {
  "ProjectPath",
  "ProjectName"
}
--call to the setTextField_Labels to automatically add the labels and textFields
M.setTextField_Labels(win,labels)

--shows the GUI
guihua.show(win)
end

return M
