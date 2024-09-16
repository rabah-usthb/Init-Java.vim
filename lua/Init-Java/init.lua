local M = {}
--top left corner character of the textfield
local top_left_corner = '┌'
--straight horizontal line character of the textfield
local straight_horizontal_line = '─'
--top right corner character of the textfield
local top_right_corner = '┐'
--straight vertical line character of the textfield
local straight_vertical_line = '│'
--bottom left corner character of the textfield
local bottom_left_corner =  '└'
--bottom left corner character of the textfield
local bottom_right_corner = '┘'

local indexLineInputable = {}


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


function M.getClosestInputableLine(currentLine)
   local min = math.floor(currentLine-indexLineInputable[1])
   local currentValue = 0
   for i = 2, #indexLineInputable, 1 do
       currentValue =  math.abs(currentLine-indexLineInputable[i])
       if(min>currentValue) then
           min = currentValue
        end
   end
   return min
end


function M.restrictCursor(startCol,endCol)
    local buf = vim.api.nvim_get_current_buf()
    local win_id = vim.api.nvim_get_current_win()
    local cursor_pos = vim.api.nvim_win_get_cursor(win_id)
    local currentLine, currentColumn = cursor_pos[1], cursor_pos[2]
    local rightLine = false
         for _, line in ipairs(indexLineInputable) do
            if line == currentLine and (currentColumn > endCol and currentColumn < startCol) then    
             vim.api.nvim_win_set_cursor(win_id, {currentLine, startCol})
             rightLine = true
            end
         end
         if rightLine == false then    
           local minLine = M.getClosestInputableLine(currentLine)
           vim.api.nvim_win_set_cursor(win_id, {minLine, startCol})
         end
    end



   -- Define the setupCursorListener function
function M.setupCursorListener(startCol, endCol)
    -- Create an autocommand group for easy management
    local augroup = vim.api.nvim_create_augroup("CursorListenerGroup", { clear = true })

    -- Set up the autocommand and capture startCol and endCol in the callback
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = augroup,
        callback = function()
            -- Call restrictCursor with the captured startCol and endCol
            M.restrictCursor(startCol, endCol)
        end,
        buffer = vim.api.nvim_get_current_buf(),  -- Apply to current buffer
    })
end


--write the empty line to create gap between each text field
function M.writeGapLine(buf,indexLine,GapYField)
   for i = 1,GapYField, 1 do
    vim.api.nvim_buf_set_lines(buf, indexLine[1], indexLine[2], false, {""})
    M.updateIndexLine(indexLine)
   end
end

--update the index line 
function M.updateIndexLine(indexLine)
    indexLine[1] = indexLine[1]+1
    indexLine[2] = indexLine[2]+1
   end


