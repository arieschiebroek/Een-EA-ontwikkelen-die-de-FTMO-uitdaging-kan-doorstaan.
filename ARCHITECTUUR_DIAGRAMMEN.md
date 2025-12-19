# FTMO EA System Architectuur - Visuele Diagrammen

## 🔄 Multi-EA Coördinatie Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                        ACCOUNT €10,000                          │
│                     (Max 5% Daily Loss)                         │
└─────────────────────────────────────────────────────────────────┘
                              │
         ┌────────────────────┼────────────────────┐
         │                    │                    │
    ┌────▼────┐          ┌────▼────┐         ┌────▼────┐
    │  EA #1  │          │  EA #2  │         │  EA #3  │
    │ EURUSD  │          │ GBPUSD  │         │ XAUUSD  │
    │ (100001)│          │ (100002)│         │ (100003)│
    └────┬────┘          └────┬────┘         └────┬────┘
         │                    │                    │
         └────────────────────┼────────────────────┘
                              │
                    ┌─────────▼──────────┐
                    │  Shared Files      │
                    │  ─────────────     │
                    │  Coordination.txt  │
                    │  Daily_Loss.txt    │
                    └────────────────────┘
```

## 📊 Trade Lifecycle

```
START
  │
  ▼
┌─────────────────────┐
│ New Tick Arrives    │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐      YES    ┌──────────────────┐
│ New Day?            │─────────────>│ Reset Daily Vars │
└──────────┬──────────┘              └──────────────────┘
           │ NO
           ▼
┌─────────────────────┐      YES    ┌──────────────────┐
│ Daily Loss >= 5%?   │─────────────>│ Close All Trades │──> STOP
└──────────┬──────────┘              │ Block Trading    │
           │ NO                      └──────────────────┘
           ▼
┌─────────────────────┐
│ Manage Open Trades  │
│ (Check Break-Even)  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐      NO     ┌──────────────────┐
│ Can This EA Trade?  │─────────────>│ Wait for Next    │──> RETURN
│ (Coordination Check)│              │ Tick             │
└──────────┬──────────┘              └──────────────────┘
           │ YES
           ▼
┌─────────────────────┐      NO     ┌──────────────────┐
│ New Bar?            │─────────────>│ Wait for New Bar │──> RETURN
└──────────┬──────────┘              └──────────────────┘
           │ YES
           ▼
┌─────────────────────┐      NONE   ┌──────────────────┐
│ Generate Signal     │─────────────>│ No Action        │──> RETURN
└──────────┬──────────┘              └──────────────────┘
           │ BUY/SELL
           ▼
┌─────────────────────┐
│ Open Trade          │
│ Set SL & TP         │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Update Coordination │
│ (HasActiveTrade=1)  │
└─────────────────────┘
```

## 🎯 Break-Even Trigger System

```
TRADE OPENED (BUY @ 1.1000)
│
│ SL = 1.0970 (-30 pips)
│ TP = 1.1060 (+60 pips)
│
▼
┌────────────────────────────────────────┐
│ Monitoring Loop (Every Tick)           │
│                                        │
│ Current Price: 1.1000 → 1.1005 → ...  │
└────────────┬───────────────────────────┘
             │
             ▼
        Current Price = 1.1020 (+20 pips) ✓
             │
             ▼
┌────────────────────────────────────────┐
│ BREAK-EVEN TRIGGERED!                  │
│                                        │
│ Old SL: 1.0970                        │
│ New SL: 1.1005 (Entry + 5 pips)      │
└────────────┬───────────────────────────┘
             │
             ▼
┌────────────────────────────────────────┐
│ OrderModify() → SL Updated            │
└────────────┬───────────────────────────┘
             │
             ▼
┌────────────────────────────────────────┐
│ UpdateCoordination(false)             │
│ → Other EAs Can Now Trade             │
└────────────────────────────────────────┘
```

## 🔒 Coordination State Machine

### Scenario 1: First Trade Opens

```
TIME: 10:00

