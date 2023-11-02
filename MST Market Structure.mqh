//+------------------------------------------------------------------+
//|                                         MST Market Structure.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"



input string MS_P; // ***** Market Structure parameters *****
input int PeriodForMS = 200;
input int PeriodFolLoaclPoint = 5;
input double MaxDistanceFromMSATR = 0.2;
input double MaxLegRatio = 0.75;
input double MinLegRatio = 0.25;
input double MinLegRatioATR = 0.1;

int LastHigh, LastLow, FirstHigh , FirstLow ;
int FinalCheckPoint;
double LegRatio;
/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| MS - H                               |
//+------------------------------------------------------------------+
********************************************************************************************************************************/


void MS_Initiate()
{    
   FinalCheckPoint = PeriodForMS - PeriodFolLoaclPoint - 1;
}   


bool LocalMax(int Candle)
{
   if (Candle == iHighest(NULL , PERIOD_H1 , MODE_HIGH , 2*PeriodFolLoaclPoint+1 , Candle - PeriodFolLoaclPoint)) return true;
   return false;
}


bool LocalMin(int Candle)
{
   if (Candle == iLowest(NULL , PERIOD_H1 , MODE_LOW , 2*PeriodFolLoaclPoint+1 , Candle - PeriodFolLoaclPoint)) return true;
   return false;
}



