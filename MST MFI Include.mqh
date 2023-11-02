//+------------------------------------------------------------------+
//|                                              MST MFI Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"





//+------------------------------------------------------------------+
//| MFI Include varibales                         |
//+------------------------------------------------------------------+


ArraySet mfiBuffer[];
int mfiHandle[];


input group "MFI parameters"; 
input int MFIPeriod = 14;
input int MFIOverExtended = 20;

input int MFIDivLookBackPeriod = 50;




bool MFI_DIV_check_is_buy (int sym)
{   
    if(!IsLocalMFIMin(3 , sym)) return false;
    for (int i=6 ; i <MFIDivLookBackPeriod ; i++)
    {
      if(mfiBuffer[sym].b[i] < 50 - MFIOverExtended)
         if(mfiBuffer[sym].b[i] < mfiBuffer[sym].b[3])
             if (IsLocalMFIMin(i , sym))
               if(Close[3].a[sym].b[i] > Close[3].a[sym].b[3])
                  return ( true );
    }
    return ( false );
}    


bool MFI_DIV_check_is_sell (int sym)
{   
    if(!IsLocalMFIMax(3 , sym)) return false;
    for (int i=6 ; i <MFIDivLookBackPeriod ; i++)
    {
      if(mfiBuffer[sym].b[i] > 50 + MFIOverExtended)
         if(mfiBuffer[sym].b[i] > mfiBuffer[sym].b[3])
             if (IsLocalMFIMax(i , sym))
               if(Close[3].a[sym].b[i] < Close[3].a[sym].b[3])
                  return ( true );
    }
    return ( false );
}    



bool MFI_DIVHide_check_is_buy (int sym)
{   
    if(!IsLocalMFIMin(3 , sym)) return false;
    if(mfiBuffer[sym].b[3] < 50 - MFIOverExtended)
       for (int i=6 ; i <MFIDivLookBackPeriod ; i++)
       {
         if(mfiBuffer[sym].b[i] > mfiBuffer[sym].b[3])
             if (IsLocalMFIMin(i , sym))
               if(Close[3].a[sym].b[i] < Close[3].a[sym].b[3])
                  return ( true );
       }
    return ( false );
}    


bool MFI_DIVHide_check_is_sell (int sym)
{   
    if(!IsLocalMFIMax(3 , sym)) return false;
    if(mfiBuffer[sym].b[3] > 50 + MFIOverExtended)
       for (int i=6 ; i <MFIDivLookBackPeriod ; i++)
       {
         if(mfiBuffer[sym].b[i] < mfiBuffer[sym].b[3])
             if (IsLocalMFIMax(i , sym))
               if(Close[3].a[sym].b[i] > Close[3].a[sym].b[3])
                  return ( true );
       }
    return ( false );
}   

bool MFI_Over_check_is_buy (int sym)
{
    if(mfiBuffer[sym].b[3] < 50 - MFIOverExtended)
      if(IsLocalMFIMin(3 , sym))
           return ( true );
    return false;       
}    


bool MFI_Over_check_is_sell (int sym)
{   
    if(mfiBuffer[sym].b[3] > 50 + MFIOverExtended)
      if(IsLocalMFIMax(3 , sym))
           return ( true );
    return false;  
}   



bool MFI_With_check_is_buy (int sym)
{   
    if(mfiBuffer[sym].b[1] > 50 + MFIOverExtended)       return true;
    return false;        
    
}    


bool MFI_With_check_is_sell (int sym)
{   
    if(mfiBuffer[sym].b[1] < 50 - MFIOverExtended)       return true;
    return false;     
}   




void ManageMFIDivExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(MFI_DIV_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(MFI_DIV_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}



void ManageMFIDivHideExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(MFI_DIVHide_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(MFI_DIVHide_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}

void ManageMFIOverExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(MFI_Over_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(MFI_Over_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}

void ManageMFIWithExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(MFI_With_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(MFI_With_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}



bool IsLocalMFIMax(int Candle , int sym)
{
   if(mfiBuffer[sym].b[Candle] > mfiBuffer[sym].b[Candle+1])
       if(mfiBuffer[sym].b[Candle] > mfiBuffer[sym].b[Candle+2])
         if(mfiBuffer[sym].b[Candle] > mfiBuffer[sym].b[Candle-1])
            if(mfiBuffer[sym].b[Candle] > mfiBuffer[sym].b[Candle-2])
                              return true;

   return false;
}


bool IsLocalMFIMin(int Candle , int sym)
{
   if(mfiBuffer[sym].b[Candle] < mfiBuffer[sym].b[Candle+1])
       if(mfiBuffer[sym].b[Candle] < mfiBuffer[sym].b[Candle+2])
         if(mfiBuffer[sym].b[Candle] < mfiBuffer[sym].b[Candle-1])
            if(mfiBuffer[sym].b[Candle] < mfiBuffer[sym].b[Candle-2])
               return true;

   return false;
}