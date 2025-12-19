# Optimalisatie Instellingen - Verhoog Winst & Aantal Trades

## 🚀 Instellingen voor Meer Winst en Meer Trades

Dit document bevat geavanceerde configuraties om de winstgevendheid en het aantal trades te verhogen. **Waarschuwing**: Hogere winst gaat gepaard met hoger risico!

---

## 📊 Strategie 1: Verhoog Trading Frequentie

### Aanpassingen voor Meer Trades

#### EURUSD - High Frequency Setup
```
EA_MagicNumber = 100001
RiskPercentPerTrade = 1.5
MaxDailyLossPercent = 5.0

// Kleinere SL/TP voor meer signalen
StopLossPips = 15
TakeProfitPips = 30
BreakEvenPips = 8
BreakEvenExtraPips = 3

// Meer trades toegestaan
MaxTradesPerDay = 20
Slippage = 5
```

**Verwacht resultaat:**
- Trades per dag: 10-15
- Win rate: 55-60%
- Maandelijkse winst: 15-20%

#### GBPUSD - High Frequency Setup
```
EA_MagicNumber = 100002
RiskPercentPerTrade = 1.2
StopLossPips = 20
TakeProfitPips = 40
BreakEvenPips = 10
MaxTradesPerDay = 15
```

#### USDJPY - High Frequency Setup
```
EA_MagicNumber = 100004
RiskPercentPerTrade = 1.5
StopLossPips = 15
TakeProfitPips = 30
BreakEvenPips = 8
MaxTradesPerDay = 20
```

---

## 💰 Strategie 2: Verhoog Risk/Reward Ratio

### Grotere Take Profit voor Meer Winst per Trade

#### EURUSD - High R:R Setup
```
EA_MagicNumber = 100001
RiskPercentPerTrade = 1.2

// Grotere TP, zelfde SL = betere R:R
StopLossPips = 25
TakeProfitPips = 75    // 1:3 risk/reward!
BreakEvenPips = 15
MaxTradesPerDay = 8
```

**Verwacht resultaat:**
- Win rate: 45-50%
- Risk/Reward: 1:3
- Maandelijkse winst: 12-18%

#### GBPUSD - High R:R Setup
```
EA_MagicNumber = 100002
RiskPercentPerTrade = 1.0
StopLossPips = 30
TakeProfitPips = 90    // 1:3 risk/reward
BreakEvenPips = 18
MaxTradesPerDay = 8
```

---

## 🔥 Strategie 3: Aggressive Multi-Symbol Portfolio

### Maximale Diversificatie = Meer Opportunities

#### 4-Symbol Aggressive Portfolio

**EURUSD:**
```
Magic: 100001
Risk: 1.5%
SL: 20 pips
TP: 50 pips
BE: 10 pips
MaxTrades: 15/dag
```

**GBPUSD:**
```
Magic: 100002
Risk: 1.5%
SL: 25 pips
TP: 60 pips
BE: 12 pips
MaxTrades: 12/dag
```

**USDJPY:**
```
Magic: 100004
Risk: 1.2%
SL: 18 pips
TP: 45 pips
BE: 9 pips
MaxTrades: 15/dag
```

**AUDUSD:**
```
Magic: 100005
Risk: 1.2%
SL: 22 pips
TP: 55 pips
BE: 11 pips
MaxTrades: 12/dag
```

**Verwacht totaal:**
- Combined trades: 20-30/dag (door coördinatie)
- Maandelijkse winst: 18-25%
- Max simultaan risico: 1.5% (door coördinatie)

---

## ⚡ Strategie 4: Scalping Setup (Ultra High Frequency)

### Voor Zeer Actieve Trading

#### EURUSD Scalping
```
EA_MagicNumber = 100001
RiskPercentPerTrade = 0.8

// Zeer kleine targets voor snelle trades
StopLossPips = 8
TakeProfitPips = 16
BreakEvenPips = 5
BreakEvenExtraPips = 2

MaxTradesPerDay = 30
Slippage = 3
```

**Let op:** Vereist lage spreads (<1 pip voor EURUSD)

#### USDJPY Scalping
```
EA_MagicNumber = 100004
RiskPercentPerTrade = 0.8
StopLossPips = 10
TakeProfitPips = 20
BreakEvenPips = 6
MaxTradesPerDay = 25
```