void DrawMarketStrcuture(int TF)
{
         
         DeleteAllMarketStrcuture();
         for(int i = PeriodFolLoaclPoint+1 ; i< FinalCheckPoint -2*PeriodFolLoaclPoint ; i++)
         {
            if (LocalMax(i))
            {
               LastHigh = i;
               for(int j = i+PeriodFolLoaclPoint+1 ; j<FinalCheckPoint - PeriodFolLoaclPoint-1 ; j++)
               {
                  if (LocalMin(j))
                  {
                     LastLow = j;
                     for(int k = j+PeriodFolLoaclPoint+1 ; j< FinalCheckPoint ; j++)
                     {
                        if (LocalMax(k))
                        {
                           FirstHigh = k;
                           if (High[TF].a[FirstHigh] > High[TF].a[LastHigh] + MinLegRatioATR*ATRBuffer[1])
                           {
                              if (High[TF].a[FirstHigh] - Low[TF].a[LastLow] >0)   LegRatio = (High[TF].a[FirstHigh] - High[TF].a[LastHigh])/ (High[TF].a[FirstHigh] - Low[TF].a[LastLow]) ;
                              else (LegRatio = -1);
                              if(LegRatio < MaxLegRatio &&  LegRatio > MinLegRatio)
                              {
                                 for(int l = k+PeriodFolLoaclPoint+1 ; l< FinalCheckPoint ; l++)
                                 {
                                    if (LocalMin(l))
                                    {
                                       FirstLow = l;
                                       if (Low[TF].a[FirstLow]-MinLegRatioATR*ATRBuffer[1] > Low[TF].a[LastLow])
                                          if(Low[TF].a[FirstLow] < High[TF].a[FirstHigh])
                                          {
                                             ObjectCreate( 0 , "FirstLegUp" , OBJ_TREND , 0 , iTime(_Symbol , PERIOD_H1 , FirstLow) , Low[TF].a[FirstLow]   , iTime(_Symbol , PERIOD_H1 , FirstHigh) ,High[TF].a[FirstHigh]);
                                             ObjectCreate( 0 , "LegDown"    , OBJ_TREND , 0 , iTime(_Symbol , PERIOD_H1 , FirstHigh), High[TF].a[FirstHigh] , iTime(_Symbol , PERIOD_H1 , LastLow)   ,Low[TF].a[LastLow]);
                                             ObjectCreate( 0 , "SecondLegUp" ,OBJ_TREND , 0 , iTime(_Symbol , PERIOD_H1 , LastLow) , Low[TF].a[LastLow]   , iTime(_Symbol , PERIOD_H1 , LastHigh) ,High[TF].a[LastHigh]);
                                             ObjectSetInteger(0 , "FirstLegUp" , OBJPROP_COLOR , clrBlue);
                                             ObjectSetInteger(0 , "FirstLegUp" , OBJPROP_WIDTH , 3);
                                             ObjectSetInteger(0 , "LegDown" , OBJPROP_COLOR , clrBlue);
                                             ObjectSetInteger(0 , "LegDown" , OBJPROP_WIDTH , 3);
                                             ObjectSetInteger(0 , "SecondLegUp" , OBJPROP_COLOR , clrBlue);
                                             ObjectSetInteger(0 , "SecondLegUp" , OBJPROP_WIDTH , 3);                                                                                          
                                             Print("Found down trend, ijkl: " , i , " , " , j , " , " , k , " , " , l);
                                             return;
                                          }
                                    }
                                 
                                 }
                              
                              }
                           
                           }
     
                           ObjectSetInteger(0 , TrendString , OBJPROP_COLOR , Red);
                           ObjectSetInteger(0 , TrendString , OBJPROP_STYLE , STYLE_DASH);
                           ObjectSetInteger(0 , TrendString , OBJPROP_WIDTH , 1);
                           ObjectSetInteger(0 , TrendString , OBJPROP_RAY_RIGHT , true);        

                          // else if(Sideways)
                          // {
                           
                           
                           
                         //  }
                        }
                     
                     }
                  
                  }
               }
            
            }


            //copy but opposite
            
            
            
            
         }
         /*
         UpperLimit = 0;
         HighSR = FindUpperLevel(TF);
         LocalMax = High[TF].a[iHighest(NULL , ReturnTF(TF) , MODE_HIGH , PeriodForSR , 1)];
         int LoopCounter = 0;
         do
         {
               if(!MQLInfoInteger(MQL_TESTER)) DrawHLine("UpperSR" , HighSR , Red);
               UpperSR = HighSR;
               if (Count_Touches ("UpperSR" , UpperSR,TF) >= TouchesForSR)  break;
               
               if(!MQLInfoInteger(MQL_TESTER))  DeleteArrows ("UpperSR");
               HighSR = HighSR+RoundPipsForSR*sPip;
               LoopCounter++;
               if(HighSR>LocalMax)
               {
                  if(!MQLInfoInteger(MQL_TESTER))  ObjectDelete(0, "UpperSR");
                  UpperSR = 0;
                  UpperLimit = HighSR;
                  if(!MQLInfoInteger(MQL_TESTER))  DrawHLine("UpperLimit" , HighSR , Blue);
                  break;
               }
         } 
         while (LoopCounter < MaxHightOfSRDistance); 
         
         
         
         LowerLimit = 0;
         
         LowSR = FindLowerLevel(TF);  
         LocalMin = Low[TF].a[iLowest(NULL , ReturnTF(TF) , MODE_LOW , PeriodForSR , 1)];
         LoopCounter = 0;
         do
         {
               if(!MQLInfoInteger(MQL_TESTER)) DrawHLine ("LowerSR" , LowSR , Green);
               LowerSR = LowSR;
               
               if (Count_Touches ("LowerSR" , LowerSR,TF) >= TouchesForSR) break;
               if(!MQLInfoInteger(MQL_TESTER))   DeleteArrows ("LowerSR");
               LowSR = LowSR-RoundPipsForSR*sPip;
               LoopCounter++;
               if(LowSR<LocalMin || LoopCounter == MaxHightOfSRDistance)
               {
                  if(!MQLInfoInteger(MQL_TESTER))   ObjectDelete (0, "LowerSR");
                  LowerSR = 0;
                  if(!MQLInfoInteger(MQL_TESTER))  DrawHLine ("LowerLimit" , LowSR , Blue);
                  LowerLimit = LowSR;
                  break;
               }              
         }
         while (LoopCounter < MaxHightOfSRDistance ); 
         */ 
}

