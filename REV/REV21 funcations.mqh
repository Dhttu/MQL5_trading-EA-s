//+------------------------------------------------------------------+
//|                                             REV21 funcations.mqh |
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



COrderInfo orderInfo;
CDealInfo dealInfo;
MqlDateTime dt_struct;
CTrade trade;
CAccountInfo accInfo;
CPositionInfo posInfo;
CSymbolInfo symInfo;
MqlTradeRequest request;
MqlTradeResult result;
int history=100;
int PT = 0; // Poistions Total




//--- price buffers
double Close[], Open[], High[] , Low[] ,CloseH4[], OpenH4[], HighH4[] , LowH4[]  ,CloseD[] , OpenD[] , HighD[] , LowD[] ;
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


double  ADXBuffer[];
int      ADXHandle;

double  ATRBuffer[];
int      ATRHandle;
int      ATR = 14;

double  ATRH4Buffer[];
int      ATRH4Handle;


int base_yearly_trades = 8;

datetime EndOfTest; 
datetime StartOfTest;


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

double upperBandBufferH4[];
double middleBandBufferH4[];
double lowerBandBufferH4[];
int bandHandleH4=0;

double upperBandBufferH[];
double middleBandBufferH[];
double lowerBandBufferH[];
int bandHandleH=0;




double GR_R , RG_R ;

double GSV, LongGSV , ShortGSV;
double DownArr , UpArr;



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




