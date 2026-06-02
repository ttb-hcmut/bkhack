:lua vim.lsp.enable('ocamllsp')
LoadNeotree
lua << EOF
local opt = require("config/neotree")
local hidden = {
	"_build",
	"_opam",
	"dist",
	"dist__serve",
	"node_modules"
}
for _, it in pairs(hidden) do
	table.insert(
		opt.filesystem.filtered_items.hide_by_pattern, it
	)
end
require("neo-tree").setup(opt)
EOF
