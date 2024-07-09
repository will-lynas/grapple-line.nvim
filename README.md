# grapple-line.nvim

A lualine component for `grapple.nvim`

![image](https://github.com/will-lynas/grapple-line.nvim/assets/43895423/d94783c7-dbef-4c91-bc61-00cb1dd2e581)
_Here `grapple-line.nvim` is used on the right of the tabline._

## `lazy.nvim` setup

### Minimal

```lua
{
	"will-lynas/grapple-line.nvim",
	dependencies = {
		"cbochs/grapple.nvim",
	},
}
```

### Full

```lua
{
	"will-lynas/grapple-line.nvim",
	dependencies = {
		"cbochs/grapple.nvim",
	},
	opts = {
		active_highlight = "lualine_a_normal",
		number_of_files = 4,
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
