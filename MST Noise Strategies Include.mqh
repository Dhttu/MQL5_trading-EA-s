//+------------------------------------------------------------------+
//|                                 MST Noise Strategies Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"






/*******************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//|                                                                  |
//| #include ER - Kaufman's Efficiency Ratio                                     |
//|                                                                  |
//+------------------------------------------------------------------+
*********************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*********************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*********************************************************************************************************************************/





input group "Efficincy Ratio parameters"; 
input int ER_CandlesCount = 20;
input double ER_LowExitValue = 0;
input double ER_HighAgainstExitValue = 1;

double ER_R[] , ER_R_D[];





/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| ER - Main TF                              |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

double check_RatioER(int sym)
{
   double Change = MathAbs(Close[Main_TF_N].a[sym].b[1] - Close[Main_TF_N].a[sym].b[1+ER_CandlesCount]);
   double Derivitive = 0;
   for (int i=1 ; i<=ER_CandlesCount ; i++)
   {
      Derivitive = Derivitive + MathAbs(Close[Main_TF_N].a[sym].b[i] - Close[Main_TF_N].a[sym].b[i+1]);
   }
   return (Change / Derivitive );
}


void ManageERHighNoiseExit(int sym)
{
         if (ER_R[sym] < ER_LowExitValue )
         {
                CloseAllTrades(1 , sym );
                return ;
         }
         if (ER_R[sym] < ER_LowExitValue )
                   CloseAllTrades(-1, sym );
}


void ManageERLowNoiseAgainstExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if (ER_R[sym] > ER_HighAgainstExitValue )
         if (Candle_color (1 , Main_TF_N , sym) == -1)
         {
            trade.PositionClose(PositionGetTicket(Pos));
            return;
         }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if (ER_R[sym] > ER_HighAgainstExitValue )
         if (Candle_color (1 , Main_TF_N , sym) == 1)
            trade.PositionClose(PositionGetTicket(Pos));
}





/*******************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//|                                                                  |
//| #include KAMA                                       |
//|                                                                  |
//+------------------------------------------------------------------+
*********************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*********************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*********************************************************************************************************************************/



double KAMA[] ;
double PrevKAMA[];

double KAMA_D[] ;
double PrevKAMA_D[];

double SC1 = 0.602151;
double SC2 = 0.064516;


/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| KAMA - Main TF                              |
//+------------------------------------------------------------------+
********************************************************************************************************************************/




void InitiateKAMA(int sym)
{
   int first_value = Indicatorhistory-1;
   PrevKAMA[sym] = Close[Main_TF_N].a[sym].b[first_value];
   for (int i = first_value-1 ; i>1 ; i--)
   {
      double SC = MathPow(check_PastER(i , sym)*SC1 + SC2 , 2);
      KAMA[sym] = PrevKAMA[sym] + SC*(Close[Main_TF_N].a[sym].b[i] - PrevKAMA[sym]);
      PrevKAMA[sym] = KAMA[sym];
   }
}

double check_PastER(int candle , int sym)
{
   candle = candle+1;
   double Change = MathAbs(Close[Main_TF_N].a[sym].b[candle] - Close[Main_TF_N].a[sym].b[candle+ER_CandlesCount]);
   double Derivitive = 0;
   for (int i=candle ; i<=candle+ER_CandlesCount ; i++)
   {
      Derivitive = Derivitive + MathAbs(Close[Main_TF_N].a[sym].b[i] - Close[Main_TF_N].a[sym].b[i+1]);
   }
   return (Change / Derivitive );
}

void check_KAMA(int sym)
{
      double SC = MathPow(ER_R[sym]*SC1 + SC2 , 2);
      PrevKAMA[sym] = KAMA[sym];
      KAMA[sym] = PrevKAMA[sym] + SC*(Close[Main_TF_N].a[sym].b[1] - PrevKAMA[sym]);
}





bool KAMA_check_is_buy (int sym)
{   
   if(Close[Main_TF_N].a[sym].b[1] > KAMA[sym])
      if(Close[Main_TF_N].a[sym].b[2] < PrevKAMA[sym])
             return ( true );
   return false;
}    


bool KAMA_check_is_sell (int sym)
{   
   if(Close[Main_TF_N].a[sym].b[1] < KAMA[sym])
      if(Close[Main_TF_N].a[sym].b[2] > PrevKAMA[sym])
             return ( true );
   return false;
}     



void ManageKAMAExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(KAMA_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(KAMA_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}




