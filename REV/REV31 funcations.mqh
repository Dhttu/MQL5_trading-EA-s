//+------------------------------------------------------------------+
//|                                             REV31 funcations.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+



#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"


#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\TerminalInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
#include <Expert\Money\MoneyFixedRisk.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Math\Stat\Normal.mqh>


COrderInfo orderInfo;
CDealInfo dealInfo;
MqlDateTime dt_struct;
CTrade trade;
CAccountInfo accInfo;
CPositionInfo posInfo;
CSymbolInfo symInfo;
MqlTradeRequest request;
MqlTradeResult result;
int history=105;
int PT = 0; // Poistions Total




//--- price buffers
double Close[], Open[], High[] , Low[]  ,CloseH4[], OpenH4[], HighH4[] , LowH4[]  ,CloseD[] , OpenD[] , HighD[] , LowD[] ;
datetime Time[];


bool filter_Pas = true;

double CurrentRiskPerTrade ;


datetime Position_Open_time ;


double HighestTrail;
double LowestTrail; 



int Prev_Hour = 0; 
int Cur_Hour = 0;
datetime ThreshHold = 0, TimeNow = 0;
int slipege = 10;
double pip = 0;
bool MainRun = false;
//Trades placed at start of candle


//  *****  not in mql4:
bool positionOpen=false;


double  ATRBuffer[];
int      ATRHandle;
int      ATR = 14;




//+------------------------------------------------------------------+
//| Open Orders Include varibales                         |
//+------------------------------------------------------------------+

double StopLoss=0;
double TakeProfit=0; 
double UpdatedMultiplier = 0;

int ticket;
double Order_size = 0;



//+------------------------------------------------------------------+
//| Manage Open Trades include varibales                         |
//+------------------------------------------------------------------+

   double   Acountprofit; 
   double  CanlesTrailValue, SRTrailValue ,TrendTrailValue, UserTrailValue ;
   double   FinalTrailValue; 
   
   
   
   
//+------------------------------------------------------------------+
//| Range Include varibales                         |
//+------------------------------------------------------------------+


double UpperSR=0, UpperLimit=0 , LowerSR=0 , LowerLimit=0;

double HighestInRange;
double LowestInRange; 







//+------------------------------------------------------------------+
//| BB Include varibales                         |
//+------------------------------------------------------------------+

double upperBandBuffer[];
double middleBandBuffer[];
double lowerBandBuffer[];
int bandHandle=0;


//+------------------------------------------------------------------+
//| Range Include varibales                         |
//+------------------------------------------------------------------+




input string GSV_P; // ***** Gereatest swing value parameters *****
input int PeriodForGSV = 5;
//input double BuyGSVUpperValue = -1.9;
input double SellGSVLowerValue = 3;
double GSV, LongGSV , ShortGSV;
double DownArr , UpArr;

//+------------------------------------------------------------------+
//| GR Include varibales                         |
//+------------------------------------------------------------------+


 string GRRatio_P; // ***** Grenn/Red Ratio parameters *****
 int Ratio_CandlesCount = 100;
 double BuyEnterLimitP_RG = 1.05;
 double BuyExitLimitP_RG = 1;
 double SellEnterLimitP_GR = 1.25;
 double SellExitLimitP_GR = 1;


double GR_R , RG_R ;



void LoadHistory()
{
         
        if(CopyClose(_Symbol,_Period,0,history,Close)<0) {PrintFormat("Error loading close price data, code %d",GetLastError()); return;}
         if(CopyOpen(_Symbol,_Period,0,history,Open)<0) {PrintFormat("Error loading open price data, code %d",GetLastError()); return;}
         if(CopyHigh(_Symbol,_Period,0,history,High)<0) {PrintFormat("Error loading high price data, code %d",GetLastError()); return;}
         if(CopyLow(_Symbol,_Period,0,history,Low)<0) {PrintFormat("Error loading low price data, code %d",GetLastError()); return;}
         if(CopyTime(_Symbol ,_Period ,0 , history , Time) < 0 )  {PrintFormat("Error loading time data, code %d",GetLastError()); return;}
                    
         if(CopyClose(_Symbol,PERIOD_H4,0,history,CloseH4)<0) {PrintFormat("Error loading close price data, code %d",GetLastError()); return;}
         if(CopyOpen(_Symbol,PERIOD_H4,0,history,OpenH4)<0) {PrintFormat("Error loading open price data, code %d",GetLastError()); return;}
         if(CopyHigh(_Symbol,PERIOD_H4,0,history,HighH4)<0) {PrintFormat("Error loading high price data, code %d",GetLastError()); return;}
         if(CopyLow(_Symbol,PERIOD_H4,0,history,LowH4)<0) {PrintFormat("Error loading low price data, code %d",GetLastError()); return;}  
            
         if(CopyClose(_Symbol,PERIOD_D1,0,history,CloseD)<0) {PrintFormat("Error loading close price data, code %d",GetLastError()); return;}
         if(CopyOpen(_Symbol,PERIOD_D1,0,history,OpenD)<0) {PrintFormat("Error loading open price data, code %d",GetLastError()); return;}
         if(CopyHigh(_Symbol,PERIOD_D1,0,history,HighD)<0) {PrintFormat("Error loading high price data, code %d",GetLastError()); return;}
         if(CopyLow(_Symbol,PERIOD_D1,0,history,LowD)<0) {PrintFormat("Error loading low price data, code %d",GetLastError()); return;}
         

           //for ATR:
               if(CopyBuffer(ATRHandle,0,0,ATR,ATRBuffer)<0) {PrintFormat("Error loading ATR data, code %d",GetLastError()); return;}
            
            
            //for MA:
            if(CopyBuffer(FastMAHandle,0,0,FastMA,FastMABuffer)<0) {PrintFormat("Error loading Fast MA data for %s, code %d",_Symbol,GetLastError()); return;}
            if(CopyBuffer(SlowMAHandle,0,0,SlowMA,SlowMABuffer)<0) {PrintFormat("Error loading Slow MA data for %s, code %d",_Symbol,GetLastError()); return;}
            if(CopyBuffer(LongMAHandle,0,0,LongMA,LongMABuffer)<0) {PrintFormat("Error loading Long MA data for %s, code %d",_Symbol,GetLastError()); return;}
            
            if(CopyBuffer(FastMAHandle_D,0,0,FastMA_D,FastMABuffer_D)<0) {PrintFormat("Error loading Fast MA data for %s, code %d",_Symbol,GetLastError()); return;}
            if(CopyBuffer(SlowMAHandle_D,0,0,SlowMA_D,SlowMABuffer_D)<0) {PrintFormat("Error loading Slow MA data for %s, code %d",_Symbol,GetLastError()); return;}
            if(CopyBuffer(LongMAHandle_D,0,0,LongMA_D,LongMABuffer_D)<0) {PrintFormat("Error loading Long MA data for %s, code %d",_Symbol,GetLastError()); return;}

           //for BB
           if(CopyBuffer(bandHandle,1,0,BBPeriod,upperBandBuffer)<0) {PrintFormat("Error loading upper band data, code %d", GetLastError()); return;}
           if(CopyBuffer(bandHandle,2,0,BBPeriod,lowerBandBuffer)<0) {PrintFormat("Error loading lower band data, code %d",GetLastError()); return;}
           if(CopyBuffer(bandHandle,0,0,BBPeriod,middleBandBuffer)<0) {PrintFormat("Error loading middle band data, code %d",GetLastError()); return;}
           

        //for RSI:
            if(CopyBuffer(rsiHandle,0,0,RSIPeriod,rsiBuffer)<0) {PrintFormat("Error loading rsi data, code %d",GetLastError()); return;}
            if(CopyBuffer(FastrsiHandle,0,0,FastRSIPeriod,FastrsiBuffer)<0) {PrintFormat("Error loading Fast rsi data, code %d",GetLastError()); return;}
            
           TimeCurrent(dt_struct);
           
           GSV = CalculateGSV();    
                  
           MAsAlighn = 0;
           CheckMAsAlignment();
           
           MAsAlighn_D = 0;
           CheckMAsAlignment_D();
           
          
            
}

