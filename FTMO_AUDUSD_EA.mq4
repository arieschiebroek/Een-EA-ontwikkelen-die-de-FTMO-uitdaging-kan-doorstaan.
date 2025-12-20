//+------------------------------------------------------------------+
//|                                               FTMO_AUDUSD_EA.mq4 |
//|                        Expert Advisor voor FTMO Challenge        |
//|                        Geoptimaliseerd voor AUDUSD               |
//+------------------------------------------------------------------+
#property copyright "FTMO Challenge EA - AUDUSD"
#property link      ""
#property version   "1.00"
#property strict

//--- Input parameters
input double LotSize = 0.01;              // Lot grootte
input int StopLoss = 85;                   // Stop Loss in pips
input int TakeProfit = 130;                // Take Profit in pips (1.5:1 R/R)
input int MagicNumber = 444444;            // Magic Number voor AUDUSD
input double MaxDailyLossPercent = 5.0;    // Maximaal dagelijks verlies in % (FTMO: 5%)
input double MaxTotalDrawdown = 1000;      // Maximale totale drawdown in USD
input int RSI_Period = 14;                 // RSI periode
input int EMA_Fast = 11;                   // Snelle EMA
input int EMA_Slow = 22;                   // Langzame EMA
input int Stoch_K = 14;                    // Stochastic %K periode
input int Stoch_D = 3;                     // Stochastic %D periode
input int Stoch_Slowing = 3;               // Stochastic Slowing

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
   
   Print("FTMO AUDUSD EA Geïnitialiseerd");
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
   Print("FTMO AUDUSD EA Gestopt");
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
   
   // Trading logica voor AUDUSD
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
//| Get trade signal - AUDUSD Specifieke Strategie                  |
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
   
   // Stochastic Oscillator voor overbought/oversold
   double stochMain = iStochastic(Symbol(), PERIOD_H1, Stoch_K, Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_MAIN, 0);
   double stochSignal = iStochastic(Symbol(), PERIOD_H1, Stoch_K, Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_SIGNAL, 0);
   double stochMainPrev = iStochastic(Symbol(), PERIOD_H1, Stoch_K, Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_MAIN, 1);
   double stochSignalPrev = iStochastic(Symbol(), PERIOD_H1, Stoch_K, Stoch_D, Stoch_Slowing, MODE_SMA, 0, MODE_SIGNAL, 1);
   
   // ADX voor trend sterkte (commodity currency - trend-follower)
   double adx = iADX(Symbol(), PERIOD_H1, 14, PRICE_CLOSE, MODE_MAIN, 0);
   double plusDI = iADX(Symbol(), PERIOD_H1, 14, PRICE_CLOSE, MODE_PLUSDI, 0);
   double minusDI = iADX(Symbol(), PERIOD_H1, 14, PRICE_CLOSE, MODE_MINUSDI, 0);
   
   // AUDUSD specifieke condities:
   // - Commodity currency - correlatie met risico sentiment
   // - Stochastic voor timing entries
   // - ADX voor trend sterkte bevestiging
   // - EMA trend richting
   
   bool strongTrend = (adx > 25); // ADX > 25 = sterke trend
   bool stochBullishCross = (stochMainPrev <= stochSignalPrev && stochMain > stochSignal);
   bool stochBearishCross = (stochMainPrev >= stochSignalPrev && stochMain < stochSignal);
   
   // Buy Signal: EMA uptrend + Stochastic oversold bounce + ADX trend + RSI
   if(emaFast > emaSlow && stochMain < 30 && stochBullishCross && 
      plusDI > minusDI && rsi < 55)
   {
      Print("AUDUSD Buy signaal - EMA Trend + Stoch Oversold + ADX");
      return OP_BUY;
   }
   
   // Extra Buy: Strong trend met EMA crossover
   if(emaFastPrev <= emaSlowPrev && emaFast > emaSlow && 
      strongTrend && plusDI > minusDI && rsi < 60)
   {
      Print("AUDUSD Buy signaal - EMA Crossover met sterke uptrend");
      return OP_BUY;
   }
   
   // Sell Signal: EMA downtrend + Stochastic overbought drop + ADX trend + RSI
   if(emaFast < emaSlow && stochMain > 70 && stochBearishCross && 
      minusDI > plusDI && rsi > 45)
   {
      Print("AUDUSD Sell signaal - EMA Trend + Stoch Overbought + ADX");
      return OP_SELL;
   }
   
   // Extra Sell: Strong trend met EMA crossover
   if(emaFastPrev >= emaSlowPrev && emaFast < emaSlow && 
      strongTrend && minusDI > plusDI && rsi > 40)
   {
      Print("AUDUSD Sell signaal - EMA Crossover met sterke downtrend");
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
                         "FTMO AUDUSD Buy", MagicNumber, 0, clrGreen);
   
   if(ticket > 0)
   {
      Print("AUDUSD Buy order geopend: ", ticket, " @ ", price);
   }
   else
   {
      Print("Fout bij openen AUDUSD buy order: ", GetLastError());
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
                         "FTMO AUDUSD Sell", MagicNumber, 0, clrRed);
   
   if(ticket > 0)
   {
      Print("AUDUSD Sell order geopend: ", ticket, " @ ", price);
   }
   else
   {
      Print("Fout bij openen AUDUSD sell order: ", GetLastError());
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
            // AUDUSD: Trailing stop bij 60 pips winst
            double currentPrice = (OrderType() == OP_BUY) ? Bid : Ask;
            double profit = (OrderType() == OP_BUY) ? 
                           (currentPrice - OrderOpenPrice()) / PipValue : 
                           (OrderOpenPrice() - currentPrice) / PipValue;
            
            if(profit >= 60) // 60 pips winst
            {
               double newSL = (OrderType() == OP_BUY) ?
                             currentPrice - 35 * PipValue :
                             currentPrice + 35 * PipValue;
               
               if((OrderType() == OP_BUY && newSL > OrderStopLoss()) ||
                  (OrderType() == OP_SELL && newSL < OrderStopLoss()))
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue);
                  Print("AUDUSD Trailing stop aangepast voor order ", OrderTicket());
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
   Print("Totaal ", closedCount, " AUDUSD order(s) gesloten vanwege FTMO limiet");
}
//+------------------------------------------------------------------+
