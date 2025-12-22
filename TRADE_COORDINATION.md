# Multi-EA Trade Coordination System

## Overzicht

Dit systeem implementeert een geavanceerde trade coordinatie tussen meerdere Expert Advisors om te voldoen aan strikte FTMO risk management regels.

## Nieuwe Regels

### 1. Break-Even Stop Loss
- **Wanneer**: Na X pips winst (instelbaar per EA, standaard 30 pips)
- **Actie**: Stop Loss wordt automatisch naar break-even (+2 pips voor spread) gezet
- **Signaal**: Dit geeft signaal dat een nieuwe trade geopend mag worden

### 2. Trade Coordinatie
- **Regel**: Er mag altijd maar **ÉÉN** EA een trade hebben waarvan de stop loss NIET op break-even staat
- **Logica**:
  - Trade 1 wordt geopend → Andere EA's wachten
  - Trade 1 bereikt break-even → Trade 2 mag nu geopend worden
  - Trade 2 bereikt break-even → Trade 3 mag nu geopend worden
  - Etc.

### 3. Dagelijkse Verlies Limiet (FTMO 5% Regel)
- **Limiet**: Maximaal 5% dagelijks verlies ($500 op $10,000 account)
- **Actie bij overschrijding**:
  - Alle open trades worden **onmiddellijk** gesloten
  - Trading wordt **geblokkeerd** voor de rest van de dag
  - Alle EA's respecteren dit blok automatisch

## Technische Implementatie

### Global Variables (MT4)
Het systeem gebruikt MT4 Global Variables voor cross-EA communicatie:

```mql4
FTMO_ActiveTrades      // Totaal aantal actieve trades
FTMO_TradesAtRisk      // Aantal trades NIET op breakeven
FTMO_DailyAllowed      // 1 = trading toegestaan, 0 = geblokkeerd
```

### Nieuwe Input Parameters

Alle EA's hebben nu een extra parameter:

```mql4
input int BreakEvenPips = 30;  // Pips winst voordat SL naar breakeven gaat
```

**Aanbevolen waardes per currency pair:**
- EURUSD: 30 pips
- USDJPY: 35 pips
- GBPUSD: 40 pips
- AUDUSD: 35 pips
- XAUUSD: 80 pips (volatiel)

### Workflow

#### Trade Opening
```
1. EA ontvangt trade signaal
2. Check: Is DailyTradingAllowed == 1?
   → NEE: Stop, trading geblokkeerd
3. Check: Is TradesAtRisk < 1?
   → NEE: Stop, er is al een trade at risk
4. Open nieuwe trade
5. Update GlobalVariables
```

#### Position Management
```
1. Elke tick: Check alle open trades
2. Voor elke trade:
   a. Bereken huidige profit in pips
   b. Is profit >= BreakEvenPips?
      → JA: Zet SL naar break-even (+2 pips)
      → Log: "Nieuwe trade mag nu worden geopend"
   c. Is profit >= TrailingStopLevel?
      → JA: Pas trailing stop aan
3. Update GlobalVariables
```

#### Daily Loss Check
```
1. Elke tick: Bereken Daily P&L
2. Is Daily P&L <= -$500?
   → JA:
     - Close ALLE open trades
     - Set DailyTradingAllowed = 0
     - Log waarschuwing
3. Nieuwe dag gedetecteerd?
   → JA:
     - Reset DailyTradingAllowed = 1
     - Reset DailyStartBalance
```

## Voordelen

### ✅ Risk Management
- Maximaal 1 trade at risk tegelijk
- Automatische break-even bescherming
- Strikte naleving van FTMO 5% regel

### ✅ Portfolio Diversificatie
- Meerdere currency pairs mogelijk
- Verschillende strategieën per pair
- Geen conflicten tussen EA's

### ✅ Psychologische Voordelen
- Geen stress over meerdere posities at risk
- Duidelijke regels en automatisering
- Focus op kwaliteit boven kwantiteit

## Gebruiksvoorbeeld

### Scenario 1: Succesvolle Trade Sequence
```
09:00 - EURUSD EA opent Buy @ 1.1000 (SL: 1.0920, TP: 1.1120)
        → TradesAtRisk = 1
        → USDJPY en GBPUSD EA's wachten

09:45 - EURUSD bereikt 1.1030 (30 pips winst)
        → SL automatisch naar 1.1002 (breakeven)
        → TradesAtRisk = 0
        → Print: "Nieuwe trade mag nu geopend worden"

10:00 - USDJPY EA opent Sell @ 110.50 (SL: 111.40, TP: 109.15)
        → TradesAtRisk = 1
        → GBPUSD EA wacht

10:30 - USDJPY bereikt 110.15 (35 pips winst)
        → SL automatisch naar 110.52 (breakeven)
        → TradesAtRisk = 0

11:00 - GBPUSD EA opent Buy @ 1.2500
        → TradesAtRisk = 1

12:00 - EURUSD hits TP @ 1.1120 (+120 pips profit)
        USDJPY hits TP @ 109.15 (+135 pips profit)
        GBPUSD bereikt breakeven → nieuwe trade mogelijk
```