void Initiate()
{
    ZeroBalance();

   //For MA:
   ArraySetAsSeries(FastMABuffer,true);
   ArraySetAsSeries(SlowMABuffer,true);
   ArraySetAsSeries(LongMABuffer,true);

 
      //For ATR:
   ArraySetAsSeries(ATRBuffer,true);
   ATRHandle=iATR(_Symbol , PERIOD_CURRENT , ATR);

   //for BB: 
   ArraySetAsSeries(upperBandBuffer,true);
   ArraySetAsSeries(lowerBandBuffer,true);
   ArraySetAsSeries(middleBandBuffer,true);
   bandHandle=iBands(_Symbol,PERIOD_CURRENT,BBPeriod,0,BBDeviation,PRICE_CLOSE);
 

    //for RSI:
   ArraySetAsSeries(rsiBuffer,true);
   ArraySetAsSeries(FastrsiBuffer,true);



   ArraySetAsSeries(Open,true);
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Time,true);
      
   ArraySetAsSeries(OpenH4,true);
   ArraySetAsSeries(CloseH4,true);
   ArraySetAsSeries(HighH4,true);
   ArraySetAsSeries(LowH4,true);
   
   ArraySetAsSeries(OpenD,true);
   ArraySetAsSeries(CloseD,true);
   ArraySetAsSeries(HighD,true);
   ArraySetAsSeries(LowD,true);
 

   history =MathMax(100 ,   SL_CandlesForTrailing ) + 10;
   
   trade.SetExpertMagicNumber(MagicNumber);
   symInfo.Name(Symbol());
   symInfo.Refresh();
   pip=10*_Point;

       CurrentRiskPerTrade = UserRiskPerTrade;
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



int Count_consecutive_losses()
{
   HistorySelect(0,TimeCurrent());
   int LastLoss=0;
   int Looper=HistoryDealsTotal();
   while(Looper>0  && LastLoss <10)
   { 
         ulong HTicket = HistoryDealGetTicket(Looper-1);
         if((HistoryDealGetInteger(HTicket, DEAL_MAGIC) == MagicNumber) && (HistoryDealGetString(HTicket, DEAL_SYMBOL) == Symbol()))
         {
               if(HistoryDealGetDouble(HTicket, DEAL_PROFIT) >=0 )  return (LastLoss);
               LastLoss ++;
         }
         
        Looper --;
   }

   return (LastLoss);
}


void CloseAllTrades (int Direc)
{
     if (Direc == 1) //close buy trades
     {
         Print("close all buy trades " , rev);
         for(int k=PositionsTotal();k>=0;k--)
           {   
           if(posInfo.SelectByIndex(k))
              if(PositionGetInteger(POSITION_MAGIC)==MagicNumber) 
                  if ( posInfo.PositionType()==POSITION_TYPE_BUY ) 
                       trade.PositionClose(PositionGetTicket(k));
           }
     }
     else //close sell trades
     {
         Print("close all sell trades " , rev );
         for(int k=PositionsTotal();k>=0;k--)
           {
                if(posInfo.SelectByIndex(k))
                    if(PositionGetInteger(POSITION_MAGIC)==MagicNumber) 
                           if ( posInfo.PositionType()==POSITION_TYPE_SELL ) 
                                  trade.PositionClose(PositionGetTicket(k));
           }
     }     

}


double CalculateLotSize(double SL) //Calculate the size of the position size 
{         
   double nTickValue=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_VALUE); //We get the value of a tick
      if (SL ==0) SL = 1;
      if (nTickValue ==0) nTickValue = 0.00001;
         

   double LotSize=(AccountInfoDouble(ACCOUNT_BALANCE)*CurrentRiskPerTrade/100)/(SL*nTickValue);   //We apply the formula to calculate the position size and assign the value to the variable


   LotSize = NormalizeDouble(LotSize, 1);

   return LotSize/10;
}



