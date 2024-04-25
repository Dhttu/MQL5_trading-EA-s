//+------------------------------------------------------------------+
//|                                                  Master file.mq5 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\TerminalInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
#include <Expert\Money\MoneyFixedRisk.mqh>

MqlDateTime dt_struct;
CTrade trade;
CAccountInfo accInfo;
CPositionInfo posInfo;
CSymbolInfo symInfo;
MqlTradeRequest request;
MqlTradeResult result;
int history=1000;
int PT = 0; // Poistions Total


input const ulong MagicNumber = 123456;
input double RR_ratio = 2;



//--- price buffers
double Close[], Open[], High[] , Low[];


input int FirstTradingHour = 2;
input int LastTradingHour = 22; 


int TradingMinutes = 00; // not in use
input int WaitXCandlesBeforeExit = 1;
datetime ThreshHold = 0, TimeNow = 0;
int slipege = 10;
double pip = 0;
bool MainRun = false;
bool positionOpen=false;



input bool UseRR = false; 
// RR will overide SL and TP - only relevent for: range, double, trend, last candles SL
input bool UseTP = true;
//TP can be false if usuing exit strategy
input bool UseTrailingSL = false;


//main strategy
input bool UseMA = true;
input bool UsePatterns = false; 
input bool UseHA = false; 
input bool UseSR = false; 
input bool UseBreakOut = false; 
input bool UseRange = false; 
input bool UseDouble = false; 
input bool UseBB = false;



// following only relevent for strategies combination and confirmation - need to make sure that in use in all subfunctions in strategies functions
input bool ConfirmWithMA = false;
input bool ConfirmWithHA = false;
input bool ConfirmWithPattern = false;
input bool ConfirmWithFIB = false;
input bool ConfirmWithRSI = false;
input bool ConfirmWithBB = false;
bool ConfirmWithMACD = false; // not in use
//cinfirm with BB - dont buy low and sell high

// following only relevent for managing trades using strategy
input bool UseMAExit = false;
input bool UseSRExit = false;
input bool UseBreakOutExit = false;
input bool UseBBExit = false;
input bool UseDoubleExit = false;
input bool UseRangExit = false; 
input bool UseTrailingExit = false;

bool UseMACDExit = false;//not in use


datetime EndOfTest,StartOfTest; 

/*
#include <Open Orders include.mqh>
#include <Manage Open Trades include.mqh>
#include <HA include.mqh>
#include <MA include.mqh>
#include <Range include.mqh>
#include <Double include.mqh>
#include <BB include.mqh>
#include <RSI include.mqh>
#include <FIB include.mqh>
#include <Pattern include.mqh>
#include <Close SL include.mqh>
*/

//+------------------------------------------------------------------+
//| Open Orders Include varibales                         |
//+------------------------------------------------------------------+

input int PipsInPreviousCandlesExclude=30;
input int AmountPreviousCandlesExclude=1;

 //% of balance to risk in one tradeblinking 
input double MaxRiskPerTrade=1;
input double UserStopLoss=50;
input double Trail=50; 
double TrailStart=50; //not in use
input double UserTakeProfit=100; 

double StopLoss=0;
double TakeProfit=0; 


int ticket;
double Order_size = 0;

//+------------------------------------------------------------------+
//| Manage Open Trades & Open Orders Include varibales                         |
//+------------------------------------------------------------------+

double HighestTrail;
double LowestTrail; 
input int CandlesForTrailing=10;
input int PipsBufferForTrailing=5;

//+------------------------------------------------------------------+
//| HA Include varibales                         |
//+------------------------------------------------------------------+

input double HA_wik_ratio = 2;
//max ratio of allowed wiks - trigger os sale / buy and close

double HA_High [16], HA_Low[16] , HA_Open[16], HA_Close[16];

//+------------------------------------------------------------------+
//| MA Include varibales                         |
//+------------------------------------------------------------------+

double  FastMABuffer[];
double  SlowMABuffer[];

int      FastMAHandle;
int      SlowMAHandle;

input int FastMA = 5;
input int SlowMA = 21;


//+------------------------------------------------------------------+
//| Range Include varibales                         |
//+------------------------------------------------------------------+

input double SlackForRange = 2;
input double SLSlackForRange = 7;
input double TPSlackForRange = 3;
input int PeriodForRange = 40;
input int TouchesForRange = 3;
input double ConfirmForBreakout = 1;
input int LastTouchOfSR = 3;

double CalculatedSLForBreakout = 0;
double CalculatedSLForSR = 0;

double CalculatedTPForRange = 0;
double CalculatedSLForRange = 0;
//need tocuhes on both sides

double HighestInRange;
double LowestInRange; 
int CountH = 0;//counter for the number of high touches
int CountL = 0;//counter for the number of low touches
int LastHigh = 100;
int LastLow = 100;




//+------------------------------------------------------------------+
//| Double Include varibales                         |
//+------------------------------------------------------------------+

input int SlackForDouble = 3;
input int PeriodForDouble = 20;
input int SLSlackForDouble = 10;
input int WaitBetweenCandlesDouble = 6;
double CalculatedSLFordouble = 0;


//+------------------------------------------------------------------+
//| BB Include varibales                         |
//+------------------------------------------------------------------+

double upperBandBuffer[];
double middleBandBuffer[];
double lowerBandBuffer[];
int bandHandle=0;



input int BBPeriod = 20;
input double BBDeviation = 2;

//+------------------------------------------------------------------+
//| RSI Include varibales                         |
//+------------------------------------------------------------------+

double rsiBuffer[];

int rsiHandle=0;

input int RSIPeriod = 14;
input int RSIOverExtended = 25;

//+------------------------------------------------------------------+
//| FIB Include varibales                         |
//+------------------------------------------------------------------+

input int PeriodForFIB = 20;

//+------------------------------------------------------------------+
//| Pattern Include varibales                         |
//+------------------------------------------------------------------+





/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//|Start of General functions:                         |
//+------------------------------------------------------------------+
********************************************************************************************************************************/


int OnInit()
{
   //For MA:
   ArraySetAsSeries(FastMABuffer,true);
   ArraySetAsSeries(SlowMABuffer,true);
   SlowMAHandle=iMA(_Symbol,_Period,SlowMA,0,MODE_EMA,PRICE_CLOSE);
   FastMAHandle=iMA(_Symbol,_Period,FastMA,0,MODE_EMA,PRICE_CLOSE);
 
   //for BB: 
   ArraySetAsSeries(upperBandBuffer,true);
   ArraySetAsSeries(lowerBandBuffer,true);
   ArraySetAsSeries(middleBandBuffer,true);
   bandHandle=iBands(_Symbol,_Period,BBPeriod,0,BBDeviation,PRICE_CLOSE);
   
   //for RSI:
   ArraySetAsSeries(rsiBuffer,true);
   rsiHandle =iRSI(_Symbol,_Period,RSIPeriod,PRICE_CLOSE);

   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);

   
   trade.SetExpertMagicNumber(MagicNumber);
   symInfo.Name(Symbol());
   symInfo.Refresh();
   pip=10*_Point;
   return(INIT_SUCCEEDED);  
 }

