//+------------------------------------------------------------------+
//|                                            FTMO_EA_VOLLEDIG.mq4 |
//|                        Expert Advisor voor FTMO Challenge        |
//|           COMPLETE VERSIE MET ALLE FEATURES                      |
//+------------------------------------------------------------------+
#property copyright "FTMO Challenge EA - Volledig"
#property link      ""
#property version   "2.00"
#property strict

//--- Input parameters
input double LotSize = 0.01;              // Lot grootte
input int StopLoss = 100;                  // Stop Loss in pips
input int TakeProfit = 150;                // Take Profit in pips (1.5:1 R/R)
input int BreakEvenPips = 40;              // Pips winst voordat SL naar breakeven gaat
input int BreakEvenOffset = 2;             // Extra pips boven breakeven (voor spread/veiligheid)
input int MagicNumber = 123456;            // Magic Number
input double MaxDailyLossPercent = 5.0;    // Maximaal dagelijks verlies in % (FTMO: 5%)
input double MaxTotalDrawdown = 1000;      // Maximale totale drawdown in USD
input int RSI_Period = 14;                 // RSI periode
input int EMA_Fast = 12;                   // Snelle EMA
input int EMA_Slow = 26;                   // Langzame EMA

//--- Global variables
double InitialBalance;
double DailyStartBalance;
datetime LastDayChecked;
double MaxDrawdownReached = 0;
double PipValue;

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
   
   Print("FTMO EA VOLLEDIG Geïnitialiseerd");
   Print("Start Balance: ", InitialBalance);
   Print("Account: ", AccountNumber());
   Print("Symbool: ", Symbol());
   Print("Timeframe: H1");
   Print("Pip Value: ", PipValue);
   Print("Break-Even Pips: ", BreakEvenPips);
   Print("Break-Even Offset: ", BreakEvenOffset);
   Print("=== ALLE FEATURES ACTIEF ===");
   Print("✓ Dynamische 5% dagelijkse verlies limiet");
   Print("✓ Break-even stop loss systeem");
   Print("✓ Multi-EA trade coordinatie");
   Print("✓ Sequentiële trading (max 1 at risk)");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("FTMO EA VOLLEDIG Gestopt");
   Print("Eind Balance: ", AccountBalance());
   Print("Totaal Winst/Verlies: ", AccountBalance() - InitialBalance);
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check of we in een nieuwe dag zijn voor dagelijkse reset
   if(TimeDay(TimeCurrent()) != TimeDay(LastDayChecked))
   {
      DailyStartBalance = AccountBalance();
      LastDayChecked = TimeCurrent();
      GlobalVariableSet(GV_DailyTradingAllowed, 1); // Reset trading permission
      Print("Nieuwe handelsdag gestart. Dagelijkse balans reset: ", DailyStartBalance);
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
   
   // Check of trading vandaag nog toegestaan is
   if(GlobalVariableGet(GV_DailyTradingAllowed) == 0)
   {
      return; // Trading geblokkeerd voor vandaag
   }
   
   // FTMO Regel Check: Maximale Drawdown Limiet
   double CurrentDrawdown = InitialBalance - AccountBalance();
   if(CurrentDrawdown > MaxDrawdownReached)
      MaxDrawdownReached = CurrentDrawdown;
      
   if(CurrentDrawdown >= MaxTotalDrawdown)
   {
      Print("WAARSCHUWING: Maximale drawdown bereikt! Alle posities sluiten.");
      CloseAllOrders();
      return;
   }
   
   // Update globale trade status
   UpdateGlobalTradeStatus();
   
   // Manage bestaande posities
   if(CountOrders() > 0)
   {
      ManageOpenPositions();
      return;
   }
   
   // Check of nieuwe trade toegestaan is
   // Regel: Maximaal 1 trade "at risk" (niet op breakeven) tegelijk
   double tradesAtRisk = GlobalVariableGet(GV_TradesAtRisk);
   if(tradesAtRisk >= 1)
   {
      // Er is al een trade actief die niet op breakeven staat
      return;
   }
   
   // Alleen handelen op nieuwe bar (H1)
   static datetime lastBarTime = 0;
   if(Time[0] == lastBarTime)
      return;
   lastBarTime = Time[0];
   
   // Trading logica
   int signal = GetTradeSignal();
   
   if(signal == OP_BUY)
   {
      OpenBuyOrder();
   }
   else if(signal == OP_SELL)
   {
      OpenSellOrder();
   }
}

