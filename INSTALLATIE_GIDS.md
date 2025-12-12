# 📦 Installatie Handleiding - FTMO Challenge EA

Deze gids leidt je stap-voor-stap door de installatie en setup van de FTMO Challenge Expert Advisor.

## ✅ Vereisten

Voordat je begint, zorg dat je het volgende hebt:

- [ ] MetaTrader 4 platform geïnstalleerd
- [ ] Een trading account (demo of live) met minimaal €10,000 / $10,000 balance
- [ ] Basis kennis van MT4
- [ ] (Optioneel) VPS voor 24/7 trading

## 📥 Stap 1: Download de Bestanden

Download de volgende bestanden van deze repository:

1. `FTMO_Challenge_EA.mq4` - Het hoofdbestand van de Expert Advisor
2. `FTMO_Challenge_EA_Balanced.set` - Preset met gebalanceerde instellingen
3. `FTMO_Challenge_EA_Conservative.set` - Preset met conservatieve instellingen
4. `README.md` - Volledige documentatie
5. `CONFIGURATIE_GIDS.md` - Geavanceerde configuratie gids

## 🔧 Stap 2: Installeer de Expert Advisor

### 2.1 Open de Data Folder

1. Open MetaTrader 4
2. Ga naar **File** → **Open Data Folder**
3. Een Windows Explorer venster opent

### 2.2 Kopieer het EA Bestand

1. Navigeer naar de map: `MQL4` → `Experts`
2. Kopieer `FTMO_Challenge_EA.mq4` naar deze map

### 2.3 Installeer Preset Bestanden (Optioneel maar Aanbevolen)

1. Navigeer vanuit de Data Folder naar: `MQL4` → `Presets`
2. Als de map `Presets` niet bestaat, maak deze aan
3. Kopieer de `.set` bestanden naar deze map:
   - `FTMO_Challenge_EA_Balanced.set`
   - `FTMO_Challenge_EA_Conservative.set`

### 2.4 Herstart of Refresh MT4

**Optie A: Refresh (sneller)**
1. In MT4, ga naar **Navigator** paneel (links)
2. Onder "Expert Advisors", klik rechts → **Refresh**

**Optie B: Herstart (als refresh niet werkt)**
1. Sluit MT4 volledig
2. Open MT4 opnieuw

### 2.5 Verifieer Installatie

1. In het **Navigator** paneel (Ctrl+N als het niet zichtbaar is)
2. Klik op het **+** bij "Expert Advisors"
3. Je zou nu `FTMO_Challenge_EA` moeten zien

✅ **Gelukt!** De EA is nu geïnstalleerd.

## ⚙️ Stap 3: Configureer de Expert Advisor

### 3.1 Open een Chart

1. In **Market Watch** (Ctrl+M), zoek je gewenste symbool (bijv. EURUSD)
2. Rechter-klik op het symbool → **Chart Window**
3. Stel de timeframe in op **H1** (1 uur)
   - Klik rechts op de chart → **Timeframe** → **H1**
   - Of gebruik sneltoets in de toolbar

### 3.2 Activeer de EA

1. In het **Navigator** paneel, vind `FTMO_Challenge_EA`
2. Sleep de EA naar de H1 chart
3. Het "EA Properties" venster opent automatisch

### 3.3 Configureer Common Tab

In het "Common" tabblad:

1. ✅ **Allow live trading** - Vink aan
2. ✅ **Allow DLL imports** - Vink aan (indien gevraagd door je broker)
3. ✅ **Confirm DLL function calls** - Optioneel (uit voor minder pop-ups)
4. ✅ **Allow imports of external experts** - Optioneel

### 3.4 Load een Preset (Aanbevolen)

In het "Inputs" tabblad:

1. Klik op de **Load** knop (onderaan)
2. Selecteer een preset:
   - `FTMO_Challenge_EA_Conservative.set` - Voor beginners
   - `FTMO_Challenge_EA_Balanced.set` - Standaard (aanbevolen)
3. Klik **Open**
4. Alle parameters worden nu automatisch ingesteld!

### 3.5 Of Handmatig Configureren

Als je geen preset gebruikt, stel dan minimaal deze parameters in:

