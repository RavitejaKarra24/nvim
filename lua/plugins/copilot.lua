return {
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
      
      -- Function to check if AI autocomplete should be enabled
      local function should_enable_copilot()
        return vim.g.ai_autocomplete_enabled ~= false
      end
      
      -- Auto-command to respect the global toggle
      vim.api.nvim_create_autocmd("InsertEnter", {
        pattern = "*",
        callback = function()
          if should_enable_copilot() then
            vim.cmd("Copilot enable")
          else
            vim.cmd("Copilot disable")
          end
        end,
      })
    end,
  }
}