-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("v", "<leader>as", function()
  -- 1. Save the current content of register 'v' so we don't clobber your clipboard
  local saved_reg = vim.fn.getreg("v")

  -- 2. Yank the visual selection into register 'v'
  vim.cmd('noau normal! "vy')
  local text = vim.fn.getreg("v")

  -- 3. Restore the original content of register 'v'
  vim.fn.setreg("v", saved_reg)

  -- 4. Get the relative file path for context
  local file_path = vim.fn.expand("%:.")

  -- 5. Format the prompt payload
  local payload = string.format("Context from `%s`:\n```\n%s\n```\n", file_path, text)

  -- 6. Write to a temp file (bypasses all shell quoting/escaping nightmares)
  local tmpfile = os.tmpname()
  local f = io.open(tmpfile, "w")
  if f then
    f:write(payload)
    f:close()

    -- 7. Send to Tmux's last active pane and clean up the temp file
    -- The -p flag pastes it, and -t '{last}' targets the previously focused pane
    local cmd = string.format("tmux load-buffer %s && tmux paste-buffer -p -t '{last}' && rm %s", tmpfile, tmpfile)
    os.execute(cmd)

    print("Sent to Gemini!")
  else
    print("Error: Could not create temp file for Tmux transfer.")
  end
end, { desc = "Send selection to Gemini CLI in last Tmux pane" })
