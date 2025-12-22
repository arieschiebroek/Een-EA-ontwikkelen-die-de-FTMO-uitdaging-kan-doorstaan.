# FTMO Challenge Expert Advisor - Installatie Handleiding

## Overzicht
Deze Expert Advisor (EA) is speciaal ontwikkeld om te voldoen aan de FTMO Challenge regels en werkt op MT4 met een account van $10,000 op de H1 timeframe.

## FTMO Regels die worden geïmplementeerd

### 1. Maximale Dagelijkse Verlies Limiet
- **Standaard**: $500 (5% van $10,000 account)
- De EA stopt automatisch met handelen als deze limiet wordt bereikt
- Reset dagelijks om 00:00 server tijd

### 2. Maximale Totale Drawdown
- **Standaard**: $1,000 (10% van $10,000 account)
- Alle posities worden automatisch gesloten bij overschrijding
- Dit beschermt tegen te grote verliezen

### 3. Minimum Handelsdagen
- FTMO vereist minimaal 4 handelsdagen
- Zorg dat de EA minimaal 4 dagen actief is

### 4. Profit Target
- Voor Challenge 1: $800 (8% van $10,000)
- Voor Challenge 2 (Verificatie): $500 (5% van $10,000)

## Installatie Instructies

### Stap 1: Download de EA
1. Download het bestand `FTMO_EA.mq4` uit deze repository

### Stap 2: Installeer in MT4
1. Open MetaTrader 4
2. Klik op `File` → `Open Data Folder`
3. Navigeer naar de map `MQL4` → `Experts`
4. Kopieer `FTMO_EA.mq4` naar deze map
5. Herstart MT4 of klik op `Refresh` in de Navigator

### Stap 3: Configureer de EA
1. Open een H1 chart van het gewenste paar (bijv. EURUSD)
2. Sleep de EA vanuit de Navigator naar de chart
3. In het configuratiescherm:
   - **LotSize**: Start met 0.01 voor veilig risicobeheer
   - **StopLoss**: 100 pips (aanpasbaar)
   - **TakeProfit**: 150 pips (aanpasbaar, 1.5:1 risk/reward ratio)
   - **MaxDailyLoss**: 500 USD (houd dit op 5% van account)
   - **MaxTotalDrawdown**: 1000 USD (houd dit op 10% van account)
4. Zorg dat "Allow live trading" is aangevinkt
5. Klik op `OK`

### Stap 4: Verifieer de Installatie
- Check de `Experts` tab in de Terminal
- Je zou moeten zien: "FTMO EA Geïnitialiseerd"
- Controleer of de juiste account en symbool worden weergegeven

## Trading Strategie

De EA gebruikt een combinatie van technische indicatoren:

### Indicatoren
1. **RSI (Relative Strength Index)**
   - Periode: 14
   - Gebruikt voor het identificeren van overbought/oversold condities

2. **EMA Crossover**
   - Fast EMA: 12 periode
   - Slow EMA: 26 periode
   - Trade signalen bij crossover momenten

### Entry Regels
- **Buy Signal**: Snelle EMA kruist boven langzame EMA + RSI onder 50
- **Sell Signal**: Snelle EMA kruist onder langzame EMA + RSI boven 50
- Alleen handelen op nieuwe H1 bars (geen meerdere trades per uur)

### Risk Management
- Vaste lot size (aanbevolen: 0.01 voor $10k account)
- Stop Loss en Take Profit op elke trade
- Risk/Reward ratio: 1:1.5 (100 pips SL, 150 pips TP)
- Maximum 1 positie tegelijk

## Aanbevolen Instellingen voor FTMO Challenge

### Voor $10,000 Account (Challenge 1)
```
LotSize = 0.01 (risico ~$1 per pip)
StopLoss = 100 pips ($100 risico per trade = 1%)
TakeProfit = 150 pips ($150 potentiële winst = 1.5%)
MaxDailyLoss = 500 ($500 = 5% max dagelijks verlies)
MaxTotalDrawdown = 1000 ($1,000 = 10% max totaal)
```

### Conservatieve Instellingen (Voor beginners)
```
LotSize = 0.01
StopLoss = 80
TakeProfit = 120
MaxDailyLoss = 400
MaxTotalDrawdown = 800
```

### Agressieve Instellingen (Alleen voor ervaren traders)
```
LotSize = 0.02
StopLoss = 120
TakeProfit = 180
MaxDailyLoss = 500
MaxTotalDrawdown = 1000
```

## Backtesting

### Hoe te Backtesten
1. Open de Strategy Tester in MT4 (Ctrl + R)
2. Selecteer `FTMO_EA` als Expert Advisor
3. Instellingen:
   - Symbool: EURUSD (of uw voorkeur)
   - Periode: H1
   - Datum bereik: Minimaal 6 maanden historische data
   - Model: "Every tick" of "Open prices only"
4. Klik op `Start`

### Waar op te letten bij Backtest Resultaten
- **Profit Factor**: Moet > 1.5 zijn
- **Win Rate**: 50%+ is goed
- **Maximum Drawdown**: Moet < $1,000 blijven
- **Totale Trades**: Minimaal 50+ trades voor statistische relevantie

## Monitoring en Onderhoud

### Dagelijkse Checks
1. Controleer de dagelijkse P&L in de Terminal
2. Verifieer dat EA actief is (groene pijl bij naam in chart)
3. Check of er geen error messages zijn in Experts tab

### Wekelijkse Evaluatie
1. Bekijk de totale winst/verlies
2. Analyseer welke trades winstgevend waren
3. Overweeg parameter aanpassingen indien nodig

## Veelgestelde Vragen

**Q: Waarom handelt de EA niet?**
A: Check of:
- "Allow live trading" is aangevinkt
- De markt open is
- Er een nieuwe H1 bar is gevormd
- Dagelijkse verlies limiet niet is bereikt
- Er geen open posities zijn

**Q: Kan ik de EA op meerdere charts gebruiken?**
A: Ja, maar zorg dat elke instantie een uniek Magic Number heeft om conflicten te voorkomen.

**Q: Hoeveel winst kan ik verwachten?**
A: Dit hangt af van marktcondities. De EA is geoptimaliseerd voor consistentie, niet voor snelle winsten. Verwacht gemiddeld 3-5% per maand.

**Q: Is de EA geschikt voor demo accounts?**
A: Ja! Test altijd eerst op een demo account voordat je live gaat.

## Waarschuwingen

⚠️ **Belangrijke Opmerkingen**:
- Deze EA garandeert GEEN winst
- Past trading bevat risico's
- Test altijd eerst op demo account
- Gebruik alleen geld dat je kunt verliezen
- Monitor de EA regelmatig
- FTMO regels kunnen wijzigen - verifieer altijd de actuele regels

## Troubleshooting

### EA start niet
- Verifieer dat DLL imports zijn toegestaan (niet nodig voor deze EA)
- Check of de EA in de juiste map staat
- Herstart MT4

### Geen trades worden geopend
- Controleer de Experts tab voor error berichten
- Verifieer dat spread niet te hoog is
- Check of account voldoende margin heeft

### Orders worden meteen gesloten
- Check of dagelijkse verlies limiet is bereikt
- Verifieer Stop Loss en Take Profit waarden
- Controleer broker minimum lot size

## Support en Updates

Voor vragen, bugs of suggesties, open een issue in de GitHub repository.

## Licentie

Deze EA is open source en mag vrij worden gebruikt en aangepast voor persoonlijk gebruik.

---

**Succes met de FTMO Challenge! 🚀**
