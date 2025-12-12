# FTMO Challenge Expert Advisor voor MT4

Deze Expert Advisor (EA) is speciaal ontwikkeld om de FTMO uitdaging te kunnen doorstaan op MetaTrader 4.

## 📋 Specificaties

- **Platform**: MetaTrader 4 (MT4)
- **Timeframe**: H1 (1 uur)
- **Account Balance**: €10,000 / $10,000
- **Trading Stijl**: Trend following met support/resistance analyse
- **Risk Management**: FTMO-compliant met strikte limiet controles

## 🎯 FTMO Uitdaging Requirements

De EA is ontworpen om te voldoen aan de standaard FTMO challenge vereisten:

- ✅ **Profit Target**: 10% (€1,000 op €10,000 account)
- ✅ **Maximum Dagelijks Verlies**: 5% (standaard ingesteld op 4% voor veiligheid)
- ✅ **Maximum Totaal Verlies**: 10% (standaard ingesteld op 8% voor veiligheid)
- ✅ **Minimum Trading Dagen**: De EA handelt consistent met goede signalen
- ✅ **Risk Management**: 1% risico per trade (configureerbaar)

## 🔧 Installatie

1. Open MetaTrader 4
2. Klik op `File` → `Open Data Folder`
3. Navigeer naar `MQL4` → `Experts`
4. Kopieer het bestand `FTMO_Challenge_EA.mq4` naar deze map
5. Herstart MetaTrader 4 of klik op `Refresh` in de Navigator
6. De EA verschijnt nu in de Navigator onder `Expert Advisors`

## 📊 Gebruik

### Expert Advisor Activeren

1. Open een H1 chart van je gewenste trading symbool (bijv. EURUSD, GBPUSD)
2. Sleep de `FTMO_Challenge_EA` vanuit de Navigator naar de chart
3. In het configuratiescherm:
   - Vink `Allow live trading` aan
   - Vink `Allow DLL imports` aan (indien nodig)
   - Configureer de parameters (zie hieronder)
4. Klik op `OK`
5. Controleer of er een smiley-icoon in de rechterbovenhoek van de chart verschijnt

### Belangrijke Parameters

#### Risk Management Settings
- **RiskPercentPerTrade** (1.0%): Percentage van balance dat geriskeerd wordt per trade
- **MaxDailyLossPercent** (4.0%): Maximum dagelijks verlies als percentage
- **MaxTotalLossPercent** (8.0%): Maximum totaal verlies als percentage van startbalance
- **MaxOpenPositions** (3): Maximum aantal gelijktijdige open posities

#### Trading Strategy Settings
- **FastMA_Period** (20): Periode voor snelle Moving Average
- **SlowMA_Period** (50): Periode voor langzame Moving Average
- **RSI_Period** (14): Periode voor RSI indicator
- **RSI_Overbought** (70): RSI niveau voor overbought conditie
- **RSI_Oversold** (30): RSI niveau voor oversold conditie
- **ATR_Period** (14): Periode voor ATR (volatiliteit meting)

#### Trade Management
- **StopLossATR** (2.0): Stop Loss als ATR multiplier
- **TakeProfitATR** (3.0): Take Profit als ATR multiplier
- **UseTrailingStop** (true): Activeer trailing stop functionaliteit
- **TrailingStopATR** (1.5): Trailing stop als ATR multiplier
- **MinRiskRewardRatio** (1.5): Minimum risk/reward verhouding voor trades

#### Trading Filters
- **StartHour** (2): Begin uur voor trading (server tijd)
- **EndHour** (22): Eind uur voor trading (server tijd)
- **MaxSpreadPips** (3.0): Maximum toegestane spread in pips
- **TradeOnMonday** (true): Sta trading op maandag toe
- **TradeOnFriday** (true): Sta trading op vrijdag toe

## 📈 Trading Strategie

De EA gebruikt een combinatie van technieken:

### 1. Trend Following
- Gebruikt twee EMA's (Exponential Moving Averages) voor trend identificatie
- Fast EMA (20) en Slow EMA (50)
- Handelt alleen in richting van de trend

### 2. Entry Signals
- **Buy Signal**: Fast EMA kruist boven Slow EMA + RSI onder 70 + prijs boven support
- **Sell Signal**: Fast EMA kruist onder Slow EMA + RSI boven 30 + prijs onder resistance

### 3. Support & Resistance
- Analyseert laatste 20 bars voor support en resistance niveaus
- Gebruikt deze voor extra bevestiging van signalen

