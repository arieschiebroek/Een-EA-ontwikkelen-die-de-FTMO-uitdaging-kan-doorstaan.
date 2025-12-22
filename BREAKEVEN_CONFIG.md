# Variabele Break-Even Configuratie

## Overzicht

De break-even functionaliteit is nu volledig variabel instelbaar met twee parameters die samen bepalen wanneer en waar de stop loss wordt aangepast.

## Nieuwe Parameters

### 1. BreakEvenPips
**Beschrijving**: Aantal pips winst voordat de stop loss naar break-even wordt verplaatst.

**Standaard waardes per currency pair:**
```
EURUSD: 30 pips
USDJPY: 35 pips  
GBPUSD: 40 pips
AUDUSD: 35 pips
XAUUSD: 80 pips
```

**Gebruik:**
- Lager = Sneller beschermd, maar meer kans op vroeg uitgestopt worden
- Hoger = Meer ruimte voor movement, maar langer at risk

### 2. BreakEvenOffset (NIEUW)
**Beschrijving**: Extra pips boven/onder entry price waar de stop loss wordt geplaatst.

**Standaard waarde**: `2 pips`

**Reden**: 
- Beschermt tegen spreads en kleine price fluctuaties
- Voorkomt dat trade meteen sluit bij minimale retracement
- Garandeert kleine winst in plaats van exact breakeven

**Gebruik:**
- `0 pips` = Exact op entry price (riskant bij spreads)
- `2 pips` = Standaard (aanbevolen)
- `5 pips` = Conservatief (kleine gegarandeerde winst)

## Voorbeelden

### Voorbeeld 1: EURUSD Buy
```
Entry: 1.1000
BreakEvenPips: 30
BreakEvenOffset: 2

Situatie na 30 pips winst (prijs = 1.1030):
→ Stop Loss wordt gezet op: 1.1002 (entry + 2 pips)
→ Trade is nu beschermd met 2 pips winst gegarandeerd
```

### Voorbeeld 2: XAUUSD Sell  
```
Entry: 1950.00
BreakEvenPips: 80
BreakEvenOffset: 5

Situatie na 80 pips winst (prijs = 1942.00):
→ Stop Loss wordt gezet op: 1945.00 (entry - 5 pips)
→ Trade is nu beschermd met 5 pips (=$5) winst gegarandeerd
```

### Voorbeeld 3: Conservatieve Settings
```
BreakEvenPips: 50  (wacht langer)
BreakEvenOffset: 10 (grotere buffer)

→ Minder trades bereiken break-even
→ Maar als ze het bereiken: 10 pips winst gegarandeerd
```

### Voorbeeld 4: Agressieve Settings
```
BreakEvenPips: 20  (snel break-even)
BreakEvenOffset: 0  (exact breakeven)

→ Meer trades bereiken break-even
→ Maar geen winst gegarandeerd, alleen capital bescherming
```

## IsOrderAtBreakEven() Functie

De check of een order op break-even staat is ook variabel:

```mql4
double breakEvenZone = BreakEvenOffset + 3; // Offset + 3 pips buffer

if(distance <= breakEvenZone)
{
   return true; // Order is op breakeven
}
```

**Logica:**
- Met `BreakEvenOffset = 2`: Order is "at breakeven" als SL binnen 5 pips van entry (2 + 3 buffer)
- Met `BreakEvenOffset = 5`: Order is "at breakeven" als SL binnen 8 pips van entry (5 + 3 buffer)

Dit voorkomt false positives bij kleine SL aanpassingen.

## Configuratie per Currency Pair

### EURUSD (Laag volatiel)
```
BreakEvenPips = 30
BreakEvenOffset = 2
```
**Rationale:** Tight spreads, stabiel, snel beschermen is veilig

### USDJPY (Medium volatiel)
```
BreakEvenPips = 35
BreakEvenOffset = 3
```
**Rationale:** Grotere intraday swings, iets meer ruimte nodig

### GBPUSD (Hoog volatiel)
```
BreakEvenPips = 40
BreakEvenOffset = 4
```
**Rationale:** Zeer volatiel, meer ruimte om whipsaws te vermijden

### AUDUSD (Medium volatiel)
```
BreakEvenPips = 35
BreakEvenOffset = 3
```
**Rationale:** Commodity currency, redelijke volatiliteit

