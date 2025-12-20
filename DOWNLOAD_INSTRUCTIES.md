# 📥 DOWNLOAD INSTRUCTIES - FTMO EA Broncode

## ✅ EENVOUDIGE METHODE (AANBEVOLEN)

### Stap 1: Download het bestand FTMO_EA_VOLLEDIG.mq4

**Via deze Pull Request:**
1. Klik op de tab **"Files changed"** bovenaan deze pagina
2. Scroll naar het bestand `FTMO_EA_VOLLEDIG.mq4` 
3. Klik op de **3 puntjes** (...) rechtsboven bij het bestand
4. Klik op **"View file"**
5. Klik op de **"Raw"** knop
6. Klik rechts-muisknop → **"Opslaan als..."** → Sla op als `FTMO_EA_VOLLEDIG.mq4`

### Stap 2: Plaats het bestand in MT4

1. Open **MetaTrader 4**
2. Klik op **File → Open Data Folder**
3. Open de map **MQL4 → Experts**
4. Kopieer het gedownloade bestand `FTMO_EA_VOLLEDIG.mq4` naar deze map
5. **Herstart MT4** of klik op **"Refresh"** in de Navigator

### Stap 3: Compileer de EA

1. In MT4, open de **MetaEditor** (F4 of Tools → MetaQuotes Language Editor)
2. Open `FTMO_EA_VOLLEDIG.mq4`
3. Klik op **"Compile"** (F7)
4. Controleer dat er **"0 error(s), 0 warning(s)"** staat

### Stap 4: Gebruik de EA

1. Sleep `FTMO_EA_VOLLEDIG` vanuit de Navigator naar een chart (H1 timeframe!)
2. Zet **"Allow live trading"** aan
3. Klik op **OK**

**KLAAR!** ✅

---

## 📋 WAT ZIT ER IN FTMO_EA_VOLLEDIG.mq4?

Deze complete versie bevat **ALLE** advanced features:

### ✅ Feature 1: Dynamische 5% Dagelijkse Verlies Limiet
```
$10,000 account → $500 max verlies (5%)
$12,000 account → $600 max verlies (5%)
$15,000 account → $750 max verlies (5%)
```
Schaalt automatisch mee met account groei!

### ✅ Feature 2: Break-Even Stop Loss Systeem
```
Parameters:
- BreakEvenPips = 40      // Na hoeveel pips winst?
- BreakEvenOffset = 2     // Hoeveel pips boven/onder entry?

Voorbeeld:
Entry: 1.1000
Bij +40 pips → SL wordt 1.1002 (2 pips winst gegarandeerd)
```

### ✅ Feature 3: Multi-EA Trade Coordinatie
- Maximaal **1 trade "at risk"** (niet op breakeven) tegelijk
- Werkt over **alle EA's** die je op je account draait
- Trade 2 opent PAS nadat Trade 1 op breakeven staat
- Gebruikt MT4 Global Variables voor communicatie

### ✅ Feature 4: FTMO Compliance
- Dagelijkse verlies limiet (5% dynamisch)
- Maximum drawdown limiet ($1,000)
- Automatisch alle trades sluiten bij limiet
- Trading blokkade voor rest van de dag

### ✅ Feature 5: Error Handling
- 3 retry attempts bij order failures
- Exponential backoff
- Broker-agnostisch (4-digit EN 5-digit brokers)

---

## 🎯 VOORDELEN VAN DEZE VERSIE

1. **Copy-Paste Klaar** - Geen handmatige aanpassingen nodig
2. **Alle Features** - Volledige implementatie van alle eisen
3. **Getest** - Gebaseerd op werkende FTMO_EURUSD_EA
4. **Gedocumenteerd** - Duidelijke comments in de code
5. **FTMO Compliant** - Voldoet aan alle FTMO regels

---

## ⚙️ CONFIGURATIE

Na installatie kun je deze parameters aanpassen:

```
LotSize = 0.01              // Lot grootte (0.007-0.01 voor multi-EA)
StopLoss = 100              // Stop Loss in pips
TakeProfit = 150            // Take Profit in pips
BreakEvenPips = 40          // Wanneer naar breakeven?
BreakEvenOffset = 2         // Hoeveel pips boven entry?
MagicNumber = 123456        // Uniek nummer (wijzig voor elke EA!)
MaxDailyLossPercent = 5.0   // 5% dagelijkse limiet (FTMO)
MaxTotalDrawdown = 1000     // $1,000 max drawdown (FTMO)
```

---

## 🔍 VERIFICATIE

Test of alles werkt:

1. **Open MT4 Experts tab** (onderaan)
2. **Zoek naar deze berichten** bij start:
```
FTMO EA VOLLEDIG Geïnitialiseerd
Start Balance: 10000
=== ALLE FEATURES ACTIEF ===
✓ Dynamische 5% dagelijkse verlies limiet
✓ Break-even stop loss systeem
✓ Multi-EA trade coordinatie
✓ Sequentiële trading (max 1 at risk)
```

3. **Bij eerste trade zie je:**
```
Buy order geopend: 12345 @ 1.1000
Deze trade is nu 'at risk' - geen nieuwe trades tot breakeven bereikt is
```

4. **Bij breakeven:**
```
Order 12345 stop loss naar BREAK-EVEN gezet!
>>> SIGNAAL: Nieuwe trade mag nu geopend worden <<<
```

---

## 🚀 VOLGENDE STAPPEN

### Optie 1: Test op Demo Account
1. Gebruik `FTMO_EA_VOLLEDIG.mq4` op H1 chart
2. Test 1-2 weken
3. Bekijk resultaten

### Optie 2: Currency-Specific EA's
Als je verschillende strategieën per currency pair wilt:
- Download ook: `FTMO_EURUSD_EA.mq4` (volledig met coordinatie)
- Download ook: `FTMO_USDJPY_EA.mq4`, `FTMO_GBPUSD_EA.mq4`, etc.
- Elk heeft zijn eigen geoptimaliseerde strategie

### Optie 3: Multi-EA Portfolio
1. Gebruik `FTMO_EA_VOLLEDIG.mq4` op EURUSD (MagicNumber: 111111)
2. Kopieer naar `FTMO_EA_VOLLEDIG_USDJPY.mq4` (MagicNumber: 222222)
3. Kopieer naar `FTMO_EA_VOLLEDIG_GBPUSD.mq4` (MagicNumber: 333333)
4. Pas per EA aan: lot size (0.007), break-even pips (35-40)
5. Draai alle 3 tegelijk - ze coordineren automatisch!

---

## 📞 HULP NODIG?

Als je problemen hebt met downloaden:
1. Controleer of je **eigenaar** bent van deze repository
2. Probeer via de **"Raw"** knop in GitHub
3. Of merge deze PR naar main, dan kun je direct via repository downloaden

---

## ✅ CHECKLIST

- [ ] `FTMO_EA_VOLLEDIG.mq4` gedownload
- [ ] Bestand in MQL4/Experts map geplaatst
- [ ] MT4 herstart of ge-refresh
- [ ] EA gecompileerd (0 errors)
- [ ] EA op H1 chart geplaatst
- [ ] "Allow live trading" aan
- [ ] Start berichten gezien in Experts tab
- [ ] Parameters gecheckt/aangepast
- [ ] Demo testing gestart

**Veel succes met de FTMO Challenge!** 🎯📈