### 4. Risk Management
- Stop Loss gebaseerd op ATR (Average True Range) voor markt-aangepaste stops
- Take Profit gebaseerd op ATR voor realistische targets
- Trailing Stop om winsten te beschermen
- Position sizing gebaseerd op risico percentage

### 5. Safety Features
- **Dagelijkse Loss Limiet**: Stopt automatisch bij te veel dagelijks verlies
- **Totale Loss Limiet**: Beschermt tegen te grote drawdown
- **Spread Filter**: Handelt niet bij te hoge spreads
- **Time Filter**: Handelt alleen tijdens liquide uren
- **Maximum Posities**: Voorkomt overtrading

## ⚙️ Optimalisatie Tips

Voor beste resultaten op verschillende symbolen:

1. **Backtesting**:
   - Test de EA eerst op historische data (minimaal 1 jaar)
   - Gebruik kwaliteitsdata met goede tick data
   - Test op H1 timeframe zoals gespecificeerd

2. **Forward Testing**:
   - Test op demo account voordat je live gaat
   - Monitor de performance gedurende minimaal 2 weken

3. **Parameter Optimalisatie**:
   - Voor volatiele paren (GBPJPY): verhoog StopLossATR naar 2.5-3.0
   - Voor rustige paren (EURUSD): gebruik standaard instellingen
   - Pas MaxSpreadPips aan op basis van je broker

4. **Symbool Selectie**:
   - Best getest op: EURUSD, GBPUSD, USDJPY, AUDUSD
   - Vermijd exotische paren met hoge spreads

## 📊 Monitoring

Houd de volgende zaken in de gaten:

- **Experts Tab**: Controleer log berichten van de EA
- **Trade Tab**: Monitor open posities
- **Account History**: Analyseer gesloten trades
- **Balance Curve**: Check of deze consistent omhoog gaat

### Belangrijke Log Berichten

```
"FTMO Challenge EA geïnitialiseerd" - EA is gestart
"Dagelijks verlies limiet bereikt" - Trading gestopt voor vandaag
"Totaal verlies limiet bereikt" - Trading permanent gestopt
"Order geopend: BUY/SELL" - Nieuwe trade geopend
"Trailing stop updated" - Stop loss aangepast
```

## ⚠️ Waarschuwingen

1. **Demo Testing**: Test ALTIJD eerst op een demo account
2. **VPS Aanbevolen**: Gebruik een VPS voor 24/7 operatie
3. **Internet Connectie**: Zorg voor stabiele verbinding
4. **Broker Keuze**: Kies een broker met lage spreads en goede executie
5. **Niet Aangepast voor Nieuws**: EA handelt door tijdens nieuws - overweeg handmatig uitzetten bij belangrijke events
6. **Past Performance**: Backtesting resultaten zijn geen garantie voor toekomstige performance

## 🔍 Troubleshooting

### EA handelt niet
- Controleer of "AutoTrading" is ingeschakeld (groene knop in toolbar)
- Verifieer dat spread binnen MaxSpreadPips ligt
- Check of de tijd binnen StartHour en EndHour valt
- Controleer of dagelijkse/totale loss limiet niet is bereikt

### Teveel verlies trades
- Overweeg risk per trade te verlagen (bijv. 0.5%)
- Verhoog MinRiskRewardRatio voor betere trades
- Pas MA periodes aan voor andere marktcondities

### Geen trailing stop activiteit
- Controleer of UseTrailingStop = true
- Trades moeten eerst in profit zijn voordat trailing start

## 📝 Licentie

Deze EA is ontwikkeld voor persoonlijk gebruik voor de FTMO challenge.

## 💡 Tips voor FTMO Success

1. **Geduld**: Laat de EA zijn werk doen, don't overoptimize
2. **Consistent**: Laat de EA draaien tijdens liquide uren
3. **Monitor**: Check dagelijks maar wijzig niet constant parameters
4. **Risk Management**: Houd je aan de 1% risico regel
5. **Diversificatie**: Overweeg meerdere symbolen met lage correlatie
6. **Stop bij Limiet**: Als de dagelijkse loss limiet bereikt is, accepteer dit

## 🎓 Volgende Stappen

1. Installeer de EA op MT4
2. Test op demo account gedurende 2 weken
3. Analyseer de resultaten en optimaliseer indien nodig
4. Start met kleine risk (0.5-1%) op FTMO challenge account
5. Monitor dagelijks maar pas niet continu aan
6. Haal de FTMO challenge! 🚀

---

**Belangrijk**: Deze EA is een hulpmiddel. Succes in trading vereist ook begrip van markten, geduld en discipline. Gebruik altijd eerst een demo account!
