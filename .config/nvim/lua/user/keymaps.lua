local opts = { noremap = true, silent = true }

local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.keymap.set

local function vscode_opts(desc)
  return { noremap = true, silent = true, desc = "VS Code: " .. desc }
end

local function vscode_keymap(modes, keys, command, desc)
  for _, key in ipairs(keys) do
    keymap(modes, key, command, vscode_opts(desc))
  end
end

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- VSCode-style entry points
vscode_keymap({ "n", "i", "v" }, { "<D-s>", "<C-s>" }, "<cmd>w<CR>", "save file")
vscode_keymap("n", { "<D-p>", "<C-p>" }, "<cmd>lua require('telescope.builtin').find_files(require('telescope.themes').get_dropdown{previewer = false})<CR>", "quick open file")
vscode_keymap("n", { "<D-S-p>", "<C-S-p>" }, "<cmd>Telescope commands<CR>", "command palette")
vscode_keymap({ "n", "i", "v" }, { "<D-f>" }, "<cmd>Telescope current_buffer_fuzzy_find<CR>", "find in current file")
vscode_keymap("n", { "<C-f>" }, "<cmd>Telescope current_buffer_fuzzy_find<CR>", "find in current file")
vscode_keymap({ "n", "i", "v" }, { "<D-S-f>" }, "<cmd>Telescope live_grep theme=ivy<CR>", "search in workspace")
vscode_keymap("n", { "<C-S-f>" }, "<cmd>Telescope live_grep theme=ivy<CR>", "search in workspace")
vscode_keymap("n", { "<D-b>", "<C-b>" }, "<cmd>NvimTreeToggle<CR>", "toggle explorer")
vscode_keymap("n", { "<D-w>", "<C-w>" }, "<cmd>Bdelete<CR>", "close editor")
vscode_keymap("n", { "<D-`>", "<C-`>" }, "<cmd>ToggleTerm direction=float<CR>", "toggle terminal")
vscode_keymap("n", { "<F2>" }, "<cmd>lua vim.lsp.buf.rename()<CR>", "rename symbol")
vscode_keymap("n", { "<F12>" }, "<cmd>lua vim.lsp.buf.definition()<CR>", "go to definition")
vscode_keymap("n", { "<S-F12>" }, "<cmd>Telescope lsp_references<CR>", "find references")
vscode_keymap("n", { "<A-F12>" }, "<cmd>lua vim.lsp.buf.hover()<CR>", "show hover")
vscode_keymap("n", { "<D-.>", "<C-.>" }, "<cmd>lua vim.lsp.buf.code_action()<CR>", "code action")
keymap("n", "<leader><leader>", "<cmd>Telescope commands<CR>", opts)
keymap("n", "<leader>/", "<cmd>Telescope live_grep theme=ivy<CR>", opts)
keymap("n", "<leader>?", "<cmd>Telescope keymaps<CR>", opts)
keymap("n", "<leader>r", "<cmd>Telescope oldfiles<CR>", opts)
keymap("n", "<leader>x", "<cmd>Telescope diagnostics<CR>", opts)

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<Tab>", ":bnext<CR>", opts)
keymap("n", "<S-Tab>", ":bprevious<CR>", opts)

-- Move text up and down
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)

-- Insert --
-- Press jk fast to exit insert mode 
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)

-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv^", opts)
keymap("v", ">", ">gv^", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":m '>+1<CR>gv=gv", opts)
keymap("x", "K", ":m '<-2<CR>gv=gv", opts)
keymap("x", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("x", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Terminal --
-- Better terminal navigation
-- keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
-- keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
-- keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
-- keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
