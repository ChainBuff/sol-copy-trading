# 配置详解

## sell_tip 卖出交易的tip

``` toml
[sell_tip]
# 默认 1083100 / 1e9 = 0.0010831 SOL, 提交 Temporal, 官网声明不能小于 0.001 SOL
amount=1083100
```

## 通用止盈止损策略

- 此策略逻辑, 用于在跟单进场后进行兜底止盈止损.
- 在进入分批售卖后（指追踪止盈止损），通用止盈止损策略就算再次命中, 也不会在触发

### 止盈止损

``` toml
# 通用止盈策略
# 指内盘与外盘都会可能触发此策略
[strategy.stop_profit]

# tip + priority_fee + service_fee = transaction_fee
# 最新价格已经包含所有费用直接出售, 且报价次数超过 50 次 (从入场后发生了50笔交易)
# 用于兜底本金, 值越大且并未触发其他止盈条件或止损, 意味着持仓周期变长
quota_num_and_transaction_fee = 50

# 全部仓位按照最新价格出售, 达到两倍手续费直接出售全部仓位
# 如果已经触发了分批止盈则无法再出发此条件
transaction_fee_two = true

# 5s 价格不变, 满足 strategy.pump.sell.hold_profit || strategy.raydium.sell.hold_profit 进行减仓
# 不满足，则无事发生
# 如果不想启用此参数, 可直接注释
price_invariable_second = 5
```

### 止损策略

``` toml
# 通用止损策略
# 指内盘与外盘都会可能触发此策略
[strategy.stop_loss]

# 15s 最新价格没有任何变化, 出售全部仓位
# 如果不想启用此参数, 可直接注释
price_invariable_second = 15

# 最新价格小于 -20.0 止损出售全部仓位.
lt_rate = -20.0

# 位置1: 盈利次数(指盈利百分比 > 0 的次数), 默认 20.
# 位置2: 最新涨幅百分比
# 场景如盈利百分比 > 20, 且最新价格突然下降至 -10% 已下, 会触发此条件.
gt_zero_and_lt_rate = [20, -10.0]


# 位置1: 最新涨幅百分比
# 位置2: 价格更新次数
# 场景如最新盈利百分比下跌超过-15%时, 且报价次数过了50次
lt_rate_and_quota_num = [-15.0, 50]

# 亏损权重止损
# 场景如盈利百分比 < 10, 那么权重值则单次增加 18.
# 此权重数值是否止损, 看 loss_num 设置数值大小. 达到 loss_num 止损
# 解释这个权重指标, 在盘面上下波动过大, 且没有达到 < lt_rate 时, 不想过早止损， 但是也不能干等止盈. 所以出现此指标
loss_weight = [
  [-3.0, 3],
  [-5.0, 5],
  [-10.0, 10]
]

# 亏损权重上限值 
# 次数达到止损, 由每次最新价格报价时, 按照loss_weight 数组顺序循环增加
loss_num = 500
```

## 内盘策略

### 内盘购买限制

``` toml
[strategy.pump.buy]

# 只进入首次, 如果购买失败, 有其他聪明钱包购买相同的代币, 则跳过
is_first_buy = true

# 内盘实际 SOL 的储备, 内盘转外盘需内盘达到85个, 有些价格浮动大钱包跟进去容易挂在顶点
# 开外盘的时候如果没有塞外盘情况, 容易亏损, 值应该越大，而不是小
amm_wsol = 60.0


# 位置1: 不计算聪明钱包购买的价值, SOL 池子的大小.
# 位置2: 聪明钱包购买的 SOL 大小
# 条件触发: WSOL < 1.0 && copy_buy_sol > 5.0  = 池子太小, 聪明钱包买的太多, 怕跟单的聪明钱包割你
pre_wsol_and_copy_buy_sol = [1.0, 5.0]

# 聪明钱包购买之前的池子， 小于 30 SOL，且聪明钱包买入大于15 SOL, 不买
# 位置1: 不计算聪明钱包购买的价值, SOL 池子的大小.
# 位置2: 聪明钱包购买的 SOL 大小
# 条件触发: WSOL < 30.0 && copy_buy_sol > 15.0 = 交易后聪明钱包持仓占比太高, 容易砸穿池子, 怕跟单的聪明钱包割你
pre_wsol_and_copy_buy_sol_1 = [30.0, 15.0]

# 聪明钱包购买太少不买
copy_buy_sol = 0.5
```

### 内盘卖出策略

``` toml
[strategy.pump.sell]

# 开始追踪止盈止损策略后, 下降止损价格
# 1. 最新涨幅百分比达到, 聪明钱包配置项, wallets.first_stop_profit 开启追踪止盈止损
# 2. 基于购买成本价格 * 百分之5 计算出止损价格, 最新价格小于止损价止损
first_down_cost_price = 0.05

# 第一次分批后，下一次止盈价格
# 首次开始追踪止盈止损后, 下一次止盈价格
# 1. 基于市场最新价格 * 百分之10 则是 下一次的止盈点
first_next_stop_profit_price = 0.1

# 守住利润，用于快速完仓位，机会于风险并存
hold_profit_enable = true

# 盈利百分比大于 20% 时, 看 batch_step_num 次数是否达标, batch_step_num 根据每次价格变化更新
hold_profit = 20.0
# 在利润大于 20% 时，每 5 次价格变化，按照 reduce_stock 的值进行，剩余token数量比减仓
batch_step_num = 5
# 减仓比例
reduce_stock = 0.2
```

