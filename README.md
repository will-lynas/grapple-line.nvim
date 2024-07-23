# grapple-line.nvim

A lualine component for `grapple.nvim`

![image](https://github.com/will-lynas/grapple-line.nvim/assets/43895423/d94783c7-dbef-4c91-bc61-00cb1dd2e581)
_Here `grapple-line.nvim` is used on the right of the tabline._

## `lazy.nvim` setup

### Minimal

```lua
{
	"will-lynas/grapple-line.nvim",
	version = "1.x",
	dependencies = {
		"cbochs/grapple.nvim",
	},
}
```

### Full

The default values are shown in the `opts` table.

```lua
{
	"will-lynas/grapple-line.nvim",
	dependencies = {
		"cbochs/grapple.nvim",
	},
	version = "1.x",
	opts = {
		number_of_files = 4,
		colors = {
			active = "lualine_a_normal",
			inactive = "lualine_a_inactive",
		},
		-- Accepted values:
		-- "unique_filename" shows the filename and parent directories if needed
		-- "filename" shows the filename only
		mode = "unique_filename",
		-- If a tag name is set, use that instead of the filename
		show_names = false,
	},
}
```

## Usage

```lua
require("lualine").setup({
	tabline = {
		lualine_z = { require("grapple-line").status },
	},
})
```
