//+------------------------------------------------------------------+
//|                                 MST Range Strategies Include.mqh |
//|                                  Copyright 2021, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Ltd."
#property link      "https://www.mql5.com"



   
   
input string SR_P; // ***** SR parameters *****
input int PeriodForSR = 200;
input int TouchesForSR = 3;
input double SlackForSR = 1;
input double MaxDistanceFromSRATR = 0.2;
input int MinHightOfSRDistance = 4;
input int MaxHightOfSRDistance = 200;   



input string SR_P_D; // ***** SR_D parameters *****
input int PeriodForSR_D = 200;
input int TouchesForSR_D = 3;
input double SlackForSR_D = 5;
input double MaxDistanceFromSRATR_D = 1;
input int MinHightOfSRDistance_D = 4;
input int MaxHightOfSRDistance_D = 250;   
   

input string BO_P; // ***** BreakOut parameters *****
input double SlackForBreakoutATR = 0.1   ;

input string BO_P_D; // ***** BreakOut_D parameters *****
input double SlackForBreakoutATR_D = 0.1 ;

   
input string FO_P; // ***** FakeOut parameters *****
input int HoursFromFakeOut = 2   ;
input int HoursBeforeFakeOut = 2   ;
input double FakeOutATRSlack = 0.5  ;

input string FO_P_D; // ***** FakeOut_D parameters *****
input int DaysFromFakeOut = 2   ;
input int DaysBeforeFakeOut = 2   ;
input double FakeOutATRSlack_D = 0.5 ;

   
double UpperSR=0, UpperLimit=0 , LowerSR=0 , LowerLimit=0;
double UpperSR_D=0, UpperLimit_D=0 , LowerSR_D=0 , LowerLimit_D=0;

//double RejectionFromSR = 2; //ready for user input, decided to use 2 times the slack

double sPip;
bool proceed;
//int SlackForPip = 3;

double HighSR, LowSR;
double HighSR_D, LowSR_D;

double uSlackForSR,uRejectionFromSR;
double uSlackForSR_D,uRejectionFromSR_D;

double LocalMax,LocalMin;
double LocalMax_D,LocalMin_D;

double RoundPipsForSR;
double RoundPipsForSR_D;

int DistanceForArow = 3;
int DistanceForArow_D = 5;
int DistanceForDArow;
int DistanceForUArow;
int DistanceForDArow_D;
int DistanceForUArow_D;

string TempName;
double TempForCalc = 0;


double HighestInRange;
double LowestInRange; 
double SRLevel; 
double PrevLowerSRLevel = 0;
double PrevUpperSRLevel = 0;
double PrevLowerSRLevel_D = 0;
double PrevUpperSRLevel_D = 0;







void SR_Initiate()
{    
   DistanceForDArow = 5*DistanceForArow;
   DistanceForDArow_D = 10*DistanceForArow_D;
   DistanceForUArow = DistanceForArow;
   DistanceForUArow_D = DistanceForArow_D;
   sPip = Point()*10;
   if (_Symbol == "XAUUSD" ) 
   {
 //     sPip = sPip/10;
      DistanceForDArow = 3*DistanceForDArow;
      DistanceForUArow = 3*DistanceForUArow;
      DistanceForDArow_D = 3*DistanceForDArow_D;
      DistanceForUArow_D = 3*DistanceForUArow_D;
   }
   
   uSlackForSR = SlackForSR*sPip;
// uRejectionFromSR = RejectionFromSR*sPip;//ready for user input, decided to use 2 times the slack
   uRejectionFromSR = uSlackForSR*2;
   RoundPipsForSR = SlackForSR*2;  
   
   uSlackForSR_D = SlackForSR_D*sPip;
   uRejectionFromSR_D = uSlackForSR_D*2;
   RoundPipsForSR_D = SlackForSR_D*2;  
}   

/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| SR - H                               |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

