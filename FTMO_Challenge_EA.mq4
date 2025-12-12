//+------------------------------------------------------------------+
//|                                             FTMO_Challenge_EA.mq4 |
//|                                   Expert Advisor voor FTMO uitdaging |
//|                                                                      |
//+------------------------------------------------------------------+
#property copyright "FTMO Challenge EA"
#property link      ""
#property version   "1.00"
#property strict

// Input parameters voor strategie
input string    Section1 = "=== Risk Management Settings ===";
input double    RiskPercentPerTrade = 1.0;        // Risk per trade (% van balance)
input double    MaxDailyLossPercent = 4.0;        // Max dagelijks verlies (% van balance)
input double    MaxTotalLossPercent = 8.0;        // Max totaal verlies (% van startbalance)
input int       MaxOpenPositions = 3;             // Max aantal open posities

input string    Section2 = "=== Trading Strategy Settings ===";
input int       FastMA_Period = 20;               // Snelle Moving Average periode
input int       SlowMA_Period = 50;               // Langzame Moving Average periode
input int       RSI_Period = 14;                  // RSI periode
input double    RSI_Overbought = 70;              // RSI overbought level
input double    RSI_Oversold = 30;                // RSI oversold level
input int       ATR_Period = 14;                  // ATR periode voor volatiliteit

input string    Section3 = "=== Trade Management ===";
input double    StopLossATR = 2.0;                // Stop Loss (ATR multiplier)
input double    TakeProfitATR = 3.0;              // Take Profit (ATR multiplier)
input bool      UseTrailingStop = true;           // Gebruik Trailing Stop
input double    TrailingStopATR = 1.5;            // Trailing Stop (ATR multiplier)
input double    MinRiskRewardRatio = 1.5;         // Minimum Risk/Reward verhouding

input string    Section4 = "=== Trading Filters ===";
input int       StartHour = 2;                    // Start trading uur (server tijd)
input int       EndHour = 22;                     // Stop trading uur (server tijd)
input double    MaxSpreadPips = 3.0;              // Maximum toegestane spread in pips
input bool      TradeOnMonday = true;             // Trade op maandag
input bool      TradeOnFriday = true;             // Trade op vrijdag

input string    Section5 = "=== Expert Advisor Settings ===";
input int       MagicNumber = 123456;             // Magic number voor deze EA
input string    TradeComment = "FTMO_EA";         // Comment voor trades

// Globale variabelen
double StartBalance;
double DayStartBalance;
datetime LastBarTime;
datetime DayStartTime;
int TotalTradesToday = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                     |
//+------------------------------------------------------------------+
int OnInit()
{
   StartBalance = AccountBalance();
   DayStartBalance = AccountBalance();
   DayStartTime = TimeCurrent();
   LastBarTime = Time[0];
   
   Print("FTMO Challenge EA geïnitialiseerd");
   Print("Start Balance: ", StartBalance);
   Print("Account: ", AccountNumber());
   Print("Symbol: ", Symbol());
   Print("Timeframe: H1");
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                   |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("EA gestopt. Reden: ", reason);
}

//+------------------------------------------------------------------+
//| Expert tick function                                               |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check voor nieuwe bar
   if(Time[0] == LastBarTime)
      return;
   LastBarTime = Time[0];
   
   // Check nieuwe dag
   CheckNewDay();
   
   // Safety checks
   if(!IsSafeToTrade())
      return;
   
   // Update trailing stops voor bestaande posities
   if(UseTrailingStop)
      UpdateTrailingStops();
   
   // Check of we kunnen handelen
   if(CountOpenPositions() >= MaxOpenPositions)
      return;
   
   // Analyseer markt en handel
   AnalyzeAndTrade();
}

//+------------------------------------------------------------------+
//| Check of het een nieuwe dag is                                    |
//+------------------------------------------------------------------+
void CheckNewDay()
{
   datetime currentDayStart = iTime(Symbol(), PERIOD_D1, 0);
   
   if(currentDayStart != DayStartTime)
   {
      DayStartTime = currentDayStart;
      DayStartBalance = AccountBalance();
      TotalTradesToday = 0;
      Print("Nieuwe trading dag. Start balance: ", DayStartBalance);
   }
}

