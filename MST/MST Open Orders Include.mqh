//+------------------------------------------------------------------+
//|                                      MST Open Orders Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"



COrderInfo orderInfo;
CDealInfo dealInfo;
MqlDateTime dt_struct;
CTrade trade;
CAccountInfo accInfo;
CPositionInfo posInfo;
CSymbolInfo symInfo;
MqlTradeRequest myrequest;
MqlTradeResult myresult;


double StopLoss=0;
double TakeProfit=0; 
double UpdatedMultiplier = 0;
double EnterPrice  , TPPrice , SLPrice;

double Default_SL;

bool UseTP = false;
bool UseTrail = false;

int myticket;
double Order_size = 0;

int slipege = 10;


int Prev_Hour = 0; 
int Cur_Hour = 0;
//datetime ThreshHold = 0, TimeNow = 0;
//bool MainRun = false;

double HighestTrail;
double LowestTrail; 
bool positionOpen=false;

double TempTest;

double CalculateLotSize(double SL , int sym) //Calculate the size of the position size 
{         
   double nTickValue=SymbolInfoDouble(SymbolArray[sym],SYMBOL_TRADE_TICK_VALUE); //We get the value of a tick
      if (SL ==0) SL = 1;
      if (nTickValue ==0) nTickValue = 0.00001;
   double LotSize=(AccountInfoDouble(ACCOUNT_BALANCE)*CurrentRiskPerTrade/100)/(SL*nTickValue);   //We apply the formula to calculate the position size and assign the value to the variable
   LotSize = NormalizeDouble(LotSize, 1);
   return LotSize/10;
}


int Count_consecutive_losses(int sym)
{
   HistorySelect(0,TimeCurrent());
   int LastLoss=0;
   int Looper=HistoryDealsTotal();
   while(Looper>0  && LastLoss <10)
   { 
         ulong HTicket = HistoryDealGetTicket(Looper-1);
         if((HistoryDealGetInteger(HTicket, DEAL_MAGIC) == MagicNumber[sym]) && (HistoryDealGetString(HTicket, DEAL_SYMBOL) == SymbolArray[sym]))
         {
               if(HistoryDealGetDouble(HTicket, DEAL_PROFIT) >=0 )  return (LastLoss);
               LastLoss ++;
         } 
        Looper --;
   }
   return (LastLoss);
}



void Calculate_CandlesSL (int Dricetion , double price ,int sym) 
{
      int temp = ReturnTFIndex(Main_TF);
      if (Dricetion ==0) // Buy
      {
            LowestTrail = Low[temp].a[sym].b[iLowest(SymbolArray[sym] , Main_TF , MODE_LOW , SL_CandlesForTrailing , 1)];
            StopLoss = price - LowestTrail + SL_Candles_ATR_Slack*ATRBuffer[sym].b[1];
      }
      else
      {
            HighestTrail = High[temp].a[sym].b[iHighest(SymbolArray[sym] , Main_TF , MODE_HIGH , SL_CandlesForTrailing , 1)];
            StopLoss = (HighestTrail - price + SL_Candles_ATR_Slack*ATRBuffer[sym].b[1]);
      }
}


int PositionsTotalForSymbol(int sym)
{
   int Counter=0;
   int Looper = PositionsTotal();
   while(Looper>0 &&  Counter < 10)   
   { 
         if(posInfo.SelectByIndex(Looper-1))
         {
            if(PositionGetInteger(POSITION_MAGIC)==MagicNumber[sym]) 
            {
                          Counter ++;    // if ( PositionGetDouble(POSITION_PROFIT)<0 )  Counter ++;  -> the grey one - only for trades in negative profit
            }
        }
      Looper --;
   }
   return (Counter);
}



int Calculate_Martingale(int Direc , int sym)
{
   int Counter=0;
   int Looper = PositionsTotal();
   while(Looper>0 &&  Counter < 10)   
   { 
         if(posInfo.SelectByIndex(Looper-1))
         {
            if(PositionGetInteger(POSITION_MAGIC)==MagicNumber[sym]) 
            {
                  if(  (posInfo.PositionType()==POSITION_TYPE_BUY && Direc == 1) ||   (posInfo.PositionType()==POSITION_TYPE_SELL && Direc == -1)  ) 
                     {
                          Counter ++;    // if ( PositionGetDouble(POSITION_PROFIT)<0 )  Counter ++;  -> the grey one - only for trades in negative profit
                     } 
            }
        }
      Looper --;
   }
         PrintMessage(sym , "martinglae calc: " ,("Counter for martinglae is " + string(Counter)) );
   return (Counter);
}


