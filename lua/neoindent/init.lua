local M = {}

UP = -1
DOWN = 1

---@alias direction integer

---@param lnum integer?
---@param direction direction
---@return integer
local function find_end_of_indent(lnum, direction)
  assert(direction == 1 or direction == -1, "direction must be either UP or DOWN, got " .. direction)
  if lnum == nil then
    lnum = vim.fn.line(".")
  end
  assert(lnum > 0 and lnum <= vim.fn.line("$"), "lnum must be within the buffer size, got " .. lnum)

  local current_indentation = vim.fn.indent(lnum)

  if current_indentation == 0 then
    -- Find the indentation of the next closest lines
    local next_indentation = vim.fn.indent(vim.fn.nextnonblank(lnum))
    local prev_indentation = vim.fn.indent(vim.fn.prevnonblank(lnum))
    current_indentation = math.max(next_indentation, prev_indentation)
  end

  while true do
    lnum = lnum + direction
    if lnum <= 0 or lnum > vim.fn.line("$") then
      return lnum - direction
    end
    if vim.fn.getline(lnum) == "" then
      goto continue
    end
    if vim.fn.indent(lnum) < current_indentation then
      return lnum - direction
    end
    ::continue::
  end
end

function M:NeoindentGoUp()
  local lnum = find_end_of_indent(nil, UP)
  vim.cmd("norm! " .. lnum .. "G_")
end

function M:NeoindentGoDown()
  local lnum = find_end_of_indent(nil, DOWN)
  vim.cmd("norm! " .. lnum .. "G_")
end

function M:NeoindentObject()
  local ltop = find_end_of_indent(nil, UP)
  local lbottom = find_end_of_indent(nil, DOWN)

  vim.fn.setpos("'<", { vim.fn.bufnr(), ltop, 1, 0 })
  vim.fn.setpos("'>", { vim.fn.bufnr(), lbottom, string.len(vim.fn.getline(lbottom)), 1 })
  vim.cmd("normal! gv")
end

function M:setup(overrides)
  overrides = overrides or {}
  local keymap = {
    up = "[i",
    down = "]i",
    object = "ii",
  }

  for k, v in pairs(overrides) do
    keymap[k] = v
  end
  vim.keymap.set({ "n", "x" }, keymap["up"], M.NeoindentGoUp)
  vim.keymap.set({ "n", "x" }, keymap["down"], M.NeoindentGoDown)
  vim.keymap.set("x", keymap["object"], M.NeoindentObject)
  vim.keymap.set("o", keymap["object"], M.NeoindentObject)
end

return M
