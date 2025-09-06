return {
  "saghen/blink.cmp",
  event = "VimEnter",
  version = "1.*",
  dependencies = {},
  --- @module 'blink.cmp'
  --- @type blink.cmp.Config
  opts = {
    keymap = {
      preset = "enter",
    },
    -- completion = {
    --   -- By default, you may press `<c-space>` to show the documentation.
    --   -- Optionally, set `auto_show = true` to show the documentation after a delay.
    --   documentation = { auto_show = true, auto_show_delay_ms = 500 },
    -- },
    sources = {
      default = { "lsp", "path", "snippets", "lazydev" },
      providers = {
        lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
      },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
}
