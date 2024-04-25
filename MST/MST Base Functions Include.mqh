//+------------------------------------------------------------------+
//|                                   MST Base Functions Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"


 
//--- indicator buffers           
struct ArraySet
{
    double b[]; 
};

//--- price buffers           
struct ArrayDualSet
{
    ArraySet a[]; 
};

ArrayDualSet Close[7]  , Open[7]   , High[7]   , Low[7] ;

ArraySet  ATRBuffer[];
int      ATRHandle[];
ArraySet  ATRBuffer_Long[];
int      ATRHandle_Long[];
int      ATR = 14;


int FirstTradingHour_C , LastTradingHour_C;



ENUM_TIMEFRAMES ReturnTF(int index)
{
   switch(index)
  {
      case 0:
         return PERIOD_M1;
         break;
      case 1:
         return PERIOD_M5;
         break;
      case 2:
         return PERIOD_M15;
         break;
      case 3:
         return PERIOD_H1;
         break;
      case 4:
         return PERIOD_H4;
         break;
      case 5:
         return PERIOD_D1;
         break;   
      case 6:
         return PERIOD_W1;
         break;     
  }
  return (-1);
}




bool New_TF_Candle(ENUM_TIMEFRAMES TF)
{
   switch(TF)
  {
      /* old - only check for new day
      case PERIOD_D1:
         if(PreviousDay != dt_struct.day)  return true;
         return false;
         break;
      */
      case PERIOD_D1:
         if(PreviousHour != dt_struct.hour && dt_struct.hour ==2)  return true;        // all daily trades will be open at 02:00 due to spreads
         return false;
         break;
      case PERIOD_H4:
         if(PreviousHour != dt_struct.hour && dt_struct.hour%4 ==0) return true;
         return false;
         break;        
      case PERIOD_H1:
         if(PreviousHour != dt_struct.hour) return true;
         return false;
         break;
      case PERIOD_M15:
         if(dt_struct.min %15 ==0) return true;
         return false;
         break;
      case PERIOD_M5:
         if(dt_struct.min %5 ==0) return true;
         return false;
         break;
      case PERIOD_M1:
         return true;
         break;
      default:
         if(PreviousHour != dt_struct.hour) return true;
         return false;
        break;
  }
}


int ReturnTFIndex(ENUM_TIMEFRAMES index)
{
   switch(index)
  {
      case PERIOD_M1:
         return 0;
         break;
      case PERIOD_M5:
         return 1;
         break;
      case PERIOD_M15:
         return 2;
         break;
      case PERIOD_H1:
         return 3;
         break;
      case PERIOD_H4:
         return 4;
         break;
      case PERIOD_D1:
         return 5;
         break;   
      case PERIOD_W1:
         return 6;
         break;     
  }
  return (-1);
}




bool isNewBar()
{
   CurrentTick = iTime(_Symbol , PERIOD_M1 , 0) ;
   if (CurrentTick != LastTick)
   {
      LastTick = CurrentTick;
      TimeCurrent(dt_struct);  
      return true;
   }
   return false;
}




void CopyPriceBuffers()
{
         
         ENUM_TIMEFRAMES temp;
         for (int i=0 ; i<=6 ; i++)
         {
            temp = ReturnTF(i);
            if(!New_TF_Candle(temp)) continue;
            for(int s=0 ; s<NumberOfTradeableSymbols ; s++)
            {
               if(CopyClose(SymbolArray[s],temp,0,history,Close[i].a[s].b)<0) {PrintErrorMessage (s, "Close" ) ; return;}
               if(CopyOpen(SymbolArray[s],temp,0,history,Open[i].a[s].b)<0) {PrintErrorMessage (s, "Open" ); return;}
               if(CopyHigh(SymbolArray[s],temp,0,history,High[i].a[s].b)<0) {PrintErrorMessage (s, "High" ); return;}
               if(CopyLow(SymbolArray[s],temp,0,history,Low[i].a[s].b)<0) {PrintErrorMessage (s, "Low" ); return;}  
            }     
         } 
}