State: No Active Trades
┌─────────────────────────────────────────┐
│ Coordination.txt                        │
│ ─────────────────                       │
│ (empty or all EAs have HasActive=0)    │
└─────────────────────────────────────────┘

EA1 (EURUSD) checks CanThisEATrade()
  ├─> No daily loss limit      ✓
  ├─> No active trade self     ✓
  └─> No other EA active       ✓
      RESULT: TRUE → Can Trade

EA1 Opens BUY Trade @ 1.1000
  └─> UpdateCoordination(true)

┌─────────────────────────────────────────┐
│ Coordination.txt                        │
│ ─────────────────                       │
│ 100001;EURUSD;1  ← EA1 Active          │
└─────────────────────────────────────────┘

EA2 (GBPUSD) checks CanThisEATrade()
  ├─> No daily loss limit      ✓
  ├─> No active trade self     ✓
  └─> Other EA has active      ✗ (EA1=1)
      RESULT: FALSE → Wait

EA3 (XAUUSD) checks CanThisEATrade()
  ├─> No daily loss limit      ✓
  ├─> No active trade self     ✓
  └─> Other EA has active      ✗ (EA1=1)
      RESULT: FALSE → Wait
```

### Scenario 2: Break-Even Reached

```
TIME: 10:15

EA1 Trade reaches +20 pips
  └─> MoveToBreakEven()
      └─> SL moved to 1.1005
      └─> UpdateCoordination(false)

┌─────────────────────────────────────────┐
│ Coordination.txt                        │
│ ─────────────────                       │
│ 100001;EURUSD;0  ← EA1 at BE           │
└─────────────────────────────────────────┘

EA2 (GBPUSD) checks CanThisEATrade()
  ├─> No daily loss limit      ✓
  ├─> No active trade self     ✓
  └─> No other EA active       ✓ (EA1=0 now)
      RESULT: TRUE → Can Trade!

EA2 Opens SELL Trade @ 1.2500
  └─> UpdateCoordination(true)

┌─────────────────────────────────────────┐
│ Coordination.txt                        │
│ ─────────────────                       │
│ 100001;EURUSD;0                        │
│ 100002;GBPUSD;1  ← EA2 Active          │
└─────────────────────────────────────────┘

EA3 (XAUUSD) checks CanThisEATrade()
  └─> Other EA has active      ✗ (EA2=1)
      RESULT: FALSE → Wait
```

### Scenario 3: Daily Loss Limit

```
TIME: 14:30

Account State:
  Starting Balance: €10,000
  Current Equity:   €9,450
  Daily Loss:       €550 (-5.5%)

EA1 CheckDailyLossLimit()
  └─> 5.5% >= 5.0% ✗
      └─> CloseAllTrades()
      └─> DailyLossLimitReached = true
      └─> WriteDailyLossFile(true)

┌─────────────────────────────────────────┐
│ Daily_Loss.txt                          │
│ ─────────────────                       │
│ 12;1  ← Day 12, Limit Reached          │
└─────────────────────────────────────────┘

ALL EAs (EA1, EA2, EA3) next tick:
  └─> ReadDailyLossFile() = true
      └─> CanThisEATrade() = FALSE
          └─> BLOCKED for rest of day

┌─────────────────────────────────────────┐
│ ALL TRADING STOPPED                     │
│ Waiting for new day...                  │
└─────────────────────────────────────────┘

NEXT DAY (00:00):

EA1 CheckNewDay()
  └─> New day detected
      └─> Reset daily variables
      └─> ResetDailyLossFile()

┌─────────────────────────────────────────┐
│ Daily_Loss.txt                          │
│ ─────────────────                       │
│ 13;0  ← Day 13, No Limit               │
└─────────────────────────────────────────┘