//+------------------------------------------------------------------+
//| Get trade signal                                                 |
//+------------------------------------------------------------------+
int GetTradeSignal()
{
   // RSI Indicator
   double rsi = iRSI(Symbol(), PERIOD_H1, RSI_Period, PRICE_CLOSE, 0);
   
   // EMA Indicators
   double emaFast = iMA(Symbol(), PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaSlow = iMA(Symbol(), PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaFastPrev = iMA(Symbol(), PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE, 1);
   double emaSlowPrev = iMA(Symbol(), PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE, 1);
   
   // Buy Signal: EMA crossover (fast crosses above slow) AND RSI oversold
   if(emaFastPrev <= emaSlowPrev && emaFast > emaSlow && rsi < 50)
   {
      Print("Buy signaal gedetecteerd - EMA Crossover + RSI");
      return OP_BUY;
   }
   
   // Sell Signal: EMA crossover (fast crosses below slow) AND RSI overbought
   if(emaFastPrev >= emaSlowPrev && emaFast < emaSlow && rsi > 50)
   {
      Print("Sell signaal gedetecteerd - EMA Crossover + RSI");
      return OP_SELL;
   }
   
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
   
   int ticket = OrderSend(Symbol(), OP_BUY, LotSize, price, 3, sl, tp, 
                         "FTMO Buy", MagicNumber, 0, clrGreen);
   
   if(ticket > 0)
   {
      Print("Buy order geopend: ", ticket, " @ ", price);
      Print("Deze trade is nu 'at risk' - geen nieuwe trades tot breakeven bereikt is");
      // Update global status
      UpdateGlobalTradeStatus();
   }
   else
   {
      Print("Fout bij openen buy order: ", GetLastError());
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
   
   int ticket = OrderSend(Symbol(), OP_SELL, LotSize, price, 3, sl, tp, 
                         "FTMO Sell", MagicNumber, 0, clrRed);
   
   if(ticket > 0)
   {
      Print("Sell order geopend: ", ticket, " @ ", price);
      Print("Deze trade is nu 'at risk' - geen nieuwe trades tot breakeven bereikt is");
      // Update global status
      UpdateGlobalTradeStatus();
   }
   else
   {
      Print("Fout bij openen sell order: ", GetLastError());
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
            
            // Check of we break-even moeten instellen
            if(profit >= BreakEvenPips)
            {
               bool isAtBreakEven = IsOrderAtBreakEven(OrderTicket());
               
               if(!isAtBreakEven)
               {
                  // Zet stop loss op breakeven (+ offset pips voor spread/veiligheid)
                  double newSL = (OrderType() == OP_BUY) ?
                                OrderOpenPrice() + BreakEvenOffset * PipValue :
                                OrderOpenPrice() - BreakEvenOffset * PipValue;
                  
                  if(OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue))
                  {
                     Print("Order ", OrderTicket(), " stop loss naar BREAK-EVEN gezet!");
                     Print("Break-even niveau: ", OrderOpenPrice(), " + ", BreakEvenOffset, " pips = ", newSL);
                     Print(">>> SIGNAAL: Nieuwe trade mag nu geopend worden door deze of andere EA <<<");
                  }
               }
            }
            
            // Trailing stop bij verdere winst (na breakeven)
            if(profit >= 60) // 60 pips winst
            {
               double newSL = (OrderType() == OP_BUY) ?
                             currentPrice - 30 * PipValue :
                             currentPrice + 30 * PipValue;
               
               if((OrderType() == OP_BUY && newSL > OrderStopLoss()) ||
                  (OrderType() == OP_SELL && newSL < OrderStopLoss()))
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue);
                  Print("Trailing stop aangepast voor order ", OrderTicket());
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
                  Print("Fout bij sluiten order ", OrderTicket(), ": ", error, " (poging ", attempts + 1, "/", maxAttempts, ")");
                  Sleep(1000);
                  attempts++;
               }
               else
               {
                  closedCount++;
                  Print("Order ", OrderTicket(), " succesvol gesloten");
               }
            }
            
            if(!closed)
            {
               Print("WAARSCHUWING: Order ", OrderTicket(), " kon niet gesloten worden na ", maxAttempts, " pogingen");
            }
         }
      }
   }
   Print("Totaal ", closedCount, " order(s) gesloten vanwege FTMO limiet");
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