bool check_is_buy (int sym)
{  
   if (!ConfirmIsBuy(sym))            return false;
   if (!PassedFiltersGeneral(sym))    return false;
   if (!PassedFiltersBuy(sym))        return false;
   if (UseRaw)                        return true ;
  // if (UseMarketStructureTrend)    return MarketStructureTrend_check_is_buy(Main_TF_N , sym) ;
   //if (UseMarketStructureSideways) return MarketStructureSideways_check_is_buy(Main_TF_N , sym) ; 
   if (UseSpecial)                 return Special_check_is_buy(Main_TF_N , sym) ;      
   if (UseSR)                      return SR_check_is_buy(Main_TF_N , sym) ;
   if (UseBreakOut)                return Breakout_check_is_buy(Main_TF_N , sym) ; 
   if (UseFakeOut)                 return Fakeout_check_is_buy(Main_TF_N , sym) ;      
   if (UseTrend)                   return Trend_check_is_buy(Main_TF_N , sym) ;  
   if (UseTrendBreakOut)           return TrendBreakOut_check_is_buy(Main_TF_N , sym) ; 
   if (UseDouble)                  return Double_check_is_buy(Main_TF_N , sym) ;
   if (UseMACross)                 return MA_check_is_buy(sym) ;  
   if (UseRSIDiv)                  return RSI_DIV_check_is_buy(sym) ;     
   if (UseRSIDivHide)              return RSI_DIVHide_check_is_buy(sym) ;     
   if (UseRSIOver)                 return RSI_Over_check_is_buy(sym) ;    
   if (UseRSIWith)                 return RSI_With_check_is_buy(sym) ;  
   if (UseMFIDiv)                  return MFI_DIV_check_is_buy(sym) ;     
   if (UseMFIDivHide)              return MFI_DIVHide_check_is_buy(sym) ; 
   if (UseMFIOver)                 return MFI_Over_check_is_buy(sym) ;    
   if (UseMFIWith)                 return MFI_With_check_is_buy(sym) ;      
   if (UseBBWith)                  return BB_With_check_is_buy(sym) ;
   if (UseBBReturn)                return BB_Ret_check_is_buy(sym) ; 
   if (UseGRRatio)                 return GR_check_is_buy(sym) ;
   if (UseKAMACross)               return KAMA_check_is_buy(sym) ;          

   return false;
}    


bool check_is_sell (int sym)
{ 
   if (!ConfirmIsSell(sym))          return false;
   if (!PassedFiltersGeneral(sym))   return false;
   if (!PassedFiltersSell(sym))      return false;
   if (UseRaw)                       return true ;

   //if (UseMarketStructureTrend)   return MarketStructureTrend_check_is_sell(Main_TF_N , sym) ;
 //  if (UseMarketStructureSideways)return MarketStructureSideways_check_is_sell(Main_TF_N , sym) ;  
   if (UseSpecial)                return Special_check_is_sell(Main_TF_N , sym) ;   
   if (UseSR)                     return SR_check_is_sell(Main_TF_N , sym) ;
   if (UseBreakOut)               return Breakout_check_is_sell(Main_TF_N , sym) ;   
   if (UseFakeOut)                return Fakeout_check_is_sell(Main_TF_N , sym) ;  
   if (UseTrend)                  return Trend_check_is_sell(Main_TF_N , sym) ;     
   if (UseTrendBreakOut)          return TrendBreakOut_check_is_sell(Main_TF_N , sym) ;   
   if (UseDouble)                 return Double_check_is_sell(Main_TF_N , sym) ;    
   if (UseMACross)                return MA_check_is_sell(sym) ; 
   if (UseRSIDiv)                 return RSI_DIV_check_is_sell(sym) ;    
   if (UseRSIDivHide)             return RSI_DIVHide_check_is_sell(sym) ;    
   if (UseRSIOver)                return RSI_Over_check_is_sell(sym) ;    
   if (UseRSIWith)                return RSI_With_check_is_sell(sym) ;  
   if (UseMFIDiv)                 return MFI_DIV_check_is_sell(sym) ;
   if (UseMFIDivHide)             return MFI_DIVHide_check_is_sell(sym) ;         
   if (UseMFIOver)                return MFI_Over_check_is_sell(sym) ;    
   if (UseMFIWith)                return MFI_With_check_is_sell(sym) ;      
   if (UseBBWith)                 return BB_With_check_is_sell(sym) ; 
   if (UseBBReturn)               return BB_Ret_check_is_sell(sym) ; 
   if (UseGRRatio)                return GR_check_is_sell(sym) ;
   if (UseKAMACross)              return KAMA_check_is_sell(sym) ;    
   
   return(false);
}        


int PlaceBuyOrder(int sym) // new
   {
      trade.SetExpertMagicNumber(MagicNumber[sym]);
      symInfo.Name(SymbolArray[sym]);
      CurrentRiskPerTrade = UserRisk     ;
      if(DoubleUpMartingale > 1)  CurrentRiskPerTrade = CurrentRiskPerTrade*MathPow(DoubleUpMartingale , Count_consecutive_losses(sym));
      if(Martingale > 1)          CurrentRiskPerTrade = CurrentRiskPerTrade*MathPow(Martingale , Calculate_Martingale(1, sym));
      Order_size = CalculateLotSize(StopLoss, sym);
      Order_size = MathMax(Order_size , 0.01);
      if (UseFixedOS) Order_size = NormalizeDouble(CurrentRiskPerTrade * AccountInfoDouble(ACCOUNT_BALANCE) / (100000 ) , 2);
      
      CalcBuyData(sym);
      
      if     (TradeMethod ==1 )   OrderPrint(sym , "buy market: " );
      else OrderPrint(sym , "buy limit: "  , 
                      ( "TradeMethod: " + string(TradeMethod) + " ,Expiration time : " +
                       TimeToString(TimeCurrent(dt_struct) + PendingOrdersExpirationBars) + string(PeriodSeconds(Main_TF)) )     );
         
               
         positionOpen=false;
         int i=0;
         do
         {
             if (i>=1) 
             {
                Sleep(25);
                if (i==2)  Sleep(100);
                if (i==3)  Sleep(500);
                CalcBuyData(sym); 
             }
             FillBuyData(sym);
             if(OrderSend(myrequest,myresult))
             {
               positionOpen=true;
               OrderPrint(sym, "Buy Order done");
             }
             else  OrderPrint(sym , "Buy OrderSend failed" ,  ("error: " + string(GetLastError()) ));
              i=i+1;
          }
          while(!positionOpen && i<4);
      return myticket;
   }
 

