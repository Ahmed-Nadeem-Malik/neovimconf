-- Leader configuration
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- Ensure Mason installs are on PATH for tooling invoked from Neovim
if vim.fs and vim.fn then
  local mason_bin = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'bin')
  if vim.fn.isdirectory(mason_bin) == 1 then
    local path_sep = package.config:sub(1, 1) == '\\' and ';' or ':'
    if not vim.env.PATH or not vim.env.PATH:find(mason_bin, 1, true) then
      vim.env.PATH = mason_bin .. path_sep .. (vim.env.PATH or '')
    end
  end
end

-- Prefer the local venv for Python plugins if available
local py_host = vim.fn.expand '~/.config/nvim/venv/bin/python'
if vim.fn.executable(py_host) == 1 then
  vim.g.python3_host_prog = py_host
end

if vim.g.neovide or vim.g.goneovim then
  vim.o.guifont = 'FiraCode Nerd Font Mono:h15:liga=0'
end

vim.schedule(function()
  vim.o.clipboard = 'unnamedplus'
end)

local opt = vim.opt
opt.number = true
opt.relativenumber = true
opt.mouse = 'a'
opt.showmode = false
opt.list = true
opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
opt.expandtab = true
opt.shiftwidth = 4
opt.tabstop = 4
opt.softtabstop = 4
opt.breakindent = true
opt.signcolumn = 'yes'
opt.ignorecase = true
opt.smartcase = true
opt.updatetime = 250
opt.timeoutlen = 300
opt.splitright = true
opt.splitbelow = true
opt.inccommand = 'split'
opt.cursorline = true
opt.scrolloff = 10
opt.confirm = true
opt.termguicolors = true
opt.undofile = true
local undo_dir = vim.fn.stdpath 'state' .. '/undo'
opt.undodir = undo_dir
vim.fn.mkdir(undo_dir, 'p')

local map = vim.keymap.set
map('n', '<leader>n', '<cmd>Ex<CR>', { desc = 'Open explorer' })
map('n', '<Esc>', '<cmd>nohlsearch<CR>')
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostic list' })
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
map('n', '<leader>wh', '<C-w>h', { desc = 'Window left' })
map('n', '<leader>wl', '<C-w>l', { desc = 'Window right' })
map('n', '<leader>wj', function()
  vim.cmd.wincmd 'j'
end, { desc = 'Window down' })
map('n', '<leader>wk', function()
  vim.cmd.wincmd 'k'
end, { desc = 'Window up' })

vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    'NMAC427/guess-indent.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    config = true,
  },

  {
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
    },
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    ft = { 'markdown' },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-tree/nvim-web-devicons',
    },
    opts = {
      completions = { lsp = { enabled = true } },
    },
  },

  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      delay = 0,
      icons = {
        mappings = vim.g.have_nerd_font,
        keys = vim.g.have_nerd_font and {} or {
          Up = '<Up> ',
          Down = '<Down> ',
          Left = '<Left> ',
          Right = '<Right> ',
          C = '<C-…> ',
          M = '<M-…> ',
          D = '<D-…> ',
          S = '<S-…> ',
          CR = '<CR> ',
          Esc = '<Esc> ',
          ScrollWheelDown = '<ScrollWheelDown> ',
          ScrollWheelUp = '<ScrollWheelUp> ',
          NL = '<NL> ',
          BS = '<BS> ',
          Space = '<Space> ',
          Tab = '<Tab> ',
          F1 = '<F1>',
          F2 = '<F2>',
          F3 = '<F3>',
          F4 = '<F4>',
          F5 = '<F5>',
          F6 = '<F6>',
          F7 = '<F7>',
          F8 = '<F8>',
          F9 = '<F9>',
          F10 = '<F10>',
          F11 = '<F11>',
          F12 = '<F12>',
        },
      },
      spec = {
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
    config = function(_, opts)
      require('which-key').setup(opts)
      vim.api.nvim_set_hl(0, 'WhichKeyNormal', { link = 'Normal' })
    end,
  },

  {
    'nvim-telescope/telescope.nvim',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      'nvim-telescope/telescope-ui-select.nvim',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local telescope = require 'telescope'
      telescope.setup {
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      map('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      map('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      map('n', '<leader>sb', builtin.buffers, { desc = '[S]earch [B]uffers' })
      map('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      map('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      map('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      map('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
      map('n', '<leader>/', function()
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = 'Fuzzy search buffer' })
    end,
  },

  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',
      { 'j-hui/fidget.nvim', opts = {} },
    },
    config = function()
      local augroup = vim.api.nvim_create_augroup('lsp-attach', { clear = true })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = augroup,
        callback = function(event)
          local buf = event.buf
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if not client then
            return
          end

          if client.name == 'ts_ls' then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
          end

          local function bufmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc })
          end

          bufmap('n', 'grn', vim.lsp.buf.rename, 'LSP rename')
          bufmap({ 'n', 'x' }, 'gra', vim.lsp.buf.code_action, 'LSP code action')
          bufmap('n', 'grd', require('telescope.builtin').lsp_definitions, 'LSP definition')
          bufmap('n', 'grD', vim.lsp.buf.declaration, 'LSP declaration')
          bufmap('n', 'gri', require('telescope.builtin').lsp_implementations, 'LSP implementation')
          bufmap('n', 'grr', require('telescope.builtin').lsp_references, 'LSP references')
          bufmap('n', 'grt', require('telescope.builtin').lsp_type_definitions, 'LSP type definitions')
          bufmap('n', 'gO', require('telescope.builtin').lsp_document_symbols, 'LSP document symbols')
          bufmap('n', 'gW', require('telescope.builtin').lsp_dynamic_workspace_symbols, 'LSP workspace symbols')
          bufmap('n', 'K', vim.lsp.buf.hover, 'LSP hover')
          bufmap('n', '<C-k>', vim.lsp.buf.signature_help, 'LSP signature help')
          bufmap('n', '<leader>co', function()
            vim.lsp.buf.code_action {
              context = { only = { 'source.organizeImports' }, diagnostics = {} },
              apply = true,
            }
          end, 'Organize imports')

          if client.server_capabilities.documentHighlightProvider then
            local highlight_group = vim.api.nvim_create_augroup('lsp-highlight-' .. buf, { clear = true })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              group = highlight_group,
              buffer = buf,
              callback = vim.lsp.buf.document_highlight,
            })
            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              group = highlight_group,
              buffer = buf,
              callback = vim.lsp.buf.clear_references,
            })
          end

          if client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            bufmap('n', '<leader>th', function()
              local enabled = vim.lsp.inlay_hint.is_enabled { bufnr = buf }
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = buf })
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      vim.diagnostic.config {
        severity_sort = true,
        float = { border = 'rounded', source = 'if_many' },
        underline = { severity = vim.diagnostic.severity.ERROR },
        virtual_text = { source = 'if_many', spacing = 2 },
        signs = vim.g.have_nerd_font and {
          text = {
            [vim.diagnostic.severity.ERROR] = '󰅚 ',
            [vim.diagnostic.severity.WARN] = '󰀪 ',
            [vim.diagnostic.severity.INFO] = '󰋽 ',
            [vim.diagnostic.severity.HINT] = '󰌶 ',
          },
        } or {},
      }

      local ok, blink = pcall(require, 'blink.cmp')
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      if ok then
        capabilities = blink.get_lsp_capabilities()
      end

      local servers = {
        clangd = {},
        basedpyright = {
          settings = {
            python = {
              analysis = {
                -- options: "off" | "basic" | "standard" | "recommended" | "strict" | "all"
                typeCheckingMode = 'off',
                diagnosticMode = 'openFilesOnly',
                -- optional: quiet specific rules
                diagnosticSeverityOverrides = {
                  reportAny = 'none', -- allow Any
                  -- reportUnknownVariableType = "warning",
                },
              },
            },
          },
        },
        ts_ls = {
          settings = {
            typescript = { format = { enable = false } },
            javascript = { format = { enable = false } },
          },
        },
        html = {},
        cssls = {},
        jsonls = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              diagnostics = { globals = { 'vim' } },
            },
          },
        },
      }

      require('mason-tool-installer').setup {
        ensure_installed = {
          'stylua',
          'black',
          'isort',
          'ruff',
          'prettierd',
          'eslint_d',
          'typescript-language-server',
          'clang-format',
        },
        auto_update = false,
        run_on_start = true,
      }

      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_format = 'fallback' }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = {}
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        end
        return { timeout_ms = 1000, lsp_format = 'fallback' }
      end,
      formatters = {
        prettierd = {
          env = {
            PRETTIERD_DEFAULT_CONFIG = vim.fn.expand '~/.config/prettier/.prettierrc.json',
          },
        },
      },
      formatters_by_ft = {
        lua = { 'stylua' },
        python = { 'isort', 'black' },
        html = { 'prettierd' },
        css = { 'prettierd' },
        json = { 'prettierd' },
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        c = { 'clang-format' },
        cpp = { 'clang-format' },
      },
    },
  },

  {
    'mfussenegger/nvim-lint',
    event = { 'BufWritePost', 'BufReadPost', 'InsertLeave' },
    config = function()
      local lint = require 'lint'
      local has_eslint_d = vim.fn.executable 'eslint_d' == 1
      local eslint = has_eslint_d and 'eslint_d' or 'eslint'

      lint.linters_by_ft = {
        python = { 'ruff' },
        javascript = { eslint },
        javascriptreact = { eslint },
        typescript = { eslint },
        typescriptreact = { eslint },
      }

      local eslint_config_files = {
        '.eslintrc',
        '.eslintrc.json',
        '.eslintrc.js',
        '.eslintrc.cjs',
        '.eslintrc.mjs',
        '.eslintrc.yaml',
        '.eslintrc.yml',
        'eslint.config.js',
        'eslint.config.cjs',
        'eslint.config.mjs',
        'eslint.config.ts',
        'eslint.config.cts',
        'eslint.config.mts',
        'eslint.config.json',
        'package.json',
      }

      local function has_eslint_config(ctx)
        local filename = ctx and ctx.filename or ''
        if not filename or filename == '' then
          return false
        end

        local dirname = vim.fs.dirname(filename)
        if not dirname then
          return false
        end

        local found = vim.fs.find(eslint_config_files, { path = dirname, upward = true })
        for _, path in ipairs(found) do
          if vim.fs.basename(path) ~= 'package.json' then
            return true
          end

          local ok, content = pcall(vim.fn.readfile, path)
          if ok then
            local parsed_ok, data = pcall(vim.json.decode, table.concat(content, '\n'))
            if parsed_ok and type(data) == 'table' then
              if data.eslintConfig ~= nil then
                return true
              end

              local dep_sections = {
                data.dependencies,
                data.devDependencies,
                data.peerDependencies,
                data.optionalDependencies,
              }

              for _, deps in ipairs(dep_sections) do
                if type(deps) == 'table' then
                  for name, _ in pairs(deps) do
                    if name == 'eslint' or name:match '^eslint%-' or name:match '^@eslint/' then
                      return true
                    end
                  end
                end
              end
            end
          end
        end

        return false
      end

      for _, name in ipairs { 'eslint_d', 'eslint' } do
        local linter = lint.linters[name]
        if linter then
          linter.condition = has_eslint_config
        end
      end

      if lint.linters.flake8 then
        lint.linters.flake8.args = { '--max-line-length=120' }
      end

      vim.api.nvim_create_autocmd({ 'BufWritePost', 'BufReadPost', 'InsertLeave' }, {
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },

  {
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        opts = {},
      },
      'folke/lazydev.nvim',
    },
    opts = {
      keymap = { preset = 'super-tab' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
        trigger = { show_in_snippet = false },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'lazydev' },
        providers = {
          lazydev = { module = 'lazydev.integrations.blink', score_offset = 100 },
        },
      },
      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },

  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    cmd = 'Neotree',
    keys = {
      { '<leader>e', ':Neotree toggle<CR>', desc = 'Toggle File Explorer' },
      { '<leader>E', ':Neotree reveal<CR>', desc = 'Reveal Current File' },
    },
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
      window = {
        width = 30,
        mappings = {
          ['<space>'] = 'toggle_node',
          ['<cr>'] = 'open',
          ['o'] = 'open',
          ['S'] = 'split_with_window_picker',
          ['s'] = 'vsplit_with_window_picker',
          ['h'] = 'close_node',
          ['l'] = 'open',
        },
      },
    },
  },

  {
    'folke/todo-comments.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-lua/plenary.nvim' },
    opts = { signs = false },
  },

  {
    'echasnovski/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'python',
        'javascript',
        'typescript',
        'tsx',
        'json',
        'html',
        'css',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
      },
      auto_install = true,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = {},
      },
      indent = { enable = true },
    },
  },

  {
    'scottmckendry/cyberdream.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('cyberdream').setup {
        variant = 'default',
        transparent = true,
        bold = true,
        italic = false,
        underline = true,
        borderless_pickers = false,
      }
      vim.cmd.colorscheme 'cyberdream'
    end,
  },
}, {
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '*.h',
  callback = function()
    if vim.fn.search([[\v(class|namespace|std::)]], 'nw') > 0 then
      vim.bo.filetype = 'cpp'
    end
  end,
})
