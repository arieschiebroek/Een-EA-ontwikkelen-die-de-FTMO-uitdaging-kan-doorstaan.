# Currency-Specific FTMO Expert Advisors

## Overzicht

Deze repository bevat nu 6 Expert Advisors, elk geoptimaliseerd voor een specifiek currency paar maar allemaal voldoen aan de FTMO Challenge regels.

## Expert Advisors Collectie

### 1. FTMO_EA.mq4 (Basis/Algemeen)
- **Currency Pair**: Elk paar (universeel)
- **Magic Number**: 123456
- **Stop Loss**: 100 pips
- **Take Profit**: 150 pips
- **Strategie**: EMA (12/26) + RSI crossover
- **Geschikt voor**: Beginners, algemeen gebruik

### 2. FTMO_EURUSD_EA.mq4
- **Currency Pair**: EURUSD
- **Magic Number**: 111111
- **Stop Loss**: 80 pips
- **Take Profit**: 120 pips
- **Strategie**: EMA (9/21) + RSI + ATR volatiliteit filter
- **Speciale Features**:
  - Volatiliteit filter (alleen handelen bij toenemende volatiliteit)
  - Trailing stop bij 50 pips winst (30 pips trailing)
  - Conservatieve RSI zones (45/55)
- **Geschikt voor**: EURUSD - meest liquide paar, lagere spreads

### 3. FTMO_USDJPY_EA.mq4
- **Currency Pair**: USDJPY
- **Magic Number**: 222222
- **Stop Loss**: 90 pips
- **Take Profit**: 135 pips
- **Strategie**: EMA (8/18) + RSI + Bollinger Bands mean reversion
- **Speciale Features**:
  - Bollinger Bands voor overbought/oversold extremen
  - Mean reversion strategie bij extreme RSI (<25 of >75)
  - ATR-based dynamische trailing stop
- **Geschikt voor**: USDJPY - volatiel paar met sterke trends en reversals

### 4. FTMO_GBPUSD_EA.mq4
- **Currency Pair**: GBPUSD (Cable)
- **Magic Number**: 333333
- **Stop Loss**: 110 pips
- **Take Profit**: 165 pips
- **Strategie**: EMA (10/20) + MACD + SMA 50 trend filter
- **Speciale Features**:
  - MACD crossover voor momentum bevestiging
  - SMA 50 voor lange termijn trend richting
  - Trailing stop bij 80 pips winst (40 pips trailing)
  - Sterke trend-following aanpak
- **Geschikt voor**: GBPUSD - zeer volatiel, grote bewegingen

### 5. FTMO_AUDUSD_EA.mq4
- **Currency Pair**: AUDUSD (Aussie)
- **Magic Number**: 444444
- **Stop Loss**: 85 pips
- **Take Profit**: 130 pips
- **Strategie**: EMA (11/22) + Stochastic + ADX trend sterkte
- **Speciale Features**:
  - Stochastic voor timing entries bij overbought/oversold
  - ADX voor trend sterkte bevestiging (>25)
  - DI+ en DI- voor trend richting
  - Trailing stop bij 60 pips winst (35 pips trailing)
- **Geschikt voor**: AUDUSD - commodity currency, correlatie met risico sentiment

### 6. FTMO_XAUUSD_EA.mq4
- **Currency Pair**: XAUUSD (Gold)
- **Magic Number**: 555555
- **Stop Loss**: 200 pips
- **Take Profit**: 300 pips
- **Strategie**: EMA (15/30) + RSI + ATR + Support/Resistance
- **Speciale Features**:
  - Langere EMA's voor minder whipsaws bij volatiliteit
  - Support/Resistance levels (20-bar highs/lows)
  - MA 200 voor lange termijn trend
  - Minimum ATR threshold voor volatiliteit
  - ATR-based trailing stop (2x ATR)
  - Grotere slippage tolerance (5 pips)
- **Geschikt voor**: XAUUSD - safe haven, zeer volatiel, beweegt op nieuws

## FTMO Compliance Matrix