void DrawSR(int TF)
{
         // Remembger previous SR levels for Breakout and Fakeout
         if (UseBreakOut)
         {
               if (LowerSR>0) PrevLowerSRLevel = LowerSR;
               else PrevLowerSRLevel = 0;
               if (UpperSR>0) PrevUpperSRLevel = UpperSR;
               else PrevUpperSRLevel = 0;          
         }
         
         DeleteAllSR();
         UpperLimit = 0;
         HighSR = FindUpperLevel(TF);
         LocalMax = High[TF].a[iHighest(NULL , ReturnTF(TF) , MODE_HIGH , PeriodForSR , 1)];
         int LoopCounter = 0;
         do
         {
               if(DrawLines) DrawHLine("UpperSR" , HighSR , Red);
               UpperSR = HighSR;
               if (Count_Touches ("UpperSR" , UpperSR,TF) >= TouchesForSR)  break;
               
               if(DrawLines)  DeleteArrows ("UpperSR");
               HighSR = HighSR+RoundPipsForSR*sPip;
               LoopCounter++;
               if(HighSR>LocalMax)
               {
                  if(DrawLines)  ObjectDelete(0, "UpperSR");
                  UpperSR = 0;
                  UpperLimit = HighSR;
                  if(DrawLines)  DrawHLine("UpperLimit" , HighSR , Blue);
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
               if(DrawLines) DrawHLine ("LowerSR" , LowSR , Green);
               LowerSR = LowSR;
               
               if (Count_Touches ("LowerSR" , LowerSR,TF) >= TouchesForSR) break;
               if(DrawLines)   DeleteArrows ("LowerSR");
               LowSR = LowSR-RoundPipsForSR*sPip;
               LoopCounter++;
               if(LowSR<LocalMin || LoopCounter == MaxHightOfSRDistance)
               {
                  if(DrawLines)   ObjectDelete (0, "LowerSR");
                  LowerSR = 0;
                  if(DrawLines)  DrawHLine ("LowerLimit" , LowSR , Blue);
                  LowerLimit = LowSR;
                  break;
               }              
         }
         while (LoopCounter < MaxHightOfSRDistance );  
}


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
            if(DrawLines)
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
           if(DrawLines)
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




bool SR_check_is_buy (int TF)
{  
   if (TradeMethod >2 ) return (SR_check_is_buy_stop (TF)); 
   if (LowerSR==0)     return (false);
   SRLevel = LowerSR;
   if (  Open[TF].a [0] - SRLevel < MaxDistanceFromSRATR * ATRBuffer[1]  ) return (true);
   return (false);
}    


bool SR_check_is_sell (int TF)
{
   if (TradeMethod >2) return (SR_check_is_sell_stop (TF));   
   if (UpperSR==0)     return (false);       
   SRLevel = UpperSR; 
   if (SRLevel - Open[TF].a [0]  < MaxDistanceFromSRATR*ATRBuffer[1]  ) return (true);

   return (false);
}    


bool SR_check_is_buy_stop (int TF)
{
   if (UpperSR==0)     return (false);       
   SRLevel = UpperSR; 
   if (SRLevel - Open[TF].a [0]  < MaxDistanceFromSRATR*ATRBuffer[1]  ) return (true);

   return (false);
}    

bool SR_check_is_sell_stop (int TF)
{  
   if (LowerSR==0)     return (false);
   SRLevel = LowerSR;
   if (  Open[TF].a [0] - SRLevel < MaxDistanceFromSRATR*ATRBuffer[1]  ) return (true);
   return (false);
}    




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



void DeleteAllSR()
{     
            if(DrawLines)  
            {
                  DeleteAllArrows ();
                  ObjectDelete(0, "UpperLimit");
                  ObjectDelete(0, "LowerLimit");
                  ObjectDelete(0, "UpperSR");
                  ObjectDelete(0, "LowerSR");
            }
            UpperLimit = 0;
            LowerLimit=0;
            UpperSR=0;
            LowerSR=0;             
}

void ManageSRExit(int Pos)
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
//| Breakout / Fakeout - H                               |
//+------------------------------------------------------------------+
********************************************************************************************************************************/




bool Breakout_check_is_buy (int TF)
{  
   if (PrevUpperSRLevel==0)     return (false);
   SRLevel = PrevUpperSRLevel; 
   if (Close[TF].a [1] > SRLevel + SlackForBreakoutATR * ATRBuffer[1]) return (true);   
   return false ; 
}    

bool Breakout_check_is_sell (int TF)
{
   if (PrevLowerSRLevel==0)     return (false);       
   SRLevel = PrevLowerSRLevel; 
   if (Close[TF].a [1] < SRLevel - SlackForBreakoutATR * ATRBuffer[1]) return (true);   
   return false ; 
}    

     

void ManageBreakoutExit(int Pos)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(Breakout_check_is_sell(3))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(Breakout_check_is_buy(3))
         trade.PositionClose(PositionGetTicket(Pos));
}


bool Fakeout_check_is_buy (int TF)
{  
   if (LowerSR==0)     return (false);
   SRLevel = LowerSR; 
   if (Low[TF].a[iLowest(_Symbol , PERIOD_H1 , MODE_LOW , HoursFromFakeOut , 1)] > SRLevel - FakeOutATRSlack * ATRBuffer[1]) return (false); // broke down in a Fakeout (at least x times ATR)
   if (Low[TF].a[iLowest(_Symbol , PERIOD_H1 , MODE_LOW ,HoursBeforeFakeOut , HoursFromFakeOut)] < SRLevel)                  return (false); // was above SR before fakeout    
   return SR_check_is_buy(TF) ; 
}    

