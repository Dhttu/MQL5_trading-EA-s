//+------------------------------------------------------------------+
//|                                  MST Candle Patterns Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"




//Color Pattern 0 - N/A . 1-G , 2-GGG , 3- GGR , 4-GRG , 5-GRR , 6-RGG , 7-RGR , 8-RRG , 9-RRR , 10-R


bool CheckCandlePattern(int TF_index , int legend, int sym )
{  
   ENUM_TIMEFRAMES TF = ReturnTF(TF_index);
   
   switch(legend)
  {
      case 0:
         Alert("CheckCandlePattern recived 0 as paremeter " );
         return false;
         break;
      case 1:
         return (Candle_color (1 , TF_index , sym) == 1);
         break;
      case 2:
         return (ThreeCandlePattern(TF_index , sym) == "GGG");
         break;
      case 3:
         return (ThreeCandlePattern(TF_index , sym) == "GGR");
         break;
      case 4:
         return (ThreeCandlePattern(TF_index , sym) == "GRG");
         break;
      case 5:
         return (ThreeCandlePattern(TF_index , sym) == "GRR");
         break;   
      case 6:
         return (ThreeCandlePattern(TF_index , sym) == "RGG");
         break;  
      case 7:
         return (ThreeCandlePattern(TF_index , sym) == "RGR");
         break;
      case 8:
         return (ThreeCandlePattern(TF_index , sym) == "RRG");
         break;
      case 9:
         return (ThreeCandlePattern(TF_index , sym) == "RRR");
         break;
      case 10:
         return (Candle_color (1 , TF_index , sym) == -1);
         break;   
      default:
        Alert("CheckCandlePattern recived wrong paremeter, paremetes is: " , TF_index);
        return false;
        break;  
   }
   return false;
}





int Candle_color (int candle_i , int TF , int sym)
{
   if(candle_i == history) return (0); // Make sure no error du to request of candle over history
   if (Close[TF].a[sym].b[candle_i] < Open[TF].a[sym].b[candle_i]) return (-1);//red
   if (Close[TF].a[sym].b[candle_i] > Open[TF].a[sym].b[candle_i]) return (1); //green
   return (0); // no body (open==close)
}




int SameCandleCount(int candle_i , int TF , int sym)
{
   if(Candle_color(candle_i  ,TF , sym) == Candle_color(candle_i+1  ,TF , sym))
      return (1+SameCandleCount(candle_i+1 , TF , sym));
   return 1;
}


int CountGreenCandles(int candle_i , int TF , int sym)
{
   if(Candle_color(candle_i  ,TF, sym) <=0 ) return 0;
   return (SameCandleCount(candle_i , TF, sym));   
}

int CountRedCandles(int candle_i , int TF , int sym)
{
   if(Candle_color(candle_i  ,TF, sym) >=0 ) return 0;
   return (SameCandleCount(candle_i , TF, sym));   
}


double Body_Size (int candle_i , int TF , int sym)
{
   return (MathAbs( (Close[TF].a[sym].b[candle_i] - Open[TF].a[sym].b[candle_i] )));
}

double Candle_Size (int candle_i , int TF, int sym)
{
   return (MathAbs( (High[TF].a[sym].b[candle_i] - Low[TF].a[sym].b[candle_i] )));
}



double Upper_Wik_Size (int candle_i, int TF , int sym)
{
   if (Candle_color (candle_i, TF, sym) ==-1) return ( (High[TF].a[sym].b[candle_i] - Open[TF].a[sym].b[candle_i]));
   else return ( (High[TF].a[sym].b[candle_i] - Close[TF].a[sym].b[candle_i] ));
}


double Lower_Wik_Size (int candle_i, int TF , int sym)
{
   if (Candle_color (candle_i, TF , sym) ==-1) return ( (Close[TF].a[sym].b[candle_i] - Low[TF].a[sym].b[candle_i]));
   else return ( (Open[TF].a[sym].b[candle_i] - Low[TF].a[sym].b[candle_i] ));
}


double Upper_wik_ratio (int candle_i, int TF, int sym)
{
   if (Upper_Wik_Size (candle_i, TF, sym) == 0 ) return (1000);
   return (Body_Size (candle_i, TF, sym) / Upper_Wik_Size (candle_i, TF, sym));
}


double Lower_wik_ratio (int candle_i, int TF , int sym)
{   
   if (Lower_Wik_Size (candle_i, TF, sym) == 0 ) return (1000);
   return (Body_Size (candle_i, TF, sym) / Lower_Wik_Size (candle_i, TF, sym));
}


double wik_ratio (int candle_i, int TF , int sym)
{
   if (Upper_Wik_Size (candle_i, TF, sym) == 0 &&  Lower_Wik_Size (candle_i, TF, sym) == 0  ) return (10); // no wiks
   return ( Body_Size(candle_i, TF, sym)  / (Upper_Wik_Size (candle_i, TF, sym) + Lower_Wik_Size (candle_i, TF, sym)));
}

bool Is_Marbouzo (int i, int TF , int sym)
{
         if (Candle_color(i, TF, sym)== 0) return false;
        if (MathMax(Upper_wik_ratio(i, TF, sym),Lower_wik_ratio(i, TF, sym))>=3 && wik_ratio(i, TF, sym)>1.75) return true;
        return false;
}