| EA | Dagelijks Verlies | Max Drawdown | Risk/Reward | Trailing Stop |
|---|---|---|---|---|
| FTMO_EA | ✅ $500 | ✅ $1,000 | 1:1.5 | ❌ |
| EURUSD | ✅ $500 | ✅ $1,000 | 1:1.5 | ✅ 50 pips |
| USDJPY | ✅ $500 | ✅ $1,000 | 1:1.5 | ✅ ATR-based |
| GBPUSD | ✅ $500 | ✅ $1,000 | 1:1.5 | ✅ 80 pips |
| AUDUSD | ✅ $500 | ✅ $1,000 | 1:1.5 | ✅ 60 pips |
| XAUUSD | ✅ $500 | ✅ $1,000 | 1:1.5 | ✅ ATR-based |

## Installatie per Currency Pair

### Stap 1: Kies uw EA(s)
Download de EA's voor de currency pairs die u wilt handelen:
- `FTMO_EURUSD_EA.mq4` voor EUR/USD chart
- `FTMO_USDJPY_EA.mq4` voor USD/JPY chart
- `FTMO_GBPUSD_EA.mq4` voor GBP/USD chart
- `FTMO_AUDUSD_EA.mq4` voor AUD/USD chart
- `FTMO_XAUUSD_EA.mq4` voor XAU/USD (Gold) chart

### Stap 2: Installeer in MT4
1. Kopieer de .mq4 bestanden naar `MT4/MQL4/Experts/`
2. Herstart MT4 of klik Refresh in Navigator

### Stap 3: Configureer per Chart
1. Open een H1 chart voor het gewenste paar
2. Sleep de corresponderende EA naar de chart
3. Configureer parameters indien nodig
4. Zorg dat "Allow live trading" is aangevinkt

## Multi-EA Setup (Meerdere Pairs Tegelijk)

### Voordelen
✅ **Diversificatie**: Spread risico over meerdere currency pairs
✅ **Meer handelskansen**: Elk paar heeft eigen bewegingen
✅ **Unieke Magic Numbers**: Geen conflicten tussen EA's
✅ **FTMO Compliant**: Alle EA's delen dezelfde risk limits

### Aanbevolen Combinaties