void Calculate_CandlesSL (int Dricetion)
{
      if (Dricetion ==0) // Buy
      {
            LowestTrail = Low[iLowest(NULL , 0 , MODE_LOW , SL_CandlesForTrailing , 1)];
            StopLoss = (SymbolInfoDouble(_Symbol,SYMBOL_ASK) - LowestTrail + SLATR_SlackRatio*ATRBuffer[1])/pip;
      }
      else
      {
            HighestTrail = High[iHighest(NULL , 0 , MODE_HIGH , SL_CandlesForTrailing , 1)];
            StopLoss = (HighestTrail - SymbolInfoDouble(_Symbol,SYMBOL_BID) + SLATR_SlackRatio*ATRBuffer[1])/pip;
      }
}



int Calculate_Martingale(int Direc)
{
   int Counter=0;
   int Looper = PositionsTotal();
   while(Looper>0 &&  Counter < 10)   
   { 
         if(posInfo.SelectByIndex(Looper-1))
         {
            if(PositionGetInteger(POSITION_MAGIC)==MagicNumber) 
            {
                  if(  (posInfo.PositionType()==POSITION_TYPE_BUY && Direc == 1) ||   (posInfo.PositionType()==POSITION_TYPE_SELL && Direc == -1)  ) 
                     {
                          Counter ++;    // if ( PositionGetDouble(POSITION_PROFIT)<0 )  Counter ++;  -> the grey one - only for trades in negative profit
                     } 
            }
        }
      Looper --;
   }
         Print ("Counter for martinglae is " , Counter) ;
   return (Counter);
}


int PlaceBuyOrder()
   {
      StopLoss = 2500;
      if (UseCandlesSL) Calculate_CandlesSL (0) ;
      if (UseUserSL)    StopLoss = MathMin(UserStopLoss ,StopLoss) ;
      
      
       TakeProfit = 0;
       if (UseTP)
       {
          if (UseATRTP) TakeProfit = MathMax(TakeProfit , ATRTP_ratio * ATRBuffer[1]/pip);
          if (UseUserTP) TakeProfit=   MathMax(TakeProfit ,UserTakeProfit);
       }   
        
      CurrentRiskPerTrade = UserRiskPerTrade     ;
      if(DoubleUpMartingale > 1)  CurrentRiskPerTrade = CurrentRiskPerTrade*MathPow(DoubleUpMartingale , Count_consecutive_losses());
      if(Martingale > 1)          CurrentRiskPerTrade = CurrentRiskPerTrade*MathPow(Martingale , Calculate_Martingale(1));
      
      Order_size = CalculateLotSize(StopLoss);
      Order_size = MathMax(Order_size , 0.01);
      if (UseFixedOD) Order_size = NormalizeDouble(CurrentRiskPerTrade * AccountInfoDouble(ACCOUNT_BALANCE) / (100000 ) , 2);
      
      Print("buy order, Order size is: " , Order_size ,"  ,StopLoss is:" ,StopLoss , "  ,TakeProfit is: " , TakeProfit );
      double price=0;
      
         positionOpen=false;
         int i=0;
         do
         {
             FillBuyData();
             if(OrderSend(request,result))
              {
               positionOpen=true;
              }
             else
             {
               Alert("OrderSend failed with error #" , GetLastError()," price is:" ,price , " ," , rev );
               Print("OrderSend failed with error #" , GetLastError()," price is:" ,price , " ," , rev );
             }
              Sleep(1000);
              i=i+1;
          }
          while(!positionOpen && i<10);

      return ticket;
   }
 

int PlaceSellOrder()//need to update per creteria of SL TP manage trade ext
   {
     
      StopLoss = 2500;
      if (UseCandlesSL) Calculate_CandlesSL (-1) ;
      if (UseUserSL)    StopLoss = MathMin(UserStopLoss ,StopLoss) ;

       TakeProfit = 0;
       if (UseTP)
       {
          if (UseATRTP) TakeProfit = MathMax(TakeProfit , ATRTP_ratio * ATRBuffer[1]/pip);
          if (UseUserTP) TakeProfit= MathMax(TakeProfit ,UserTakeProfit); 
       }   
       
      CurrentRiskPerTrade = UserRiskPerTrade     ;
      if(DoubleUpMartingale > 1)  CurrentRiskPerTrade = CurrentRiskPerTrade*MathPow(DoubleUpMartingale , Count_consecutive_losses());
      if(Martingale > 1) CurrentRiskPerTrade = CurrentRiskPerTrade*MathPow(Martingale , Calculate_Martingale(-1));
      
      Order_size = CalculateLotSize (StopLoss);      // create sell order
      Order_size = MathMax(Order_size , 0.01);
      if (UseFixedOD) Order_size = NormalizeDouble(CurrentRiskPerTrade * AccountInfoDouble(ACCOUNT_BALANCE) / (100000 ) , 2);

      Print("sell order, Order size is: " , Order_size ,"  ,StopLoss is:" ,StopLoss , "  ,TakeProfit is: " , TakeProfit );
      double price=0;
         positionOpen=false;
         int i=0;
         do
         {
             FillSellData();
             if(OrderSend(request,result))
              {
               positionOpen=true;
              }
             else
             {
               Alert("OrderSend failed with error #" , GetLastError()," price is:" ,price , " ," , rev );
               Print("OrderSend failed with error #" , GetLastError()," price is:" ,price , " ," , rev );
             }
              Sleep(1000);
              i=i+1;
          }
          while(!positionOpen && i<10);
          

      return ticket;
   }

void FillBuyData()
{
          ZeroMemory(request);
         double price=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
         request.action=TRADE_ACTION_DEAL;
         request.type=ORDER_TYPE_BUY;
         request.symbol = _Symbol;
         request.volume = Order_size;
         request.type_filling=ORDER_FILLING_FOK;
         request.price=price;
         if(UseTP && TakeProfit >0) request.tp = price + TakeProfit*pip;
         else request.tp = NULL;
         request.sl = price - StopLoss*pip;
         request.deviation=10;
         request.magic=MagicNumber;

}

void FillSellData()
{

         ZeroMemory(request);
         double price=SymbolInfoDouble(_Symbol,SYMBOL_BID);
         request.action=TRADE_ACTION_DEAL;
         request.type=ORDER_TYPE_SELL;
         request.symbol = _Symbol;
         request.volume = Order_size;
         request.type_filling=ORDER_FILLING_FOK;
         request.price=price;
         if(UseTP && TakeProfit >0) request.tp = price - TakeProfit*pip;
         else request.tp = NULL;
         request.sl = price + StopLoss*pip;
         request.deviation=10;
         request.magic=MagicNumber;

}