void OnDeinit(const int reason) { }



double OnTester()
{

    double Score=0;
    double Profit = TesterStatistics(STAT_PROFIT);
 //   double NorProfit = 365*Profit/ ((StartOfTest - EndOfTest)/86400) // 86400 to normalize for days, 365 to normnalize for 
    double SumOfTrades = TesterStatistics(STAT_TRADES);
    
    double s = int(StartOfTest);
    double e = int(EndOfTest);
    double temp = double((e - s)/(365*86400));
    if (temp == 0) temp = 1;
    if (temp > 8) temp = 5;
    double YearlyProfit = Profit / temp;
    double NormalYearlyProfit=0;
    
    double MaxDD = TesterStatistics(STAT_EQUITYDD_PERCENT);
    if(MaxDD == 0)  return(-1);
    

    
    double NormalSumOfTrades = MathSqrt(SumOfTrades)+0.01*MathPow(SumOfTrades, 2);
    if(YearlyProfit>0)  NormalYearlyProfit = 4*MathSqrt(YearlyProfit)+0.0007*MathPow(YearlyProfit, 2);
    else NormalYearlyProfit = -(MathPow(YearlyProfit, 2)*MathSqrt(NormalSumOfTrades));
    Score = MathSqrt(1+NormalSumOfTrades/100) * NormalYearlyProfit / (0.3*MathPow(MaxDD, 3)+MathSqrt(MaxDD)) ;
    if (YearlyProfit>0 && SumOfTrades <16) Score = Score / (18 - SumOfTrades);
    if (Score<0 ) Score = Score / 100;
    
    //final changes: to support more accurate best result
    if (Score<0 ) Score = Score * MathSqrt(TesterStatistics(STAT_EXPECTED_PAYOFF)) * MathLog10(TesterStatistics(STAT_PROFIT_FACTOR)) ;
    
    return(Score);

}


  

/* got it from udemy
double CalculateLotSize(double sl)//Calculate the size of the position size 
{
   double aBalance, aRiskMoney, aLotStep, aTickValue, aTickSize;
   

   aLotStep=SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP);
   aTickValue=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE);
   aTickSize=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
   
   int lotDigits=0;
   do
   {
      lotDigits++;
      aLotStep*=10;
   }while(aLotStep<1);
      
   aBalance=AccountInfoDouble(ACCOUNT_BALANCE);
   aRiskMoney=aBalance*(MaxRiskPerTrade/100);   
   double lot=aRiskMoney/(sl*(aTickValue/aTickSize)+1);  
   lot=NormalizeDouble(lot,lotDigits);

         
   return lot;
}
*/

double CalculateLotSize(double SL) //Calculate the size of the position size 
{         
   double nTickValue=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE); //We get the value of a tick
   Print ("AccountInfoDouble(ACCOUNT_BALANCE): " , AccountInfoDouble(ACCOUNT_BALANCE));
//   Print( "nTickValue is " ,  nTickValue) ;
      if (SL ==0)
      {
         Print ("StopLoss = 0");
         SL = 1;
      }
      if (nTickValue ==0)
      {
         Print ("nTickValue = 0");
         nTickValue = 0.00001;
      }
   double LotSize=(AccountInfoDouble(ACCOUNT_BALANCE)*MaxRiskPerTrade/100)/(SL*nTickValue);   //We apply the formula to calculate the position size and assign the value to the variable
//   Print( "LotSize is " , LotSize) ;
LotSize = NormalizeDouble(LotSize, 1);
   return LotSize/10;
}



bool isNewBar()
  {
   static long last_time=0;

   long lastbar_time=SeriesInfoInteger(_Symbol,_Period,SERIES_LASTBAR_DATE);

   if(last_time==0)
     {
      last_time=lastbar_time;
      return false;
     }

   if(last_time!=lastbar_time)
     {
      last_time=lastbar_time;
      return true;
     }
   return false;
  }


void OnTick()
  {
    
    static datetime StartOfTest = TimeCurrent(); 

    if(isNewBar())
    {
         MainRun = true;
         if(CopyClose(_Symbol,_Period,0,history,Close)<0) {PrintFormat("Error loading close price data, code %d",GetLastError()); return;}
         if(CopyOpen(_Symbol,_Period,0,history,Open)<0) {PrintFormat("Error loading open price data, code %d",GetLastError()); return;}
         if(CopyHigh(_Symbol,_Period,0,history,High)<0) {PrintFormat("Error loading high price data, code %d",GetLastError()); return;}
         if(CopyLow(_Symbol,_Period,0,history,Low)<0) {PrintFormat("Error loading low price data, code %d",GetLastError()); return;}
         
         //for MA
         
            if(CopyBuffer(FastMAHandle,0,0,history,FastMABuffer)<0) {PrintFormat("Error loading MA data for %s, code %d",_Symbol,GetLastError()); return;}
            if(CopyBuffer(SlowMAHandle,0,0,history,SlowMABuffer)<0) {PrintFormat("Error loading Long MA data for %s, code %d",_Symbol,GetLastError()); return;}
            
          //for BB
          
           if(CopyBuffer(bandHandle,1,0,history,upperBandBuffer)<0) {PrintFormat("Error loading upper band data, code %d", GetLastError()); return;}
           if(CopyBuffer(bandHandle,2,0,history,lowerBandBuffer)<0) {PrintFormat("Error loading lower band data, code %d",GetLastError()); return;}
           if(CopyBuffer(bandHandle,0,0,history,middleBandBuffer)<0) {PrintFormat("Error loading middle band data, code %d",GetLastError()); return;}
           
           //for RSI:
            if(CopyBuffer(rsiHandle,0,0,history,rsiBuffer)<0) {PrintFormat("Error loading rsi data, code %d",GetLastError()); return;}
            
            //for tester:
            EndOfTest = TimeCurrent();
    }
    if(posInfo.SelectByMagic(_Symbol , MagicNumber)) positionOpen=true;
    else positionOpen=false;

    if (positionOpen && MainRun )
    {         
            if(posInfo.SelectByMagic(_Symbol , MagicNumber)) 
                 {
                     TimeNow = TimeCurrent();
                     ThreshHold = TimeNow - 3600*WaitXCandlesBeforeExit ;//3600 seconds in an hour
                     if (ThreshHold > PositionGetInteger(POSITION_TIME)) manage_open_trade();
                 }

     }

          //check to open new trade - only run on new bar
    TimeCurrent(dt_struct);
    if (!positionOpen && MainRun && dt_struct.hour>= FirstTradingHour && dt_struct.hour <=LastTradingHour )
    {

              if (check_is_buy ()) PlaceBuyOrder();
              else if (check_is_sell() ) PlaceSellOrder();
      
     }


    MainRun = false;
    if (positionOpen) manage_SL();


  }



