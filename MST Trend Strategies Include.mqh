//+------------------------------------------------------------------+
//|                                 MST Trend Strategies Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"



input group "Trend parameters"; 
input double SlackForTrendATR = 0.1;
input double MinSlopeATRsDiv = 10;
input int PeriodForTrend = 100;
input double MaxDistanceFromTrendATR =2;

input string TBO_P; // ***** Trend BreakOut parameters *****
input double SlackForTrendBreakoutATR = 0.1   ;




double TrendLevel; 


double TempAnchorPrice ,  TempSlope ,Temp2AnchorPrice  , Temp2Slope , TrendU_AnchorPrice=0  ,TrendU_Slope=0 , TrendD_AnchorPrice = 0  ,TrendD_Slope = 0;
int TempAnchorShift , Temp2AnchorShift , TrendU_AnchorShift, TrendD_AnchorShift;

bool found = false;
bool Violated = false;
int MidTouches = 0;
string TrendString;

// new varibales:

int LineLength=0;
double AnchorPoint =0 , FinalPoint =0;
double slope = 0,fx = 0;

struct TrendLine_S
{
   double LineStart;
   double LineSlope;
   int LineFirstBar;
};

TrendLine_S     UpTrend[],     DownTrend[];
TrendLine_S PrevUpTrend[], PrevDownTrend[];



double CalcTrendValue(double a , double b , double x)
{
   return (a*x + b);
}


/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//|Trend - H                               |
//+------------------------------------------------------------------+
********************************************************************************************************************************/


void DeleteAllTrend(int sym)
{
       if(DrawLines)
       {
            DeleteAllPoints ();       
            ObjectDelete(0, "UpTrend");       
            ObjectDelete(0, "DownTrend");       
       }
            UpTrend[sym].LineStart =0;
            DownTrend[sym].LineStart =0;            
}



void DeleteAllPoints ()
{
   string tempstring;
   for (int i=1 ; i<PeriodForTrend ; i++)
   {
          tempstring = "UpTrend";
          StringAdd(tempstring,string(i));
          ObjectDelete(0,tempstring);
   
          tempstring = "DownTrend";
          StringAdd(tempstring,string(i));
          ObjectDelete(0,tempstring);  
   }
}   


