//+------------------------------------------------------------------+
//|                                        FTMO_EURUSD_EA_SIMPLE.mq4 |
//|                        Expert Advisor voor FTMO Challenge        |
//|            VEREENVOUDIGDE VERSIE - Zonder volatiliteit filter    |
//+------------------------------------------------------------------+
#property copyright "FTMO Challenge EA - EURUSD SIMPLE"
#property link      ""
#property version   "1.10"
#property strict

//--- Input parameters
input double LotSize = 0.01;              // Lot grootte
input int StopLoss = 80;                   // Stop Loss in pips (EURUSD optimaal)
input int TakeProfit = 120;                // Take Profit in pips (1.5:1 R/R)
input int BreakEvenPips = 30;              // Pips winst voordat SL naar breakeven gaat
input int BreakEvenOffset = 2;             // Extra pips boven breakeven (voor spread/veiligheid)
input int MagicNumber = 111111;            // Magic Number voor EURUSD
input double MaxDailyLossPercent = 5.0;    // Maximaal dagelijks verlies in % (FTMO: 5%)
input double MaxTotalDrawdown = 1000;      // Maximale totale drawdown in USD
input int RSI_Period = 14;                 // RSI periode
input int EMA_Fast = 9;                    // Snelle EMA (aangepast voor EURUSD)
input int EMA_Slow = 21;                   // Langzame EMA (aangepast voor EURUSD)
input int TrailingStop = 50;               // Trailing stop in pips
input int TrailingStep = 5;                // Trailing step in pips

//--- Global variables
double InitialBalance;
double DailyStartBalance;
datetime LastDayChecked;
double MaxDrawdownReached = 0;
double PipValue;
int TickCounter = 0;
datetime LastBarTime = 0;

//--- Globale variabelen voor multi-EA coordinatie
string GV_ActiveTrades = "FTMO_ActiveTrades";
string GV_TradesAtRisk = "FTMO_TradesAtRisk";
string GV_DailyTradingAllowed = "FTMO_DailyAllowed";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   InitialBalance = AccountBalance();
   DailyStartBalance = AccountBalance();
   LastDayChecked = TimeCurrent();
   
   // Calculate pip value based on broker digits
   if(Digits == 5 || Digits == 3)
      PipValue = Point * 10;
   else
      PipValue = Point;
   
   // Initialiseer globale variabelen indien nodig
   if(!GlobalVariableCheck(GV_ActiveTrades))
      GlobalVariableSet(GV_ActiveTrades, 0);
   if(!GlobalVariableCheck(GV_TradesAtRisk))
      GlobalVariableSet(GV_TradesAtRisk, 0);
   if(!GlobalVariableCheck(GV_DailyTradingAllowed))
      GlobalVariableSet(GV_DailyTradingAllowed, 1);
   
   Print("========================================");
   Print("FTMO EURUSD EA SIMPLE Geïnitialiseerd");
   Print("========================================");
   Print("Start Balance: ", InitialBalance);
   Print("Symbool: ", Symbol());
   Print("EMA Fast/Slow: ", EMA_Fast, "/", EMA_Slow);
   Print("RSI Period: ", RSI_Period);
   Print("GEEN VOLATILITEIT FILTER - Meer signalen!");
   Print("========================================");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("========================================");
   Print("FTMO EURUSD EA SIMPLE Gestopt");
   Print("Eind Balance: ", AccountBalance());
   Print("Totaal P/L: ", AccountBalance() - InitialBalance);
   Print("========================================");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   TickCounter++;
   
   // Print status elke 100 ticks
   if(TickCounter % 100 == 0)
   {
      double tradesAtRisk = GlobalVariableGet(GV_TradesAtRisk);
      double dailyAllowed = GlobalVariableGet(GV_DailyTradingAllowed);
      Print("DEBUG [Tick ", TickCounter, "]: EA actief | Balance: ", AccountBalance(), 
            " | TradesAtRisk: ", tradesAtRisk, " | DailyAllowed: ", dailyAllowed);
   }
   
   // Check dagelijkse reset
   CheckDailyReset();
   
   // Check dagelijkse verlies limiet
   double dailyPL = AccountBalance() - DailyStartBalance;
   double maxDailyLoss = DailyStartBalance * MaxDailyLossPercent / 100.0;
   
   if(dailyPL < -maxDailyLoss)
   {
      Print("========================================");
      Print("WAARSCHUWING: Dagelijkse verlies limiet bereikt!");
      Print("Dagelijks verlies: $", -dailyPL, " (max: $", maxDailyLoss, ")");
      Print("Alle orders worden gesloten, trading geblokkeerd");
      Print("========================================");
      
      CloseAllOrders();
      GlobalVariableSet(GV_DailyTradingAllowed, 0);
      return;
   }
   
   // Manage open positions
   ManageOpenPositions();
   
   // Check nieuwe bar voor trading signaal
   datetime currentBarTime = iTime(Symbol(), PERIOD_H1, 0);
   if(currentBarTime != LastBarTime)
   {
      LastBarTime = currentBarTime;
      Print("DEBUG: ===== NIEUWE BAR GEDETECTEERD =====");
      
      // Check of we mogen traden
      double dailyAllowed = GlobalVariableGet(GV_DailyTradingAllowed);
      if(dailyAllowed == 0)
      {
         Print("DEBUG: Trading geblokkeerd voor vandaag (daily loss limiet)");
         return;
      }
      
      // Check of er al een trade at risk is
      double tradesAtRisk = GlobalVariableGet(GV_TradesAtRisk);
      if(tradesAtRisk >= 1)
      {
         Print("DEBUG: Wachten - er is al 1 trade at risk (", tradesAtRisk, ")");
         return;
      }
      
      // Check of we al een positie open hebben
      if(CountOrders() > 0)
      {
         Print("DEBUG: Er is al een open positie voor dit symbool");
         return;
      }
      
      // Get signal en open order indien nodig
      int signal = GetTradeSignal();
      
      if(signal == OP_BUY)
      {
         Print("DEBUG: BUY SIGNAAL - probeer order te openen");
         OpenBuyOrder();
      }
      else if(signal == OP_SELL)
      {
         Print("DEBUG: SELL SIGNAAL - probeer order te openen");
         OpenSellOrder();
      }
   }
}