/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| Open Orders Include                         |
//+------------------------------------------------------------------+
********************************************************************************************************************************/


bool check_is_buy ()
{  
      if (PipsInPreviousCandlesExclude*pip  <  High[iHighest (NULL , 0 , MODE_HIGH , AmountPreviousCandlesExclude , 1)] - Low[iLowest(NULL , 0 , MODE_LOW , AmountPreviousCandlesExclude , 1)]) return (false);                    
      if(!confrim_is_buy ())   return (false); 
      if(UseMA)                return (MA_check_is_buy());
      if(UseHA)                return (HA_check_is_buy());
      if(UseRange)             return (Range_check_is_buy());
      if(UseDouble)            return (Double_check_is_buy());
      if(UseBreakOut)          return (Breakout_check_is_buy());
      if (UsePatterns)         return (Pattern_check_is_buy());
      if (UseSR)               return (SR_check_is_buy());
      if (UseBB)               return (BB_check_is_buy());      
   return(false);
   
}    


bool check_is_sell ()
{
   if (PipsInPreviousCandlesExclude*pip  <  High[iHighest (NULL , 0 , MODE_HIGH , AmountPreviousCandlesExclude , 1)] - Low[iLowest(NULL , 0 , MODE_LOW , AmountPreviousCandlesExclude , 1)]) return (false); 
   if(!confrim_is_sell ())    return (false); 
   if(UseMA )                 return (MA_check_is_sell());
   if(UseHA)                  return (HA_check_is_sell());
   if(UseRange)               return (Range_check_is_sell());
   if(UseDouble)              return (Double_check_is_sell());
   if(UseBreakOut)            return (Breakout_check_is_sell());
   if (UsePatterns)           return (Pattern_check_is_sell());
   if (UseSR)                 return (SR_check_is_sell());
   if(UseBB)                  return (BB_check_is_sell());
   return(false);

}               

/*******************************************************************************************************************************
 no need at the moment
********************************************************************************************************************************/
/*
int OpenOrdersThisPair(string pair)
{
   int total = 0;
   int PT = PositionsTotal();
   if (PT>0)
       for (i=PT-1;i>=0 ; i--)
       {
          if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
               if (OrderSymbol()==pair && OrderMagicNumber() == MagicNumber) total++;

       }
   return (total);
}
*/



bool confrim_is_buy ()
{
      if(!ConfirmWithMA || MA_confirm_is_buy())
         if(!ConfirmWithHA || HA_confirm_is_buy())
             if(!ConfirmWithBB || BB_confirm_is_buy())
                if(!ConfirmWithRSI || RSI_confirm_is_buy())
                   if(!ConfirmWithFIB || FIB_confirm_is_buy())
                       if(!ConfirmWithPattern || Pattern_confirm_is_buy())
                             return (true);
      return (false);
}


bool confrim_is_sell ()
{      
     if(!ConfirmWithMA || MA_confirm_is_sell())
        if(!ConfirmWithHA || HA_confirm_is_sell())

           if(!ConfirmWithBB || BB_confirm_is_sell())
               if(!ConfirmWithRSI || RSI_confirm_is_sell())
                   if(!ConfirmWithFIB || FIB_confirm_is_sell())
                       if(!ConfirmWithPattern || Pattern_confirm_is_sell())
                            return (true);
      return (false);
}



int PlaceBuyOrder()
   {
       StopLoss=UserStopLoss;
       TakeProfit=UserTakeProfit;      
       if(UseBreakOut)          StopLoss=CalculatedSLForBreakout;
       if(UseSR)                StopLoss=CalculatedSLForSR;
       
       /*
       if(UseSR)
       {
            Print( "use SR");
            Print("CalculatedSLForSR is: " , CalculatedSLForSR);
            Print(" SL before is: " , StopLoss);
            StopLoss=CalculatedSLForSR;
            Print(" SL after is: " , StopLoss);
       
       
       }
       
       
       */
       
       if(UseDouble)            StopLoss=CalculatedSLFordouble;
       if(UseRange)
       {
                                StopLoss=CalculatedSLForRange;
                                TakeProfit=CalculatedTPForRange;
       }
       
       if (UseTrailingSL) 
      {
            LowestTrail = Low[iLowest(NULL , 0 , MODE_LOW , CandlesForTrailing , 1)];
            StopLoss = ((SymbolInfoDouble(_Symbol,SYMBOL_ASK) - LowestTrail)/pip + PipsBufferForTrailing);
      
      }
      if (UseRR)          TakeProfit = StopLoss * RR_ratio;
      
      Order_size = CalculateLotSize (StopLoss);

//      Print( "lot size is:" , CalculateLotSize (StopLoss));
      // ???????????????????????????????????????????????????????????????????????????????????????????


      // update parameters for buy
          ZeroMemory(request);
         double price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         request.action=TRADE_ACTION_DEAL;
         request.type=ORDER_TYPE_BUY;
         request.symbol = _Symbol;
         request.volume = Order_size;
         request.type_filling=ORDER_FILLING_FOK;
         request.price=price;
         if(UseTP) request.tp = price + TakeProfit*pip;
         else request.tp = NULL;
         request.sl = price - StopLoss*pip;
         request.deviation=10;
         request.magic=MagicNumber;
      
          if(OrderSend(request,result))
           {
            Print("Long Order:",result.comment);
            positionOpen=true;
           }
         else
            Print("Long Fail",GetLastError());     

      return ticket;
   }
   