/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| Manage Open Trades include                       |
//+------------------------------------------------------------------+
********************************************************************************************************************************/



 

bool manage_SL() //check if SL needs to be updated, if yes: call on function update SL
{
   if(CopyBuffer(ATRHandle,0,0,ATR+2,ATRBuffer)<0) {PrintFormat("Error loading ATR data, code %d",GetLastError()); return false;}
   PT = PositionsTotal();
   while(PT>=0)    //manage buy orders:
   {
         if(posInfo.SelectByIndex(PT))
         {
            if(PositionGetInteger(POSITION_MAGIC)==MagicNumber) 
            {
               if(posInfo.PositionType()==POSITION_TYPE_BUY)
               {  
                      if(PositionGetDouble(POSITION_PRICE_CURRENT) > PositionGetDouble(POSITION_PRICE_OPEN) +ATRTrail_StartMultiplier*ATRBuffer[1] )
                          if(PositionGetDouble(POSITION_PRICE_CURRENT) > PositionGetDouble(POSITION_SL) + ATRTrail_TrailMultiplier*ATRBuffer[1]+pip)
                          {
                                 FinalTrailValue = PositionGetDouble(POSITION_PRICE_CURRENT) -ATRTrail_TrailMultiplier*ATRBuffer[1];
                                 Update_SL(); 
                          }
               }
               else // sell position
               {

                      if(PositionGetDouble(POSITION_PRICE_CURRENT) < PositionGetDouble(POSITION_PRICE_OPEN) -ATRTrail_StartMultiplier*ATRBuffer[1] )
                          if(PositionGetDouble(POSITION_PRICE_CURRENT) < PositionGetDouble(POSITION_SL) - ATRTrail_TrailMultiplier*ATRBuffer[1]-pip)
                          {
                                 FinalTrailValue = PositionGetDouble(POSITION_PRICE_CURRENT) +ATRTrail_TrailMultiplier*ATRBuffer[1];
                                 Update_SL(); 
                          }
                }
             }
     }
    PT = PT-1;
   }
   return true;
}



bool manage_open_trade_GR()
{
         PT = PositionsTotal();
         while(PT>=0)  
         {
            if(posInfo.SelectByIndex(PT))
            {   
               if(PositionGetInteger(POSITION_MAGIC)==MagicNumber) 
               {
                  if(     posInfo.PositionType()==POSITION_TYPE_BUY)
                  {
                        if (RG_R < BuyExitLimitP_RG ) CloseAllTrades(1 );
                        return true;
                  }
                  else if(posInfo.PositionType()==POSITION_TYPE_SELL)
                  {
                        if (GR_R < SellExitLimitP_GR ) CloseAllTrades(-1 );
                        return true;
                  }
               }
            }
            PT--;
         }
    return true;
}

bool manage_timed_exit()
{
         PT = PositionsTotal();
         while(PT>=0)  
         {
            if(posInfo.SelectByIndex(PT))
            {   
               if(PositionGetInteger(POSITION_MAGIC)==MagicNumber) 
               {
                     if (iBarShift(NULL , PERIOD_CURRENT , PositionGetInteger(POSITION_TIME) , false) >=  BarsInTrade)       
                     {            
                              trade.PositionClose(PositionGetTicket(PT));
                     }
                 }
            }
            
            PT--;
         }
    return true;


}


void Update_SL() // update SL
{                             
      trade.PositionModify(posInfo.Ticket() ,FinalTrailValue , PositionGetDouble(POSITION_TP));    
}  


void CheckMAsAlignment ()
{
   if (FastMABuffer[1] < SlowMABuffer[1] && SlowMABuffer[1] < LongMABuffer[1]) MAsAlighn =-1;
   if (FastMABuffer[1] > SlowMABuffer[1] && SlowMABuffer[1] > LongMABuffer[1]) MAsAlighn = 1;
   //Print(MAsAlighn);
}

void CheckMAsAlignment_D ()
{
   if (FastMABuffer_D[1] < SlowMABuffer_D[1] && SlowMABuffer_D[1] < LongMABuffer_D[1]) MAsAlighn_D =-1;
   if (FastMABuffer_D[1] > SlowMABuffer_D[1] && SlowMABuffer_D[1] > LongMABuffer_D[1]) MAsAlighn_D = 1;
}

double check_RatioRGD()
{
   double RedC = 0;
   double GreenC = 0;
   for (int i=1 ; i<=Ratio_CandlesCount ; i++)
   {
         if (  OpenD[i] < CloseD[i]) GreenC++;
         else if (OpenD[i] > CloseD[i])  RedC++;
   }
   return (RedC / GreenC);
}

double check_RatioGRD()
{
   double RedC = 0;
   double GreenC = 0;
   for (int i=1 ; i<=Ratio_CandlesCount ; i++)
   {
         if (  OpenD[i] < CloseD[i]) GreenC++;
         else if (OpenD[i] > CloseD[i])  RedC++;
   }
   return (GreenC / RedC);
}


/*

double check_RatioRGH4()
{
   double RedC = 0;
   double GreenC = 0;
   for (int i=1 ; i<=Ratio_CandlesCount ; i++)
   {
         if (  OpenH4[i] < CloseH4[i]) GreenC++;
         else if (OpenH4[i] > CloseH4[i])  RedC++;
   }
   return (RedC / GreenC);
}

double check_RatioGRH4()
{
   double RedC = 0;
   double GreenC = 0;
   for (int i=1 ; i<=Ratio_CandlesCount ; i++)
   {
         if (  OpenH4[i] < CloseH4[i]) GreenC++;
         else if (OpenH4[i] > CloseH4[i])  RedC++;
   }
   return (GreenC / RedC);
}

*/



/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| Base                              |
//+------------------------------------------------------------------+
********************************************************************************************************************************/
int Candle_color (int candle_i)
{
   if (Close [candle_i] < Open[candle_i]) return (-1);//red
   if (Close [candle_i] > Open[candle_i]) return (1); //green
   return (0); // no body (open==close)
}


