fx_version("cerulean")
game("gta5")

author("Forge Devs - PierreMoraes")
description("Sistema de posicionamento de animacao com prop")
version("1.2.5")
lua54("yes")

shared_scripts({
	"@pr_bridge/init.lua",
	"shared/config.lua",
	"server/version.lua",
})

client_scripts({
	"client/**.lua",
})

server_scripts({
	"server/**.lua",
})

ui_page("web/index.html")

files({
	"locale/*.lua",
	"web/index.html",
	"web/main.js",
	"web/formats.js",
	"web/main.css",
	"web/logo.png",
	"web/Road_Rage.otf",
})

dependencies({
	"pr_bridge",
})
