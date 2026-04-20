-- ~/.config/nvim/init.lua

vim.g.mapleader = " "

-- podstawowe opcje
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.scrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.clipboard = "unnamedplus"
vim.opt.termguicolors = true

-- auto-twórz katalogi przy zapisie
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function(event)
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- skróty dla Obsidian workflow
vim.keymap.set("n", "<leader>p", ":!pandoc % -o %.html -s<CR>", { desc = "Pandoc → HTML" })
vim.keymap.set("n", "<leader>f", "<CMD>Oil<CR>",                 { desc = "Przeglądarka plików (oil)" })
vim.keymap.set("n", "<leader>w", ":w<CR>",                       { desc = "Zapisz" })
vim.keymap.set("n", "<leader>q", ":q<CR>",                       { desc = "Zamknij" })

-- nawigacja w trybie wrap
vim.keymap.set("n", "j", "gj")
vim.keymap.set("n", "k", "gk")

-- oil.nvim bootstrap
local oil_path = vim.fn.stdpath("data") .. "/oil"
if not vim.loop.fs_stat(oil_path .. "/lua/oil") then
  vim.fn.system({
    "git", "clone", "--depth=1",
    "https://github.com/stevearc/oil.nvim",
    oil_path
  })
end
vim.opt.rtp:prepend(oil_path)

require("oil").setup({
  default_file_explorer = true,
  delete_to_trash = false,
  view_options = { show_hidden = false },
  keymaps = {
    ["<CR>"] = "actions.select",
  },
  win_options = {},
})

-- otwórz png/jpg/pdf zewnętrznym programem z oil
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.png", "*.jpg", "*.jpeg", "*.pdf" },
  callback = function()
    local file = vim.api.nvim_buf_get_name(0)
    local ext = file:match("%.(%w+)$"):lower()
    vim.cmd("bdelete")
    if ext == "pdf" then
      vim.fn.jobstart({ "zathura", file }, { detach = true })
    else
      vim.fn.jobstart({ "geeqie", file }, { detach = true })
    end
  end,
})

-- live preview: pandoc przy każdym zapisie pliku .md
vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.md",
  callback = function()
    local file = vim.api.nvim_buf_get_name(0)
    local basename = vim.fn.fnamemodify(file, ":t:r")
    local html_file = "/tmp/obsidian-preview/" .. basename .. ".html"
    vim.fn.jobstart({
      "pandoc", file, "-o", html_file,
      "-s", "--mathjax", "--metadata", "title=" .. basename
    }, { detach = true })
  end,
})

-- przekieruj surf gdy zmieniasz plik w nvim
-- informuj serwer o aktywnym pliku
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*.md",
  callback = function()
    local file = vim.api.nvim_buf_get_name(0)
    if file == "" then return end
    local basename = vim.fn.fnamemodify(file, ":t:r")
    local encoded = basename:gsub(" ", "%%20")
    vim.fn.jobstart({
      "curl", "-s", "http://localhost:8080/switch/" .. encoded
    }, { detach = true })
  end,
})
