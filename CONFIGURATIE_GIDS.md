# FTMO Challenge EA - Configuratie Gids

## 🎯 Voorgeconfigureerde Settings voor Verschillende Scenarios

### 1. Conservatief (Aanbevolen voor beginners)

**Risk Management**
```
RiskPercentPerTrade = 0.5
MaxDailyLossPercent = 3.0
MaxTotalLossPercent = 6.0
MaxOpenPositions = 2
```

**Strategy**
```
FastMA_Period = 20
SlowMA_Period = 50
RSI_Period = 14
RSI_Overbought = 65
RSI_Oversold = 35
ATR_Period = 14
```

**Trade Management**
```
StopLossATR = 2.5
TakeProfitATR = 4.0
UseTrailingStop = true
TrailingStopATR = 2.0
MinRiskRewardRatio = 2.0
```

**Kenmerken**: Laag risico, minder trades, hogere win rate verwacht

---

### 2. Balanced (Aanbevolen voor FTMO challenge)

**Risk Management**
```
RiskPercentPerTrade = 1.0
MaxDailyLossPercent = 4.0
MaxTotalLossPercent = 8.0
MaxOpenPositions = 3
```

**Strategy**
```
FastMA_Period = 20
SlowMA_Period = 50
RSI_Period = 14
RSI_Overbought = 70
RSI_Oversold = 30
ATR_Period = 14
```

**Trade Management**
```
StopLossATR = 2.0
TakeProfitATR = 3.0
UseTrailingStop = true
TrailingStopATR = 1.5
MinRiskRewardRatio = 1.5
```

**Kenmerken**: Gebalanceerd tussen risico en rendement, standaard settings

---

### 3. Agressief (Alleen voor ervaren traders)

**Risk Management**
```
RiskPercentPerTrade = 1.5
MaxDailyLossPercent = 4.5
MaxTotalLossPercent = 8.5
MaxOpenPositions = 4
```

**Strategy**
```
FastMA_Period = 15
SlowMA_Period = 40
RSI_Period = 10
RSI_Overbought = 75
RSI_Oversold = 25
ATR_Period = 10
```

**Trade Management**
```
StopLossATR = 1.5
TakeProfitATR = 2.5
UseTrailingStop = true
TrailingStopATR = 1.0
MinRiskRewardRatio = 1.3
```

**Kenmerken**: Meer trades, hoger risico, kan sneller profit target bereiken

---

## 📊 Symbool-Specifieke Settings

### EURUSD (Aanbevolen voor beginners)
```
MaxSpreadPips = 2.0
StopLossATR = 2.0
TakeProfitATR = 3.0
StartHour = 7
EndHour = 20
```
**Reden**: Laagste spreads, hoogste liquiditeit

### GBPUSD
```
MaxSpreadPips = 2.5
StopLossATR = 2.5
TakeProfitATR = 3.5
StartHour = 7
EndHour = 20
```
**Reden**: Meer volatiel dan EUR/USD

### USDJPY
```
MaxSpreadPips = 2.0
StopLossATR = 2.0
TakeProfitATR = 3.0
StartHour = 0
EndHour = 8
TradeOnMonday = false
```
**Reden**: Best tijdens Aziatische sessie

### AUDUSD
```
MaxSpreadPips = 2.5
StopLossATR = 2.0
TakeProfitATR = 3.0
StartHour = 22
EndHour = 8
```
**Reden**: Volgt Australische/Aziatische sessie

### GBPJPY (Gevorderd)
```
MaxSpreadPips = 4.0
StopLossATR = 3.0
TakeProfitATR = 4.5
StartHour = 7
EndHour = 20
MinRiskRewardRatio = 2.0
```
**Reden**: Zeer volatiel, hogere spreads

---

## ⏰ Tijdzone Aanpassingen

De EA gebruikt MT4 server tijd. Pas StartHour en EndHour aan op basis van je broker:

### GMT+0 Broker
```
StartHour = 7    // London open
EndHour = 20     // Voor NYSE close
```

### GMT+2 Broker (meeste Europese brokers)
```
StartHour = 9    // London open (lokale tijd)
EndHour = 22     // Voor NYSE close
```

### GMT+3 Broker
```
StartHour = 10   // London open (lokale tijd)
EndHour = 23     // Voor NYSE close
```

**Tip**: Check je broker tijd met `TimeGMTOffset()` of in MT4 Market Watch

---

## 📅 Week Planning

### Maandag
```
TradeOnMonday = true (met voorzichtigheid)
RiskPercentPerTrade = 0.75  // Verlaag risico op maandag
```
**Reden**: Vaak gap na weekend, meer volatiliteit

### Dinsdag - Donderdag (Beste dagen)
```
TradeOnMonday = true
RiskPercentPerTrade = 1.0   // Normaal risico
MaxOpenPositions = 3
```
**Reden**: Meeste liquiditeit, voorspelbare bewegingen

### Vrijdag
```
TradeOnFriday = true
EndHour = 16    // Stop vroeg op vrijdag
MaxOpenPositions = 2  // Minder posities
```
**Reden**: Posities sluiten voor weekend

---

## 🎲 Optimalisatie Strategie

### Stap 1: Basis Testing (Week 1)
- Gebruik **Balanced** settings
- Test op **EURUSD** H1
- Monitor resultaten dagelijks
- Accepteer 5-10 trades per week als normaal

