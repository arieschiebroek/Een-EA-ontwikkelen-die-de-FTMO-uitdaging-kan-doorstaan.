# Configuratie Voorbeelden voor Verschillende Symbolen

Deze voorbeelden zijn geoptimaliseerd voor FTMO Challenge trading op een €10,000 account.

## 🥇 EURUSD - Low Volatility, High Liquidity

### Conservative (Aanbevolen voor Beginners)
```
EA_MagicNumber = 100001
EA_Comment = "FTMO_EURUSD"

// Risk Settings
RiskPercentPerTrade = 0.5
MaxDailyLossPercent = 5.0

// Stop Loss & Break-Even
StopLossPips = 30
TakeProfitPips = 60
BreakEvenPips = 15
BreakEvenExtraPips = 5

// Trading Settings
EnableTrading = true
MaxTradesPerDay = 5
Slippage = 3
```

### Moderate
```
EA_MagicNumber = 100001
RiskPercentPerTrade = 1.0
StopLossPips = 25
TakeProfitPips = 50
BreakEvenPips = 12
MaxTradesPerDay = 8
```

### Aggressive (Voor Ervaren Traders)
```
EA_MagicNumber = 100001
RiskPercentPerTrade = 1.5
StopLossPips = 20
TakeProfitPips = 40
BreakEvenPips = 10
MaxTradesPerDay = 10
```

---

## 🥈 GBPUSD - Medium Volatility

### Conservative
```
EA_MagicNumber = 100002
EA_Comment = "FTMO_GBPUSD"

RiskPercentPerTrade = 0.5
MaxDailyLossPercent = 5.0

StopLossPips = 40
TakeProfitPips = 80
BreakEvenPips = 20
BreakEvenExtraPips = 5

EnableTrading = true
MaxTradesPerDay = 5
Slippage = 5
```

### Moderate
```
EA_MagicNumber = 100002
RiskPercentPerTrade = 1.0
StopLossPips = 35
TakeProfitPips = 70
BreakEvenPips = 18
MaxTradesPerDay = 7
```

### Aggressive
```
EA_MagicNumber = 100002
RiskPercentPerTrade = 1.5
StopLossPips = 30
TakeProfitPips = 60
BreakEvenPips = 15
MaxTradesPerDay = 10
```

---

## 🥉 XAUUSD (Gold) - High Volatility

### Conservative (Sterk Aanbevolen voor Gold)
```
EA_MagicNumber = 100003
EA_Comment = "FTMO_XAUUSD"

RiskPercentPerTrade = 0.3
MaxDailyLossPercent = 5.0

StopLossPips = 100
TakeProfitPips = 200
BreakEvenPips = 50
BreakEvenExtraPips = 10

EnableTrading = true
MaxTradesPerDay = 3
Slippage = 10
```

### Moderate
```
EA_MagicNumber = 100003
RiskPercentPerTrade = 0.5
StopLossPips = 80
TakeProfitPips = 160
BreakEvenPips = 40
MaxTradesPerDay = 5
```

**Waarschuwing**: Gold is zeer volatiel. Gebruik altijd lagere risk% dan bij forex pairs.

---

## 💴 USDJPY - Low Spread, Predictable

### Conservative
```
EA_MagicNumber = 100004
EA_Comment = "FTMO_USDJPY"

RiskPercentPerTrade = 0.8
MaxDailyLossPercent = 5.0

StopLossPips = 25
TakeProfitPips = 50
BreakEvenPips = 12
BreakEvenExtraPips = 5

EnableTrading = true
MaxTradesPerDay = 6
Slippage = 3
```

### Moderate
```
EA_MagicNumber = 100004
RiskPercentPerTrade = 1.0
StopLossPips = 20
TakeProfitPips = 40
BreakEvenPips = 10
MaxTradesPerDay = 8
```

---

## 🇦🇺 AUDUSD - Commodity Currency

### Conservative
```
EA_MagicNumber = 100005
EA_Comment = "FTMO_AUDUSD"

RiskPercentPerTrade = 0.7
MaxDailyLossPercent = 5.0

StopLossPips = 35
TakeProfitPips = 70
BreakEvenPips = 18
BreakEvenExtraPips = 5

EnableTrading = true
MaxTradesPerDay = 5
Slippage = 4
```

---

## 🇨🇭 USDCHF - Safe Haven

### Conservative
```
EA_MagicNumber = 100006
EA_Comment = "FTMO_USDCHF"

RiskPercentPerTrade = 0.8
MaxDailyLossPercent = 5.0

StopLossPips = 30
TakeProfitPips = 60
BreakEvenPips = 15
BreakEvenExtraPips = 5

EnableTrading = true
MaxTradesPerDay = 5
Slippage = 3
```

---

## 🏦 Multi-Symbol Portfolio Configuratie

Voor optimale diversificatie, combineer meerdere symbolen met verschillende karakteristieken:

### Portfolio 1: Conservative Mix
```
EURUSD (100001): Risk 0.5%, SL 30
USDJPY (100004): Risk 0.5%, SL 25
GBPUSD (100002): Risk 0.5%, SL 40
```
**Totaal Max Risk**: 1.5% per cycle

### Portfolio 2: Balanced Mix
```
EURUSD (100001): Risk 1.0%, SL 30
XAUUSD (100003): Risk 0.5%, SL 100
GBPUSD (100002): Risk 0.8%, SL 35
```
**Totaal Max Risk**: 2.3% per cycle

### Portfolio 3: Aggressive Mix
```
EURUSD (100001): Risk 1.5%, SL 25
GBPUSD (100002): Risk 1.5%, SL 30
USDJPY (100004): Risk 1.0%, SL 20
AUDUSD (100005): Risk 1.0%, SL 35
```
**Totaal Max Risk**: 5.0% per cycle