int PlaceSellOrder(int sym)
   {
      trade.SetExpertMagicNumber(MagicNumber[sym]);
      symInfo.Name(SymbolArray[sym]);
      CurrentRiskPerTrade = UserRisk     ;
      if(DoubleUpMartingale > 1)  CurrentRiskPerTrade = CurrentRiskPerTrade*MathPow(DoubleUpMartingale , Count_consecutive_losses(sym));
      if(Martingale > 1) CurrentRiskPerTrade = CurrentRiskPerTrade*MathPow(Martingale , Calculate_Martingale(-1 , sym));
      
      Order_size = CalculateLotSize (StopLoss, sym);      // create sell order
      Order_size = MathMax(Order_size , 0.01);
      if (UseFixedOS) Order_size = NormalizeDouble(CurrentRiskPerTrade * AccountInfoDouble(ACCOUNT_BALANCE) / (100000 ) , 2);      
      
      CalcSellData(sym);
      
      if     (TradeMethod ==1 )  OrderPrint(sym , "sell market: " );
      else  OrderPrint(sym , "buy limit: "  , 
                      ( "TradeMethod: " + string(TradeMethod) + " ,Expiration time : " +
                       TimeToString(TimeCurrent(dt_struct) + PendingOrdersExpirationBars) + string(PeriodSeconds(Main_TF)) )     );     
 
         positionOpen=false;
         int i=0;
         do
         {
             if (i>=1) 
             {
                Sleep(25);
                if (i==2)  Sleep(100);
                if (i==3)  Sleep(500);
                CalcSellData(sym); 
             }
             FillSellData(sym);
             if(OrderSend(myrequest,myresult))
             {
               positionOpen=true;
               OrderPrint(sym, "Sell Order done");
             }
              else  OrderPrint(sym , "Sell OrderSend failed" ,  ("error: " + string(GetLastError()) ));
              i=i+1;
          }
          while(!positionOpen && i<4);
      return myticket;
   }

void CalcBuyData(int sym)
{
      symInfo.Refresh();
      if     (TradeMethod ==1 ) EnterPrice = SymbolInfoDouble(SymbolArray[sym],SYMBOL_ASK);
      else if(TradeMethod ==2 ) 
      {
         if (UseSR   || UseFakeOut  )   EnterPrice = LowerSR[sym]            - PendingOrdersATRSlack * ATRBuffer[sym].b[1];
         else if (UseBreakOut)               EnterPrice = PrevUpperSRLevel[sym]   - PendingOrdersATRSlack * ATRBuffer[sym].b[1];
         else if (UseDouble  )               EnterPrice = DoubleUpPrice[sym]      - PendingOrdersATRSlack * ATRBuffer[sym].b[1];                
         else if (UseTrend)            EnterPrice = CalcTrendValue(UpTrend[sym].LineSlope   , UpTrend[sym].LineStart   , UpTrend[sym].LineFirstBar)                     - PendingOrdersATRSlack * ATRBuffer[sym].b[1];
         else if (UseTrendBreakOut)    EnterPrice = CalcTrendValue(PrevDownTrend[sym].LineSlope   , PrevDownTrend[sym].LineStart   , PrevDownTrend[sym].LineFirstBar)   - PendingOrdersATRSlack * ATRBuffer[sym].b[1]; 
         else     EnterPrice = SymbolInfoDouble(SymbolArray[sym],SYMBOL_ASK)          - PendingOrdersATRSlack * ATRBuffer[sym].b[1];     

         //PrintMessage(sym, "buy limit order price calculation: ", ("PendingOrdersATRSlack is: " + PendingOrdersATRSlack + " ,ATRBuffer is: " + ATRBuffer[sym].b[1]));
         DeleteOldPosition(ORDER_TYPE_BUY_LIMIT , sym);
      }   
      
      else // Trade method == 3 || 4 
      {
         if (UseSpecial)                      EnterPrice = CalcSpecialBuyStopOrder(sym);
         else if  (UseSR    || UseFakeOut  )  EnterPrice = UpperSR[sym]              + PendingOrdersATRSlack * ATRBuffer[sym].b[1] ;
         else if (UseBreakOut)                EnterPrice = PrevUpperSRLevel[sym]     + PendingOrdersATRSlack * ATRBuffer[sym].b[1];
         else if (UseDouble  )                EnterPrice = DoubleDownPrice[sym]      + PendingOrdersATRSlack * ATRBuffer[sym].b[1];  
         else if (UseTrend)            EnterPrice = CalcTrendValue(DownTrend[sym].LineSlope   , DownTrend[sym].LineStart   , DownTrend[sym].LineFirstBar)               + PendingOrdersATRSlack * ATRBuffer[sym].b[1];   
         else if (UseTrendBreakOut)    EnterPrice = CalcTrendValue(PrevDownTrend[sym].LineSlope   , PrevDownTrend[sym].LineStart   , PrevDownTrend[sym].LineFirstBar)   + PendingOrdersATRSlack * ATRBuffer[sym].b[1];
         else     EnterPrice = SymbolInfoDouble(SymbolArray[sym],SYMBOL_ASK)             + PendingOrdersATRSlack * ATRBuffer[sym].b[1];   
                        
         if(TradeMethod ==3)       DeleteOldPosition(ORDER_TYPE_BUY_STOP , sym);
         else if(TradeMethod ==4 ) DeleteOldPosition(ORDER_TYPE_BUY_STOP_LIMIT , sym);
      }   
               
      Default_SL = Default_SL_ATR * ATRBuffer[sym].b[1];
      if (UseCandlesSL)
      {
          Calculate_CandlesSL (0 , EnterPrice , sym) ;
          StopLoss = MathMin(StopLoss , Default_SL);
      }
      else StopLoss = Default_SL;
      
      if (UseFixedSL)   StopLoss = MathMin(StopLoss , SL_FixedSL ) ; 
      if (UseSRSL)      StopLoss = MathMin(StopLoss ,Calculate_SR_Long_SL     (ReturnTFIndex(Main_TF), EnterPrice, sym)) ;
      if (UseTrendSL)   StopLoss = MathMin(StopLoss ,Calculate_Trend_Long_SL  (ReturnTFIndex(Main_TF), EnterPrice, sym)) ;
      if (UseSpecialSL) StopLoss = MathMin(StopLoss ,CalcSpecialBuySL(sym) ) ;   // the sell enter price is the buy SL
      
       TakeProfit = 0;
       if (UseTP)
       {
          if (UseSpecialTP)   TakeProfit =  MathMax(TakeProfit , CalcSpecialBuyTP(sym));
          if (UseATRTP)       TakeProfit =  ATRTP_ratio * ATRBuffer[sym].b[1];
          if (UseRRTP)        TakeProfit =  MathMax(TakeProfit , RR_TP_Ratio * StopLoss);
          if (TradeMethod<2)
          {
             if (UseSRTP)    TakeProfit=  MathMax(TakeProfit ,Calculate_SR_Long_TP  (ReturnTFIndex(Main_TF), EnterPrice, sym));
          }
          else if (TradeMethod==3)
          {
             if (UseSRTP)    TakeProfit=  MathMax(TakeProfit ,Calculate_SR_Short_TP  (ReturnTFIndex(Main_TF), EnterPrice, sym));            
          }
       }   
        
      SLPrice = EnterPrice - StopLoss  ;
      TPPrice = EnterPrice + TakeProfit  ;
}