ALL EAs: Trading ENABLED again
```

## 💰 Risk Management Flow

```
┌─────────────────────────────────────────┐
│ TRADE SIGNAL GENERATED                  │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ Calculate Lot Size                      │
│                                         │
│ Account Balance: €10,000                │
│ Risk Per Trade:  1.0%                  │
│ Risk Amount:     €100                   │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ Symbol: EURUSD                          │
│ Stop Loss: 30 pips                     │
│ Pip Value: €10/lot                     │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ Lot Size Calculation:                   │
│                                         │
│ Lots = Risk Amount / (SL × Pip Value)  │
│      = €100 / (30 × €10)               │
│      = €100 / €300                      │
│      = 0.33 lots                        │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ Normalize to Broker Requirements        │
│                                         │
│ Min Lot: 0.01                          │
│ Max Lot: 100.00                        │
│ Lot Step: 0.01                         │
│                                         │
│ Final Lot Size: 0.33                   │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│ ORDER SENT                              │
│                                         │
│ Symbol: EURUSD                         │
│ Type:   BUY                            │
│ Lots:   0.33                           │
│ SL:     -30 pips (€99 max loss)        │
│ TP:     +60 pips (€198 max profit)     │
└─────────────────────────────────────────┘
```

## 📈 Multi-Symbol Portfolio View

```
FTMO ACCOUNT: €10,000
Daily Loss Limit: €500 (5%)
═══════════════════════════════════════════════════════════

