# FTMO EA - Quick Reference Guide

## 🚀 Snelle Installatie (5 minuten)

1. Download `FTMO_EA.mq4`
2. Kopieer naar `C:\Program Files\[Broker]\MQL4\Experts\`
3. Herstart MT4
4. Sleep EA naar H1 chart
5. Configureer (zie hieronder)
6. Enable AutoTrading (groene knop)

## ⚙️ Basis Configuratie (Kopieer & Plak)

### EURUSD Setup (Start hier!)
```
EA_MagicNumber: 100001
RiskPercentPerTrade: 1.0
StopLossPips: 30
TakeProfitPips: 60
BreakEvenPips: 15
BreakEvenExtraPips: 5
MaxDailyLossPercent: 5.0
MaxTradesPerDay: 5
```

### Als je een tweede symbool toevoegt (bijv. GBPUSD)
```
EA_MagicNumber: 100002 (MOET verschillend zijn!)
RiskPercentPerTrade: 1.0
StopLossPips: 40
TakeProfitPips: 80
BreakEvenPips: 20
```

## 📋 Dagelijkse Checklist

### Ochtend (Voor Trading)
- [ ] Check of alle EA's actief zijn (groene knop)
- [ ] Verifieer account balance
- [ ] Check economic calendar voor nieuws
- [ ] Bekijk Expert tab voor errors

### Avond (Na Trading)
- [ ] Review dagelijkse P&L
- [ ] Check hoeveel trades per EA
- [ ] Noteer welke setups werkten
- [ ] Backup coördinatie files (optioneel)

## 🎯 Belangrijkste Regels (Onthoud Deze!)

1. **Elk symbool = Uniek Magic Number**
   ```
   EURUSD: 100001
   GBPUSD: 100002
   XAUUSD: 100003
   ```

2. **Alleen 1 EA actief zonder break-even**
   ```
   ✅ EA1 heeft trade zonder BE → Andere wachten
   ✅ EA1 bereikt BE → Andere mogen nu
   ❌ Twee EA's tegelijk zonder BE → FOUT!
   ```

3. **5% Daily Loss = STOP**
   ```
   Start: €10,000
   Limiet: €9,500
   Bij bereikt: Alles wordt gesloten
   ```

4. **Test eerst op DEMO!**
   ```
   Minimaal 1 week
   Check alle functies
   Verifieer winsten
   ```

## 🔧 Meest Voorkomende Problemen & Oplossingen

### "EA opent geen trades"
**Check**:
1. Is AutoTrading AAN? (groene knop rechts boven)
2. Is `EnableTrading = true`?
3. Is dagelijkse limiet bereikt? (check Expert tab)
4. Heeft andere EA al een trade zonder BE?

**Fix**: 
```
// In EA settings
EnableTrading: true

// Check Expert tab output voor:
"Dagelijkse verlies limiet bereikt"
"Andere EA heeft actieve trade"
```

### "Break-even activeert niet"
**Check**:
1. Heeft trade genoeg winst? (>= BreakEvenPips)
2. Is spread te groot?

**Fix**:
```
// Verlaag BreakEvenPips
BreakEvenPips: 15 → 10

// OF verhoog bij high spread
BreakEvenExtraPips: 5 → 8
```

### "Te veel losses"
**Fix**:
```
// Verlaag risk
RiskPercentPerTrade: 1.0 → 0.5

// Vergroot SL
StopLossPips: 30 → 40

// OF verbeter strategie in GenerateSignal()
```

### "Meerdere EA's traden tegelijk"
**Dit is een FOUT! Fix**:
```
// Check of elk EA uniek Magic Number heeft
EA 1: 100001
EA 2: 100002 (NIET 100001!)

// Check coördinatie files:
C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\Common\Files\
- FTMO_EA_Coordination.txt
- FTMO_Daily_Loss.txt
```

## 📊 Performance Monitoring

### Wat te monitoren?
```
Dagelijks:
- Total P&L (moet > 0 trend hebben)
- Win Rate (doel: >50%)
- Aantal trades (niet te veel, niet te weinig)

