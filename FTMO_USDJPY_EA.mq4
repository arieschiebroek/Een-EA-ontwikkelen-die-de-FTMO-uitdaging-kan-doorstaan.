//+------------------------------------------------------------------+
//|                                               FTMO_USDJPY_EA.mq4 |
//|                        Expert Advisor voor FTMO Challenge        |
//|                        Geoptimaliseerd voor USDJPY               |
//+------------------------------------------------------------------+
#property copyright "FTMO Challenge EA - USDJPY"
#property link      ""
#property version   "1.00"
#property strict

//--- Input parameters
input double LotSize = 0.01;              // Lot grootte
input int StopLoss = 90;                   // Stop Loss in pips (USDJPY volatiel)
input int TakeProfit = 135;                // Take Profit in pips (1.5:1 R/R)
input int MagicNumber = 222222;            // Magic Number voor USDJPY
input double MaxDailyLossPercent = 5.0;    // Maximaal dagelijks verlies in % (FTMO: 5%)
input double MaxTotalDrawdown = 1000;      // Maximale totale drawdown in USD
input int RSI_Period = 14;                 // RSI periode
input int EMA_Fast = 8;                    // Snelle EMA (aangepast voor USDJPY)
input int EMA_Slow = 18;                   // Langzame EMA (aangepast voor USDJPY)
input int BB_Period = 20;                  // Bollinger Bands periode
input double BB_Deviation = 2.0;           // Bollinger Bands deviatie

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
   
   Print("FTMO USDJPY EA Geïnitialiseerd");
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
   Print("FTMO USDJPY EA Gestopt");
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
   
   // Trading logica voor USDJPY
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
//| Get trade signal - USDJPY Specifieke Strategie                  |
//+------------------------------------------------------------------+
int GetTradeSignal()
{
   // RSI Indicator
   double rsi = iRSI(Symbol(), PERIOD_H1, RSI_Period, PRICE_CLOSE, 0);
   double rsiPrev = iRSI(Symbol(), PERIOD_H1, RSI_Period, PRICE_CLOSE, 1);
   
   // EMA Indicators (8/18 voor USDJPY - sneller)
   double emaFast = iMA(Symbol(), PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaSlow = iMA(Symbol(), PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaFastPrev = iMA(Symbol(), PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE, 1);
   double emaSlowPrev = iMA(Symbol(), PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE, 1);
   
   // Bollinger Bands voor volatiliteit en extremen
   double bbUpper = iBands(Symbol(), PERIOD_H1, BB_Period, BB_Deviation, 0, PRICE_CLOSE, MODE_UPPER, 0);
   double bbLower = iBands(Symbol(), PERIOD_H1, BB_Period, BB_Deviation, 0, PRICE_CLOSE, MODE_LOWER, 0);
   double bbMiddle = iBands(Symbol(), PERIOD_H1, BB_Period, BB_Deviation, 0, PRICE_CLOSE, MODE_MAIN, 0);
   
   double currentPrice = Close[0];
   double prevPrice = Close[1];
   
   // USDJPY specifieke condities:
   // - Bollinger Bands voor mean reversion
   // - EMA trend bevestiging
   // - RSI momentum
   
   // Buy Signal: Prijs bounced van lower BB + EMA crossover + RSI stijgend
   if(prevPrice <= bbLower && currentPrice > bbLower && 
      emaFast > emaSlow && rsi < 50 && rsi > rsiPrev)
   {
      Print("USDJPY Buy signaal - BB Bounce + EMA Trend + RSI Momentum");
      return OP_BUY;
   }
   
   // Sell Signal: Prijs bounced van upper BB + EMA crossover + RSI dalend
   if(prevPrice >= bbUpper && currentPrice < bbUpper && 
      emaFast < emaSlow && rsi > 50 && rsi < rsiPrev)
   {
      Print("USDJPY Sell signaal - BB Bounce + EMA Trend + RSI Momentum");
      return OP_SELL;
   }
   
   // Extra: Mean reversion bij extreme RSI
   if(rsi < 25 && currentPrice < bbLower && emaFast > emaFastPrev)
   {
      Print("USDJPY Buy signaal - Extreme Oversold + Mean Reversion");
      return OP_BUY;
   }
   
   if(rsi > 75 && currentPrice > bbUpper && emaFast < emaFastPrev)
   {
      Print("USDJPY Sell signaal - Extreme Overbought + Mean Reversion");
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
                         "FTMO USDJPY Buy", MagicNumber, 0, clrGreen);
   
   if(ticket > 0)
   {
      Print("USDJPY Buy order geopend: ", ticket, " @ ", price);
   }
   else
   {
      Print("Fout bij openen USDJPY buy order: ", GetLastError());
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
                         "FTMO USDJPY Sell", MagicNumber, 0, clrRed);
   
   if(ticket > 0)
   {
      Print("USDJPY Sell order geopend: ", ticket, " @ ", price);
   }
   else
   {
      Print("Fout bij openen USDJPY sell order: ", GetLastError());
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
            // USDJPY: Dynamische trailing stop op basis van ATR
            double atr = iATR(Symbol(), PERIOD_H1, 14, 0);
            double currentPrice = (OrderType() == OP_BUY) ? Bid : Ask;
            double profit = (OrderType() == OP_BUY) ? 
                           (currentPrice - OrderOpenPrice()) / PipValue : 
                           (OrderOpenPrice() - currentPrice) / PipValue;
            
            if(profit >= 60) // 60 pips winst voor USDJPY
            {
               double trailDistance = atr / PipValue * 2; // 2x ATR trailing
               double newSL = (OrderType() == OP_BUY) ?
                             currentPrice - trailDistance * PipValue :
                             currentPrice + trailDistance * PipValue;
               
               if((OrderType() == OP_BUY && newSL > OrderStopLoss()) ||
                  (OrderType() == OP_SELL && newSL < OrderStopLoss()))
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue);
                  Print("USDJPY ATR-based trailing stop aangepast voor order ", OrderTicket());
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
   Print("Totaal ", closedCount, " USDJPY order(s) gesloten vanwege FTMO limiet");
}
//+------------------------------------------------------------------+