void CalcSellData(int sym)
{
      symInfo.Refresh();
      if     (TradeMethod ==1 ) EnterPrice = SymbolInfoDouble(SymbolArray[sym],SYMBOL_BID);
      else if(TradeMethod ==2 ) 
      {
         if      (UseSR   || UseFakeOut  )   EnterPrice = UpperSR[sym]            + PendingOrdersATRSlack * ATRBuffer[sym].b[1];
         else if (UseBreakOut)               EnterPrice = PrevLowerSRLevel[sym]   + PendingOrdersATRSlack * ATRBuffer[sym].b[1];   
         else if (UseDouble  )               EnterPrice = DoubleDownPrice[sym]    + PendingOrdersATRSlack * ATRBuffer[sym].b[1];               
         else if (UseTrend)            EnterPrice = CalcTrendValue(DownTrend[sym].LineSlope   , DownTrend[sym].LineStart   , DownTrend[sym].LineFirstBar)         + PendingOrdersATRSlack * ATRBuffer[sym].b[1];
         else if (UseTrendBreakOut)    EnterPrice = CalcTrendValue(PrevUpTrend[sym].LineSlope   , PrevUpTrend[sym].LineStart   , PrevUpTrend[sym].LineFirstBar)   + PendingOrdersATRSlack * ATRBuffer[sym].b[1];
         else    EnterPrice = SymbolInfoDouble(SymbolArray[sym],SYMBOL_BID)  + PendingOrdersATRSlack * ATRBuffer[sym].b[1]; 
         
         //PrintMessage(sym, "sell limit order price calculation: ", ("PendingOrdersATRSlack is: " + PendingOrdersATRSlack + " ,ATRBuffer is: " + ATRBuffer[sym].b[1]));
         DeleteOldPosition(ORDER_TYPE_SELL_LIMIT , sym);
      }   
      else // Trade method == 3 || 4
      {
         if (UseSpecial)                     EnterPrice = CalcSpecialSellStopOrder(sym);
         else if (UseSR   || UseFakeOut  )   EnterPrice = LowerSR[sym]            - PendingOrdersATRSlack * ATRBuffer[sym].b[1] ;
         else if (UseBreakOut)               EnterPrice = PrevLowerSRLevel[sym]   - PendingOrdersATRSlack * ATRBuffer[sym].b[1];
         else if (UseDouble  )               EnterPrice = DoubleUpPrice[sym]      - PendingOrdersATRSlack * ATRBuffer[sym].b[1];           
         else if (UseTrend)            EnterPrice = CalcTrendValue(UpTrend[sym].LineSlope   , UpTrend[sym].LineStart   , UpTrend[sym].LineFirstBar)               - PendingOrdersATRSlack * ATRBuffer[sym].b[1];  
         else if (UseTrendBreakOut)    EnterPrice = CalcTrendValue(PrevUpTrend[sym].LineSlope   , PrevUpTrend[sym].LineStart   , PrevUpTrend[sym].LineFirstBar)   - PendingOrdersATRSlack * ATRBuffer[sym].b[1]; 
         
         else    EnterPrice = SymbolInfoDouble(SymbolArray[sym],SYMBOL_BID)  - PendingOrdersATRSlack * ATRBuffer[sym].b[1];     
                    
         if(TradeMethod ==3 )      DeleteOldPosition(ORDER_TYPE_SELL_STOP , sym);
         else if(TradeMethod ==4 ) DeleteOldPosition(ORDER_TYPE_SELL_STOP_LIMIT, sym);
      }    
      
      Default_SL = Default_SL_ATR * ATRBuffer[sym].b[1];
      if (UseCandlesSL)
      {
          Calculate_CandlesSL (-1 , EnterPrice , sym) ;
          StopLoss = MathMin(StopLoss , Default_SL);
      }
      else StopLoss = Default_SL;
      
      if (UseFixedSL)    StopLoss = MathMin(StopLoss , SL_FixedSL ) ; 
      if (UseSRSL)       StopLoss = MathMin(StopLoss ,Calculate_SR_Short_SL(ReturnTFIndex(Main_TF), EnterPrice, sym))  ;
      if (UseTrendSL)    StopLoss = MathMin(StopLoss ,Calculate_Trend_Short_SL  (ReturnTFIndex(Main_TF), EnterPrice, sym)) ;
      if (UseSpecialSL)  StopLoss = MathMin(StopLoss ,CalcSpecialSellSL(sym)) ;   // the buy enter price is the sell SL

       TakeProfit = 0;
       if (UseTP)
       {
          if (UseATRTP)       TakeProfit =  ATRTP_ratio * ATRBuffer[sym].b[1];
          if (UseRRTP)        TakeProfit =  MathMax(TakeProfit , RR_TP_Ratio * StopLoss);
          if (UseSpecialTP)   TakeProfit =  MathMax(TakeProfit , CalcSpecialSellTP(sym));
          if (TradeMethod<2)
          {
             if (UseSRTP)    TakeProfit=  MathMax(TakeProfit ,Calculate_SR_Short_TP  (ReturnTFIndex(Main_TF), EnterPrice, sym));
          }
          else if (TradeMethod==3)
          {
             if (UseSRTP)    TakeProfit=  MathMax(TakeProfit ,Calculate_SR_Long_TP  (ReturnTFIndex(Main_TF), EnterPrice, sym));              
          }
       }   

      SLPrice = EnterPrice + StopLoss ;
      TPPrice = EnterPrice - TakeProfit;


}



