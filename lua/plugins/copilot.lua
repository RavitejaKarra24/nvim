return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      panel = { enabled = false },
      suggestion = {
        enabled = true,
        auto_trigger = true,
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

    -- Toggle Copilot suggestion auto trigger
    vim.keymap.set("n", "<leader>at", function()
      local ok, suggestion = pcall(require, "copilot.suggestion")
      if not ok then return end
      suggestion.toggle_auto_trigger()
      local status = suggestion.is_auto_trigger_enabled and suggestion.is_auto_trigger_enabled() and "enabled" or "disabled"
      vim.notify("Copilot suggestions " .. status)
    end, { desc = "Toggle Copilot suggestions" })
  end,
}