int PlaceSellOrder()//need to update per creteria of SL TP manage trade ext
   {
      StopLoss=UserStopLoss;
      TakeProfit=UserTakeProfit;        
      if(UseBreakOut)          StopLoss=CalculatedSLForBreakout;
      if(UseSR)                StopLoss=CalculatedSLForSR;
/*      
      if(  )
      {
            Print( "use SR");
            Print("CalculatedSLForSR is: " , CalculatedSLForSR);
            Print(" SL before is: " , StopLoss);
            StopLoss=CalculatedSLForSR;
            Print(" SL after is: " , StopLoss);
       
       
       }
   */    
       
      if(UseDouble)            StopLoss=CalculatedSLFordouble;
      if(UseRange)
      {
                                StopLoss=CalculatedSLForRange;
                                TakeProfit=CalculatedTPForRange;
      }
      
      if (UseTrailingSL) 
      {
            HighestTrail = High[iHighest(NULL , 0 , MODE_HIGH , CandlesForTrailing , 1)];
            StopLoss = (HighestTrail - SymbolInfoDouble(_Symbol,SYMBOL_BID))/pip + PipsBufferForTrailing;
      
      }
      if (UseRR)          TakeProfit = StopLoss * RR_ratio;


      Order_size = CalculateLotSize (StopLoss);      // create sell order
         double price=SymbolInfoDouble(_Symbol,SYMBOL_BID);
         request.action=TRADE_ACTION_DEAL;
         request.type=ORDER_TYPE_SELL;
         request.symbol = _Symbol;
         request.volume = Order_size;
         request.type_filling=ORDER_FILLING_FOK;
         request.price=price;
         if(UseTP) request.tp = price - TakeProfit*pip;
         else request.tp = NULL;
         request.sl = price + StopLoss*pip;
         request.deviation=10;
         request.magic=MagicNumber;
         if(OrderSend(request,result))
           {
            Print("Short Order:",result.comment);
            positionOpen=true;
           }
         else
            Print("Short Failed:",GetLastError());
      return ticket;
   }


/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| Manage Open Trades include                       |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

void manage_SL() //check if SL needs to be updated, if yes: call on function update SL
{
// ****************** need to update for trail start *********************
    PT = PositionsTotal();
   if(PT>0)    //manage buy orders:
   {
         if(posInfo.SelectByMagic(_Symbol , MagicNumber)) 
         {
            if(posInfo.PositionType()==POSITION_TYPE_BUY)
            {  
               if (UseTrailingExit)
               {
                  LowestTrail = Low[iLowest(NULL , 0 , MODE_LOW , CandlesForTrailing , 1)];
                  if(PositionGetDouble(POSITION_SL) + pip < LowestTrail - PipsBufferForTrailing*pip ) trade.PositionModify(_Symbol, LowestTrail - PipsBufferForTrailing*pip  ,PositionGetDouble(POSITION_TP));
               }   
           
                else if(PositionGetDouble(POSITION_SL) + pip < SymbolInfoDouble(_Symbol,SYMBOL_BID) - Trail*pip )   trade.PositionModify(_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_BID) - Trail*pip,PositionGetDouble(POSITION_TP));
            }
            
            
            
            else if(UseTrailingExit)
            {
                  HighestTrail = High[iHighest(NULL , 0 , MODE_HIGH , CandlesForTrailing , 1)];
                  if(PositionGetDouble(POSITION_SL) - pip > HighestTrail + PipsBufferForTrailing*pip )  trade.PositionModify(_Symbol,HighestTrail + PipsBufferForTrailing*pip,PositionGetDouble(POSITION_TP));
            }
            
            else if(PositionGetDouble(POSITION_SL) - pip > SymbolInfoDouble(_Symbol,SYMBOL_ASK) + Trail*pip )  trade.PositionModify(_Symbol,SymbolInfoDouble(_Symbol,SYMBOL_ASK) + Trail*pip,PositionGetDouble(POSITION_TP));
         }
   }
}



void Trailing_manage_trade() // update  for MA cross back
{   

         if(posInfo.SelectByMagic(_Symbol, MagicNumber))
         {
            if(posInfo.PositionType()==POSITION_TYPE_BUY)
            { 
                       
                  if(Pattern_check_is_sell() ) 
                      {
                           if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket)+ " closed by Trailing_manage_trade ");    
                           else Alert ( "order "+ IntegerToString(ticket)+ " didnt close by Trailing_manage_trade, returnd this error " + IntegerToString(GetLastError()));
                      }   
            }
            if(posInfo.PositionType()==POSITION_TYPE_SELL)
            {
                   
                   if( Pattern_check_is_buy() )
                       {
                              if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket) + " closed by Trailing_manage_trade ");
                              else Alert ( "order " + IntegerToString(ticket) + " didnt close by Trailing_manage_trade, returnd this error " +IntegerToString(GetLastError()));
                       }
            }
         }
}






void manage_open_trade() // manage open trades per user settings
{
   if (UseMAExit)         MA_manage_trade();
   if (UseRangExit)       Range_manage_trade();
   if (UseBreakOutExit)   Breakout_manage_trade();
   if (UseBBExit)         BB_manage_trade();
   if (UseDoubleExit)     Double_manage_trade();
   if (UseSRExit)         SR_manage_trade();
      
  

}  




/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| HA Include                                        |
//+------------------------------------------------------------------+
********************************************************************************************************************************/




bool HA_check_is_buy ()
{     
      HA_Open [15] = (Open[16] + Close[16])/2 ;
      HA_Close[15] = (Open[15] + High[15] + Low[15] + Close[15]) / 4;
      HA_High [15] = MathMax(High[15], MathMax(HA_Open[15], HA_Close[15]));
      HA_Low[15] = MathMin(Low[15], MathMin(HA_Open[15], HA_Close[15]));
      
      for (int i=14 ; i>=0 ; i--)
      {
         HA_Open [i] = (HA_Open[i+1] + HA_Close[i+1])/2 ;
         HA_Close[i] = (Open[i] + High[i] + Low[i] + Close[i]) / 4;
         HA_High [i] = MathMax(High[i], MathMax(HA_Open[i], HA_Close[i]));
         HA_Low[i] = MathMin(Low[i], MathMin(HA_Open[i], HA_Close[i]));
      }
      if (HA_Open[1] < HA_Close[1])
         {
 //           if (((HA_Open[1] - HA_Low[1])*HA_wik_ratio) <(HA_High[1] - HA_Close[1])||(HA_Low[1] == HA_Open[1]))      Print ("HA Check is Buy result is true") ; 
            return (  ((HA_Open[1] - HA_Low[1])*HA_wik_ratio) <(HA_High[1] - HA_Close[1])||(HA_Low[1] == HA_Open[1])  );
         }
 //     Print ("HA Check is Buy result is false") ;    
      return (false);
}    


