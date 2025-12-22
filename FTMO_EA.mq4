//+------------------------------------------------------------------+
//|                                                      FTMO_EA.mq4 |
//|                        Expert Advisor voor FTMO Challenge        |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "FTMO Challenge EA"
#property link      ""
#property version   "1.00"
#property strict

//--- Input parameters
input double LotSize = 0.01;              // Lot grootte
input int StopLoss = 100;                  // Stop Loss in pips
input int TakeProfit = 150;                // Take Profit in pips
input int MagicNumber = 123456;            // Magic Number
input double MaxDailyLossPercent = 5.0;    // Maximaal dagelijks verlies in % (FTMO: 5%)
input double MaxTotalDrawdown = 1000;      // Maximale totale drawdown in USD ($10k account = 10% max)
input int RSI_Period = 14;                 // RSI periode
input int EMA_Fast = 12;                  // Snelle EMA periode
input int EMA_Slow = 26;                  // Langzame EMA periode

//--- Global variables
double InitialBalance;
double DailyStartBalance;
datetime LastDayChecked;
double MaxDrawdownReached = 0;
double PipValue;

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
   
   Print("FTMO EA Geïnitialiseerd");
   Print("Start Balance: ", InitialBalance);
   Print("Account: ", AccountNumber());
   Print("Symbool: ", Symbol());
   Print("Timeframe: H1");
   Print("Pip Value: ", PipValue);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("FTMO EA Gestopt");
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
      Print("Nieuwe handelsdag gestart. Dagelijkse balans reset: ", DailyStartBalance);
   }
   
   // FTMO Regel Check: Dagelijks Verlies Limiet (5% van dagelijkse start balance)
   double MaxDailyLoss = DailyStartBalance * (MaxDailyLossPercent / 100.0);
   double DailyPnL = AccountBalance() - DailyStartBalance;
   if(DailyPnL <= -MaxDailyLoss)
   {
      Print("WAARSCHUWING: Dagelijkse verlies limiet bereikt!");
      Print("Start balance: ", DailyStartBalance, " | Max verlies: ", MaxDailyLoss, " (", MaxDailyLossPercent, "%)");
      Print("Huidig verlies: ", -DailyPnL, " | Geen nieuwe trades.");
      CloseAllOrders();
      return;
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
   
   // Controleer of er al een open positie is
   if(CountOrders() > 0)
   {
      ManageOpenPositions();
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
            // Trailing stop logica kan hier toegevoegd worden
            // Voor nu: laat orders lopen tot TP of SL
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
                  Sleep(1000); // Wait 1 second before retry
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