bool Fakeout_check_is_sell (int TF)
{
   if (UpperSR==0)     return (false);       
   SRLevel = UpperSR; 
   if (High[TF].a[iHighest(_Symbol , PERIOD_H1 , MODE_HIGH , HoursFromFakeOut , 1)] < SRLevel + FakeOutATRSlack * ATRBuffer[1]) return (false);
   if (High[TF].a[iHighest(_Symbol , PERIOD_H1 , MODE_HIGH ,HoursBeforeFakeOut , HoursFromFakeOut)] > SRLevel)                  return (false); // 
   return SR_check_is_sell(TF) ; 
}    


void ManageFakeoutExit(int Pos)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(Fakeout_check_is_sell(3))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(Fakeout_check_is_buy(3))
         trade.PositionClose(PositionGetTicket(Pos));
}



/*******************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//|                                                                  |
//| DAILY:                                                           |
//|                                                                  |
//+------------------------------------------------------------------+
*********************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*********************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*********************************************************************************************************************************/






/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| SR - daily                               |
//+------------------------------------------------------------------+
********************************************************************************************************************************/
         // Remembger previous SR levels for Breakout and Fakeout



void DrawSR_D(int TF)
{
         // Remembger previous SR levels for Breakout and Fakeout
         if (UseBreakOut_D)
         {
               if (LowerSR_D>0) PrevLowerSRLevel_D = LowerSR_D;
               else PrevLowerSRLevel_D = 0;
               if (UpperSR>0)   PrevUpperSRLevel_D = UpperSR_D;
               else PrevUpperSRLevel_D = 0;          
         }
         
         DeleteAllSR_D();
         UpperLimit_D = 0;
         HighSR_D = FindUpperLevel_D(TF);
         LocalMax = High[TF].a[iHighest(NULL , ReturnTF(TF) , MODE_HIGH , PeriodForSR_D , 1)];
         int LoopCounter = 0;
         do
         {
               if(DrawLines)  DrawHLine_D("UpperSR_D" , HighSR_D , Red);
               UpperSR_D = HighSR_D;
               if (Count_Touches_D ("UpperSR_D" , UpperSR_D,TF) >= TouchesForSR_D)  break;
               
               if(DrawLines)  DeleteArrows ("UpperSR_D");
               HighSR_D = HighSR_D + RoundPipsForSR_D*sPip;
               LoopCounter++;
               if(HighSR_D>LocalMax)
               {
                  if(DrawLines) ObjectDelete(0, "UpperSR_D");
                  UpperSR_D = 0;
                  UpperLimit_D = HighSR_D;
                  if(DrawLines)  DrawHLine_D("UpperLimit_D" , HighSR_D , Blue);
                  break;
               }
         } 
         while (LoopCounter < MaxHightOfSRDistance_D); 
         
         
         
         LowerLimit = 0;
         
         LowSR_D = FindLowerLevel_D(TF);  
         LocalMin = Low[TF].a[iLowest(NULL , ReturnTF(TF) , MODE_LOW , PeriodForSR_D , 1)];
         LoopCounter = 0;
         do
         {
               if(DrawLines) DrawHLine_D ("LowerSR_D" , LowSR_D , Green);
               LowerSR_D = LowSR_D;
               
               if (Count_Touches_D ("LowerSR_D" , LowerSR_D,TF) >= TouchesForSR) break;
               if(DrawLines) DeleteArrows ("LowerSR_D");
               LowSR_D = LowSR_D-RoundPipsForSR_D*sPip;
               LoopCounter++;
               if(LowSR_D<LocalMin || LoopCounter == MaxHightOfSRDistance_D)
               {
                  if(DrawLines) ObjectDelete (0, "LowerSR_D");
                  LowerSR_D = 0;
                  if(DrawLines) DrawHLine_D ("LowerLimit_D" , LowSR_D , Blue);
                  LowerLimit_D = LowSR_D;
                  break;
               }              
         }
         while (LoopCounter < MaxHightOfSRDistance_D );  
}



void DrawHLine_D (string name , double price, color Lcolor)
{
                     ObjectDelete (0,name);
                     ObjectCreate (0, name , OBJ_HLINE , 0 , 0 ,price);                    
                     ObjectSetInteger(0 , name , OBJPROP_COLOR , Lcolor);
                     ObjectSetInteger(0 , name , OBJPROP_STYLE , STYLE_SOLID);
                     ObjectSetInteger(0 , name , OBJPROP_WIDTH , 3);
                     ObjectSetInteger(0 , name , OBJPROP_RAY , true);    
}



