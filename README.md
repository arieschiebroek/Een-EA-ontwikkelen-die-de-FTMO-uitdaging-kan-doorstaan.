# FTMO Challenge Expert Advisors - Multi-Currency Portfolio

Een complete collectie van Expert Advisors voor MetaTrader 4, elk geoptimaliseerd voor specifieke currency pairs en allemaal FTMO Challenge compliant.

## 🎯 Multi-EA Strategie

Deze repository bevat **6 verschillende Expert Advisors**, elk met een unieke strategie:

1. **FTMO_EA.mq4** - Basis/Universeel (alle pairs)
2. **FTMO_EURUSD_EA.mq4** - Geoptimaliseerd voor EUR/USD
3. **FTMO_USDJPY_EA.mq4** - Geoptimaliseerd voor USD/JPY
4. **FTMO_GBPUSD_EA.mq4** - Geoptimaliseerd voor GBP/USD
5. **FTMO_AUDUSD_EA.mq4** - Geoptimaliseerd voor AUD/USD
6. **FTMO_XAUUSD_EA.mq4** - Geoptimaliseerd voor XAU/USD (Gold)

## ✨ Features

- ✅ **FTMO Compliant**: Alle EA's volgen FTMO regels automatisch
- ✅ **Currency-Specific Strategieën**: Elke EA aangepast voor het betreffende paar
- ✅ **Risk Management**: Ingebouwde stop loss en take profit per EA
- ✅ **Dagelijkse Verlies Limiet**: $500 gezamenlijk voor alle EA's
- ✅ **Maximale Drawdown**: $1,000 bescherming over alle EA's
- ✅ **Unique Magic Numbers**: Geen conflicten bij multi-EA setup
- ✅ **H1 Timeframe**: Alle EA's werken op 1-uur charts
- ✅ **Portfolio Diversificatie**: Handel 4-5 pairs tegelijk voor betere spreiding

## 📋 Vereisten

- MetaTrader 4 Platform
- FTMO Challenge Account ($10,000)
- H1 Timeframe
- Minimaal 4 handelsdagen voor FTMO

## 🚀 Snelstart

### Single EA Setup
1. **Download**: Download `FTMO_EA.mq4` uit deze repository
2. **Installeer**: Plaats het bestand in `MT4/MQL4/Experts/`
3. **Configureer**: Open H1 chart en sleep de EA erop
4. **Start**: Zet "Allow live trading" aan

### Multi-EA Portfolio Setup (Aanbevolen)
1. **Download**: Download 3-5 currency-specific EA's (bijv. EURUSD, USDJPY, GBPUSD, AUDUSD)
2. **Installeer**: Plaats alle bestanden in `MT4/MQL4/Experts/`
3. **Configureer**: Open H1 chart voor elk paar en sleep de juiste EA erop
4. **Optimaliseer**: Verlaag lot size per EA (bijv. 0.008) voor veiligere diversificatie
5. **Start**: Monitor totale exposure over alle EA's

➡️ **Gedetailleerde instructies**: Zie [INSTALLATIE.md](INSTALLATIE.md)
➡️ **Multi-EA guide**: Zie [CURRENCY_SPECIFIC_EAS.md](CURRENCY_SPECIFIC_EAS.md)

## 📚 Documentatie

- **[CURRENCY_SPECIFIC_EAS.md](CURRENCY_SPECIFIC_EAS.md)** - 🆕 Complete gids voor alle currency-specific EA's
- **[INSTALLATIE.md](INSTALLATIE.md)** - Complete installatie en gebruiks handleiding
- **[VORIGE_SESSIE.md](VORIGE_SESSIE.md)** - Uitleg over ontwikkeling en eerdere sessie
- **Expert Advisor Files**:
  - [FTMO_EA.mq4](FTMO_EA.mq4) - Basis EA
  - [FTMO_EURUSD_EA.mq4](FTMO_EURUSD_EA.mq4) - EUR/USD specialist
  - [FTMO_USDJPY_EA.mq4](FTMO_USDJPY_EA.mq4) - USD/JPY specialist
  - [FTMO_GBPUSD_EA.mq4](FTMO_GBPUSD_EA.mq4) - GBP/USD specialist
  - [FTMO_AUDUSD_EA.mq4](FTMO_AUDUSD_EA.mq4) - AUD/USD specialist
  - [FTMO_XAUUSD_EA.mq4](FTMO_XAUUSD_EA.mq4) - Gold specialist

