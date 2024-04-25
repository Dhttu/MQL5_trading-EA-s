//+------------------------------------------------------------------+
//|                                           MST Double Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"



input group "Double parameters"; 
input double SlackForDoubleATR = 0.1;
input int PeriodForDouble = 50;
input int WaitBetweenCandlesDouble = 6;
input int MaxBarsFromDouble = 5;
input double MaxDistanceFromDoubleATR = 3;
input double MinDistanceFromDoubleATR = 0.25;


int temp1 , temp2 ;
int FirstTouchCandle , SecondTouchCandle ;
double FirstTouchValue , SecondTouchValue ;
bool DoubleUp[] ;
bool DoubleDown[] ;

double DoubleUpPrice[] ;
double DoubleDownPrice[];





/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| Double - H                               |
//+------------------------------------------------------------------+
********************************************************************************************************************************/


void DrawUpDoublePoint(string name ,int i ,  double PointPrice , int TF , int sym)
{
               ObjectCreate(0 , name , OBJ_ARROW , 0 , iTime(SymbolArray[sym] , ReturnTF(TF) , i) , PointPrice); // Create an arrow, 
               ObjectSetInteger(0,name,OBJPROP_ARROWCODE,233);    // Set the arrow code                
               ObjectSetInteger(0,name,OBJPROP_COLOR ,clrBlue);
               ObjectSetInteger(0,name,OBJPROP_WIDTH ,3);
               ChartRedraw(0);   
}


void DrawDownDoublePoint(string name ,int i ,  double PointPrice , int TF, int sym)
{
               ObjectCreate(0 , name , OBJ_ARROW , 0 , iTime(SymbolArray[sym] , ReturnTF(TF) , i) , PointPrice); // Create an arrow, 
               ObjectSetInteger(0,name,OBJPROP_ARROWCODE,234);    // Set the arrow code                
               ObjectSetInteger(0,name,OBJPROP_COLOR ,clrBlue);
               ObjectSetInteger(0,name,OBJPROP_WIDTH ,3);
               ChartRedraw(0);   
}


void DeleteDoubleUpPoints( int sym)
{
            if(DrawLines)
            {
               ObjectDelete(0, "FirstDoubleUpPoint");       
               ObjectDelete(0, "SecondDoubleUpPoint");  
            }
            DoubleUp[sym] = false;
            DoubleUpPrice[sym] = 0;
}


void DeleteDoubleDownPoints(int sym)
{
            if(DrawLines)
            {
                  ObjectDelete(0, "FirstDoubleDownPoint");
                  ObjectDelete(0, "SecondDoubleDownPoint");
            }
            DoubleDown[sym] = false;
            DoubleDownPrice[sym] = 0;
}





void DrawDoubleUp(int TF , int sym)
{
   DeleteDoubleUpPoints(sym);
   temp1 = iLowest(SymbolArray[sym] , Main_TF , MODE_LOW , PeriodForDouble , 1) ; 
   if (temp1 ==1)  temp2 = iLowest(SymbolArray[sym] , Main_TF , MODE_LOW , PeriodForDouble-1 , 2) ; 
   else temp2 = MathMin (iLowest(SymbolArray[sym] , Main_TF , MODE_LOW , PeriodForDouble - temp1 , temp1 + 1 ) , iLowest(SymbolArray[sym] , Main_TF , MODE_LOW , temp1-2 , 1)); // find 2nd point by 2 ranges -> before and after first point
   if (MathAbs(temp1 - temp2) < WaitBetweenCandlesDouble) return ;
   FirstTouchCandle =  MathMax(temp1 , temp2);
   SecondTouchCandle = MathMin(temp1 , temp2);
   
   FirstTouchValue  = Low[TF].a[sym].b[FirstTouchCandle]  ; 
   SecondTouchValue = Low[TF].a[sym].b[SecondTouchCandle]  ; 

   if(MathAbs(FirstTouchValue - SecondTouchValue) > SlackForDoubleATR * ATRBuffer[sym].b[1]) return ; // no double
   if(Open[TF].a[sym].b[0]  < SecondTouchValue) return ; // below double - double is invalidated
   if(DrawLines) DrawUpDoublePoint("FirstDoubleUpPoint"  , FirstTouchCandle  , FirstTouchValue  , TF , sym);
   if(DrawLines) DrawUpDoublePoint("SecondDoubleUpPoint" , SecondTouchCandle , SecondTouchValue , TF , sym);   
   if(SecondTouchCandle>MaxBarsFromDouble) return ; // to much cbadles passed since double
   if(Open[TF].a[sym].b[0] -SecondTouchValue < MinDistanceFromDoubleATR * ATRBuffer[sym].b[1]) return ; // to close to double
   if(Open[TF].a[sym].b[0] -SecondTouchValue > MaxDistanceFromDoubleATR * ATRBuffer[sym].b[1]) return ; // to far from double

   DoubleUp[sym] = true;
   DoubleUpPrice[sym] = SecondTouchValue;
}