//+------------------------------------------------------------------+
//| Check of het veilig is om te handelen                             |
//+------------------------------------------------------------------+
bool IsSafeToTrade()
{
   // Check dagelijks verlies
   double dailyPL = AccountBalance() - DayStartBalance;
   double maxDailyLoss = DayStartBalance * (MaxDailyLossPercent / 100.0);
   
   if(dailyPL < -maxDailyLoss)
   {
      Print("Dagelijks verlies limiet bereikt: ", dailyPL);
      return false;
   }
   
   // Check totaal verlies
   double totalPL = AccountBalance() - StartBalance;
   double maxTotalLoss = StartBalance * (MaxTotalLossPercent / 100.0);
   
   if(totalPL < -maxTotalLoss)
   {
      Print("Totaal verlies limiet bereikt: ", totalPL);
      return false;
   }
   
   // Check trading uren
   int currentHour = Hour();
   if(currentHour < StartHour || currentHour >= EndHour)
      return false;
   
   // Check dag van de week
   int dayOfWeek = DayOfWeek();
   if(!TradeOnMonday && dayOfWeek == 1)
      return false;
   if(!TradeOnFriday && dayOfWeek == 5)
      return false;
   
   // Check spread
   double spread = (Ask - Bid) / Point / 10; // Convert to pips
   if(spread > MaxSpreadPips)
   {
      Print("Spread te hoog: ", spread, " pips");
      return false;
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Tel open posities                                                 |
//+------------------------------------------------------------------+
int CountOpenPositions()
{
   int count = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
            count++;
      }
   }
   return count;
}

