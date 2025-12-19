# FTMO Challenge Expert Advisor

Een Expert Advisor voor MetaTrader 4 die voldoet aan alle FTMO Challenge regels.

## ✨ Features

- ✅ **FTMO Compliant**: Automatische naleving van alle FTMO regels
- ✅ **Risk Management**: Ingebouwde stop loss en take profit
- ✅ **Dagelijkse Verlies Limiet**: Automatisch stoppen bij $500 verlies
- ✅ **Maximale Drawdown**: Bescherming tegen >$1,000 drawdown
- ✅ **Trading Strategie**: EMA crossover + RSI indicator systeem
- ✅ **H1 Timeframe**: Geoptimaliseerd voor 1-uur charts
- ✅ **$10,000 Account**: Specifiek ingesteld voor FTMO Challenge

## 📋 Vereisten

- MetaTrader 4 Platform
- FTMO Challenge Account ($10,000)
- H1 Timeframe
- Minimaal 4 handelsdagen voor FTMO

## 🚀 Snelstart

1. **Download**: Download `FTMO_EA.mq4` uit deze repository
2. **Installeer**: Plaats het bestand in `MT4/MQL4/Experts/`
3. **Configureer**: Open H1 chart en sleep de EA erop
4. **Start**: Zet "Allow live trading" aan

➡️ **Gedetailleerde instructies**: Zie [INSTALLATIE.md](INSTALLATIE.md)

## 📚 Documentatie

- **[INSTALLATIE.md](INSTALLATIE.md)** - Complete installatie en gebruiks handleiding
- **[VORIGE_SESSIE.md](VORIGE_SESSIE.md)** - Uitleg over ontwikkeling en eerdere sessie
- **[FTMO_EA.mq4](FTMO_EA.mq4)** - De Expert Advisor code

## 🎯 FTMO Regels Implementatie

| Regel | Limiet | Status |
|-------|--------|--------|
| Max Dagelijks Verlies | $500 (5%) | ✅ Geïmplementeerd |
| Max Totale Drawdown | $1,000 (10%) | ✅ Geïmplementeerd |
| Minimum Handelsdagen | 4 dagen | ⚠️ Handmatig monitoren |
| Profit Target (Challenge 1) | $800 (8%) | 📊 Doel |
| Profit Target (Verificatie) | $500 (5%) | 📊 Doel |

## 📈 Trading Strategie

**Indicatoren:**
- EMA (12, 26) - Trend identificatie
- RSI (14) - Momentum en overbought/oversold

**Entry Regels:**
- **Buy**: Fast EMA kruist boven Slow EMA + RSI < 50
- **Sell**: Fast EMA kruist onder Slow EMA + RSI > 50

**Risk Management:**
- Stop Loss: 100 pips (1% risico)
- Take Profit: 150 pips (1.5% winst)
- Risk/Reward Ratio: 1:1.5
- Maximum 1 positie tegelijk

## ⚙️ Aanbevolen Instellingen

```
LotSize = 0.01              // Veilig voor $10k account
StopLoss = 100              // 100 pips
TakeProfit = 150            // 150 pips (1.5:1 R:R)
MaxDailyLoss = 500          // $500 dagelijkse limiet
MaxTotalDrawdown = 1000     // $1,000 totale limiet
```

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