//+------------------------------------------------------------------+
//| Get trade signal - VEREENVOUDIGD zonder ATR filter              |
//+------------------------------------------------------------------+
int GetTradeSignal()
{
   Print("DEBUG: --- SIGNAAL ANALYSE START ---");
   
   // RSI Indicator
   double rsi = iRSI(Symbol(), PERIOD_H1, RSI_Period, PRICE_CLOSE, 0);
   Print("DEBUG: RSI(", RSI_Period, ") = ", DoubleToStr(rsi, 2));
   
   // EMA Indicators
   double emaFast = iMA(Symbol(), PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaSlow = iMA(Symbol(), PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaFastPrev = iMA(Symbol(), PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE, 1);
   double emaSlowPrev = iMA(Symbol(), PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE, 1);
   
   Print("DEBUG: EMA Fast(", EMA_Fast, ") Current: ", DoubleToStr(emaFast, 5), " | Previous: ", DoubleToStr(emaFastPrev, 5));
   Print("DEBUG: EMA Slow(", EMA_Slow, ") Current: ", DoubleToStr(emaSlow, 5), " | Previous: ", DoubleToStr(emaSlowPrev, 5));
   
   // Buy Signal Checks (ALLEEN EMA crossover + RSI)
   bool emaCrossUpNow = (emaFast > emaSlow);
   bool emaCrossUpPrev = (emaFastPrev <= emaSlowPrev);
   bool emaBuyCross = (emaCrossUpPrev && emaCrossUpNow);
   bool rsiBuyZone = (rsi < 50);  // Versoepeld van 45 naar 50
   
   Print("DEBUG: --- BUY CONDITIE CHECK ---");
   Print("DEBUG: EMA Cross Up? ", (emaBuyCross ? "JA" : "NEE"));
   Print("DEBUG: RSI < 50? ", (rsiBuyZone ? "JA" : "NEE"), " (RSI=", DoubleToStr(rsi, 2), ")");
   
   // Buy Signal: ALLEEN EMA crossover + RSI (GEEN volatiliteit filter!)
   if(emaBuyCross && rsiBuyZone)
   {
      Print("DEBUG: *** BUY SIGNAAL ACTIEF ***");
      return OP_BUY;
   }
   
   // Sell Signal Checks
   bool emaCrossDownNow = (emaFast < emaSlow);
   bool emaCrossDownPrev = (emaFastPrev >= emaSlowPrev);
   bool emaSellCross = (emaCrossDownPrev && emaCrossDownNow);
   bool rsiSellZone = (rsi > 50);  // Versoepeld van 55 naar 50
   
   Print("DEBUG: --- SELL CONDITIE CHECK ---");
   Print("DEBUG: EMA Cross Down? ", (emaSellCross ? "JA" : "NEE"));
   Print("DEBUG: RSI > 50? ", (rsiSellZone ? "JA" : "NEE"), " (RSI=", DoubleToStr(rsi, 2), ")");
   
   // Sell Signal: ALLEEN EMA crossover + RSI (GEEN volatiliteit filter!)
   if(emaSellCross && rsiSellZone)
   {
      Print("DEBUG: *** SELL SIGNAAL ACTIEF ***");
      return OP_SELL;
   }
   
   Print("DEBUG: Geen signaal");
   Print("DEBUG: --- SIGNAAL ANALYSE EINDE ---");
   
   return -1;
}

//+------------------------------------------------------------------+
//| Open Buy Order                                                   |
//+------------------------------------------------------------------+
void OpenBuyOrder()
{
   double price = Ask;
   double sl = price - StopLoss * PipValue;
   double tp = price + TakeProfit * PipValue;
   
   Print("DEBUG: Probeer BUY order te openen...");
   Print("DEBUG: Price: ", price, " | SL: ", sl, " | TP: ", tp);
   
   int ticket = OrderSend(Symbol(), OP_BUY, LotSize, price, 3, sl, tp, 
                         "FTMO EURUSD Buy", MagicNumber, 0, clrGreen);
   
   if(ticket > 0)
   {
      Print("DEBUG: *** BUY ORDER SUCCESVOL GEOPEND *** Ticket: ", ticket);
      GlobalVariableSet(GV_ActiveTrades, GlobalVariableGet(GV_ActiveTrades) + 1);
      GlobalVariableSet(GV_TradesAtRisk, GlobalVariableGet(GV_TradesAtRisk) + 1);
   }
   else
   {
      int error = GetLastError();
      Print("DEBUG: FOUT bij openen BUY order. Error: ", error, " - ", ErrorDescription(error));
   }
}

//+------------------------------------------------------------------+
//| Open Sell Order                                                  |
//+------------------------------------------------------------------+
void OpenSellOrder()
{
   double price = Bid;
   double sl = price + StopLoss * PipValue;
   double tp = price - TakeProfit * PipValue;
   
   Print("DEBUG: Probeer SELL order te openen...");
   Print("DEBUG: Price: ", price, " | SL: ", sl, " | TP: ", tp);
   
   int ticket = OrderSend(Symbol(), OP_SELL, LotSize, price, 3, sl, tp, 
                         "FTMO EURUSD Sell", MagicNumber, 0, clrRed);
   
   if(ticket > 0)
   {
      Print("DEBUG: *** SELL ORDER SUCCESVOL GEOPEND *** Ticket: ", ticket);
      GlobalVariableSet(GV_ActiveTrades, GlobalVariableGet(GV_ActiveTrades) + 1);
      GlobalVariableSet(GV_TradesAtRisk, GlobalVariableGet(GV_TradesAtRisk) + 1);
   }
   else
   {
      int error = GetLastError();
      Print("DEBUG: FOUT bij openen SELL order. Error: ", error, " - ", ErrorDescription(error));
   }
}

//+------------------------------------------------------------------+
//| Manage open positions - Break-even & Trailing                   |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      
      double profit = 0;
      bool isAtBreakEven = IsOrderAtBreakEven();
      
      if(OrderType() == OP_BUY)
      {
         profit = (Bid - OrderOpenPrice()) / PipValue;
         
         // Break-even check
         if(!isAtBreakEven && profit >= BreakEvenPips)
         {
            double newSL = OrderOpenPrice() + BreakEvenOffset * PipValue;
            if(newSL > OrderStopLoss())
            {
               if(OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue))
               {
                  Print("DEBUG: *** BREAK-EVEN GEZET *** Ticket: ", OrderTicket(), " | SL: ", newSL);
                  UpdateGlobalTradeStatus();
               }
            }
         }
         
         // Trailing stop
         if(profit >= TrailingStop)
         {
            double newSL = Bid - TrailingStop * PipValue;
            if(newSL > OrderStopLoss() + TrailingStep * PipValue)
            {
               if(OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue))
               {
                  Print("DEBUG: Trailing stop aangepast naar: ", newSL);
               }
            }
         }
      }
      else if(OrderType() == OP_SELL)
      {
         profit = (OrderOpenPrice() - Ask) / PipValue;
         
         // Break-even check
         if(!isAtBreakEven && profit >= BreakEvenPips)
         {
            double newSL = OrderOpenPrice() - BreakEvenOffset * PipValue;
            if(newSL < OrderStopLoss() || OrderStopLoss() == 0)
            {
               if(OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue))
               {
                  Print("DEBUG: *** BREAK-EVEN GEZET *** Ticket: ", OrderTicket(), " | SL: ", newSL);
                  UpdateGlobalTradeStatus();
               }
            }
         }
         
         // Trailing stop
         if(profit >= TrailingStop)
         {
            double newSL = Ask + TrailingStop * PipValue;
            if(newSL < OrderStopLoss() - TrailingStep * PipValue || OrderStopLoss() == 0)
            {
               if(OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue))
               {
                  Print("DEBUG: Trailing stop aangepast naar: ", newSL);
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check if order is at break-even                                 |
//+------------------------------------------------------------------+
bool IsOrderAtBreakEven()
{
   if(OrderType() == OP_BUY)
   {
      double beLevel = OrderOpenPrice() + (BreakEvenOffset - 1) * PipValue;
      return (OrderStopLoss() >= beLevel);
   }
   else if(OrderType() == OP_SELL)
   {
      double beLevel = OrderOpenPrice() - (BreakEvenOffset - 1) * PipValue;
      return (OrderStopLoss() <= beLevel && OrderStopLoss() > 0);
   }
   return false;
}

//+------------------------------------------------------------------+
//| Update global trade status                                       |
//+------------------------------------------------------------------+
void UpdateGlobalTradeStatus()
{
   int totalOrders = 0;
   int ordersAtRisk = 0;
   
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderMagicNumber() != MagicNumber) continue;
      
      totalOrders++;
      if(!IsOrderAtBreakEven())
         ordersAtRisk++;
   }
   
   GlobalVariableSet(GV_ActiveTrades, totalOrders);
   GlobalVariableSet(GV_TradesAtRisk, ordersAtRisk);
   
   Print("DEBUG: Global status updated - Active: ", totalOrders, " | At Risk: ", ordersAtRisk);
}

