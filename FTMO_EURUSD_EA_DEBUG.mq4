//+------------------------------------------------------------------+
//|                                        FTMO_EURUSD_EA_DEBUG.mq4 |
//|                        Expert Advisor voor FTMO Challenge        |
//|                        DEBUG VERSIE met uitgebreide logging      |
//+------------------------------------------------------------------+
#property copyright "FTMO Challenge EA - EURUSD DEBUG"
#property link      ""
#property version   "1.00"
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
input int ATR_Period = 14;                 // ATR periode voor volatiliteit filter
input double ATR_Multiplier = 1.5;         // ATR multiplier voor trend sterkte

//--- Global variables
double InitialBalance;
double DailyStartBalance;
datetime LastDayChecked;
double MaxDrawdownReached = 0;
double PipValue;
int TickCounter = 0; // Tel aantal ticks voor debug output

//--- Globale variabelen voor multi-EA coordinatie
string GV_ActiveTrades = "FTMO_ActiveTrades";           // Aantal actieve trades
string GV_TradesAtRisk = "FTMO_TradesAtRisk";           // Trades NIET op breakeven
string GV_DailyTradingAllowed = "FTMO_DailyAllowed";    // Trading toegestaan vandaag

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
   Print("DEBUG: FTMO EURUSD EA Geïnitialiseerd");
   Print("========================================");
   Print("DEBUG: Start Balance: ", InitialBalance);
   Print("DEBUG: Account: ", AccountNumber());
   Print("DEBUG: Symbool: ", Symbol());
   Print("DEBUG: Timeframe: H1");
   Print("DEBUG: Digits: ", Digits);
   Print("DEBUG: Point: ", Point);
   Print("DEBUG: Pip Value: ", PipValue);
   Print("DEBUG: Break-Even Pips: ", BreakEvenPips);
   Print("DEBUG: MagicNumber: ", MagicNumber);
   Print("DEBUG: EMA Fast/Slow: ", EMA_Fast, "/", EMA_Slow);
   Print("DEBUG: RSI Period: ", RSI_Period);
   Print("========================================");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("========================================");
   Print("DEBUG: FTMO EURUSD EA Gestopt");
   Print("DEBUG: Eind Balance: ", AccountBalance());
   Print("DEBUG: Totaal Winst/Verlies: ", AccountBalance() - InitialBalance);
   Print("========================================");
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   TickCounter++;
   
   // Print debug info elke 100 ticks
   if(TickCounter % 100 == 0)
   {
      Print("DEBUG [Tick ", TickCounter, "]: EA actief | Balance: ", AccountBalance(), 
            " | TradesAtRisk: ", GlobalVariableGet(GV_TradesAtRisk),
            " | DailyAllowed: ", GlobalVariableGet(GV_DailyTradingAllowed));
   }
   
   // Check of we in een nieuwe dag zijn voor dagelijkse reset
   if(TimeDay(TimeCurrent()) != TimeDay(LastDayChecked))
   {
      DailyStartBalance = AccountBalance();
      LastDayChecked = TimeCurrent();
      GlobalVariableSet(GV_DailyTradingAllowed, 1); // Reset trading permission
      Print("DEBUG: ===== NIEUWE HANDELSDAG =====");
      Print("DEBUG: Dagelijkse balans reset: ", DailyStartBalance);
   }
   
   // FTMO Regel Check: Dagelijks Verlies Limiet (5% van dagelijkse start balance)
   double MaxDailyLoss = DailyStartBalance * (MaxDailyLossPercent / 100.0);
   double DailyPnL = AccountBalance() - DailyStartBalance;
   
   if(DailyPnL <= -MaxDailyLoss)
   {
      Print("DEBUG: !!!!! DAGELIJKSE VERLIES LIMIET BEREIKT !!!!!");
      Print("DEBUG: Start balance: ", DailyStartBalance, " | Max verlies: ", MaxDailyLoss, " (", MaxDailyLossPercent, "%)");
      Print("DEBUG: Huidig verlies: ", -DailyPnL, " | Alle trades sluiten.");
      GlobalVariableSet(GV_DailyTradingAllowed, 0); // Blokkeer alle EA's
      CloseAllOrders();
      return;
   }
   
   // Check of trading vandaag nog toegestaan is
   double dailyAllowed = GlobalVariableGet(GV_DailyTradingAllowed);
   if(dailyAllowed == 0)
   {
      if(TickCounter % 500 == 0)
      {
         Print("DEBUG: Trading GEBLOKKEERD - DailyAllowed = 0");
      }
      return; // Trading geblokkeerd voor vandaag
   }
   
   // FTMO Regel Check: Maximale Drawdown Limiet
   double CurrentDrawdown = InitialBalance - AccountBalance();
   if(CurrentDrawdown > MaxDrawdownReached)
      MaxDrawdownReached = CurrentDrawdown;
      
   if(CurrentDrawdown >= MaxTotalDrawdown)
   {
      Print("DEBUG: !!!!! MAXIMALE DRAWDOWN BEREIKT !!!!!");
      Print("DEBUG: Drawdown: ", CurrentDrawdown, " >= ", MaxTotalDrawdown);
      CloseAllOrders();
      return;
   }
   
   // Update globale trade status
   UpdateGlobalTradeStatus();
   
   // Manage bestaande posities
   int orderCount = CountOrders();
   if(orderCount > 0)
   {
      if(TickCounter % 100 == 0)
      {
         Print("DEBUG: ", orderCount, " actieve order(s) - manage mode");
      }
      ManageOpenPositions();
      return;
   }
   
   // Check of nieuwe trade toegestaan is
   // Regel: Maximaal 1 trade "at risk" (niet op breakeven) tegelijk
   double tradesAtRisk = GlobalVariableGet(GV_TradesAtRisk);
   if(tradesAtRisk >= 1)
   {
      if(TickCounter % 500 == 0)
      {
         Print("DEBUG: Nieuwe trade GEBLOKKEERD - TradesAtRisk = ", tradesAtRisk, " (max 1)");
      }
      return;
   }
   
   // Alleen handelen op nieuwe bar (H1)
   static datetime lastBarTime = 0;
   if(Time[0] == lastBarTime)
      return;
   
   Print("DEBUG: ===== NIEUWE BAR GEDETECTEERD =====");
   Print("DEBUG: Tijd: ", TimeToStr(Time[0]));
   lastBarTime = Time[0];
   
   // Trading logica voor EURUSD
   int signal = GetTradeSignal();
   
   if(signal == OP_BUY)
   {
      Print("DEBUG: BUY SIGNAAL ONTVANGEN - probeer order te openen");
      OpenBuyOrder();
   }
   else if(signal == OP_SELL)
   {
      Print("DEBUG: SELL SIGNAAL ONTVANGEN - probeer order te openen");
      OpenSellOrder();
   }
   else
   {
      Print("DEBUG: Geen trade signaal - wachten op volgende bar");
   }
}

