# MetaTrader 4 EA Toolkit

Expert Advisors and supporting libraries from the algorithmic trading platform I built in 2018 as co-founder of PES Finance Capital. They ran on MetaTrader 4 against Indian MCX commodity and currency contracts. The company has since closed; this repo shares the MetaTrader side of the system.

## How the system worked

```
Web dashboard ──► MySQL (per-symbol settings) ──► Expert Advisor (MetaTrader 4)
                                                      │
                     OpenPosition / OrderBook ◄───────┤ updates positions and logs
                                                      │
                     <SYMBOL>_Signal.text  ◄──────────┘ writes BUY / SELL signals
                              │
                              ▼
                     Bridge app (not included) ──► broker APIs
```

- Traders set each symbol's parameters on a web dashboard: moving-average periods, stop-loss limits, position sizes, and a force-exit switch. These were stored in a `MasterRecord` table.
- The EA re-reads those settings on every tick, so a change on the dashboard takes effect immediately without restarting MetaTrader.
- When the EA decides to enter or exit, it writes the signal to a per-symbol file and updates the position tables in MySQL.
- A separate bridge application (not in this repo) watched the signal files and placed the orders through the brokers' APIs.

## What's here

| File | What it does |
|---|---|
| `Experts/Increment_StopLoss_EA.mq4` | The main production EA. Trend-following entries and exits from MACD / moving-average crossovers or candle patterns, filtered by ADX trend strength and stochastic. Stop-loss distance is measured in candle sizes: it starts at a per-symbol minimum and is adjusted step by step as the trade develops, within a per-symbol maximum. Position size, stop-loss limits and force-exit come from the database. On-chart labels and manual buy/sell buttons. |
| `Experts/Vortex-ADX_EA_Long_Trend_Currency.mq4` | Standalone EA (no database). Entries on Vortex indicator crossovers confirmed by ADX / DI and moving averages, with higher-timeframe pivot points and a trailing stop-loss. |
| `Experts/Trend_Identifier_V2.mq4` | Multi-symbol trend scanner rather than a trading EA. Combines Vortex crossovers, ADX trend and slope, DI slopes, moving-average crossovers and stochastic state into a trend summary per symbol. |
| `Experts/Smart_TrendIdentifier_V1.mq4` | Feeds the dashboard: computes percentage change, ADX, RSI and VWAP per symbol and writes them to the `TrendBook` table. |
| `Include/SQLOperations.mqh` | All MySQL reads and writes: per-symbol settings, open positions, order and trade books, logs. |
| `Include/ReadInputValues.mqh` | Order handling: position sizing and scaling, writing signal files, updating positions. |
| `Include/StopLossMgmt.mqh` | The incremental stop-loss calculation. |
| `Include/TIOperation.mqh` | Indicator calculations and database updates for the trend identifier. |
| `Include/labelUI.mqh`, `ButtonCreate.mqh`, `Arrow_Stop_Buy.mqh` | On-chart labels, buttons and stop-loss markers. |
| `Include/mql4-mysql.mqh` | Third-party MySQL wrapper for MQL4 by Sergey Lukin (Unlicense), included unchanged. |

## Requirements

- MetaTrader 4, with **Allow DLL imports** enabled
- MySQL, with `libmysql.dll` (32-bit) in `MQL4/Libraries`
- A Vortex indicator compiled as `vortex-indicator` in `MQL4/Indicators` (third-party, not included)
- The database schema is not included. The EAs use these tables: `MasterRecord`, `OpenPosition`, `OrderBook`, `TradeBook`, `TrendBook`

To install, copy the `MQL4` folder into the terminal's data folder (File → Open Data Folder), then set the database host, user, password and name in the EA's inputs.

## Status

This is 2018 code, shared as it ran. It hasn't been recompiled against current MetaTrader 4 builds. The only changes for publishing: database credentials moved from the code into EA inputs, and the file headers updated.

## What I'd do differently today

- **Connection handling:** `OnTick` waits for a broker connection in a `while(!IsConnected())` loop, which blocks the EA. It should return and let the next tick retry.
- **Database connections:** each query opens and closes its own MySQL connection. I'd reuse one connection per EA and reconnect only on failure.
- **Signal hand-off:** passing signals through text files works, but a message queue would be more robust, with an idempotency key on every signal so a retried signal can never place a duplicate order.
- **Code hygiene:** clearer variable names, removing commented-out code, and Strategy Tester backtests checked into the repo.

## Disclaimer

Shared for portfolio purposes. Nothing here is financial advice or a claim about trading performance. Test on a demo account.
