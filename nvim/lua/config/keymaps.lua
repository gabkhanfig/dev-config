-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Cmd+c / Ctrl+c: copy selection to system clipboard
vim.keymap.set("v", "<D-c>", '"+y', { desc = "Copy to clipboard" })
vim.keymap.set("v", "<C-c>", '"+y', { desc = "Copy to clipboard" })

-- Cmd+d / Ctrl+d: duplicate current line
vim.keymap.set("n", "<D-d>", '"wyy"wp', { desc = "Duplicate line" })
vim.keymap.set("n", "<C-d>", '"wyy"wp', { desc = "Duplicate line" })