//+------------------------------------------------------------------+
//| Get trade signal - EURUSD Specifieke Strategie MET DEBUG        |
//+------------------------------------------------------------------+
int GetTradeSignal()
{
   Print("DEBUG: --- SIGNAAL ANALYSE START ---");
   
   // RSI Indicator
   double rsi = iRSI(Symbol(), PERIOD_H1, RSI_Period, PRICE_CLOSE, 0);
   Print("DEBUG: RSI(", RSI_Period, ") = ", DoubleToStr(rsi, 2));
   
   // EMA Indicators (9/21 voor EURUSD)
   double emaFast = iMA(Symbol(), PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaSlow = iMA(Symbol(), PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaFastPrev = iMA(Symbol(), PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE, 1);
   double emaSlowPrev = iMA(Symbol(), PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE, 1);
   
   Print("DEBUG: EMA Fast(", EMA_Fast, ") Current: ", DoubleToStr(emaFast, 5), " | Previous: ", DoubleToStr(emaFastPrev, 5));
   Print("DEBUG: EMA Slow(", EMA_Slow, ") Current: ", DoubleToStr(emaSlow, 5), " | Previous: ", DoubleToStr(emaSlowPrev, 5));
   
   // ATR voor volatiliteit filter
   double atr = iATR(Symbol(), PERIOD_H1, ATR_Period, 0);
   double atrSlow = iATR(Symbol(), PERIOD_H1, ATR_Period, 10);
   
   Print("DEBUG: ATR Current: ", DoubleToStr(atr, 5), " | ATR Slow: ", DoubleToStr(atrSlow, 5));
   
   bool volatilityOK = (atr > atrSlow * 1.1); // Volatiliteit moet toenemen
   Print("DEBUG: Volatiliteit OK? ", (volatilityOK ? "JA" : "NEE"), " (ATR > ATR_Slow * 1.1)");
   
   // Buy Signal Checks
   bool emaCrossUpNow = (emaFast > emaSlow);
   bool emaCrossUpPrev = (emaFastPrev <= emaSlowPrev);
   bool emaBuyCross = (emaCrossUpPrev && emaCrossUpNow);
   bool rsiBuyZone = (rsi < 45);
   
   Print("DEBUG: --- BUY CONDITIE CHECK ---");
   Print("DEBUG: EMA Cross Up (Prev <= & Now >)? ", (emaBuyCross ? "JA" : "NEE"));
   Print("DEBUG: RSI < 45? ", (rsiBuyZone ? "JA" : "NEE"), " (RSI=", DoubleToStr(rsi, 2), ")");
   Print("DEBUG: Volatility OK? ", (volatilityOK ? "JA" : "NEE"));
   
   // Buy Signal: EMA crossover + RSI oversold zone + volatiliteit
   if(emaBuyCross && rsiBuyZone && volatilityOK)
   {
      Print("DEBUG: *** BUY SIGNAAL ACTIEF *** Alle conditie voldaan!");
      return OP_BUY;
   }
   
   // Sell Signal Checks
   bool emaCrossDownNow = (emaFast < emaSlow);
   bool emaCrossDownPrev = (emaFastPrev >= emaSlowPrev);
   bool emaSellCross = (emaCrossDownPrev && emaCrossDownNow);
   bool rsiSellZone = (rsi > 55);
   
   Print("DEBUG: --- SELL CONDITIE CHECK ---");
   Print("DEBUG: EMA Cross Down (Prev >= & Now <)? ", (emaSellCross ? "JA" : "NEE"));
   Print("DEBUG: RSI > 55? ", (rsiSellZone ? "JA" : "NEE"), " (RSI=", DoubleToStr(rsi, 2), ")");
   Print("DEBUG: Volatility OK? ", (volatilityOK ? "JA" : "NEE"));
   
   // Sell Signal: EMA crossover + RSI overbought zone + volatiliteit
   if(emaSellCross && rsiSellZone && volatilityOK)
   {
      Print("DEBUG: *** SELL SIGNAAL ACTIEF *** Alle conditie voldaan!");
      return OP_SELL;
   }
   
   Print("DEBUG: Geen signaal - niet alle condities voldaan");
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
   Print("DEBUG: Lot Size: ", LotSize, " | Magic: ", MagicNumber);
   
   int ticket = OrderSend(Symbol(), OP_BUY, LotSize, price, 3, sl, tp, 
                         "FTMO EURUSD Buy", MagicNumber, 0, clrGreen);
   
   if(ticket > 0)
   {
      Print("DEBUG: *** BUY ORDER SUCCESVOL GEOPEND ***");
      Print("DEBUG: Ticket: ", ticket, " @ ", price);
      Print("DEBUG: Deze trade is nu 'at risk' - geen nieuwe trades tot breakeven bereikt is");
      // Update global status
      UpdateGlobalTradeStatus();
   }
   else
   {
      int error = GetLastError();
      Print("DEBUG: !!! FOUT bij openen BUY order !!!");
      Print("DEBUG: Error Code: ", error);
      Print("DEBUG: Error Description: ", ErrorDescription(error));
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
   Print("DEBUG: Lot Size: ", LotSize, " | Magic: ", MagicNumber);
   
   int ticket = OrderSend(Symbol(), OP_SELL, LotSize, price, 3, sl, tp, 
                         "FTMO EURUSD Sell", MagicNumber, 0, clrRed);
   
   if(ticket > 0)
   {
      Print("DEBUG: *** SELL ORDER SUCCESVOL GEOPEND ***");
      Print("DEBUG: Ticket: ", ticket, " @ ", price);
      Print("DEBUG: Deze trade is nu 'at risk' - geen nieuwe trades tot breakeven bereikt is");
      // Update global status
      UpdateGlobalTradeStatus();
   }
   else
   {
      int error = GetLastError();
      Print("DEBUG: !!! FOUT bij openen SELL order !!!");
      Print("DEBUG: Error Code: ", error);
      Print("DEBUG: Error Description: ", ErrorDescription(error));
   }
}

//+------------------------------------------------------------------+
//| Manage Open Positions                                            |
//+------------------------------------------------------------------+
void ManageOpenPositions()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            double currentPrice = (OrderType() == OP_BUY) ? Bid : Ask;
            double profit = (OrderType() == OP_BUY) ? 
                           (currentPrice - OrderOpenPrice()) / PipValue : 
                           (OrderOpenPrice() - currentPrice) / PipValue;
            
            if(TickCounter % 100 == 0)
            {
               Print("DEBUG: Order ", OrderTicket(), " | Profit: ", DoubleToStr(profit, 1), " pips");
            }
            
            // Check of we break-even moeten instellen
            if(profit >= BreakEvenPips)
            {
               bool isAtBreakEven = IsOrderAtBreakEven(OrderTicket());
               
               if(!isAtBreakEven)
               {
                  Print("DEBUG: Order ", OrderTicket(), " heeft ", DoubleToStr(profit, 1), " pips winst - zet breakeven!");
                  
                  // Zet stop loss op breakeven (+ offset pips voor spread/veiligheid)
                  double newSL = (OrderType() == OP_BUY) ?
                                OrderOpenPrice() + BreakEvenOffset * PipValue :
                                OrderOpenPrice() - BreakEvenOffset * PipValue;
                  
                  if(OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue))
                  {
                     Print("DEBUG: *** BREAK-EVEN GEZET ***");
                     Print("DEBUG: Order ", OrderTicket(), " SL: ", OrderOpenPrice(), " -> ", newSL);
                     Print("DEBUG: >>> SIGNAAL: Nieuwe trade mag nu geopend worden <<<");
                     UpdateGlobalTradeStatus(); // Update status
                  }
                  else
                  {
                     Print("DEBUG: Fout bij modify order: ", GetLastError());
                  }
               }
            }
            
            // EURUSD: Trailing stop bij verdere winst (na breakeven)
            if(profit >= 50) // 50 pips winst
            {
               double newSL = (OrderType() == OP_BUY) ?
                             currentPrice - 30 * PipValue :
                             currentPrice + 30 * PipValue;
               
               if((OrderType() == OP_BUY && newSL > OrderStopLoss()) ||
                  (OrderType() == OP_SELL && newSL < OrderStopLoss()))
               {
                  if(OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue))
                  {
                     Print("DEBUG: Trailing stop aangepast voor order ", OrderTicket());
                  }
               }
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Count Orders                                                     |
//+------------------------------------------------------------------+
int CountOrders()
{
   int count = 0;
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            count++;
         }
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Close All Orders                                                 |
//+------------------------------------------------------------------+
void CloseAllOrders()
{
   Print("DEBUG: Sluiten ALLE orders...");
   int closedCount = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            bool closed = false;
            int attempts = 0;
            int maxAttempts = 3;
            
            while(!closed && attempts < maxAttempts)
            {
               if(OrderType() == OP_BUY)
               {
                  closed = OrderClose(OrderTicket(), OrderLots(), Bid, 3, clrRed);
               }
               else if(OrderType() == OP_SELL)
               {
                  closed = OrderClose(OrderTicket(), OrderLots(), Ask, 3, clrRed);
               }
               
               if(!closed)
               {
                  int error = GetLastError();
                  Print("DEBUG: Fout bij sluiten order ", OrderTicket(), ": ", error, " (poging ", attempts + 1, "/", maxAttempts, ")");
                  Sleep(1000);
                  attempts++;
               }
               else
               {
                  closedCount++;
                  Print("DEBUG: Order ", OrderTicket(), " succesvol gesloten");
               }
            }
            
            if(!closed)
            {
               Print("DEBUG: WAARSCHUWING: Order ", OrderTicket(), " kon niet gesloten worden na ", maxAttempts, " pogingen");
            }
         }
      }
   }
   Print("DEBUG: Totaal ", closedCount, " order(s) gesloten");
}