void DrawTrendLines(int TF , int sym)
{
       if (UseTrendBreakOut)
       {
               if (UpTrend[sym].LineStart>0) PrevUpTrend[sym] = UpTrend[sym];
               else PrevUpTrend[sym].LineStart = 0;
               if (DownTrend[sym].LineStart>0) PrevDownTrend[sym] = DownTrend[sym];
               else PrevDownTrend[sym].LineStart = 0;          
       }
     DeleteAllTrend(sym);
     // Up Trend:
     TrendString = "UpTrend";
     AnchorPoint =0 ;
     FinalPoint =0;
     slope = 0;
     MidTouches = 0;
     found = false;
 
     for( int i = 1 ; i<PeriodForTrend-5 ; i++)   
     {
         for( int k = PeriodForTrend ; k>=i+5 ; k--)  
         {
            Violated = false;
            AnchorPoint = Low[TF].a[sym].b[k];
            FinalPoint =  Low[TF].a[sym].b[i];
            if (AnchorPoint > FinalPoint) continue;
            slope = (FinalPoint - AnchorPoint)/(k-i-1);
            if (slope < ATRBuffer[sym].b[1] / MinSlopeATRsDiv) continue;
            for( int l = k ; l>=1 ; l--)  
            {
               fx = CalcTrendValue(slope , AnchorPoint , k-l);
               if(Close[TF].a[sym].b[l] < fx)
               {
                   Violated = true;
                   break;
               }
            }
            if (Violated) continue;
            for( int j = k-2 ; j>=i+2 ; j--)  
            {
               fx = CalcTrendValue(slope , AnchorPoint , k-j);
               if( MathAbs(Low[TF].a[sym].b[j] - fx) < SlackForTrendATR * ATRBuffer[sym].b[1])
               {
                  MidTouches+=1;
                  if(DrawLines)  DrawMidPoint(TrendString , j , fx , TF , sym);
                  found = true;
               }
             }
                if( found) 
                {
                      if(DrawLines)
                      {
                           if (!ObjectCreate (0, TrendString , OBJ_TREND , 0 , iTime(SymbolArray[sym] , Main_TF , k) , AnchorPoint , iTime(SymbolArray[sym] , Main_TF , i) , FinalPoint))   break ;
                           ObjectSetInteger(0 , TrendString , OBJPROP_COLOR , Green);
                           ObjectSetInteger(0 , TrendString , OBJPROP_STYLE , STYLE_DASH);
                           ObjectSetInteger(0 , TrendString , OBJPROP_WIDTH , 1);
                           ObjectSetInteger(0 , TrendString , OBJPROP_RAY_RIGHT , true);
                           DrawEndPoint(TrendString , k  , AnchorPoint , TF , sym);
                          DrawEndPoint(TrendString , i  , FinalPoint , TF, sym);
                           
                      }
                      UpTrend[sym].LineStart = AnchorPoint;
                      UpTrend[sym].LineSlope = slope;
                      UpTrend[sym].LineFirstBar = k;
                    break;
                 }
            if( found)  break;
         }
         if( found)  break;
     }

     // down Trend:
     TrendString = "DownTrend";
     AnchorPoint =0 ;
     FinalPoint =0;
     slope = 0;
     MidTouches = 0;
     found = false;
 
     for( int i = 1 ; i<PeriodForTrend-5 ; i++)   
     {
         for( int k = PeriodForTrend ; k>=i+5 ; k--)  
         {
            Violated = false;
            AnchorPoint = High[TF].a[sym].b[k];
            FinalPoint =  High[TF].a[sym].b[i];
            if (AnchorPoint < FinalPoint) continue;
            slope = (FinalPoint - AnchorPoint)/(k-i-1);
            if (-slope < ATRBuffer[sym].b[1] / MinSlopeATRsDiv) continue;
            for( int l = k ; l>=1 ; l--)  
            {
               fx = CalcTrendValue(slope , AnchorPoint , k-l);
               if(Close[TF].a[sym].b[l] > fx)
               {
                   Violated = true;
                   break;
               }
            }
            if (Violated) continue;
            for( int j = k-2 ; j>=i+2 ; j--)  
            {
               fx = CalcTrendValue(slope , AnchorPoint , k-j);
               if( MathAbs(High[TF].a[sym].b[j] - fx) < SlackForTrendATR * ATRBuffer[sym].b[1])
               {
                  MidTouches+=1;
                  if(DrawLines)  DrawMidPoint(TrendString , j , fx , TF , sym);
                  found = true;
               }
             }
                if( found) 
                {
                      if(DrawLines)
                      {
                           if (!ObjectCreate (0, TrendString , OBJ_TREND , 0 , iTime(SymbolArray[sym] , Main_TF , k) , AnchorPoint , iTime(SymbolArray[sym] , Main_TF , i) , FinalPoint))   break ;
                           ObjectSetInteger(0 , TrendString , OBJPROP_COLOR , Red);
                           ObjectSetInteger(0 , TrendString , OBJPROP_STYLE , STYLE_DASH);
                           ObjectSetInteger(0 , TrendString , OBJPROP_WIDTH , 1);
                           ObjectSetInteger(0 , TrendString , OBJPROP_RAY_RIGHT , true);
                           DrawEndPoint(TrendString , k  , AnchorPoint , TF, sym);
                           DrawEndPoint(TrendString , i  , FinalPoint , TF, sym);
                           
                      }
                      DownTrend[sym].LineStart = AnchorPoint;
                      DownTrend[sym].LineSlope = slope;
                      DownTrend[sym].LineFirstBar = k;
                    break;
                 }
            if( found)  break;
         }
         if( found)  break;
     }
}



void DrawMidPoint(string name ,int i ,  double PointPrice , int TF , int sym)
{
               TempName = name;
               StringAdd(TempName , string(i));

               ObjectCreate(0 , TempName , OBJ_ARROW , 0 , iTime(SymbolArray[sym] , ReturnTF(TF) , i) , PointPrice); // Create an arrow, 
               ObjectSetInteger(0,TempName,OBJPROP_ARROWCODE,119);    // Set the arrow code                
               ObjectSetInteger(0,TempName,OBJPROP_COLOR ,clrYellow);
               ChartRedraw(0);   
}

void DrawEndPoint(string name ,int i ,  double PointPrice , int TF , int sym)
{
               TempName = name;
               StringAdd(TempName , string(i));

               ObjectCreate(0 , TempName , OBJ_ARROW , 0 , iTime(SymbolArray[sym] , ReturnTF(TF) , i) , PointPrice); // Create an arrow, 
               ObjectSetInteger(0,TempName,OBJPROP_ARROWCODE,164);    // Set the arrow code                
               ObjectSetInteger(0,TempName,OBJPROP_COLOR ,clrBlue);
               ChartRedraw(0);   
}



