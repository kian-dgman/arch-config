-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "redblack",
  callback = function()
    local pure_black = "#000000"

    local target_groups = {
      "Normal",
      "NormalNC",
      "SignColumn",
      "NormalFloat",
      "CursorLineNr",
      "NeoTreeNormal",
      "NeoTreeNormalNC",
      "TelescopeNormal",
      "LineNr",
      "FoldColumn",
      "NonText",
      "VertSplit",
    }

    -- Make redblack theme more black --
    for _, group in ipairs(target_groups) do
      local current_hl = vim.api.nvim_get_hl(0, { name = group })

      current_hl.bg = pure_black

      vim.api.nvim_set_hl(0, group, current_hl)
    end

    -- Diff Overrides ---
    vim.api.nvim_set_hl(0, "DiffChange", { bg = "#1c1c1c", fg = "#d0d0d0" })
    vim.api.nvim_set_hl(0, "DiffText", { bg = "#5f0000", fg = "#ff8787" })
    vim.api.nvim_set_hl(0, "DiffAdd", { bg = "#003300", fg = "#87ff87" })
    vim.api.nvim_set_hl(0, "DiffDelete", { bg = "#330000", fg = "#ff5f5f" })
  end,
})