void FillBuyData(int sym)
{
         string comment;
         ZeroMemory(myrequest);
         switch (TradeMethod)
         {
            case 1:
               myrequest.action=TRADE_ACTION_DEAL;
               myrequest.type=ORDER_TYPE_BUY;
               break;
            case 2:
               myrequest.action=TRADE_ACTION_PENDING;
               myrequest.type=ORDER_TYPE_BUY_LIMIT;
               myrequest.type_time = ORDER_TIME_SPECIFIED;
               myrequest.expiration = TimeCurrent(dt_struct) + PendingOrdersExpirationBars * PeriodSeconds(Main_TF);
               break;
            
           case 3:
               myrequest.action=TRADE_ACTION_PENDING;
               myrequest.type=ORDER_TYPE_BUY_STOP;
               myrequest.type_time = ORDER_TIME_SPECIFIED;
               myrequest.expiration = TimeCurrent(dt_struct) + PendingOrdersExpirationBars * PeriodSeconds(Main_TF);
               break;
               
           case 4:
               myrequest.action=TRADE_ACTION_PENDING;
               myrequest.type=ORDER_TYPE_BUY_STOP_LIMIT;
               myrequest.type_time = ORDER_TIME_SPECIFIED;
               myrequest.expiration = TimeCurrent(dt_struct) + PendingOrdersExpirationBars * PeriodSeconds(Main_TF);
          //     if (UseMarketStructureTrend)            myrequest.stoplimit = LowerSR            - StopLimitOrdersATRSlack * ATRBuffer[sym].b[1] ;
          //     else if (UseMarketStructureSideways)    myrequest.stoplimit = LowerSR_D          - StopLimitOrdersATRSlack * ATRBuffer[sym].b[1] ; 
                    if (UseSR   || UseFakeOut  )  myrequest.stoplimit = UpperSR[sym] +            StopLimitOrdersATRSlack *ATRBuffer[sym].b[1] ;
               else if (UseBreakOut)              myrequest.stoplimit = PrevUpperSRLevel[sym] +   StopLimitOrdersATRSlack *ATRBuffer[sym].b[1] ;
               else if (UseDouble)                myrequest.stoplimit = DoubleDownPrice[sym]    + StopLimitOrdersATRSlack *ATRBuffer[sym].b[1] ;             
               else if (UseTrend)    myrequest.stoplimit = CalcTrendValue(UpTrend[sym].LineSlope   , UpTrend[sym].LineStart , UpTrend[sym].LineFirstBar)     +  StopLimitOrdersATRSlack *ATRBuffer[sym].b[1] ;
               else if (UseTrendBreakOut)    myrequest.stoplimit = CalcTrendValue(PrevDownTrend[sym].LineSlope   , PrevDownTrend[sym].LineStart , PrevDownTrend[sym].LineFirstBar)     +  StopLimitOrdersATRSlack *ATRBuffer[sym].b[1] ;
               else     myrequest.stoplimit =  SymbolInfoDouble(SymbolArray[sym],SYMBOL_ASK)  +StopLimitOrdersATRSlack *ATRBuffer[sym].b[1] ;
               break;
         }
         myrequest.symbol = SymbolArray[sym];
         myrequest.volume = Order_size;
         myrequest.type_filling=ORDER_FILLING_FOK;
         myrequest.price=EnterPrice;
         if(UseTP && TakeProfit >0) myrequest.tp = TPPrice;
         else myrequest.tp = NULL;
         myrequest.sl = SLPrice;
         myrequest.deviation=10;
         myrequest.magic=MagicNumber[sym];
         StringConcatenate(comment , "rev: " , rev , "magic: " , MagicNumber[sym] ,   " ,Order type: " , myrequest.type);
         myrequest.comment = comment;
}


