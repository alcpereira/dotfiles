return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  opts = {
    columns = { "icon" },
    view_options = {
      show_hidden = true,
    },
  },
  keys = {
    { "-", "<CMD>Oil --float<CR>", desc = "Open parent directory" },
  },
  dependencies = { "nvim-tree/nvim-web-devicons" },
}
