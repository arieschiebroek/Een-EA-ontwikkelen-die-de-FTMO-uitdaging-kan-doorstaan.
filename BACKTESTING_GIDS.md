# Backtesting & Parameter Optimalisatie Gids

## 🧪 Hoe Test Je de EA voor 1 Jaar met Verschillende Instellingen

Je vraag gaat over **backtesting** - het testen van de EA op historische data. Dit doe je met de **Strategy Tester** in MetaTrader 4, niet door de EA op een chart te slepen.

---

## 📊 Stap 1: Open Strategy Tester

### In MetaTrader 4:
1. Klik op **View** menu → **Strategy Tester**
2. Of druk op **Ctrl + R**
3. Een nieuw venster "Strategy Tester" opent onderaan je scherm

### Strategy Tester Interface:
```
┌─────────────────────────────────────────────┐
│ [Settings] [Results] [Graph] [Report]      │
├─────────────────────────────────────────────┤
│ Expert Advisor:  [Selecteer EA ▼]          │
│ Symbol:          [EURUSD ▼]                 │
│ Period:          [H1 ▼]                     │
│ Model:           [Every tick ▼]             │
│ Date Range:      [2024.01.01 - 2024.12.31] │
│ Optimization:    [ ] Enabled                │
│                                              │
│ [Expert Properties] [Start] [Stop]          │
└─────────────────────────────────────────────┘
```

---

## ⚙️ Stap 2: Configureer de Backtest

### Basis Instellingen:

**1. Expert Advisor:** Selecteer `FTMO_EA`

**2. Symbol:** Kies het symbool (bijv. `EURUSD`)

**3. Period:** Kies timeframe
   - `H1` (aanbevolen voor deze EA)
   - Of andere timeframe

**4. Model:** Kies nauwkeurigheid
   - **Every tick** (meest nauwkeurig, langzaam)
   - **1 minute OHLC** (sneller, minder nauwkeurig)
   - **Open prices only** (snelst, minst nauwkeurig)
   
   ⚠️ **Aanbeveling:** Gebruik "Every tick" voor betrouwbare resultaten

**5. Date Range:** 
   - Van: `2024.01.01`
   - Tot: `2024.12.31`
   - Of een andere periode (minimaal 3-6 maanden aanbevolen)

**6. Spread:** 
   - Gebruik huidige spread van je broker
   - Of stel handmatig in (bijv. 10 points voor EURUSD)

---

## 🎯 Stap 3: Stel Parameters In

### Klik op "Expert properties" knop

Je ziet nu hetzelfde scherm als wanneer je de EA op een chart sleept:

```
┌──────────────────────────────────────────────┐
│ FTMO_EA Properties                           │
├──────────────────────────────────────────────┤
│ [Inputs] [Testing] [Optimization]            │
│                                               │
│ EA_MagicNumber          100001               │
│ EA_Comment              "FTMO_EA"            │
│ RiskPercentPerTrade     1.0                  │
│ MaxDailyLossPercent     5.0                  │
│ StopLossPips            50                   │
│ TakeProfitPips          100                  │
│ BreakEvenPips           20                   │
│ BreakEvenExtraPips      5                    │
│ MaxTradesPerDay         10                   │
│ Slippage                3                    │
│                                               │
│ [OK] [Cancel]                                │
└──────────────────────────────────────────────┘
```

### Pas Parameters Aan:

**Bijvoorbeeld voor High Frequency test:**
```
RiskPercentPerTrade = 1.5
StopLossPips = 15
TakeProfitPips = 30
BreakEvenPips = 8
BreakEvenExtraPips = 3
MaxTradesPerDay = 20
```

---

## 🚀 Stap 4: Start de Backtest

### Klik op "Start" knop

De backtest begint nu te draaien. Je ziet:
- **Groene lijn** = Equity curve
- **Progress bar** onderaan
- **Journal tab** toont logs

### Backtest duurt:
- 1 jaar data op H1 = 5-15 minuten (afhankelijk van PC)
- Met "Every tick" model = langer
- Met "Open prices" model = sneller

---

## 📈 Stap 5: Analyseer Resultaten

### Na voltooiing zie je in de tabs:

#### **Results Tab** - Alle trades:
```
┌────────────────────────────────────────────────────┐
│ Time        │ Type │ Lots │ Price   │ S/L    │ T/P │
├────────────────────────────────────────────────────┤
│ 2024.01.02  │ buy  │ 0.10 │ 1.1000  │ 1.0970 │ ... │
│ 2024.01.05  │ sell │ 0.10 │ 1.0990  │ 1.1020 │ ... │
│ ...         │ ...  │ ...  │ ...     │ ...    │ ... │
└────────────────────────────────────────────────────┘
```