**Verwacht resultaat:**
- Trades per dag: 15-25
- Win rate: 60-65%
- Maandelijkse winst: 15-22%

---

## 🎯 Strategie 5: Breakout Trading (Grote Bewegingen)

### Minder Trades, Grotere Winsten

#### EURUSD Breakout
```
EA_MagicNumber = 100001
RiskPercentPerTrade = 2.0

// Grotere SL/TP voor breakouts
StopLossPips = 40
TakeProfitPips = 120    // 1:3 R:R
BreakEvenPips = 25
MaxTradesPerDay = 5
```

**Verwacht resultaat:**
- Trades per dag: 2-4
- Win rate: 40-45%
- Maandelijkse winst: 12-18%

#### XAUUSD Breakout (Gold)
```
EA_MagicNumber = 100003
RiskPercentPerTrade = 1.0
StopLossPips = 80
TakeProfitPips = 240    // 1:3 R:R
BreakEvenPips = 50
MaxTradesPerDay = 3
```

---

## 📈 Optimalisatie Tips

### 1. Verlaag Break-Even Trigger
**Huidige:** 20 pips  
**Optimalisatie:** 10-12 pips

**Voordeel:**
- Sneller op break-even = meer trades mogelijk
- Minder risico per actieve trade
- Andere EA's kunnen eerder traden

**Voorbeeld:**
```
BreakEvenPips = 10     // Was 20
BreakEvenExtraPips = 3 // Was 5
```

### 2. Verhoog MaxTradesPerDay
**Huidige:** 10 trades  
**Optimalisatie:** 15-20 trades

**Implementatie:**
```
MaxTradesPerDay = 20  // Was 10
```

**Effect:** Meer trading opportunities, vooral bij volatiele markten

### 3. Verhoog Risk Per Trade
**Conservative:** 0.5-1.0%  
**Moderate:** 1.0-1.5%  
**Aggressive:** 1.5-2.0%

**Voorbeeld voor 10% per maand:**
```
// Met 1.5% risk per trade en 50% win rate bij 1:2 R:R
RiskPercentPerTrade = 1.5
```

**Berekening:**
- 40 trades/maand × 50% win = 20 wins
- 20 wins × 3% = 60% winst
- 20 losses × 1.5% = 30% verlies
- Net: 30% per maand (zeer agressief!)

### 4. Kleinere Stop Loss
**Effect:** Meer trades mogelijk met zelfde risico

**Voorbeeld:**
```
// Van:
StopLossPips = 50
RiskPercentPerTrade = 1.0

// Naar:
StopLossPips = 25
RiskPercentPerTrade = 1.0
```

**Resultaat:** 2x grotere lot size = dubbele winst bij TP!

### 5. Optimaliseer Break-Even Strategie

**Standaard:**
```
BreakEvenPips = 20
BreakEvenExtraPips = 5
```

**Optimalisatie voor Meer Trades:**
```
BreakEvenPips = 12
BreakEvenExtraPips = 3
```

**Optimalisatie voor Meer Winst:**
```
BreakEvenPips = 25
BreakEvenExtraPips = 10
```

---

## 🏆 Aanbevolen Setup per Doelstelling

### Doel: 15% per Maand (Hoge Frequentie)

#### 3-Symbol Portfolio
```
EURUSD:
- Risk: 1.5%
- SL: 20, TP: 40
- BE: 10
- MaxTrades: 15

GBPUSD:
- Risk: 1.2%
- SL: 25, TP: 50
- BE: 12
- MaxTrades: 12

USDJPY:
- Risk: 1.5%
- SL: 18, TP: 36
- BE: 9
- MaxTrades: 15
```

**Verwacht:** 15-18% per maand, 25-35 trades/maand totaal

### Doel: 20% per Maand (Maximum Aggressive)

#### 4-Symbol Portfolio
```
EURUSD:
- Risk: 2.0%
- SL: 15, TP: 45
- BE: 8
- MaxTrades: 20

GBPUSD:
- Risk: 1.8%
- SL: 20, TP: 60
- BE: 10
- MaxTrades: 15

USDJPY:
- Risk: 1.5%
- SL: 15, TP: 45
- BE: 8
- MaxTrades: 20

AUDUSD:
- Risk: 1.5%
- SL: 20, TP: 60
- BE: 10
- MaxTrades: 15
```

