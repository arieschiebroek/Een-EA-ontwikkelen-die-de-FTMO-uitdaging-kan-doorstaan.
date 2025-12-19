# Technische Documentatie FTMO EA

## Architectuur Overzicht

### Componenten

1. **FTMO_EA.mq4** - Hoofd EA bestand
2. **Coördinatie Systeem** - File-based communicatie tussen EA's
3. **Risk Management Module** - Position sizing en loss limiting
4. **Trade Management** - Order handling en break-even logic

## File-Based Coördinatie

### FTMO_EA_Coordination.txt
Format: `MagicNumber;Symbol;HasActiveTrade`

Voorbeeld:
```
100001;EURUSD;1
100002;XAUUSD;0
100003;GBPUSD;0
```

**Betekenis**:
- EURUSD EA (100001) heeft een actieve trade zonder break-even
- XAUUSD EA (100002) heeft geen actieve trade of trade is op break-even
- GBPUSD EA (100003) heeft geen actieve trade of trade is op break-even

### FTMO_Daily_Loss.txt
Format: `Day;LimitReached`

Voorbeeld:
```
12;1
```

**Betekenis**:
- Op dag 12 van de maand is de dagelijkse verlies limiet bereikt
- Alle EA's moeten stoppen met traden voor deze dag

## Functie Overzicht

### Initialisatie
```mql4
int OnInit()
```
- Initialiseer globale variabelen
- Stel start balances in
- Maak coördinatie bestanden aan

### Tick Handler
```mql4
void OnTick()
```
**Volgorde van operaties**:
1. Check nieuwe dag
2. Check dagelijkse verlies limiet
3. Manage bestaande trades (break-even)
4. Check of trading toegestaan is
5. Check nieuwe bar
6. Check coördinatie
7. Genereer signaal
8. Open trade indien toegestaan

### Coördinatie Logica

#### CanThisEATrade()
```mql4
bool CanThisEATrade()
```
**Controleert**:
1. Is dagelijkse verlies limiet bereikt? (global)
2. Heeft deze EA zelf een actieve trade zonder BE?
3. Heeft een andere EA een actieve trade zonder BE?

**Return**: `true` als EA mag traden, anders `false`

#### HasActiveTradeWithoutBreakEven()
```mql4
bool HasActiveTradeWithoutBreakEven()
```
**Logica voor BUY**:
- Als `OrderStopLoss() < OrderOpenPrice()` → Geen break-even
- Als `OrderStopLoss() == 0` → Geen break-even

**Logica voor SELL**:
- Als `OrderStopLoss() > OrderOpenPrice()` → Geen break-even
- Als `OrderStopLoss() == 0` → Geen break-even

#### AnotherEAHasActiveTrade()
```mql4
bool AnotherEAHasActiveTrade()
```
- Leest `FTMO_EA_Coordination.txt`
- Zoekt naar andere EA's met `HasActiveTrade = 1`
- Negeert eigen Magic Number

### Break-Even Management

#### MoveToBreakEven()
```mql4
void MoveToBreakEven(int ticket)
```

**Voor BUY trade**:
```
Current Profit = Bid - OrderOpenPrice()
If Profit >= BreakEvenPips:
    New SL = OrderOpenPrice() + BreakEvenExtraPips
    Modify Order
    Update Coordination (HasActiveTrade = false)
```

**Voor SELL trade**:
```
Current Profit = OrderOpenPrice() - Ask
If Profit >= BreakEvenPips:
    New SL = OrderOpenPrice() - BreakEvenExtraPips
    Modify Order
    Update Coordination (HasActiveTrade = false)
```

### Risk Management

#### CalculateLotSize()
```mql4
double CalculateLotSize()
```

**Formule**:
```
Risk Amount = Account Balance × (Risk% / 100)
Pip Value = (Tick Value / Tick Size) × Pip Size
Lot Size = Risk Amount / (Stop Loss Pips × Pip Value)
```

**Normalisatie**:
- Round naar LotStep
- Clamp tussen MinLot en MaxLot

