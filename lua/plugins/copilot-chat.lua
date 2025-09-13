return {
  -- Simple chat implementation that works with Copilot
  {
    "github/copilot.vim",
    config = function()
      -- Configure Copilot
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_assume_mapped = true
      
      -- Set up custom keymaps for copilot suggestions
      vim.api.nvim_set_keymap("i", "<C-J>", 'copilot#Accept("<CR>")', { silent = true, expr = true })
      vim.api.nvim_set_keymap("i", "<C-K>", 'copilot#Previous()', { silent = true, expr = true })
      vim.api.nvim_set_keymap("i", "<C-L>", 'copilot#Next()', { silent = true, expr = true })
      
      -- Global variable to track AI autocomplete state
      vim.g.ai_autocomplete_enabled = true
      
      -- Global variable to track current model (placeholder for UI)
      vim.g.current_ai_model = "copilot"
      
      -- Function to create a simple chat buffer
      local function create_chat_buffer()
        -- Create a new buffer
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(buf, 'filetype', 'markdown')
        vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
        vim.api.nvim_buf_set_option(buf, 'swapfile', false)
        
        -- Create a horizontal split window
        vim.cmd('split')
        local win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win, buf)
        vim.api.nvim_win_set_height(win, math.floor(vim.o.lines * 0.4))
        
        -- Set buffer name
        vim.api.nvim_buf_set_name(buf, 'AI Chat')
        
        -- Add header
        local header = {
          "# AI Chat Window",
          "",
          "Ask questions about your code here.",
          "Type your questions below and Copilot will help you.",
          "",
          "---",
          "",
        }
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, header)
        
        -- Move cursor to the end
        vim.api.nvim_win_set_cursor(win, {#header + 1, 0})
        
        return buf, win
      end
      
      -- Function to toggle AI autocomplete
      local function toggle_ai_autocomplete()
        vim.g.ai_autocomplete_enabled = not vim.g.ai_autocomplete_enabled
        local status = vim.g.ai_autocomplete_enabled and "enabled" or "disabled"
        print("AI autocomplete " .. status)
        
        -- Toggle copilot suggestions
        if vim.g.ai_autocomplete_enabled then
          vim.cmd("Copilot enable")
        else
          vim.cmd("Copilot disable")
        end
      end
      
      -- Function to change AI model (placeholder UI)
      local function change_ai_model()
        local models = {
          "copilot",
          "gemini-2.5-pro",
          "claude-4",
          "grok-4",
          "gpt-4o",
          "o1-preview",
          "o1-mini",
          "claude-3.5-sonnet"
        }
        
        vim.ui.select(models, {
          prompt = "Select AI Model:",
          format_item = function(item)
            return item == vim.g.current_ai_model and item .. " (current)" or item
          end,
        }, function(choice)
          if choice then
            vim.g.current_ai_model = choice
            print("AI model changed to: " .. choice)
            if choice ~= "copilot" then
              print("Note: Non-Copilot models require additional setup (API keys, etc.)")
            end
          end
        end)
      end
      
      -- Function to open chat with selected code
      local function chat_with_selection()
        -- Get visual selection
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        local lines = vim.fn.getline(start_pos[2], end_pos[2])
        
        if type(lines) == "string" then
          lines = {lines}
        end
        
        -- Handle partial line selections
        if #lines > 0 then
          if #lines == 1 then
            lines[1] = string.sub(lines[1], start_pos[3], end_pos[3])
          else
            lines[1] = string.sub(lines[1], start_pos[3])
            lines[#lines] = string.sub(lines[#lines], 1, end_pos[3])
          end
        end
        
        local selected_code = table.concat(lines, "\n")
        
        -- Create chat buffer if it doesn't exist
        local buf_exists = false
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local buf_name = vim.api.nvim_buf_get_name(buf)
          if buf_name:match("AI Chat") then
            buf_exists = true
            -- Switch to existing buffer
            vim.cmd('sbuffer ' .. buf)
            break
          end
        end
        
        if not buf_exists then
          create_chat_buffer()
        end
        
        -- Add the selected code to chat
        local chat_lines = {
          "",
          "## Selected Code:",
          "",
          "```" .. vim.bo.filetype,
          selected_code,
          "```",
          "",
          "## Question:",
          "",
        }
        
        local current_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        vim.api.nvim_buf_set_lines(0, -1, -1, false, chat_lines)
        
        -- Position cursor at the end for user input
        local new_line_count = #current_lines + #chat_lines
        vim.api.nvim_win_set_cursor(0, {new_line_count, 0})
        
        -- Enter insert mode
        vim.cmd('startinsert!')
      end
      
      -- Function to open empty chat
      local function open_chat()
        create_chat_buffer()
        vim.cmd('startinsert!')
      end
      
      -- Function to close chat
      local function close_chat()
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local buf_name = vim.api.nvim_buf_get_name(buf)
          if buf_name:match("AI Chat") then
            vim.api.nvim_buf_delete(buf, {force = true})
            break
          end
        end
      end
      
      -- Function to toggle chat
      local function toggle_chat()
        local chat_open = false
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
          local buf_name = vim.api.nvim_buf_get_name(buf)
          if buf_name:match("AI Chat") then
            chat_open = true
            break
          end
        end
        
        if chat_open then
          close_chat()
        else
          open_chat()
        end
      end
      
      -- Auto-command to respect the global toggle
      vim.api.nvim_create_autocmd("InsertEnter", {
        pattern = "*",
        callback = function()
          if vim.g.ai_autocomplete_enabled then
            vim.cmd("Copilot enable")
          else
            vim.cmd("Copilot disable")
          end
        end,
      })
      
      -- Key mappings
      -- Visual mode: select code and press 'ai' to start chat
      vim.keymap.set('v', 'ai', chat_with_selection, { desc = "AI Chat - Chat with visual selection" })
      
      -- Normal mode mappings
      vim.keymap.set('n', '<leader>ai', open_chat, { desc = "AI Chat - Open chat" })
      vim.keymap.set('n', '<leader>ao', open_chat, { desc = "AI Chat - Open chat" })
      vim.keymap.set('n', '<leader>ac', close_chat, { desc = "AI Chat - Close chat" })
      vim.keymap.set('n', '<leader>at', toggle_chat, { desc = "AI Chat - Toggle chat" })
      
      -- Model selector
      vim.keymap.set('n', '<leader>am', change_ai_model, { desc = "AI Chat - Change AI model" })
      
      -- Toggle AI autocomplete
      vim.keymap.set('n', '<leader>aa', toggle_ai_autocomplete, { desc = "Toggle AI autocomplete" })
      
      -- Predefined prompts that add text to chat
      vim.keymap.set('n', '<leader>ae', function()
        open_chat()
        vim.api.nvim_put({"## Please explain this code:"}, "l", true, true)
      end, { desc = "AI Chat - Explain code" })
      
      vim.keymap.set('n', '<leader>ar', function()
        open_chat()
        vim.api.nvim_put({"## Please review this code for potential issues:"}, "l", true, true)
      end, { desc = "AI Chat - Review code" })
      
      vim.keymap.set('n', '<leader>af', function()
        open_chat()
        vim.api.nvim_put({"## Please fix any issues in this code:"}, "l", true, true)
      end, { desc = "AI Chat - Fix code" })
      
      vim.keymap.set('n', '<leader>ap', function()
        open_chat()
        vim.api.nvim_put({"## Please optimize this code for better performance:"}, "l", true, true)
      end, { desc = "AI Chat - Optimize code" })
      
      vim.keymap.set('n', '<leader>ad', function()
        open_chat()
        vim.api.nvim_put({"## Please generate documentation for this code:"}, "l", true, true)
      end, { desc = "AI Chat - Generate docs" })
      
      vim.keymap.set('n', '<leader>as', function()
        open_chat()
        vim.api.nvim_put({"## Please generate tests for this code:"}, "l", true, true)
      end, { desc = "AI Chat - Generate tests" })
      
      -- Visual mode prompts
      vim.keymap.set('v', '<leader>ae', function()
        chat_with_selection()
        vim.api.nvim_put({"Please explain this code."}, "l", true, true)
      end, { desc = "AI Chat - Explain selection" })
      
      vim.keymap.set('v', '<leader>ar', function()
        chat_with_selection()
        vim.api.nvim_put({"Please review this code for potential issues."}, "l", true, true)
      end, { desc = "AI Chat - Review selection" })
      
      vim.keymap.set('v', '<leader>af', function()
        chat_with_selection()
        vim.api.nvim_put({"Please fix any issues in this code."}, "l", true, true)
      end, { desc = "AI Chat - Fix selection" })
      
      vim.keymap.set('v', '<leader>ap', function()
        chat_with_selection()
        vim.api.nvim_put({"Please optimize this code for better performance."}, "l", true, true)
      end, { desc = "AI Chat - Optimize selection" })
      
      vim.keymap.set('v', '<leader>ad', function()
        chat_with_selection()
        vim.api.nvim_put({"Please generate documentation for this code."}, "l", true, true)
      end, { desc = "AI Chat - Document selection" })
      
      vim.keymap.set('v', '<leader>as', function()
        chat_with_selection()
        vim.api.nvim_put({"Please generate tests for this code."}, "l", true, true)
      end, { desc = "AI Chat - Generate tests for selection" })
    end,
  }
}