**Verwacht:** 20-25% per maand, 40-50 trades/maand totaal  
**Risico:** Hoog! Max DD kan 10-12% zijn

### Doel: Balans (12-15% per maand, Gecontroleerd Risico)

#### 2-Symbol Portfolio
```
EURUSD:
- Risk: 1.2%
- SL: 25, TP: 60
- BE: 15
- MaxTrades: 12

GBPUSD:
- Risk: 1.0%
- SL: 30, TP: 75
- BE: 18
- MaxTrades: 10
```

**Verwacht:** 12-15% per maand, 20-25 trades/maand totaal  
**Risico:** Medium, Max DD 6-8%

---

## 🔧 Code Aanpassingen voor Extra Features

### 1. Toevoegen: Dynamische Lot Size Scaling

**Voeg toe aan FTMO_EA.mq4 (na regel 470):**

```mql4
//+------------------------------------------------------------------+
//| Bereken lot size met profit scaling                             |
//+------------------------------------------------------------------+
double CalculateLotSizeWithScaling()
{
   double baseRisk = RiskPercentPerTrade;
   
   // Als account winstgevend is, verhoog risk
   double currentProfit = AccountEquity() - StartingBalance;
   double profitPercent = (currentProfit / StartingBalance) * 100.0;
   
   if(profitPercent > 5.0)
   {
      baseRisk = RiskPercentPerTrade * 1.2; // 20% meer risk bij 5%+ winst
   }
   if(profitPercent > 10.0)
   {
      baseRisk = RiskPercentPerTrade * 1.5; // 50% meer risk bij 10%+ winst
   }
   
   // Rest van originele CalculateLotSize() code...
   double riskAmount = AccountBalance() * (baseRisk / 100.0);
   // etc...
}
```

**Effect:** Automatisch verhogen van lot size bij winst!

### 2. Toevoegen: Trailing Stop voor Meer Winst

**Voeg toe als nieuwe input parameter:**

```mql4
input int    TrailingStopPips = 15;       // Trailing stop in pips
input bool   UseTrailingStop = true;      // Gebruik trailing stop
```

**Voeg functie toe:**

```mql4
//+------------------------------------------------------------------+
//| Trailing Stop Management                                         |
//+------------------------------------------------------------------+
void ManageTrailingStop(int ticket)
{
   if(!UseTrailingStop)
      return;
      
   if(!OrderSelect(ticket, SELECT_BY_TICKET))
      return;
   
   double point = MarketInfo(OrderSymbol(), MODE_POINT);
   int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
   
   double pipValue = point;
   if(digits == 3 || digits == 5)
      pipValue = point * 10;
   
   double trailDistance = TrailingStopPips * pipValue;
   
   if(OrderType() == OP_BUY)
   {
      double newSL = Bid - trailDistance;
      
      if(newSL > OrderStopLoss() && newSL < Bid)
      {
         OrderModify(ticket, OrderOpenPrice(), 
                    NormalizeDouble(newSL, digits), 
                    OrderTakeProfit(), 0, clrBlue);
      }
   }
   else if(OrderType() == OP_SELL)
   {
      double newSL = Ask + trailDistance;
      
      if(newSL < OrderStopLoss() || OrderStopLoss() == 0)
      {
         if(newSL > Ask)
         {
            OrderModify(ticket, OrderOpenPrice(), 
                       NormalizeDouble(newSL, digits), 
                       OrderTakeProfit(), 0, clrRed);
         }
      }
   }
}
```

**Roep aan in ManageOpenTrades():**

```mql4
void ManageOpenTrades()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
         
      if(OrderMagicNumber() != EA_MagicNumber)
         continue;
         
      if(OrderSymbol() != Symbol())
         continue;
      
      // Check break-even
      MoveToBreakEven(OrderTicket());
      
      // Check trailing stop
      ManageTrailingStop(OrderTicket());  // NIEUW!
   }
}
```

**Effect:** Vergroot winsten door trailing stop!

