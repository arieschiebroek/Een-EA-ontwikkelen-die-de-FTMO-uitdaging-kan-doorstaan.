# Volgende Stappen - Van Code naar Live Trading

## 🎯 Overzicht

Je hebt nu een complete FTMO Challenge EA! Dit document begeleidt je van de huidige code naar succesvol live trading.

## ✅ Wat Je Nu Hebt

- ✅ Complete EA code (FTMO_EA.mq4)
- ✅ Uitgebreide documentatie (7 documenten)
- ✅ Configuratie voorbeelden voor 6+ symbolen
- ✅ Risk management systeem
- ✅ Multi-EA coördinatie
- ✅ FTMO 5% daily loss bescherming

## 📋 Implementatie Roadmap

### FASE 1: Setup & Testing (Week 1)

#### Stap 1: Installeer de EA (30 minuten)
```
□ Download alle bestanden van deze repository
□ Open MetaTrader 4
□ Navigeer naar: Data Folder → MQL4 → Experts
□ Kopieer FTMO_EA.mq4 naar Experts folder
□ Herstart MT4 (of Refresh in Navigator)
```

#### Stap 2: Compileer de EA (5 minuten)
```
□ Open MetaEditor (druk F4 in MT4)
□ Open FTMO_EA.mq4
□ Klik "Compile" (of druk F7)
□ Controleer op errors (moet 0 errors zijn)
□ Sluit MetaEditor
```

#### Stap 3: Demo Account Setup (10 minuten)
```
□ Open demo account bij broker (bij voorkeur FTMO-approved)
□ Account size: €10,000 (simuleer FTMO)
□ Leverage: 1:100 of hoger
□ Zorg voor goede internet connectie
```

#### Stap 4: Eerste EA Installatie - EURUSD (15 minuten)
```
□ Open EURUSD chart, timeframe H1
□ Sleep FTMO_EA vanuit Navigator naar chart
□ Configureer parameters:
  • EA_MagicNumber: 100001
  • RiskPercentPerTrade: 0.5 (conservatief!)
  • StopLossPips: 30
  • TakeProfitPips: 60
  • BreakEvenPips: 15
  • MaxDailyLossPercent: 5.0
□ Klik OK
□ Zorg dat AutoTrading AAN staat (groene knop)
□ Check Expert tab voor "FTMO EA Initialisatie" bericht
```

#### Stap 5: Monitor & Leer (3-7 dagen)
```
□ Laat EA draaien op EURUSD alleen
□ Check dagelijks:
  • Expert tab voor logs
  • Trades in "Trade" tab
  • Account Statistics tab
□ Noteer:
  • Hoeveel trades per dag?
  • Win percentage?
  • Werkt break-even systeem?
□ Pas NIETS aan deze week - leer eerst!
```

### FASE 2: Optimalisatie (Week 2)

#### Stap 6: Analyseer Demo Resultaten (1 uur)
```
□ Open Account History (rechtsklik → Save as Report)
□ Controleer:
  • Total trades: Minimum 10+
  • Win rate: Target >50%
  • Average win vs loss: Target 2:1
  • Max drawdown: Target <3%
□ Identificeer problemen:
  • Te weinig trades? → Signal generatie verbeteren
  • Win rate laag? → Filter toevoegen
  • Drawdown hoog? → Risk verlagen
```