#### Conservative Portfolio (Demo Testing)
```
1. FTMO_EURUSD_EA.mq4 op EURUSD H1
2. FTMO_AUDUSD_EA.mq4 op AUDUSD H1
3. FTMO_USDJPY_EA.mq4 op USDJPY H1
```
**Totaal risico per trade**: ~$100 (3 EA's x 0.01 lot x ~$100 SL)

#### Balanced Portfolio (4 Pairs)
```
1. FTMO_EURUSD_EA.mq4 op EURUSD H1
2. FTMO_USDJPY_EA.mq4 op USDJPY H1
3. FTMO_GBPUSD_EA.mq4 op GBPUSD H1
4. FTMO_AUDUSD_EA.mq4 op AUDUSD H1
```
**Totaal risico per trade**: ~$120 (4 EA's x 0.01 lot x ~$90 SL avg)

#### Aggressive Portfolio (5 Pairs)
```
1. FTMO_EURUSD_EA.mq4 op EURUSD H1
2. FTMO_USDJPY_EA.mq4 op USDJPY H1
3. FTMO_GBPUSD_EA.mq4 op GBPUSD H1
4. FTMO_AUDUSD_EA.mq4 op AUDUSD H1
5. FTMO_XAUUSD_EA.mq4 op XAUUSD H1
```
**Totaal risico per trade**: ~$150 (5 EA's x 0.01 lot x ~$100 SL avg)

⚠️ **Belangrijk**: Bij gebruik van meerdere EA's tegelijk:
- **Dagelijks verlies limiet** blijft $500 voor ALLE EA's samen
- **Max drawdown** blijft $1,000 voor ALLE EA's samen
- Monitor totale exposure nauwkeurig
- Overweeg lot sizes te verlagen (bijv. 0.008 per EA)

## Parameter Aanpassingen

### Conservatieve Settings (Veiliger)
```
LotSize = 0.008           // Lager risico per trade
MaxDailyLoss = 400        // Veiliger buffer
MaxTotalDrawdown = 800    // Veiliger buffer
```

### Standaard Settings (Aanbevolen)
```
LotSize = 0.01            // Standard voor $10k
MaxDailyLoss = 500        // FTMO limiet
MaxTotalDrawdown = 1000   // FTMO limiet
```

### Multi-EA Settings (Bij 4-5 EA's tegelijk)
```
LotSize = 0.007-0.008     // Lagere lot size per EA
MaxDailyLoss = 500        // Gedeeld tussen alle EA's
MaxTotalDrawdown = 1000   // Gedeeld tussen alle EA's
```

## Backtesting Strategie

### Individuele EA Testing
1. Test elke EA apart op historische data (min. 6 maanden)
2. Gebruik Strategy Tester in MT4
3. Analyseer:
   - Win rate (target: >50%)
   - Profit factor (target: >1.5)
   - Max drawdown (<$1,000)
   - Aantal trades (min. 30 voor statistiek)

### Portfolio Backtesting
Voor multi-EA setup:
1. Test elke EA individueel
2. Simuleer combined performance:
   - Tel alle trades van alle EA's samen
   - Check of combined drawdown <$1,000 blijft
   - Verifieer dat combined daily loss <$500 blijft

## Demo Testing Plan

### Week 1-2: Individuele Tests
- Test elke EA apart op demo
- Monitor dagelijkse performance
- Pas parameters aan indien nodig
- Documenteer resultaten

### Week 3-4: Multi-EA Test
- Draai 3-4 EA's tegelijk
- Monitor totale exposure
- Check FTMO compliance
- Optimaliseer lot sizes

### Week 5-6: Final Validation
- Full portfolio met 4-5 EA's
- Simuleer echte FTMO Challenge condities
- Verifieer consistente winst
- Check emotionele comfort level

## Live Trading Roadmap

### Fase 1: Demo Account (4-6 weken)
✅ Test alle EA's individueel
✅ Test multi-EA setup
✅ Verifieer FTMO compliance
✅ Documenteer alle trades

### Fase 2: FTMO Challenge 1 (Target: $800 profit)
- Start met 2-3 EA's (conservatief)
- Monitor dagelijks
- Pas lot sizes aan bij winst
- Focus op consistency, niet snelheid

### Fase 3: FTMO Challenge 2 / Verification (Target: $500 profit)
- Gebruik succesvolle EA combinatie
- Mogelijk meer EA's toevoegen
- Blijf binnen risk parameters

### Fase 4: FTMO Funded Account
- Scale up voorzichtig
- Continue monitoring
- Documenteer strategie wijzigingen

## Performance Tracking

### Metrics per EA
- Dagelijkse P&L
- Win rate
- Average win vs average loss
- Maximum drawdown
- Sharpe ratio

### Portfolio Metrics
- Combined daily P&L
- Correlation tussen pairs
- Total exposure
- Risk-adjusted returns

## Troubleshooting Multi-EA Setup

### Probleem: Te veel gelijktijdige trades
**Oplossing**: Pas timing aan of gebruik tijd filters per EA

### Probleem: FTMO limiet snel bereikt
**Oplossing**: Verlaag lot sizes of reduceer aantal actieve EA's

### Probleem: EA's openen conflicterende trades
**Oplossing**: Dit is normaal - verschillende pairs, verschillende strategieën

### Probleem: Performance monitor
**Oplossing**: Gebruik MT4 account history of externe tools zoals MyFxBook

## Best Practices

1. ✅ **Start Klein**: Begin met 1-2 EA's, breid uit naar 4-5
2. ✅ **Test Grondig**: Minimum 4 weken demo testing
3. ✅ **Monitor Dagelijks**: Check totale exposure en P&L
4. ✅ **Documenteer**: Hou trading journal bij voor alle EA's
5. ✅ **Pas Aan**: Optimaliseer parameters op basis van resultaten
6. ✅ **Blijf Disciplined**: Volg FTMO regels strikt
7. ✅ **Gebruik Trailing Stops**: Bescherm winsten
8. ✅ **Diversificeer**: Meerdere pairs = minder risico

## Support

Voor vragen over specifieke EA's of multi-EA setups, open een issue in de GitHub repository.

---

**Succes met uw multi-EA FTMO Challenge strategie! 🚀📈**