double Body_Size (int candle_i)
{
   return (MathAbs( (Close [candle_i] - Open[candle_i] )));
}


double Upper_Wik_Size (int candle_i)
{
   if (Candle_color (candle_i) ==-1) return ( (High[candle_i] - Open [candle_i]));
   else return ( (High [candle_i] - Close[candle_i] ));
}


double Lower_Wik_Size (int candle_i)
{
   if (Candle_color (candle_i) ==-1) return ( (Close[candle_i] - Low [candle_i]));
   else return ( (Open [candle_i] - Low[candle_i] ));
}


double Upper_wik_ratio (int candle_i)
{
   if (Upper_Wik_Size (candle_i) == 0 ) return (1000);
   return (Body_Size (candle_i) / Upper_Wik_Size (candle_i));
}


double Lower_wik_ratio (int candle_i)
{   
   if (Lower_Wik_Size (candle_i) == 0 ) return (1000);
   return (Body_Size (candle_i) / Lower_Wik_Size (candle_i));
}


double wik_ratio (int candle_i)
{
   if (Upper_Wik_Size (candle_i) == 0 &&  Lower_Wik_Size (candle_i) == 0  ) return (10); // no wiks
   return ( Body_Size(candle_i)  / (Upper_Wik_Size (candle_i) + Lower_Wik_Size (candle_i)));
}

bool Is_Marbouzo (int i)
{
         if (Candle_color(i)== 0) return false;
        if (MathMax(Upper_wik_ratio(i),Lower_wik_ratio(i))>=3 && wik_ratio(i)>1.75) return true;
        return false;
}



bool NotGGR()
{
     if (Candle_color(3) == 1 && Candle_color(2) == 1 )
     {
         return false; 
     }
     return true;
}



bool RRR()
{
   if (Candle_color(3) == -1 && Candle_color(2) == -1 && Candle_color(1) == -1 ) return true;
   return false;
}

bool RRG()
{
   if (Candle_color(3) == -1 && Candle_color(2) == -1 && Candle_color(1) == 1 ) return true;
   return false;
}


bool GGG()
{
   if (Candle_color(3) == 1 && Candle_color(2) == 1 && Candle_color(1) == 1 ) return true;
   return false;
}

bool GRG()
{
   if (Candle_color(3) == 1 && Candle_color(2) == -1 && Candle_color(1) == 1 ) return true;
   return false;
}

bool GRR()
{
   if (Candle_color(3) == 1 && Candle_color(2) == -1 && Candle_color(1) == -1 ) return true;
   return false;
}

bool GGR()
{
   if (Candle_color(3) == 1 && Candle_color(2) == 1 && Candle_color(1) == -1 ) return true;
   return false;
}


bool RGR()
{
   if (Candle_color(3) == -1 && Candle_color(2) == 1 && Candle_color(1) == -1 ) return true;
   return false;
}

bool RGG()
{
   if (Candle_color(3) == -1 && Candle_color(2) == 1 && Candle_color(1) == 1 ) return true;
   return false;
}


bool Ham(int i)
{
     if (wik_ratio(i) > 0.3) return false;
     if (Upper_Wik_Size(i) == 0) return true;
     if (Lower_Wik_Size(i) /Upper_Wik_Size(i) >2 ) return true;

     return false;
}


bool InvHam(int i)
{
     if (wik_ratio(i) > 0.3) return false;
     if (Lower_Wik_Size(1) == 0) return true;
     if (Upper_Wik_Size(1) / Lower_Wik_Size(1)  >2 ) return true;

     return false;
}


bool HHHL(int i)
{
   if (High[i] > High[i+1] && Low[i] > Low[i+1]) return true;
   return false;

}

bool LHLL(int i)
{
   if (High[i] < High[i+1] && Low[i] < Low[i+1]) return true;
   return false;

}

bool KangoroTail()
{
   if(Candle_color(1) == 1)
   {
      if (LHLL(2) && HHHL(1))
      {
         return true;
      }
      else return false;
   }
   
   if(Candle_color(1) == -1)
   {
      if (HHHL(2) && LHLL(1))
      {
         return true;
      }
      else return false;
   }
   return false;

}


bool HHHCLLL_C(int i)
{
   if (Candle_color(i) == 1)
      if (Close[i] > Close[i+1] && High[i] > High[i+1])
         return true;
   if (Candle_color(i) == -1)
      if (Close[i] < Close[i+1] && Low[i] < Low[i+1])
         return true;
   return false;
}



bool Out(int i)
{
   if (High[i] > High[i+1] && Low[i] < Low[i+1])
         return true;
   return false;
}



bool InBar(int i)
{
   if (High[i] < High[i+1] && Low[i] > Low[2])
         return true;
   return false;
}



bool Engulf(int i)
{
     if (Candle_color(i) == Candle_color(i+1))
         return false;
         
     if (Candle_color(i) == 1)
     {
         if(Open[i] <= Close[i+1] && Close[i] >= Open[i+1]) return true;
         else return false;   
     }
     
     if (Candle_color(i) == -1)
     {
         if(Open[i] >= Close[i+1] && Close[i] <= Open[i+1]) return true;
         else return false;   
     }
     return false;
}


double CalculateGSV()
{
    UpArr = 0;
    DownArr = 0;
    for (int i = 1 ; i<= PeriodForGSV ; i++)
    {
        UpArr = UpArr+ High[i] - Open[i];
        DownArr = DownArr + Open[i] - Low[i];
               
    }
    LongGSV = UpArr / PeriodForGSV;
    ShortGSV = DownArr / PeriodForGSV;
    if (UpArr > DownArr) return (UpArr / DownArr);
    else return (- DownArr/UpArr);
    
}




/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| H                               |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