void FillSellData(int sym)
{
         string comment;
         
         ZeroMemory(myrequest);
         switch (TradeMethod)
         {
            case 1:
               myrequest.action=TRADE_ACTION_DEAL;
               myrequest.type=ORDER_TYPE_SELL;
               break;
            case 2:
               myrequest.action=TRADE_ACTION_PENDING;
               myrequest.type=ORDER_TYPE_SELL_LIMIT;
               myrequest.type_time = ORDER_TIME_SPECIFIED;
               myrequest.expiration = TimeCurrent(dt_struct) + PendingOrdersExpirationBars * PeriodSeconds(Main_TF);
               break;
            
           case 3:
               myrequest.action=TRADE_ACTION_PENDING;
               myrequest.type=ORDER_TYPE_SELL_STOP;
               myrequest.type_time = ORDER_TIME_SPECIFIED;
               myrequest.expiration = TimeCurrent(dt_struct) + PendingOrdersExpirationBars * PeriodSeconds(Main_TF);
               break;
               
           case 4:
               myrequest.action=TRADE_ACTION_PENDING;
               myrequest.type=ORDER_TYPE_SELL_STOP_LIMIT;
               myrequest.type_time = ORDER_TIME_SPECIFIED;
               myrequest.expiration = TimeCurrent(dt_struct) + PendingOrdersExpirationBars * PeriodSeconds(Main_TF);
   //            if (UseMarketStructureTrend)            myrequest.stoplimit = LowerSR            - StopLimitOrdersATRSlack * ATRBuffer[sym].b[1] ;
   //            else if (UseMarketStructureSideways)    myrequest.stoplimit = LowerSR_D          - StopLimitOrdersATRSlack * ATRBuffer[sym].b[1] ;               
                    if (UseSR   || UseFakeOut  )  myrequest.stoplimit = LowerSR[sym]            - StopLimitOrdersATRSlack * ATRBuffer[sym].b[1] ;
               else if (UseBreakOut)              myrequest.stoplimit = PrevLowerSRLevel[sym]   - StopLimitOrdersATRSlack * ATRBuffer[sym].b[1] ;
               else if (UseDouble)                myrequest.stoplimit = DoubleUpPrice[sym]      - StopLimitOrdersATRSlack * ATRBuffer[sym].b[1] ;                 
               else if (UseTrend)    myrequest.stoplimit = CalcTrendValue(DownTrend[sym].LineSlope  , DownTrend[sym].LineStart  ,   DownTrend[sym].LineFirstBar)   - StopLimitOrdersATRSlack *ATRBuffer[sym].b[1] ;
               else if (UseTrendBreakOut)    myrequest.stoplimit = CalcTrendValue(PrevUpTrend[sym].LineSlope   , PrevUpTrend[sym].LineStart , PrevUpTrend[sym].LineFirstBar)     -  StopLimitOrdersATRSlack *ATRBuffer[sym].b[1] ;
               else     myrequest.stoplimit =  SymbolInfoDouble(SymbolArray[sym],SYMBOL_BID)  - StopLimitOrdersATRSlack *ATRBuffer[sym].b[1] ;
               break;
         }
         myrequest.symbol = SymbolArray[sym];
         myrequest.volume = Order_size;
         myrequest.type_filling=ORDER_FILLING_FOK;
         myrequest.price=EnterPrice;
         if(UseTP && TakeProfit >0) myrequest.tp = TPPrice;
         else myrequest.tp = NULL;
         myrequest.sl = SLPrice;
         myrequest.deviation=10;
         myrequest.magic=MagicNumber[sym];
         StringConcatenate(comment , "rev: " , rev , "magic: " , MagicNumber[sym] ,   " ,Order type: " , myrequest.type);
         myrequest.comment = comment;
}


