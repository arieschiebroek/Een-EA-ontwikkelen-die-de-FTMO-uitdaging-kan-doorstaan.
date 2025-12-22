# Stapsgewijze Handleiding: FTMO_EA.mq4 Volledig Updaten

## Overzicht
Deze handleiding helpt u stap voor stap om uw FTMO_EA.mq4 bestand volledig bij te werken met alle nieuwe features:
- ✅ Trade coordinatie systeem (break-even + cross-EA communicatie)
- ✅ Dynamische 5% dagelijkse verlies limiet
- ✅ Variabele break-even configuratie

## Stap 1: Broncode Downloaden

### Optie A: Via GitHub Pull Request (Eenvoudigst)

1. **Open deze Pull Request in uw browser**
2. **Klik op de "Files changed" tab** bovenaan
3. **Zoek het bestand FTMO_EA.mq4**
4. **Klik op de drie puntjes (•••)** rechts van de bestandsnaam
5. **Selecteer "View file"**
6. **Klik op "Raw"** knop rechtsboven
7. **Rechtsklik → "Opslaan als..."** → Sla op als `FTMO_EA_UPDATED.mq4`

### Optie B: Kopieer de Complete Code Hieronder

Scroll naar beneden in dit document voor de volledige code van FTMO_EA.mq4 met alle updates.

## Stap 2: Backup Maken van Uw Huidige EA

**Belangrijk!** Maak eerst een backup:

1. Open uw MT4
2. Ga naar **File → Open Data Folder**
3. Navigeer naar **MQL4 → Experts**
4. Kopieer uw huidige `FTMO_EA.mq4`
5. Hernoem de kopie naar `FTMO_EA_BACKUP_[DATUM].mq4`

## Stap 3: Nieuwe Features Toevoegen

U heeft **2 opties**:

### Optie 1: Volledig Vervangen (AANBEVOLEN)

1. **Download de volledige updated FTMO_EA.mq4** (zie Stap 1)
2. **Vervang** uw oude FTMO_EA.mq4 in de **MQL4/Experts** folder
3. **Open MT4 MetaEditor**
4. **Compileer** het bestand (F7 of klik op "Compile")
5. **Klaar!** De EA heeft nu alle features

### Optie 2: Handmatig Updaten

Als u uw eigen aanpassingen wilt behouden, volg deze stappen:

#### 3.1 Update Input Parameters

Zoek in uw FTMO_EA.mq4:
```mql4
input double MaxDailyLoss = 500;
```

Vervang door:
```mql4
input double MaxDailyLossPercent = 5.0;    // Maximaal dagelijks verlies in % (FTMO: 5%)
input int BreakEvenPips = 30;              // Pips winst voordat SL naar breakeven gaat
input int BreakEvenOffset = 2;             // Extra pips boven breakeven (voor spread/veiligheid)
```

#### 3.2 Voeg Global Variables toe

Na de bestaande global variables (na `double PipValue;`):
```mql4
//--- Globale variabelen voor multi-EA coordinatie
string GV_ActiveTrades = "FTMO_ActiveTrades";
string GV_TradesAtRisk = "FTMO_TradesAtRisk";
string GV_DailyTradingAllowed = "FTMO_DailyAllowed";
```

#### 3.3 Update OnInit() Functie

Voeg toe voor `return(INIT_SUCCEEDED);`:
```mql4
   // Initialiseer globale variabelen indien nodig
   if(!GlobalVariableCheck(GV_ActiveTrades))
      GlobalVariableSet(GV_ActiveTrades, 0);
   if(!GlobalVariableCheck(GV_TradesAtRisk))
      GlobalVariableSet(GV_TradesAtRisk, 0);
   if(!GlobalVariableCheck(GV_DailyTradingAllowed))
      GlobalVariableSet(GV_DailyTradingAllowed, 1);
   
   Print("Break-Even Pips: ", BreakEvenPips);
   Print("Break-Even Offset: ", BreakEvenOffset);
```

#### 3.4 Update Dagelijkse Verlies Check in OnTick()

Zoek de dagelijkse verlies check:
```mql4
// FTMO Regel Check: Dagelijks Verlies Limiet
double DailyPnL = AccountBalance() - DailyStartBalance;
if(DailyPnL <= -MaxDailyLoss)
{
   Print("WAARSCHUWING: Dagelijkse verlies limiet bereikt! Geen nieuwe trades.");
   CloseAllOrders();
   return;
}
```