bool HA_check_is_sell ()
{
      HA_Open [15] = (Open[16] + Close[16])/2 ;
      HA_Close[15] = (Open[15] + High[15] + Low[15] + Close[15]) / 4 ;
      HA_High [15] = MathMax(High[15], MathMax(HA_Open[15], HA_Close[15]));
      HA_Low[15] = MathMin(Low[15], MathMin(HA_Open[15], HA_Close[15]));
      
      for (int i= 14 ; i>=0 ; i--)
      {
         HA_Open [i] = (HA_Open[i+1] + HA_Close[i+1])/2 ;
         HA_Close[i] = (Open[i] + High[i] + Low[i] + Close[i]) / 4 ;
         HA_High [i] = MathMax(High[i], MathMax(HA_Open[i], HA_Close[i]));
         HA_Low[i] = MathMin(Low[i], MathMin(HA_Open[i], HA_Close[i]));
        
      
      
      }      
       if( HA_Open[1] > HA_Close[1])
       {  
 //         if (((HA_High[1] - HA_Open[1])*HA_wik_ratio) <((HA_Close[1] - HA_Low[1]))|| (HA_High[1] == HA_Open[1] ))      Print ("HA Check is Sell result is true") ; 
          return ( ((HA_High[1] - HA_Open[1])*HA_wik_ratio) <((HA_Close[1] - HA_Low[1]))|| (HA_High[1] == HA_Open[1] ));
       }
 //      Print ("HA Check is Sell result is false") ;    
       return (false);
}         

bool HA_confirm_is_buy ()
{      
      HA_Open [15] = (Open[16] + Close[16])/2 ;
      HA_Close[15] = (Open[15] + High[15] + Low[15] + Close[15]) / 4;
      HA_High [15] = MathMax(High[15], MathMax(HA_Open[15], HA_Close[15]));
      HA_Low[15] = MathMin(Low[15], MathMin(HA_Open[15], HA_Close[15]));
      
      for (int i=14 ; i>=0 ; i--)
      {
         HA_Open [i] = (HA_Open[i+1] + HA_Close[i+1])/2 ;
         HA_Close[i] = (Open[i] + High[i] + Low[i] + Close[i]) / 4;
         HA_High [i] = MathMax(High[i], MathMax(HA_Open[i], HA_Close[i]));
         HA_Low[i] = MathMin(Low[i], MathMin(HA_Open[i], HA_Close[i]));
      }
      if (HA_Open[1] < HA_Close[1])
      {
//        if ( ((HA_Open[1] - HA_Low[1])*HA_wik_ratio) <(HA_High[1] - HA_Close[1])||(HA_Low[1] == HA_Open[1]))  Print ("HA Confirm is Buy result is true") ; 
       return (  ((HA_Open[1] - HA_Low[1])*HA_wik_ratio) <(HA_High[1] - HA_Close[1])||(HA_Low[1] == HA_Open[1])  );
       }
       
 //     Print ("HA Confirm is Buy result is false") ; 
      return (false);
}    


bool HA_confirm_is_sell ()
{
      HA_Open [15] = (Open[16] + Close[16])/2 ;
      HA_Close[15] = (Open[15] + High[15] + Low[15] + Close[15]) / 4 ;
      HA_High [15] = MathMax(High[15], MathMax(HA_Open[15], HA_Close[15]));
      HA_Low[15] = MathMin(Low[15], MathMin(HA_Open[15], HA_Close[15]));
      
      for (int i= 14 ; i>=0 ; i--)
      {
         HA_Open [i] = (HA_Open[i+1] + HA_Close[i+1])/2 ;
         HA_Close[i] = (Open[i] + High[i] + Low[i] + Close[i]) / 4 ;
         HA_High [i] = MathMax(High[i], MathMax(HA_Open[i], HA_Close[i]));
         HA_Low[i] = MathMin(Low[i], MathMin(HA_Open[i], HA_Close[i]));
        
      
      
      }      
      if( HA_Open[1] > HA_Close[1])
      
      {
//       if (  ((HA_High[1] - HA_Open[1])*HA_wik_ratio) <((HA_Close[1] - HA_Low[1]))|| (HA_High[1] == HA_Open[1] ))  Print ("HA Confirm is Sell result is true") ; 
       return ( ((HA_High[1] - HA_Open[1])*HA_wik_ratio) <((HA_Close[1] - HA_Low[1]))|| (HA_High[1] == HA_Open[1] ));
      } 
       
       
//      Print ("HA Confirm is Sell result is false") ; 
      return (false);
}         




      
      
void HA_manage_trade() // check vurrent open and closes if neccesery
{
      HA_Open [15] = (Open[16] + Close[16])/2 ;
      HA_Close[15] = (Open[15] + High[15] + Low[15] + Close[15]) / 4;
      HA_High [15] = MathMax(High[15], MathMax(HA_Open[15], HA_Close[15]));
      HA_Low[15] = MathMin(Low[15], MathMin(HA_Open[15], HA_Close[15]));
      for (int i= 14 ; i>=0 ; i--)
      {
         HA_Open [i] = (HA_Open[i+1] + HA_Close[i+1])/2 ;
         HA_Close[i] = (Open[i] + High[i] + Low[i] + Close[i]) / 4;
         HA_High [i] = MathMax(High[i], MathMax(HA_Open[i], HA_Close[i]));
         HA_Low[i] = MathMin(Low[i], MathMin(HA_Open[i], HA_Close[i]));    
      }


         if(posInfo.SelectByMagic(_Symbol, MagicNumber))
         {
            if(posInfo.PositionType()==POSITION_TYPE_BUY)
            {     
              if( HA_Open[1] >= HA_Close[1] ) 
                      {
                        if (Close[1] < High[2])
                        {
                           if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket)+ " closed by HA_manage_trade ");    
                           else Alert ( "order "+ IntegerToString(ticket)+ " didnt close by HA_manage_trade, returnd this error " + IntegerToString(GetLastError()));
                        }
                      }   
            }
            if(posInfo.PositionType()==POSITION_TYPE_SELL)
            {
                   if( HA_Open[1] <= HA_Close[1] )
                       {
                           if (Close[1] > Low[2])
                           {
                              if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket) + " closed by HA_manage_trade ");
                              else Alert ( "order " + IntegerToString(ticket) + " didnt close by HA_manage_trade, returnd this error " +IntegerToString(GetLastError()));
                           }
                       }
            }
            

         }
         
}



/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//|  MA Include                                      |
//+------------------------------------------------------------------+
********************************************************************************************************************************/


bool MA_check_is_buy ()
{   
    if (!confrim_is_buy())    return(false);
    return (  FastMABuffer[1] > SlowMABuffer[1]  && FastMABuffer[2] < SlowMABuffer[2] );
}    


bool MA_check_is_sell ()
{
        if (!confrim_is_sell())    return(false);
        return (  FastMABuffer[1] < SlowMABuffer[1] && FastMABuffer[2] >SlowMABuffer[2] );

}         


bool MA_confirm_is_buy ()
{      
 //   if ( iMA(NULL , 0, FastMA,0,1 , 0,1) > iMA(NULL , 0, SlowMA,0,1 , 0,1))      Print ("MA confirm is Buy result is true") ; 
 //   else Print ("MA confirm is Buy result is false") ; 
    return (  FastMABuffer[1] > SlowMABuffer[1]);

}    