bool Trend_check_is_buy (int TF , int sym)
{  
   if (TradeMethod >2 ) return (Trend_check_is_buy_stop (TF, sym)); 
   if (UpTrend[sym].LineStart == 0)    return (false);
   TrendLevel =  CalcTrendValue(UpTrend[sym].LineSlope , UpTrend[sym].LineStart , UpTrend[sym].LineFirstBar);             
   if ( Open[TF].a[sym].b[0] > TrendLevel &&  Open[TF].a[sym].b[0] - TrendLevel < MaxDistanceFromTrendATR*ATRBuffer[sym].b[1]  )    return (true);
   return (false);
}    

bool Trend_check_is_sell (int TF, int sym)
{  
   if (TradeMethod >2) return (SR_check_is_sell_stop (TF, sym));   
   if (DownTrend[sym].LineStart == 0)    return (false);
   TrendLevel =  CalcTrendValue(DownTrend[sym].LineSlope , DownTrend[sym].LineStart , DownTrend[sym].LineFirstBar);             
   if ( Open[TF].a[sym].b[0] < TrendLevel &&  TrendLevel - Open[TF].a[sym].b[0]   < MaxDistanceFromTrendATR*ATRBuffer[sym].b[1]  )    return (true);
   return (false);
}    



bool Trend_check_is_buy_stop (int TF, int sym)
{  
   if (DownTrend[sym].LineStart == 0)    return (false);
   TrendLevel =  CalcTrendValue(DownTrend[sym].LineSlope , DownTrend[sym].LineStart , DownTrend[sym].LineFirstBar);             
   if ( Open[TF].a[sym].b[0] < TrendLevel &&  TrendLevel - Open[TF].a[sym].b[0] < MaxDistanceFromTrendATR*ATRBuffer[sym].b[1]  )    return (true);
   return (false);
}    


bool Trend_check_is_sell_stop (int TF, int sym)
{  
   if (UpTrend[sym].LineStart == 0)    return (false);
   TrendLevel =  CalcTrendValue(UpTrend[sym].LineSlope , UpTrend[sym].LineStart , UpTrend[sym].LineFirstBar);             
   if ( Open[TF].a[sym].b[0] > TrendLevel &&   Open[TF].a[sym].b[0] - TrendLevel   < MaxDistanceFromTrendATR*ATRBuffer[sym].b[1]  )    return (true);
   return (false);
}   



double Calculate_Trend_Long_SL(int TF,double price , int sym)
{
   
   if (UpTrend[sym].LineStart==0) return Default_SL;
   return ((price - UpTrend[sym].LineStart +  SL_Trend_ATR_Slack * ATRBuffer[sym].b[1] ));
}

double Calculate_Trend_Short_SL(int TF,double price, int sym)
{
   if (DownTrend[sym].LineStart==0) return Default_SL;
   return ((DownTrend[sym].LineStart - price + SL_Trend_ATR_Slack * ATRBuffer[sym].b[1]));
}


void ManageTrendExit(int Pos, int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(Trend_check_is_sell(Main_TF_N , sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(Trend_check_is_buy(Main_TF_N , sym))
         trade.PositionClose(PositionGetTicket(Pos));
}






/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//| TrendBreakout                             |
//+------------------------------------------------------------------+
********************************************************************************************************************************/




bool TrendBreakOut_check_is_buy (int TF, int sym)
{  
   if (PrevDownTrend[sym].LineStart==0)     return (false);
   TrendLevel = CalcTrendValue(PrevDownTrend[sym].LineSlope   , PrevDownTrend[sym].LineStart   , PrevDownTrend[sym].LineFirstBar); 
   if (Close[TF].a[sym].b[1] > TrendLevel + SlackForTrendBreakoutATR * ATRBuffer[sym].b[1]) return (true);   
   return false ; 
}    

bool TrendBreakOut_check_is_sell (int TF, int sym)
{
   if (PrevUpTrend[sym].LineStart==0)     return (false);       
   TrendLevel = CalcTrendValue(PrevUpTrend[sym].LineSlope   , PrevUpTrend[sym].LineStart   , PrevUpTrend[sym].LineFirstBar); 
   if (Close[TF].a[sym].b[1] < TrendLevel - SlackForTrendBreakoutATR * ATRBuffer[sym].b[1]) return (true);   
   return false ; 
}    

     

void ManageTrendBreakOutExit(int Pos, int sym)
{
   if(posInfo.PositionType()==POSITION_TYPE_BUY)
      if(TrendBreakOut_check_is_sell(Main_TF_N, sym))
      {
         trade.PositionClose(PositionGetTicket(Pos));
         return;
      }
   if(posInfo.PositionType()==POSITION_TYPE_SELL)
      if(TrendBreakOut_check_is_buy(Main_TF_N, sym))
         trade.PositionClose(PositionGetTicket(Pos));
}