void DrawDoubleDown(int TF , int sym)
{
   DeleteDoubleDownPoints(sym);
   temp1 = iHighest(SymbolArray[sym] , Main_TF , MODE_HIGH , PeriodForDouble , 1) ; 
   if (temp1 ==1)  temp2 = iHighest(SymbolArray[sym] , Main_TF , MODE_HIGH , PeriodForDouble-1 , 2) ; 
   else temp2 = MathMin (iHighest(SymbolArray[sym] , Main_TF , MODE_HIGH , PeriodForDouble - temp1 , temp1 + 1 ) , iHighest(SymbolArray[sym] , Main_TF , MODE_HIGH , temp1-2 , 1)); // find 2nd point by 2 ranges -> before and after first point
   if (MathAbs(temp1 - temp2) < WaitBetweenCandlesDouble) return ;
   FirstTouchCandle =  MathMax(temp1 , temp2);
   SecondTouchCandle = MathMin(temp1 , temp2);
   
   FirstTouchValue  = High[TF].a[sym].b[FirstTouchCandle]  ; 
   SecondTouchValue = High[TF].a[sym].b[SecondTouchCandle]  ; 

   if(MathAbs(FirstTouchValue - SecondTouchValue) > SlackForDoubleATR * ATRBuffer[sym].b[1]) return ; // no double
   
   if(Open[TF].a[sym].b[0]  > SecondTouchValue) return ; // Above double - double is invalidated
   if(DrawLines) DrawDownDoublePoint("FirstDoubleDownPoint"  , FirstTouchCandle  , FirstTouchValue  + ATRBuffer[sym].b[1], TF , sym);
   if(DrawLines) DrawDownDoublePoint("SecondDoubleDownPoint" , SecondTouchCandle , SecondTouchValue + ATRBuffer[sym].b[1], TF ,  sym);
   if(SecondTouchCandle>MaxBarsFromDouble) return ; // to much cbadles passed since double
   if(SecondTouchValue - Open[TF].a[sym].b[0] < MinDistanceFromDoubleATR * ATRBuffer[sym].b[1]) return ; // to close to double
   if(SecondTouchValue - Open[TF].a[sym].b[0] > MaxDistanceFromDoubleATR * ATRBuffer[sym].b[1]) return ; // to far from double

   DoubleDown[sym] = true;
   DoubleDownPrice[sym] = SecondTouchValue;
}



bool Double_check_is_buy (int TF, int sym)
{  
   if (TradeMethod >2 ) return DoubleDown[sym]; 
   return DoubleUp[sym];
}    


bool Double_check_is_sell (int TF,int sym)
{
   if (TradeMethod >2 ) return DoubleUp[sym];   
   return DoubleDown[sym];
}    






void ManageDoubleExit(int Pos , int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(Double_check_is_sell(Main_TF_N , sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(Double_check_is_buy(Main_TF_N, sym))
         trade.PositionClose(PositionGetTicket(Pos));
}

