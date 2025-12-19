//+------------------------------------------------------------------+
//|                                               FTMO_XAUUSD_EA.mq4 |
//|                        Expert Advisor voor FTMO Challenge        |
//|                        Geoptimaliseerd voor XAUUSD (Gold)        |
//+------------------------------------------------------------------+
#property copyright "FTMO Challenge EA - XAUUSD"
#property link      ""
#property version   "1.00"
#property strict

//--- Input parameters
input double LotSize = 0.01;              // Lot grootte
input int StopLoss = 200;                  // Stop Loss in pips (Gold zeer volatiel)
input int TakeProfit = 300;                // Take Profit in pips (1.5:1 R/R)
input int MagicNumber = 555555;            // Magic Number voor XAUUSD
input double MaxDailyLoss = 500;           // Maximaal dagelijks verlies in USD
input double MaxTotalDrawdown = 1000;      // Maximale totale drawdown in USD
input int RSI_Period = 14;                 // RSI periode
input int EMA_Fast = 15;                   // Snelle EMA (langer voor Gold)
input int EMA_Slow = 30;                   // Langzame EMA (langer voor Gold)
input int ATR_Period = 14;                 // ATR periode
input double ATR_MinThreshold = 1.0;       // Minimum ATR voor trade entry

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
   
   Print("FTMO XAUUSD (Gold) EA Geïnitialiseerd");
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
   Print("FTMO XAUUSD EA Gestopt");
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
   
   // FTMO Regel Check: Dagelijks Verlies Limiet
   double DailyPnL = AccountBalance() - DailyStartBalance;
   if(DailyPnL <= -MaxDailyLoss)
   {
      Print("WAARSCHUWING: Dagelijkse verlies limiet bereikt! Geen nieuwe trades.");
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
   
   // Trading logica voor XAUUSD
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
//| Get trade signal - XAUUSD Specifieke Strategie                  |
//+------------------------------------------------------------------+
int GetTradeSignal()
{
   // RSI Indicator
   double rsi = iRSI(Symbol(), PERIOD_H1, RSI_Period, PRICE_CLOSE, 0);
   double rsiPrev = iRSI(Symbol(), PERIOD_H1, RSI_Period, PRICE_CLOSE, 1);
   
   // EMA Indicators (15/30 voor Gold - filter noise)
   double emaFast = iMA(Symbol(), PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaSlow = iMA(Symbol(), PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE, 0);
   double emaFastPrev = iMA(Symbol(), PERIOD_H1, EMA_Fast, 0, MODE_EMA, PRICE_CLOSE, 1);
   double emaSlowPrev = iMA(Symbol(), PERIOD_H1, EMA_Slow, 0, MODE_EMA, PRICE_CLOSE, 1);
   
   // ATR voor volatiliteit - Gold beweegt anders
   double atr = iATR(Symbol(), PERIOD_H1, ATR_Period, 0);
   double atrAvg = 0;
   for(int i = 0; i < 10; i++)
   {
      atrAvg += iATR(Symbol(), PERIOD_H1, ATR_Period, i);
   }
   atrAvg = atrAvg / 10;
   
   // Support/Resistance met recent highs/lows
   double recentHigh = High[iHighest(Symbol(), PERIOD_H1, MODE_HIGH, 20, 1)];
   double recentLow = Low[iLowest(Symbol(), PERIOD_H1, MODE_LOW, 20, 1)];
   double currentPrice = Close[0];
   
   // Price distance from MA200 (long term trend)
   double ma200 = iMA(Symbol(), PERIOD_H1, 200, 0, MODE_SMA, PRICE_CLOSE, 0);
   
   // XAUUSD specifieke condities:
   // - Safe haven asset - beweegt op nieuws en risico sentiment
   // - Volatiliteit check (alleen handelen in actieve periodes)
   // - Support/Resistance levels belangrijk
   // - Langere EMA's voor minder whipsaws
   
   bool volatilityOK = (atr > ATR_MinThreshold && atr > atrAvg * 0.8);
   bool uptrend = (emaFast > emaSlow && currentPrice > ma200);
   bool downtrend = (emaFast < emaSlow && currentPrice < ma200);
   
   // Buy Signal: EMA crossover + bounce from support + RSI oversold + volatiliteit
   if(emaFastPrev <= emaSlowPrev && emaFast > emaSlow && 
      rsi < 40 && volatilityOK && uptrend)
   {
      Print("XAUUSD Buy signaal - EMA Crossover + Trend + RSI + Volatiliteit");
      return OP_BUY;
   }
   
   // Extra Buy: Near support met RSI divergence
   if(currentPrice < (recentLow * 1.002) && rsi < 35 && rsi > rsiPrev && 
      emaFast > emaSlow && volatilityOK)
   {
      Print("XAUUSD Buy signaal - Support Bounce + RSI Divergence");
      return OP_BUY;
   }
   
   // Sell Signal: EMA crossover + rejection from resistance + RSI overbought + volatiliteit
   if(emaFastPrev >= emaSlowPrev && emaFast < emaSlow && 
      rsi > 60 && volatilityOK && downtrend)
   {
      Print("XAUUSD Sell signaal - EMA Crossover + Trend + RSI + Volatiliteit");
      return OP_SELL;
   }
   
   // Extra Sell: Near resistance met RSI divergence
   if(currentPrice > (recentHigh * 0.998) && rsi > 65 && rsi < rsiPrev && 
      emaFast < emaSlow && volatilityOK)
   {
      Print("XAUUSD Sell signaal - Resistance Rejection + RSI Divergence");
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
   
   int ticket = OrderSend(Symbol(), OP_BUY, LotSize, price, 5, sl, tp, 
                         "FTMO XAUUSD Buy", MagicNumber, 0, clrGreen);
   
   if(ticket > 0)
   {
      Print("XAUUSD Buy order geopend: ", ticket, " @ ", price);
   }
   else
   {
      Print("Fout bij openen XAUUSD buy order: ", GetLastError());
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
   
   int ticket = OrderSend(Symbol(), OP_SELL, LotSize, price, 5, sl, tp, 
                         "FTMO XAUUSD Sell", MagicNumber, 0, clrRed);
   
   if(ticket > 0)
   {
      Print("XAUUSD Sell order geopend: ", ticket, " @ ", price);
   }
   else
   {
      Print("Fout bij openen XAUUSD sell order: ", GetLastError());
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
            // XAUUSD: ATR-based trailing stop (zeer volatiel)
            double atr = iATR(Symbol(), PERIOD_H1, ATR_Period, 0);
            double currentPrice = (OrderType() == OP_BUY) ? Bid : Ask;
            double profit = (OrderType() == OP_BUY) ? 
                           (currentPrice - OrderOpenPrice()) / PipValue : 
                           (OrderOpenPrice() - currentPrice) / PipValue;
            
            if(profit >= 150) // 150 pips winst (50% van target)
            {
               double trailDistance = atr * 2; // 2x ATR trailing
               double newSL = (OrderType() == OP_BUY) ?
                             currentPrice - trailDistance :
                             currentPrice + trailDistance;
               
               if((OrderType() == OP_BUY && newSL > OrderStopLoss()) ||
                  (OrderType() == OP_SELL && newSL < OrderStopLoss()))
               {
                  OrderModify(OrderTicket(), OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrBlue);
                  Print("XAUUSD ATR trailing stop aangepast voor order ", OrderTicket());
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
                  closed = OrderClose(OrderTicket(), OrderLots(), Bid, 5, clrRed);
               }
               else if(OrderType() == OP_SELL)
               {
                  closed = OrderClose(OrderTicket(), OrderLots(), Ask, 5, clrRed);
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
   Print("Totaal ", closedCount, " XAUUSD order(s) gesloten vanwege FTMO limiet");
}
//+------------------------------------------------------------------+
