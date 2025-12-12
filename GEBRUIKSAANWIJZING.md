# FTMO EA - Gebruiksaanwijzing

## Overzicht
Deze Expert Advisor (EA) is speciaal ontworpen om de FTMO Challenge te doorstaan met de volgende kenmerken:
- Multi-symbol trading (meerdere EA's op één account)
- Automatische break-even stop-loss management
- FTMO 5% dagelijkse verlies limiet bescherming
- Gecoördineerde trading tussen verschillende EA instanties
- Configureerbare risk management

## Belangrijkste Functies

### 1. Multi-Symbol Trading
- U kunt meerdere instanties van deze EA draaien op hetzelfde account
- Elk paar (XAUUSD, EURUSD, GBPUSD, etc.) krijgt zijn eigen EA instantie
- Elke EA moet een uniek Magic Number hebben

### 2. Break-Even Management
- Na een configureerbaar aantal pips winst wordt de stop-loss automatisch naar break-even verplaatst
- Zodra een trade op break-even staat, mag een volgende EA een nieuwe trade openen
- **Regel**: Er mag altijd maar één EA een trade hebben waarvan de stop-loss NIET op break-even staat

### 3. FTMO 5% Dagelijkse Verlies Limiet
- De EA monitort continu het dagelijkse verlies
- Als het verlies 5% (of geconfigureerde waarde) bereikt:
  - Worden ALLE openstaande trades van deze EA onmiddellijk gesloten
  - Wordt de EA geblokkeerd voor de rest van de dag
  - Kunnen ALLE EA's op het account niet meer traden (via gedeeld bestand)

### 4. Trade Coördinatie
- EA's communiceren via gedeelde bestanden in de MT4 Common Files folder
- Voorkomt dat meerdere EA's tegelijk traden zonder break-even
- Zorgt voor ordelijke trading volgens FTMO regels

## Installatie

### Stap 1: Kopieer de EA
1. Kopieer `FTMO_EA.mq4` naar de map: `MT4/MQL4/Experts/`
2. Herstart MetaTrader 4 of klik op "Refresh" in de Navigator

### Stap 2: Compileer de EA (indien nodig)
1. Open MetaEditor (F4 in MT4)
2. Open `FTMO_EA.mq4`
3. Klik op "Compile" of druk F7
4. Controleer op fouten in het tabblad "Errors"

### Stap 3: Installeer de EA op Charts
1. Open een chart voor elk symbool dat u wilt traden (bijv. EURUSD H1)
2. Sleep de EA vanuit Navigator naar de chart
3. Configureer de parameters (zie hieronder)
4. Zorg ervoor dat "AutoTrading" is ingeschakeld (groene knop rechts boven)

## Configuratie Parameters

### EA Identificatie
```
EA_MagicNumber = 100001
```
- **Belangrijk**: Elk symbool moet een UNIEK magic number hebben
- Voorbeeld:
  - EURUSD: 100001
  - XAUUSD: 100002
  - GBPUSD: 100003

```
EA_Comment = "FTMO_EA"
```
- Comment die wordt toegevoegd aan alle trades

### Risico Instellingen
```
RiskPercentPerTrade = 1.0
```
- Percentage van account balance dat per trade wordt gerisikeerd
- Aanbevolen: 0.5% - 2% voor FTMO

```
MaxDailyLossPercent = 5.0
```
- Maximaal toegestaan dagelijks verlies (FTMO regel)
- **Niet aanpassen** tenzij u andere regels hanteert

```
MonthlyProfitTarget = 10.0
```
- Informatie parameter voor winstdoel (wordt niet afgedwongen door EA)

### Stop Loss & Break-Even
```
StopLossPips = 50
```
- Initial stop loss in pips
- **Pas aan per symbool**: Volatiele paren (XAUUSD) hebben grotere SL nodig

```
TakeProfitPips = 100
```
- Take profit in pips
- Aanbevolen: Minimaal 2x de stop loss (1:2 risk/reward ratio)

```
BreakEvenPips = 20
```
- Aantal pips winst voordat SL naar break-even gaat
- **Belangrijk**: Dit triggert ook de mogelijkheid voor andere EA's om te traden

```
BreakEvenExtraPips = 5
```
- Extra pips boven entry price bij break-even
- Voorkomt dat trade op 0 wordt gesloten door spread

### Trading Instellingen
```
EnableTrading = true
```
- Schakel trading in/uit
- Handig voor tijdelijk pauzeren zonder EA te verwijderen

```
MaxTradesPerDay = 10
```
- Maximaal aantal trades per dag per EA
- Voorkomt overtrading

```
Slippage = 3
```
- Toegestane slippage in pips

## Configuratie Voorbeelden

### EURUSD (Conservative)
```
EA_MagicNumber = 100001
StopLossPips = 30
TakeProfitPips = 60
BreakEvenPips = 15
RiskPercentPerTrade = 1.0
```

### XAUUSD (Volatiel)
```
EA_MagicNumber = 100002
StopLossPips = 100
TakeProfitPips = 200
BreakEvenPips = 50
RiskPercentPerTrade = 0.5
```

### GBPUSD (Medium)
```
EA_MagicNumber = 100003
StopLossPips = 40
TakeProfitPips = 80
BreakEvenPips = 20
RiskPercentPerTrade = 1.0
```

## Werking van de EA

### Trading Cyclus
1. **Signaal Generatie**: EA analyseert de markt (Moving Average crossover)
2. **Coördinatie Check**: Controleert of een andere EA al actief is
3. **Trade Openen**: Als signaal en coördinatie OK zijn
4. **Break-Even Management**: Monitort winst en verplaatst SL
5. **Risk Management**: Controleert dagelijks verlies

### Coördinatie Tussen EA's
```
EA 1 (EURUSD) opent trade → SL niet op BE → Andere EA's wachten
EA 1 bereikt +20 pips    → SL naar BE     → Andere EA's mogen traden
EA 2 (XAUUSD) opent trade → SL niet op BE → Andere EA's wachten
etc.
```

### Dagelijkse Verlies Limiet
```
Start Balance: €10,000
Max Verlies:   €500 (5%)

Als Equity ≤ €9,500:
- Sluit ALLE trades
- Blokkeer trading voor vandaag
- Reset morgen automatisch
```

## Trading Signaal Aanpassen

De huidige EA gebruikt een simpel Moving Average crossover systeem. U kunt dit aanpassen in de functie `GenerateSignal()`:

```mql4
int GenerateSignal()
{
   // HIER: Voeg uw eigen signaal logica toe
   
   // Voorbeelden:
   // - RSI overbought/oversold
   // - Bollinger Bands
   // - MACD
   // - Support/Resistance levels
   // - Candlestick patterns
   
   // Return:
   //  1  = BUY signaal
   // -1  = SELL signaal
   //  0  = Geen signaal
}
```

### Voorbeelden voor Verschillende Symbolen

**Voor XAUUSD** (Gold - Volatiel):
- Gebruik grotere SL/TP
- Overweeg Bollinger Bands of ATR-based indicators
- Houd rekening met nieuws events

**Voor EURUSD** (Stable):
- Kortere SL/TP mogelijk
- Trend-following strategieën werken goed
- Support/Resistance levels belangrijk

**Voor GBPUSD** (Brexit Volatility):
- Medium SL/TP
- Vermijd trading rond nieuws
- Overweeg tijd filters (London/NY session)

## Best Practices

### 1. Start met Demo Account
- Test de EA grondig op demo voordat u live gaat
- Controleer of coördinatie tussen EA's werkt
- Verifieer break-even functionaliteit

### 2. Backtesting
- Test elke symbool/EA configuratie apart
- Gebruik minimaal 1 jaar historische data
- Let op drawdown en win rate

### 3. Optimalisatie per Symbool
- Elk paar heeft andere karakteristieken
- Tune SL, TP, en BE parameters individueel
- Houd rekening met spreads en commissies

### 4. Monitoring
- Controleer dagelijks de Expert tab voor logs
- Let op waarschuwingen over dagelijks verlies
- Verifieer dat coördinatie werkt

### 5. Risk Management
- Start conservatief (0.5-1% risk per trade)
- Verhoog alleen na bewezen resultaten
- Houd altijd de 5% dagelijkse limiet in acht

## Troubleshooting

### Probleem: EA opent geen trades
**Oplossing**:
- Controleer of AutoTrading is ingeschakeld
- Controleer of `EnableTrading = true`
- Check of dagelijkse verlies limiet is bereikt
- Verifieer dat een andere EA niet al een actieve trade heeft

### Probleem: Break-even werkt niet
**Oplossing**:
- Controleer of `BreakEvenPips` niet te groot is
- Verifieer spread (spread kan break-even blokkeren)
- Check logs voor modificatie errors

### Probleem: Dagelijkse limiet te vroeg bereikt
**Oplossing**:
- Verlaag `RiskPercentPerTrade`
- Vergroot `StopLossPips` (maar houd risk hetzelfde)
- Review trading strategie/signalen

### Probleem: Meerdere EA's openen tegelijk trades
**Oplossing**:
- Controleer of elke EA een uniek Magic Number heeft
- Verifieer dat coördinatie bestanden toegankelijk zijn
- Check MT4 Common Files folder permissions

## Bestandslocaties

### EA Bestand
```
MT4/MQL4/Experts/FTMO_EA.mq4
```

### Coördinatie Bestanden (Automatisch Aangemaakt)
```
MT4/MQL4/Files/Common/FTMO_EA_Coordination.txt
MT4/MQL4/Files/Common/FTMO_Daily_Loss.txt
```

## FTMO Challenge Specificaties

### FTMO Challenge Phase 1
- Account: €10,000 (of €25,000, €50,000, €100,000)
- Profit Target: 10% in 30 dagen
- Max Daily Loss: 5% (€500 op €10,000 account)
- Max Total Loss: 10% (€1,000 op €10,000 account)
- Minimum Trading Days: 4

### FTMO Challenge Phase 2 (Verification)
- Account: €10,000
- Profit Target: 5% in 60 dagen
- Max Daily Loss: 5%
- Max Total Loss: 10%
- Minimum Trading Days: 4

### Deze EA Helpt Met:
✅ Automatische 5% dagelijkse verlies limiet
✅ Consistent risico management (1% per trade)
✅ Break-even bescherming voor capital preservation
✅ Multi-symbol diversificatie
✅ Gecontroleerd aantal trades per dag

### U Moet Nog Zelf:
- De EA optimaliseren voor elk symbool
- Een goede trading strategie ontwikkelen
- Minimum 4 trading dagen halen
- Monitoren en aanpassen indien nodig

## Veelgestelde Vragen

**Q: Kan ik de EA op meerdere timeframes gebruiken?**
A: Ja, maar gebruik dan verschillende Magic Numbers per timeframe.

**Q: Werkt de EA ook op andere brokers dan FTMO?**
A: Ja, de EA werkt op elke MT4 broker.

**Q: Kan ik de signaal logica aanpassen zonder programmeerkennis?**
A: Nee, voor signaal aanpassingen heeft u MQL4 kennis nodig of moet u een developer inhuren.

**Q: Wat gebeurt er als mijn VPS/computer crasht?**
A: De EA start opnieuw op als MT4 herstart. Bestaande trades blijven open.

**Q: Kan ik de EA combineren met manuele trades?**
A: Ja, maar gebruik dan andere Magic Numbers voor manuele trades. Let op: manuele trades tellen MEE voor de dagelijkse verlies limiet!

**Q: Hoe vaak moet ik de EA updaten?**
A: Monitoor prestaties wekelijks. Pas parameters aan als marktcondities veranderen.

## Support en Updates

Voor vragen, bugs, of suggesties:
1. Check eerst deze documentatie
2. Review de logs in de Expert tab
3. Test op demo account
4. Documenteer het probleem met screenshots

## Disclaimer

Deze EA is een tool voor automated trading. Succesvolle trading vereist:
- Een solide trading strategie
- Goede risk management
- Continue monitoring en optimalisatie
- Begrip van de markten

Gebruik altijd eerst een demo account voordat u live gaat. Trading heeft risico's en er zijn geen garanties voor winst.

---

**Versie**: 1.0
**Laatst bijgewerkt**: December 2025
**Compatibiliteit**: MetaTrader 4
**Licentie**: Open Source