### XAUUSD/Gold (Extreem volatiel)
```
BreakEvenPips = 80
BreakEvenOffset = 10
```
**Rationale:** 
- Grote price swings (tientallen pips binnen minuten)
- Hogere spreads
- Meer ruimte = minder premature exits

## Account Growth Scenario's

### Scenario 1: Account $10,000 → $15,000
**Aanpassing optie 1** (conservatiever):
```
BreakEvenPips: 30 → 40
BreakEvenOffset: 2 → 3
```
**Reden:** Groter account = meer te verliezen, meer conservatief

**Aanpassing optie 2** (ongewijzigd):
```
BreakEvenPips: 30 (blijft gelijk)
BreakEvenOffset: 2 (blijft gelijk)
```
**Reden:** Strategie werkt, niet wijzigen

### Scenario 2: Account $10,000 → $8,000 (drawdown)
**Aanpassing** (agressiever herstellen):
```
BreakEvenPips: 30 → 25
BreakEvenOffset: 2 → 2
```
**Reden:** Sneller beschermen, voorzichtiger worden

## Monitoring & Logging

Na break-even wordt er nu gelogd:
```
EURUSD Order 12345 stop loss naar BREAK-EVEN gezet!
Break-even niveau: 1.1000 + 2 pips = 1.1002
>>> SIGNAAL: Nieuwe trade mag nu geopend worden door deze of andere EA <<<
```

Deze logging toont:
- Order nummer
- Entry price
- Break-even offset
- Nieuw SL niveau
- Signaal dat nieuwe trade toegestaan is

## Best Practices

### 1. Backtesten
Test verschillende combinaties:
```
Set A: BreakEvenPips=20, Offset=0
Set B: BreakEvenPips=30, Offset=2  (standaard)
Set C: BreakEvenPips=40, Offset=5
Set D: BreakEvenPips=50, Offset=10
```

Analyseer:
- Win rate na break-even
- Average profit van break-even trades
- Aantal premature exits

### 2. Forward Testing (Demo)
Monitor gedurende 2 weken:
- Hoeveel trades bereiken break-even?
- Hoeveel worden uitgestopt op break-even?
- Wat is de gemiddelde verdere winst?

### 3. Aanpassingen tijdens Live Trading
**DON'T**: Parameters wijzigen tijdens actieve trade
**DO**: Parameters aanpassen aan begin van nieuwe dag
**DO**: Documenteer alle parameter wijzigingen

### 4. Multi-EA Portfolio
Verschillende settings per EA mogelijk:
```
EURUSD: BreakEvenPips=25, Offset=2  (agressief)
GBPUSD: BreakEvenPips=45, Offset=5  (conservatief)
XAUUSD: BreakEvenPips=100, Offset=15 (zeer conservatief)
```

Dit creëert portfolio diversificatie in risk management.

## Troubleshooting

### Probleem: Te veel trades uitgestopt op break-even
**Oplossing**: 
- Verhoog `BreakEvenPips` (bijv. 30 → 40)
- Verhoog `BreakEvenOffset` (bijv. 2 → 5)

### Probleem: Te weinig trades bereiken break-even
**Oplossing**:
- Verlaag `BreakEvenPips` (bijv. 40 → 30)
- Maar risico: meer trades at risk tegelijk

### Probleem: Break-even wordt te laat gezet
**Oplossing**:
- Verlaag `BreakEvenPips`
- Check of `IsOrderAtBreakEven()` correct werkt

### Probleem: Order telt nog als "at risk" na break-even
**Check**:
```mql4
double breakEvenZone = BreakEvenOffset + 3;
```
Als `BreakEvenOffset` > 7, verhoog de buffer.

## Samenvatting

**Nieuwe flexibiliteit:**
- ✅ 2 variabele parameters in plaats van hard-coded waarde
- ✅ Aanpasbaar per currency pair
- ✅ Aanpasbaar per trader voorkeur
- ✅ Aanpasbaar op basis van backtest resultaten

**Aanbevolen start settings:**
```
BreakEvenPips: Gebruik standaard per pair (30-80)
BreakEvenOffset: 2 pips (universeel goed)
```

**Na 1 maand evaluatie:**
Pas aan op basis van:
1. Win rate van break-even trades
2. Average profit when stopped at BE
3. Percentage trades that reach BE

---

**De break-even functionaliteit is nu volledig configureerbaar! 🎯**
