//+------------------------------------------------------------------+
//|                                               MST GR Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"



input group "Grenn/Red Ratio parameters"; 
input int Ratio_CandlesCount = 100;
input double BuyEnterLimitP_GR = 1.35;
input double SellEnterLimitP_GR = 1.35;
input double BuyExitLimitP_GR = 1;
input double SellExitLimitP_GR = 1;

double GR_R[] , GR_R_D[];


double check_RatioGR(int sym)
{
   double RedC = 0;
   double GreenC = 0;
   for (int i=1 ; i<=Ratio_CandlesCount ; i++)
   {
         if (  Candle_color (i , Main_TF_N , sym) == 1 ) GreenC++;
         else if (Candle_color (i , Main_TF_N , sym) == -1)  RedC++;
   }
   if(DrawLines)
   {
      ObjectCreate (0 , "GR_R" , OBJ_TEXT ,  0 ,iTime(SymbolArray[sym] , Main_TF , 1) , High[3].a[sym].b[1]);  
      ObjectSetDouble(0,"GR_R",OBJPROP_ANGLE,90); 
      ObjectSetInteger(0,"GR_R",OBJPROP_COLOR,clrBlue); 
      ObjectSetString(0,"GR_R",OBJPROP_TEXT,string(GreenC / RedC));
      ObjectSetInteger(0,"GR_R",OBJPROP_FONTSIZE,16); 
   }
   return (GreenC / RedC );
}



bool GR_check_is_buy (int sym)
{   
     if (GR_R[sym] > BuyEnterLimitP_GR )  return ( true );
     return false;
}    


bool GR_check_is_sell (int sym)
{   
     if (1/GR_R[sym] > SellEnterLimitP_GR )  return ( true );
     return false;
}    



void ManageGRRatioExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(GR_check_is_sell(sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(GR_check_is_buy(sym))
         trade.PositionClose(PositionGetTicket(Pos));
}



void ManageExitGRRatioExit(int sym)
{
                  if(     posInfo.PositionType()==POSITION_TYPE_BUY)
                  {
                        if (GR_R[sym] < BuyExitLimitP_GR ) CloseAllTrades(1 , sym );
                        return ;
                  }
                  if(posInfo.PositionType()==POSITION_TYPE_SELL)
                        if (1/GR_R[sym] < SellExitLimitP_GR ) 
                            CloseAllTrades(-1, sym );
}