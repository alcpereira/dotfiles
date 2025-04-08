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
    },
    notify_on_error = false,
    format_on_save = {
      timeout_ms = 500,
      lsp_format = "fallback",
    },
    formatters_by_ft = {
      lua = { "stylua" },
      typescriptreact = { "prettierd", "eslint_d" },
      typescript = { "prettierd", "eslint_d" },
      javascriptreact = { "prettierd", "eslint_d" },
      javascript = { "prettierd", "eslint_d" },
      css = { "prettierd" },
      html = { "prettierd" },
      -- yaml = { "yamlfmt", "prettierd", "prettier", stop_after_first = true },
      yaml = { "prettierd" },
      markdown = { "prettierd" },
      toml = { "taplo" },
    },
  },
}
