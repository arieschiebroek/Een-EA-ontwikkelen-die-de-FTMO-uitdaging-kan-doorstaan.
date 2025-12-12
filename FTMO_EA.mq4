//+------------------------------------------------------------------+
//|                                                      FTMO_EA.mq4 |
//|                     Expert Advisor voor FTMO Challenge           |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "FTMO Challenge EA"
#property link      ""
#property version   "1.00"
#property strict

//--- Input Parameters
input string EA_Settings = "=== EA Identificatie ===";
input int    EA_MagicNumber = 100001;        // Uniek nummer per EA/Symbol
input string EA_Comment = "FTMO_EA";         // Comment voor trades

input string Risk_Settings = "=== Risico Instellingen ===";
input double RiskPercentPerTrade = 1.0;      // Risico per trade (%)
input double MaxDailyLossPercent = 5.0;      // Maximaal dagelijks verlies (%)
input double MonthlyProfitTarget = 10.0;     // Maandelijks winstdoel (%)

input string SL_BE_Settings = "=== Stop Loss & Break-Even ===";
input int    StopLossPips = 50;              // Stop Loss in pips
input int    TakeProfitPips = 100;           // Take Profit in pips
input int    BreakEvenPips = 20;             // Pips winst voor break-even
input int    BreakEvenExtraPips = 5;         // Extra pips bij break-even

input string Trading_Settings = "=== Trading Instellingen ===";
input bool   EnableTrading = true;           // Schakel trading in/uit
input int    MaxTradesPerDay = 10;           // Maximaal trades per dag
input int    Slippage = 3;                   // Toegestane slippage

//--- Global Variables
double StartingBalance;
double DailyStartBalance;
datetime LastBarTime;
datetime CurrentDay;
int TradesToday = 0;
bool DailyLossLimitReached = false;

// File voor coordinatie tussen EA's
string CoordinationFile = "FTMO_EA_Coordination.txt";
string DailyLossFile = "FTMO_Daily_Loss.txt";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   Print("=== FTMO EA Initialisatie ===");
   Print("Symbol: ", Symbol());
   Print("Magic Number: ", EA_MagicNumber);
   Print("Stop Loss: ", StopLossPips, " pips");
   Print("Break-Even: ", BreakEvenPips, " pips");
   Print("Max Daily Loss: ", MaxDailyLossPercent, "%");
   
   StartingBalance = AccountBalance();
   DailyStartBalance = AccountBalance();
   CurrentDay = TimeCurrent();
   LastBarTime = Time[0];
   
   // Initialiseer coordinatie files
   InitializeCoordinationFiles();
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   Print("FTMO EA gestopt. Reden: ", reason);
   // Verwijder deze EA uit coordinatie
   RemoveFromCoordination();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
   // Check of het een nieuwe dag is
   CheckNewDay();
   
   // Check dagelijkse verlies limiet
   if(CheckDailyLossLimit())
   {
      CloseAllTrades("Dagelijkse verlies limiet bereikt");
      return;
   }
   
   // Manage bestaande trades
   ManageOpenTrades();
   
   // Check of trading is toegestaan
   if(!EnableTrading || DailyLossLimitReached)
      return;
      
   // Check max trades per dag
   if(TradesToday >= MaxTradesPerDay)
      return;
   
   // Check of we een nieuwe bar hebben
   if(Time[0] == LastBarTime)
      return;
   LastBarTime = Time[0];
   
   // Check of deze EA mag traden (coordinatie check)
   if(!CanThisEATrade())
   {
      // Er is al een andere EA actief zonder break-even
      return;
   }
   
   // Genereer trading signaal
   int signal = GenerateSignal();
   
   if(signal == 1) // Buy signaal
   {
      OpenBuyTrade();
   }
   else if(signal == -1) // Sell signaal
   {
      OpenSellTrade();
   }
}

//+------------------------------------------------------------------+
//| Check nieuwe dag                                                 |
//+------------------------------------------------------------------+
void CheckNewDay()
{
   datetime currentTime = TimeCurrent();
   
   if(TimeDay(currentTime) != TimeDay(CurrentDay))
   {
      // Nieuwe dag
      CurrentDay = currentTime;
      DailyStartBalance = AccountBalance();
      TradesToday = 0;
      DailyLossLimitReached = false;
      
      Print("=== Nieuwe trading dag ===");
      Print("Start balance: ", DailyStartBalance);
      
      // Reset daily loss file
      ResetDailyLossFile();
   }
}