## 外盘策略

### 外盘购买限制

``` toml
[strategy.raydium.buy]

# 只进入首次, 如果购买失败, 有其他聪明钱包购买相同的代币, 则跳过
is_first_buy = true

# wsol 池子 大于 300, 价格拉升不高, 进去容易亏钱
amm_wsol = 300.0

# 位置1: 聪明钱包购买之前的池子, 大于 1 SOL
# 位置2: 当前WSOL 池子小于 30.0
# 场景: 外盘开盘被砸的很低， 然后进入被还持有仓位的抛压
pre_wsol_and_copy_buy_sol = [1.0, 30.0]

# 聪明钱包购买之前的池子， 小于 30 SOL，且聪明钱包买入大于15 SOL, 不买
# 位置1: 聪明钱包购买之前的池子，小于 30 SOL
# 位置2: 聪明钱包买入大于 15 SOL
# 场景: 历史已经破发的盘子, 聪明钱包购买大额, 基本上是砸盘的概率大.
pre_wsol_and_copy_buy_sol_1 = [30.0, 15.0]

# 聪明钱包购买太少不买
copy_buy_sol = 0.5

# 不是中等波动或者高等波动的钱包，池子大于 150 不买,拉不动
not_high_medium = 150.0
```

### 外盘卖出策略

- 跟内盘类似

``` toml
[strategy.raydium.sell]
# 开始追踪止盈止损策略后, 下降止损价格
# 1. 最新涨幅百分比达到, 聪明钱包配置项, wallets.first_stop_profit 开启追踪止盈止损
# 2. 基于购买成本价格 * 百分之5 计算出止损价格, 最新价格小于止损价止损
first_down_cost_price = 0.05

# 第一次分批后，下一次止盈价格
# 首次开始追踪止盈止损后, 下一次止盈价格
# 1. 基于市场最新价格 * 百分之10 则是 下一次的止盈点
first_next_stop_profit_price = 0.1

# 守住利润，用于快速完仓位，机会于风险并存
hold_profit_enable = true

# 盈利百分比大于 20% 时, 看 batch_step_num 次数是否达标, batch_step_num 根据每次价格变化更新
hold_profit = 20.0
# 在利润大于 20% 时，每 5 次价格变化，按照 reduce_stock 的值进行，剩余token数量比减仓
batch_step_num = 5
# 减仓比例
reduce_stock = 0.2
```

## 聪明钱包配置

``` toml
[[wallets]]
# 高波动, 意味着后面跟单的流动性很好. 与 strategy.raydium.buy.not_high_medium 联动
is_high = true
# 中等波动, 一般波动, 但是 tip 很卷, 有很大机会拉升价格. 与 strategy.raydium.buy.not_high_medium 联动
is_medium = false
# 波动小
is_low = false
# 内盘 swqos 小费
pump_tip = 10000000
# 跟单此聪明钱包内盘, 购入的金额 SOL, 单位需要除以 1E9;
pump_input_sol = 100000000
# 滑点, 内盘滑点影响的输入金额, 所以尽量别设置太高. 设置太高容易抬轿子.
pump_bps = 2500
# 外盘 swqos 小费
raydium_tip = 10000000
# 跟单此聪明钱包内盘, 购入的金额 SOL, 单位需要除以 1E9;
raydium_input_sol = 100000000
# 外盘滑点,影响最小收到的 token 数量, 别设置太高. 设置太高容易抬轿子.
raydium_bps = 2500
# 聪明钱包
address = "DfMxre4cKmvogbLrPigxmibVTTQDuzjdXojWzjCXXhzj"
# 优先费用 = ((100 * 1e6) * 100001) / 1e9 = SOL 
priority_fee = 100
# 是否分批
# 此值等于 false, 则直走通用的止盈止损
is_batch = true
# 首次分批止盈百分比
# 在没有触发常规的止盈止损, 最新涨幅达到设置值，开始减仓, 减仓比例等于 first_reduce_stock 配置
first_stop_profit = 20.0
# 首次分批减仓比例
# 与 first_stop_profit 配置相辅相成
first_reduce_stock = 0.3
# 聪明钱包清仓, 是否清仓, 不跑大概率要没.
is_copy_run = true
# 分批止盈百分比
# 首次分批止盈后, 最新价格达到 strategy.(pump|raydium).sell.first_next_stop_profit_price 计算值后， 开始阶梯是止盈
# 1. 位置1: 0.2 即是仓位, 也是基于市价计算下一次止盈价格的算法,
# 下一次止盈 = 市价 + 市价 * 0.2; 止损也是基于这个值, 止损 = 市价 - 市价 * 0.2, 如果计算出止损价格小于, 购入成本, 则等于购入成本.
step_stop_loss = [0.2, 0.2, 0.3, 0.4, 0.5]
# 分批阶段中, 询价超过 150, 清仓, 值越大，持仓周期越长.
step_num = 150
# 剩余仓位的价值, 单位 SOL
# 默认配置小于 0.5 SOL 清仓
remain_sell_sol = 500000000
```
