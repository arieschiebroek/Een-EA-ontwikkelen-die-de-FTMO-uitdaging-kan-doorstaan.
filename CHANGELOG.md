# Changelog - FTMO Challenge EA

Alle belangrijke wijzigingen aan dit project worden gedocumenteerd in dit bestand.

## [1.0.0] - 2025-12-12

### ✨ Toegevoegd
- Initiële release van FTMO Challenge Expert Advisor
- Trend-following strategie met EMA crossovers
- RSI filter voor overbought/oversold condities
- Support en Resistance analyse
- ATR-gebaseerde stop loss en take profit
- Dynamische position sizing op basis van risico percentage
- Trailing stop functionaliteit
- Dagelijkse loss limiet bescherming (max 4%)
- Totale loss limiet bescherming (max 8%)
- Spread filter voor optimale entry conditions
- Trading tijd filters (configureerbaar)
- Maximum open posities limiet
- Risk/Reward ratio filter (min 1.5:1)
- Comprehensive logging en monitoring
- Magic number voor multi-EA support

### 📚 Documentatie
- README.md met volledige gebruikshandleiding
- INSTALLATIE_GIDS.md met stap-voor-stap installatie
- CONFIGURATIE_GIDS.md met geavanceerde settings
- QUICK_START.md voor snelle setup
- CHANGELOG.md voor versie tracking

### ⚙️ Preset Bestanden
- FTMO_Challenge_EA_Balanced.set (standaard, 1% risk)
- FTMO_Challenge_EA_Conservative.set (veilig, 0.5% risk)

### 🎯 Features voor FTMO Compliance
- Automatische dagelijkse loss limiet (configureerbaar op 4%)
- Automatische totale loss limiet (configureerbaar op 8%)
- Minimum trading dagen support (door consistente strategie)
- Risk management op 1% per trade (configureerbaar)
- Position sizing op basis van account balance

### 🛡️ Safety Features
- Spread controle voor optimale executie
- Time-based trading filters
- Maximum aantal gelijktijdige posities
- Automatische stop bij loss limieten
- Day-of-week filters (maandag/vrijdag configureerbaar)

### 📊 Trading Strategie
- Fast EMA (20) vs Slow EMA (50) crossover
- RSI filter (14 period, 30/70 levels)
- Support/Resistance confirmatie
- ATR voor volatiliteit aanpassing
- Dynamic stop loss (2.0 × ATR)
- Dynamic take profit (3.0 × ATR)
- Trailing stop (1.5 × ATR)

### 🔧 Technische Specificaties
- Platform: MetaTrader 4
- Timeframe: H1 (1 uur)
- Account type: €10,000 / $10,000
- Programmeer taal: MQL4
- Property: #strict mode enabled

---

## Toekomstige Versies (Planned)

### [1.1.0] - Planned
- [ ] Multi-timeframe confirmatie
- [ ] News filter integratie
- [ ] Email/push notificaties bij trades
- [ ] Performance dashboard overlay
- [ ] Break-even stop loss optie
- [ ] Partial profit taking optie

### [1.2.0] - Planned
- [ ] Machine learning signal filter
- [ ] Adaptive parameter optimalisatie
- [ ] Market regime detection
- [ ] Volume profile analyse
- [ ] Advanced money management

### [2.0.0] - Planned
- [ ] MT5 versie
- [ ] Multi-symbol support
- [ ] Portfolio management
- [ ] Risk correlation analysis
- [ ] Web dashboard voor monitoring

---

## Versie Nummering

Dit project gebruikt [Semantic Versioning](https://semver.org/):

- **MAJOR** versie: Incompatibele API wijzigingen
- **MINOR** versie: Nieuwe functionaliteit (backward compatible)
- **PATCH** versie: Bug fixes (backward compatible)

Formaat: `MAJOR.MINOR.PATCH` (bijvoorbeeld 1.0.0)

---

## Update Instructies

### Van 1.0.0 naar toekomstige versie:

1. Backup je huidige .mq4 bestand
2. Backup je custom .set preset bestanden
3. Download nieuwe versie
4. Kopieer naar MQL4/Experts map
5. Refresh MT4 Navigator
6. Test eerst op demo account
7. Migreer naar live na succesvolle test

---

## Bug Reports & Feature Requests

Voor bug reports of feature requests:
1. Check eerst de documentatie
2. Verifieer het probleem op demo account
3. Documenteer de stappen om te reproduceren
4. Include MT4 versie en broker informatie

---

## Credits

**Ontwikkeld voor**: FTMO Challenge traders
**Platform**: MetaTrader 4
**Versie**: 1.0.0
**Release Datum**: 12 December 2025

---

*Dit EA is ontwikkeld met focus op veiligheid, betrouwbaarheid en FTMO compliance.*