### Stap 2: Analyse (Week 2)
Analyseer:
- Win rate (target: >50%)
- Average win/loss ratio (target: >1.5)
- Maximum drawdown (moet <5% zijn)
- Aantal trades per dag (target: 1-2)

### Stap 3: Fine-Tuning
Als win rate < 45%:
```
MinRiskRewardRatio = 2.0
RSI_Overbought = 65
RSI_Oversold = 35
```

Als te weinig trades:
```
FastMA_Period = 15
SlowMA_Period = 40
MinRiskRewardRatio = 1.3
```

Als te veel verlies trades:
```
StopLossATR = 2.5
TakeProfitATR = 4.0
MaxSpreadPips = 2.0
```

### Stap 4: Live Trading
- Start met **Conservatief** settings
- Eerste week: 0.5% risk
- Tweede week: 0.75% risk (als profitable)
- Derde week+: 1.0% risk (als consistent profitable)

---

## 🚨 Emergency Settings (Als je dicht bij loss limiet bent)

Als je balance < €9,500:
```
RiskPercentPerTrade = 0.3
MaxDailyLossPercent = 2.0
MaxOpenPositions = 1
MinRiskRewardRatio = 2.5
UseTrailingStop = false  // Neem volle profit
```

Als dagelijks verlies > €300:
```
Stop de EA voor de dag
Analyseer wat er mis ging
Herstart volgende dag met lagere risk
```

---

## 📈 Success Metrics

### Target voor FTMO Challenge (10K account, 30 dagen)

**Week 1**: 
- Target: +€200 tot +€400
- Max Drawdown: <€200

**Week 2**: 
- Target: +€400 tot +€700
- Max Drawdown: <€300

**Week 3**: 
- Target: +€700 tot +€900
- Max Drawdown: <€400

**Week 4**: 
- Target: >€1,000 (Challenge passed!)
- Max Drawdown: <€500

### Minimum Vereisten
- ✅ 10 trading dagen (EA regelt dit automatisch)
- ✅ Max daily loss niet overschreden
- ✅ Max loss niet overschreden
- ✅ Profit target €1,000 bereikt

---

## 🔧 Geavanceerde Optimalisaties

### Multi-Timeframe Confirmatie (Handmatige check)
Voordat je de EA start:
- Check H4 trend (moet in lijn zijn met H1 trades)
- Check Daily support/resistance
- Vermijd trading tijdens grote ranging periodes

### News Events
De EA stopt niet automatisch bij nieuws. Handmatig:
- **Hoog impact nieuws**: Stop EA 30 min voor, start 30 min na
- **Medium impact**: Laat draaien maar monitor
- **Laag impact**: Laat gewoon draaien

Belangrijke news events:
- NFP (Eerste vrijdag van maand)
- FOMC meetings
- Central bank rate decisions
- GDP releases

### Broker Optimalisatie
Voor ECN brokers:
```
MaxSpreadPips = 2.0  // Meestal lagere spreads
```

Voor Market Maker brokers:
```
MaxSpreadPips = 3.5  // Vaak hogere spreads
Controleer execution quality
```

---

## 📊 Performance Tracking

Houd bij in een Excel/Google Sheet:

| Datum | Trades | Wins | Losses | P/L | Balance | Daily DD | Notes |
|-------|---------|------|--------|-----|---------|----------|-------|
| 01/01 | 2 | 1 | 1 | +€50 | €10,050 | €30 | EURUSD trending |
| 02/01 | 1 | 1 | 0 | +€80 | €10,130 | €0 | Good signal |

Track ook:
- Beste trading dagen (DI, WO, DO meestal best)
- Beste trading uren
- Beste symbolen
- Win rate per setup type

---

## 💡 Pro Tips

1. **Start Klein**: Begin met 1 symbool (EURUSD aanbevolen)
2. **Wees Geduldig**: Accepteer dat sommige dagen geen trades zijn
3. **Trust the System**: Wijzig niet dagelijks parameters
4. **Monitor maar Manage Niet**: Kijk naar trades maar close ze niet handmatig
5. **Accepteer Verliezen**: Verlies trades zijn onderdeel van het systeem
6. **Schuif Winsten Op**: Als je €500+ profit hebt, verlaag risk naar 0.75%
7. **Documenteer Alles**: Leer van elke trade cycle
8. **Gebruik VPS**: Voorkom verbindingsproblemen

---

## ❓ Veelgestelde Vragen

**Q: Hoeveel trades per week kan ik verwachten?**
A: Met standaard settings: 5-15 trades per week afhankelijk van marktcondities

**Q: Kan ik op meerdere symbolen tegelijk draaien?**
A: Ja, maar start met 1 symbool en voeg toe na 2 weken success

**Q: Moet ik parameters optimaliseren per symbool?**
A: De standaard settings werken op meeste majors, maar zie symbool-specifieke sectie

**Q: Wat als ik de daily loss limit raak?**
A: EA stopt automatisch. Analyseer wat fout ging, start volgende dag opnieuw

**Q: Hoe lang duurt het om de challenge te halen?**
A: Met 1% risk: 2-4 weken gemiddeld (afhankelijk van marktcondities)

---

Succes met de FTMO Challenge! 🚀