bool MA_confirm_is_sell ()
{
    //        if (iMA(NULL , 0, FastMA,0,1 , 0,1) < iMA(NULL , 0, SlowMA,0,1 , 0,1))      Print ("MA confirm is Sell result is true") ; 
    //        else Print ("MA confirm is Sell result is false") ; 
            return (  FastMABuffer[1] < SlowMABuffer[1]);
}         


void MA_manage_trade() // update  for MA cross back
{   
         if(posInfo.SelectByMagic(_Symbol, MagicNumber))
         {
            if(posInfo.PositionType()==POSITION_TYPE_BUY)
            {     
              if( MA_check_is_sell() ) 
                      {
                           if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket)+ " closed by MA_manage_trade ");    
                           else Alert ( "order "+ IntegerToString(ticket)+ " didnt close by MA_manage_trade, returnd this error " + IntegerToString(GetLastError()));
                      }   
            }
            if(posInfo.PositionType()==POSITION_TYPE_SELL)
            {
                   if( MA_check_is_buy() )
                       {
                              if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket) + " closed by HA_manage_trade ");
                              else Alert ( "order " + IntegerToString(ticket) + " didnt close by HA_manage_trade, returnd this error " +IntegerToString(GetLastError()));
                       }
            }
            

         }
}         
         


/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//|  Range Include                                  |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

bool Range_check_is_buy ()
{     
   //Print (iHighest(NULL , 0 , MODE_HIGH , PeriodForRange , 0));
   HighestInRange = High[iHighest(NULL , 0 , MODE_HIGH , PeriodForRange , 1)] ; 
   LowestInRange = Low[iLowest(NULL , 0 , MODE_LOW , PeriodForRange , 1)] ; 
   CountH = 0;//counter for the number of high touches
   CountL = 0;//counter for the number of low touches
   LastHigh = 100;
   LastLow = 100;
   for (int i=PeriodForRange ; i >0 ; i--)
   {
      if(Low[i] - LowestInRange  < SlackForRange*pip)
      {
          CountL ++;
          LastLow = i;
      }
      if(HighestInRange - High[i] < SlackForRange*pip)  CountH++;
   }

   if ( CountH >= TouchesForRange && CountL >= TouchesForRange&& LastLow <LastTouchOfSR  )
   {
      CalculatedSLForRange = (Open[0] - LowestInRange )/ pip + SLSlackForRange;
      CalculatedTPForRange = (HighestInRange - Open [0] )/ pip - TPSlackForRange;   
      Print ("Range check is buy returned true") ;  
      return (true);
   }
   Print ("Range check is buy returned false") ; 
   return (false);
}    


bool Range_check_is_sell ()
{     
   //Print (iHighest(NULL , 0 , MODE_HIGH , PeriodForRange , 0));
   HighestInRange = High[iHighest(NULL , 0 , MODE_HIGH , PeriodForRange , 1)] ; 
   LowestInRange = Low[iLowest(NULL , 0 , MODE_LOW , PeriodForRange , 1)] ; 
   CountH = 0;//counter for the number of high touches
   CountL = 0;//counter for the number of low touches
   LastHigh = 100;
   LastLow = 100;
   for (int i=PeriodForRange ; i >0 ; i--)

   {
      if(HighestInRange - High[i]  < SlackForRange*pip)
      {
          CountH ++;
          LastHigh = i;
      }
      if(Low[i] - LowestInRange < SlackForRange*pip)  CountL++;
   }
   if ( CountH >= TouchesForRange && CountL >= TouchesForRange && LastHigh <LastTouchOfSR )
   {
      CalculatedSLForRange = (HighestInRange - Open [0] )/ pip + SLSlackForRange;    
      CalculatedTPForRange = (Open[0] - LowestInRange )/ pip - TPSlackForRange;
      Print ("Range check is sell - true") ; 
      return (true);
   }
   Print ("Range check is sell - false") ; 
   return (false);
}    


void Range_manage_trade() // update  for MA cross back
{   
         if(posInfo.SelectByMagic(_Symbol, MagicNumber))
         {
            if(posInfo.PositionType()==POSITION_TYPE_BUY)
            {     
              if(Range_check_is_sell() ) 
                      {
                           if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket)+ " closed by Range_manage_trade ");    
                           else Alert ( "order "+ IntegerToString(ticket)+ " didnt close by Range_manage_trade, returnd this error " + IntegerToString(GetLastError()));
                      }   
            }
            if(posInfo.PositionType()==POSITION_TYPE_SELL)
            {
                   if( Range_check_is_buy() )
                       {
                              if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket) + " closed by Range_manage_trade ");
                              else Alert ( "order " + IntegerToString(ticket) + " didnt close by Range_manage_trade, returnd this error " +IntegerToString(GetLastError()));
                       }
            }
            

         }

}

bool Breakout_check_is_buy ()
{     
   HighestInRange = High[iHighest(NULL , 0 , MODE_HIGH , PeriodForRange , 2)] ; 
   CountH = 0;//counter for the number of high touches
   LastHigh = 100;
   for (int i=PeriodForRange ; i >1 ; i--)
   {
      if(HighestInRange - High[i] < SlackForRange*pip)
      {
        LastHigh = i;
        CountH++;
      }
   }
   
   if ( CountH >= TouchesForRange && Close[1] > (HighestInRange + ConfirmForBreakout*pip))
   {
      CalculatedSLForBreakout = (Open [0] - Open[1]  )/ pip + SLSlackForRange;
      Print ("Breakout_check_is_buy returnd true") ;        
      return (true);
   }
   Print ("Breakout_check_is_buy returnd false") ;   
   return (false);
}    


bool Breakout_check_is_sell ()
{     
   LowestInRange = Low[iLowest(NULL , 0 , MODE_LOW , PeriodForRange , 2)] ; 
   CountL = 0;//counter for the number of low touches
   LastLow = 100;
   for (int i=PeriodForRange ; i >1 ; i--)
   {
      if(Low[i] - LowestInRange < SlackForRange*pip)
      {
        LastLow = i;
        CountL++;
      }
   }
   if ( CountL >= TouchesForRange && Close[1] <  (LowestInRange - ConfirmForBreakout*pip))
   {  
      CalculatedSLForBreakout = (Open[1] - Open [0] )/ pip + SLSlackForRange;
      Print ("Breakout_check_is_sell returnd true") ;  
      return (true);
   }
   Print ("Breakout_check_is_sell returnd false") ;  
   return (false);
}    

      

