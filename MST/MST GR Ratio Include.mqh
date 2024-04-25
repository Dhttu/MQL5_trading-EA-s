//+------------------------------------------------------------------+
//|                                         MST GR Ratio Include.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"


input string GRRatio_P; // ***** Grenn/Red Ratio parameters *****
input int Ratio_CandlesCount = 100;
input double BuyEnterLimitP_GR = 1.35;
input double SellEnterLimitP_GR = 1.35;
input bool   UseExitGRRatioExit = false;
input double BuyExitLimitP_GR = 1;
input double SellExitLimitP_GR = 1;

double GR_R , GR_R_D;


input string GRRatio_P_D; // ***** Grenn/Red Daily Ratio parameters *****
input int Ratio_CandlesCount_D = 100;
input double BuyEnterLimitP_GR_D = 1.35;
input double SellEnterLimitP_GR_D = 1.35;
input bool   UseExitGRRatioExit_D = false;
input double BuyExitLimitP_GR_D = 1;
input double SellExitLimitP_GR_D = 1;

/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| GR - H                               |
//+------------------------------------------------------------------+
********************************************************************************************************************************/


double check_RatioGR()
{
   double RedC = 0;
   double GreenC = 0;
   for (int i=1 ; i<=Ratio_CandlesCount ; i++)
   {
         if (  Candle_color (i , 3) == 1 ) GreenC++;
         else if (Candle_color (i , 3) == -1)  RedC++;
   }
      ObjectCreate (0 , "GR_R" , OBJ_TEXT ,  0 ,iTime(_Symbol , PERIOD_H1 , 1) , High[3].a[1] + pip);  
      ObjectSetDouble(0,"GR_R",OBJPROP_ANGLE,90); 
      ObjectSetInteger(0,"GR_R",OBJPROP_COLOR,clrBlue); 
      ObjectSetString(0,"GR_R",OBJPROP_TEXT,string(GreenC / RedC));
      ObjectSetInteger(0,"GR_R",OBJPROP_FONTSIZE,16); 
   return (GreenC / RedC );
}



bool GR_check_is_buy ()
{   
     if (GR_R > BuyEnterLimitP_GR )  return ( true );
     return false;
}    


bool GR_check_is_sell ()
{   
     if (1/GR_R > SellEnterLimitP_GR )  return ( true );
     return false;
}    



void ManageGRRatioExit(int Pos)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(GR_check_is_sell())
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(GR_check_is_buy())
         trade.PositionClose(PositionGetTicket(Pos));
}



void ManageExitGRRatioExit()
{
                  if(     posInfo.PositionType()==POSITION_TYPE_BUY)
                  {
                        if (GR_R < BuyExitLimitP_GR ) CloseAllTrades(1 );
                        return ;
                  }
                  if(posInfo.PositionType()==POSITION_TYPE_SELL)
                        if (1/GR_R < SellExitLimitP_GR ) 
                            CloseAllTrades(-1 );
}



/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| GR - D                              |
//+------------------------------------------------------------------+
********************************************************************************************************************************/



double check_RatioGR_D()
{
   double RedC = 0;
   double GreenC = 0;
   for (int i=1 ; i<=Ratio_CandlesCount_D ; i++)
   {
         if (  Candle_color (i , 5) == 1 ) GreenC++;
         else if (Candle_color (i , 5) == -1)  RedC++;
   }
   return (GreenC / RedC );
}



bool GR_check_is_buy_D ()
{   
     if (GR_R_D > BuyEnterLimitP_GR_D )  return ( true );
     return false;
}    


bool GR_check_is_sell_D ()
{   
     if (1/GR_R_D > SellEnterLimitP_GR_D )  return ( true );
     return false;
}    



void ManageGRRatioExit_D(int Pos)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(GR_check_is_sell_D())
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(GR_check_is_buy_D())
         trade.PositionClose(PositionGetTicket(Pos));
}



void ManageExitGRRatioExit_D()
{
                  if(     posInfo.PositionType()==POSITION_TYPE_BUY)
                  {
                        if (GR_R_D < BuyExitLimitP_GR_D ) CloseAllTrades(1 );
                        return ;
                  }
                  if(posInfo.PositionType()==POSITION_TYPE_SELL)
                        if (1/GR_R_D < SellExitLimitP_GR_D ) 
                            CloseAllTrades(-1 );
}



