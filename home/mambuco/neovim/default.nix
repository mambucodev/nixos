{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      nil
      lua-language-server
      typescript-language-server
      vscode-langservers-extracted
      ripgrep
      fd
    ];

    plugins = with pkgs.vimPlugins; [
      nvim-treesitter.withAllGrammars
      plenary-nvim
      telescope-nvim
      telescope-fzf-native-nvim
      nvim-lspconfig
      nvim-cmp
      cmp-nvim-lsp
      cmp-buffer
      cmp-path
      luasnip
      cmp_luasnip
      lualine-nvim
      nvim-web-devicons
      gitsigns-nvim
      which-key-nvim
    ];

    initLua = ''
      vim.g.mapleader = " "
      vim.g.maplocalleader = " "

      local o = vim.opt
      o.number = true
      o.relativenumber = true
      o.expandtab = true
      o.shiftwidth = 2
      o.tabstop = 2
      o.softtabstop = 2
      o.smartindent = true
      o.wrap = false
      o.ignorecase = true
      o.smartcase = true
      o.termguicolors = true
      o.signcolumn = "yes"
      o.updatetime = 300
      o.scrolloff = 8
      o.clipboard = "unnamedplus"
      o.undofile = true
      o.splitright = true
      o.splitbelow = true
      o.mouse = "a"

      vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
      vim.keymap.set("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
      vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")

      -- nvim-treesitter's main-branch rewrite dropped `nvim-treesitter.configs`.
      -- Grammars come from Nix (withAllGrammars) on the runtimepath and filetypes
      -- self-register via the plugin's plugin/filetypes.lua, so just start
      -- highlighting + treesitter indent per buffer (pcall skips fts with no parser).
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })

      local telescope = require("telescope")
      telescope.setup({})
      pcall(telescope.load_extension, "fzf")
      local tb = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", tb.find_files, { desc = "Find files" })
      vim.keymap.set("n", "<leader>fg", tb.live_grep,  { desc = "Live grep" })
      vim.keymap.set("n", "<leader>fb", tb.buffers,    { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", tb.help_tags,  { desc = "Help" })

      require("lualine").setup({ options = { globalstatus = true } })
      require("gitsigns").setup()
      require("which-key").setup()

      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"]      = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]     = cmp.mapping.select_next_item(),
          ["<S-Tab>"]   = cmp.mapping.select_prev_item(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })

      local caps = require("cmp_nvim_lsp").default_capabilities()

      -- nvim-lspconfig 2.x deprecated the require("lspconfig")[server].setup()
      -- framework; use Neovim 0.11's native vim.lsp.config/enable. lspconfig now
      -- only ships the per-server lsp/*.lua defaults that vim.lsp.enable reads.
      vim.lsp.config("*", { capabilities = caps })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(ev)
          local map = function(k, fn, desc)
            vim.keymap.set("n", k, fn, { buffer = ev.buf, desc = desc })
          end
          map("gd",         vim.lsp.buf.definition,  "Go to definition")
          map("gr",         vim.lsp.buf.references,  "References")
          map("K",          vim.lsp.buf.hover,       "Hover")
          map("<leader>rn", vim.lsp.buf.rename,      "Rename")
          map("<leader>ca", vim.lsp.buf.code_action, "Code action")
          map("<leader>f",  function() vim.lsp.buf.format({ async = true }) end, "Format")
        end,
      })

      vim.lsp.enable({ "nil_ls", "lua_ls", "ts_ls", "jsonls", "html", "cssls" })
    '';
  };
}
