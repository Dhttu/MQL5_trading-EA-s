//+------------------------------------------------------------------+
//|                                            MST Range Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"


   
input group "SR parameters"; 
input int PeriodForSR = 100;
input int TouchesForSR = 3;
input double SlackForSRATRDiv = 10;
input double ATRFejectionMultiplier = 1;
input double MaxDistanceFromSRATR = 2;
input int MinHightOfSRDistance = 3;
input int MaxHightOfSRDistance = 200;   


   
input group "BreakOut parameters"; 
input double SlackForBreakoutATR = 0.1   ;



input group "FakeOut parameters"; 
input int BarsFromFakeOut = 2   ;
input int BarsBeforeFakeOut = 2   ;
input double FakeOutATRSlack = 0.5  ;



   
double UpperSR[], UpperLimit[] , LowerSR[] , LowerLimit[];

double PrevLowerSRLevel[];
double PrevUpperSRLevel[];
//double RejectionFromSR = 2; //ready for user input, decided to use 2 times the slack


bool proceed;


double HighSR, LowSR;

double uSlackForSR,uRejectionFromSR;

double LocalMax,LocalMin;

double DistanceForArow = 1 ;
double DistanceForDArow = 3;
double DistanceForUArow = 1;

string TempName;


double HighestInRange;
double LowestInRange; 
double SRLevel; 


int TempDigits;

void SR_Initiate()
{  
   DistanceForDArow = 2*DistanceForArow;
   DistanceForUArow = DistanceForArow;
}   

/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| SR - H                               |
//+------------------------------------------------------------------+
********************************************************************************************************************************/

void InitilizeSlacksByATR(int sym)
{
   TempDigits =  int(SymbolInfoInteger(SymbolArray[sym] , SYMBOL_DIGITS));
   uSlackForSR = NormalizeDouble(ATRBuffer[sym].b[1]/SlackForSRATRDiv ,TempDigits);
   uRejectionFromSR = ATRBuffer[sym].b[1] * ATRFejectionMultiplier;
}



void DrawSR(int TF , int sym)
{
         // Remembger previous SR levels for Breakout and Fakeout
         InitilizeSlacksByATR(sym);
         if (UseBreakOut)
         {
               if (LowerSR[sym]>0) PrevLowerSRLevel[sym] = LowerSR[sym];
               else PrevLowerSRLevel[sym] = 0;
               if (UpperSR[sym]>0) PrevUpperSRLevel[sym] = UpperSR[sym];
               else PrevUpperSRLevel[sym] = 0;          
         }
         DeleteAllSR(sym);
         UpperLimit[sym] = 0;
         HighSR = FindUpperLevel(TF , sym);
         LocalMax = High[TF].a[sym].b[iHighest(SymbolArray[sym] , ReturnTF(TF) , MODE_HIGH , PeriodForSR , 1)];
         int LoopCounter = 0;
         do
         {
               if(DrawLines) DrawHLine("UpperSR" , HighSR , Red);
               UpperSR[sym] = HighSR;
               if (Count_Touches ("UpperSR" , UpperSR[sym],TF, sym) >= TouchesForSR)  break;
               
               if(DrawLines)  DeleteArrows ("UpperSR");
               HighSR = HighSR+uSlackForSR;
               LoopCounter++;
               if(HighSR>LocalMax)
               {
                  if(DrawLines)  ObjectDelete(0, "UpperSR");
                  UpperSR[sym] = 0;
                  if(DrawLines)  DrawHLine("UpperLimit" , HighSR , Blue);
                  UpperLimit[sym] = HighSR;

                  break;
               }
         } 
         while (LoopCounter < MaxHightOfSRDistance); 
         
         LowerLimit[sym] = 0;
         LowSR = FindLowerLevel(TF,sym);  
         LocalMin = Low[TF].a[sym].b[iLowest(SymbolArray[sym] , ReturnTF(TF) , MODE_LOW , PeriodForSR , 1)];
         LoopCounter = 0;
         do
         {
               if(DrawLines) DrawHLine ("LowerSR" , LowSR , Green);
               LowerSR[sym] = LowSR;
               
               if (Count_Touches ("LowerSR" , LowerSR[sym],TF , sym) >= TouchesForSR) break;
               if(DrawLines)   DeleteArrows ("LowerSR");
               LowSR = LowSR-uSlackForSR;
               LoopCounter++;
               if(LowSR<LocalMin || LoopCounter == MaxHightOfSRDistance)
               {
                  if(DrawLines)   ObjectDelete (0, "LowerSR");
                  LowerSR[sym] = 0;
                  if(DrawLines)  DrawHLine ("LowerLimit" , LowSR , Blue );
                  LowerLimit[sym] = LowSR;
                  break;
               }              
         }
         while (LoopCounter < MaxHightOfSRDistance );  
}


