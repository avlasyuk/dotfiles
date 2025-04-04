-- Based upon https://github.com/nvim-lua/kickstart.nvim/commit/5aeddfdd5d0308506ec63b0e4f8de33e2a39355f

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.termguicolors = true

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.mouse = 'a'

vim.opt.breakindent = true

vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
--vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

vim.opt.cursorline = true

vim.opt.scrolloff = 5

vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
--vim.keymap.set('n', '<leader><space>', ':nohlsearch<CR>', { silent = true })

-- Diagnostic keymaps
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Exit terminal mode
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Highlight when yanking text
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure plugins ]]
local plugins = {
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically

  'tpope/vim-dispatch',

  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      delay = 500,
      -- Document existing key chains
      spec = {
        { '<leader>d', group = '[D]ocument' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>w', group = '[W]orkspace' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
      },
    },
  },

  -- { 'stevearc/overseer.nvim', opts = {} },

  {
    'jpalardy/vim-slime',
    config = function()
      vim.g.slime_target = 'tmux'
      vim.g.slime_python_ipython = 1
    end,
  },

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    branch = '0.1.x',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- [[ Configure Telescope ]]
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          file_ignore_patterns = {
            'node_modules',
          },
          --   mappings = {
          --     i = { ['<c-enter>'] = 'to_fuzzy_refine' },
          --   },
        },
        -- pickers = {}
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sG', function()
        builtin.live_grep {
          additional_args = function(_)
            return { '--case-sensitive' }
          end,
        }
      end, { desc = '[S]earch by [G]rep Case Sensitive' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.keymap.set('n', '<leader>m', builtin.oldfiles, { desc = '[S]earch Recent Files' })

      vim.keymap.set('n', '<leader>o', function()
        builtin.lsp_document_symbols {
          ignore_symbols = {
            'namespace',
            'variable',
            'field',
            'enummember',
            'number',
            'string',
            'boolean',
            'object',
            'array',
            'package',
          },
        }
      end, { desc = 'Toggle outline' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },

  { -- For noice signature help
    'folke/noice.nvim',
    event = 'VeryLazy',
    opts = {
      cmdline = { enabled = false },
      messages = { enabled = false },
      popupmenu = { enabled = false },
      lsp = {
        progress = { enabled = false },
        message = { enabled = false },
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
          ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
          ['vim.lsp.util.stylize_markdown'] = true,
          ['cmp.entry.get_documentation'] = true, -- requires hrsh7th/nvim-cmp
        },
      },
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      'MunifTanjim/nui.nvim',
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      -- 'rcarriga/nvim-notify',
    },
  },

  { -- LSP Configuration & Plugins
    'neovim/nvim-lspconfig',
    -- event = 'VeryLazy',
    dependencies = {
      -- Automatically install LSPs and related tools to stdpath for Neovim
      { 'williamboman/mason.nvim', opts = {} }, -- NOTE: Must be loaded before dependants
      'williamboman/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
      -- used for completion, annotations and signatures of Neovim apis
      { 'folke/neodev.nvim', opts = {} },
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          -- Jump to the definition of the word under your cursor.
          --  This is where a variable was first declared, or where a function is defined, etc.
          --  To jump back, press <C-t>.
          map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')

          -- Find references for the word under your cursor.
          map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

          -- Jump to the implementation of the word under your cursor.
          --  Useful when your language has ways of declaring types without an actual implementation.
          map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

          -- Jump to the type of the word under your cursor.
          --  Useful when you're not sure what type a variable is and you want to see
          --  the definition of its *type*, not where it was *defined*.
          map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

          -- Fuzzy find all the symbols in your current document.
          --  Symbols are things like variables, functions, types, etc.
          map('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')

          -- Fuzzy find all the symbols in your current workspace.
          --  Similar to document symbols, except searches over your entire project.
          map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

          -- Rename the variable under your cursor.
          --  Most Language Servers support renaming across files, etc.
          map('<leader>r', vim.lsp.buf.rename, '[R]ename')

          -- Execute a code action, usually your cursor needs to be on top of an error
          -- or a suggestion from your LSP for this to activate.
          map('<leader>c', vim.lsp.buf.code_action, '[C]ode [A]ction')

          -- Opens a popup that displays documentation about the word under your cursor
          --  See `:help K` for why this keymap.
          map('K', vim.lsp.buf.hover, 'Hover Documentation')

          -- WARN: This is not Goto Definition, this is Goto Declaration.
          --  For example, in C this would take you to the header.
          map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

          -- The following two autocommands are used to highlight references of the
          -- word under your cursor when your cursor rests there for a little while.
          --    See `:help CursorHold` for information about when this is executed
          --
          -- When you move your cursor, the highlights will be cleared (the second autocommand).
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          -- The following autocommand is used to enable inlay hints in your
          -- code, if the language server you are using supports them
          --
          -- This may be unwanted, since they displace some of your code
          if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
            map('<leader>th', function()
              ---@diagnostic disable-next-line: missing-parameter
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
            end, '[T]oggle Inlay [H]ints')
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

      -- Enable the following language servers
      --  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
      --
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        clangd = {},
        ts_ls = {},
        basedpyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = 'standard',
              },
            },
          },
        },
        ruff = {},

        jinja_lsp = {
          filetypes = { 'jinja', 'html' },
        },

        lua_ls = {
          -- cmd = {...},
          -- filetypes = { ...},
          -- capabilities = {},
          settings = {
            Lua = {
              completion = {
                callSnippet = 'Replace',
              },
              -- You can toggle below to ignore Lua_LS's noisy `missing-fields` warnings
              -- diagnostics = { disable = { 'missing-fields' } },
            },
          },
        },
      }

      -- Ensure the servers and tools above are installed
      --  To check the current status of installed tools and/or manually install
      --  other tools, you can run
      --    :Mason
      --
      --  You can press `g?` for help in this menu.
      require('mason').setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        'stylua', -- Used to format Lua code
      })
      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      require('mason-lspconfig').setup {
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
            require('lspconfig')[server_name].setup(server)
          end,
        },
      }
    end,
  },

  -- { 'aserowy/tmux.nvim', opts = {} },

  { -- Autoformat
    'stevearc/conform.nvim',
    lazy = false,
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format { async = true, lsp_fallback = true }
        end,
        mode = '',
        desc = '[F]ormat buffer',
      },
    },
    opts = {
      notify_on_error = true,
      format_on_save = function(bufnr)
        -- Disable "format_on_save lsp_fallback" for languages that don't
        -- have a well standardized coding style. You can add additional
        -- languages here or re-enable it for the disabled ones.
        -- Disable with a global or buffer-local variable
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
          return
        end
        local disable_filetypes = { c = true, cpp = true }
        return {
          timeout_ms = 5000,
          lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
        }
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        cpp = { 'clang-format' },
        -- Conform can also run multiple formatters sequentially
        python = { 'ruff_format' },
        --
        -- You can use a sub-list to tell conform to run *until* a formatter
        -- is found.
        -- javascript = { { "prettierd", "prettier" } },
      },
    },
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      -- Snippet Engine & its associated nvim-cmp source
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          -- Build Step is needed for regex support in snippets.
          -- This step is not supported in many windows environments.
          -- Remove the below condition to re-enable on windows.
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- `friendly-snippets` contains a variety of premade snippets.
          --    See the README about individual language/framework/plugin snippets:
          --    https://github.com/rafamadriz/friendly-snippets
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
      'saadparwaiz1/cmp_luasnip',

      -- Adds other completion capabilities.
      --  nvim-cmp does not ship with all sources by default. They are split
      --  into multiple repos for maintenance purposes.
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      -- 'hrsh7th/cmp-nvim-lsp-signature-help',
    },
    config = function()
      -- See `:help cmp`
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      luasnip.config.setup {}

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },

        completion = {
          completeopt = 'menu,menuone,noinsert',
          keyword_length = 2,
        },

        formatting = {
          expandable_indicator = false,
          fields = { 'abbr', 'menu', 'kind' },
        },

        performance = {
          debounce = 200,
        },

        -- For an understanding of why these mappings were
        -- chosen, you will need to read `:help ins-completion`
        --
        -- No, but seriously. Please read `:help ins-completion`, it is really good!
        mapping = cmp.mapping.preset.insert {
          -- Select the [n]ext item
          ['<C-n>'] = cmp.mapping.select_next_item(),
          -- Select the [p]revious item
          ['<C-p>'] = cmp.mapping.select_prev_item(),

          -- Scroll the documentation window [b]ack / [f]orward
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),

          -- Accept ([y]es) the completion.
          --  This will auto-import if your LSP supports it.
          --  This will expand snippets if the LSP sent a snippet.
          ['<C-y>'] = cmp.mapping.confirm { select = true },

          -- If you prefer more traditional completion keymaps,
          -- you can uncomment the following lines
          ['<CR>'] = cmp.mapping.confirm { select = true },
          --['<Tab>'] = cmp.mapping.select_next_item(),
          --['<S-Tab>'] = cmp.mapping.select_prev_item(),

          -- Manually trigger a completion from nvim-cmp.
          --  Generally you don't need this, because nvim-cmp will display
          --  completions whenever it has completion options available.
          ['<C-Space>'] = cmp.mapping.complete {},

          -- Think of <c-l> as moving to the right of your snippet expansion.
          --  So if you have a snippet that's like:
          --  function $name($args)
          --    $body
          --  end
          --
          -- <c-l> will move you to the right of each of the expansion locations.
          -- <c-h> is similar, except moving you backwards.
          ['<C-l>'] = cmp.mapping(function()
            if luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            end
          end, { 'i', 's' }),
          ['<C-h>'] = cmp.mapping(function()
            if luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            end
          end, { 'i', 's' }),

          -- For more advanced Luasnip keymaps (e.g. selecting choice nodes, expansion) see:
          --    https://github.com/L3MON4D3/LuaSnip?tab=readme-ov-file#keymaps
        },
        sources = {
          {
            name = 'nvim_lsp',
            entry_filter = function(entry)
              return cmp.lsp.CompletionItemKind.Snippet ~= entry:get_kind()
            end,
          },
          -- { name = 'luasnip' },
          { name = 'path' },
          -- { name = 'nvim_lsp_signature_help' },
        },
        experimental = { ghost_text = true },
        matching = { disallow_symbol_nonprefix_matching = true },
      }
    end,
  },

  -- Highlight todo, notes, etc in comments

  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'bash',
        'c',
        'cpp',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'vim',
        'vimdoc',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
      textobjects = {
        swap = {
          enable = true,
          swap_next = {
            ['<leader>a'] = '@parameter.inner',
          },
          swap_previous = {
            ['<leader>A'] = '@parameter.inner',
          },
        },
      },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      -- Prefer git instead of curl in order to improve connectivity in some environments
      require('nvim-treesitter.install').prefer_git = true
      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },

  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

  {
    'nvim-tree/nvim-tree.lua',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
      require('nvim-tree').setup()
    end,
    keys = {
      { '<leader>tt', '<CMD>NvimTreeToggle<CR>', silent = true, desc = 'Toggle file tree' },
    },
  },

  -- [[ Colorscheme ]]
  {
    'sainnhe/everforest',
    priority = 1000,
    init = function()
      vim.cmd.colorscheme 'everforest'
    end,
  },
  -- 'sainnhe/gruvbox-material',
  -- 'sainnhe/edge',
  -- 'sainnhe/sonokai',
  { 'zenbones-theme/zenbones.nvim', dependencies = { 'rktjmp/lush.nvim' } },
  -- 'olimorris/onedarkpro.nvim',
  -- { 'catppuccin/nvim', name = 'catppuccin', priority = 1000 },
  --

  { 'stevearc/dressing.nvim', opts = {} },

  'machakann/vim-sandwich', -- surround

  {
    'nvim-lualine/lualine.nvim',
    dependencies = {
      {
        'linrongbin16/lsp-progress.nvim',
        opts = {},
      },
    },
    config = function()
      require('lualine').setup {
        options = {
          component_separators = '',
          section_separators = '',
          color = 'StatusLineNC',
        },
        sections = {
          lualine_a = {
            {
              'filename',
              path = 1,
            },
          },
          lualine_b = {
            'diagnostics',
          },
          lualine_c = {},
          lualine_x = {
            {
              function()
                return require('lsp-progress').progress()
              end,
            },
            {
              'filetype',
              icons_enabled = false,
            },
          },
        },
        extensions = { 'trouble' },
      }

      vim.api.nvim_create_augroup('lualine_augroup', { clear = true })
      vim.api.nvim_create_autocmd('User', {
        group = 'lualine_augroup',
        pattern = 'LspProgressStatusUpdated',
        callback = require('lualine').refresh,
      })
    end,
  },

  {
    -- Add indentation guides even on blank lines
    'lukas-reineke/indent-blankline.nvim',
    -- Enable `lukas-reineke/indent-blankline.nvim`
    -- See `:help ibl`
    main = 'ibl',
    opts = {
      indent = { char = '▏' },
    },
  },

  {
    'ivanesmantovich/xkbswitch.nvim',
    opts = {},
    enabled = vim.fn.has 'mac' == 1,
    event = { 'FocusGained', 'CmdlineLeave', 'InsertLeave', 'FocusLost', 'InsertEnter' },
  },

  {
    'folke/trouble.nvim',
    enabled = false,
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {},
    keys = {
      {
        '<leader>te',
        '<cmd>Trouble diagnostics toggle<cr>',
        desc = 'Toggle Trouble',
      },
    },
  },
  {
    'Bekaboo/dropbar.nvim',
    -- optional, but required for fuzzy finder support
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    config = function()
      local dropbar_api = require 'dropbar.api'
      vim.keymap.set('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
      vim.keymap.set('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
      vim.keymap.set('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })
    end,
  },
}

local gitsign_arc_dir = nil
for _, dir in ipairs {
  '/Users/avlasyuk/arcadia/junk/a-matveev9/gitsigns.arc.nvim',
  '/home/arc/avlasyuk/arc/arcadia/junk/a-matveev9/gitsigns.arc.nvim',
} do
  if vim.fn.isdirectory(dir) == 1 then
    gitsign_arc_dir = dir
  end
end

local gitsign_opts = {
  -- signs = {
  --   add = { text = '+' },
  --   change = { text = '~' },
  --   delete = { text = '_' },
  --   topdelete = { text = '‾' },
  --   changedelete = { text = '~' },
  -- },
}

if gitsign_arc_dir ~= nil then
  table.insert(plugins, {
    dir = gitsign_arc_dir,
    opts = gitsign_opts,
  })
else
  table.insert(plugins, {
    'lewis6991/gitsigns.nvim',
    opts = gitsign_opts,
  })
end

if not vim.g.vscode then
  require('lazy').setup(plugins, {})

  if vim.fn.has 'gui_running' == 1 then
    vim.o.background = 'light'
    vim.o.guifont = 'JetBrainsMonoNL NFM Light:h13'
    -- vim.o.background = 'dark'
    -- vim.o.guifont = 'JetBrainsMonoNL NFM Thin:h13'
  end

  vim.g.neovide_position_animation_length = 0.00
  vim.g.neovide_cursor_animation_length = 0.00
  vim.g.neovide_cursor_trail_size = 0
  vim.g.neovide_cursor_animate_in_insert_mode = false
  vim.g.neovide_cursor_animate_command_line = false
  vim.g.neovide_scroll_animation_far_lines = 0
  vim.g.neovide_scroll_animation_length = 0.00
  vim.g.neovide_cursor_vfx_mode = ''

  -- vim.api.nvim_create_autocmd('OptionSet', {
  --   pattern = 'background',
  --   callback = function()
  --     if vim.v.option_new == 'light' then
  --       vim.o.guifont = 'JetBrainsMonoNL NFM Light:h13'
  --     else
  --       vim.o.guifont = 'JetBrainsMonoNL NFM Thin:h13'
  --     end
  --   end,
  -- })
end

-- Create a new augroup named "LargeFile"
-- local large_file_group = vim.api.nvim_create_augroup('LargeFile', { clear = true })

-- Add an autocmd to disable features for large files
vim.api.nvim_create_autocmd('BufReadPre', {
  -- group = large_file_group,
  desc = 'Optimize Neovim for large files',
  pattern = '*.json',
  callback = function(args)
    -- Get the file size
    local file = vim.fn.expand(args.file)
    local size = vim.fn.getfsize(file)

    -- If the file size is greater than 1 MB, disable certain features
    if size > 1000000 then
      vim.opt_local.syntax = 'off'
      vim.opt_local.undofile = false
      vim.opt_local.swapfile = false
    end
  end,
})

-- Take me to where I was when last edited a file
vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = '*',
  callback = function()
    local last_pos = vim.api.nvim_buf_get_mark(0, '"')
    local line = last_pos[1]
    local col = last_pos[2]
    if line > 0 and line <= vim.api.nvim_buf_line_count(0) then
      vim.api.nvim_win_set_cursor(0, { line, col })
    end
  end,
})

