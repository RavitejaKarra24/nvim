return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    dependencies = {
      { "github/copilot.vim" }, -- or zbirenbaum/copilot.lua
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    build = "make tiktoken", -- Only on MacOS or Linux
    opts = {
      -- See Configuration section for options
    },
    config = function(_, opts)
      local chat = require("CopilotChat")
      local select = require("CopilotChat.select")
      
      -- Configure for Gemini API
      chat.setup(vim.tbl_deep_extend("force", opts, {
        debug = false, -- Enable debugging
        
        -- Model configuration for Gemini
        model = "gpt-4", -- Default model, will be overridden
        
        -- Custom API configuration
        api_key_cmd = "echo $GEMINI_API_KEY", -- You'll need to set this environment variable
        
        -- Chat window configuration - using a floating window instead of sidebar
        window = {
          layout = 'float', -- 'vertical', 'horizontal', 'float', 'replace'
          width = 0.5,      -- fractional width of parent, or absolute width in columns when > 1
          height = 0.5,     -- fractional height of parent, or absolute height in rows when > 1
          -- Options below only apply to floating windows
          relative = 'editor', -- 'editor', 'win', 'cursor', 'mouse'
          border = 'single',   -- 'none', single', 'double', 'rounded', 'solid', 'shadow'
          row = nil,           -- row position of the window, default is centered
          col = nil,           -- column position of the window, default is centered
          title = 'Copilot Chat', -- title of chat window
          footer = nil,        -- footer of chat window
          zindex = 1,          -- determines if window is on top or below other floating windows
        },
        
        -- Chat configuration
        question_header = '## User ', -- Header to use for user questions
        answer_header = '## Copilot ', -- Header to use for AI answers
        error_header = '## Error ', -- Header to use for errors
        separator = '───', -- Separator to use in chat
        
        -- Default prompts
        prompts = {
          Explain = {
            prompt = '/COPILOT_EXPLAIN Write an explanation for the active selection as paragraphs of text.',
          },
          Review = {
            prompt = '/COPILOT_REVIEW Review the selected code.',
            callback = function(response, source)
              -- Handle response
            end,
          },
          Fix = {
            prompt = '/COPILOT_GENERATE There is a problem in this code. Rewrite the code to show it with the bug fixed.',
          },
          Optimize = {
            prompt = '/COPILOT_GENERATE Optimize the selected code to improve performance and readablilty.',
          },
          Docs = {
            prompt = '/COPILOT_GENERATE Please add documentation comment for the selection.',
          },
          Tests = {
            prompt = '/COPILOT_GENERATE Please generate tests for my code.',
          },
          FixDiagnostic = {
            prompt = 'Please assist with the following diagnostic issue in file:',
            selection = select.diagnostics,
          },
          Commit = {
            prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
            selection = select.gitdiff,
          },
          CommitStaged = {
            prompt = 'Write commit message for the change with commitizen convention. Make sure the title has maximum 50 characters and message is wrapped at 72 characters. Wrap the whole message in code block with language gitcommit.',
            selection = function(source)
              return select.gitdiff(source, true)
            end,
          },
        },
      }))
      
      -- Global variable to track AI autocomplete state
      vim.g.ai_autocomplete_enabled = true
      
      -- Global variable to track current model
      vim.g.current_ai_model = "gemini-pro"
      
      -- Function to toggle AI autocomplete
      local function toggle_ai_autocomplete()
        vim.g.ai_autocomplete_enabled = not vim.g.ai_autocomplete_enabled
        local status = vim.g.ai_autocomplete_enabled and "enabled" or "disabled"
        print("AI autocomplete " .. status)
        
        -- You can extend this to actually disable/enable copilot suggestions
        if vim.g.ai_autocomplete_enabled then
          vim.cmd("Copilot enable")
        else
          vim.cmd("Copilot disable")
        end
      end
      
      -- Function to change AI model
      local function change_ai_model()
        local models = {
          "gemini-pro",
          "gpt-4",
          "gpt-3.5-turbo",
          "claude-3-opus",
          "claude-3-sonnet"
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
            -- Here you would typically reconfigure the chat with the new model
            -- This would require custom implementation to switch the backend
          end
        end)
      end
      
      -- Key mappings
      -- Visual mode: select code and press 'ai' to start chat
      vim.keymap.set('v', 'ai', function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          require("CopilotChat").ask(input, { selection = require("CopilotChat.select").visual })
        end
      end, { desc = "CopilotChat - Quick chat with visual selection" })
      
      -- Normal mode mappings
      vim.keymap.set('n', '<leader>ai', function()
        local input = vim.fn.input("Quick Chat: ")
        if input ~= "" then
          require("CopilotChat").ask(input)
        end
      end, { desc = "CopilotChat - Quick chat" })
      
      -- Open chat window
      vim.keymap.set('n', '<leader>ao', '<cmd>CopilotChatOpen<cr>', { desc = "CopilotChat - Open chat window" })
      
      -- Close chat window
      vim.keymap.set('n', '<leader>ac', '<cmd>CopilotChatClose<cr>', { desc = "CopilotChat - Close chat window" })
      
      -- Toggle chat window
      vim.keymap.set('n', '<leader>at', '<cmd>CopilotChatToggle<cr>', { desc = "CopilotChat - Toggle chat window" })
      
      -- Model selector
      vim.keymap.set('n', '<leader>am', change_ai_model, { desc = "CopilotChat - Change AI model" })
      
      -- Toggle AI autocomplete
      vim.keymap.set('n', '<leader>aa', toggle_ai_autocomplete, { desc = "Toggle AI autocomplete" })
      
      -- Predefined prompts
      vim.keymap.set('n', '<leader>ae', '<cmd>CopilotChatExplain<cr>', { desc = "CopilotChat - Explain code" })
      vim.keymap.set('n', '<leader>ar', '<cmd>CopilotChatReview<cr>', { desc = "CopilotChat - Review code" })
      vim.keymap.set('n', '<leader>af', '<cmd>CopilotChatFix<cr>', { desc = "CopilotChat - Fix code" })
      vim.keymap.set('n', '<leader>ap', '<cmd>CopilotChatOptimize<cr>', { desc = "CopilotChat - Optimize code" })
      vim.keymap.set('n', '<leader>ad', '<cmd>CopilotChatDocs<cr>', { desc = "CopilotChat - Generate docs" })
      vim.keymap.set('n', '<leader>as', '<cmd>CopilotChatTests<cr>', { desc = "CopilotChat - Generate tests" })
      
      -- Visual mode prompts
      vim.keymap.set('v', '<leader>ae', '<cmd>CopilotChatExplain<cr>', { desc = "CopilotChat - Explain selection" })
      vim.keymap.set('v', '<leader>ar', '<cmd>CopilotChatReview<cr>', { desc = "CopilotChat - Review selection" })
      vim.keymap.set('v', '<leader>af', '<cmd>CopilotChatFix<cr>', { desc = "CopilotChat - Fix selection" })
      vim.keymap.set('v', '<leader>ap', '<cmd>CopilotChatOptimize<cr>', { desc = "CopilotChat - Optimize selection" })
      vim.keymap.set('v', '<leader>ad', '<cmd>CopilotChatDocs<cr>', { desc = "CopilotChat - Document selection" })
      vim.keymap.set('v', '<leader>as', '<cmd>CopilotChatTests<cr>', { desc = "CopilotChat - Generate tests for selection" })
    end,
  }
}