/*
double FindUpperLevel (int TF)
{
            TempForCalc = (Open[TF].a[0] / sPip) ; // convert to "normal number"
            TempForCalc = (TempForCalc / RoundPipsForSR) ;// devide for number of times includes the Rounding factor        
            TempForCalc = RoundPipsForSR*MathCeil (TempForCalc+MinHightOfSRDistance);// multiply by  the next (rounded up by min hight) Rounding factor 
            TempForCalc = TempForCalc*sPip ;// return to price relevet for chart 
            return  (TempForCalc);
}

double FindLowerLevel (int TF)
{
            TempForCalc = (Open[TF].a[0] / sPip) ; // convert to "normal number"
            TempForCalc = (TempForCalc / RoundPipsForSR) ;// devide for number of times includes the Rounding factor        
            TempForCalc = RoundPipsForSR*MathFloor (TempForCalc-MinHightOfSRDistance);// multiply by  the previous (rounded down by min hight) Rounding factor 
            TempForCalc = TempForCalc*sPip ;// return to price relevet for chart 
            return  (TempForCalc);
}


int Count_Touches (string name , double CurrentHLine , int TF)
{
   int Counter = 0;
   for (int i=1 ; i<PeriodForSR ; i++)
   {
         if (  Open[TF].a[i] < CurrentHLine + uSlackForSR  && MathAbs(CurrentHLine - High[TF].a[i]) < uSlackForSR && Close[TF].a[i]+ uRejectionFromSR < CurrentHLine) 
         {
            Counter++;
            if(!MQLInfoInteger(MQL_TESTER))
            {
                  TempName = name;
                  StringAdd(TempName , string(i));
                  ObjectCreate(0 , TempName ,OBJ_ARROW_DOWN , 0 ,iTime(_Symbol , PERIOD_H1 , i) , MathMax(High[TF].a[i] ,CurrentHLine) +DistanceForDArow*sPip);
                  ObjectSetInteger(0,TempName,OBJPROP_COLOR ,clrRed);
            }
            
         }
         if (Open[TF].a[i] > CurrentHLine - uSlackForSR && MathAbs(CurrentHLine - Low[TF].a[i]) < uSlackForSR && Close[TF].a[i]- uRejectionFromSR > CurrentHLine)
         {
           Counter++;
           if(!MQLInfoInteger(MQL_TESTER))
           {
                 TempName = name;
                 StringAdd(TempName , string(i));
                 ObjectCreate(0 , TempName ,OBJ_ARROW_UP , 0 ,iTime(_Symbol , PERIOD_H1 , i) , MathMin(Low[TF].a[i] ,CurrentHLine) -DistanceForUArow*sPip);
                 ObjectSetInteger(0,TempName,OBJPROP_COLOR ,clrGreen);
            }
         }
   }
   //Print("counter is " , Counter);
   return (Counter);
}




void DeleteArrows (string name)
{
   string tempstring;
   for (int i=1 ; i<PeriodForSR ; i++) 
   {
          tempstring = name;
          StringAdd(tempstring,string(i));
          ObjectDelete(0,tempstring);
   }
}


void DeleteAllArrows ()
{
   string tempstring;
   for (int i=1 ; i<PeriodForSR ; i++)
   {
          tempstring = "UpperSR";
          StringAdd(tempstring,string(i));
          ObjectDelete(0,tempstring);
          tempstring = "LowerSR";
          StringAdd(tempstring,string(i));
          ObjectDelete(0,tempstring);     
   }
}   


void DrawHLine (string name , double price, color Lcolor)
{
                     ObjectDelete (0,name);
                     ObjectCreate (0, name , OBJ_HLINE , 0 , 0 ,price);                    
                     ObjectSetInteger(0 , name , OBJPROP_COLOR , Lcolor);
                     ObjectSetInteger(0 , name , OBJPROP_STYLE , STYLE_SOLID);
                     ObjectSetInteger(0 , name , OBJPROP_WIDTH , 1);
                     ObjectSetInteger(0 , name , OBJPROP_RAY , true);    
}


*/

bool MarketStructureTrend_check_is_buy (int TF)
{  
   if (TradeMethod >2 ) return (SR_check_is_buy_stop (TF)); 
   if (LowerSR==0)     return (false);
   SRLevel = LowerSR;
   if (  Open[TF].a [0] - SRLevel < MaxDistanceFromSRATR * ATRBuffer[1]  ) return (true);
   return (false);
}    


bool MarketStructureTrend_check_is_sell (int TF)
{
   if (TradeMethod >2) return (SR_check_is_sell_stop (TF));   
   if (UpperSR==0)     return (false);       
   SRLevel = UpperSR; 
   if (SRLevel - Open[TF].a [0]  < MaxDistanceFromSRATR*ATRBuffer[1]  ) return (true);

   return (false);
}    