#### **Graph Tab** - Equity curve:
```
Visualisatie van account groei over tijd
(Moet een opwaartse trend laten zien)
```

#### **Report Tab** - Statistieken:
```
═══════════════════════════════════════════════
Total net profit:        €1,234.56
Gross profit:            €3,456.78
Gross loss:              €2,222.22

Profit factor:           1.56
Expected payoff:         €12.34

Total trades:            100
Win rate:                52%

Maximal drawdown:        €345.67 (3.46%)

═══════════════════════════════════════════════
```

### ✅ Wat te Checken:

**1. Winstgevendheid:**
- Total net profit > 0
- Profit factor > 1.5
- Expected payoff > 0

**2. Win Rate:**
- Minimaal 45-50%
- Bij 1:2 risk/reward is 40%+ acceptabel

**3. Drawdown:**
- Maximal drawdown < 10% (FTMO limiet)
- Relative drawdown < 15%

**4. Aantal Trades:**
- Minimaal 50-100 trades voor betrouwbare statistiek
- Te weinig trades = niet conclusief

**5. Equity Curve:**
- Steady upward trend (goed)
- Veel dips en recovery (risicovol)
- Flat lijn (strategie werkt niet)

---

## 🔧 Stap 6: Parameter Optimalisatie

### Voor Automatische Optimalisatie:

**1. Schakel "Optimization" aan** (checkbox in Strategy Tester)

**2. Klik "Expert properties" → "Optimization" tab**

**3. Selecteer parameters om te optimaliseren:**

```
┌──────────────────────────────────────────────────┐
│ Parameter            │ Start │ Step │ Stop  │ □  │
├──────────────────────────────────────────────────┤
│ RiskPercentPerTrade  │ 0.5   │ 0.25 │ 2.0   │ ☑  │
│ StopLossPips         │ 15    │ 5    │ 50    │ ☑  │
│ TakeProfitPips       │ 30    │ 10   │ 100   │ ☑  │
│ BreakEvenPips        │ 8     │ 2    │ 25    │ ☑  │
│ MaxTradesPerDay      │ 5     │ 5    │ 20    │ ☑  │
└──────────────────────────────────────────────────┘
```

**4. Klik "Start"**

MT4 test nu ALLE combinaties:
- RiskPercent: 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0
- StopLoss: 15, 20, 25, 30, 35, 40, 45, 50
- etc.

⚠️ **Let op:** Dit kan UREN duren! (duizenden combinaties)

**5. Sorteer resultaten op "Profit factor" of "Total net profit"**

**6. Selecteer beste combinatie en noteer de parameters**

---

## 📋 Praktisch Voorbeeld: Test EURUSD Settings

### Test 1: Conservative Setup

```
1. Open Strategy Tester
2. Expert Advisor: FTMO_EA
3. Symbol: EURUSD
4. Period: H1
5. Model: Every tick
6. Date: 2024.01.01 - 2024.12.31

7. Expert Properties → Inputs:
   RiskPercentPerTrade = 0.5
   StopLossPips = 30
   TakeProfitPips = 60
   BreakEvenPips = 15
   MaxTradesPerDay = 5

8. Klik Start
9. Wacht 10-15 minuten
10. Check resultaten
```

**Verwacht:**
- Profit: 8-12% per jaar
- Drawdown: < 5%
- Trades: 50-80

### Test 2: Aggressive Setup

```
Gebruik zelfde stappen maar met:
   RiskPercentPerTrade = 1.5
   StopLossPips = 15
   TakeProfitPips = 30
   BreakEvenPips = 8
   MaxTradesPerDay = 20
```

**Verwacht:**
- Profit: 15-25% per jaar
- Drawdown: 8-12%
- Trades: 150-250

### Vergelijk Resultaten:

| Setup        | Profit | DD   | Trades | PF   |
|--------------|--------|------|--------|------|
| Conservative | 10%    | 4%   | 65     | 1.8  |
| Aggressive   | 20%    | 11%  | 180    | 1.5  |

Kies de setup die past bij je risico profiel.

---

## 🎓 Geavanceerde Optimalisatie Tips

### 1. Forward Testing

Na backtest op 2024 data:
```
Test op 2023 data (out-of-sample)
Als resultaten vergelijkbaar → Goede parameters!
Als resultaten slechter → Overfitting!
```

### 2. Walk-Forward Analysis

Test op rollende perioden:
```
Periode 1: 2024 Q1-Q2 (train) → Q3 (test)
Periode 2: 2024 Q2-Q3 (train) → Q4 (test)
etc.
```

### 3. Multi-Symbol Testing

Test elk symbool apart:
```
EURUSD: Test met parameters X
GBPUSD: Test met parameters Y
XAUUSD: Test met parameters Z
```

Gebruik beste parameters per symbool!

### 4. Robustness Testing