#### CheckDailyLossLimit()
```mql4
bool CheckDailyLossLimit()
```

**Formule**:
```
Daily Loss = DailyStartBalance - Current Equity
Daily Loss% = (Daily Loss / DailyStartBalance) × 100

If Daily Loss% >= MaxDailyLossPercent:
    Close All Trades
    Set DailyLossLimitReached = true
    Write to FTMO_Daily_Loss.txt
```

### Trade Execution

#### OpenBuyTrade()
```mql4
void OpenBuyTrade()
```
**Stappen**:
1. Bereken lot size
2. Bereken SL en TP levels
3. Send order met `OrderSend()`
4. Update coördinatie (`HasActiveTrade = true`)

#### OpenSellTrade()
```mql4
void OpenSellTrade()
```
Identiek aan OpenBuyTrade maar voor SELL orders.

### Signal Generation

#### GenerateSignal()
```mql4
int GenerateSignal()
```

**Huidige Implementatie**: Moving Average Crossover
- Fast MA: 20 periode SMA
- Slow MA: 50 periode SMA

**BUY Signaal**:
```
MA_fast[1] <= MA_slow[1] AND MA_fast[0] > MA_slow[0]
```

**SELL Signaal**:
```
MA_fast[1] >= MA_slow[1] AND MA_fast[0] < MA_slow[0]
```

**Customization**: Vervang deze logica met uw eigen strategie.

## Pip Calculation voor 3/5 Digit Brokers

```mql4
double point = MarketInfo(Symbol(), MODE_POINT);
int digits = MarketInfo(Symbol(), MODE_DIGITS);

double pipValue = point;
if(digits == 3 || digits == 5)
    pipValue = point * 10;
```

**Voorbeeld**:
- EURUSD (5 digits): Point = 0.00001, Pip = 0.0001
- USDJPY (3 digits): Point = 0.001, Pip = 0.01
- XAUUSD (2 digits): Point = 0.01, Pip = 0.01

## State Machine

### EA State Diagram

```
[Initialisatie]
      ↓
[Check Nieuwe Dag] → [Reset Daily Variables]
      ↓
[Check Daily Loss] → [Bereikt?] → [Close All & Block]
      ↓                   ↓ Nee
[Manage Trades] → [Move to BE if possible]
      ↓
[Check Can Trade] → [Blocked?] → [Return]
      ↓                   ↓ Nee
[Generate Signal] → [No Signal?] → [Return]
      ↓                   ↓ Signal
[Open Trade] → [Update Coordination]
```

## Coördinatie Flow

### Scenario 1: Eerste Trade
```
EA1 (EURUSD) checks CanThisEATrade()
  → No daily loss limit
  → No active trades without BE
  → No other EA has active trade
  → Return TRUE
  
EA1 opens BUY trade
EA1 UpdateCoordination(HasActiveTrade = TRUE)

EA2 (XAUUSD) checks CanThisEATrade()
  → AnotherEAHasActiveTrade() = TRUE
  → Return FALSE
  → EA2 waits
```

### Scenario 2: Break-Even Bereikt
```
EA1 trade reaches +20 pips
EA1 MoveToBreakEven()
  → Modify SL to Entry + 5 pips
  → UpdateCoordination(HasActiveTrade = FALSE)
  
EA2 (XAUUSD) checks CanThisEATrade()
  → AnotherEAHasActiveTrade() = FALSE
  → Return TRUE
  → EA2 can now trade
```

### Scenario 3: Daily Loss Limit
```
Account reaches 5% daily loss
Any EA CheckDailyLossLimit() = TRUE
  → CloseAllTrades()
  → WriteDailyLossFile(TRUE)
  
All EAs:
  → ReadDailyLossFile() = TRUE
  → CanThisEATrade() = FALSE
  → Blocked for rest of day
  
Next day:
  → CheckNewDay() detects new day
  → ResetDailyLossFile()
  → Trading enabled again
```

## Error Handling

### OrderSend Errors
```mql4
int ticket = OrderSend(...);
if(ticket > 0)
{
    // Succes
}
else
{
    int error = GetLastError();
    Print("Order failed. Error: ", error);
    // Geen retry - wacht op volgende signaal
}
```