```
=== Risk Management Settings ===
RiskPercentPerTrade: 1.0
MaxDailyLossPercent: 4.0
MaxTotalLossPercent: 8.0
MaxOpenPositions: 3

=== Trading Filters ===
StartHour: [Pas aan op basis van je broker tijd]
EndHour: [Pas aan op basis van je broker tijd]
MaxSpreadPips: 3.0

=== Expert Advisor Settings ===
MagicNumber: 123456 (verander als je meerdere EA's gebruikt)
```

### 3.6 Accepteer de Settings

1. Klik **OK**
2. De EA is nu actief!

## ✅ Stap 4: Verifieer dat de EA Draait

### 4.1 Check Visual Indicators

In de rechterbovenhoek van je chart zou je moeten zien:

- 😊 **Smiley icoon** - EA is actief en draait
- 😞 **Frowning icoon** - EA is actief maar AutoTrading is uit
- ❌ **Geen icoon** - EA is niet actief

De EA naam zou ook zichtbaar moeten zijn: `FTMO_Challenge_EA`

### 4.2 Enable AutoTrading

Als je een frowning icoon ziet:

1. Klik op de **AutoTrading** knop in de toolbar
   - Het ziet eruit als een verkeerslicht of play-knop
   - Het zou groen moeten worden
2. Het icoon op de chart verandert naar een smiley 😊

### 4.3 Check de Experts Log

1. Open het **Terminal** venster (Ctrl+T)
2. Ga naar het **Experts** tabblad
3. Je zou berichten moeten zien zoals:
   ```
   FTMO Challenge EA geïnitialiseerd
   Start Balance: 10000.00
   Account: [je account nummer]
   Symbol: EURUSD
   Timeframe: H1
   ```

✅ **Perfect!** De EA is nu actief en monitort de markt.

## 📊 Stap 5: Monitoring en Onderhoud

### 5.1 Daily Monitoring

Check dagelijks:

1. **Terminal → Trade** tab - Bekijk open posities
2. **Terminal → Account History** tab - Bekijk gesloten trades
3. **Terminal → Experts** tab - Lees log berichten
4. **Chart** - Visuele bevestiging van EA status

### 5.2 Belangrijk om te Weten

**De EA handelt NIET op elke bar:**
- ⏳ Het is normaal om uren/dagen zonder trades te hebben
- ✅ Dit is GOED - quality over quantity
- 📊 Verwacht 5-15 trades per week bij normale marktcondities

**Dagelijkse Checks:**
- Is AutoTrading nog aan? (Groen verkeerslicht)
- Zijn er errors in de Experts log?
- Is de spread normaal? (Check in Market Watch)
- Is de internet connectie stabiel?

### 5.3 Wekelijkse Review

Elke week:
1. Analyseer de trades in Account History
2. Bereken win rate: (Wins / Totaal trades) × 100%
3. Check of je op schema ligt voor de profit target
4. Overweeg parameters aan te passen als nodig (zie CONFIGURATIE_GIDS.md)

## 🔧 Stap 6: Optimalisatie (Optioneel)

### Voor Gevorderden

Als je de EA wil optimaliseren voor jouw specifieke broker/symbool:

1. Gebruik MT4's **Strategy Tester**:
   - View → Strategy Tester (Ctrl+R)
   - Selecteer FTMO_Challenge_EA
   - Stel periode in op minimaal 1 jaar
   - Gebruik "Every tick" model voor nauwkeurigheid

2. Analyseer backtest resultaten:
   - Kijk naar Total Net Profit
   - Check Maximum Drawdown (moet <10% zijn)
   - Verifieer Profit Factor (>1.5 is goed)

3. Pas parameters aan indien nodig
4. Test opnieuw

**Let op**: Over-optimalisatie kan leiden tot slechte forward performance!

## ❗ Troubleshooting

### Probleem: EA verschijnt niet in Navigator

**Oplossing:**
1. Controleer of het bestand in de juiste map staat: `MQL4/Experts/`
2. Controleer bestandsnaam: moet eindigen op `.mq4`
3. Probeer MT4 volledig te herstarten
4. Check of er een `.ex4` bestand is gecompileerd in dezelfde map

### Probleem: "Expert Advisor is not allowed to trade"

**Oplossing:**
1. Tools → Options → Expert Advisors
2. Vink aan: "Allow automated trading"
3. Vink aan: "Allow DLL imports"
4. Herstart EA door chart te sluiten en opnieuw te openen

