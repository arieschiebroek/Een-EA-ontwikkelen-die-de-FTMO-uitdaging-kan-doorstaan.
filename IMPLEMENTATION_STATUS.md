# Implementation Status - Trade Coordination System

## ✅ Geïmplementeerd (Commit 80dace2)

### 1. FTMO_EURUSD_EA.mq4 - VOLLEDIG BIJGEWERKT
**Features:**
- ✅ `BreakEvenPips = 30` parameter toegevoegd
- ✅ Global Variables voor cross-EA communicatie
- ✅ `UpdateGlobalTradeStatus()` functie
- ✅ `IsOrderAtBreakEven()` functie
- ✅ Automatische break-even stop loss bij 30 pips winst
- ✅ Check voor `TradesAtRisk < 1` voordat nieuwe trade
- ✅ Dagelijkse verlies limiet met `DailyAllowed` flag
- ✅ Trailing stop na breakeven (50 pips → 30 pips trailing)

**Totaal:** 433 regels, volledig functioneel

### 2. TRADE_COORDINATION.md - COMPLETE DOCUMENTATIE
**Inhoud:**
- ✅ Uitleg van het coordinatie systeem
- ✅ Global Variables uitleg
- ✅ Workflow diagrammen
- ✅ Gebruiksvoorbeelden (scenario's)
- ✅ Parameter aanbevelingen per currency pair
- ✅ Troubleshooting gids
- ✅ FAQs

## ⏳ Te Implementeren

### Resterende EA's die bijgewerkt moeten worden:

1. **FTMO_EA.mq4** (Basis EA)
   - Break-Even: 30 pips
   - Strategie: EMA 12/26 + RSI

2. **FTMO_USDJPY_EA.mq4**
   - Break-Even: 35 pips
   - Strategie: EMA 8/18 + Bollinger Bands

3. **FTMO_GBPUSD_EA.mq4**
   - Break-Even: 40 pips  
   - Strategie: EMA 10/20 + MACD

4. **FTMO_AUDUSD_EA.mq4**
   - Break-Even: 35 pips
   - Strategie: EMA 11/22 + Stochastic + ADX

5. **FTMO_XAUUSD_EA.mq4** (Gold)
   - Break-Even: 80 pips
   - Strategie: EMA 15/30 + S/R + ATR

## Vereiste Wijzigingen per EA

### A. Input Parameters
Toevoegen na `TakeProfit`:
```mql4
input int BreakEvenPips = XX;              // Pips winst voordat SL naar breakeven gaat
```
- FTMO_EA: 30
- USDJPY: 35
- GBPUSD: 40
- AUDUSD: 35
- XAUUSD: 80

### B. Global Variables
Toevoegen na `double PipValue;`:
```mql4
//--- Globale variabelen voor multi-EA coordinatie
string GV_ActiveTrades = "FTMO_ActiveTrades";
string GV_TradesAtRisk = "FTMO_TradesAtRisk";
string GV_DailyTradingAllowed = "FTMO_DailyAllowed";
```

### C. OnInit() Functie
Toevoegen voor `return(INIT_SUCCEEDED);`:
```mql4
// Initialiseer globale variabelen indien nodig
if(!GlobalVariableCheck(GV_ActiveTrades))
   GlobalVariableSet(GV_ActiveTrades, 0);
if(!GlobalVariableCheck(GV_TradesAtRisk))
   GlobalVariableSet(GV_TradesAtRisk, 0);
if(!GlobalVariableCheck(GV_DailyTradingAllowed))
   GlobalVariableSet(GV_DailyTradingAllowed, 1);

Print("Break-Even Pips: ", BreakEvenPips);
```

### D. OnTick() Functie
**Toevoegen** na dagelijkse reset check:
```mql4
// Check of trading vandaag nog toegestaan is
if(GlobalVariableGet(GV_DailyTradingAllowed) == 0)
{
   return; // Trading geblokkeerd voor vandaag
}
```

**Wijzigen** bij dagelijks verlies check:
```mql4
if(DailyPnL <= -MaxDailyLoss)
{
   Print("WAARSCHUWING: Dagelijkse verlies limiet bereikt! Alle trades sluiten.");
   GlobalVariableSet(GV_DailyTradingAllowed, 0); // Blokkeer alle EA's
   CloseAllOrders();
   return;
}
```

**Toevoegen** na drawdown check:
```mql4
// Update globale trade status
UpdateGlobalTradeStatus();
```

**Toevoegen** voor position management check:
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

### E. ManageOpenPositions() Functie
**Toevoegen** aan het begin van de position loop:
```mql4
// Check of we break-even moeten instellen
if(profit >= BreakEvenPips)
{
   bool isAtBreakEven = IsOrderAtBreakEven(OrderTicket());
   
   if(!isAtBreakEven)
   {
      // Zet stop loss op breakeven (+ 2 pips voor spread)
      double newSL = (OrderType() == OP_BUY) ?
                    OrderOpenPrice() + 2 * PipValue :
                    OrderOpenPrice() - 2 * PipValue;
      
      if(OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue))
      {
         Print("[PAIR] Order ", OrderTicket(), " stop loss naar BREAK-EVEN gezet!");
         Print(">>> SIGNAAL: Nieuwe trade mag nu geopend worden <<<");
      }
   }
}
```

### F. Open Order Functions
**Toevoegen** na successful order open:
```mql4
Print("Deze trade is nu 'at risk' - geen nieuwe trades tot breakeven");
UpdateGlobalTradeStatus();
```

### G. Helper Functions
**Toevoegen** aan einde van bestand:
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
   
   if(distance <= 5)
   {
      return true;
   }
   
   return false;
}
```

## Testing Plan

### 1. Demo Account Test (2 weken)
- ✅ Week 1: Test EURUSD EA apart
- ⏳ Week 2: Test alle 6 EA's samen
- Check: Break-even werking
- Check: Cross-EA coordinatie
- Check: Daily loss limiet

### 2. Multi-EA Scenario Test
- Start 3 EA's (EURUSD, USDJPY, GBPUSD)
- Verifieer dat slechts 1 trade at risk is
- Check dat tweede trade pas opent na breakeven
- Monitor Global Variables

### 3. Daily Loss Test
- Simuleer -$500 verlies
- Verifieer dat alle EA's stoppen
- Check dat nieuwe dag reset werkt

## Gebruikersinstructies

### Na volledige implementatie:

1. **Installeer alle EA's** in MT4/MQL4/Experts/
2. **Open charts**: H1 voor EURUSD, USDJPY, GBPUSD, AUDUSD, XAUUSD
3. **Attach EA's** aan juiste charts
4. **Verifieer settings**:
   - `BreakEvenPips` correct per pair
   - `MaxDailyLoss = 500`
   - `LotSize = 0.007-0.008` (voor multi-EA)
5. **Monitor Global Variables**:
   - Tools → Global Variables in MT4
   - Kijk naar FTMO_TradesAtRisk (moet 0 of 1 zijn)

## Volgende Commit

Zal de overige 5 EA's updaten met identieke coordinatie logica.
Geschatte toevoeging: ~350 regels per EA.

---

**Status:** 1 van 6 EA's volledig bijgewerkt + complete documentatie
**Volgende:** Update overige 5 EA's met coordinatie systeem