bool ConfirmIsBuy(int sym)
{
   int j=0;
   int Tempi = Main_TF_N;
   for (int i=0 ; i<2 ; i++)
   {

      if(i==1) Tempi = Secondary_TF_N;
      j=0;
      if (ConfirmEnterMatrix[i][j] >0)
         if (!CheckCandlePattern(Tempi , ConfirmEnterMatrix[i][j] , sym))
            return false;
      j++;
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!HHHCLLL_C(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (HHHCLLL_C(1, Tempi, sym))
            return false;  
      j++;
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!Engulf(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (Engulf(1, Tempi, sym))
            return false;  
      j++;      
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!Is_Marbouzo(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (Is_Marbouzo(1, Tempi, sym))
            return false;  
      j++;
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!Out(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (Out(1, Tempi, sym))
            return false;  
      j++;
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!InBar(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (InBar(1, Tempi, sym))
            return false;  
      j++;
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!Ham(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (Ham(1, Tempi, sym))
            return false;  
      j++; 
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!InvHam(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (InvHam(1, Tempi, sym))
            return false;  
      j++;    
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!KangoroTail(Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (KangoroTail(Tempi, sym))
            return false;  
      j++; 
      
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!LongtPartialKangoro(Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (LongtPartialKangoro(Tempi, sym))
            return false;  
      j++;    
      if (ConfirmEnterMatrix[i][j] >0)
         if (CountGreenCandles(1 , Tempi, sym) < ConfirmEnterMatrix[i][j] )
            return false;
      if (ConfirmEnterMatrix[i][j] <0)
         if(CountGreenCandles(1 , Tempi, sym) >= (-1)*ConfirmEnterMatrix[i][j] )
            return false;  
      j++; 
      if (ConfirmEnterMatrix[i][j] >0)
         if (CountRedCandles(1 , Tempi, sym) < ConfirmEnterMatrix[i][j] )
            return false;
      if (ConfirmEnterMatrix[i][j] <0)
         if(CountRedCandles(1 , Tempi, sym) >= (-1)*ConfirmEnterMatrix[i][j] )
            return false;  
      j++;     
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!InsideBreakout_check_is_buy(Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (InsideBreakout_check_is_buy(Tempi, sym))
            return false;                                
   }
   return true;
}


bool ConfirmIsSell(int sym)
{
   int j=0;
   int Tempi = Main_TF_N;
   for (int i=0 ; i<2 ; i++)
   {
      if(i==1) Tempi = Secondary_TF_N;
      j=0;
      if (ConfirmEnterMatrix[i][j] >0)
         if (!CheckCandlePattern(Tempi , 11-ConfirmEnterMatrix[i][j], sym))
            return false;
      j++;
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!HHHCLLL_C(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (HHHCLLL_C(1, Tempi, sym))
            return false;  
      j++;
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!Engulf(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (Engulf(1, Tempi, sym))
            return false;  
      j++;      
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!Is_Marbouzo(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (Is_Marbouzo(1, Tempi, sym))
            return false;  
      j++;
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!Out(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (Out(1, Tempi, sym))
            return false;  
      j++;
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!InBar(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (InBar(1, Tempi, sym))
            return false;  
      j++;
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!Ham(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (Ham(1, Tempi, sym))
            return false;  
      j++; 
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!InvHam(1, Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (InvHam(1, Tempi, sym))
            return false;  
      j++;    
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!KangoroTail(Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (KangoroTail(Tempi, sym))
            return false;  
      j++; 
      
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!ShortPartialKangoro(Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (ShortPartialKangoro(Tempi, sym))
            return false;  
      j++;    
      if (ConfirmEnterMatrix[i][j] >0)
         if (CountRedCandles(1 , Tempi, sym) < ConfirmEnterMatrix[i][j] )
            return false;
      if (ConfirmEnterMatrix[i][j] <0)
         if(CountRedCandles(1 , Tempi, sym) >= (-1)*ConfirmEnterMatrix[i][j] )
            return false;  
      j++; 
      if (ConfirmEnterMatrix[i][j] >0)
         if (CountGreenCandles(1 , Tempi, sym) < ConfirmEnterMatrix[i][j] )
            return false;
      if (ConfirmEnterMatrix[i][j] <0)
         if(CountGreenCandles(1 , Tempi, sym) >= (-1)*ConfirmEnterMatrix[i][j] )
            return false;  
      j++;    
      if (ConfirmEnterMatrix[i][j] ==1)
         if (!InsideBreakout_check_is_sell(Tempi, sym))
            return false;
      if (ConfirmEnterMatrix[i][j] ==2)
         if (InsideBreakout_check_is_sell(Tempi, sym))
            return false;                                
   }
   return true;
}



bool PassedFiltersGeneral(int sym)
{
      if (!((Mon && dt_struct.day_of_week == 1) || (Tue && dt_struct.day_of_week == 2) || (Wed && dt_struct.day_of_week == 3) || (Thur && dt_struct.day_of_week == 4) || (Fri && dt_struct.day_of_week == 5)) )  
            return false;                 
      TempTest =  (Candle_Size(1 , Main_TF_N , sym) / ATRBuffer[sym].b[1]);
      if (MaxMainPrevCandleSizeInATR  < TempTest)    return (false);        
      if (MinMainPrevCandleSizeInATR  > TempTest)    return (false);   
   
      //ATR
      if (ATRBuffer[sym].b[1]/ATRBuffer_Long[sym].b[1] > Max_MaintoLong_ATR)
             return (false);    
      if (ATRBuffer[sym].b[1]/ATRBuffer_Long[sym].b[1] < Min_MaintoLong_ATR)
             return (false);                                
      //BB
      if (!BB_Expending_Allowed)
         if(BB_Expanding(sym))
            return (false);  
       if (!BB_Contracting_Allowed)
         if(BB_Contracting(sym))
            return (false);  
      if (BB_Expending_Must)
         if(!BB_Expanding(sym))
            return (false);  
      if (BB_Contracting_Must)
         if(!BB_Contracting(sym))
            return (false);                                  

      if(MaxER_EnterLimit<1)         // condition to start testing  
         if(ER_R[sym]   > MaxER_EnterLimit)
            return (false);
      if(MinER_EnterLimit>0)         // condition to start testing        
         if(ER_R[sym]   < MinER_EnterLimit)
            return (false);
         
      return true;
}




bool PassedFiltersBuy(int sym)
{
      if(BarsWithTrendFilter)
         if(Open[Main_TF_N].a[sym].b[0] < Close[Main_TF_N].a[sym].b[BarsTrendXBars])
            return (false);   
            
      if(BarsAgainstTrendFilter)
         if(Open[Main_TF_N].a[sym].b[0] > Close[Main_TF_N].a[sym].b[BarsTrendXBars])
            return (false);       
      
      if(MaxSRFilter)
         if(UpperLimit[sym]>0)
            if(UpperLimit[sym] - Close[Main_TF_N].a[sym].b[1] < ATR_SlackForSRFilter * ATRBuffer[sym].b[1])
               return (false);
       if(Max_GR_R<2)         // condition to start testing   
         if(GR_R[sym]   > Max_GR_R)
            return (false);
        
      if(MAsAlighnFilter)
      {
         switch(MAsAlighnFilterValue)
        {
            case -1:
               if(MAsAlighn[sym] >-1) return false;
               break;
            case 0:
               if(MAsAlighn[sym] != 0) return false;
               break;
            case 1:
               if(MAsAlighn[sym] <1) return false;
               break;
        }
      }  
      if(MALongSlopeFilter)
            if(FastMABuffer[sym].b[1] < FastMABuffer[sym].b[2] )
               return (false);               
               
      if(LongMAConfirmFilter==1)
            if(Open[0].a[sym].b[0] < LongMABuffer[sym].b[1])
               return (false);          
      if(LongMAConfirmFilter==-1)
            if(Open[0].a[sym].b[0] > LongMABuffer[sym].b[1])
               return (false);                 

// RSI filters: 
      if(!RSI_OverBought_Allowed)
         if(rsiBuffer[sym].b[1]> 50 + RSIOverExtended)
            return false;
      if(!RSI_Positive_Not_OverBought_Allowed)
         if(rsiBuffer[sym].b[1] > 50)
            if (!RSI_OverBought_Allowed ||   rsiBuffer[sym].b[1] <  50 + RSIOverExtended)
               return false;
      if(!RSI_OverSold_Allowed)
         if(rsiBuffer[sym].b[1] < 50 - RSIOverExtended)
            return false;
      if(!RSI_Negative_Not_OverSold_Allowed)
         if(rsiBuffer[sym].b[1] < 50)
            if (!RSI_OverSold_Allowed ||   rsiBuffer[sym].b[1] >  50 - RSIOverExtended)
               return false;

// MFI filters: 
      if(!MFI_OverBought_Allowed)
         if(mfiBuffer[sym].b[1]> 50 + MFIOverExtended)
            return false;
      if(!MFI_Positive_Not_OverBought_Allowed)
         if(mfiBuffer[sym].b[1] > 50)
            if(!MFI_OverBought_Allowed || mfiBuffer[sym].b[1] < 50 + MFIOverExtended)
               return false;            
      if(!MFI_OverSold_Allowed)
         if(mfiBuffer[sym].b[1] < 50 - MFIOverExtended)
            return false;
      if(!MFI_Negative_Not_OverSold_Allowed)
         if(mfiBuffer[sym].b[1] < 50)
            if(!MFI_OverBought_Allowed || mfiBuffer[sym].b[1] > 50 - MFIOverExtended)
               return false;   
                          
       if(KAMAConfirmFilter)
            if(Open[0].a[sym].b[0] < KAMA[sym])
               return (false);               
  
                     
      return true;
}




bool PassedFiltersSell(int sym)
{
      if(BarsWithTrendFilter)
         if(Open[Main_TF_N].a[sym].b[0] > Close[Main_TF_N].a[sym].b[BarsTrendXBars])
            return (false);   
            
      if(BarsAgainstTrendFilter)
         if(Open[Main_TF_N].a[sym].b[0] < Close[Main_TF_N].a[sym].b[BarsTrendXBars])
            return (false);       
      
      if(MaxSRFilter)
         if(UpperLimit[sym]>0)
            if(Close[Main_TF_N].a[sym].b[1] - LowerLimit[sym]  < ATR_SlackForSRFilter * ATRBuffer[sym].b[1])
               return (false);
      if(Max_GR_R<2)    // condition to start testing      
         if(1/GR_R[sym]   > Max_GR_R)
            return (false); 
         
      if(MAsAlighnFilter)
      {
         switch(MAsAlighnFilterValue)
        {
            case -1:
               if(MAsAlighn[sym] <1) return false;
               break;
            case 0:
               if(MAsAlighn[sym] != 0) return false;
               break;
            case 1:
               if(MAsAlighn[sym] >-1) return false;
               break;
        }
      }
      
      if(MALongSlopeFilter)
            if(FastMABuffer[sym].b[1] > FastMABuffer[sym].b[2] )
               return (false);               
    

      if(LongMAConfirmFilter ==1)
            if(Open[0].a[sym].b[0] > LongMABuffer[sym].b[1])
               return (false);          
      if(LongMAConfirmFilter ==-1)
            if(Open[0].a[sym].b[0] < LongMABuffer[sym].b[1])
               return (false);   

// RSI filters: 
      if(!RSI_OverBought_Allowed)
         if(rsiBuffer[sym].b[1] < 50 - RSIOverExtended)
            return false;
      if(!RSI_Positive_Not_OverBought_Allowed)
         if(rsiBuffer[sym].b[1] < 50)
            if(!RSI_OverBought_Allowed || rsiBuffer[sym].b[1] > 50 - RSIOverExtended)
               return false;            
      if(!RSI_OverSold_Allowed)
         if(rsiBuffer[sym].b[1]> 50 + RSIOverExtended)
            return false;
      if(!RSI_Negative_Not_OverSold_Allowed)
         if(rsiBuffer[sym].b[1] > 50)
            if(!RSI_OverSold_Allowed || rsiBuffer[sym].b[1] < 50 + RSIOverExtended)
               return false;   

// MFI filters: 
      if(!MFI_OverBought_Allowed)
         if(mfiBuffer[sym].b[1] < 50 - MFIOverExtended)
            return false;
      if(!MFI_Positive_Not_OverBought_Allowed)
         if(mfiBuffer[sym].b[1] < 50)
            if(!MFI_OverBought_Allowed || mfiBuffer[sym].b[1] > 50 - MFIOverExtended)
               return false;            
      if(!MFI_OverSold_Allowed)
         if(mfiBuffer[sym].b[1]> 50 + MFIOverExtended)
            return false;
      if(!MFI_Negative_Not_OverSold_Allowed)
         if(mfiBuffer[sym].b[1] > 50)
            if(!MFI_OverSold_Allowed || mfiBuffer[sym].b[1] < 50 + MFIOverExtended)
               return false;   
              
       if(KAMAConfirmFilter)
            if(Open[0].a[sym].b[0] > KAMA[sym])
               return (false);               
     
      return true;
}




void DeleteOldPosition(ENUM_ORDER_TYPE OType , int sym ) 
{
         ulong Sticket = 0;
         int OT = OrdersTotal();
         while(OT>=0)  
         {
            if(orderInfo.SelectByIndex(OT))
               if(OrderGetInteger(ORDER_MAGIC)==MagicNumber[sym]) 
                     if ( OrderGetInteger(ORDER_TYPE)==OType ) 
                        if( OrderGetDouble(ORDER_PRICE_OPEN) == EnterPrice)
                           trade.OrderDelete(OrderGetInteger(ORDER_TICKET));
            OT--;
         }
}

void OrderPrint(int sym, string mainMSG , string additionalMSG = "")
{
    PrintMessage( sym , mainMSG , 
               ( "Order size: " + string(Order_size) + " ,Enter Price: " + string(EnterPrice) +  " ,SL:" + string(StopLoss) + " ,TP: " + string(TakeProfit) +
               " ,SLPrice:" + string(SLPrice) + " ,TPPrice is: " + string(TPPrice) + additionalMSG )   );   
}