#### Stap 7: Customiseer Trading Strategie (2-4 uren)
```
□ Open FTMO_EA.mq4 in MetaEditor
□ Zoek functie: int GenerateSignal()
□ Huidige strategie: MA crossover
□ Opties voor verbetering:
  
  OPTIE A: RSI Filter Toevoegen
  ─────────────────────────────
  double rsi = iRSI(Symbol(), 0, 14, PRICE_CLOSE, 0);
  
  // Voor BUY: RSI moet > 50 zijn
  if(ma_fast_0 > ma_slow_0 && rsi > 50)
      return 1;
  
  // Voor SELL: RSI moet < 50 zijn
  if(ma_fast_0 < ma_slow_0 && rsi < 50)
      return -1;
  
  OPTIE B: Tijd Filter (Alleen London/NY)
  ─────────────────────────────────────
  int hour = TimeHour(TimeCurrent());
  
  // Alleen traden tussen 07:00-20:00 GMT
  if(hour < 7 || hour > 20)
      return 0; // Geen trading
  
  OPTIE C: Trend Filter (Higher Timeframe)
  ────────────────────────────────────────
  double ma_h4 = iMA(Symbol(), PERIOD_H4, 200, 0, MODE_SMA, PRICE_CLOSE, 0);
  double close = iClose(Symbol(), 0, 0);
  
  // Alleen BUY in uptrend
  if(signal == 1 && close < ma_h4)
      return 0; // Skip BUY in downtrend
  
□ Kies ÉÉN verbetering en implementeer
□ Compileer opnieuw
□ Test op demo
```

#### Stap 8: Parameter Optimalisatie (2-3 dagen)
```
□ Gebruik Strategy Tester in MT4 (Ctrl+R)
□ Test verschillende combinaties:
  • StopLossPips: 20, 25, 30, 35, 40
  • TakeProfitPips: 40, 50, 60, 70, 80
  • BreakEvenPips: 10, 15, 20
□ Zoek optimale balans voor EURUSD
□ Noteer beste parameters
□ Update live demo EA
```

### FASE 3: Multi-Symbol Expansion (Week 3)

#### Stap 9: Voeg Tweede Symbool Toe (30 minuten)
```
□ Kies symbool: GBPUSD of USDJPY (lage correlatie met EURUSD)
□ Open chart, timeframe H1
□ Sleep FTMO_EA naar chart
□ Configureer:
  • EA_MagicNumber: 100002 (BELANGRIJK: Anders dan 100001!)
  • RiskPercentPerTrade: 0.5-1.0
  • StopLossPips: Aangepast voor symbool (zie CONFIGURATIE_VOORBEELDEN.md)
□ Enable AutoTrading
□ Check Expert tab: Beide EA's actief
```

#### Stap 10: Verifieer Coördinatie (2 dagen)
```
□ Monitor beide EA's
□ Check dat slechts 1 EA tegelijk tradet (zonder BE)
□ Verifieer break-even trigger:
  • EA1 opent trade
  • EA1 bereikt BE
  • EA2 kan nu ook traden
□ Check files:
  • C:\Users\[User]\AppData\Roaming\MetaQuotes\Terminal\Common\Files\
  • FTMO_EA_Coordination.txt moet beide EA's tonen
```

#### Stap 11: Optioneel - Derde/Vierde Symbool (1 week)
```
□ Als 2 EA's goed werken, voeg toe:
  • Symbol: XAUUSD (voorzichtig - volatiel!)
  • MagicNumber: 100003
  • Risk: 0.3-0.5% (lager voor gold)
□ OF:
  • Symbol: USDJPY
  • MagicNumber: 100004
  • Risk: 1.0%
□ Monitor portfolio performance
```

### FASE 4: FTMO Challenge Prep (Week 4)

#### Stap 12: Backtest Volledige Setup (1 dag)
```
□ Strategy Tester voor elk symbool:
  • Periode: 1 jaar
  • Model: Every tick (meest accuraat)
  • Optimization: OFF (gebruik je demo settings)
□ Verifieer voor ALLE symbolen:
  • Win rate > 45%
  • Profit factor > 1.5
  • Drawdown < 10%
□ Als niet voldoende → Terug naar optimalisatie
```

#### Stap 13: Demo Challenge Simulatie (2 weken)
```
□ Reset demo account naar €10,000
□ Handel exact zoals FTMO challenge:
  • Max 5% daily loss - Check dagelijks!
  • Doel: 10% in 30 dagen
  • Min 4 trading days
□ Track dagelijks:
  Day 1: Start €10,000
  Day 2: €10,050 (+0.5%)
  Day 3: €10,120 (+1.2%)
  ...etc
□ Doel week 2: >€10,500 (5%+)
□ Doel week 4: >€11,000 (10%+)
```