//+------------------------------------------------------------------+
//| Update Global Trade Status - Updates cross-EA coordination      |
//+------------------------------------------------------------------+
void UpdateGlobalTradeStatus()
{
   int totalTrades = 0;
   int tradesAtRisk = 0;
   
   // Tel alle orders van ALLE EA's
   for(int i = 0; i < OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         // Alleen market orders (geen pending orders)
         if(OrderType() == OP_BUY || OrderType() == OP_SELL)
         {
            totalTrades++;
            
            // Check of deze order NOG NIET op breakeven staat
            if(!IsOrderAtBreakEven(OrderTicket()))
            {
               tradesAtRisk++;
            }
         }
      }
   }
   
   GlobalVariableSet(GV_ActiveTrades, totalTrades);
   GlobalVariableSet(GV_TradesAtRisk, tradesAtRisk);
   
   Print("DEBUG: Global Status Update - ActiveTrades: ", totalTrades, " | TradesAtRisk: ", tradesAtRisk);
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
      return false; // Geen SL = niet op breakeven
   
   // Check of SL binnen bereik van breakeven staat (offset + buffer van 3 pips)
   double distance = MathAbs(stopLoss - openPrice) / PipValue;
   double breakEvenZone = BreakEvenOffset + 3; // Offset + 3 pips buffer
   
   if(distance <= breakEvenZone)
   {
      return true; // Op of dichtbij breakeven
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Error Description Helper                                         |
//+------------------------------------------------------------------+
string ErrorDescription(int error_code)
{
   string error_string;
   
   switch(error_code)
   {
      case 0:    error_string="Geen error";                                                  break;
      case 1:    error_string="Geen error, maar resultaat onbekend";                         break;
      case 2:    error_string="Algemene error";                                              break;
      case 3:    error_string="Ongeldige trade parameters";                                  break;
      case 4:    error_string="Trade server is bezet";                                       break;
      case 5:    error_string="Oude versie van client terminal";                             break;
      case 6:    error_string="Geen connectie met trade server";                             break;
      case 7:    error_string="Niet genoeg rechten";                                         break;
      case 8:    error_string="Te frequent aanvragen";                                       break;
      case 9:    error_string="Niet toegestane operatie";                                    break;
      case 64:   error_string="Account gedisabled";                                          break;
      case 65:   error_string="Ongeldig account nummer";                                     break;
      case 128:  error_string="Trade timeout";                                               break;
      case 129:  error_string="Ongeldige prijs";                                             break;
      case 130:  error_string="Ongeldige stops";                                             break;
      case 131:  error_string="Ongeldig trade volume";                                       break;
      case 132:  error_string="Markt is gesloten";                                           break;
      case 133:  error_string="Trading disabled";                                            break;
      case 134:  error_string="Niet genoeg geld";                                            break;
      case 135:  error_string="Prijs is veranderd";                                          break;
      case 136:  error_string="Geen prijzen";                                                break;
      case 137:  error_string="Broker is bezet";                                             break;
      case 138:  error_string="Nieuwe prijzen";                                              break;
      case 139:  error_string="Order is locked";                                             break;
      case 140:  error_string="Alleen long posities toegestaan";                             break;
      case 141:  error_string="Te veel aanvragen";                                           break;
      case 145:  error_string="Modificatie niet toegestaan";                                 break;
      case 146:  error_string="Trade context is bezet";                                      break;
      case 147:  error_string="Expiratie datum niet toegestaan";                             break;
      case 148:  error_string="Te veel open posities";                                       break;
      case 4000: error_string="Geen error";                                                  break;
      case 4108: error_string="Ongeldig ticket nummer";                                      break;
      case 4109: error_string="Trading niet toegestaan - Expert Advisor settings";           break;
      case 4110: error_string="Longs niet toegestaan - Expert Advisor settings";             break;
      case 4111: error_string="Shorts niet toegestaan - Expert Advisor settings";            break;
      default:   error_string="Onbekende error code: "+IntegerToString(error_code);          break;
   }
   
   return(error_string);
}
//+------------------------------------------------------------------+
