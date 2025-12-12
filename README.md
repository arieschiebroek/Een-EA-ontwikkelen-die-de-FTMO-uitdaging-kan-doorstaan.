# FTMO Challenge Expert Advisor

Een geavanceerde Expert Advisor (EA) voor MetaTrader 4 die speciaal ontworpen is om de FTMO Challenge te doorstaan.

## ✨ Belangrijkste Kenmerken

- 🔄 **Multi-Symbol Trading** - Meerdere EA's op één account (XAUUSD, EURUSD, GBPUSD, etc.)
- 🛡️ **Break-Even Bescherming** - Automatische stop-loss management
- 📊 **FTMO 5% Dagelijkse Limiet** - Automatische beveiliging tegen overmatig verlies
- 🤝 **Gecoördineerde Trading** - Intelligente communicatie tussen EA instanties
- ⚙️ **Volledig Configureerbaar** - Pas aan voor elk symbool en strategie

## 📋 Vereisten

- MetaTrader 4 (MT4)
- Account van €10,000 (of andere FTMO account size)
- Timeframe: H1 (of naar wens configureerbaar)
- VPS aanbevolen voor 24/7 trading

## 🚀 Snelstart

1. **Download** `FTMO_EA.mq4`
2. **Kopieer** naar `MT4/MQL4/Experts/`
3. **Compileer** in MetaEditor
4. **Sleep** EA naar chart (H1 timeframe aanbevolen)
5. **Configureer** parameters per symbool
6. **Enable** AutoTrading

Zie [GEBRUIKSAANWIJZING.md](GEBRUIKSAANWIJZING.md) voor gedetailleerde installatie-instructies.

## 📚 Documentatie

- **[GEBRUIKSAANWIJZING.md](GEBRUIKSAANWIJZING.md)** - Volledige gebruikersgids
- **[TECHNISCHE_DOCUMENTATIE.md](TECHNISCHE_DOCUMENTATIE.md)** - Technische details voor developers
- **[CONFIGURATIE_VOORBEELDEN.md](CONFIGURATIE_VOORBEELDEN.md)** - Pre-configured settings voor verschillende symbolen

## 🎯 FTMO Challenge Specificaties

Deze EA helpt met:
- ✅ Automatische 5% dagelijkse verlies limiet
- ✅ Consistent risico management (1% per trade)
- ✅ Break-even bescherming voor capital preservation
- ✅ Multi-symbol diversificatie
- ✅ Gecontroleerd aantal trades per dag

**FTMO Regels**:
- Account: €10,000
- Profit Target: 10% in 30 dagen (Phase 1)
- Max Daily Loss: 5%
- Max Total Loss: 10%
- Minimum Trading Days: 4

## ⚙️ Configuratie Voorbeeld

```mql4
// EURUSD Configuratie
EA_MagicNumber = 100001
StopLossPips = 30
TakeProfitPips = 60
BreakEvenPips = 15
RiskPercentPerTrade = 1.0
MaxDailyLossPercent = 5.0
```

## 🔧 Hoe het Werkt

### Multi-EA Coördinatie
```
EA 1 (EURUSD) opent trade → SL niet op BE → Andere EA's wachten
EA 1 bereikt +20 pips    → SL naar BE     → Andere EA's mogen traden
EA 2 (XAUUSD) opent trade → SL niet op BE → Andere EA's wachten
```

### Dagelijkse Verlies Bescherming
```
Start Balance: €10,000
Huidige Equity: €9,400 (-€600 = -6%)
→ Alle trades worden gesloten
→ Trading geblokkeerd voor vandaag
→ Reset automatisch morgen
```

## 📊 Trading Strategie

De EA gebruikt standaard een Moving Average crossover strategie:
- Fast MA: 20 periode SMA
- Slow MA: 50 periode SMA

**U kunt dit aanpassen** in de `GenerateSignal()` functie voor:
- RSI/Stochastic
- Bollinger Bands
- Support/Resistance
- Candlestick patterns
- Uw eigen custom strategie

## ⚠️ Belangrijke Regels

1. **Uniek Magic Number** per symbool/EA
2. **Alleen één EA** zonder break-even tegelijk
3. **Dagelijkse limiet** geldt voor ALLE EA's samen
4. **Test eerst** op demo account
5. **Monitor** regelmatig de performance

## 🛠️ Aanpassen voor Uw Strategie

De EA is een framework. Belangrijkste aanpassing punten:

1. **Signal Generation** (`GenerateSignal()`)
   - Implementeer uw trading logica
   - Voeg indicatoren toe
   - Creëer entry filters

2. **Risk Management** (Parameters)
   - Pas SL/TP aan per symbool
   - Tune break-even levels
   - Optimaliseer risk per trade

3. **Entry/Exit Filters**
   - Tijd filters (sessies)
   - Volatility filters
   - News filters

## 📈 Verwachte Resultaten

De EA is ontworpen om:
- **Minimaal 10% profit** per maand te halen
- **Maximum 5% daily drawdown** te respecteren
- **Consistent** te traden met goede risk/reward

**Let op**: Resultaten hangen af van:
- Uw trading strategie implementatie
- Marktcondities
- Parameter optimalisatie
- Symbol selectie

## 🐛 Troubleshooting

**EA opent geen trades?**
- Check AutoTrading is aan
- Verifieer dat dagelijkse limiet niet bereikt is
- Controleer of andere EA niet al actief is

**Break-even werkt niet?**
- Controleer BreakEvenPips setting
- Kijk naar spread (kan BE blokkeren)
- Check logs voor errors

Zie [GEBRUIKSAANWIJZING.md](GEBRUIKSAANWIJZING.md) voor meer troubleshooting.

## 📝 Licentie

Open Source - Vrij te gebruiken en aan te passen

## ⚠️ Disclaimer

Trading heeft risico's. Deze EA is een tool, geen garantie voor winst.
- Test altijd eerst op demo
- Begrijp de code voordat u live gaat
- Monitor uw trades regelmatig
- Gebruik goede risk management

**Geen garanties voor winstgevendheid**

## 🤝 Bijdragen

Suggesties en verbeteringen zijn welkom!

## 📧 Support

Voor vragen of problemen:
1. Lees eerst de documentatie
2. Test op demo account
3. Check de logs
4. Open een issue op GitHub

---

**Versie**: 1.0  
**Platform**: MetaTrader 4  
**Type**: Expert Advisor  
**Doel**: FTMO Challenge
