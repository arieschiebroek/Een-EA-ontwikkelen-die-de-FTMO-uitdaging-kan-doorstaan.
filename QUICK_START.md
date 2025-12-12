# 🚀 Quick Start Guide - FTMO Challenge EA

**Voor ervaren traders die snel willen beginnen**

## ⚡ 5-Minuten Setup

### 1. Installeer (2 min)
```
1. Download FTMO_Challenge_EA.mq4
2. MT4 → File → Open Data Folder → MQL4/Experts
3. Kopieer .mq4 bestand daar naartoe
4. Navigator → Expert Advisors → Refresh
```

### 2. Activeer (1 min)
```
1. Open EURUSD chart → Set H1 timeframe
2. Sleep EA naar chart
3. Vink aan: "Allow live trading"
4. Load preset: FTMO_Challenge_EA_Balanced.set
5. Klik OK
```

### 3. Verifieer (1 min)
```
1. Check smiley icoon 😊 in rechterbovenhoek
2. Klik AutoTrading knop (groen)
3. Terminal → Experts tab → Check init bericht
```

### 4. Monitor (1 min)
```
Dagelijks check:
- Open posities (Terminal → Trade tab)
- Log messages (Terminal → Experts tab)
- Account balance en equity
```

✅ **Klaar!** De EA draait nu en monitort de markt.

---

## 📋 Standaard Settings (Balanced Preset)

### Risk Management
- Risk per trade: **1.0%**
- Max daily loss: **4.0%**
- Max total loss: **8.0%**
- Max positions: **3**

### Strategy
- Fast MA: **20 EMA**
- Slow MA: **50 EMA**
- RSI: **14 period**

### Targets
- Stop Loss: **2.0 × ATR**
- Take Profit: **3.0 × ATR**
- R:R ratio: **Min 1.5:1**

---

## 🎯 FTMO Challenge Targets

| Metric | Target | Status Check |
|--------|--------|--------------|
| Profit | €1,000 (10%) | Balance - 10,000 |
| Max Daily Loss | €500 (5%) | Controlled by EA |
| Max Total Loss | €1,000 (10%) | Controlled by EA |
| Trading Days | 10+ days | Track manually |

**Timeline**: 2-4 weken (gemiddeld met 1% risk)

---

## 📊 Expected Performance

### Week-by-Week
- **Week 1**: €200-400 profit
- **Week 2**: €400-700 cumulative
- **Week 3**: €700-900 cumulative
- **Week 4**: €1,000+ ✅ **PASSED**

### Trading Metrics
- Trades per week: **5-15**
- Trades per day: **0-3**
- Win rate target: **>50%**
- Profit factor: **>1.5**

---

## ⚠️ Critical Checks

### Daily
- [ ] AutoTrading enabled (groen)
- [ ] No errors in Experts log
- [ ] Spread is normal (<3 pips)
- [ ] Internet/VPS stable

### Weekly
- [ ] Review all trades
- [ ] Check win rate
- [ ] Verify on track for target
- [ ] No parameter changes needed

---

## 🔧 Quick Troubleshooting

| Problem | Quick Fix |
|---------|-----------|
| EA niet zichtbaar | Refresh Navigator of herstart MT4 |
| "Not allowed to trade" | Tools → Options → Enable auto trading |
| Geen trades | Normaal! Wacht op signalen (kan dagen duren) |
| Te veel verliezen | Switch naar Conservative preset |
| Daily loss bereikt | Wacht tot volgende dag (EA stopt auto) |

---

## 💡 Pro Tips

1. **Start op Demo**: Test 2 weken eerst
2. **Gebruik VPS**: Voor 24/7 operatie
3. **Één Symbool**: Begin met EURUSD
4. **Geduld**: Sommige dagen geen trades = normaal
5. **Niet Aanpassen**: Laat parameters met rust
6. **Trust the Process**: Accept verlies trades

---

## 🔄 Best Practices

### DO ✅
- Test eerst op demo
- Gebruik VPS voor stabiliteit
- Monitor dagelijks
- Accepteer enkele verlies trades
- Laat EA zijn werk doen
- Documenteer alle trades

### DON'T ❌
- Handmatig trades sluiten
- Dagelijks parameters wijzigen
- Paniek bij verlies trades
- Meerdere symbolen tegelijk (in begin)
- EA uitzetten bij eerste verlies
- Te veel optimaliseren van parameters

---

## 📞 Need Help?

1. Check `INSTALLATIE_GIDS.md` voor volledige setup
2. Lees `CONFIGURATIE_GIDS.md` voor optimalisatie
3. Check Experts log voor errors
4. Review `README.md` voor strategie details

---

## 🎓 Presets Kiezen

### Conservative (0.5% risk)
**Voor**: Beginners, eerste FTMO poging
**Verwacht**: Langzamer naar target, veiliger

### Balanced (1.0% risk) ⭐ **AANBEVOLEN**
**Voor**: Ervaren traders, standaard FTMO
**Verwacht**: 2-4 weken naar target

### Custom
**Voor**: Experts die willen optimaliseren
**Zie**: CONFIGURATIE_GIDS.md

---

## 📈 Success Metrics

### Good Signs ✅
- Win rate >50%
- Consistent kleine winsten
- Drawdown <3%
- 1-2 trades per dag gemiddeld

### Warning Signs ⚠️
- Win rate <40%
- Grote verliezen (>2% per trade)
- Drawdown >5%
- Teveel trades per dag (>5)

**Bij Warning Signs**: 
1. Stop EA
2. Review settings
3. Switch naar Conservative
4. Test weer op demo

---

## 🏆 Challenge Completion

Wanneer je €1,000+ profit hebt:

1. ✅ Verify minimum 10 trading dagen
2. ✅ Check geen regel overtreding
3. ✅ Documenteer je trades
4. ✅ Request verification
5. 🎉 **Gefeliciteerd!**

---

**Remember**: Past performance ≠ Future results

*Trade safe, stay disciplined, trust the process* 🚀
