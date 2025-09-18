local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
      })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "rose-pine/neovim",
    name = "rose-pine",
    opts = {
      variant = "",
      terminal_colors = true,
      styles = {
        transparency = true,
        italic = false
      }
    }
  },
  {
    'nvim-tree/nvim-tree.lua',
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = {
          side = "right",
        }
      })
    end
  },
  -- LSP Configuration
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      -- Autocompletion
      "hrsh7th/nvim-cmp",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip", -- Required for nvim-cmp snippets
      "saadparwaiz1/cmp_luasnip",
      -- Linting
      "mfussenegger/nvim-lint",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- LSP Servers setup
      -- Configure tsserver for TypeScript and JavaScript
      lspconfig.ts_ls.setup({
        cmd = { "/opt/homebrew/bin/typescript-language-server", "--stdio" },
        -- You can add custom settings here.
        -- For example, to enable formatting on save (requires a formatter like Prettier configured in your project):
         on_attach = function(client, bufnr)
           if client.name == "ts_ls" then
             client.server_capabilities.documentFormattingProvider = true
             vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
               callback = function()
                 vim.lsp.buf.format({ bufnr = bufnr })
               end,
             })
           end
           vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr })
         end,
      })

      lspconfig.tailwindcss.setup({
        cmd = { "/opt/homebrew/bin/tailwindcss-language-server", "--stdio" },
      })

      -- Autocompletion setup with nvim-cmp
      cmp.setup({
        snippet = {
          -- REQUIRED - This tells nvim-cmp how to expand snippets
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(), -- Trigger completion menu
          ['<C-e>'] = cmp.mapping.abort(),        -- Close completion menu
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' }, -- LSP source for language-specific suggestions
          { name = 'luasnip' },  -- Snippet source
        }, {
          { name = 'buffer' },   -- Fallback to buffer words
        })
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    init = function()
      vim.api.nvim_create_autocmd({ "BufWritePost" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
})

vim.opt.number = true
vim.opt.relativenumber = tru
vim.opt.relativenumber = true


vim.cmd.colorscheme("rose-pine")

vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>')
