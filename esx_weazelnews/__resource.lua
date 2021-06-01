resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

version '1.0.0'

server_scripts {
  'config.lua',
  'server/*.lua'
}

client_scripts {
  "src/client/RMenu.lua",
  "src/client/menu/RageUI.lua",
  "src/client/menu/Menu.lua",
  "src/client/menu/MenuController.lua",
  "src/client/components/*.lua",
  "src/client/menu/elements/*.lua",
  "src/client/menu/items/*.lua",
  "src/client/menu/panels/*.lua",
  "src/client/menu/panels/*.lua",
  "src/client/menu/windows/*.lua",

  'config.lua',
  'client/*.lua'
}