Vervang door:
```mql4
// Check of trading vandaag nog toegestaan is
if(GlobalVariableGet(GV_DailyTradingAllowed) == 0)
{
   return; // Trading geblokkeerd voor vandaag
}

// FTMO Regel Check: Dagelijks Verlies Limiet (5% van dagelijkse start balance)
double MaxDailyLoss = DailyStartBalance * (MaxDailyLossPercent / 100.0);
double DailyPnL = AccountBalance() - DailyStartBalance;
if(DailyPnL <= -MaxDailyLoss)
{
   Print("WAARSCHUWING: Dagelijkse verlies limiet bereikt!");
   Print("Start balance: ", DailyStartBalance, " | Max verlies: ", MaxDailyLoss, " (", MaxDailyLossPercent, "%)");
   Print("Huidig verlies: ", -DailyPnL, " | Alle trades sluiten.");
   GlobalVariableSet(GV_DailyTradingAllowed, 0); // Blokkeer alle EA's
   CloseAllOrders();
   return;
}

// Update globale trade status
UpdateGlobalTradeStatus();
```

#### 3.5 Voeg Trade Coordinatie Check toe

Voor de trade entry logic (voor `if(CheckBuySignal())`), voeg toe:
```mql4
// Manage bestaande posities
if(CountOrders() > 0)
{
   ManageOpenPositions();
   return;
}

// Check of nieuwe trade toegestaan is
double tradesAtRisk = GlobalVariableGet(GV_TradesAtRisk);
if(tradesAtRisk >= 1)
{
   // Er is al een trade actief die niet op breakeven staat
   return;
}
```

#### 3.6 Update ManageOpenPositions() Functie

Voeg break-even logic toe aan uw position management:
```mql4
// Check of we break-even moeten instellen
if(profit >= BreakEvenPips)
{
   bool isAtBreakEven = IsOrderAtBreakEven(OrderTicket());
   
   if(!isAtBreakEven)
   {
      // Zet stop loss op breakeven (+ offset pips voor spread)
      double newSL = (OrderType() == OP_BUY) ?
                    OrderOpenPrice() + BreakEvenOffset * PipValue :
                    OrderOpenPrice() - BreakEvenOffset * PipValue;
      
      if(OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue))
      {
         Print("Order ", OrderTicket(), " stop loss naar BREAK-EVEN gezet!");
         Print("Break-even niveau: ", OrderOpenPrice(), " + ", BreakEvenOffset, " pips = ", newSL);
         Print(">>> SIGNAAL: Nieuwe trade mag nu geopend worden <<<");
      }
   }
}
```

#### 3.7 Voeg Helper Functies toe

Voeg aan het einde van het bestand (voor de laatste `//+------------------------------------------------------------------+`):

```mql4
//+------------------------------------------------------------------+
//| Update Global Trade Status                                       |
//+------------------------------------------------------------------+
void UpdateGlobalTradeStatus()
{
   int totalTrades = 0;
   int tradesAtRisk = 0;
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
         {
            totalTrades++;
            if(!IsOrderAtBreakEven(OrderTicket()))
            {
               tradesAtRisk++;
            }
         }
      }
   }
   
   GlobalVariableSet(GV_ActiveTrades, totalTrades);
   GlobalVariableSet(GV_TradesAtRisk, tradesAtRisk);
}

//+------------------------------------------------------------------+
//| Check if order is at break-even                                 |
//+------------------------------------------------------------------+
bool IsOrderAtBreakEven(int ticket)
{
   if(!OrderSelect(ticket, SELECT_BY_TICKET))
      return false;
   
   double openPrice = OrderOpenPrice();
   double stopLoss = OrderStopLoss();
   
   if(stopLoss == 0)
      return false;
   
   double distance = MathAbs(stopLoss - openPrice) / PipValue;
   double breakEvenZone = BreakEvenOffset + 3;
   
   if(distance <= breakEvenZone)
   {
      return true;
   }
   
   return false;
}
```

#### 3.8 Update Order Opening Functions

Na elke succesvolle order (na `OrderSend()`):
```mql4
if(ticket > 0)
{
   Print("Order geopend: ", ticket);
   Print("Deze trade is nu 'at risk' - geen nieuwe trades tot breakeven");
   UpdateGlobalTradeStatus();
}
```

## Stap 4: Compileren en Testen

1. **Open MetaEditor** (in MT4: Tools → MetaEditor, of druk F4)
2. **Open uw FTMO_EA.mq4** bestand
3. **Druk F7** of klik op "Compile" knop
4. **Check voor errors** in het "Errors" tab onderaan
5. **Als succesvol:** "0 error(s), 0 warning(s)" verschijnt

### Veel voorkomende compile errors:

**Error: 'BreakEvenPips' - undeclared identifier**
→ Oplossing: Controleer of u de input parameters correct heeft toegevoegd

**Error: 'UpdateGlobalTradeStatus' - function not defined**
→ Oplossing: Controleer of u de helper functies aan het einde heeft toegevoegd

**Error: ')' - unexpected token**
→ Oplossing: Check of alle haakjes correct zijn gesloten

