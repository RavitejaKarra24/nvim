return {
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
      'L3MON4D3/LuaSnip',
    },
    config = function()
      -- Keymaps and LSP on_attach
      local function on_attach(client, bufnr)
        local opts = {buffer = bufnr}

        -- Go to definition of symbol under cursor
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
        -- Show hover information of symbol under cursor
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        -- Search for symbol in workspace
        vim.keymap.set('n', '<leader>vws', vim.lsp.buf.workspace_symbol, opts)
        -- Show diagnostics in a floating window
        vim.keymap.set('n', '<leader>vd', vim.diagnostic.open_float, opts)
        -- Copy diagnostic to clipboard
        vim.keymap.set('n', '<leader>vc', function()
            local bufnr0 = 0
            local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1
            local diagnostics = vim.diagnostic.get(bufnr0, { lnum = lnum })
            local diagnostic = diagnostics and diagnostics[1] or nil
            if diagnostic and diagnostic.message then
                vim.fn.setreg('+', diagnostic.message)
                print("Diagnostic copied to clipboard!")
            else
                print("No diagnostic message at current line")
            end
        end, opts)
        -- shows all diagnostics in a list
        vim.keymap.set('n', '<leader>va', function()
            local diagnostics = vim.diagnostic.get(0)
            if #diagnostics == 0 then
                print("No diagnostics found")
                return
            end

            local lines = {}
            for _, d in ipairs(diagnostics) do
                table.insert(lines, d.message)
            end

            local all_diagnostics = table.concat(lines, "\n")
            vim.fn.setreg('+', all_diagnostics)
            print("All diagnostics copied to clipboard!")
        end, opts)
        -- Jump to next diagnostic
        vim.keymap.set('n', '[d', vim.diagnostic.goto_next, opts)
        -- Jump to previous diagnostic
        vim.keymap.set('n', ']d', vim.diagnostic.goto_prev, opts)
        -- Show code actions available at cursor position
        vim.keymap.set('n', '<leader>vca', vim.lsp.buf.code_action, opts)
        -- Show references of symbol under cursor
        vim.keymap.set('n', '<leader>vrr', vim.lsp.buf.references, opts)
        -- Rename symbol under cursor
        vim.keymap.set('n', '<leader>vrn', vim.lsp.buf.rename, opts)
        -- Show signature help while typing in insert mode
        vim.keymap.set('i', '<C-h>', vim.lsp.buf.signature_help, opts)
      end

      -- Capabilities for nvim-cmp
      local capabilities = require('cmp_nvim_lsp').default_capabilities()

      -- Mason setup
      require('mason').setup()
      require('mason-lspconfig').setup({
        ensure_installed = {'ts_ls', 'rust_analyzer', 'lua_ls'},
        automatic_installation = true,
        handlers = {
          function(server)
            local opts = {
              capabilities = capabilities,
              on_attach = on_attach,
            }
            if server == 'lua_ls' then
              opts.settings = {
                Lua = {
                  runtime = { version = 'LuaJIT' },
                  diagnostics = { globals = {'vim'} },
                  workspace = { library = vim.api.nvim_get_runtime_file("", true) },
                }
              }
            end
            vim.lsp.config(server, opts)
            vim.lsp.enable(server)
          end,
        },
      })

      -- CMP setup with error handling
      local function safe_require(module)
        local ok, result = pcall(require, module)
        if ok then return result end
        return nil
      end

      local function make_safe_fn(fn, ...)
        local args = {...}
        return function()
          return fn(unpack(args))
        end
      end

      local ok, cmp = pcall(require, 'cmp')
      if not ok then
        vim.notify('Failed to load nvim-cmp: ' .. cmp, vim.log.levels.ERROR)
        return
      end

      -- Add missing functions to api module if it exists
      local api = safe_require('cmp.utils.api')
      if api and not api.apply_text_edits then
        api.apply_text_edits = function(edits, bufnr, encoding)
          for _, edit in ipairs(edits) do
            local start_line = edit.range.start.line
            local start_char = edit.range.start.character
            local end_line = edit.range["end"].line
            local end_char = edit.range["end"].character

            vim.api.nvim_buf_set_text(
              bufnr,
              start_line,
              start_char,
              end_line,
              end_char,
              vim.split(edit.newText, "\n")
            )
          end
        end
      end

      -- Patch source.lua if it exists
      local source = safe_require("cmp.source")
      if source and not source.safe then
        source.safe = make_safe_fn
      end

      -- Setup completion
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-y>'] = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
          ['<C-Space>'] = cmp.mapping.complete(),
        }),
        sources = {
          {name = 'nvim_lsp'},
          {name = 'luasnip'},
          {name = 'buffer'},
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        experimental = { ghost_text = true },
        formatting = {
          fields = {'abbr', 'kind', 'menu'},
          format = function(entry, item)
            item.menu = ({ nvim_lsp = "[LSP]", luasnip = "[Snippet]", buffer = "[Buffer]" })[entry.source.name]
            return item
          end,
        },
      })
    end,
  },
}