### Probleem: EA handelt niet

**Checklist:**
1. ✅ Is AutoTrading enabled? (Groene knop in toolbar)
2. ✅ Is het binnen trading uren? (StartHour tot EndHour)
3. ✅ Is de spread laag genoeg? (Check in Market Watch)
4. ✅ Is de chart op H1 timeframe?
5. ✅ Is de dagelijkse loss limiet niet bereikt?
6. ✅ Zijn er valide trading signalen?

**Check Experts Log voor berichten:**
- "Spread te hoog" → Wacht op lagere spread
- "Dagelijks verlies limiet bereikt" → Normal, wacht tot volgende dag
- Geen berichten → Gewoon geen trading signaal, dit is normaal

### Probleem: Te veel verlies trades

**Oplossing:**
1. Switch naar Conservative preset
2. Verlaag RiskPercentPerTrade naar 0.5%
3. Verhoog MinRiskRewardRatio naar 2.0
4. Test eerst op demo account

### Probleem: EA stopt na MT4 herstart

**Oplossing:**
1. Dit is normaal MT4 gedrag
2. Optie A: Gebruik een VPS die altijd aan staat
3. Optie B: Heractiveer EA handmatig na elke MT4 herstart
4. Optie C: Gebruik preset bestanden om settings snel te herladen:
   - In EA settings, klik op "Load" en selecteer je .set bestand
   - Let op: EA moet opnieuw naar chart gesleept worden na herstart

## 📱 Extra: VPS Setup (Aanbevolen)

Voor 24/7 trading zonder onderbrekingen:

### Voordelen VPS:
- ✅ Altijd online, ook als je PC uit staat
- ✅ Stabiele internet verbinding
- ✅ Geen stroomonderbrekingen
- ✅ Lage latency naar broker servers

### VPS Providers:
- **Forex VPS**: Gespecialiseerd in MT4/MT5
- **Amazon AWS**: Flexibel maar technischer
- **Vultr**: Goede prijs/kwaliteit
- **Broker VPS**: Sommige brokers bieden gratis VPS bij hoog volume

### Setup op VPS:
1. Verbind via Remote Desktop
2. Installeer MT4 op de VPS
3. Login op je trading account
4. Volg bovenstaande installatie stappen
5. Laat de VPS 24/7 draaien

## 📚 Volgende Stappen

Na installatie:

1. ✅ **Test op Demo** (minimaal 2 weken)
   - Monitor dagelijks
   - Analyseer performance
   - Pas parameters aan indien nodig

2. ✅ **Lees de Documentatie**
   - `README.md` - Volledige gebruikshandleiding
   - `CONFIGURATIE_GIDS.md` - Geavanceerde settings

3. ✅ **Start Voorzichtig op Live**
   - Begin met Conservative preset
   - Monitor eerste week intensief
   - Verhoog risk alleen na consistente resultaten

4. ✅ **Join Community** (optioneel)
   - Deel je ervaringen
   - Leer van andere traders
   - Vraag hulp bij problemen

## 🎯 FTMO Challenge Checklist

Voor je start met de FTMO challenge:

- [ ] EA getest op demo account (minimaal 2 weken)
- [ ] Win rate >50% behaald op demo
- [ ] Maximum drawdown <5% gebleven op demo
- [ ] Trading plan gedocumenteerd
- [ ] Risico parameters ingesteld (1% of minder)
- [ ] VPS setup (aanbevolen)
- [ ] Backup plan voor technische problemen
- [ ] Emotionele voorbereiding (accepteer verliezen)

## ⚠️ Finale Waarschuwing

**LET OP:**
- Past performance is geen garantie voor toekomstige resultaten
- Test ALTIJD eerst op een demo account
- Gebruik NOOIT geld dat je niet kunt verliezen
- De EA is een hulpmiddel, geen geldmachine
- Discipline en geduld zijn essentieel voor succes

## 📞 Hulp Nodig?

Als je problemen hebt met de installatie:

1. Controleer deze guide opnieuw stap-voor-stap
2. Lees de Troubleshooting sectie
3. Check de Experts log voor foutmeldingen
4. Zoek in MT4 forums naar specifieke errors

---

**Succes met je FTMO Challenge!** 🚀

*Gemaakt met zorg voor succesvolle FTMO traders*