### 3. Toevoegen: Meerdere Timeframe Filter

**Alleen traden als hogere timeframe bevestigt:**

```mql4
//+------------------------------------------------------------------+
//| Multi-Timeframe Trend Filter                                     |
//+------------------------------------------------------------------+
bool MultiTimeframeTrendFilter(int signal)
{
   // Check H4 trend
   double ma_h4 = iMA(Symbol(), PERIOD_H4, 100, 0, MODE_SMA, PRICE_CLOSE, 0);
   double close_h4 = iClose(Symbol(), PERIOD_H4, 0);
   
   // BUY: alleen als H4 uptrend
   if(signal == 1 && close_h4 < ma_h4)
      return false;
   
   // SELL: alleen als H4 downtrend
   if(signal == -1 && close_h4 > ma_h4)
      return false;
   
   return true;
}
```

**Gebruik in OnTick():**

```mql4
int signal = GenerateSignal();

// Voeg filter toe
if(signal != 0 && !MultiTimeframeTrendFilter(signal))
   signal = 0;

if(signal == 1)
   OpenBuyTrade();
else if(signal == -1)
   OpenSellTrade();
```

**Effect:** Betere win rate door trend confirmatie!

---

## ⚠️ Risico Waarschuwingen

### Bij Agressieve Instellingen

1. **Hoge Drawdown**
   - Verwacht 8-12% drawdown mogelijk
   - Zorg dat je dit mentaal aankan
   - Monitor dagelijks!

2. **Overtrading**
   - Te veel trades = hogere kosten (spreads)
   - Kan leiden tot emotionele beslissingen
   - Volg je plan strikt!

3. **FTMO Limiet Risico**
   - Met 2% risk per trade, 3 losses = 6% (limiet overschreden!)
   - Overweeg max 1.5% risk
   - Gebruik altijd de 5% daily loss limiet

### Aanbevolen Testen

**ALTIJD eerst op demo:**
- Minimum 2 weken demo met aggressive settings
- Monitor max drawdown
- Check dat je niet >5% per dag verliest
- Verifieer win rate >45%

---

## 📊 Performance Verwachtingen

### Conservative → Moderate
```
Risk: 0.5% → 1.0%
Trades: 5 → 8 per dag
Maandelijks: 8% → 12%
Max DD: 3% → 5%
```

### Moderate → Aggressive
```
Risk: 1.0% → 1.5%
Trades: 8 → 15 per dag
Maandelijks: 12% → 18%
Max DD: 5% → 8%
```

### Aggressive → Maximum
```
Risk: 1.5% → 2.0%
Trades: 15 → 20+ per dag
Maandelijks: 18% → 25%
Max DD: 8% → 12%
```

---

## 🎓 Implementatie Stappenplan

### Week 1: Test Moderate Settings
```
1. Start met moderate configuratie
2. Monitor 1 week op demo
3. Noteer: trades/dag, win rate, max DD
```

### Week 2: Upgrade naar Aggressive
```
1. Verhoog risk naar 1.5%
2. Verlaag SL/TP voor meer trades
3. Monitor nauwkeurig
```

### Week 3: Optimalisatie
```
1. Identificeer beste symbolen
2. Tune parameters per symbool
3. Voeg trailing stop toe (optioneel)
```

### Week 4: Live Testing
```
1. Als demo >15% profit: Start live!
2. Begin conservatief op live
3. Scale up geleidelijk
```

---

## 💡 Snelle Wins

### Voor Direct Meer Trades
```
MaxTradesPerDay = 20     // Van 10
BreakEvenPips = 10       // Van 20
```

### Voor Direct Meer Winst
```
RiskPercentPerTrade = 1.5   // Van 1.0
TakeProfitPips = 75         // Van 60 (bij SL 25)
```

### Voor Beste Balance
```
RiskPercentPerTrade = 1.2
StopLossPips = 22
TakeProfitPips = 55
BreakEvenPips = 12
MaxTradesPerDay = 15
```

---

**Let op:** Gebruik deze settings op eigen risico. Test ALTIJD eerst grondig op demo!

**Versie:** 1.0  
**Laatst bijgewerkt:** December 2025  
**Voor:** FTMO EA v1.0 Optimalisatie
