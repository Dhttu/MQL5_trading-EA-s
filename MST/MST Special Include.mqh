//+------------------------------------------------------------------+
//|                                                  MST Special.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"

input group "Special"; 
input int Special_id = 1;
input int XbarsSpecial = 5;
input int Xbars2ndSpecial = 5;
input int SpecialIndicatorPeriod = 3;
input double SpecialMultiplierEntery = 0.01;
input double SpecialMultiplierSL = 2.0;



void InitiateSpecial()
{
    switch(Special_id)
    {
      case 102:
         Calc_MA=true;
         return ;
         break;
      case 104:
         Calc_BB=true;
         return ;
         break;
      default:
         return; 
         break;
    }


}


bool Special_check_is_buy (int TF , int sym)
{   
    switch(Special_id)
    {
      case 100:
         return Special_100_check_is_buy(TF,sym);
         break;
      case 101:
         return Special_101_check_is_buy(TF,sym);
         break;
      case 102:
         return Special_102_check_is_buy(TF,sym);
         break;
      case 103:
         return Special_103_check_is_buy(TF,sym);
         break;
      case 104:
         return Special_104_check_is_buy(TF,sym);
         break;
      default:
         return ( false ); 
         break;
    }
}  



bool Special_check_is_sell (int TF , int sym)
{   
    switch(Special_id)
    {
      case 100:
         return Special_100_check_is_sell(TF,sym);
         break;
      case 101:
         return Special_101_check_is_sell(TF,sym);
         break;
      case 102:
         return Special_102_check_is_sell(TF,sym);
         break;
      case 103:
         return Special_103_check_is_sell(TF,sym);
         break;
      case 104:
         return Special_104_check_is_sell(TF,sym);
         break;
      default:
         return ( false ); 
         break;
    }
} 





void ManageSpecialExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(Special_check_is_sell(Main_TF_N ,sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(Special_check_is_buy(Main_TF_N ,sym))
         trade.PositionClose(PositionGetTicket(Pos));
} 



double CalcSpecialBuyStopOrder(int sym)
{
    switch(Special_id)
    {
      case 101:
         return High[Main_TF_N].a[sym].b[1];
         break;
      case 103:
         return High[Main_TF_N].a[sym].b[1];
         break;
      default:
         return ( -1 ); 
         break;
    }
}


double CalcSpecialSellStopOrder(int sym)
{
    switch(Special_id)
    {
      case 101:
         return Low[Main_TF_N].a[sym].b[1];
         break;
      case 103:
         return Low[Main_TF_N].a[sym].b[1];
         break;
      default:
         return ( -1 ); 
         break;
    }
}


double CalcSpecialBuySL(int sym)
{
    switch(Special_id)
    {
      case 101:
         return Candle_Size (1 , Main_TF_N, sym);
         break;
      case 102:
         return SpecialMultiplierSL * SpecialMultiplierEntery * LongMABuffer[sym].b[1];
         break;
      default:
         return ( -1 ); 
         break;
    }
}





double CalcSpecialSellSL(int sym)
{
    switch(Special_id)
    {
      case 101:
         return Candle_Size (1 , Main_TF_N, sym);
         break;
       case 102:
         return SpecialMultiplierSL * SpecialMultiplierEntery * LongMABuffer[sym].b[1];
         break;
      default:
         return ( -1 ); 
         break;
    }
}



double CalcSpecialBuyTP(int sym)
{
    switch(Special_id)
    {
      case 102:
         return LongMABuffer[sym].b[1] - Close[Main_TF_N].a[sym].b[1];
         break;
      default:
         return ( -1 ); 
         break;
    }
}





double CalcSpecialSellTP(int sym)
{
    switch(Special_id)
    {
       case 102:
         return Close[Main_TF_N].a[sym].b[1] - LongMABuffer[sym].b[1];
         break;
      default:
         return ( -1 ); 
         break;
    }
}

//+------------------------------------------------------------------+
//|                                                                  |
//|          **** Specific strategies *****                          |
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------100-----------------------------------+


bool Special_100_check_is_buy (int TF , int sym)
{   
      if (Close[TF].a[sym].b[1] < Close[TF].a[sym].b[iLowest(SymbolArray[sym] , Main_TF , MODE_CLOSE , XbarsSpecial , 2)])
               return ( true );
      return ( false );  
}  

bool Special_100_check_is_sell (int TF , int sym)
{   
      if (Close[TF].a[sym].b[1] > Close[Main_TF_N].a[sym].b[iHighest(SymbolArray[sym] , Main_TF , MODE_CLOSE , XbarsSpecial , 2)])
               return ( true );
      return ( false );  
} 


//+------------------101-----------------------------------+

bool Special_101_check_is_buy (int TF , int sym)
{   
      if (InBar(1, TF , sym))
               return ( true );
      return ( false );  
}  

bool Special_101_check_is_sell (int TF , int sym)
{   
      if (InBar(1, TF , sym))
               return ( true );
      return ( false );  
} 



//+------------------102-----------------------------------+

bool Special_102_check_is_buy (int TF , int sym)
{   
      if (Close[Main_TF_N].a[sym].b[1] < (1-SpecialMultiplierEntery) * LongMABuffer[sym].b[1])
               return ( true );
      return ( false );  
}  

bool Special_102_check_is_sell (int TF , int sym)
{
      if (Close[Main_TF_N].a[sym].b[1] > (1+SpecialMultiplierEntery) * LongMABuffer[sym].b[1]  )
               return ( true );
      return ( false );  
} 


//+------------------103-----------------------------------+


bool HHHC(int i, int TF, int sym)
{
      if (Close[TF].a[sym].b[i] > Close[TF].a[sym].b[i+1] && High[TF].a[sym].b[i] > High[TF].a[sym].b[i+1])
         return true;
   return false;
}

bool LLLC(int i, int TF, int sym)
{
      if (Close[TF].a[sym].b[i] < Close[TF].a[sym].b[i+1] && Low[TF].a[sym].b[i] < Low[TF].a[sym].b[i+1])
         return true;
   return false;
}


bool Special_103_check_is_buy (int TF , int sym)
{   
      for(int i=2; i <XbarsSpecial+2 ; i++)
      {
         if(!HHHC(i , TF , sym))
            return ( false );  
      
      }
            if (LLLC(1 , TF, sym))
               return ( true );
      return ( false );  
}  

bool Special_103_check_is_sell (int TF , int sym)
{
      for(int i=2; i <XbarsSpecial+2 ; i++)
      {
         if(!LLLC(i , TF , sym))
            return ( false );  
      
      }
            if (HHHC(1 , TF, sym))
               return ( true );
      return ( false ); 
} 





bool Special_104_check_is_buy (int TF , int sym)
{   
      if (Close[Main_TF_N].a[sym].b[1] > upperBandBuffer[sym].b[1] && Close[Main_TF_N].a[sym].b[2] > upperBandBuffer[sym].b[2] && Close[Main_TF_N].a[sym].b[3] < upperBandBuffer[sym].b[3])
               return ( true );
      return ( false );  
}  

bool Special_104_check_is_sell (int TF , int sym)
{
      if (Close[Main_TF_N].a[sym].b[1] < lowerBandBuffer[sym].b[1] && Close[Main_TF_N].a[sym].b[2] < lowerBandBuffer[sym].b[2] && Close[Main_TF_N].a[sym].b[3] > lowerBandBuffer[sym].b[3])
               return ( true );
      return ( false );  
} 



/*   *********   old veraitions:   ******


bool Special_check_is_buy (int TF , int sym)
{   
      if(dt_struct.day_of_week == 2) // it's tuesday, now need to check previous [1] canlde and compare to Friday's candle [2]
         if(High[5].a[sym].b[1] < Open[5].a[sym].b[2]) // only daily
            if(Candle_color(1, 5 , sym) == -1)
               return ( true );
      return ( false );  
}  


bool Special_check_is_sell (int TF , int sym)
{   
      if(dt_struct.day_of_week == 2) // it's tuesday, now need to check previous [1] canlde and compare to Friday's candle [2]
         if(Low[5].a[sym].b[1] > Open[5].a[sym].b[2])  // only daily
            if(Candle_color(1, 5 , sym) == 1)
               return ( true );
      return ( false );  
} 


bool Special_101_check_is_buy (int TF , int sym)
{   
      if (Close[TF].a[sym].b[1] > Close[TF].a[sym].b[XbarsSpecial])
         if(Close[TF].a[sym].b[1] < Close[TF].a[sym].b[Xbars2ndSpecial])
               return ( true );
      return ( false );  
}  

bool Special_101_check_is_sell (int TF , int sym)
{   
      if (Close[TF].a[sym].b[1] < Close[TF].a[sym].b[XbarsSpecial])
         if(Close[TF].a[sym].b[1] > Close[TF].a[sym].b[Xbars2ndSpecial])
               return ( true );
      return ( false );  
} 








bool Special_104_check_is_buy (int TF , int sym)
{   
      if (Close[Main_TF_N].a[sym].b[1] > High[Main_TF_N].a[sym].b[iHighest(SymbolArray[sym] , PERIOD_H1 , MODE_HIGH , dt_struct.hour , 2)])
               return ( true );
      return ( false );  
}  

bool Special_104_check_is_sell (int TF , int sym)
{
      if (Close[Main_TF_N].a[sym].b[1] < Low[Main_TF_N].a[sym].b[iLowest(SymbolArray[sym] , PERIOD_H1 , MODE_LOW , dt_struct.hour , 2)])
               return ( true );
      return ( false );  
} 










*/