**Belangrijk**: Door de coördinatie kan er maar 1 EA tegelijk actief zijn zonder break-even, dus het daadwerkelijke risico is altijd het risico van één trade.

---

## ⚙️ Aanpassen voor Specifieke Sessies

### London Session (07:00 - 16:00 GMT)
Best voor: GBPUSD, EURUSD, EURGBP
```
// Hogere volatiliteit toegestaan
StopLossPips = +5 extra
BreakEvenPips = sneller activeren
MaxTradesPerDay = meer trades
```

### New York Session (12:00 - 21:00 GMT)
Best voor: EURUSD, GBPUSD, XAUUSD
```
// Overlap met London = hoge liquiditeit
Normale instellingen OK
```

### Asian Session (00:00 - 09:00 GMT)
Best voor: USDJPY, AUDUSD, NZDUSD
```
// Lagere volatiliteit
StopLossPips = smaller OK
BreakEvenPips = korter OK
```

---

## 📊 Optimalisatie Tips per Symbool

### EURUSD
- ✅ Meest stable en voorspelbaar
- ✅ Lage spreads
- ✅ Perfect voor beginners
- 💡 Tip: Werkt goed met trend-following strategieën

### GBPUSD
- ⚠️ Hogere volatiliteit dan EURUSD
- ⚠️ Gevoelig voor Brexit/UK nieuws
- 💡 Tip: Vermijd trading rond BOE announcements

### XAUUSD (Gold)
- ⚠️ Zeer volatiel
- ⚠️ Hoge spreads
- ⚠️ Kan snel bewegen
- 💡 Tip: Alleen voor ervaren traders
- 💡 Tip: Gebruik time filters (vermijd illiquide tijden)

### USDJPY
- ✅ Lage spreads
- ✅ Goed voor scalping
- ⚠️ Gevoelig voor BOJ policy
- 💡 Tip: Best tijdens Asian/London overlap

---

## 🎯 FTMO Challenge Optimalisatie

### Week 1: Start Conservatief
```
Alle symbolen:
RiskPercentPerTrade = 0.5%
Focus op: EURUSD + USDJPY (lage volatiliteit)
Doel: Build confidence, no losses
```

### Week 2-3: Scale Up
```
Als winst > 3%:
RiskPercentPerTrade = 0.8-1.0%
Voeg toe: GBPUSD
Doel: Accelerate naar 10%
```

### Week 4: Bereik Doel
```
Als winst > 8%:
Verlaag risk: RiskPercentPerTrade = 0.5%
Focus: Behoud winst, vermijd losses
Doel: Finish 10%+
```

---

## ⚠️ Belangrijke Waarschuwingen

### Spread Variatie
Spreads kunnen variëren per broker:
```
EURUSD: 0.5 - 2.0 pips
GBPUSD: 0.8 - 3.0 pips
XAUUSD: 2.0 - 5.0 pips
```
**Actie**: Test uw broker spreads en pas BreakEvenPips aan!

### Slippage
Bij hoge volatiliteit (nieuws):
```
Slippage = 3   # Normaal
Slippage = 10  # Bij high volatility (XAUUSD)
Slippage = 5   # Bij medium volatility (GBPUSD)
```

### Commission
Sommige brokers hebben commissie:
```
Als commissie > 0:
Pas TakeProfitPips aan om commissie te dekken
BreakEvenExtraPips = groter (om commissie te dekken)
```

---

## 🔧 Quick Setup Wizard

### Stap 1: Kies Uw Risk Profile
- **Conservative**: RiskPercentPerTrade = 0.5%
- **Moderate**: RiskPercentPerTrade = 1.0%
- **Aggressive**: RiskPercentPerTrade = 1.5%

### Stap 2: Kies Symbolen
- **Beginner**: EURUSD + USDJPY (2 EA's)
- **Intermediate**: EURUSD + GBPUSD + USDJPY (3 EA's)
- **Advanced**: EURUSD + GBPUSD + XAUUSD + USDJPY (4 EA's)

### Stap 3: Pas SL/TP aan voor Symbool
Gebruik bovenstaande voorbeelden

### Stap 4: Set Unique Magic Numbers
```
EURUSD  = 100001
GBPUSD  = 100002
XAUUSD  = 100003
USDJPY  = 100004
AUDUSD  = 100005
USDCHF  = 100006
etc.
```

### Stap 5: Test op Demo!
- Minimaal 1 week demo trading
- Verifieer coördinatie werkt
- Check daily loss limit werkt
- Monitor performance

---

## 📈 Verwachte Resultaten per Configuratie

### Conservative Setup
- **Verwacht**: 8-12% per maand
- **Max Drawdown**: 3-5%
- **Win Rate**: 45-55%
- **Risk/Reward**: 1:2

### Moderate Setup
- **Verwacht**: 10-15% per maand
- **Max Drawdown**: 5-8%
- **Win Rate**: 50-60%
- **Risk/Reward**: 1:2

### Aggressive Setup
- **Verwacht**: 12-20% per maand
- **Max Drawdown**: 8-12%
- **Win Rate**: 55-65%
- **Risk/Reward**: 1:2

**Let op**: Deze zijn schattingen. Daadwerkelijke resultaten hangen af van marktcondities en uw strategie implementatie.

---

## 🎓 Best Practices

1. **Start Klein**: Begin met 1-2 symbolen
2. **Test Grondig**: Minimaal 1 week demo
3. **Monitor Dagelijks**: Check logs en performance
4. **Pas Geleidelijk Aan**: Verander slechts 1 parameter tegelijk
5. **Houd Records**: Noteer welke settings werken

---

**Versie**: 1.0  
**Laatst bijgewerkt**: December 2025  
**Voor**: FTMO Challenge EA v1.0