## 🎯 FTMO Regels Implementatie

| Regel | Limiet | Status |
|-------|--------|--------|
| Max Dagelijks Verlies | $500 (5%) | ✅ Geïmplementeerd |
| Max Totale Drawdown | $1,000 (10%) | ✅ Geïmplementeerd |
| Minimum Handelsdagen | 4 dagen | ⚠️ Handmatig monitoren |
| Profit Target (Challenge 1) | $800 (8%) | 📊 Doel |
| Profit Target (Verificatie) | $500 (5%) | 📊 Doel |

## 📈 Trading Strategieën per Currency

### FTMO_EURUSD_EA
- **Strategie**: EMA (9/21) + RSI + ATR volatiliteit filter
- **SL/TP**: 80/120 pips
- **Specials**: Trailing stop, volatiliteit check

### FTMO_USDJPY_EA
- **Strategie**: EMA (8/18) + RSI + Bollinger Bands mean reversion
- **SL/TP**: 90/135 pips
- **Specials**: BB extremen, ATR trailing stop

### FTMO_GBPUSD_EA
- **Strategie**: EMA (10/20) + MACD + SMA 50 trend
- **SL/TP**: 110/165 pips
- **Specials**: Sterke trend-following, MACD bevestiging

### FTMO_AUDUSD_EA
- **Strategie**: EMA (11/22) + Stochastic + ADX
- **SL/TP**: 85/130 pips
- **Specials**: Stochastic timing, ADX trend sterkte

### FTMO_XAUUSD_EA (Gold)
- **Strategie**: EMA (15/30) + RSI + ATR + Support/Resistance
- **SL/TP**: 200/300 pips
- **Specials**: S/R levels, MA200, grote stops voor volatiliteit

➡️ **Volledige strategie details**: [CURRENCY_SPECIFIC_EAS.md](CURRENCY_SPECIFIC_EAS.md)

## ⚙️ Aanbevolen Instellingen

### Single EA
```
LotSize = 0.01              // Standaard voor $10k account
MaxDailyLoss = 500          // $500 dagelijkse limiet
MaxTotalDrawdown = 1000     // $1,000 totale limiet
```

### Multi-EA Portfolio (4-5 EA's)
```
LotSize = 0.007-0.008       // Lagere lot per EA voor diversificatie
MaxDailyLoss = 500          // GEDEELD tussen alle EA's
MaxTotalDrawdown = 1000     // GEDEELD tussen alle EA's
```

**Voordelen Multi-EA Aanpak:**
- ✅ Diversificatie over meerdere markets
- ✅ Meer handelskansen (verschillende pairs)
- ✅ Risico spreiding
- ✅ Unieke strategieën per paar

## ⚠️ Waarschuwingen

- Deze EA garandeert **GEEN** winst
- Test **altijd** eerst op demo account
- Monitor de EA regelmatig
- Gebruik alleen geld dat je kunt verliezen
- FTMO regels kunnen wijzigen - verifieer actuele regels

## 🛠️ Troubleshooting

**EA handelt niet?**
- Check of "Allow live trading" is aangevinkt
- Verifieer dat er een nieuwe H1 bar is
- Controleer de Experts tab voor errors

**Meer problemen?** Zie [INSTALLATIE.md](INSTALLATIE.md) voor uitgebreide troubleshooting.

## 📊 Backtesting

1. Open Strategy Tester (Ctrl + R)
2. Selecteer FTMO_EA
3. Kies H1 timeframe
4. Gebruik minimaal 6 maanden data
5. Analyseer: Profit Factor > 1.5, Win Rate > 50%

## 🤝 Contributing

Voel je vrij om issues te openen of pull requests in te dienen voor verbeteringen.

## 📄 Licentie

Open source - vrij te gebruiken voor persoonlijk gebruik.

---

**Veel succes met de FTMO Challenge! 🎯📈**

Deze EA moet werken op MT4 op een account van 10000,- en H1.