void LoadHistory()
{
         CopyPriceBuffers();
         if(New_TF_Candle(Main_TF))
         {  
            if(MQLInfoInteger(MQL_TESTER)) BalanceOnNewCandle();
               
            for(int s=0 ; s<NumberOfTradeableSymbols ; s++) 
            {
               if(CopyBuffer(ATRHandle[s],0,0,3,ATRBuffer[s].b)<0) {PrintErrorMessage (s, "ATR_Main" ); return;}
               if(CopyBuffer(ATRHandle_Long[s],0,0,3,ATRBuffer_Long[s].b)<0) {PrintErrorMessage (s, "ATR_Long" ); return;}
               //for MA:
               if (Calc_MA)
               {
                  if(CopyBuffer(FastMAHandle[s],0,0,MALookBackBars+2,FastMABuffer[s].b)<0) {PrintErrorMessage (s, "FastMA" ); return;}
                  if(CopyBuffer(SlowMAHandle[s],0,0,MALookBackBars+2,SlowMABuffer[s].b)<0) {PrintErrorMessage (s, "SlowMA" ); return;}
                  if(CopyBuffer(LongMAHandle[s],0,0,MALookBackBars+2,LongMABuffer[s].b)<0) {PrintErrorMessage (s, "LongMA" ); return;}                  
               }
               //for BB
               if (Calc_BB)
               {
                  if(CopyBuffer(bandHandle[s],1,0,BBChangeLookBackPeriod+2,upperBandBuffer[s].b)<0) {PrintErrorMessage (s, "BB_Upper" ); return;}
                  if(CopyBuffer(bandHandle[s],2,0,BBChangeLookBackPeriod+2,lowerBandBuffer[s].b)<0) {PrintErrorMessage (s, "BB_Lower" ); return;}
                  if(CopyBuffer(bandHandle[s],0,0,BBChangeLookBackPeriod+2,middleBandBuffer[s].b)<0) {PrintErrorMessage (s, "BB_Midle"); return;}
               }  
               if (Calc_RSI)
                  if(CopyBuffer(rsiHandle[s],0,0,RSIDivLookBackPeriod+2,rsiBuffer[s].b)<0) {PrintErrorMessage (s, "RSI" ); return;} 
               if (Calc_MFI)
                   if(CopyBuffer(mfiHandle[s],0,0,MFIDivLookBackPeriod+2,mfiBuffer[s].b)<0) {PrintErrorMessage (s, "MFI" ); return;}
               

               if (Calc_SR) DrawSR(Main_TF_N , s); 
               if (Calc_Trend) DrawTrendLines(Main_TF_N , s); 
               if(Calc_Double) 
               {
                    DrawDoubleUp(Main_TF_N , s);
                    DrawDoubleDown(Main_TF_N , s);              
               }
               if (Calc_MA) CheckMAsAlignment(s);
               if (Calc_GR) GR_R[s] = check_RatioGR(s); 
               if (Calc_ER) ER_R[s] = check_RatioER(s); 
               if (Calc_Kama)         check_KAMA(s);
            }
         }//end of new TF candle
}
   
   

   
void HandleNewBar()
{
          //for tester:
          LoadHistory();
          if(New_TF_Candle(Main_TF))
          {
                if (dt_struct.hour>= FirstTradingHour_C &&  dt_struct.hour <LastTradingHour_C  ) // use _C for Code , so can be modified
                {
                              if (BuyLong) 
                              { 
                                 for(int s = 0 ; s<NumberOfTradeableSymbols; s++)
                                 {  
                                    if (check_is_buy (s) )
                                    {
                                       if(UseOpoositeTradeExit) CloseAllTrades (-1 , s );
                                       if(PositionsTotalForSymbol(s)< MaxOpenTrades)   PlaceBuyOrder(s);                     
                                    }
                                 }
                              }
                              if (SellShort) 
                              {   
                                 for(int s = 0 ; s<NumberOfTradeableSymbols; s++)
                                 {  
                                 if (check_is_sell(s)  )
                                    {
                                       if(UseOpoositeTradeExit) CloseAllTrades (1,s  );
                                       if(PositionsTotalForSymbol(s)< MaxOpenTrades) PlaceSellOrder(s);
                                    }
                                 }
                              }
                   }// end of condition of trading: trading hours
           } // end of condition of trading: new TF candle
 
}// end of new candle


void PrintMessage(int sym  , string mainMSG ,string MSGbody )
{
   Print(mainMSG , " ,magic: " , MagicNumber[sym] , " ,symbol: " , SymbolArray[sym], " ," ,MSGbody);
}



void PrintMessage(string mainMSG)
{
   Print(mainMSG , " for rev magic number: " ,RevMagicNumber );
}


void PrintErrorMessage(int sym  , string errorType )
{
   Print("Error loading " ,  errorType , " price data ,errorcode : " , GetLastError() , " ,magic: " , MagicNumber[sym] , " ,symbol: " , SymbolArray[sym] );
}



/*
void PrintMessageMain(string mainMSG)
{
   Print(mainMSG , " for rev magic number: " ,RevMagicNumber );
}
*/