//+------------------------------------------------------------------+
//| Analyseer markt en plaats trades                                  |
//+------------------------------------------------------------------+
void AnalyzeAndTrade()
{
   // Bereken indicators
   double fastMA = iMA(Symbol(), 0, FastMA_Period, 0, MODE_EMA, PRICE_CLOSE, 1);
   double slowMA = iMA(Symbol(), 0, SlowMA_Period, 0, MODE_EMA, PRICE_CLOSE, 1);
   double rsi = iRSI(Symbol(), 0, RSI_Period, PRICE_CLOSE, 1);
   double atr = iATR(Symbol(), 0, ATR_Period, 1);
   
   double fastMA_prev = iMA(Symbol(), 0, FastMA_Period, 0, MODE_EMA, PRICE_CLOSE, 2);
   double slowMA_prev = iMA(Symbol(), 0, SlowMA_Period, 0, MODE_EMA, PRICE_CLOSE, 2);
   
   // Trend bepaling
   bool uptrend = fastMA > slowMA;
   bool downtrend = fastMA < slowMA;
   
   // Crossover detectie
   bool bullishCross = (fastMA > slowMA) && (fastMA_prev <= slowMA_prev);
   bool bearishCross = (fastMA < slowMA) && (fastMA_prev >= slowMA_prev);
   
   // Zoek support en resistance
   double resistance = FindResistance();
   double support = FindSupport();
   
   // Buy signaal
   if(bullishCross && rsi < 70 && Close[1] > support)
   {
      double lotSize = CalculateLotSize(atr);
      if(lotSize > 0)
      {
         double sl = CalculateStopLoss(OP_BUY, atr);
         double tp = CalculateTakeProfit(OP_BUY, atr, sl);
         
         // Controleer risk/reward ratio
         double risk = Ask - sl;
         double reward = tp - Ask;
         if(risk > 0 && reward > 0 && (reward / risk) >= MinRiskRewardRatio)
         {
            OpenTrade(OP_BUY, lotSize, sl, tp);
         }
      }
   }
   
   // Sell signaal
   if(bearishCross && rsi > 30 && Close[1] < resistance)
   {
      double lotSize = CalculateLotSize(atr);
      if(lotSize > 0)
      {
         double sl = CalculateStopLoss(OP_SELL, atr);
         double tp = CalculateTakeProfit(OP_SELL, atr, sl);
         
         // Controleer risk/reward ratio
         double risk = sl - Bid;
         double reward = Bid - tp;
         if(risk > 0 && reward > 0 && (reward / risk) >= MinRiskRewardRatio)
         {
            OpenTrade(OP_SELL, lotSize, sl, tp);
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Vind resistance niveau                                             |
//+------------------------------------------------------------------+
double FindResistance()
{
   double highest = High[1];
   for(int i = 2; i <= 20; i++)
   {
      if(High[i] > highest)
         highest = High[i];
   }
   return highest;
}

//+------------------------------------------------------------------+
//| Vind support niveau                                               |
//+------------------------------------------------------------------+
double FindSupport()
{
   double lowest = Low[1];
   for(int i = 2; i <= 20; i++)
   {
      if(Low[i] < lowest)
         lowest = Low[i];
   }
   return lowest;
}

//+------------------------------------------------------------------+
//| Bereken lot size op basis van risico                              |
//+------------------------------------------------------------------+
double CalculateLotSize(double atr)
{
   double riskAmount = AccountBalance() * (RiskPercentPerTrade / 100.0);
   double stopLossDistance = atr * StopLossATR;
   
   // Bereken lot size op basis van risico
   double pointValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double pointSize = MarketInfo(Symbol(), MODE_POINT);
   
   // Lot size = Risk Amount / (Stop Loss in Points × Point Value)
   double stopLossInPoints = stopLossDistance / pointSize;
   double lotSize = riskAmount / (stopLossInPoints * pointValue);
   
   // Normaliseer lot size
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   lotSize = MathMax(minLot, MathMin(maxLot, lotSize));
   
   return lotSize;
}

//+------------------------------------------------------------------+
//| Bereken Stop Loss                                                 |
//+------------------------------------------------------------------+
double CalculateStopLoss(int orderType, double atr)
{
   double sl;
   double slDistance = atr * StopLossATR;
   
   if(orderType == OP_BUY)
      sl = Ask - slDistance;
   else
      sl = Bid + slDistance;
   
   return NormalizeDouble(sl, Digits);
}

//+------------------------------------------------------------------+
//| Bereken Take Profit                                               |
//+------------------------------------------------------------------+
double CalculateTakeProfit(int orderType, double atr, double stopLoss)
{
   double tp;
   double tpDistance = atr * TakeProfitATR;
   
   if(orderType == OP_BUY)
      tp = Ask + tpDistance;
   else
      tp = Bid - tpDistance;
   
   return NormalizeDouble(tp, Digits);
}

//+------------------------------------------------------------------+
//| Open een trade                                                     |
//+------------------------------------------------------------------+
void OpenTrade(int orderType, double lotSize, double stopLoss, double takeProfit)
{
   double price;
   color arrowColor;
   string orderTypeStr;
   
   if(orderType == OP_BUY)
   {
      price = Ask;
      arrowColor = clrBlue;
      orderTypeStr = "BUY";
   }
   else
   {
      price = Bid;
      arrowColor = clrRed;
      orderTypeStr = "SELL";
   }
   
   int ticket = OrderSend(Symbol(), orderType, lotSize, price, 3, stopLoss, takeProfit, 
                          TradeComment, MagicNumber, 0, arrowColor);
   
   if(ticket > 0)
   {
      TotalTradesToday++;
      Print("Order geopend: ", orderTypeStr, " Ticket: ", ticket, " Lot: ", lotSize, 
            " SL: ", stopLoss, " TP: ", takeProfit);
   }
   else
   {
      Print("Error bij openen order: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Update trailing stops                                             |
//+------------------------------------------------------------------+
void UpdateTrailingStops()
{
   double atr = iATR(Symbol(), 0, ATR_Period, 1);
   double trailDistance = atr * TrailingStopATR;
   double minStopLevel = MarketInfo(Symbol(), MODE_STOPLEVEL) * Point;
   
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
      {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == MagicNumber)
         {
            if(OrderType() == OP_BUY)
            {
               double newSL = Bid - trailDistance;
               // Zorg dat nieuwe SL beter is dan oude EN minimale afstand heeft
               if(newSL > OrderStopLoss() && (Bid - newSL) >= minStopLevel)
               {
                  bool modified = OrderModify(OrderTicket(), OrderOpenPrice(), 
                                             NormalizeDouble(newSL, Digits), 
                                             OrderTakeProfit(), 0, clrBlue);
                  if(modified)
                     Print("Trailing stop updated voor BUY order #", OrderTicket());
               }
            }
            else if(OrderType() == OP_SELL)
            {
               double newSL = Ask + trailDistance;
               // Zorg dat nieuwe SL beter is dan oude EN minimale afstand heeft
               if((OrderStopLoss() == 0 || newSL < OrderStopLoss()) && (newSL - Ask) >= minStopLevel)
               {
                  bool modified = OrderModify(OrderTicket(), OrderOpenPrice(), 
                                             NormalizeDouble(newSL, Digits), 
                                             OrderTakeProfit(), 0, clrRed);
                  if(modified)
                     Print("Trailing stop updated voor SELL order #", OrderTicket());
               }
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