#### Stap 14: Risk Management Verificatie
```
□ Controleer NOOIT meer dan:
  • 5% verlies op 1 dag
  • 10% totaal verlies
□ Als ooit >4% daily loss:
  → STOP handmatig
  → Analyseer wat fout ging
  → Verbeter strategie/settings
□ Test 5% daily loss limiet:
  → Simuleer grote loss (sluit trades handmatig)
  → Verifieer EA stopt met traden
  → Check dat ALLE EA's stoppen
```

### FASE 5: Live FTMO Challenge (Week 5+)

#### Stap 15: FTMO Account Aanvragen
```
□ Ga naar ftmo.com
□ Kies account size: €10,000 (aanbevolen om mee te starten)
□ Koop FTMO Challenge
□ Ontvang login credentials
□ Login in MT4 met FTMO account
```

#### Stap 16: Live EA Setup (1 uur)
```
BELANGRIJK: Dubbel check alles!

□ Installeer EA op FTMO account (zelfde proces als demo)
□ Start CONSERVATIEF:
  Week 1 settings:
  • Alleen EURUSD
  • Risk: 0.5% per trade
  • Max trades per dag: 5
□ Verifieer:
  • AutoTrading AAN
  • EA draait correct
  • Coördinatie files werken
  • 5% limiet ingesteld
```

#### Stap 17: Challenge Execution (30 dagen)
```
Week 1: Foundation (Doel: 2-3%)
─────────────────────────────────
□ EURUSD alleen
□ Risk: 0.5%
□ Focus: Consistency, no big losses
□ Dagelijkse check: 15 minuten

Week 2: Scale (Doel: 5-7% totaal)
──────────────────────────────────
□ Voeg GBPUSD/USDJPY toe
□ Risk: 0.8-1.0%
□ Monitor coördinatie
□ Dagelijkse check: 20 minuten

Week 3: Accelerate (Doel: 10%+ totaal)
───────────────────────────────────────
□ All EAs actief (max 3-4)
□ Risk: 1.0%
□ Push naar target
□ Dagelijkse check: 30 minuten

Week 4: Protect (Doel: Finish 10%+)
────────────────────────────────────
□ Als >10%: VERLAAG risk naar 0.3%
□ Focus: Behoud winst
□ Wees conservatief
□ Dagelijkse check: 15 minuten
```

#### Stap 18: Daily Routine tijdens Challenge
```
OCHTEND (08:00):
□ Check alle EA's = actief
□ Review overnight trades
□ Check economic calendar
□ Noteer current P&L

MIDDAG (14:00):
□ Quick check P&L
□ Check voor waarschuwingen in Expert tab

AVOND (21:00):
□ Screenshot van stats
□ Noteer daily P&L
□ Update trading journal:
  • Wat werkte?
  • Wat niet?
  • Aanpassingen nodig?
```

### FASE 6: Post-Challenge

#### Als Je PASSEERT ✅
```
□ Congratulations! 🎉
□ Verification Phase (60 dagen, 5% target):
  • Zelfde EA
  • Zelfde settings
  • Nog conservatiever (risk 0.5%)
□ Na verification → Funded account!
```

#### Als Je FAALT ❌
```
□ Analyseer waarom:
  • Te agressief?
  • Strategie fout?
  • Slecht risk management?
□ Fix problemen
□ Test 2 weken extra op demo
□ Probeer opnieuw (vaak 50% korting 2e poging)
```

## 🎓 Best Practices Checklist

### Voor Challenge Start
```
□ Minimum 3 weken demo trading
□ Win rate > 50% bewezen
□ Max drawdown < 5% bewezen
□ Begrijp ALLE EA functies
□ Hebt backup plan voor problemen
```