## Stap 5: EA Installeren in MT4

1. **Sluit MetaEditor**
2. **Open MT4**
3. **In Navigator panel** (linkerkant): Kijk onder **Expert Advisors**
4. **U zou "FTMO_EA" moeten zien**
5. **Sleep de EA** naar een H1 chart (bijv. EURUSD H1)

## Stap 6: EA Configureren

1. **Dubbelklik op de EA** in de chart of rechtsklik → "Expert Advisors" → "Properties"
2. **Inputs tab:** Configureer parameters:
   ```
   LotSize = 0.01
   StopLoss = 100
   TakeProfit = 150
   BreakEvenPips = 30
   BreakEvenOffset = 2
   MaxDailyLossPercent = 5.0
   MaxTotalDrawdown = 1000
   ```
3. **Common tab:** 
   - ✅ Allow live trading
   - ✅ Allow DLL imports (indien nodig)
4. **Klik OK**

## Stap 7: Verificatie

### Check 1: Expert Journal
Open **Terminal → Expert** tab, u zou moeten zien:
```
FTMO EA Geïnitialiseerd
Start Balance: [uw balance]
Account: [uw account nummer]
Break-Even Pips: 30
Break-Even Offset: 2
```

### Check 2: Global Variables
In MT4: **Tools → Global Variables**, u zou moeten zien:
```
FTMO_ActiveTrades = 0
FTMO_TradesAtRisk = 0
FTMO_DailyAllowed = 1
```

### Check 3: Test Trade
- Wacht op een trade signaal
- Als trade wordt geopend, check of `FTMO_TradesAtRisk = 1`
- Als trade 30 pips winst bereikt, check of SL naar breakeven gaat
- Check of `FTMO_TradesAtRisk` terug naar 0 gaat

## Stap 8: Multi-EA Setup (Optioneel)

Als u meerdere EA's wilt runnen:

1. **Open meerdere charts** (bijv. EURUSD H1, USDJPY H1, GBPUSD H1)
2. **Installeer verschillende EA's** op elke chart:
   - EURUSD: FTMO_EURUSD_EA (Magic: 111111)
   - USDJPY: FTMO_USDJPY_EA (Magic: 222222)
   - GBPUSD: FTMO_GBPUSD_EA (Magic: 333333)
3. **Pas LotSize aan:** Voor 3 EA's → gebruik 0.007-0.008 per EA
4. **Monitor Global Variables:** Alle EA's delen `FTMO_TradesAtRisk`

## Troubleshooting

### Probleem: EA opent geen trades
**Oplossing:**
- Check `FTMO_DailyAllowed` in Global Variables (moet 1 zijn)
- Check `FTMO_TradesAtRisk` (moet 0 zijn voor nieuwe trade)
- Check Expert Journal voor error messages

### Probleem: Break-even werkt niet
**Oplossing:**
- Check of trade minimaal `BreakEvenPips` (30) in winst is
- Check of `IsOrderAtBreakEven()` functie correct is geïmplementeerd
- Verifieer dat `ManageOpenPositions()` wordt aangeroepen

### Probleem: Dagelijkse verlies limiet triggert niet
**Oplossing:**
- Check of `MaxDailyLossPercent` correct is ingesteld (5.0)
- Verifieer berekening: `MaxDailyLoss = DailyStartBalance * 0.05`
- Check Expert Journal voor dagelijkse reset messages

### Probleem: Compile errors
**Oplossing:**
- Controleer alle haakjes: elke `{` moet een `}` hebben
- Controleer alle functies: `UpdateGlobalTradeStatus()` en `IsOrderAtBreakEven()`
- Check spelling van variabelen (hoofdlettergevoelig!)

## Volgende Stappen

1. ✅ **Backtest** de EA op historische data (1-3 maanden)
2. ✅ **Demo test** gedurende minimaal 2 weken
3. ✅ **Monitor** dagelijkse performance en drawdown
4. ✅ **Optimaliseer** parameters indien nodig
5. ✅ **Live trading** pas starten na succesvolle demo periode

## Belangrijke Notities

⚠️ **Risico Waarschuwing:**
- Start altijd met demo account
- Test alle features grondig
- Begrijp alle parameters voor live gebruik
- Monitor dagelijks uw trades

📚 **Extra Documentatie:**
- `TRADE_COORDINATION.md` - Uitgebreide uitleg coordinatie systeem
- `BREAKEVEN_CONFIG.md` - Break-even configuratie gids
- `CURRENCY_SPECIFIC_EAS.md` - Multi-EA portfolio setup

## Contact & Support

Bij problemen of vragen:
1. Check eerst de documentatie bestanden
2. Controleer Expert Journal in MT4
3. Verifieer Global Variables
4. Test op demo account eerst

---

**Succes met uw FTMO Challenge! 🎯📈**