//+------------------------------------------------------------------+
//| Count orders for this EA                                         |
//+------------------------------------------------------------------+
int CountOrders()
{
   int count = 0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         count++;
   }
   return count;
}

//+------------------------------------------------------------------+
//| Close all orders                                                 |
//+------------------------------------------------------------------+
void CloseAllOrders()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) continue;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != MagicNumber) continue;
      
      bool closed = false;
      if(OrderType() == OP_BUY)
         closed = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrRed);
      else if(OrderType() == OP_SELL)
         closed = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed);
      
      if(closed)
         Print("Order gesloten: ", OrderTicket());
   }
   
   UpdateGlobalTradeStatus();
}

//+------------------------------------------------------------------+
//| Check daily reset                                                |
//+------------------------------------------------------------------+
void CheckDailyReset()
{
   datetime currentTime = TimeCurrent();
   
   if(TimeDay(currentTime) != TimeDay(LastDayChecked))
   {
      Print("========================================");
      Print("NIEUWE DAG - Reset dagelijkse limiet");
      Print("Vorige dag start balance: ", DailyStartBalance);
      DailyStartBalance = AccountBalance();
      Print("Nieuwe dag start balance: ", DailyStartBalance);
      GlobalVariableSet(GV_DailyTradingAllowed, 1);
      Print("========================================");
      
      LastDayChecked = currentTime;
   }
}

