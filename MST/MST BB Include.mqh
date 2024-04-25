//+------------------------------------------------------------------+
//|                                               MST BB Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"





//+------------------------------------------------------------------+
//| BB Include varibales                         |
//+------------------------------------------------------------------+

ArraySet upperBandBuffer[];
ArraySet middleBandBuffer[];
ArraySet lowerBandBuffer[];
int bandHandle[];


input group "BB parameters"; 
input int BBPeriod = 20;
input double BBDeviation = 2;
input int BBChangeLookBackPeriod = 2;


bool BB_With_check_is_buy (int sym)
{   
        if (Close[3].a[sym].b[1] > upperBandBuffer[sym].b[1])
            return (true);        
        return ( false );
}    


bool BB_With_check_is_sell (int sym)
{   
    if (Close[3].a[sym].b[1] < lowerBandBuffer[sym].b[1])
         return (true);
    return ( false ); 
}    


bool BB_Ret_check_is_buy (int sym)
{   
    if (Close[3].a[sym].b[1]> lowerBandBuffer[sym].b[1] && Close[3].a[sym].b[2] < lowerBandBuffer[sym].b[2])
         return (true);
    return ( false );    
}    


bool BB_Ret_check_is_sell (int sym)
{   
        if (Close[3].a[sym].b[1] < upperBandBuffer[sym].b[1] && Close[3].a[sym].b[2] > upperBandBuffer[sym].b[2])
            return (true);        
        return ( false );
}    


bool BB_Contracting (int sym)
{   
        for(int i=1 ; i<= BBChangeLookBackPeriod ; i++)
        {
            if(upperBandBuffer[sym].b[i]-lowerBandBuffer[sym].b[i] > upperBandBuffer[sym].b[i+1]-lowerBandBuffer[sym].b[i+1]) return ( false );
        }
        return (true);               
}    

bool BB_Expanding (int sym)
{   
        for(int i=1 ; i<= BBChangeLookBackPeriod ; i++)
        {
            if(upperBandBuffer[sym].b[i]-lowerBandBuffer[sym].b[i] < upperBandBuffer[sym].b[i+1]-lowerBandBuffer[sym].b[i+1]) return ( false );
        }
        return (true);               
}    


void ManageBBReturnExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(BB_Ret_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(BB_Ret_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}



void ManageBBWithExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(BB_With_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(BB_With_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}


void ManageBB_Contracting_Exit(int Pos , int sym)
{
   if(BB_Contracting(sym))       trade.PositionClose(PositionGetTicket(Pos));
}


void ManageBB_Expending_Against_Exit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(BB_Expanding(sym))
         if (Candle_color (1 , Main_TF_N , sym) == -1)
         {
            trade.PositionClose(PositionGetTicket(Pos));
            return;
         }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(BB_Expanding(sym))
         if (Candle_color (1 , Main_TF_N , sym) == 1)
            trade.PositionClose(PositionGetTicket(Pos));
            
}