void Breakout_manage_trade() // update  for range the occured on charts and broke to oposite side
{   



         if(posInfo.SelectByMagic(_Symbol, MagicNumber))
         {
            if(posInfo.PositionType()==POSITION_TYPE_BUY)
            {     
              if(Breakout_check_is_sell()  ) 
                      {
                           if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket)+ " closed by Breakout_manage_trade ");    
                           else Alert ( "order "+ IntegerToString(ticket)+ " didnt close by Breakout_manage_trade, returnd this error " + IntegerToString(GetLastError()));
                      }   
            }
            if(posInfo.PositionType()==POSITION_TYPE_SELL)
            {
                   if( Breakout_check_is_buy() )
                       {
                              if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket) + " closed by Breakout_manage_trade ");
                              else Alert ( "order " + IntegerToString(ticket) + " didnt close by Breakout_manage_trade, returnd this error " +IntegerToString(GetLastError()));
                       }
            }
         }
     
}



bool SR_check_is_buy ()
{     
   //Print (iHighest(NULL , 0 , MODE_HIGH , PeriodForRange , 0));

   LowestInRange = Low[iLowest(NULL , 0 , MODE_LOW , PeriodForRange , 1)] ; 
   CountL = 0;//counter for the number of low touches
   LastLow = 100;
   for (int i=PeriodForRange ; i >0 ; i--)
   {
      if(Low[i] - LowestInRange  < SlackForRange*pip)
      {
          CountL ++;
          LastLow = i;
      }
   }

   if (  CountL >= TouchesForRange&& LastLow <LastTouchOfSR  )
   {
      CalculatedSLForSR = (Open[0] - LowestInRange )/ pip + SLSlackForRange;
       Print ("SR_check_is_buy returnd true, " , "SL is: " ,  CalculatedSLForSR) ; 
      return (true);
 
   }
   Print ("SR_check_is_buy returnd false") ; 
   return (false);
}    


bool SR_check_is_sell ()
{     
   //Print (iHighest(NULL , 0 , MODE_HIGH , PeriodForRange , 0));

   HighestInRange = High[iHighest(NULL , 0 , MODE_HIGH , PeriodForRange , 1)] ; 
   CountH = 0;//counter for the number of high touches
   LastHigh = 100;
   for (int i=PeriodForRange ; i >0 ; i--)

   {
      if(HighestInRange - High[i]  < SlackForRange*pip)
      {
          CountH ++;
          LastHigh = i;
      }
   }
   if ( CountH >= TouchesForRange && LastHigh <LastTouchOfSR )
   {
      CalculatedSLForSR = (HighestInRange - Open [0] )/ pip + SLSlackForRange;  
             Print ("SR_check_is_sell returnd true, " , "SL is: " ,  CalculatedSLForSR) ; 
      return (true);
   }
   Print ("SR_check_is_sell returnd false") ; 
   return (false);
}    

      
      

void SR_manage_trade() // update  for MA cross back
{   
         
         if(posInfo.SelectByMagic(_Symbol, MagicNumber))
         {
            if(posInfo.PositionType()==POSITION_TYPE_BUY)
            {     
            
            
            ///*******************order to position!!!!!!
              if(SR_check_is_sell()  &&  ((TimeCurrent() - PositionGetInteger(POSITION_TIME))/60 > (LastTouchOfSR * 60)  ))  //conmpare the time in minutes (Last touch *60 for minutes)  
                      {
                           if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket)+ " closed by Breakout_manage_trade ");    
                           else Alert ( "order "+ IntegerToString(ticket)+ " didnt close by Breakout_manage_trade, returnd this error " + IntegerToString(GetLastError()));
                      }   
            }
            if(posInfo.PositionType()==POSITION_TYPE_SELL)
            {
                   if( SR_check_is_buy() && ( (TimeCurrent() - PositionGetInteger(POSITION_TIME))/60> (LastTouchOfSR * 60)  ) )
                       {
                              if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket) + " closed by Breakout_manage_trade ");
                              else Alert ( "order " + IntegerToString(ticket) + " didnt close by Breakout_manage_trade, returnd this error " +IntegerToString(GetLastError()));
                       }
            }
         }

      
      
      
}


/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| Double Include                                   |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

bool Double_check_is_buy ()
{     
   int FirstTouchCandle = iLowest(NULL , 0 , MODE_LOW , PeriodForDouble , 1) ; 
   if (FirstTouchCandle < WaitBetweenCandlesDouble) return (false);
   double FirstTouchValue = Low[FirstTouchCandle] ; 
   int CountL = 0;//counter for the number of low touches
   int LastLow = -1;
   for (int i=PeriodForDouble ; i >0 ; i--)
   {
      if(Low[i] - FirstTouchValue  < SlackForDouble*pip)
      {
          CountL ++;
          LastLow = i;
      }
   }

   if (CountL == 2 && LastLow ==1 )
   {
       CalculatedSLFordouble = (Open[0] - FirstTouchValue )/ pip + SLSlackForDouble;
       Print ("Double_check_is_buy returned true") ;  
       return (true);
   }
   Print ("Double_check_is_buy returned false") ;  
   return (false);
}    

bool Double_check_is_sell ()
{     
   int FirstTouchCandle = iHighest(NULL , 0 , MODE_HIGH , PeriodForDouble , 1) ; 
   if (FirstTouchCandle < WaitBetweenCandlesDouble) return (false);
   double FirstTouchValue = High[FirstTouchCandle] ; 
   int CountH = 0;//counter for the number of high touches
   int LastHigh = -1;
   for (int i=PeriodForDouble ; i >0 ; i--)
   {
      if(FirstTouchValue - High[i]  < SlackForDouble*pip)
      {
          CountH ++;
          LastHigh = i;
      }
   }

   if (CountH == 2 && LastHigh ==1  )
   {
     CalculatedSLFordouble = (FirstTouchValue - Open [0] )/ pip + SLSlackForDouble;
     Print ("Double_check_is_sell returned true") ;
      return (true);
 
   } 
   Print ("Double_check_is_sell returned false") ;
   return (false);
}    



void Double_manage_trade() // update  for MA cross back
{   
         if(posInfo.SelectByMagic(_Symbol, MagicNumber))
         {
            if(posInfo.PositionType()==POSITION_TYPE_BUY)
            {     
              if(Double_check_is_sell() ) 
                      {
                           if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket)+ " closed by Double_manage_trade ");    
                           else Alert ( "order "+ IntegerToString(ticket)+ " didnt close by Double_manage_trade, returnd this error " + IntegerToString(GetLastError()));
                      }   
            }
            if(posInfo.PositionType()==POSITION_TYPE_SELL)
            {
                   if( Double_check_is_buy() )
                       {
                              if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket) + " closed by Double_manage_trade ");
                              else Alert ( "order " + IntegerToString(ticket) + " didnt close by Double_manage_trade, returnd this error " +IntegerToString(GetLastError()));
                       }
            }            
         }
}