//+------------------------------------------------------------------+
//| Error description                                                |
//+------------------------------------------------------------------+
string ErrorDescription(int errorCode)
{
   switch(errorCode)
   {
      case 0:   return "Geen error";
      case 1:   return "Geen error, maar resultaat is onbekend";
      case 2:   return "Algemene error";
      case 3:   return "Ongeldige parameters";
      case 4:   return "Trade server is bezet";
      case 5:   return "Oude versie van client terminal";
      case 6:   return "Geen verbinding met trade server";
      case 7:   return "Niet genoeg rechten";
      case 8:   return "Te frequente verzoeken";
      case 9:   return "Ongeldige operatie verstoort server";
      case 64:  return "Account geblokkeerd";
      case 65:  return "Ongeldig account nummer";
      case 128: return "Trade timeout";
      case 129: return "Ongeldige prijs";
      case 130: return "Ongeldige stops";
      case 131: return "Ongeldig trade volume";
      case 132: return "Markt is gesloten";
      case 133: return "Trading is uitgeschakeld";
      case 134: return "Niet genoeg geld";
      case 135: return "Prijs is veranderd";
      case 136: return "Geen prijzen";
      case 137: return "Broker is bezet";
      case 138: return "Nieuwe prijzen";
      case 139: return "Order is vergrendeld";
      case 140: return "Alleen long toegestaan";
      case 141: return "Te veel verzoeken";
      case 145: return "Wijziging niet toegestaan";
      case 146: return "Trade context is bezet";
      case 147: return "Expiratie werd gespecificeerd";
      case 148: return "Aantal open en pending orders heeft limiet bereikt";
      default:  return "Onbekende error: " + IntegerToString(errorCode);
   }
}
