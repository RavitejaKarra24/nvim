return {
  "CopilotC-Nvim/CopilotChat.nvim",
  branch = "main",
  dependencies = {
    "zbirenbaum/copilot.lua",
    "nvim-lua/plenary.nvim",
    -- Telescope is optional but nice to have for history/search
    { "nvim-telescope/telescope.nvim", optional = true },
  },
  config = function()
    local ok, chat = pcall(require, "CopilotChat")
    if not ok then return end

    -- Open chat as a right-side vertical pane
    chat.setup({
      window = {
        layout = 'vertical',
        width = 0.4,
        position = 'right',
      },
    })

    local select_mod_ok, select_mod = pcall(require, "CopilotChat.select")
    if not select_mod_ok then return end

    -- Central list of models (edit to match your provider availability)
    local available_models = {
      -- OpenAI / ChatGPT
      "gpt-5", "gpt-5-thinking", "gpt-5-mini", "gpt-4.1", "gpt-4o", "gpt-4o-mini",
      -- Anthropic
      "claude-4", "claude-4.1", "claude-4-opus", "claude-4-thinking", "claude-3.5-sonnet", "claude-3.5-haiku",
      -- xAI (Grok)
      "grok-4", "grok-4-fast", "grok-4-code", "grok-4-mini",
      -- Google (Gemini)
      "gemini-2.5-pro", "gemini-2.5-flash",
    }

    -- Visual selection: prompt then ask about selection
    vim.keymap.set("v", "<leader>aa", function()
      local prompt = vim.fn.input("Ask Copilot: ")
      if not prompt or prompt == "" then return end
      chat.ask(prompt, { selection = select_mod.visual })
    end, { desc = "CopilotChat ask (visual selection)" })

    -- Current buffer: prompt then ask about buffer
    vim.keymap.set("n", "<leader>ab", function()
      local prompt = vim.fn.input("Ask Copilot (buffer): ")
      if not prompt or prompt == "" then return end
      chat.ask(prompt, { selection = select_mod.buffer })
    end, { desc = "CopilotChat ask (current buffer)" })

    -- Toggle chat window
    vim.keymap.set("n", "<leader>ac", function()
      chat.toggle()
    end, { desc = "CopilotChat toggle" })

    -- Open blank chat window to ask random questions
    vim.keymap.set("n", "<leader>ao", function()
      chat.open()
    end, { desc = "CopilotChat open (blank)" })

    -- Prompt for a free-form question (no selection)
    vim.keymap.set("n", "<leader>aq", function()
      local prompt = vim.fn.input("Ask Copilot: ")
      if not prompt or prompt == "" then return end
      chat.ask(prompt)
    end, { desc = "CopilotChat ask (free-form)" })

    -- Quick cycle models
    local current_model_index = 1
    vim.keymap.set("n", "<leader>am", function()
      current_model_index = current_model_index % #available_models + 1
      local new_model = available_models[current_model_index]
      chat.setup({ model = new_model })
      vim.notify("CopilotChat model: " .. new_model)
    end, { desc = "CopilotChat toggle model" })

    -- Telescope-based model picker (normal mode)
    local function open_model_picker()
      local has_telescope, pickers = pcall(require, 'telescope.pickers')
      if has_telescope then
        local finders = require('telescope.finders')
        local conf = require('telescope.config').values
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        pickers.new({}, {
          prompt_title = 'CopilotChat Models',
          finder = finders.new_table({ results = available_models }),
          sorter = conf.generic_sorter({}),
          previewer = nil,
          attach_mappings = function(_, map)
            map({ 'i', 'n' }, '<CR>', function(bufnr)
              local selection = action_state.get_selected_entry()
              actions.close(bufnr)
              if not selection or not selection[1] then return end
              local model = selection[1]
              -- Update current index for cycling
              for i, m in ipairs(available_models) do
                if m == model then current_model_index = i break end
              end
              chat.setup({ model = model })
              vim.notify("CopilotChat model: " .. model)
            end)
            return true
          end,
        }):find()
        return
      end

      -- Fallback: minimal floating list if Telescope is unavailable
      local buf = vim.api.nvim_create_buf(false, true)
      local width = 42
      local height = math.min(#available_models + 2, 20)
      local opts = {
        relative = 'editor',
        width = width,
        height = height,
        col = vim.o.columns - width - 2,
        row = math.floor((vim.o.lines - height) / 2),
        style = 'minimal',
        border = 'rounded',
        title = 'CopilotChat Models',
      }
      local win = vim.api.nvim_open_win(buf, true, opts)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, available_models)
      vim.bo[buf].modifiable = false
      vim.bo[buf].bufhidden = 'wipe'
      local function select_current_line()
        local line = vim.api.nvim_get_current_line()
        if not line or line == '' then return end
        for i, m in ipairs(available_models) do
          if m == line then current_model_index = i break end
        end
        chat.setup({ model = line })
        vim.notify("CopilotChat model: " .. line)
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
      end
      vim.keymap.set('n', '<CR>', select_current_line, { buffer = buf, nowait = true, silent = true })
      vim.keymap.set('n', 'q', function()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
      end, { buffer = buf, nowait = true, silent = true })
    end

    -- Normal-mode keymap to open the picker
    vim.keymap.set("n", "<leader>aM", open_model_picker, { desc = "CopilotChat model picker" })
  end,
}


