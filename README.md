# wl-bot

This is a program used to provide tools for QQ and Telegram groups, written in Haskell.

## How it works

The program uses the [mirai-api-http](https://github.com/mamoe/mirai-api-http) to communicate with [Mirai](https://github.com/mamoe/mirai), and get updates from Telegram through _Webhook_.

## What it can do

- Search entries from [Baidu Baike](https://baike.baidu.com/) (`/bk`)
- Save notes (`/svnote` `/note`)
- Roll dice (`/dc`)
- Search image by image using [SauceNAO](https://saucenao.com/) and [Ascii2d](https://ascii2d.net/)(`/sp` `/asc`)
- Search anime using [WAIT](https://trace.moe/) (`/am`)
- Using [pixiv.cat](https://pixiv.cat/) to get images by Pixiv id (`/pid`)
- And some contents that may be not suitable to present..

Get all commands using `/help`.


## How to use it

1. Download the pre-build binary file from [release](https://github.com/Nutr1t07/wl-bot/releases/).

2. Create `config.json` under the same directory as `wl-bot-exe`:

   ```json
   {
      "tg_token":"",
      "mirai_server":"",
      "webhook_server":"",
      "port":8443,
      "ws_host":"",
      "ws_port":6700,
      "mirai_auth_key": "",
      "mirai_qq_id": ""
   }
   ```

| Key                 | Description                          | Example Value            |
|---------------------|--------------------------------------|--------------------------|
| port                | The port this program listen         | 8443                     |
| webhook\_server     | Server address used for Webhook      | "https://yourserver/"    |
| mirai\_server       | CoolQ server address for API calling | "http://localhost:5700/" |
| tg\_token           | Token for Telegram Bot API           |                          |
| ws\_host            | Mirai WebSocket listening address    |                          |
| ws\_port            | Mirai WebSocket listening port       |                          |
| mirai\_auth\_key    | mirai-api-http auth key              |                          |
| mirai\_qq\_id       | QQ bot id                            |                          |


3. Enable Mirai **Http API** plugin, set the config of the plugin:

   ```yaml
   enableWebsocket: true
   ```

4. Run `wl-bot-exe`:

   ```bash
   nohup ./wl-bot-exe &
   ```

# Acknowledgements

- [mirai](https://github.com/mamoe/mirai)
- [mirai-api-http](https://github.com/mamoe/mirai-api-http)
- [Baidu Baike](https://baike.baidu.com/)
- [SauceNAO](https://saucenao.com/)
- [Ascii2d](https://ascii2d.net/)
- [WAIT](https://trace.moe/)
- [pixiv.cat](https://pixiv.cat/)
- [NHentai](https://nhentai.net/)
- [JavDB](https://javdb.com/)