Wekelijks:
- Drawdown (max 5% per dag, 10% totaal)
- Profit naar target (doel 10% per maand)
- Welke symbolen presteren best
```

### Goede Performance Indicators
```
✅ Win rate: 50-60%
✅ Risk/Reward: 1:2 of beter
✅ Max daily loss: <3% (limiet is 5%)
✅ Trades per week: 10-20 (niet overtraden)
```

### Slechte Performance Indicators
```
❌ Win rate: <40%
❌ Daily losses: Frequent 4-5%
❌ Trades per day: >20 (overtrading)
❌ Veel breakeven hits zonder profit
```

## 🎓 FTMO Challenge Strategie

### Week 1: Build Foundation
```
✅ Start met EURUSD alleen
✅ Risk: 0.5% per trade
✅ Doel: 2-3% profit, GEEN grote losses
✅ Leer hoe EA werkt
```

### Week 2: Scale Up
```
✅ Voeg GBPUSD of USDJPY toe
✅ Risk: 0.8-1.0% per trade
✅ Doel: 5-7% total profit
✅ Monitor coördinatie tussen EA's
```

### Week 3: Accelerate
```
✅ Optioneel: Voeg 3e symbool toe
✅ Risk: 1.0% per trade
✅ Doel: 10% total profit
✅ Focus op consistency
```

### Week 4: Protect
```
✅ ALS je >10% hebt: VERLAAG RISK
✅ Risk: 0.3-0.5% per trade
✅ Doel: Behoud profit, finish challenge
✅ Wees conservatief!
```

## 💡 Pro Tips

### Tip 1: Correlatie
```
⚠️ EURUSD en GBPUSD zijn gecorreleerd
→ Als beide verlies = dubbel risico!
→ Overweeg: EURUSD + USDJPY (minder correlatie)
```

### Tip 2: Tijd Filters
```
💡 Beste trading tijden:
- London Open: 08:00-12:00 GMT (EURUSD, GBPUSD)
- NY Open: 13:00-17:00 GMT (alle pairs)
- Asian: 00:00-06:00 GMT (USDJPY, AUDUSD)

⚠️ Vermijd:
- Vrijdag na 16:00 GMT
- Voor/tijdens major news
- Lage liquiditeit perioden
```

### Tip 3: Parameter Tuning
```
📊 Als win rate <50%:
→ Verbeter signal logica (GenerateSignal)
→ Voeg filters toe
→ Overweeg andere timeframe

📊 Als win rate >60% maar weinig trades:
→ Versoepel entry condities
→ Voeg meer symbolen toe
→ Check of BreakEvenPips niet te hoog is
```

### Tip 4: Backtest
```
🧪 Voor live trading:
1. Open Strategy Tester (Ctrl+R)
2. Selecteer FTMO_EA
3. Symbool: EURUSD
4. Periode: H1
5. Data: 1 jaar
6. Model: Every tick
7. Run!

📊 Check resultaten:
- Total trades: >100
- Win%: >45%
- Profit factor: >1.5
- Drawdown: <10%
```

## 📞 Hulp Nodig?

### Volgorde van troubleshooting:
1. **Check deze Quick Reference** ↑
2. **Lees GEBRUIKSAANWIJZING.md** (gedetailleerd)
3. **Check Expert tab** in MT4 voor logs
4. **Test op demo** om probleem te isoleren
5. **Review TECHNISCHE_DOCUMENTATIE.md** (voor developers)

### Nuttige Logs Locaties
```
MT4 Logs:
C:\Program Files\[Broker]\MQL4\Logs\

Expert Tab in MT4:
→ Klik "Expert Advisors" onderaan
→ Zoek naar jouw EA output
→ Errors zijn in ROOD
```

## 🎯 Snelle Optimalisatie

### Te conservatief? (Weinig trades, langzame groei)
```
➕ Verlaag BreakEvenPips: 20 → 15
➕ Verhoog MaxTradesPerDay: 5 → 8
➕ Verhoog Risk: 0.5 → 1.0%
```

### Te agressief? (Veel losses, hoge drawdown)
```
➖ Verhoog BreakEvenPips: 15 → 20
➖ Verlaag MaxTradesPerDay: 10 → 5
➖ Verlaag Risk: 1.5 → 1.0%
➖ Vergroot StopLoss: 30 → 40
```

### Perfect balance? (50%+ win rate, consistent growth)
```
✅ Verander NIETS!
✅ Monitor 1x per week
✅ Alleen aanpassen bij marktverandering
```

## 📱 Daily Routine (3 minuten)

### Morgen (09:00)
```
1. Open MT4
2. Check alle EA's = groen
3. Check geen errors in Expert tab
4. Klaar!
```

### Avond (21:00)
```
1. Screenshot van account stats
2. Noteer P&L van vandaag
3. Check: Onder 5% loss? ✅
4. Klaar voor morgen!
```

---

## ⚡ Ultra Quick Setup (Copy-Paste)

**1. Eerste EA (EURUSD):**
```
Magic: 100001, Risk: 1.0, SL: 30, TP: 60, BE: 15
```

**2. Tweede EA (GBPUSD):**
```
Magic: 100002, Risk: 1.0, SL: 40, TP: 80, BE: 20
```

**3. Enable AutoTrading**

**4. Done!** ✅

---

**🎯 Doel: 10% in 30 dagen**  
**⚠️ Limiet: Max 5% loss per dag**  
**✅ Regel: 1 EA actief zonder BE tegelijk**

---

Print deze pagina en houd bij je trading station! 📄

**Versie**: 1.0  
**Platform**: MetaTrader 4