bool Ham(int i, int TF , int sym)
{
     if (wik_ratio(i,TF, sym) > 0.3) return false;
     if (Upper_Wik_Size(i,TF, sym) == 0) return true;
     if (Lower_Wik_Size(i,TF, sym) /Upper_Wik_Size(i,TF, sym) >2 ) return true;

     return false;
}


bool InvHam(int i, int TF , int sym)
{
     if (wik_ratio(i,TF, sym) > 0.3) return false;
     if (Lower_Wik_Size(1,TF, sym) == 0) return true;
     if (Upper_Wik_Size(1,TF, sym) / Lower_Wik_Size(1,TF, sym)  >2 ) return true;

     return false;
}


bool HHHL(int i, int TF , int sym)
{
   if (High[TF].a[sym].b[i] > High[TF].a[sym].b[i+1] && Low[TF].a[sym].b[i] > Low[TF].a[sym].b[i+1]) return true;
   return false;

}

bool LHLL(int i, int TF , int sym)
{
   if (High[TF].a[sym].b[i] < High[TF].a[sym].b[i+1] && Low[TF].a[sym].b[i] < Low[TF].a[sym].b[i+1]) return true;
   return false;

}

bool KangoroTail(int TF , int sym)
{
   if(Candle_color(1,TF, sym) == 1)
   {
      if (LHLL(2,TF, sym) && HHHL(1,TF, sym))
      {
         return true;
      }
      else return false;
   }
   
   if(Candle_color(1,TF, sym) == -1)
   {
      if (HHHL(2,TF, sym) && LHLL(1,TF, sym))
      {
         return true;
      }
      else return false;
   }
   return false;

}


bool HHHCLLL_C(int i, int TF, int sym)
{
   if (Candle_color(i, TF, sym) == 1)
      if (Close[TF].a[sym].b[i] > Close[TF].a[sym].b[i+1] && High[TF].a[sym].b[i] > High[TF].a[sym].b[i+1])
         return true;
   if (Candle_color(i, TF, sym) == -1)
      if (Close[TF].a[sym].b[i] < Close[TF].a[sym].b[i+1] && Low[TF].a[sym].b[i] < Low[TF].a[sym].b[i+1])
         return true;
   return false;
}



bool Out(int i, int TF , int sym)
{
   if (High[TF].a[sym].b[i] > High[TF].a[sym].b[i+1] && Low[TF].a[sym].b[i] < Low[TF].a[sym].b[i+1])
         return true;
   return false;
}



bool InBar(int i, int TF , int sym)
{
   if (High[TF].a[sym].b[i] < High[TF].a[sym].b[i+1] && Low[TF].a[sym].b[i] > Low[TF].a[sym].b[2])
         return true;
   return false;
}



bool Engulf(int i, int TF , int sym)
{
     if (Candle_color(i, TF, sym) == Candle_color(i+1, TF, sym))
         return false;
         
     if (Candle_color(i, TF, sym) == 1)
     {
         if(Open[TF].a[sym].b[i] <= Close[TF].a[sym].b[i+1] && Close[TF].a[sym].b[i] >= Open[TF].a[sym].b[i+1]) return true;
         else return false;   
     }
     
     if (Candle_color(i, TF, sym) == -1)
     {
         if(Open[TF].a[sym].b[i] >= Close[TF].a[sym].b[i+1] && Close[TF].a[sym].b[i] <= Open[TF].a[sym].b[i+1]) return true;
         else return false;   
     }
     return false;
}



string ThreeCandlePattern(int TF , int sym)
{
  string tempStr = "";
  if (Candle_color (3 , TF, sym) == 1)
      StringAdd(tempStr , "G");
  else if (Candle_color (3 , TF, sym) == -1)
      StringAdd(tempStr , "R");
  else
      StringAdd(tempStr , "N");
  if (Candle_color (2 , TF, sym) == 1)
      StringAdd(tempStr , "G");
  else if (Candle_color (2 , TF, sym) == -1)
      StringAdd(tempStr , "R");
  else
      StringAdd(tempStr , "N");
  if (Candle_color (1 , TF, sym) == 1)
      StringAdd(tempStr , "G");
  else if (Candle_color (1 , TF, sym) == -1)
      StringAdd(tempStr , "R");
  else
      StringAdd(tempStr , "N");
  return tempStr;
}


bool LongtPartialKangoro(int TF , int sym)
{
   if (Low[TF].a[sym].b[2] < Low[TF].a[sym].b[3])
      if (Low[TF].a[sym].b[2] < Low[TF].a[sym].b[1])
         return true ;
   return false ;

}


bool ShortPartialKangoro(int TF , int sym)
{
   if (High[TF].a[sym].b[2] > High[TF].a[sym].b[3])
      if (High[TF].a[sym].b[2] > High[TF].a[sym].b[1])
         return true ;
         
   return false ;
}




bool InsideBreakout_check_is_buy (int TF , int sym)
{     
   if (!InBar(2 , TF, sym)) return (false);
   if ( Close[TF].a[sym].b[1] > High[TF].a[sym].b[3] ) return (true);
   return (false);
}    


bool InsideBreakout_check_is_sell (int TF , int sym)
{     
   if (!InBar(2 , TF , sym)) return (false);
   if ( Close[TF].a[sym].b[1] < Low[TF].a[sym].b[3]) return (true);
   return (false);
}    


