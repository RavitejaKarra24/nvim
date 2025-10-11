return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    vim.g.ai_mode_enabled = vim.g.ai_mode_enabled or false

    local function set_ai_mode(enabled)
      vim.g.ai_mode_enabled = enabled

      local suggestion_ok, suggestion = pcall(require, "copilot.suggestion")
      if suggestion_ok then
        local is_enabled = suggestion.is_auto_trigger_enabled and suggestion.is_auto_trigger_enabled()
        if enabled then
          if suggestion.enable_auto_trigger then
            suggestion.enable_auto_trigger()
          elseif suggestion.toggle_auto_trigger and not is_enabled then
            suggestion.toggle_auto_trigger()
          end
        else
          if suggestion.disable_auto_trigger then
            suggestion.disable_auto_trigger()
          elseif suggestion.toggle_auto_trigger and is_enabled then
            suggestion.toggle_auto_trigger()
          end
          if suggestion.dismiss then suggestion.dismiss() end
        end
      end

      local cmp_ok, cmp = pcall(require, "cmp")
      if cmp_ok then
        if enabled and cmp.abort then
          cmp.abort()
        end
      end

      local status_msg
      if enabled then
        status_msg = "Copilot AI mode enabled (LSP completions disabled)"
      else
        status_msg = "Copilot AI mode disabled (LSP completions enabled)"
      end
      vim.notify(status_msg)
    end

    require("copilot").setup({
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = false,
        debounce = 75,
        keymap = {
          accept = "<M-l>",
          accept_word = "<M-w>",
          accept_line = "<M-d>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        markdown = true,
        help = true,
        gitcommit = true,
        ["."] = true,
      },
    })

    -- Toggle Copilot exclusive AI mode
    vim.keymap.set("n", "<leader>ai", function()
      set_ai_mode(not vim.g.ai_mode_enabled)
    end, { desc = "Toggle Copilot AI mode" })
  end,
}


