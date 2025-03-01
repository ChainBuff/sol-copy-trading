
# Copy-trading

## 简介

跟单速度极佳的机器人, 全套使用 `Rust` 进行开发, 可进行 `PUMP` 和 `Raydium` 的 `Swap` 跟单交易, 内置止盈止损配置, 可以按照每个钱包的风格来定止盈的区间, 前置的`GRPC` 指获取交易信息的延迟需要极低, 均衡的小费模式, 需要按照自己理想状态调整， 优先费和 `TIP` 都需要均衡就行, 大额小费可以卷热门钱包比如说 `Dfm`、`DNf`.

## 收费标准

- 每笔交易的 `1%`, 百分之`1`中 `7` 成由开发者收取, `3` 成捐献给社区.
- copy9oyT2sLN9QvwHHJy7TWSVi3szVdtogVAjQ9jWvx 开发者收费钱包
- buffaAJKmNLao65TDTUGq8oB9HgxkfPLGqPMFQapotJ 社区钱包

## 安装依赖

### Redis

#### 更新 Redis 官方依赖

``` bash
# 步骤 1
1. curl -fsSL https://packages.redis.io/gpg | sudo gpg --dearmor -o /usr/share/keyrings/redis-archive-keyring.gpg

# 步骤 2
2. echo "deb [signed-by=/usr/share/keyrings/redis-archive-keyring.gpg] https://packages.redis.io/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/redis.list

3. sudo apt-get update && sudo apt-get install redis
```

#### 编辑配置文件开启 Unixsocket

``` conf
# 修改 socket 文件路径, 并赋予 777 权限
unixsocket /var/run/redis/redis.sock
unixsocketperm 777
```

#### 启动 Redis

``` bash
1. sudo service redis-server start

2. sudo service redis-server status
# 查看 sock 文件是否存在
3. ls /var/run/redis/redis.sock

# active = running 则代表成功
● redis-server.service - Advanced key-value store
     Loaded: loaded (/usr/lib/systemd/system/redis-server.service; disabled; preset: enable>
     Active: active (running) since Thu 2025-02-27 16:25:00 EET; 2min 44s ago
       Docs: http://redis.io/documentation,
             man:redis-server(1)
   Main PID: 1887 (redis-server)
     Status: "Ready to accept connections"
      Tasks: 6 (limit: 19150)
     Memory: 3.5M (peak: 4.2M)
        CPU: 416ms
     CGroup: /system.slice/redis-server.service
             └─1887 "/usr/bin/redis-server 127.0.0.1:6379"

Feb 27 16:25:00 active-puma systemd[1]: Starting redis-server.service - Advanced key-value >
Feb 27 16:25:00 active-puma systemd[1]: Started redis-server.service - Advanced key-value >
```

### 配置介绍

#### SWQoS

跟单机器人, 上链选择的都是 `SOLANA`, 比较热门 SWQoS 的服务商, 使用各家的免费版本即可满足需求, 如果你的频率很高那么可以选择付费, 如果所有服务商都开启了，那么在上链的时候会选择最快速度的交易上链, 就算开启了4个服务商那么也只会有一笔交易确认上链.

##### Jito

- 默认启用

##### BloxRoute

- 默认不启用, 可使用免费版本，跟单足够用
- 申请地址: <https://portal.bloxroute.com/registration>, 只需要注册一个免费的账号，然后在`Acount` Tag 中， 找到 Authorization Header 内容, 填入 `token` 中即可
- 地域选择: <https://docs.bloxroute.com/solana/trader-api/introduction/regions>, 选择离你服务器最近的地址即可，保证低延迟

``` toml
[bloxroute]
enable = true
url="germany.solana.dex.blxrbdn.com"
token="xxxx"
```

##### Temproal

- 默认启用, 使用社区合作的秘钥, 如果使用者较多, TPS 可能会超过限制, 请自行找客服申请独享, 免费

``` toml
[temproal]
enable = true
url="http://fra2.nozomi.temporal.xyz/?c=f9b4c049-bfb1-4981-90ed-edc3aed018fb"
```

##### Nextblock

- 默认不启用, 可使用免费版本，跟单足够用
- 申请地址: <https://nextblock.io/app/endpoints-api> 注册一个免费的地址, 然后创建一个API KEY， 复制KEY Id
- 地域选择: <https://docs.nextblock.io/getting-started/quickstart> 目前只有 FRA 、NY

``` toml
[nextblock]
enable = true
url="fra.nextblock.io"
token="xxx"
```

#### 启动

``` bash
# 前台运行
./copy-trading

# 后台运行
nohup ./copy-trading > copy-trading.log &
```