//+------------------------------------------------------------------+
//| Check dagelijkse verlies limiet                                  |
//+------------------------------------------------------------------+
bool CheckDailyLossLimit()
{
   if(DailyLossLimitReached)
      return true;
      
   double currentEquity = AccountEquity();
   double dailyLoss = DailyStartBalance - currentEquity;
   double dailyLossPercent = (dailyLoss / DailyStartBalance) * 100.0;
   
   if(dailyLossPercent >= MaxDailyLossPercent)
   {
      DailyLossLimitReached = true;
      Print("!!! WAARSCHUWING: Dagelijkse verlies limiet bereikt !!!");
      Print("Start balance: ", DailyStartBalance);
      Print("Current equity: ", currentEquity);
      Print("Verlies: ", dailyLoss, " (", dailyLossPercent, "%)");
      
      WriteDailyLossFile(true);
      return true;
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Manage open trades                                               |
//+------------------------------------------------------------------+
void ManageOpenTrades()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
         
      if(OrderMagicNumber() != EA_MagicNumber)
         continue;
         
      if(OrderSymbol() != Symbol())
         continue;
      
      // Check break-even
      MoveToBreakEven(OrderTicket());
   }
}

//+------------------------------------------------------------------+
//| Move stop loss naar break-even                                   |
//+------------------------------------------------------------------+
void MoveToBreakEven(int ticket)
{
   if(!OrderSelect(ticket, SELECT_BY_TICKET))
      return;
      
   double point = MarketInfo(OrderSymbol(), MODE_POINT);
   int digits = (int)MarketInfo(OrderSymbol(), MODE_DIGITS);
   
   // Normaliseer digits voor 3/5 digit brokers
   double pipValue = point;
   if(digits == 3 || digits == 5)
      pipValue = point * 10;
   
   double breakEvenDistance = BreakEvenPips * pipValue;
   double breakEvenExtra = BreakEvenExtraPips * pipValue;
   
   if(OrderType() == OP_BUY)
   {
      double currentProfit = Bid - OrderOpenPrice();
      
      // Check of winst >= break-even pips
      if(currentProfit >= breakEvenDistance)
      {
         double newSL = NormalizeDouble(OrderOpenPrice() + breakEvenExtra, digits);
         
         // Check of SL nog niet op break-even staat
         if(OrderStopLoss() < OrderOpenPrice() || OrderStopLoss() == 0)
         {
            if(OrderModify(ticket, OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrGreen))
            {
               Print("BUY trade ", ticket, " SL verplaatst naar break-even: ", newSL);
               // Update coordinatie - deze trade is nu op break-even
               UpdateCoordination(false);
            }
         }
      }
   }
   else if(OrderType() == OP_SELL)
   {
      double currentProfit = OrderOpenPrice() - Ask;
      
      if(currentProfit >= breakEvenDistance)
      {
         double newSL = NormalizeDouble(OrderOpenPrice() - breakEvenExtra, digits);
         
         if(OrderStopLoss() > OrderOpenPrice() || OrderStopLoss() == 0)
         {
            if(OrderModify(ticket, OrderOpenPrice(), newSL, OrderTakeProfit(), 0, clrRed))
            {
               Print("SELL trade ", ticket, " SL verplaatst naar break-even: ", newSL);
               // Update coordinatie - deze trade is nu op break-even
               UpdateCoordination(false);
            }
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Check of deze EA mag traden                                      |
//+------------------------------------------------------------------+
bool CanThisEATrade()
{
   // Check eerst dagelijkse verlies in global file
   if(ReadDailyLossFile())
   {
      DailyLossLimitReached = true;
      return false;
   }
   
   // Check of er al een actieve trade is zonder break-even
   // Als deze EA zelf een actieve trade heeft zonder BE, mag niet meer traden
   if(HasActiveTradeWithoutBreakEven())
      return false;
   
   // Check of een andere EA een actieve trade heeft zonder break-even
   if(AnotherEAHasActiveTrade())
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Check of deze EA een actieve trade heeft zonder break-even       |
//+------------------------------------------------------------------+
bool HasActiveTradeWithoutBreakEven()
{
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
         
      if(OrderMagicNumber() != EA_MagicNumber)
         continue;
         
      if(OrderSymbol() != Symbol())
         continue;
      
      // Check of SL op break-even staat
      if(OrderType() == OP_BUY)
      {
         if(OrderStopLoss() < OrderOpenPrice() || OrderStopLoss() == 0)
            return true; // Trade zonder break-even
      }
      else if(OrderType() == OP_SELL)
      {
         if(OrderStopLoss() > OrderOpenPrice() || OrderStopLoss() == 0)
            return true; // Trade zonder break-even
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Check of een andere EA een actieve trade heeft                   |
//+------------------------------------------------------------------+
bool AnotherEAHasActiveTrade()
{
   int handle = FileOpen(CoordinationFile, FILE_READ|FILE_TXT|FILE_COMMON);
   
   if(handle == INVALID_HANDLE)
      return false;
      
   while(!FileIsEnding(handle))
   {
      string line = FileReadString(handle);
      
      if(StringLen(line) > 0)
      {
         string parts[];
         int count = StringSplit(line, ';', parts);
         
         if(count >= 3)
         {
            int magicNumber = (int)StringToInteger(parts[0]);
            bool hasActiveTrade = (bool)StringToInteger(parts[2]);
            
            // Als een andere EA een actieve trade heeft
            if(magicNumber != EA_MagicNumber && hasActiveTrade)
            {
               FileClose(handle);
               return true;
            }
         }
      }
   }
   
   FileClose(handle);
   return false;
}

//+------------------------------------------------------------------+
//| Genereer trading signaal                                         |
//+------------------------------------------------------------------+
int GenerateSignal()
{
   // Dit is een basis signaal generator
   // Kan aangepast worden voor elk symbol met specifieke indicatoren
   
   // Voorbeeld: Simpel Moving Average crossover
   double ma_fast_0 = iMA(Symbol(), 0, 20, 0, MODE_SMA, PRICE_CLOSE, 0);
   double ma_fast_1 = iMA(Symbol(), 0, 20, 0, MODE_SMA, PRICE_CLOSE, 1);
   double ma_slow_0 = iMA(Symbol(), 0, 50, 0, MODE_SMA, PRICE_CLOSE, 0);
   double ma_slow_1 = iMA(Symbol(), 0, 50, 0, MODE_SMA, PRICE_CLOSE, 1);
   
   // Buy signal: fast MA crosses above slow MA
   if(ma_fast_1 <= ma_slow_1 && ma_fast_0 > ma_slow_0)
      return 1;
   
   // Sell signal: fast MA crosses below slow MA
   if(ma_fast_1 >= ma_slow_1 && ma_fast_0 < ma_slow_0)
      return -1;
   
   return 0; // Geen signaal
}

//+------------------------------------------------------------------+
//| Open BUY trade                                                    |
//+------------------------------------------------------------------+
void OpenBuyTrade()
{
   double lotSize = CalculateLotSize();
   
   if(lotSize <= 0)
   {
      Print("Lot size berekening mislukt");
      return;
   }
   
   double point = MarketInfo(Symbol(), MODE_POINT);
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   
   double pipValue = point;
   if(digits == 3 || digits == 5)
      pipValue = point * 10;
   
   double sl = Ask - (StopLossPips * pipValue);
   double tp = Ask + (TakeProfitPips * pipValue);
   
   sl = NormalizeDouble(sl, digits);
   tp = NormalizeDouble(tp, digits);
   
   int ticket = OrderSend(Symbol(), OP_BUY, lotSize, Ask, Slippage, sl, tp, 
                          EA_Comment, EA_MagicNumber, 0, clrGreen);
   
   if(ticket > 0)
   {
      Print("BUY order geopend: Ticket ", ticket, " Lots: ", lotSize);
      TradesToday++;
      
      // Update coordinatie - we hebben nu een actieve trade
      UpdateCoordination(true);
   }
   else
   {
      Print("BUY order mislukt. Error: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Open SELL trade                                                   |
//+------------------------------------------------------------------+
void OpenSellTrade()
{
   double lotSize = CalculateLotSize();
   
   if(lotSize <= 0)
   {
      Print("Lot size berekening mislukt");
      return;
   }
   
   double point = MarketInfo(Symbol(), MODE_POINT);
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   
   double pipValue = point;
   if(digits == 3 || digits == 5)
      pipValue = point * 10;
   
   double sl = Bid + (StopLossPips * pipValue);
   double tp = Bid - (TakeProfitPips * pipValue);
   
   sl = NormalizeDouble(sl, digits);
   tp = NormalizeDouble(tp, digits);
   
   int ticket = OrderSend(Symbol(), OP_SELL, lotSize, Bid, Slippage, sl, tp, 
                          EA_Comment, EA_MagicNumber, 0, clrRed);
   
   if(ticket > 0)
   {
      Print("SELL order geopend: Ticket ", ticket, " Lots: ", lotSize);
      TradesToday++;
      
      // Update coordinatie - we hebben nu een actieve trade
      UpdateCoordination(true);
   }
   else
   {
      Print("SELL order mislukt. Error: ", GetLastError());
   }
}

//+------------------------------------------------------------------+
//| Bereken lot size op basis van risico                            |
//+------------------------------------------------------------------+
double CalculateLotSize()
{
   double riskAmount = AccountBalance() * (RiskPercentPerTrade / 100.0);
   
   double point = MarketInfo(Symbol(), MODE_POINT);
   int digits = (int)MarketInfo(Symbol(), MODE_DIGITS);
   
   double pipValue = point;
   if(digits == 3 || digits == 5)
      pipValue = point * 10;
   
   double tickValue = MarketInfo(Symbol(), MODE_TICKVALUE);
   double tickSize = MarketInfo(Symbol(), MODE_TICKSIZE);
   
   // Bereken pip waarde
   double pipValueInAccountCurrency = (tickValue / tickSize) * pipValue;
   
   // Bereken lot size
   double lotSize = riskAmount / (StopLossPips * pipValueInAccountCurrency);
   
   // Normaliseer lot size
   double minLot = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   
   lotSize = MathFloor(lotSize / lotStep) * lotStep;
   
   if(lotSize < minLot)
      lotSize = minLot;
   if(lotSize > maxLot)
      lotSize = maxLot;
   
   return NormalizeDouble(lotSize, 2);
}

//+------------------------------------------------------------------+
//| Sluit alle trades                                                |
//+------------------------------------------------------------------+
void CloseAllTrades(string reason)
{
   Print("Alle trades sluiten. Reden: ", reason);
   
   for(int i = OrdersTotal() - 1; i >= 0; i--)
   {
      if(!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
         continue;
         
      if(OrderMagicNumber() != EA_MagicNumber)
         continue;
         
      if(OrderSymbol() != Symbol())
         continue;
      
      bool closed = false;
      
      if(OrderType() == OP_BUY)
      {
         closed = OrderClose(OrderTicket(), OrderLots(), Bid, Slippage, clrRed);
      }
      else if(OrderType() == OP_SELL)
      {
         closed = OrderClose(OrderTicket(), OrderLots(), Ask, Slippage, clrRed);
      }
      
      if(closed)
         Print("Trade ", OrderTicket(), " gesloten");
      else
         Print("Fout bij sluiten trade ", OrderTicket(), ". Error: ", GetLastError());
   }
   
   UpdateCoordination(false);
}

//+------------------------------------------------------------------+
//| Initialiseer coordinatie files                                   |
//+------------------------------------------------------------------+
void InitializeCoordinationFiles()
{
   // Maak coordinatie file aan als deze niet bestaat
   int handle = FileOpen(CoordinationFile, FILE_READ|FILE_WRITE|FILE_TXT|FILE_COMMON);
   if(handle != INVALID_HANDLE)
      FileClose(handle);
      
   // Maak daily loss file aan
   handle = FileOpen(DailyLossFile, FILE_READ|FILE_WRITE|FILE_TXT|FILE_COMMON);
   if(handle != INVALID_HANDLE)
      FileClose(handle);
}

//+------------------------------------------------------------------+
//| Update coordinatie file                                          |
//+------------------------------------------------------------------+
void UpdateCoordination(bool hasActiveTrade)
{
   // Lees huidige coordinatie
   string content = "";
   bool found = false;
   
   int handle = FileOpen(CoordinationFile, FILE_READ|FILE_TXT|FILE_COMMON);
   if(handle != INVALID_HANDLE)
   {
      while(!FileIsEnding(handle))
      {
         string line = FileReadString(handle);
         
         if(StringLen(line) > 0)
         {
            string parts[];
            int count = StringSplit(line, ';', parts);
            
            if(count >= 3)
            {
               int magicNumber = (int)StringToInteger(parts[0]);
               
               if(magicNumber == EA_MagicNumber)
               {
                  // Update deze EA
                  found = true;
                  content += IntegerToString(EA_MagicNumber) + ";" + 
                            Symbol() + ";" + 
                            IntegerToString(hasActiveTrade ? 1 : 0) + "\n";
               }
               else
               {
                  // Behoud andere EA's
                  content += line + "\n";
               }
            }
         }
      }
      FileClose(handle);
   }
   
   // Als niet gevonden, voeg toe
   if(!found)
   {
      content += IntegerToString(EA_MagicNumber) + ";" + 
                Symbol() + ";" + 
                IntegerToString(hasActiveTrade ? 1 : 0) + "\n";
   }
   
   // Schrijf terug
   handle = FileOpen(CoordinationFile, FILE_WRITE|FILE_TXT|FILE_COMMON);
   if(handle != INVALID_HANDLE)
   {
      FileWriteString(handle, content);
      FileClose(handle);
   }
}

//+------------------------------------------------------------------+
//| Verwijder deze EA uit coordinatie                                |
//+------------------------------------------------------------------+
void RemoveFromCoordination()
{
   string content = "";
   
   int handle = FileOpen(CoordinationFile, FILE_READ|FILE_TXT|FILE_COMMON);
   if(handle != INVALID_HANDLE)
   {
      while(!FileIsEnding(handle))
      {
         string line = FileReadString(handle);
         
         if(StringLen(line) > 0)
         {
            string parts[];
            int count = StringSplit(line, ';', parts);
            
            if(count >= 3)
            {
               int magicNumber = (int)StringToInteger(parts[0]);
               
               if(magicNumber != EA_MagicNumber)
               {
                  content += line + "\n";
               }
            }
         }
      }
      FileClose(handle);
   }
   
   // Schrijf terug
   handle = FileOpen(CoordinationFile, FILE_WRITE|FILE_TXT|FILE_COMMON);
   if(handle != INVALID_HANDLE)
   {
      FileWriteString(handle, content);
      FileClose(handle);
   }
}

//+------------------------------------------------------------------+
//| Schrijf daily loss file                                          |
//+------------------------------------------------------------------+
void WriteDailyLossFile(bool limitReached)
{
   int handle = FileOpen(DailyLossFile, FILE_WRITE|FILE_TXT|FILE_COMMON);
   
   if(handle != INVALID_HANDLE)
   {
      string content = IntegerToString(TimeDay(TimeCurrent())) + ";" + 
                      IntegerToString(limitReached ? 1 : 0);
      FileWriteString(handle, content);
      FileClose(handle);
   }
}

//+------------------------------------------------------------------+
//| Lees daily loss file                                             |
//+------------------------------------------------------------------+
bool ReadDailyLossFile()
{
   int handle = FileOpen(DailyLossFile, FILE_READ|FILE_TXT|FILE_COMMON);
   
   if(handle == INVALID_HANDLE)
      return false;
      
   string line = FileReadString(handle);
   FileClose(handle);
   
   if(StringLen(line) > 0)
   {
      string parts[];
      int count = StringSplit(line, ';', parts);
      
      if(count >= 2)
      {
         int day = (int)StringToInteger(parts[0]);
         bool limitReached = (bool)StringToInteger(parts[1]);
         
         // Check of het vandaag is
         if(day == TimeDay(TimeCurrent()) && limitReached)
            return true;
      }
   }
   
   return false;
}

//+------------------------------------------------------------------+
//| Reset daily loss file                                            |
//+------------------------------------------------------------------+
void ResetDailyLossFile()
{
   WriteDailyLossFile(false);
}
//+------------------------------------------------------------------+