### Scenario 2: Daily Loss Limit Bereikt
```
09:00 - EURUSD Buy geopend
09:15 - EURUSD bereikt breakeven
09:30 - USDJPY Sell geopend
09:35 - USDJPY hit SL (-90 pips, -$90 verlies)
10:00 - GBPUSD Buy geopend
10:15 - GBPUSD bereikt breakeven
10:30 - AUDUSD Sell geopend
10:45 - AUDUSD hit SL (-85 pips, -$85 verlies)
...
14:00 - Totaal verlies bereikt -$500
        → Alle open trades automatisch gesloten
        → DailyTradingAllowed = 0
        → Geen nieuwe trades meer vandaag
```

## Helper Functions

### UpdateGlobalTradeStatus()
```mql4
// Telt alle trades en bepaalt hoeveel at risk zijn
// Moet aangeroepen worden na elke trade open/close/modify
```

### IsOrderAtBreakEven(ticket)
```mql4
// Returns true als SL binnen 5 pips van open price staat
// Used om te bepalen of een trade nog at risk is
```

## Parameters Aanpassen

### Break-Even Pips
Pas aan op basis van:
- **Volatiliteit** van het pair (hoger = meer pips)
- **Spread** (hoger spread = meer pips nodig)
- **Backtesting** resultaten

**Conservatief** (veiliger):
```
EURUSD: 40 pips
USDJPY: 45 pips
GBPUSD: 50 pips
AUDUSD: 45 pips
XAUUSD: 100 pips
```

**Standaard** (aanbevolen):
```
EURUSD: 30 pips
USDJPY: 35 pips
GBPUSD: 40 pips
AUDUSD: 35 pips
XAUUSD: 80 pips
```

**Agressief** (meer trades, meer risico):
```
EURUSD: 20 pips
USDJPY: 25 pips
GBPUSD: 30 pips
AUDUSD: 25 pips
XAUUSD: 60 pips
```

## Monitoring

### Belangrijke Logs
Let op deze berichten in de Experts tab:

```
"Deze trade is nu 'at risk' - geen nieuwe trades tot breakeven bereikt is"
→ Nieuwe trade geopend

"Order X stop loss naar BREAK-EVEN gezet!"
→ Trade nu beschermd

">>> SIGNAAL: Nieuwe trade mag nu geopend worden door deze of andere EA <<<"
→ Volgende EA mag traden

"WAARSCHUWING: Dagelijkse verlies limiet bereikt! Alle trades sluiten."
→ Daily loss hit, trading gestopt

"Nieuwe handelsdag gestart. Dagelijkse balans reset: $X"
→ Nieuwe dag, trading weer toegestaan
```

### Global Variables Checken
In MT4: Tools → Global Variables

Kijk naar:
- `FTMO_TradesAtRisk`: Moet 0 of 1 zijn
- `FTMO_ActiveTrades`: Totaal aantal open trades
- `FTMO_DailyAllowed`: Moet 1 zijn (0 = trading geblokkeerd)

## Troubleshooting

### Probleem: EA's openen geen trades
**Check:**
1. Is `FTMO_TradesAtRisk` > 0?
   → Er is al een trade at risk, wacht tot breakeven
2. Is `FTMO_DailyAllowed` == 0?
   → Daily loss limiet bereikt, wacht tot morgen
3. Kijk in Experts tab voor waarschuwingen

### Probleem: Break-even wordt te vroeg/laat gezet
**Oplossing:** Pas `BreakEvenPips` parameter aan per EA

### Probleem: Meerdere trades openen tegelijk
**Check:**
1. Draaien de EA's op verschillende accounts?
2. Zijn de Global Variables correct geïnitialiseerd?
3. Herstart alle EA's om variabelen te resetten

### Probleem: Daily loss limiet niet gerespecteerd
**Check:**
1. Is `MaxDailyLoss` correct ingesteld ($500)?
2. Draait er een EA zonder de nieuwe coordinatie code?
3. Check of alle EA's dezelfde Global Variable namen gebruiken

## Best Practices

1. ✅ **Test eerst op demo**: Minimaal 2 weken met alle EA's
2. ✅ **Start conservatief**: Begin met grotere BreakEvenPips waardes
3. ✅ **Monitor dagelijks**: Check Global Variables en logs
4. ✅ **Documenteer**: Houd trading journal bij
5. ✅ **Pas aan**: Optimaliseer break-even levels op basis van resultaten
6. ✅ **Blijf disciplined**: Verander parameters niet tijdens trading dag

## Veelgestelde Vragen

**Q: Kunnen verschillende EA's tegelijk at risk zijn?**
A: NEE. Dit is juist de kern van het systeem. Maximaal 1 trade at risk.

**Q: Wat als ik handmatig trade naast de EA's?**
A: Het systeem telt ALLE trades. Handmatige trades beïnvloeden de coordinatie.

**Q: Kan ik een EA uitzetten en anderen laten draaien?**
A: JA. Het systeem werkt met elke combinatie van actieve EA's.

**Q: Reset de daily loss counter automatisch?**
A: JA. Om 00:00 server tijd wordt alles gereset.

**Q: Wat als ik 5 EA's heb maar er is maar 1 trade per dag?**
A: Dat kan gebeuren als marktcondities slecht zijn of als trades snel SL hitten voordat breakeven bereikt wordt. Dit is juist een voordeel - beschermt tegen overtrading.

---

**Dit systeem maximaliseert veiligheid terwijl het meerdere EA's toestaat om te draaien. Perfect voor FTMO Challenge! 🛡️📈**