┌─────────────────────────────────────────────────────────┐
│ EA #1: EURUSD (Magic: 100001)                           │
├─────────────────────────────────────────────────────────┤
│ Status:      ● ACTIVE (Trade open, at Break-Even)      │
│ Position:    BUY 0.30 lots @ 1.1000                    │
│ Current P&L: +€45 (trade protected at BE)              │
│ Risk:        1.0% per trade                            │
│ SL/TP:       30/60 pips                                │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ EA #2: GBPUSD (Magic: 100002)                           │
├─────────────────────────────────────────────────────────┤
│ Status:      ● ACTIVE (Trade open, NOT at BE)          │
│ Position:    SELL 0.25 lots @ 1.2500                   │
│ Current P&L: +€30 (approaching BE trigger)             │
│ Risk:        1.0% per trade                            │
│ SL/TP:       40/80 pips                                │
│              ⚠️ Other EAs WAITING                       │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ EA #3: XAUUSD (Magic: 100003)                           │
├─────────────────────────────────────────────────────────┤
│ Status:      ⏸ WAITING (EA #2 active without BE)       │
│ Position:    None                                       │
│ Current P&L: €0                                         │
│ Risk:        0.5% per trade                            │
│ SL/TP:       100/200 pips                              │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│ EA #4: USDJPY (Magic: 100004)                           │
├─────────────────────────────────────────────────────────┤
│ Status:      ⏸ WAITING (EA #2 active without BE)       │
│ Position:    None                                       │
│ Current P&L: €0                                         │
│ Risk:        1.0% per trade                            │
│ SL/TP:       25/50 pips                                │
└─────────────────────────────────────────────────────────┘

═══════════════════════════════════════════════════════════
Total Daily P&L:     +€75 (+0.75%)
Daily Loss Remaining: €575 (4.25% buffer)
═══════════════════════════════════════════════════════════
```

## 🔄 File System Interaction

```
MetaTrader 4 Terminal
│
├─ MT4/MQL4/Experts/
│  └─ FTMO_EA.mq4  ← Main EA Code
│
└─ MT4/Files/Common/  ← Shared Access
   │
   ├─ FTMO_EA_Coordination.txt
   │  │
   │  │ Format: MagicNumber;Symbol;HasActiveTrade
   │  │
   │  ├─ Written by: All EA instances
   │  ├─ Read by: All EA instances
   │  └─ Updates: When trade opens/reaches BE
   │
   └─ FTMO_Daily_Loss.txt
      │
      │ Format: Day;LimitReached
      │
      ├─ Written by: Any EA hitting 5% loss
      ├─ Read by: All EA instances (every tick)
      └─ Reset: Automatically at 00:00 each day

┌───────────────────────────────────────────────┐
│ File Access Pattern                           │
│                                               │
│ Every Tick:                                   │
│   1. Read Daily_Loss.txt → Check if blocked  │
│   2. Read Coordination.txt → Check if can trade│
│                                               │
│ On Trade Open:                                │
│   3. Write Coordination.txt → Set active=1   │
│                                               │
│ On Break-Even:                                │
│   4. Write Coordination.txt → Set active=0   │
│                                               │
│ On 5% Loss:                                   │
│   5. Write Daily_Loss.txt → Block all EAs    │
└───────────────────────────────────────────────┘
```

## 🎯 FTMO Challenge Progress Timeline

```
Week 1: BUILDING FOUNDATION
├─ Day 1-2: Setup & Testing
│  └─ Install EA on EURUSD (conservative)
│      Risk: 0.5%, Profit: +1.5%
│
├─ Day 3-4: Add Second Symbol
│  └─ Add GBPUSD
│      Risk: 0.5%, Profit: +2.8%
│
└─ Day 5-7: Monitor & Optimize
   └─ Fine-tune parameters
       Risk: 0.8%, Profit: +4.2%

Week 2: SCALING UP
├─ Day 8-10: Increase Risk
│  └─ Risk: 1.0% per trade
│      Profit: +6.5%
│
└─ Day 11-14: Add Third Symbol
   └─ Add XAUUSD (conservative)
       Risk: 0.5% (gold), Profit: +8.3%

Week 3: ACCELERATING
├─ Day 15-18: Full Portfolio
│  └─ All 3-4 EAs active
│      Profit: +10.5% ✓ TARGET REACHED
│
└─ Day 19-21: Consolidation
   └─ Profit: +11.8%

Week 4: PROTECTING
└─ Day 22-30: Reduce Risk
   └─ Risk: 0.3-0.5% per trade
       Protect profits
       Final: +12.5% ✓✓

═══════════════════════════════════════════════
CHALLENGE PASSED!
Next: Verification Phase (Same strategy, 5% target)
═══════════════════════════════════════════════
```

## 🏗️ System Architecture Summary

```
┌─────────────────────────────────────────────────────────────┐
│                     USER LAYER                              │
│                                                             │
│  ┌─────────────┐  ┌──────────────┐  ┌─────────────┐      │
│  │ MetaTrader 4│  │ Configuration│  │Documentation│      │
│  │   Charts    │  │   Settings   │  │   Guides    │      │
│  └─────────────┘  └──────────────┘  └─────────────┘      │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                  EA INSTANCES LAYER                         │
│                                                             │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ EURUSD EA│  │ GBPUSD EA│  │ XAUUSD EA│  │ USDJPY EA│  │
│  │ (100001) │  │ (100002) │  │ (100003) │  │ (100004) │  │
│  └─────┬────┘  └─────┬────┘  └─────┬────┘  └─────┬────┘  │
└────────┼─────────────┼─────────────┼─────────────┼────────┘
         │             │             │             │
┌────────▼─────────────▼─────────────▼─────────────▼────────┐
│              COORDINATION LAYER                            │
│                                                            │
│  ┌────────────────────┐      ┌─────────────────────┐     │
│  │ Coordination File  │      │ Daily Loss File     │     │
│  │ ─────────────────  │      │ ───────────────     │     │
│  │ • Trade Status     │      │ • Loss Tracking     │     │
│  │ • EA Synchronization│     │ • Day Reset        │     │
│  └────────────────────┘      └─────────────────────┘     │
└────────────────────────┬───────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                  RISK MANAGEMENT LAYER                      │
│                                                             │
│  • Position Sizing    • Daily Loss Monitor                 │
│  • Break-Even Logic   • Account Protection                 │
│  • SL/TP Management   • Equity Tracking                    │
└────────────────────────┬────────────────────────────────────┘
                         │
┌────────────────────────▼────────────────────────────────────┐
│                   BROKER/MARKET LAYER                       │
│                                                             │
│  • Order Execution    • Price Feeds                        │
│  • Position Management• Trade Confirmations               │
└─────────────────────────────────────────────────────────────┘
```

---

**Deze diagrammen helpen te visualiseren hoe alle componenten samenwerken**

**Versie**: 1.0  
**Voor**: FTMO Challenge EA
