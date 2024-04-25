//+------------------------------------------------------------------+
//|                                               MST MA Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"







//+------------------------------------------------------------------+
//| MA Include varibales                         |
//+------------------------------------------------------------------+

input group "MA parameters"; 

input int FastMA = 7;
input int SlowMA = 21;
input int LongMA = 50;
input int MALookBackBars = 3;
input bool UseEMA = false;
int MAsAlighn[];


ArraySet  FastMABuffer[];
ArraySet  SlowMABuffer[];
ArraySet  LongMABuffer[];
int      FastMAHandle[];
int      SlowMAHandle[];
int      LongMAHandle[];




void CheckMAsAlignment (int sym)
{
   MAsAlighn[sym] =0;
   if (FastMABuffer[sym].b[1] < SlowMABuffer[sym].b[1] && SlowMABuffer[sym].b[1] < LongMABuffer[sym].b[1]) MAsAlighn[sym] =-1;
   else if (FastMABuffer[sym].b[1] > SlowMABuffer[sym].b[1] && SlowMABuffer[sym].b[1] > LongMABuffer[sym].b[1]) MAsAlighn[sym] = 1;
}



bool MA_check_is_buy (int sym)
{   
    if (  FastMABuffer[sym].b[MALookBackBars+1] > SlowMABuffer[sym].b[MALookBackBars+1] ) return false ;
    for (int i = MALookBackBars ; i>0 ; i--)
    {
       if (  FastMABuffer[sym].b[i] < SlowMABuffer[sym].b[i] ) return false ;
    }
    return ( true );
}    


bool MA_check_is_sell (int sym)
{   
    if (  FastMABuffer[sym].b[MALookBackBars+1] < SlowMABuffer[sym].b[MALookBackBars+1] ) return false ;
    for (int i = MALookBackBars ; i>0 ; i--)
    {
       if (  FastMABuffer[sym].b[i] > SlowMABuffer[sym].b[i] ) return false ;
    }
    return ( true );
}     



void ManageMAExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(MA_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(MA_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}


void ManagePriceCrossMAExit(int sym)
{
      if (Close[Main_TF_N].a[sym].b[1] > LongMABuffer[sym].b[1]  )
         if (Close[Main_TF_N].a[sym].b[2] < LongMABuffer[sym].b[2]  )
         {
            CloseAllTrades(1 , sym );
            return;
         }
      if (Close[Main_TF_N].a[sym].b[1] < LongMABuffer[sym].b[1]  )
         if (Close[Main_TF_N].a[sym].b[2] > LongMABuffer[sym].b[2]  )
            CloseAllTrades(-1, sym );
}

