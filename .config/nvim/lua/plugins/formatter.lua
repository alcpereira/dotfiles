return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "Conforminfo" },
  keys = {
    {
      "<leader>f",
      function()
        require("conform").format({ async = true, lsp_format = "fallback" })
      end,
      mode = "",
      desc = "[f]ormat buffer",
    },
  },
  opts = {
    formatters = {
      prettierd = {
        require_cwd = true,
      },
      biome = {
        require_cwd = true,
      },
    },
    notify_on_error = false,
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      lua = { "stylua" },
      typescriptreact = { "prettierd", "eslint_d", "biome" },
      typescript = { "prettierd", "eslint_d", "biome" },
      javascriptreact = { "prettierd", "eslint_d", "biome" },
      javascript = { "prettierd", "eslint_d", "biome" },
      css = { "prettierd", "biome" },
      json = { "prettierd", "biome" },
      html = { "prettierd", "biome" },
      yaml = { "yamllint", "yamlfmt", "prettierd", stop_after_first = true },
      markdown = { "prettierd", "biome" },
      toml = { "taplo" },
    },
  },
}