vim.api.nvim_create_user_command('FormatDisable', function(args)
  if args.bang then
    -- FormatDisable! will disable formatting just for this buffer
    vim.b.disable_autoformat = true
  else
    vim.g.disable_autoformat = true
  end
end, {
  desc = 'Disable autoformat-on-save',
  bang = true,
})
vim.api.nvim_create_user_command('FormatEnable', function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, {
  desc = 'Re-enable autoformat-on-save',
})

vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Helix
vim.keymap.set('n', 'gs', '^', { silent = true, desc = 'Go to first non-blank in line' })
vim.keymap.set('n', 'gl', '$', { silent = true, desc = 'Go to line end' })
vim.keymap.set('n', 'gn', ':bn<CR>', { desc = 'Go to next buffer' })
vim.keymap.set('n', 'gp', ':bp<CR>', { desc = 'Go to previous buffer' })
vim.keymap.set('n', 'mm', '%', { silent = true, desc = 'Go to matching bracket' })

vim.keymap.set('n', '<leader>y', ':let @+=@<CR>', { silent = true, desc = 'Copy yank buffer to clipboard' })
vim.keymap.set('v', '<leader>y', '"+y', { silent = true, desc = 'Yank to clipboard' })

local function open_arcanum_url()
  local filepath = vim.fn.expand '%:p'
  if filepath == '' then
    vim.notify('No file path found!', vim.log.levels.ERROR)
    return
  end

  local dir = vim.fn.fnamemodify(filepath, ':h')
  local arcadia_dir = nil
  while dir and dir ~= '/' do
    if vim.fn.fnamemodify(dir, ':t') == 'arcadia' then
      arcadia_dir = dir
      break
    end
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then
      break
    end
    dir = parent
  end

  if not arcadia_dir then
    vim.notify('Arcadia directory not found in the parent directories.', vim.log.levels.ERROR)
    return
  end

  local relative_path = filepath:sub(#arcadia_dir + 2)
  if relative_path == '' then
    vim.notify('Current file is the arcadia directory itself?', vim.log.levels.ERROR)
    return
  end

  local line_num = vim.api.nvim_win_get_cursor(0)[1]
  local url = string.format('https://a.yandex-team.ru/arcadia/%s#L%d', relative_path, line_num)

  print(url)
end

local function open_file_from_arcanum_url(url)
  -- If no URL is provided, prompt the user.
  if not url or url == '' then
    url = vim.fn.input 'Arcadia URL: '
  end
  if url == '' then
    vim.notify('No URL provided!', vim.log.levels.ERROR)
    return
  end

  -- First, try to capture both the relative path and a line number.
  -- The URL format may be:
  --   https://a.yandex-team.ru/arcadia/<relative_path>[?query]#L<line_number>
  local relative_path, line_str = url:match 'arcadia/([^?#]+)[^#]*#L(%d+)'
  if not relative_path then
    -- No line number provided, so just match the relative path.
    relative_path = url:match 'arcadia/([^?#]+)'
  end

  local line_num = tonumber(line_str) -- May be nil if not provided.

  -- Search upward from the current working directory for a directory named "arcadia".
  local cwd = vim.fn.getcwd()
  local dir = cwd
  local arcadia_dir = nil
  while dir and dir ~= '/' do
    if vim.fn.fnamemodify(dir, ':t') == 'arcadia' then
      arcadia_dir = dir
      break
    end
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then
      break
    end
    dir = parent
  end

  if not arcadia_dir then
    vim.notify("Local 'arcadia' directory not found in parent directories of " .. cwd, vim.log.levels.ERROR)
    return
  end

  local local_file = arcadia_dir .. '/' .. relative_path

  if vim.fn.filereadable(local_file) == 0 then
    vim.notify('File not found: ' .. local_file, vim.log.levels.ERROR)
    return
  end

  -- Open the file.
  vim.cmd('edit ' .. vim.fn.fnameescape(local_file))

  if line_num then
    local total_lines = vim.api.nvim_buf_line_count(0)
    if line_num > total_lines then
      line_num = total_lines
    end
    vim.api.nvim_win_set_cursor(0, { line_num, 0 })
  end
end

vim.keymap.set('n', '<leader>a', open_arcanum_url, { noremap = true, silent = true })

vim.api.nvim_create_user_command('ArcanumOpen', function(opts)
  open_file_from_arcanum_url(opts.args)
end, { nargs = '?' })

vim.g.telescope_gtest_config = {
  root_dir = nil,
}
require('telescope').load_extension 'gtest'
vim.keymap.set('n', '<leader>st', '<cmd>Telescope gtest<CR>', { desc = 'Find Google Tests' })
vim.keymap.set('n', '<leader>gr', '<cmd>Telescope run_gtest<CR>', { desc = 'Run Google Test' })

require('telescope').load_extension 'endpoints'
vim.keymap.set('n', '<leader>sy', '<cmd>Telescope endpoints<CR>', { desc = 'Find Yacare Routes' })

vim.diagnostic.config { virtual_text = true }

-- vim: ts=2 sts=2 sw=2 et