/*

int Candle_color_H (int candle_i)
{
   if (CloseH [candle_i] < OpenH[candle_i]) return (-1);//red
   if (CloseH [candle_i] > OpenH[candle_i]) return (1); //green
   return (0); // no body (open==close)
}


double Body_Size_H (int candle_i)
{
   return (MathAbs( (CloseH [candle_i] - OpenH[candle_i] )));
}


double Upper_Wik_Size_H (int candle_i)
{
   if (Candle_color_H (candle_i) ==-1) return ( (HighH[candle_i] - OpenH [candle_i]));
   else return ( (HighH [candle_i] - CloseH[candle_i] ));
}


double Lower_Wik_Size_H (int candle_i)
{
   if (Candle_color_H (candle_i) ==-1) return ( (CloseH[candle_i] - LowH [candle_i]));
   else return ( (OpenH [candle_i] - LowH[candle_i] ));
}


double Upper_wik_ratio_H (int candle_i)
{
   if (Upper_Wik_Size_H (candle_i) == 0 ) return (10);
   return (Body_Size_H (candle_i) / Upper_Wik_Size_H (candle_i));
}


double Lower_wik_ratio_H (int candle_i)
{   
   if (Lower_Wik_Size_H (candle_i) == 0 ) return (10);
   return (Body_Size_H (candle_i) / Lower_Wik_Size_H (candle_i));
}


double wik_ratio_H (int candle_i)
{
   if (Upper_Wik_Size_H (candle_i) == 0 &&  Lower_Wik_Size_H (candle_i) == 0  ) return (10); // no wiks
   return ( Body_Size_H(candle_i)  / (Upper_Wik_Size_H (candle_i) + Lower_Wik_Size_H (candle_i)));
}

bool Is_Marbouzo_H (int i)
{
         if (Candle_color_H(i)== 0) return false;
        if (MathMax(Upper_wik_ratio_H(i),Lower_wik_ratio_H(i))>=3 && wik_ratio_H(i)>1.75) return true;
        return false;
}



bool NotGGR_H()
{
     if (Candle_color_H(3) == 1 && Candle_color_H(2) == 1 )
     {
         return false; 
     }
     return true;
}



bool RRR_H()
{
   if (Candle_color_H(3) == -1 && Candle_color_H(2) == -1 && Candle_color_H(1) == -1 ) return true;
   return false;
}

bool RRG_H()
{
   if (Candle_color_H(3) == -1 && Candle_color_H(2) == -1 && Candle_color_H(1) == 1 ) return true;
   return false;
}


bool GGG_H()
{
   if (Candle_color_H(3) == 1 && Candle_color_H(2) == 1 && Candle_color_H(1) == 1 ) return true;
   return false;
}

bool GRG_H()
{
   if (Candle_color_H(3) == 1 && Candle_color_H(2) == -1 && Candle_color_H(1) == 1 ) return true;
   return false;
}

bool GRR_H()
{
   if (Candle_color_H(3) == 1 && Candle_color_H(2) == -1 && Candle_color_H(1) == -1 ) return true;
   return false;
}

bool GGR_H()
{
   if (Candle_color_H(3) == 1 && Candle_color_H(2) == 1 && Candle_color_H(1) == -1 ) return true;
   return false;
}


bool RGR_H()
{
   if (Candle_color_H(3) == -1 && Candle_color_H(2) == 1 && Candle_color_H(1) == -1 ) return true;
   return false;
}

bool RGG_H()
{
   if (Candle_color_H(3) == -1 && Candle_color_H(2) == 1 && Candle_color_H(1) == 1 ) return true;
   return false;
}


bool Ham_H(int i)
{
     if (wik_ratio_H(i) > 0.3) return false;
     if (Upper_Wik_Size_H(i) == 0) return true;
     if (Lower_Wik_Size_H(i) /Upper_Wik_Size_H(i) >2 ) return true;

     return false;
}


bool InvHam_H(int i)
{
     if (wik_ratio_H(i) > 0.3) return false;
     if (Lower_Wik_Size_H(1) == 0) return true;
     if (Upper_Wik_Size_H(1) / Lower_Wik_Size_H(1)  >2 ) return true;

     return false;
}


bool HHHL_H(int i)
{
   if (HighH[i] > HighH[i+1] && LowH[i] > LowH[i+1]) return true;
   return false;

}

bool LHLL_H(int i)
{
   if (HighH[i] < HighH[i+1] && LowH[i] < LowH[i+1]) return true;
   return false;

}

bool KangoroTail_H()
{
   if(Candle_color_H(1) == 1)
   {
      if (LHLL_H(2) && HHHL_H(1))
      {
         return true;
      }
      else return false;
   }
   
   if(Candle_color_H(1) == -1)
   {
      if (HHHL_H(2) && LHLL_H(1))
      {
         return true;
      }
      else return false;
   }
   return false;

}


bool HHHCLLL_C_H(int i)
{
   if (Candle_color_H(i) == 1)
      if (CloseH[i] > CloseH[i+1] && HighH[i] > HighH[i+1])
         return true;
   if (Candle_color_H(i) == -1)
      if (CloseH[i] < CloseH[i+1] && LowH[i] < LowH[i+1])
         return true;
   return false;
}



bool Out_H(int i)
{
   if (HighH[i] > HighH[i+1] && LowH[i] < LowH[i+1])
         return true;
   return false;
}



bool InBar_H(int i)
{
   if (HighH[i] < HighH[i+1] && LowH[i] > LowH[2])
         return true;
   return false;
}



bool Engulf_H(int i)
{
     if (Candle_color_H(i) == Candle_color_H(i+1))
         return false;
         
     if (Candle_color_H(i) == 1)
     {
         if(OpenH[i] <= CloseH[i+1] && CloseH[i] >= OpenH[i+1]) return true;
         else return false;   
     }
     
     if (Candle_color_H(i) == -1)
     {
         if(OpenH[i] >= CloseH[i+1] && CloseH[i] <= OpenH[i+1]) return true;
         else return false;   
     }
     return false;
}



double CalculateGSV_H()
{
    UpArr = 0;
    DownArr = 0;
    for (int i = 1 ; i<= PeriodForGSV ; i++)
    {
        UpArr = UpArr+ HighH[i] - OpenH[i];
        DownArr = DownArr + OpenH[i] - LowH[i];
               
    }
    LongGSV = UpArr / PeriodForGSV;
    ShortGSV = DownArr / PeriodForGSV;
    if (UpArr > DownArr) return (UpArr / DownArr);
    else return (- DownArr/UpArr);
    
}



/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| H4                                 |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

int Candle_color_H4 (int candle_i)
{
   if (CloseH4 [candle_i] < OpenH4[candle_i]) return (-1);//red
   if (CloseH4 [candle_i] > OpenH4[candle_i]) return (1); //green
   return (0); // no body (open==close)
}


double Body_Size_H4 (int candle_i)
{
   return (MathAbs( (CloseH4 [candle_i] - OpenH4[candle_i] )));
}


double Upper_Wik_Size_H4 (int candle_i)
{
   if (Candle_color_H4 (candle_i) ==-1) return ( (HighH4[candle_i] - OpenH4 [candle_i]));
   else return ( (HighH4 [candle_i] - CloseH4[candle_i] ));
}


double Lower_Wik_Size_H4 (int candle_i)
{
   if (Candle_color_H4 (candle_i) ==-1) return ( (CloseH4[candle_i] - LowH4 [candle_i]));
   else return ( (OpenH4 [candle_i] - LowH4[candle_i] ));
}


double Upper_wik_ratio_H4 (int candle_i)
{
   if (Upper_Wik_Size_H4 (candle_i) == 0 ) return (10);
   return (Body_Size_H4 (candle_i) / Upper_Wik_Size_H4 (candle_i));
}


double Lower_wik_ratio_H4 (int candle_i)
{   
   if (Lower_Wik_Size_H4 (candle_i) == 0 ) return (10);
   return (Body_Size_H4 (candle_i) / Lower_Wik_Size_H4 (candle_i));
}


double wik_ratio_H4 (int candle_i)
{
   if (Upper_Wik_Size_H4 (candle_i) == 0 &&  Lower_Wik_Size_H4 (candle_i) == 0  ) return (10); // no wiks
   return ( Body_Size_H4(candle_i)  / (Upper_Wik_Size_H4 (candle_i) + Lower_Wik_Size_H4 (candle_i)));
}

bool Is_Marbouzo_H4 (int i)
{
         if (Candle_color_H4(i)== 0) return false;
        if (MathMax(Upper_wik_ratio_H4(i),Lower_wik_ratio_H4(i))>=3 && wik_ratio_H4(i)>1.75) return true;
        return false;
}



bool NotGGR_H4()
{
     if (Candle_color_H4(3) == 1 && Candle_color_H4(2) == 1 )
     {
         return false; 
     }
     return true;
}



bool RRR_H4()
{
   if (Candle_color_H4(3) == -1 && Candle_color_H4(2) == -1 && Candle_color_H4(1) == -1 ) return true;
   return false;
}

bool RRG_H4()
{
   if (Candle_color_H4(3) == -1 && Candle_color_H4(2) == -1 && Candle_color_H4(1) == 1 ) return true;
   return false;
}


bool GGG_H4()
{
   if (Candle_color_H4(3) == 1 && Candle_color_H4(2) == 1 && Candle_color_H4(1) == 1 ) return true;
   return false;
}

bool GRG_H4()
{
   if (Candle_color_H4(3) == 1 && Candle_color_H4(2) == -1 && Candle_color_H4(1) == 1 ) return true;
   return false;
}

bool GRR_H4()
{
   if (Candle_color_H4(3) == 1 && Candle_color_H4(2) == -1 && Candle_color_H4(1) == -1 ) return true;
   return false;
}

bool GGR_H4()
{
   if (Candle_color_H4(3) == 1 && Candle_color_H4(2) == 1 && Candle_color_H4(1) == -1 ) return true;
   return false;
}


bool RGR_H4()
{
   if (Candle_color_H4(3) == -1 && Candle_color_H4(2) == 1 && Candle_color_H4(1) == -1 ) return true;
   return false;
}

bool RGG_H4()
{
   if (Candle_color_H4(3) == -1 && Candle_color_H4(2) == 1 && Candle_color_H4(1) == 1 ) return true;
   return false;
}


bool Ham_H4(int i)
{
     if (wik_ratio_H4(i) > 0.3) return false;
     if (Upper_Wik_Size_H4(i) == 0) return true;
     if (Lower_Wik_Size_H4(i) /Upper_Wik_Size_H4(i) >2 ) return true;

     return false;
}


bool InvHam_H4(int i)
{
     if (wik_ratio_H4(i) > 0.3) return false;
     if (Lower_Wik_Size_H4(1) == 0) return true;
     if (Upper_Wik_Size_H4(1) / Lower_Wik_Size_H4(1)  >2 ) return true;

     return false;
}


bool HHHL_H4(int i)
{
   if (HighH4[i] > HighH4[i+1] && LowH4[i] > LowH4[i+1]) return true;
   return false;

}

bool LHLL_H4(int i)
{
   if (HighH4[i] < HighH4[i+1] && LowH4[i] < LowH4[i+1]) return true;
   return false;

}

bool KangoroTail_H4()
{
   if(Candle_color_H4(1) == 1)
   {
      if (LHLL_H4(2) && HHHL_H4(1))
      {
         return true;
      }
      else return false;
   }
   
   if(Candle_color_H4(1) == -1)
   {
      if (HHHL_H4(2) && LHLL_H4(1))
      {
         return true;
      }
      else return false;
   }
   return false;

}


bool HHHCLLL_C_H4(int i)
{
   if (Candle_color_H4(i) == 1)
      if (CloseH4[i] > CloseH4[i+1] && HighH4[i] > HighH4[i+1])
         return true;
   if (Candle_color_H4(i) == -1)
      if (CloseH4[i] < CloseH4[i+1] && LowH4[i] < LowH4[i+1])
         return true;
   return false;
}



bool Out_H4(int i)
{
   if (HighH4[i] > HighH4[i+1] && LowH4[i] < LowH4[i+1])
         return true;
   return false;
}



bool InBar_H4(int i)
{
   if (HighH4[i] < HighH4[i+1] && LowH4[i] > LowH4[2])
         return true;
   return false;
}



bool Engulf_H4(int i)
{
     if (Candle_color_H4(i) == Candle_color_H4(i+1))
         return false;
         
     if (Candle_color_H4(i) == 1)
     {
         if(OpenH4[i] <= CloseH4[i+1] && CloseH4[i] >= OpenH4[i+1]) return true;
         else return false;   
     }
     
     if (Candle_color_H4(i) == -1)
     {
         if(OpenH4[i] >= CloseH4[i+1] && CloseH4[i] <= OpenH4[i+1]) return true;
         else return false;   
     }
     return false;
}




/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| D                                |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

int Candle_color_D (int candle_i)
{
   if (CloseD [candle_i] < OpenD[candle_i]) return (-1);//red
   if (CloseD [candle_i] > OpenD[candle_i]) return (1); //green
   return (0); // no body (open==close)
}


double Body_Size_D (int candle_i)
{
   return (MathAbs( (CloseD [candle_i] - OpenD[candle_i] )));
}


double Upper_Wik_Size_D (int candle_i)
{
   if (Candle_color_D (candle_i) ==-1) return ( (HighD[candle_i] - OpenD [candle_i]));
   else return ( (HighD [candle_i] - CloseD[candle_i] ));
}


double Lower_Wik_Size_D (int candle_i)
{
   if (Candle_color_D (candle_i) ==-1) return ( (CloseD[candle_i] - LowD [candle_i]));
   else return ( (OpenD [candle_i] - LowD[candle_i] ));
}


double Upper_wik_ratio_D (int candle_i)
{
   if (Upper_Wik_Size_D (candle_i) == 0 ) return (10);
   return (Body_Size_D (candle_i) / Upper_Wik_Size_D (candle_i));
}


double Lower_wik_ratio_D (int candle_i)
{   
   if (Lower_Wik_Size_D (candle_i) == 0 ) return (10);
   return (Body_Size_D (candle_i) / Lower_Wik_Size_D (candle_i));
}


double wik_ratio_D (int candle_i)
{
   if (Upper_Wik_Size_D (candle_i) == 0 &&  Lower_Wik_Size_D (candle_i) == 0  ) return (10); // no wiks
   return ( Body_Size_D(candle_i)  / (Upper_Wik_Size_D (candle_i) + Lower_Wik_Size_D (candle_i)));
}

bool Is_Marbouzo_D (int i)
{
         if (Candle_color_D(i)== 0) return false;
        if (MathMax(Upper_wik_ratio_D(i),Lower_wik_ratio_D(i))>=3 && wik_ratio_D(i)>1.75) return true;
        return false;
}



bool NotGGR_D()
{
     if (Candle_color_D(3) == 1 && Candle_color_D(2) == 1 )
     {
         return false; 
     }
     return true;
}



bool RRR_D()
{
   if (Candle_color_D(3) == -1 && Candle_color_D(2) == -1 && Candle_color_D(1) == -1 ) return true;
   return false;
}

bool RRG_D()
{
   if (Candle_color_D(3) == -1 && Candle_color_D(2) == -1 && Candle_color_D(1) == 1 ) return true;
   return false;
}


bool GGG_D()
{
   if (Candle_color_D(3) == 1 && Candle_color_D(2) == 1 && Candle_color_D(1) == 1 ) return true;
   return false;
}

bool GRG_D()
{
   if (Candle_color_D(3) == 1 && Candle_color_D(2) == -1 && Candle_color_D(1) == 1 ) return true;
   return false;
}

bool GRR_D()
{
   if (Candle_color_D(3) == 1 && Candle_color_D(2) == -1 && Candle_color_D(1) == -1 ) return true;
   return false;
}

bool GGR_D()
{
   if (Candle_color_D(3) == 1 && Candle_color_D(2) == 1 && Candle_color_D(1) == -1 ) return true;
   return false;
}


bool RGR_D()
{
   if (Candle_color_D(3) == -1 && Candle_color_D(2) == 1 && Candle_color_D(1) == -1 ) return true;
   return false;
}

bool RGG_D()
{
   if (Candle_color_D(3) == -1 && Candle_color_D(2) == 1 && Candle_color_D(1) == 1 ) return true;
   return false;
}


bool Ham_D(int i)
{
     if (wik_ratio_D(i) > 0.3) return false;
     if (Upper_Wik_Size_D(i) == 0) return true;
     if (Lower_Wik_Size_D(i) /Upper_Wik_Size_D(i) >2 ) return true;

     return false;
}


bool InvHam_D(int i)
{
     if (wik_ratio_D(i) > 0.3) return false;
     if (Lower_Wik_Size_D(1) == 0) return true;
     if (Upper_Wik_Size_D(1) / Lower_Wik_Size_D(1)  >2 ) return true;

     return false;
}


bool HHHL_D(int i)
{
   if (HighD[i] > HighD[i+1] && LowD[i] > LowD[i+1]) return true;
   return false;

}

bool LHLL_D(int i)
{
   if (HighD[i] < HighD[i+1] && LowD[i] < LowD[i+1]) return true;
   return false;

}

bool KangoroTail_D()
{
   if(Candle_color_D(1) == 1)
   {
      if (LHLL_D(2) && HHHL_D(1))
      {
         return true;
      }
      else return false;
   }
   
   if(Candle_color_D(1) == -1)
   {
      if (HHHL_D(2) && LHLL_D(1))
      {
         return true;
      }
      else return false;
   }
   return false;

}


bool HHHCLLL_C_D(int i)
{
   if (Candle_color_D(i) == 1)
      if (CloseD[i] > CloseD[i+1] && HighD[i] > HighD[i+1])
         return true;
   if (Candle_color_D(i) == -1)
      if (CloseD[i] < CloseD[i+1] && LowD[i] < LowD[i+1])
         return true;
   return false;
}



bool Out_D(int i)
{
   if (HighD[i] > HighD[i+1] && LowD[i] < LowD[i+1])
         return true;
   return false;
}



bool InBar_D(int i)
{
   if (HighD[i] < HighD[i+1] && LowD[i] > LowD[2])
         return true;
   return false;
}



bool Engulf_D(int i)
{
     if (Candle_color_D(i) == Candle_color_D(i+1))
         return false;
         
     if (Candle_color_D(i) == 1)
     {
         if(OpenD[i] <= CloseD[i+1] && CloseD[i] >= OpenD[i+1]) return true;
         else return false;   
     }
     
     if (Candle_color_D(i) == -1)
     {
         if(OpenD[i] >= CloseD[i+1] && CloseD[i] <= OpenD[i+1]) return true;
         else return false;   
     }
     return false;
}


