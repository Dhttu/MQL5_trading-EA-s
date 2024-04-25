//+------------------------------------------------------------------+
//|                                              MST RSI Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"




//+------------------------------------------------------------------+
//| RSI Include varibales                         |
//+------------------------------------------------------------------+


ArraySet rsiBuffer[];
int rsiHandle[];


input group "RSI parameters"; 
input int RSIPeriod = 14;
input int RSIOverExtended = 20;

input int RSIDivLookBackPeriod = 50;


bool RSI_DIV_check_is_buy (int sym)
{   
    if(!IsLocalRSIMin(3 , sym)) return false;
    for (int i=6 ; i <RSIDivLookBackPeriod ; i++)
    {
      if(rsiBuffer[sym].b[i] < 50 - RSIOverExtended)
         if(rsiBuffer[sym].b[i] < rsiBuffer[sym].b[3])
             if (IsLocalRSIMin(i,sym))
               if(Close[3].a[sym].b[i] > Close[3].a[sym].b[3])
                  return ( true );
    }
    return ( false );
}    


bool RSI_DIV_check_is_sell (int sym)
{   
    if(!IsLocalRSIMax(3,sym)) return false;
    for (int i=6 ; i <RSIDivLookBackPeriod ; i++)
    {
      if(rsiBuffer[sym].b[i] > 50 + RSIOverExtended)
         if(rsiBuffer[sym].b[i] > rsiBuffer[sym].b[3])
             if (IsLocalRSIMax(i , sym))
               if(Close[3].a[sym].b[i] < Close[3].a[sym].b[3])
                  return ( true );
    }
    return ( false );
}    



bool RSI_DIVHide_check_is_buy (int sym)
{   
    if(!IsLocalRSIMin(3 , sym)) return false;
    if(rsiBuffer[sym].b[3] < 50 - RSIOverExtended)
       for (int i=6 ; i <RSIDivLookBackPeriod ; i++)
       {
         if(rsiBuffer[sym].b[i] > rsiBuffer[sym].b[3])
             if (IsLocalRSIMin(i , sym))
               if(Close[3].a[sym].b[i] < Close[3].a[sym].b[3])
                  return ( true );
       }
    return ( false );
}    


bool RSI_DIVHide_check_is_sell (int sym)
{   
    if(!IsLocalRSIMax(3 , sym)) return false;
    if(rsiBuffer[sym].b[3] > 50 + RSIOverExtended)
       for (int i=6 ; i <RSIDivLookBackPeriod ; i++)
       {
         if(rsiBuffer[sym].b[i] < rsiBuffer[sym].b[3])
             if (IsLocalRSIMax(i , sym))
               if(Close[3].a[sym].b[i] > Close[3].a[sym].b[3])
                  return ( true );
       }
    return ( false );
}   

bool RSI_Over_check_is_buy (int sym)
{
    if(rsiBuffer[sym].b[3] < 50 - RSIOverExtended)
      if(IsLocalRSIMin(3 , sym))
           return ( true );
    return false;       
}    


bool RSI_Over_check_is_sell (int sym)
{   
    if(rsiBuffer[sym].b[3] > 50 + RSIOverExtended)
      if(IsLocalRSIMax(3 , sym))
           return ( true );
    return false;  
}   



bool RSI_With_check_is_buy (int sym)
{   
    if(rsiBuffer[sym].b[1] > 50 + RSIOverExtended)       return true;
    return false;        
    
}    


bool RSI_With_check_is_sell (int sym)
{   
    if(rsiBuffer[sym].b[1] < 50 - RSIOverExtended)       return true;
    return false;     
}   




void ManageRSIDivExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(RSI_DIV_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(RSI_DIV_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}



void ManageRSIDivHideExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(RSI_DIVHide_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(RSI_DIVHide_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}

void ManageRSIOverExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(RSI_Over_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(RSI_Over_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}

void ManageRSIWithExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(RSI_With_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(RSI_With_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}



bool IsLocalRSIMax(int Candle , int sym)
{
   if(rsiBuffer[sym].b[Candle] > rsiBuffer[sym].b[Candle+1])
       if(rsiBuffer[sym].b[Candle] > rsiBuffer[sym].b[Candle+2])
         if(rsiBuffer[sym].b[Candle] > rsiBuffer[sym].b[Candle-1])
            if(rsiBuffer[sym].b[Candle] > rsiBuffer[sym].b[Candle-2])
                              return true;

   return false;
}


bool IsLocalRSIMin(int Candle , int sym)
{
   if(rsiBuffer[sym].b[Candle] < rsiBuffer[sym].b[Candle+1])
       if(rsiBuffer[sym].b[Candle] < rsiBuffer[sym].b[Candle+2])
         if(rsiBuffer[sym].b[Candle] < rsiBuffer[sym].b[Candle-1])
            if(rsiBuffer[sym].b[Candle] < rsiBuffer[sym].b[Candle-2])
               return true;

   return false;
}