void CloseAllTrades (int Direc)
{
     
     if (Direc == 1) //close buy trades
     {
         Print("close all buy trades " , rev);
         for(int k=PositionsTotal()-1;k>=0;k--)
           {   
              if(PositionGetInteger(POSITION_MAGIC)==MagicNumber) 
                  if ( posInfo.PositionType()==POSITION_TYPE_BUY ) 
                       trade.PositionClose(PositionGetTicket(k));
           }
           
     }
     else //close sell trades
     {
         Print("close all sell trades " , rev );
         for(int k=PositionsTotal()-1;k>=0;k--)
           {
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
      //      if (UseATRSL) StopLoss = MathMin(ATRMultiplier*(ATRBuffer[1]/pip) ,StopLoss) ;
      
      
       TakeProfit = 0;
       if (UseTP)
       {
          //if (UseRRTP) TakeProfit = StopLoss * RR_ratio;
          if (UseATRTP) TakeProfit = MathMax(TakeProfit , ATRTP_ratio * ATRBuffer[1]/pip);
          if (UseUserTP) TakeProfit=   MathMax(TakeProfit ,UserTakeProfit);
       }         
      CurrentRiskPerTrade = UserRiskPerTrade*MathPow(Martingale , Calculate_Martingale(1));
      Order_size = CalculateLotSize(StopLoss);
      Order_size = MathMax(Order_size , 0.01);
      
      Print("buy order, Order size is: " , Order_size ,"  ,StopLoss is:" ,StopLoss , "  ,TakeProfit is: " , TakeProfit );
      
      
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
      
          if(OrderSend(request,result))
           {
            positionOpen=true;
           }
          else
          {
            Alert("OrderSend failed with error #" , GetLastError()," price is:" ,price , " ," , rev );
            Print("OrderSend failed with error #" , GetLastError()," price is:" ,price , " ," , rev );
          }

      return ticket;
   }
 

int PlaceSellOrder()//need to update per creteria of SL TP manage trade ext
   {
     
      StopLoss = 2500;
      if (UseCandlesSL) Calculate_CandlesSL (-1) ;
      if (UseUserSL)    StopLoss = MathMin(UserStopLoss ,StopLoss) ;
      //      if (UseATRSL) StopLoss = MathMin(ATRMultiplier*(ATRBuffer[1]/pip) ,StopLoss) ;

       TakeProfit = 0;
       if (UseTP)
       {
          //if (UseRRTP) TakeProfit = StopLoss * RR_ratio;
          if (UseATRTP) TakeProfit = MathMax(TakeProfit , ATRTP_ratio * ATRBuffer[1]/pip);
          if (UseUserTP) TakeProfit= MathMax(TakeProfit ,UserTakeProfit); 
       }   
      CurrentRiskPerTrade = UserRiskPerTrade*MathPow(Martingale , Calculate_Martingale(-1));
      Order_size = CalculateLotSize (StopLoss);      // create sell order
      Order_size = MathMax(Order_size , 0.01);
      
      Print("sell order, Order size is: " , Order_size ,"  ,StopLoss is:" ,StopLoss , "  ,TakeProfit is: " , TakeProfit );

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
         if(OrderSend(request,result))
           {
            positionOpen=true;
           }
         else
         {
            Alert("OrderSend failed with error #" , GetLastError()," price is:" ,price , " ," , rev );
            Print("OrderSend failed with error #" , GetLastError()," price is:" ,price , " ," , rev );
         }

      return ticket;
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
                  if(UseMoveToBreakeven) 
                     if(PositionGetDouble(POSITION_SL) < PositionGetDouble(POSITION_PRICE_OPEN))
                          if(PositionGetDouble(POSITION_PRICE_CURRENT) > PositionGetDouble(POSITION_PRICE_OPEN) + TrailATR_BERatio*ATRBuffer[1])
                          {
                                 FinalTrailValue = PositionGetDouble(POSITION_PRICE_OPEN) + pip;
                                 Update_SL(); 
                          }
                   if(UseATRTrail) 
                      if(PositionGetDouble(POSITION_PRICE_CURRENT) > PositionGetDouble(POSITION_PRICE_OPEN) +ATRTrail_StartMultiplier*ATRBuffer[1] )
                          if(PositionGetDouble(POSITION_PRICE_CURRENT) > PositionGetDouble(POSITION_SL) + ATRTrail_TrailMultiplier*ATRBuffer[1]+pip)
                          {
                                 FinalTrailValue = PositionGetDouble(POSITION_PRICE_CURRENT) -ATRTrail_TrailMultiplier*ATRBuffer[1];
                                 Update_SL(); 
                          }
               }
               else // sell position
               {
                  if(UseMoveToBreakeven) 
                      if(PositionGetDouble(POSITION_SL) > PositionGetDouble(POSITION_PRICE_OPEN))
                          if(PositionGetDouble(POSITION_PRICE_CURRENT) < PositionGetDouble(POSITION_PRICE_OPEN) - TrailATR_BERatio*ATRBuffer[1])
                          {
                                 FinalTrailValue = PositionGetDouble(POSITION_PRICE_OPEN) - pip;
                                 Update_SL(); 
                          }
                          
                   if(UseATRTrail) 
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



bool manage_open_trade() // manage open trades per user settings
{
         if (!UseDailyProfitTrade)  return false;
         PT = PositionsTotal();
         while(PT>=0)  
         {
            if(posInfo.SelectByIndex(PT))
            {   
               if(PositionGetInteger(POSITION_MAGIC)==MagicNumber) 
               {
                  if (UseDailyProfitTrade)
                  {
                     if (iBarShift(NULL , PERIOD_D1 , PositionGetInteger(POSITION_TIME) , false) >=  WaitXDaysBeforeExit)       
                     {            
                         if(PositionGetDouble(POSITION_PROFIT) > 0) 
                         {
                              if      ( posInfo.PositionType()==POSITION_TYPE_BUY ) trade.PositionClose(PositionGetTicket(PT));
                              else if ( posInfo.PositionType()==POSITION_TYPE_SELL ) trade.PositionClose(PositionGetTicket(PT));
                         }
                     }
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
   if (Upper_Wik_Size (candle_i) == 0 ) return (10);
   return (Body_Size (candle_i) / Upper_Wik_Size (candle_i));
}


double Lower_wik_ratio (int candle_i)
{   
   if (Lower_Wik_Size (candle_i) == 0 ) return (10);
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
        if (MathMax(Upper_wik_ratio(i),Lower_wik_ratio(i))>=4 && wik_ratio(i)>2.5) return true;
        return false;
}

bool NotLLLC()
{
     if (Close[1] < Close[2] && Low[1] < Low[2])
     {
         return false; 
     }
     return true;
}

bool InvHam(int i)
{
     if (wik_ratio(i) > 0.25) return false;
     if (Lower_Wik_Size(1) == 0) return true;
     if (Upper_Wik_Size(1) / Lower_Wik_Size(1)  >2.5 ) return true;

     return false;
}



bool Not2Marb()
{
     if (Is_Marbouzo(1) && Is_Marbouzo(2)) return false;
     return true;
}



bool GRG()
{
     if (Candle_color(3) == 1 && Candle_color(2) == -1 && Candle_color(1) == 1) return true;
     return false;
}

bool GGG()
{
     if (Candle_color(3) == 1 && Candle_color(2) == 1 && Candle_color(1) == 1) return true;
     return false;
}

bool RGR()
{
     if (Candle_color(3) == -1 && Candle_color(2) == 1 && Candle_color(1) == -1) return true;
     return false;
}


bool GRR()
{
     if (Candle_color(3) == 1 && Candle_color(2) == -1 && Candle_color(1) == -1) return true;
     return false;
}


bool GGR()
{
     if (Candle_color(3) == 1 && Candle_color(2) == 1 && Candle_color(1) == -1) return true;
     return false;
}


bool RRR()
{
     if (Candle_color(3) == -1 && Candle_color(2) == -1 && Candle_color(1) == -1) return true;
     return false;
}

bool RRG()
{
     if (Candle_color(3) == -1 && Candle_color(2) == -1 && Candle_color(1) == 1) return true;
     return false;
}

bool RGG()
{
     if (Candle_color(3) == -1 && Candle_color(2) == 1 && Candle_color(1) == 1) return true;
     return false;
}


bool HHUHCLLLC(int i)
{
   if (Candle_color(i) == 1)
      if (Close[i] > Close[i+1] && High[i] > High[i+1])
         return true;
   if (Candle_color(i) == -1)
      if (Close[i] < Close[i+1] && Low[i] < Low[i+1])
         return true;
   return false;
}


bool InBar(int i)
{
   if (High[i] < High[i+1] && Low[i] > Low[i+1])
         return true;
   return false;
}


bool Out(int i)
{
   if (High[i] > High[i+1] && Low[i] < Low[i+1])
         return true;
   return false;
}


bool Ham(int i)
{
     if (wik_ratio(i) > 0.25) return false;
     if (Upper_Wik_Size(i) == 0) return true;
     if (Lower_Wik_Size(i) /Upper_Wik_Size(i) >2.5 ) return true;

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
     
     if (Candle_color(1) == -1)
     {
         if(Open[i] >= Close[i+1] && Close[i] <= Open[i+1]) return true;
         else return false;   
     }
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
      return false;
   }
   
   if(Candle_color(1) == -1)
   {
      if (HHHL(2) && LHLL(1))
      {
         return true;
      }
      return false;
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
//| H4                                 |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

int Candle_colorH4 (int candle_i)
{
   if (CloseH4 [candle_i] < OpenH4[candle_i]) return (-1);//red
   if (CloseH4 [candle_i] > OpenH4[candle_i]) return (1); //green
   return (0); // no body (open==close)
}


double Body_SizeH4 (int candle_i)
{
   return (MathAbs( (CloseH4 [candle_i] - OpenH4[candle_i] )));
}


double Upper_Wik_SizeH4 (int candle_i)
{
   if (Candle_colorH4 (candle_i) ==-1) return ( (HighH4[candle_i] - OpenH4 [candle_i]));
   else return ( (HighH4 [candle_i] - CloseH4[candle_i] ));
}


double Lower_Wik_SizeH4 (int candle_i)
{
   if (Candle_colorH4 (candle_i) ==-1) return ( (CloseH4[candle_i] - LowH4 [candle_i]));
   else return ( (OpenH4 [candle_i] - LowH4[candle_i] ));
}


double Upper_wik_ratioH4 (int candle_i)
{
   if (Upper_Wik_SizeH4 (candle_i) == 0 ) return (10);
   return (Body_SizeH4 (candle_i) / Upper_Wik_SizeH4 (candle_i));
}


double Lower_wik_ratioH4 (int candle_i)
{   
   if (Lower_Wik_SizeH4 (candle_i) == 0 ) return (10);
   return (Body_SizeH4 (candle_i) / Lower_Wik_SizeH4 (candle_i));
}


double wik_ratioH4 (int candle_i)
{
   if (Upper_Wik_SizeH4 (candle_i) == 0 &&  Lower_Wik_SizeH4 (candle_i) == 0  ) return (10); // no wiks
   return ( Body_SizeH4(candle_i)  / (Upper_Wik_SizeH4 (candle_i) + Lower_Wik_SizeH4 (candle_i)));
}

bool Is_MarbouzoH4 (int i)
{
         if (Candle_colorH4(i)== 0) return false;
        if (MathMax(Upper_wik_ratioH4(i),Lower_wik_ratioH4(i))>=4 && wik_ratioH4(i)>2.5) return true;
        return false;
}

bool NotGGRH4()
{
     if (Candle_colorH4(3) == 1 && Candle_colorH4(2) == 1 )
     {
         return false; 
     }
     return true;
}


bool ThrClrH4GRR()
{
   if (Candle_colorH4(3) == 1 && Candle_colorH4(2) == -1 && Candle_colorH4(1) == -1 ) return true;
   return false;

}



bool ThrClrH4RGG()
{
   if (Candle_colorH4(3) == -1 && Candle_colorH4(2) == 1 && Candle_colorH4(1) == 1 ) return true;
   return false;


}




bool ThrClrH4RGR()
{
   if (Candle_colorH4(3) == -1 && Candle_colorH4(2) == 1 && Candle_colorH4(1) == -1 ) return true;
   return false;


}

bool ThrClrH4RRG()
{
   if (Candle_colorH4(3) == -1 && Candle_colorH4(2) == -1 && Candle_colorH4(1) == 1 ) return true;
   return false;


}

bool ThrClrH4RRR()
{
   if (Candle_colorH4(3) == -1 && Candle_colorH4(2) == -1 && Candle_colorH4(1) == -1 ) return true;
   return false;


}

bool ThrClrH4GGG()
{
   if (Candle_colorH4(3) == 1 && Candle_colorH4(2) == 1 && Candle_colorH4(1) == 1 ) return true;
   return false;
}


bool ThrClrH4GGR()
{
   if (Candle_colorH4(3) == 1 && Candle_colorH4(2) == 1 && Candle_colorH4(1) == -1 ) return true;
   return false;
}

bool ThrClrH4GRG()
{
   if (Candle_colorH4(3) == 1 && Candle_colorH4(2) == -1 && Candle_colorH4(1) == 1 ) return true;
   return false;
}



bool HamH4(int i)
{
     if (wik_ratioH4(i) > 0.25) return false;
     if (Upper_Wik_SizeH4(i) == 0) return true;
     if (Lower_Wik_SizeH4(i) /Upper_Wik_SizeH4(i) >2.5 ) return true;

     return false;
}


bool InvHamH4(int i)
{
     if (wik_ratioH4(i) > 0.25) return false;
     if (Lower_Wik_SizeH4(1) == 0) return true;
     if (Upper_Wik_SizeH4(1) / Lower_Wik_SizeH4(1)  >2.5 ) return true;

     return false;
}


bool HHHLH4(int i)
{
   if (HighH4[i] > HighH4[i+1] && LowH4[i] > LowH4[i+1]) return true;
   return false;

}

bool LHLLH4(int i)
{
   if (HighH4[i] < HighH4[i+1] && LowH4[i] < LowH4[i+1]) return true;
   return false;

}

bool KangoroTailH4()
{
   if(Candle_colorH4(1) == 1)
   {
      if (LHLLH4(2) && HHHLH4(1))
      {
         return true;
      }
      else return false;
   }
   
   if(Candle_colorH4(1) == -1)
   {
      if (HHHLH4(2) && LHLLH4(1))
      {
         return true;
      }
      else return false;
   }
   return false;

}


bool HHUHCLLLCH4(int i)
{
   if (Candle_colorH4(i) == 1)
      if (CloseH4[i] > CloseH4[i+1] && HighH4[i] > HighH4[i+1])
         return true;
   if (Candle_colorH4(i) == -1)
      if (CloseH4[i] < CloseH4[i+1] && LowH4[i] < LowH4[i+1])
         return true;
   return false;
}



bool OutH4(int i)
{
   if (HighH4[i] > HighH4[i+1] && LowH4[i] < LowH4[i+1])
         return true;
   return false;
}



bool InBarH4(int i)
{
   if (HighH4[i] < HighH4[i+1] && LowH4[i] > LowH4[2])
         return true;
   return false;
}



bool EngulfH4(int i)
{
     if (Candle_colorH4(i) == Candle_colorH4(i+1))
         return false;
         
     if (Candle_colorH4(i) == 1)
     {
         if(OpenH4[i] <= CloseH4[i+1] && CloseH4[i] >= OpenH4[i+1]) return true;
         else return false;   
     }
     
     if (Candle_colorH4(i) == -1)
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

int Candle_colorD (int candle_i)
{
   if (CloseD [candle_i] < OpenD[candle_i]) return (-1);//red
   if (CloseD [candle_i] > OpenD[candle_i]) return (1); //green
   return (0); // no body (open==close)
}


double Body_SizeD (int candle_i)
{
   return (MathAbs( (CloseD [candle_i] - OpenD[candle_i] )));
}


double Upper_Wik_SizeD (int candle_i)
{
   if (Candle_colorD (candle_i) ==-1) return ( (HighD[candle_i] - OpenD [candle_i]));
   else return ( (HighD [candle_i] - CloseD[candle_i] ));
}


double Lower_Wik_SizeD (int candle_i)
{
   if (Candle_colorD (candle_i) ==-1) return ( (CloseD[candle_i] - LowD [candle_i]));
   else return ( (OpenD [candle_i] - LowD[candle_i] ));
}


double Upper_wik_ratioD (int candle_i)
{
   if (Upper_Wik_SizeD (candle_i) == 0 ) return (10);
   return (Body_SizeD (candle_i) / Upper_Wik_SizeD (candle_i));
}


double Lower_wik_ratioD (int candle_i)
{   
   if (Lower_Wik_SizeD (candle_i) == 0 ) return (10);
   return (Body_SizeD (candle_i) / Lower_Wik_SizeD (candle_i));
}


double wik_ratioD (int candle_i)
{
   if (Upper_Wik_SizeD (candle_i) == 0 &&  Lower_Wik_SizeD (candle_i) == 0  ) return (10); // no wiks
   return ( Body_SizeD(candle_i)  / (Upper_Wik_SizeD (candle_i) + Lower_Wik_SizeD (candle_i)));
}

bool Is_MarbouzoD (int i)
{
         if (Candle_colorD(i)== 0) return false;
        if (MathMax(Upper_wik_ratioD(i),Lower_wik_ratioD(i))>=4 && wik_ratioD(i)>2.5) return true;
        return false;
}

bool InvHamD(int i)
{
     if (wik_ratioD(i) > 0.25) return false;
     if (Lower_Wik_SizeD(1) == 0) return true;
     if (Upper_Wik_SizeD(1) / Lower_Wik_SizeD(1)  >2.5 ) return true;

     return false;
}


bool HHUHCLLLCD(int i)
{
   if (Candle_colorD(i) == 1)
      if (CloseD[i] > CloseD[i+1] && HighD[i] > HighD[i+1])
         return true;
   if (Candle_colorD(i) == -1)
      if (CloseD[i] < CloseD[i+1] && LowD[i] < LowD[i+1])
         return true;
   return false;
}

bool OutD(int i)
{
   if (HighD[i] > HighD[i+1] && LowD[i] < LowD[i+1])
         return true;
   return false;
}


bool InBarD(int i)
{
   if (HighD[i] < HighD[i+1] && LowD[i] > LowD[i+1])
         return true;
   return false;
}



bool HamD(int i)
{
     if (wik_ratioD(i) > 0.25) return false;
     if (Upper_Wik_SizeD(i) == 0) return true;
     if (Lower_Wik_SizeD(i) /Upper_Wik_SizeD(i) >2.5 ) return true;

     return false;
}

bool RRR_D()
{
   if (Candle_colorD(3) == -1 && Candle_colorD(2) == -1 && Candle_colorD(1) == -1 ) return true;
   return false;
}

bool RRG_D()
{
   if (Candle_colorD(3) == -1 && Candle_colorD(2) == -1 && Candle_colorD(1) == 1 ) return true;
   return false;
}


bool GGG_D()
{
   if (Candle_colorD(3) == 1 && Candle_colorD(2) == 1 && Candle_colorD(1) == 1 ) return true;
   return false;
}

bool GRG_D()
{
   if (Candle_colorD(3) == 1 && Candle_colorD(2) == -1 && Candle_colorD(1) == 1 ) return true;
   return false;
}

bool GRR_D()
{
   if (Candle_colorD(3) == 1 && Candle_colorD(2) == -1 && Candle_colorD(1) == -1 ) return true;
   return false;
}

bool GGR_D()
{
   if (Candle_colorD(3) == 1 && Candle_colorD(2) == 1 && Candle_colorD(1) == -1 ) return true;
   return false;
}


bool RGR_D()
{
   if (Candle_colorD(3) == -1 && Candle_colorD(2) == 1 && Candle_colorD(1) == -1 ) return true;
   return false;
}

bool RGG_D()
{
   if (Candle_colorD(3) == -1 && Candle_colorD(2) == 1 && Candle_colorD(1) == 1 ) return true;
   return false;
}

bool HHHLD(int i)
{
   if (HighD[i] > HighD[i+1] && LowD[i] > LowD[i+1]) return true;
   return false;

}

bool LHLLD(int i)
{
   if (HighD[i] < HighD[i+1] && LowD[i] < LowD[i+1]) return true;
   return false;

}

bool KangoroTailD()
{
   if(Candle_colorD(1) == 1)
   {
      if (LHLLD(2) && HHHLD(1))
      {
         return true;
      }
      else return false;
   }
   
   if(Candle_colorD(1) == -1)
   {
      if (HHHLD(2) && LHLLD(1))
      {
         return true;
      }
      else return false;
   }
   return false;

}



bool EngulfD(int i)
{
     if (Candle_colorD(i) == Candle_colorD(i+1))
         return false;
         
     if (Candle_colorD(i) == 1)
     {
         if(OpenD[i] <= CloseD[i+1] && CloseD[i] >= OpenD[i+1]) return true;
         else return false;   
     }
     
     if (Candle_colorD(i) == -1)
     {
         if(OpenD[i] >= CloseD[i+1] && CloseD[i] <= OpenD[i+1]) return true;
         else return false;   
     }
     return false;
}



      /*       
double CalculateGSV_D()
{
    UpArr = 0;
    DownArr = 0;
    for (int i = 1 ; i<= PeriodForGSV ; i++)
    {
        UpArr = UpArr+ HighD[i] - OpenD[i];
        DownArr = DownArr + OpenD[i] - LowD[i];
               
    }
    LongGSV = UpArr / PeriodForGSV;
    ShortGSV = DownArr / PeriodForGSV;
    if (UpArr > DownArr) return (UpArr / DownArr);
    else return (- DownArr/UpArr);
    
}

*/