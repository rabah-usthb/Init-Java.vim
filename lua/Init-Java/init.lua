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

--create the floating window GUI
function M.createFoaltingWidow ()
  -- Create a buffer for the floating window
    local buf = vim.api.nvim_create_buf(false, true)

    -- Define window dimensions and positioning
    local width = 50
    local height = 10
    local opts = {
        style = "minimal",
        relative = "editor",
        width = width,
        height = height,
        row = (vim.o.lines - height) / 2,  -- Vertically center
        col = (vim.o.columns - width) / 2, -- Horizontally center
    }

    -- Create a floating window
    local win = vim.api.nvim_open_win(buf, true, opts)

    -- Set up buffer options
    vim.api.nvim_buf_set_option(buf, 'buftype', 'prompt')

    -- Add multiple lines for user input (Project Path and Project Name)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        'Enter Project Path: ',
        'Enter Project Name: ',
    })

    -- Variables to store inputs
    local inputs = { path = '', name = '' }

    -- Function to handle user input
    local function handle_input(input, line)
        if line == 1 then
            inputs.path = input  -- Store path input
        elseif line == 2 then
            inputs.name = input  -- Store name input
        end
    end

    -- Function to capture user input
    local function start_prompt(line)
        -- Clear previous prompt callback if any
        vim.fn.prompt_setcallback(buf, nil)

        -- Define a new prompt callback
        vim.fn.prompt_setcallback(buf, function(input)
            handle_input(input, line)

            -- Move to the next input or finish
            if line == 1 then
                start_prompt(2)  -- Move to project name input
                vim.api.nvim_buf_set_lines(buf, 1, 2, false, {"Enter Project Name: "})
                vim.fn.prompt_setprompt(buf, '> ')
            else
                -- Process the inputs
                print("Project Path: " .. inputs.path)
                print("Project Name: " .. inputs.name)
                -- Close the floating window after both inputs are captured
                vim.api.nvim_win_close(win, true)
            end
        end)

        -- Set the buffer to insert mode
        vim.cmd("startinsert")
    end

    -- Start with the first input (project path)
    start_prompt(1)
    vim.fn.prompt_setprompt(buf, '> ')  -- Set prompt symbol

    M.createJavaProject(inputs.path,inputs.name)
end

return M 