bool MarketStructureSideways_check_is_buy (int TF)
{
   if (UpperSR==0)     return (false);       
   SRLevel = UpperSR; 
   if (SRLevel - Open[TF].a [0]  < MaxDistanceFromSRATR*ATRBuffer[1]  ) return (true);

   return (false);
}    

bool MarketStructureSideways_check_is_sell (int TF)
{  
   if (LowerSR==0)     return (false);
   SRLevel = LowerSR;
   if (  Open[TF].a [0] - SRLevel < MaxDistanceFromSRATR*ATRBuffer[1]  ) return (true);
   return (false);
}    


/*

double Calculate_SR_Long_SL(int TF,double price)
{
   if (LowerSR==0) return Default_SL;
   return ((price - LowerSR + SL_SR_ATR_Slack*ATRBuffer[1] )/ pip );
}

double Calculate_SR_Short_SL(int TF,double price)
{
   if (UpperSR==0) return Default_SL;
   return ((UpperSR - price+ SL_SR_ATR_Slack*ATRBuffer[1])/ pip);
}


double Calculate_SR_Long_TP(int TF,double price)
{
   if (LowerSR==0) return 0;
   return ((UpperSR - price+ ATR_SR_TP_Slack*ATRBuffer[1])/ pip);
}

double Calculate_SR_Short_TP(int TF,double price)
{
   if (UpperSR==0) return 0;
   return ((price - LowerSR + ATR_SR_TP_Slack*ATRBuffer[1] )/ pip );
}


*/
void DeleteAllMarketStrcuture()
{
/*
            if(!MQLInfoInteger(MQL_TESTER)) 
            {
                  DeleteAllArrows ();
                  ObjectDelete(0, "UpperLimit");
                  ObjectDelete(0, "LowerLimit");
                  ObjectDelete(0, "UpperSR");
                  ObjectDelete(0, "LowerSR");
            }
*/
            LastHigh = 0;
            LastLow=0;
            FirstHigh=0;
            FirstLow=0;             
}

void ManageMarketStructureTrendExit(int Pos)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(SR_check_is_sell(3))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(SR_check_is_buy(3))
         trade.PositionClose(PositionGetTicket(Pos));
}


void ManageMarketStructureSidewaysExit(int Pos)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(SR_check_is_sell(3))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(SR_check_is_buy(3))
         trade.PositionClose(PositionGetTicket(Pos));
}

























/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| MS - D                              |
//+------------------------------------------------------------------+
********************************************************************************************************************************/





void DrawMarketStrcuture_D(int TF)
{
}

void DeleteAllMarketStructure_D()
{
}


bool MarketStructureTrend_check_is_buy_D (int TF)
{  
   if (TradeMethod >2 ) return (SR_check_is_buy_stop (TF)); 
   if (LowerSR==0)     return (false);
   SRLevel = LowerSR;
   if (  Open[TF].a [0] - SRLevel < MaxDistanceFromSRATR * ATRBuffer[1]  ) return (true);
   return (false);
}    


bool MarketStructureTrend_check_is_sell_D (int TF)
{
   if (TradeMethod >2) return (SR_check_is_sell_stop (TF));   
   if (UpperSR==0)     return (false);       
   SRLevel = UpperSR; 
   if (SRLevel - Open[TF].a [0]  < MaxDistanceFromSRATR*ATRBuffer[1]  ) return (true);

   return (false);
}    


bool MarketStructureSideways_check_is_buy_D (int TF)
{
   if (UpperSR==0)     return (false);       
   SRLevel = UpperSR; 
   if (SRLevel - Open[TF].a [0]  < MaxDistanceFromSRATR*ATRBuffer[1]  ) return (true);

   return (false);
}    

bool MarketStructureSideways_check_is_sell_D (int TF)
{  
   if (LowerSR==0)     return (false);
   SRLevel = LowerSR;
   if (  Open[TF].a [0] - SRLevel < MaxDistanceFromSRATR*ATRBuffer[1]  ) return (true);
   return (false);
}    


void ManageMarketStructureTrendExit_D(int Pos)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(SR_check_is_sell(3))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(SR_check_is_buy(3))
         trade.PositionClose(PositionGetTicket(Pos));
}


void ManageMarketStructureSidewaysExit_D(int Pos)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(SR_check_is_sell(3))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(SR_check_is_buy(3))
         trade.PositionClose(PositionGetTicket(Pos));
}