void DeleteAllArrows_D ()
{
   string tempstring;
   for (int i=1 ; i<PeriodForSR_D ; i++)
   {
          tempstring = "UpperSR_D";
          StringAdd(tempstring,string(i));
          ObjectDelete(0,tempstring);
          tempstring = "LowerSR_D";
          StringAdd(tempstring,string(i));
          ObjectDelete(0,tempstring);     
   }
}   


void DeleteAllSR_D()
{
 
            if(DrawLines)
            {
                        DeleteAllArrows_D ();
                        ObjectDelete(0, "UpperLimit_D");
                        ObjectDelete(0, "LowerLimit_D");
                        ObjectDelete(0, "UpperSR_D");
                        ObjectDelete(0, "LowerSR_D");    
            }
            UpperLimit_D = 0;
            LowerLimit_D=0;
            UpperSR_D=0;
            LowerSR_D=0;     
}



int Count_Touches_D (string name , double CurrentHLine , int TF)
{
   int Counter = 0;
   for (int i=1 ; i<PeriodForSR_D ; i++)
   {
         if (  Open[TF].a[i] < CurrentHLine + uSlackForSR_D  && MathAbs(CurrentHLine - High[TF].a[i]) < uSlackForSR_D && Close[TF].a[i]+ uRejectionFromSR_D < CurrentHLine) 
         {
            Counter++;
            if(DrawLines)
            {
                  TempName = name;
                  StringAdd(TempName , string(i));
                  ObjectCreate(0 , TempName ,OBJ_ARROW_DOWN , 0 ,iTime(_Symbol , PERIOD_D1 , i) , MathMax(High[TF].a[i] ,CurrentHLine) +DistanceForDArow_D*sPip);
                  ObjectSetInteger(0,TempName,OBJPROP_COLOR ,clrRed);
                  ObjectSetInteger(0,TempName,OBJPROP_WIDTH ,4);
            }
            
         }
         if (Open[TF].a[i] > CurrentHLine - uSlackForSR_D && MathAbs(CurrentHLine - Low[TF].a[i]) < uSlackForSR_D && Close[TF].a[i]- uRejectionFromSR_D > CurrentHLine)
         {
           Counter++;
           if(DrawLines)
            {
                 TempName = name;
                 StringAdd(TempName , string(i));
                 ObjectCreate(0 , TempName ,OBJ_ARROW_UP , 0 ,iTime(_Symbol , PERIOD_D1 , i) , MathMin(Low[TF].a[i] ,CurrentHLine) -DistanceForUArow_D*sPip);
                 ObjectSetInteger(0,TempName,OBJPROP_COLOR ,clrGreen);
                 ObjectSetInteger(0,TempName,OBJPROP_WIDTH ,4);
            }
         }
   }
   //Print("daily counter is " , Counter);
   return (Counter);
}




double FindUpperLevel_D (int TF)
{
            TempForCalc = (Open[TF].a[0] / sPip) ; // convert to "normal number"
            TempForCalc = (TempForCalc / RoundPipsForSR_D) ;// devide for number of times includes the Rounding factor        
            TempForCalc = RoundPipsForSR_D*MathCeil (TempForCalc+MinHightOfSRDistance_D);// multiply by  the next (rounded up by min hight) Rounding factor 
            TempForCalc = TempForCalc*sPip ;// return to price relevet for chart 
            return  (TempForCalc);
}

double FindLowerLevel_D (int TF)
{
            TempForCalc = (Open[TF].a[0] / sPip) ; // convert to "normal number"
            TempForCalc = (TempForCalc / RoundPipsForSR_D) ;// devide for number of times includes the Rounding factor        
            TempForCalc = RoundPipsForSR_D*MathFloor (TempForCalc-MinHightOfSRDistance_D);// multiply by  the previous (rounded down by min hight) Rounding factor 
            TempForCalc = TempForCalc*sPip ;// return to price relevet for chart 
            return  (TempForCalc);
}



bool SR_check_is_buy_D (int TF)
{  
   if (TradeMethod >2)  return (SR_check_is_buy_D_stop (TF));
   if (LowerSR_D==0)    return (false);
   SRLevel = LowerSR_D;
   if (  Open[TF].a [0] - SRLevel < MaxDistanceFromSRATR_D*ATRBuffer[1]  ) return (true);
   return (false);
}    