Test met verschillende spreads:
```
Test 1: Spread = 5 points (optimistisch)
Test 2: Spread = 10 points (realistisch)
Test 3: Spread = 20 points (pessimistisch)
```

Als strategie werkt in alle scenarios → Robuust!

---

## ⚠️ Veelgemaakte Fouten bij Backtesting

### ❌ FOUT 1: Te Korte Periode
```
Backtest: 1 maand data
Probleem: Niet genoeg trades, niet representatief
Oplossing: Minimaal 6-12 maanden
```

### ❌ FOUT 2: Overfitting
```
Optimalisatie: Test 1000 combinaties op 2024 data
Probleem: Parameters werken perfect op 2024 maar niet op 2025
Oplossing: Gebruik forward testing en walk-forward
```

### ❌ FOUT 3: Te Optimistisch Model
```
Model: "Open prices only"
Probleem: Niet realistisch, te weinig slippage
Oplossing: Gebruik "Every tick" voor betrouwbare resultaten
```

### ❌ FOUT 4: Slechte Data Kwaliteit
```
Backtest op gratis data met gaps
Probleem: Resultaten kloppen niet
Oplossing: Gebruik data van je broker of premium data
```

### ❌ FOUT 5: Geen Spread/Commissie
```
Backtest zonder kosten
Probleem: Resultaten te rooskleurig
Oplossing: Stel realistic spread in (10-20 points)
```

---

## 📊 Interpretatie van Backtest Resultaten

### Goede Resultaten ✅

```
Total net profit:     €1,500+ (voor €10k account)
Profit factor:        > 1.5
Win rate:             45-60%
Max drawdown:         < 10%
Total trades:         100+
Sharp ratio:          > 1.0
Recovery factor:      > 3.0
```

### Acceptabele Resultaten ⚠️

```
Total net profit:     €800-1,500
Profit factor:        1.2-1.5
Win rate:             40-45%
Max drawdown:         10-15%
```

### Slechte Resultaten ❌

```
Total net profit:     < €500 of negatief
Profit factor:        < 1.2
Win rate:             < 40%
Max drawdown:         > 15%
Total trades:         < 50
```

---

## 🚀 Van Backtest naar Live Trading

### Stappen na Succesvolle Backtest:

**1. Backtest Validatie (Week 1)**
```
✓ Test op meerdere jaren (2022, 2023, 2024)
✓ Test op meerdere symbolen
✓ Forward test op out-of-sample data
✓ Check robustness (verschillende spreads)
```

**2. Demo Testing (Week 2-4)**
```
✓ Gebruik backtest parameters op demo
✓ Monitor 2-4 weken
✓ Vergelijk met backtest resultaten
✓ Pas aan indien nodig
```

**3. Small Live Testing (Week 5-8)**
```
✓ Start met 50% van gewenste lot size
✓ Monitor nauwkeurig
✓ Check slippage, spreads, execution
```

**4. Full Live Trading (Week 9+)**
```
✓ Scale up naar volle lot size
✓ Blijf monitoren
✓ Pas parameters aan bij marktveranderingen
```

---

## 💡 Snelle Referentie: Backtest Checklist

### Voor je begint:
- [ ] Download/update historische data in MT4
- [ ] Controleer data kwaliteit (geen grote gaps)
- [ ] Noteer huidige broker spreads

### Setup backtest:
- [ ] Strategy Tester geopend (Ctrl+R)
- [ ] FTMO_EA geselecteerd
- [ ] Juiste symbool & timeframe (H1)
- [ ] Model: "Every tick"
- [ ] Periode: Minimaal 6 maanden
- [ ] Spread ingesteld

### Na backtest:
- [ ] Check profit factor > 1.5
- [ ] Check max drawdown < 10%
- [ ] Check win rate > 45%
- [ ] Check aantal trades > 50
- [ ] Noteer beste parameters

### Optimalisatie (optioneel):
- [ ] "Optimization" aangezet
- [ ] Parameters geselecteerd
- [ ] Range ingesteld (Start/Step/Stop)
- [ ] Sorteer op profit factor
- [ ] Noteer top 3 combinaties

---

## 🎯 Conclusie

**Om je vraag te beantwoorden:**

Je test de EA NIET door hem op een demo/real account chart te slepen. Je gebruikt de **Strategy Tester** (Ctrl+R) in MT4 om:

1. ✅ Te testen op 1 jaar historische data
2. ✅ Verschillende parameter combinaties te proberen
3. ✅ De beste instellingen te vinden
4. ✅ Performance te analyseren zonder risico

**Na backtesting** en **demo testing** pas dan ga je live met de beste parameters!

---

**Veel succes met het optimaliseren van je EA! 📈**

**Versie:** 1.0  
**Laatst bijgewerkt:** December 2025  
**Voor:** FTMO EA Backtesting