### OrderModify Errors
```mql4
bool modified = OrderModify(...);
if(modified)
{
    // Succes - update coordination
}
else
{
    // Mislukt - probeer volgende tick opnieuw
}
```

### File Access Errors
```mql4
int handle = FileOpen(...);
if(handle == INVALID_HANDLE)
{
    // Gebruik defaults
    // Of retry volgende tick
}
```

## Performance Optimizations

### 1. File Access
- Minimale reads/writes
- Cache waar mogelijk
- Gebruik FILE_COMMON voor shared access

### 2. Bar Detection
```mql4
if(Time[0] == LastBarTime)
    return; // Skip tick - geen nieuwe bar
```

### 3. Order Selection
- Loop van achteren naar voren
- Break vroeg bij condities

## Testing Checklist

### Unit Tests
- [ ] CalculateLotSize() met verschillende account sizes
- [ ] MoveToBreakEven() logica voor BUY en SELL
- [ ] Daily loss calculation
- [ ] Coordination file read/write

### Integration Tests
- [ ] Multiple EA's op demo account
- [ ] Break-even trigger andere EA trading
- [ ] Daily loss limit sluit alle EA's
- [ ] New day reset

### Live Testing
- [ ] Start met minimale lot sizes
- [ ] Monitor coördinatie in real-time
- [ ] Verifieer file access werkt
- [ ] Check performance metrics

## Aanpassingen voor Productie

### 1. Signal Generation
Vervang `GenerateSignal()` met:
- RSI divergence
- Support/Resistance breaks
- Candlestick patterns
- Volume analysis
- Multi-timeframe confirmation

### 2. Entry Filters
Voeg toe:
- Time filters (trading sessions)
- Volatility filters (ATR)
- Trend filters (higher timeframe)
- News filters (economic calendar)

### 3. Advanced Risk Management
- Trailing stop
- Partial close at targets
- Correlation checking between pairs
- Drawdown-based position sizing

### 4. Monitoring
- Email/Push notifications
- Performance logging
- Trade journal export
- Statistics dashboard

## Bekende Beperkingen

1. **File-based coördinatie**: Kan race conditions hebben bij exact gelijktijdige access
   - Oplossing: Gebruik semaphores of database

2. **Simpel signaal systeem**: MA crossover is basis
   - Oplossing: Implementeer geavanceerde strategie

3. **Geen correlation check**: Kan gecorreleerde paren tegelijk traden
   - Oplossing: Voeg correlation matrix toe

4. **Geen slippage compensation**: Bij hoge volatiliteit kan slippage groot zijn
   - Oplossing: Dynamische slippage op basis van volatiliteit

## Toekomstige Verbeteringen

### Versie 2.0 Roadmap
- [ ] Machine learning signal generation
- [ ] Adaptive position sizing
- [ ] Multi-timeframe analysis
- [ ] Correlation-aware trading
- [ ] Advanced trailing stops
- [ ] Cloud-based coordination
- [ ] Performance analytics dashboard
- [ ] Automatic parameter optimization

## Appendix: MQL4 Reference

### Belangrijke Functies
```mql4
// Market Info
MarketInfo(symbol, MODE_POINT)
MarketInfo(symbol, MODE_DIGITS)
MarketInfo(symbol, MODE_MINLOT)
MarketInfo(symbol, MODE_MAXLOT)
MarketInfo(symbol, MODE_LOTSTEP)

// Orders
OrderSend(symbol, cmd, volume, price, slippage, sl, tp, comment, magic, expiration, color)
OrderModify(ticket, price, sl, tp, expiration, color)
OrderClose(ticket, lots, price, slippage, color)
OrderSelect(index, select_by, pool)

// Account
AccountBalance()
AccountEquity()
AccountProfit()

// Files
FileOpen(filename, mode, delimiter)
FileClose(handle)
FileWriteString(handle, text)
FileReadString(handle)
```

---

**Versie**: 1.0
**Laatst bijgewerkt**: December 2025
