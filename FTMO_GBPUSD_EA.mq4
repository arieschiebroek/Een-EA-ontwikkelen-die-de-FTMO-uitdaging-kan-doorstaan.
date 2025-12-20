//+------------------------------------------------------------------+
//|                                               FTMO_GBPUSD_EA.mq4 |
//|                        Expert Advisor voor FTMO Challenge        |
//|                        Geoptimaliseerd voor GBPUSD               |
//+------------------------------------------------------------------+
#property copyright "FTMO Challenge EA - GBPUSD"
#property link      ""
#property version   "1.00"
#property strict

//--- Input parameters
input double LotSize = 0.01;              // Lot grootte
input int StopLoss = 110;                  // Stop Loss in pips (GBPUSD volatiel)
input int TakeProfit = 165;                // Take Profit in pips (1.5:1 R/R)
input int MagicNumber = 333333;            // Magic Number voor GBPUSD
input double MaxDailyLossPercent = 5.0;    // Maximaal dagelijks verlies in % (FTMO: 5%)
input double MaxTotalDrawdown = 1000;      // Maximale totale drawdown in USD
input int RSI_Period = 14;                 // RSI periode
input int EMA_Fast = 10;                   // Snelle EMA
input int EMA_Slow = 20;                   // Langzame EMA
input int MACD_Fast = 12;                  // MACD Fast EMA
input int MACD_Slow = 26;                  // MACD Slow EMA
input int MACD_Signal = 9;                 // MACD Signal

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
   
   Print("FTMO GBPUSD EA Geïnitialiseerd");
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
   Print("FTMO GBPUSD EA Gestopt");
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
   
   // Trading logica voor GBPUSD
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
//| Get trade signal - GBPUSD Specifieke Strategie                  |
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
   
   // MACD voor momentum bevestiging
   double macdMain = iMACD(Symbol(), PERIOD_H1, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE, MODE_MAIN, 0);
   double macdSignal = iMACD(Symbol(), PERIOD_H1, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE, MODE_SIGNAL, 0);
   double macdMainPrev = iMACD(Symbol(), PERIOD_H1, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE, MODE_MAIN, 1);
   double macdSignalPrev = iMACD(Symbol(), PERIOD_H1, MACD_Fast, MACD_Slow, MACD_Signal, PRICE_CLOSE, MODE_SIGNAL, 1);
   
   // Trend strength check - SMA 50
   double sma50 = iMA(Symbol(), PERIOD_H1, 50, 0, MODE_SMA, PRICE_CLOSE, 0);
   double currentPrice = Close[0];
   
   // GBPUSD specifieke condities:
   // - Sterk trend-following systeem (volatiel paar)
   // - EMA + MACD bevestiging
   // - Price action boven/onder SMA 50 voor trend
   
   bool macdBullishCross = (macdMainPrev <= macdSignalPrev && macdMain > macdSignal);
   bool macdBearishCross = (macdMainPrev >= macdSignalPrev && macdMain < macdSignal);
   
   // Buy Signal: EMA crossover + MACD bullish + prijs boven SMA50 + RSI niet overbought
   if(emaFastPrev <= emaSlowPrev && emaFast > emaSlow && 
      macdMain > macdSignal && currentPrice > sma50 && rsi < 60)
   {
      Print("GBPUSD Buy signaal - EMA + MACD + Trend + RSI");
      return OP_BUY;
   }
   
   // Extra Buy: MACD crossover met sterke trend
   if(macdBullishCross && emaFast > emaSlow && currentPrice > sma50 && rsi < 65)
   {
      Print("GBPUSD Buy signaal - MACD Crossover met Uptrend");
      return OP_BUY;
   }
   
   // Sell Signal: EMA crossover + MACD bearish + prijs onder SMA50 + RSI niet oversold
   if(emaFastPrev >= emaSlowPrev && emaFast < emaSlow && 
      macdMain < macdSignal && currentPrice < sma50 && rsi > 40)
   {
      Print("GBPUSD Sell signaal - EMA + MACD + Trend + RSI");
      return OP_SELL;
   }
   
   // Extra Sell: MACD crossover met sterke trend
   if(macdBearishCross && emaFast < emaSlow && currentPrice < sma50 && rsi > 35)
   {
      Print("GBPUSD Sell signaal - MACD Crossover met Downtrend");
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
                         "FTMO GBPUSD Buy", MagicNumber, 0, clrGreen);
   
   if(ticket > 0)
   {
      Print("GBPUSD Buy order geopend: ", ticket, " @ ", price);
   }
   else
   {
      Print("Fout bij openen GBPUSD buy order: ", GetLastError());
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
                         "FTMO GBPUSD Sell", MagicNumber, 0, clrRed);
   
   if(ticket > 0)
   {
      Print("GBPUSD Sell order geopend: ", ticket, " @ ", price);
   }
   else
   {
      Print("Fout bij openen GBPUSD sell order: ", GetLastError());
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
            // GBPUSD: Trailing stop bij 80 pips winst (volatiel paar)
            double currentPrice = (OrderType() == OP_BUY) ? Bid : Ask;
            double profit = (OrderType() == OP_BUY) ? 
                           (currentPrice - OrderOpenPrice()) / PipValue : 
                           (OrderOpenPrice() - currentPrice) / PipValue;
            
            if(profit >= 80) // 80 pips winst
            {
               double newSL = (OrderType() == OP_BUY) ?
                             currentPrice - 40 * PipValue :
                             currentPrice + 40 * PipValue;
               
               if((OrderType() == OP_BUY && newSL > OrderStopLoss()) ||
                  (OrderType() == OP_SELL && newSL < OrderStopLoss()))
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue);
                  Print("GBPUSD Trailing stop aangepast voor order ", OrderTicket());
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
   Print("Totaal ", closedCount, " GBPUSD order(s) gesloten vanwege FTMO limiet");
}
//+------------------------------------------------------------------+