bool SR_check_is_sell_D (int TF)
{
   if (TradeMethod >2)  return (SR_check_is_sell_D_stop (TF));
   if (UpperSR_D==0)    return (false);       
   SRLevel = UpperSR_D; 
   if (SRLevel - Open[TF].a [0]  < MaxDistanceFromSRATR_D*ATRBuffer[1]  ) return (true);
   return (false);
}    



bool SR_check_is_buy_D_stop (int TF)
{
   if (UpperSR_D==0)    return (false);       
   SRLevel = UpperSR_D; 
   if (SRLevel - Open[TF].a [0]  < MaxDistanceFromSRATR_D*ATRBuffer[1]  ) return (true);
   return (false);
}  

bool SR_check_is_sell_D_stop (int TF)
{  
   if (LowerSR_D==0)    return (false);
   SRLevel = LowerSR_D;
   if (  Open[TF].a [0] - SRLevel < MaxDistanceFromSRATR_D*ATRBuffer[1]  ) return (true);
   return (false);
}    






double Calculate_SR_Long_SL_D(int TF,double price)
{
   if (LowerSR_D==0) return Default_SL;
   return ((price - LowerSR_D + SL_SR_ATR_Slack_D*ATRBuffer[1] )/ pip );
}

double Calculate_SR_Short_SL_D(int TF,double price)
{
   if (UpperSR_D==0) return Default_SL;
   return ((UpperSR_D - price+ SL_SR_ATR_Slack_D*ATRBuffer[1])/ pip);
}



double Calculate_SR_Long_TP_D(int TF,double price)
{
   if (LowerSR_D==0) return 0;
   return ((UpperSR_D - price + ATR_SR_TP_Slack_D*ATRBuffer[1])/ pip);
}

double Calculate_SR_Short_TP_D(int TF,double price)
{
   if (UpperSR_D==0) return 0;
   return ((price - LowerSR_D + ATR_SR_TP_Slack_D*ATRBuffer[1] )/ pip );
}


void ManageSRExit_D(int Pos)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(SR_check_is_sell_D(5))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(SR_check_is_buy_D(5))
         trade.PositionClose(PositionGetTicket(Pos));
}


/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| Breakout / Fakeout - D                            |
//+------------------------------------------------------------------+
********************************************************************************************************************************/



bool Breakout_check_is_buy_D (int TF)
{  
   if (PrevUpperSRLevel_D==0)     return (false);
   SRLevel = PrevUpperSRLevel_D; 
   if (Close[TF].a [1] > SRLevel + SlackForBreakoutATR_D * ATRBuffer[1]) return (true);   
   return false ; 
}    

bool Breakout_check_is_sell_D (int TF)
{
   if (PrevLowerSRLevel_D==0)     return (false);       
   SRLevel = PrevLowerSRLevel_D; 
   if (Close[TF].a [1] < SRLevel - SlackForBreakoutATR_D * ATRBuffer[1]) return (true);   
   return false ; 
}    


void ManageBreakoutExit_D(int Pos)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(Breakout_check_is_sell_D(5))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(Breakout_check_is_buy_D(5))
         trade.PositionClose(PositionGetTicket(Pos));
}




bool Fakeout_check_is_buy_D (int TF)
{  
   if (LowerSR_D==0)     return (false);
   SRLevel = LowerSR_D; 
   if (Low[TF].a[iLowest(_Symbol , PERIOD_D1 , MODE_LOW , DaysFromFakeOut , 1)] > SRLevel - FakeOutATRSlack_D * ATRBuffer[1]) return (false); // broke down in a Fakeout (at least x times ATR)
   if (Low[TF].a[iLowest(_Symbol , PERIOD_D1 , MODE_LOW ,DaysBeforeFakeOut , DaysFromFakeOut)] < SRLevel)                  return (false); // was above SR before fakeout    
   return SR_check_is_buy_D(TF) ; 
}    

bool Fakeout_check_is_sell_D (int TF)
{
   if (UpperSR_D==0)     return (false);       
   SRLevel = UpperSR_D; 
   if (High[TF].a[iHighest(_Symbol , PERIOD_D1 , MODE_HIGH , DaysFromFakeOut , 1)] < SRLevel + FakeOutATRSlack_D * ATRBuffer[1]) return (false);
   if (High[TF].a[iHighest(_Symbol , PERIOD_D1 , MODE_HIGH ,DaysBeforeFakeOut , DaysFromFakeOut)] > SRLevel)                  return (false); // 
   return SR_check_is_sell_D(TF) ; 
}    



void ManageFakeoutExit_D(int Pos)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(Fakeout_check_is_sell_D(5))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(Fakeout_check_is_buy_D(5))
         trade.PositionClose(PositionGetTicket(Pos));
}