double FindUpperLevel (int TF , int sym)
{
            return  (Open[TF].a[sym].b[0] + MinHightOfSRDistance *uSlackForSR);
}

double FindLowerLevel (int TF,int sym)
{
            return  (Open[TF].a[sym].b[0] - MinHightOfSRDistance *uSlackForSR);
}


int Count_Touches (string name , double CurrentHLine , int TF , int sym)
{
   int Counter = 0;
   for (int i=1 ; i<PeriodForSR ; i++)
   {
         if(Open[TF].a[sym].b[i] < CurrentHLine && Close[TF].a[sym].b[i] < CurrentHLine)
            if(High[TF].a[sym].b[i] > CurrentHLine || (Candle_Size(i , TF, sym) > uRejectionFromSR && CurrentHLine - High[TF].a[sym].b[i] < uRejectionFromSR/2))
            {
               Counter++;
               if(DrawLines)
               {
                     TempName = name;
                     StringAdd(TempName , string(i));
                     ObjectCreate(0 , TempName ,OBJ_ARROW_DOWN , 0 ,iTime(SymbolArray[sym] , Main_TF , i) , MathMax(High[TF].a[sym].b[i] ,CurrentHLine) +DistanceForDArow*uSlackForSR);
                     ObjectSetInteger(0,TempName,OBJPROP_COLOR ,clrRed);
               }
            
            }
         if(Open[TF].a[sym].b[i] > CurrentHLine && Close[TF].a[sym].b[i] > CurrentHLine)
            if(Low[TF].a[sym].b[i] < CurrentHLine || (Candle_Size(i , TF, sym) > uRejectionFromSR &&  Low[TF].a[sym].b[i] - CurrentHLine < uRejectionFromSR/2))
            {
              Counter++;
              if(DrawLines)
              {
                    TempName = name;
                    StringAdd(TempName , string(i));
                    ObjectCreate(0 , TempName ,OBJ_ARROW_UP , 0 ,iTime(SymbolArray[sym] , Main_TF , i) , MathMin(Low[TF].a[sym].b[i] ,CurrentHLine) -DistanceForUArow*uSlackForSR);
                    ObjectSetInteger(0,TempName,OBJPROP_COLOR ,clrGreen);
               }
            }
   }
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




bool SR_check_is_buy (int TF ,int sym)
{  
   if (TradeMethod >2 ) return (SR_check_is_buy_stop (TF,sym)); 
   if (LowerSR[sym]==0)     return (false);
   SRLevel = LowerSR[sym];
   if (  Open[TF].a[sym].b[0] - SRLevel < MaxDistanceFromSRATR * ATRBuffer[sym].b[1]  ) return (true);
   return (false);
}    


bool SR_check_is_sell (int TF,int sym)
{
   if (TradeMethod >2) return (SR_check_is_sell_stop (TF,sym));   
   if (UpperSR[sym]==0)     return (false);       
   SRLevel = UpperSR[sym]; 
   if (SRLevel - Open[TF].a[sym].b[0]  < MaxDistanceFromSRATR * ATRBuffer[sym].b[1]  ) return (true);
   return (false);
}    


bool SR_check_is_buy_stop (int TF , int sym)
{
   if (UpperSR[sym]==0)     return (false);       
   SRLevel = UpperSR[sym]; 
   if (SRLevel - Open[TF].a[sym].b[0]  < MaxDistanceFromSRATR * ATRBuffer[sym].b[1]  ) return (true);
   return (false);
}    

bool SR_check_is_sell_stop (int TF , int sym)
{  
   if (LowerSR[sym]==0)     return (false);
   SRLevel = LowerSR[sym];
   if (  Open[TF].a[sym].b[0] - SRLevel < MaxDistanceFromSRATR * ATRBuffer[sym].b[1]  ) return (true);
   return (false);
}    




double Calculate_SR_Long_SL(int TF,double price ,int sym)
{
   if (LowerSR[sym]==0) return Default_SL;
   return ((price - LowerSR[sym] + SL_SR_ATR_Slack*ATRBuffer[sym].b[1] ) );
}

double Calculate_SR_Short_SL(int TF,double price,int sym)
{
   if (UpperSR[sym]==0) return Default_SL;
   return ((UpperSR[sym] - price+ SL_SR_ATR_Slack*ATRBuffer[sym].b[1]));
}


double Calculate_SR_Long_TP(int TF,double price,int sym)
{
   if (LowerSR[sym]==0) return 0;
   return ((UpperSR[sym] - price+ ATR_SR_TP_Slack*ATRBuffer[sym].b[1]));
}

double Calculate_SR_Short_TP(int TF,double price,int sym)
{
   if (UpperSR[sym]==0) return 0;
   return ((price - LowerSR[sym] + ATR_SR_TP_Slack*ATRBuffer[sym].b[1] ) );
}



void DeleteAllSR(int sym)
{     
            if(DrawLines)  
            {
                  DeleteAllArrows ();
                  ObjectDelete(0, "UpperLimit");
                  ObjectDelete(0, "LowerLimit");
                  ObjectDelete(0, "UpperSR");
                  ObjectDelete(0, "LowerSR");
            }
            UpperLimit[sym] = 0;
            LowerLimit[sym]=0;
            UpperSR[sym]=0;
            LowerSR[sym]=0;             
}

void ManageSRExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(SR_check_is_sell(Main_TF_N , sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(SR_check_is_buy(Main_TF_N , sym))
         trade.PositionClose(PositionGetTicket(Pos));
}


/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| Breakout / Fakeout - H                               |
//+------------------------------------------------------------------+
********************************************************************************************************************************/




bool Breakout_check_is_buy (int TF, int sym)
{  
   if (PrevUpperSRLevel[sym]==0)     return (false);
   SRLevel = PrevUpperSRLevel[sym]; 
   if (Close[TF].a[sym].b[1] > SRLevel + SlackForBreakoutATR * ATRBuffer[sym].b[1]) return (true);   
   return false ; 
}    

bool Breakout_check_is_sell (int TF, int sym)
{
   if (PrevLowerSRLevel[sym]==0)     return (false);       
   SRLevel = PrevLowerSRLevel[sym]; 
   if (Close[TF].a[sym].b[1] < SRLevel - SlackForBreakoutATR * ATRBuffer[sym].b[1]) return (true);   
   return false ; 
}    

     

void ManageBreakoutExit(int Pos, int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(Breakout_check_is_sell(Main_TF_N,sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(Breakout_check_is_buy(Main_TF_N,sym))
         trade.PositionClose(PositionGetTicket(Pos));
}


bool Fakeout_check_is_buy (int TF, int sym)
{  
   if (LowerSR[sym]==0)     return (false);
   SRLevel = LowerSR[sym]; 
   if (Low[TF].a[sym].b[iLowest(SymbolArray[sym] , Main_TF , MODE_LOW , BarsFromFakeOut , 1)] > SRLevel - FakeOutATRSlack * ATRBuffer[sym].b[1]) return (false); // broke down in a Fakeout (at least x times ATR)
   if (Low[TF].a[sym].b[iLowest(SymbolArray[sym] , Main_TF , MODE_LOW ,BarsBeforeFakeOut , BarsFromFakeOut)] < SRLevel)                         return (false); // was above SR before fakeout    
   return SR_check_is_buy(TF,sym) ; 
}    

bool Fakeout_check_is_sell (int TF, int sym)
{
   if (UpperSR[sym]==0)     return (false);       
   SRLevel = UpperSR[sym]; 
   if (High[TF].a[sym].b[iHighest(SymbolArray[sym] , Main_TF , MODE_HIGH , BarsFromFakeOut , 1)] < SRLevel + FakeOutATRSlack * ATRBuffer[sym].b[1]) return (false);
   if (High[TF].a[sym].b[iHighest(SymbolArray[sym] , Main_TF , MODE_HIGH ,BarsBeforeFakeOut , BarsFromFakeOut)] > SRLevel)                         return (false); // 
   return SR_check_is_sell(TF,sym) ; 
}    


void ManageFakeoutExit(int Pos, int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(Fakeout_check_is_sell(Main_TF_N,sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(Fakeout_check_is_buy(Main_TF_N,sym))
         trade.PositionClose(PositionGetTicket(Pos));
}