### Tijdens Challenge
```
□ Check EA 2x per dag minimum
□ Gebruik VPS voor 24/7 uptime
□ Hou trading journal bij
□ NOOIT parameters aanpassen mid-challenge
□ Screenshot maken bij elke milestone
```

### Risk Management
```
□ NOOIT meer dan 1% risk als beginnend
□ Start altijd lager dan je demo deed
□ Verlaag risk als losses komen
□ Bescherm winsten (verlaag risk na 8%+)
```

## 🛠️ Troubleshooting Reference

### "EA opent geen trades"
```
1. Check AutoTrading (groene knop)
2. Check EnableTrading = true
3. Check Expert tab voor errors
4. Check of signaal logica werkt (test in Strategy Tester)
5. Check coordinatie file (andere EA actief?)
```

### "Te veel losses"
```
1. Verlaag RiskPercentPerTrade
2. Vergroot StopLossPips
3. Voeg filters toe aan GenerateSignal()
4. Check of symbool geschikt is
5. Overweeg andere timeframe
```

### "5% limiet niet werkt"
```
1. Check MaxDailyLossPercent = 5.0
2. Check Daily_Loss.txt in Common Files
3. Test handmatig (sluit trades tot -5%)
4. Verifieer dat EA trades sluit
```

## 📊 Success Metrics

Track deze wekelijks:

```
□ Total P&L %
□ Win rate %
□ Aantal trades
□ Average win vs loss
□ Max drawdown
□ Profit factor
□ Recovery factor
```

Targets voor FTMO success:
- Win rate: >50%
- Risk/Reward: >1.5
- Max DD: <8%
- Profit factor: >1.5

## 📞 Support Resources

### Documentatie
1. GEBRUIKSAANWIJZING.md - Volledige manual
2. QUICK_REFERENCE.md - Snelle fixes
3. TECHNISCHE_DOCUMENTATIE.md - Deep dive
4. CONFIGURATIE_VOORBEELDEN.md - Settings

### Tools
1. MT4 Strategy Tester - Backtesting
2. MT4 Expert tab - Logs
3. Trading journal - Excel/Notion

### Community
1. FTMO Discord/Forum
2. MQL4 Forum voor code vragen
3. Trading communities

## ✅ Final Checklist voor Challenge Start

```
□ EA getest op demo minimum 3 weken
□ Win rate > 50% bewezen
□ Multi-EA coördinatie getest
□ 5% daily loss getest (gesimuleerd)
□ VPS setup (voor 24/7 trading)
□ Backup plan voor technical issues
□ Trading journal template klaar
□ Economic calendar toegang
□ Settings gedocumenteerd
□ Confident in strategie
```

## 🎯 Jouw Persoonlijke Roadmap

Vul in:

```
WEEK 1 START DATUM: _____________
DEMO ACCOUNT BROKER: _____________
DEMO START BALANCE: €10,000

SYMBOOL 1: _________ (MagicNumber: ______)
SYMBOOL 2: _________ (MagicNumber: ______)
SYMBOOL 3: _________ (MagicNumber: ______)

CHALLENGE START TARGET: _____________
CHALLENGE GOAL: €11,000+ (10%+)

DAILY CHECK TIMES:
- Ochtend: _____
- Avond: _____

VPS PROVIDER: _____________

BACKUP PLAN:
_________________________________
_________________________________
```

## 🚀 Start Nu!

Je eerste actie vandaag:

```
1. Installeer EA in demo account
2. Configureer EURUSD alleen
3. Laat draaien 24 uur
4. Check resultaten morgen
5. Lees GEBRUIKSAANWIJZING.md compleet
```

---

**Succes met je FTMO Challenge journey!** 🎯

Remember:
- Start klein
- Test grondig  
- Wees geduldig
- Volg het plan
- Leer van fouten

**Versie**: 1.0  
**Voor**: FTMO Challenge EA Gebruikers
