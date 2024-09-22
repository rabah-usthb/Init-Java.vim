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


function M.colOutOfBounds(currentColumn,startCol,endCol)
    return (currentColumn > endCol or currentColumn < startCol)
end

function M.getClosestCol(currentColumn,startCol,endCol)
 local closetColumn = 0
 local gapStart = math.abs(currentColumn-startCol)
 local gapEnd = math.abs(currentColumn-endCol)
        if gapStart>=gapEnd then
        closetColumn = endCol
           else
          closetColumn = startCol
             end

    return closetColumn
end


function M.initCursor(win,startCol)
    vim.api.nvim_win_set_cursor(win, {indexLineInputable[1], startCol})
end




function M.getFurthestLine(currentLine)
    local max = math.abs(indexLineInputable[1]-currentLine)
    local furthestLine = indexLineInputable[1]
    local currentValue = 0
    for i = 2, #indexLineInputable, 1 do
        currentValue = math.abs(indexLineInputable[i]-currentLine)
        if  currentValue > max then
            max = currentValue
            furthestLine = indexLineInputable[i] 
        end
    end
    return furthestLine
end


function M.restrictCursor(win_id,startCol,endCol)
    local cursor_pos = vim.api.nvim_win_get_cursor(win_id)
    local currentLine, currentColumn = cursor_pos[1], cursor_pos[2]
    local rightLine = false    
            for _, line in ipairs(indexLineInputable) do
                if line == currentLine then 
                    rightLine = true 
                end
            if line == currentLine and (M.colOutOfBounds(currentColumn,startCol,endCol)) then    
            local closetColumn = M.getClosestCol(currentColumn,startCol,endCol)
            vim.api.nvim_win_set_cursor(win_id, {currentLine, closetColumn})  
            break
             end
         end
         if rightLine == false then
            local furthestLine = M.getFurthestLine(currentLine)
            local closestCol = currentColumn
             if M.colOutOfBounds(currentColumn,startCol,endCol) then
             closestCol =M.getClosestCol(currentColumn,startCol,endCol) 
             end
             vim.api.nvim_win_set_cursor(win_id, {furthestLine, closestCol})
             end
       end


function M.cleanupCursorListener()
    -- Delete the autocommand group
    vim.api.nvim_del_augroup_by_name("CursorListenerGroup")
  end








function M.setupCursorListener(buf, win_id, startCol, endCol)
    if vim.api.nvim_win_is_valid(win_id) then
    -- Create an autocommand group for easy management
    local augroup = vim.api.nvim_create_augroup("CursorListenerGroup", { clear = true })

    -- Set up the autocommand to handle CursorMoved event
    vim.api.nvim_create_autocmd("CursorMoved", {
        group = augroup,
        callback = function()
            M.restrictCursor(win_id, startCol, endCol)
        end,
        buffer = buf,  -- Apply to current buffer
    })


 -- Set up the autocommand to handle CursorMovedI event (for insert mode)
        vim.api.nvim_create_autocmd("CursorMovedI", {
            group = augroup,
            callback = function()
                M.restrictCursor(win_id, startCol, endCol)
            end,
            buffer = buf,  -- Apply to current buffer
        })

    -- Handle mode changes
  
    -- Handle InsertEnter and InsertLeave
    vim.api.nvim_create_autocmd({"InsertEnter", "InsertLeave"}, {
        group = augroup,
        callback = function()
            M.restrictCursor(win_id, startCol, endCol)
        end,
    })
     end
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
          indexLineInputable[#indexLineInputable+1] =indexLine[2]
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

function M.unshiftPipe()
  local line = vim.api.nvim_get_current_line()
 local indexO = 0 
 local indexC = 0
-- local output = ""
for i = 1, #line do
  --  output = output .. "char[" .. i .. "] = " .. string.sub(line, i, i) .. " "
    if i+2 <= #line and M.isPipe(string.sub(line,i,i+2)) then
       if indexO == 0 then
        indexO = i
          else
             indexC = i
             break
       end 
    end
end
line = string.sub(line,1,indexC-1).."   "..string.sub(line,indexC+3,#line)
--  print("opening pipe ",indexO.." closing pipe ",indexC)
 -- vim.cmd('echo "' .. output .. '"')
  
  local newLine =string.sub(line,1,62)..'│'
  vim.api.nvim_set_current_line(newLine)
end

function M.isPipe(char)
    local bool = false
    
    if #char == 3 then
        if  string.byte(char, 1) == 226 and  string.byte(char, 2) == 148 and  string.byte(char, 3) == 130 then
           bool = true 
        end
    end
    return bool
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
local win = M.setWindow(buf,winHeight,winWidth,x,y)
--call the method to set the labels and textfields
M.setTextField(labels,fieldWidth,fieldHeight,buf,offsetXLabel,offsetXField,GapYField)
--call the method to set the title
M.setTitle(title)
local startCol = offsetXField+3
local endCol = offsetXField+fieldWidth+2
M.initCursor(win,startCol)
--M.setupCursorListener(buf,win,startCol,endCol)
--M.setupDeleteListener(buf,win,startCol,endCol)
--Map the Delete key in insert mode to the Lua function

local function restrictDelete()
   local currentCol = vim.api.nvim_win_get_cursor(win)[2]-- Get the current column (0-indexed)
   -- Define key codes for backspace
    local backspace_key = vim.api.nvim_replace_termcodes('<BS>', true, true, true)
    
    -- Check if the current column should prevent deletion
    if currentCol ~= startCol and currentCol ~= endCol then
        -- Allow deletion by simulating the backspace key press
        vim.api.nvim_feedkeys(backspace_key, 'n', true)
    end
end


_G.check_and_unshift = function()   

    local line = vim.api.nvim_get_current_line()
    
--    print(#line)
    local charAtCol = line:sub(63,65)  -- Get character at the column after the pipe
    if not M.isPipe(charAtCol) then
            M.unshiftPipe()
    end
 end




-- Use InsertCharPre to run the function before inserting any character
vim.cmd [[
augroup KeyPressListener
    autocmd!
    autocmd TextChangedI * lua check_and_unshift()  -- Trigger on any key press in insert mode
    autocmd BufWinLeave * lua vim.cmd('augroup KeyPressListener | autocmd! | augroup END')  -- Remove the listener when window is closed
augroup END
]]


 vim.api.nvim_set_keymap('i', '<BS>', '', {
        noremap = true,
        silent = true,
        callback = restrictDelete  -- directly reference the function
    })
  -- Autocommand to unmap <BS> when window is closed
    vim.api.nvim_create_autocmd("WinClosed", {
        buffer = buf,
        callback = function()
            -- Unmap the Backspace key to stop the callback when window closes
            vim.api.nvim_del_keymap('i', '<BS>')
        end,
    })
    vim.api.nvim_create_autocmd("BufWinLeave", {
        buffer = buf,
        callback = M.cleanupCursorListener,
    })
end


return M