--write one field and label while updating the index line
function M.writeTextField(fieldWidth,fieldHeight,indexLine,buf,label,offsetXLabel,offsetXField,GapYField)
     local topFieldPart = M.getTopField(fieldWidth,offsetXField)
     local middleFieldPart = M.getMiddleField(fieldWidth,offsetXField)
     local bottomFieldPart = M.getbottomField(fieldWidth,offsetXField)

    vim.api.nvim_buf_set_lines(buf, indexLine[1], indexLine[2], false, { topFieldPart })
    M.updateIndexLine(indexLine)
    for i = 1,fieldHeight, 1 do
        if(i==math.floor(fieldHeight / 2) or i == fieldHeight) then  
          indexLineInputable[#indexLineInputable+1] =indexLine[1]
         vim.api.nvim_buf_set_lines(buf, indexLine[1], indexLine[2], false, { M.getMiddleField(fieldWidth,offsetXField,offsetXLabel,label) })
        else
           vim.api.nvim_buf_set_lines(buf, indexLine[1], indexLine[2], false, { middleFieldPart })
        end 
        M.updateIndexLine(indexLine)
    end

    vim.api.nvim_buf_set_lines(buf, indexLine[1], indexLine[2], false, { bottomFieldPart })
    M.updateIndexLine(indexLine)
    M.writeGapLine(buf,indexLine,GapYField)


end

--create the middle part line with two vertical line character and fieldWidth time space character between them
--and if label and its offset arent nil the line will have the label and the vertical line with its offset 
function M.getMiddleField(fieldWidth,offsetXField,offsetXLabel,label)
    local middlefield = ""
    if label == nil and offsetXLabel == nil then
     middlefield = string.rep(" ",offsetXField)..straight_vertical_line..string.rep(" ",fieldWidth)..straight_vertical_line 
    else if label~= nil and offsetXLabel~=nil then
     local sizeLabel = #label
     local offsetX = offsetXField - (offsetXLabel+sizeLabel)
     middlefield = string.rep(" ",offsetXLabel)..label..string.rep(" ",offsetX)..straight_vertical_line..string.rep(" ",fieldWidth)..straight_vertical_line 
  end
 end
    return middlefield
end

--create the top part of the textfield made with the top corners character and fieldWidth time character
--of horizontal line and offsetXField time space character to make space between beggining and the field
function M.getTopField(fieldWidth,offsetXField)
    local topFieldPart = string.rep(" ",offsetXField)..top_left_corner..string.rep(straight_horizontal_line, fieldWidth)..top_right_corner
    return topFieldPart

end

--create the bottom part of the textfield made with the bottom corners character and fieldWidth time character
--of horizontal line and offsetXField time space character to make space between beggining and the field
function M.getbottomField(fieldWidth,offsetXField)
    local bottomFieldPart = string.rep(" ",offsetXField)..bottom_left_corner..string.rep(straight_horizontal_line, fieldWidth)..bottom_right_corner
    return bottomFieldPart
end


--write the labels and textfield nbfields time
function M.setTextField(labels,fieldWidth,fieldHeight,buf,offsetXLabel,offsetXField,GapYField)
    local nbField = #labels
    local indexLine = {0,1}
    for i = 1, nbField, 1 do
        M.writeTextField(fieldWidth,fieldHeight,indexLine,buf,labels[i],offsetXLabel,offsetXField,GapYField)
    end

end

--set the title 
function M.setTitle(title)
    -- Set the terminal window title on Neovim start
    vim.cmd('set title')
    vim.cmd('let &titlestring = "' .. title .. '"')
end

--create the floating window
function M.setWindow(buf,height,width,x,y)
 -- Define the highlight group for the border
    vim.cmd('highlight MyWhiteBorder guifg=white')
  local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = width,
        height = height,
        col = x,
        row = y,
        border = 'rounded',
        style =  'minimal',
    })
    
    vim.api.nvim_win_set_option(win, 'winhl', 'FloatBorder:MyWhiteBorder')

    return win

end

--initailize the buffer of the window
function M.initBuf()
 local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')   -- Set buffer type to nofile
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')   -- Buffer is wiped when no longer visible
    vim.api.nvim_buf_set_option(buf, 'swapfile', false)     -- Disable swap file for this buffer
    vim.api.nvim_buf_set_option(buf, 'buflisted', false)    -- Do not list buffer in buffer list
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})       -- Clear any existing content
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
local winWidth = 70
--set the height of the floating window
local winHeight = 10

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
--set field width
local fieldWidth = 35
--set field height
local fieldHeight = 1
--set offset of the labels
local offsetXLabel = 6
--set offset of the fields
local offsetXField = 24
--set the gap between each fields
local GapYField = 2
--call method to create the window
M.setWindow(buf,winHeight,winWidth,x,y)
--call the method to set the labels and textfields
M.setTextField(labels,fieldWidth,fieldHeight,buf,offsetXLabel,offsetXField,GapYField)
--call the method to set the title
M.setTitle(title)
local startCol = offsetXField
local endCol = offsetXField+fieldWidth
M.setupCursorListener(startCol,endCol)

end


return M