/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| BB Include                                  |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

bool BB_check_is_buy ()
{      
      return (Close[1]> lowerBandBuffer[1] && Close[2] < lowerBandBuffer[2]);
}     


bool BB_check_is_sell ()
{
      return (Close[1] < upperBandBuffer[1] && Close[2] > upperBandBuffer[2]);
}   



bool BB_confirm_is_buy ()
{     
 //     if ( Close[1]<  iBands(NULL , 0 , BBPeriod , BBDeviation , 0 , 0 , MODE_UPPER , 1))      Print ("BB confirm is buy result is true") ; 
 //     else Print ("BB confirm is buy result is false") ;  
      return (Close[1]<  upperBandBuffer[1] );
}     


bool BB_confirm_is_sell ()
{
//      if ( Close[1] > iBands(NULL , 0 , BBPeriod , BBDeviation , 0 , 0 , MODE_LOWER , 1))      Print ("BB confirm is sell result is true") ; 
//      else Print ("BB confirm is sell result is false") ;  
      return (Close[1] > lowerBandBuffer[1]);
}   


void BB_manage_trade() // update  for MA cross back
{   
         if(posInfo.SelectByMagic(_Symbol, MagicNumber))
         {
            if(posInfo.PositionType()==POSITION_TYPE_BUY)
            {     
              if(BB_check_is_sell() ) 
                      {
                           if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket)+ " closed by BB_manage_trade ");    
                           else Alert ( "order "+ IntegerToString(ticket)+ " didnt close by BB_manage_trade, returnd this error " + IntegerToString(GetLastError()));
                      }   
            }
            if(posInfo.PositionType()==POSITION_TYPE_SELL)
            {
                   if( BB_check_is_buy() )
                       {
                              if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket) + " closed by BB_manage_trade ");
                              else Alert ( "order " + IntegerToString(ticket) + " didnt close by BB_manage_trade, returnd this error " +IntegerToString(GetLastError()));
                       }
            }
         }
}



/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| RSI Include                                  |
//+------------------------------------------------------------------+
********************************************************************************************************************************/


bool RSI_confirm_is_buy ()
{      
//      if ((50 + RSI_OverExtended)   >  iRSI(NULL , 0 , RSI_Period , PRICE_CLOSE , 1))      Print ("RSI confirm is buy result is true") ; 
//      else Print ("RSI confirm is buy result is false") ; 
      return ( (50 + RSIOverExtended)   >  rsiBuffer[1] );

}     


bool RSI_confirm_is_sell ()
{
//      if ((50 - RSI_OverExtended)   <  iRSI(NULL , 0 , RSI_Period , PRICE_CLOSE , 1))      Print ("RSI confirm is sell result is true") ; 
//      else Print ("RSI confirm is sell result is false") ; 
      return ( (50 - RSIOverExtended)   <  rsiBuffer[1] );
}   





/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| FIB Include                                  |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

bool FIB_confirm_is_buy ()
{      
         double HighestInFIB = High[iHighest(NULL , 0 , MODE_HIGH , PeriodForFIB , 1)] ; 
         double LowestInFIB = Low[iLowest(NULL , 0 , MODE_LOW , PeriodForFIB , 1)] ; 
         double FirstFIBLevelValue = (HighestInRange+LowestInRange) *0.618;
         double LastFIBLevelValue = (HighestInRange+LowestInRange) *0.382;
 //        if ((FirstFIBLevelValue > Close[1] && Close[1] > LastFIBLevelValue))      Print ("FIB confirm is buy result is true") ; 
//         else Print ("FIB confirm is buy result is false") ; 
         return ( FirstFIBLevelValue > Close[1] && Close[1] > LastFIBLevelValue);

}     


bool FIB_confirm_is_sell ()
{
         double HighestInFIB = High[iHighest(NULL , 0 , MODE_HIGH , PeriodForFIB , 1)] ; 
         double LowestInFIB = Low[iLowest(NULL , 0 , MODE_LOW , PeriodForFIB , 1)] ; 
         double FirstFIBLevelValue = (HighestInRange+LowestInRange) *0.382;
         double LastFIBLevelValue = (HighestInRange+LowestInRange) *0.618;
 //        if (FirstFIBLevelValue < Close[1] && Close[1] < LastFIBLevelValue)      Print ("FIB confirm is sell result is true") ; 
 //        else Print ("FIB confirm is sell result is false") ; 
         return ( FirstFIBLevelValue < Close[1] && Close[1] < LastFIBLevelValue);
}


/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| Pattern Include                                  |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

bool Pattern_check_is_buy ()
{   

    return (  Close[1] > Close[2] && High[1] > High[2] );
}    


bool Pattern_check_is_sell ()
{
   
    return (  Close[1] < Close[2] && Low[1] < Low[2] );
}         


bool Pattern_confirm_is_buy ()
{      
//     if ( Close[1] > Close[2] && High[1] > High[2])      Print ("Pattern confirm is buy result is true") ; 
 //    else Print ("Pattern confirm is buy result is false") ; 
    return (  Close[1] > Close[2] && High[1] > High[2] );
}    


bool Pattern_confirm_is_sell ()
{
//    if (  Close[1] < Close[2] && Low[1] < Low[2] )      Print ("Pattern confirm is sell result is true") ; 
//    else Print ("Pattern confirm is sell result is false") ; 
    return (  Close[1] < Close[2] && Low[1] < Low[2] );
}         



void Pattern_manage_trade() // update  for MA cross back
{   
         if(posInfo.SelectByMagic(_Symbol, MagicNumber))
         {
            if(posInfo.PositionType()==POSITION_TYPE_BUY)
            {     
              if(Pattern_check_is_sell() ) 
                      {
                           if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket)+ " closed by Pattern_manage_trade ");    
                           else Alert ( "order "+ IntegerToString(ticket)+ " didnt close by Pattern_manage_trade, returnd this error " + IntegerToString(GetLastError()));
                      }   
            }
            if(posInfo.PositionType()==POSITION_TYPE_SELL)
            {
                   if( Pattern_check_is_buy() )
                       {
                              if (trade.PositionClose(Symbol())) Alert ( "order "+IntegerToString(ticket) + " closed by Pattern_manage_trade ");
                              else Alert ( "order " + IntegerToString(ticket) + " didnt close by Pattern_manage_trade, returnd this error " +IntegerToString(GetLastError()));
                       }
            }
         }
}



/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| Close trailing stop  Include                                  |
//+------------------------------------------------------------------+
********************************************************************************************************************************/






