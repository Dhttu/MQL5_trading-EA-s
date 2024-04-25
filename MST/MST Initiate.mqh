//+------------------------------------------------------------------+
//|                                                 MST Initiate.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"

ENUM_TIMEFRAMES Main_TF;
ENUM_TIMEFRAMES Secondary_TF;
int Secondary_TF_N;

bool Calc_SR=false , Calc_Trend=false , Calc_Double=false , Calc_MA=false , Calc_GR=false , Calc_ER=false , Calc_Kama=false , Calc_Special=false ;
bool Calc_BB=false , Calc_RSI=false   , Calc_MFI=false ;

 
int history=14; // will be updated later, this number is for ball park number for myself
int Indicatorhistory=4; // will be updated later, this number is for ball park number for myself
int historyBuffer=4; 
int PT = 0; // Poistions Total

void ResizeAllArrays()
{
      for (int k=0 ; k<7 ; k++)
      {
         ArrayResize(Close[k].a , NumberOfTradeableSymbols);
         ArrayResize(Open[k].a , NumberOfTradeableSymbols);
         ArrayResize(High[k].a , NumberOfTradeableSymbols);   
         ArrayResize(Low[k].a , NumberOfTradeableSymbols); 
         for (int j=0 ; j<NumberOfTradeableSymbols ; j++)
         {
              ArrayResize(Close[k].a[j].b , history);
              ArrayResize(Open[k].a[j].b  , history);
              ArrayResize(High[k].a[j].b  , history);   
              ArrayResize(Low[k].a[j].b   , history); 
         }
      }    
   ArrayResize(MagicNumber, NumberOfTradeableSymbols);
   ArrayResize(PipValues, NumberOfTradeableSymbols);
   ArrayResize(ATRBuffer , NumberOfTradeableSymbols);
   ArrayResize(ATRHandle , NumberOfTradeableSymbols);
   ArrayResize(ATRBuffer_Long , NumberOfTradeableSymbols);
   ArrayResize(ATRHandle_Long , NumberOfTradeableSymbols);
   ArrayResize(PrevLowerSRLevel , NumberOfTradeableSymbols);   
   ArrayResize(PrevUpperSRLevel , NumberOfTradeableSymbols);
   ArrayResize(UpperSR , NumberOfTradeableSymbols);   
   ArrayResize(UpperLimit , NumberOfTradeableSymbols);
   ArrayResize(LowerSR , NumberOfTradeableSymbols);
   ArrayResize(LowerLimit , NumberOfTradeableSymbols);
   ArrayResize(UpTrend , NumberOfTradeableSymbols);   
   ArrayResize(DownTrend , NumberOfTradeableSymbols);    
   ArrayResize(PrevUpTrend , NumberOfTradeableSymbols);   
   ArrayResize(PrevDownTrend , NumberOfTradeableSymbols);
   ArrayResize(DoubleUp , NumberOfTradeableSymbols);   
   ArrayResize(DoubleDown , NumberOfTradeableSymbols); 
   ArrayResize(DoubleUpPrice , NumberOfTradeableSymbols);   
   ArrayResize(DoubleDownPrice , NumberOfTradeableSymbols); 
   ArrayResize(MAsAlighn , NumberOfTradeableSymbols);   
   ArrayResize(FastMABuffer , NumberOfTradeableSymbols);
   ArrayResize(SlowMABuffer , NumberOfTradeableSymbols);
   ArrayResize(LongMABuffer , NumberOfTradeableSymbols);
   ArrayResize(FastMAHandle , NumberOfTradeableSymbols);   
   ArrayResize(SlowMAHandle , NumberOfTradeableSymbols); 
   ArrayResize(LongMAHandle , NumberOfTradeableSymbols);
   ArrayResize(rsiBuffer , NumberOfTradeableSymbols);   
   ArrayResize(rsiHandle , NumberOfTradeableSymbols); 
   ArrayResize(mfiBuffer , NumberOfTradeableSymbols);   
   ArrayResize(mfiHandle , NumberOfTradeableSymbols); 
   ArrayResize(upperBandBuffer , NumberOfTradeableSymbols);   
   ArrayResize(middleBandBuffer , NumberOfTradeableSymbols); 
   ArrayResize(lowerBandBuffer , NumberOfTradeableSymbols);
   ArrayResize(bandHandle , NumberOfTradeableSymbols);    
   ArrayResize(GR_R , NumberOfTradeableSymbols);   
   ArrayResize(ER_R , NumberOfTradeableSymbols);   
   ArrayResize(KAMA , NumberOfTradeableSymbols); 
   ArrayResize(PrevKAMA , NumberOfTradeableSymbols); 

   for (int j=0 ; j<NumberOfTradeableSymbols ; j++)
   { 
       ArrayResize(ATRBuffer[j].b , Indicatorhistory); 
       ArrayResize(ATRBuffer_Long[j].b , Indicatorhistory); 
       ArrayResize(FastMABuffer[j].b , Indicatorhistory);
       ArrayResize(SlowMABuffer[j].b , Indicatorhistory); 
       ArrayResize(LongMABuffer[j].b , Indicatorhistory); 
       ArrayResize(rsiBuffer[j].b , Indicatorhistory); 
       ArrayResize(mfiBuffer[j].b , Indicatorhistory); 
       ArrayResize(upperBandBuffer[j].b , Indicatorhistory);
       ArrayResize(middleBandBuffer[j].b , Indicatorhistory);
       ArrayResize(lowerBandBuffer[j].b , Indicatorhistory);   
   }                                             
}

string MainStrategyName()
{
   if (UseRaw)                     return "Raw" ; 
   if (UseSpecial)                 return "Special" ;      
   if (UseSR)                      return "SR" ;
   if (UseBreakOut)                return "BreakOut" ; 
   if (UseFakeOut)                 return "FakeOut" ;      
   if (UseTrend)                   return "Trend" ;  
   if (UseTrendBreakOut)           return "TrendBreakOut"; 
   if (UseDouble)                  return "Double" ;
   if (UseMACross)                 return "MACross" ;  
   if (UseRSIDiv)                  return "RSIDiv" ;     
   if (UseRSIDivHide)              return "RSIDivHide" ;     
   if (UseRSIOver)                 return "RSIOver" ;    
   if (UseRSIWith)                 return "RSIWith" ;  
   if (UseMFIDiv)                  return "MFIDiv" ;     
   if (UseMFIDivHide)              return "MFIDivHide" ; 
   if (UseMFIOver)                 return "MFIOver" ;    
   if (UseMFIWith)                 return "MFIWith" ;      
   if (UseBBWith)                  return "BBWith" ;
   if (UseBBReturn)                return "BBReturn" ; 
   if (UseGRRatio)                 return "GRRatio" ;
   if (UseKAMACross)               return "KAMACross" ;    
   return "error" ;


}



void CalcInitiate()
{
   if (UseSpecial || UseSpecialExit)                                                                                                            Calc_Special=true;
   if(UseSRSL || UseSRTrail || UseSRTP || UseSR || UseBreakOut || UseFakeOut || UseSRExit || UseBreakOutExit || UseFakeOutExit || MaxSRFilter)  Calc_SR=true;                          
   if(UseTrendSL || UseTrendTrail || UseTrend || UseTrendBreakOut || UseTrendExit || UseTrendBreakOutExit)                                      Calc_Trend=true;
   if(UseDouble || UseDoubleExit)                                                                                                               Calc_Double=true;
   if(UseGRRatio || UseGRRatioExit || UseExitGRRatioExit || Max_GR_R<2)                                                                         Calc_GR=true;
   
   if(MAsAlighnFilter || UseMACross || UsePriceCrossMAExit ||  UseMACrossExit || UseMACrossExit || MALongSlopeFilter || MAsAlighnFilter  )      Calc_MA=true;
   if(UseRSIDiv || UseRSIDivHide || UseRSIOver || UseRSIWith  || UseRSIDivExit || UseRSIDivHideExit || UseRSIOverExit || UseRSIWithExit || 
      RSI_OverBought_Allowed ||  RSI_Positive_Not_OverBought_Allowed || RSI_OverSold_Allowed || RSI_Negative_Not_OverSold_Allowed )      Calc_RSI=true;
   if(UseMFIDiv || UseMFIDivHide || UseMFIOver || UseMFIWith  || UseMFIDivExit || UseMFIDivHideExit || UseMFIOverExit || UseMFIWithExit ||
      MFI_OverBought_Allowed  || MFI_Positive_Not_OverBought_Allowed  || MFI_OverSold_Allowed || MFI_Negative_Not_OverSold_Allowed )     Calc_MFI=true;
      
   if(UseBBWith || UseBBReturn || UseBBOver || UseBBWithExit  || UseBBReturnExit || UseBBOverExit || BB_Expending_Against_Exit || BB_Contracting_Exit || 
      BB_Expending_Allowed || BB_Contracting_Allowed  || BB_Expending_Must || BB_Contracting_Must)                                      Calc_BB=true;
   if(UseERLowNoiseAgainstExit || UseERHighNoiseExit || MaxER_EnterLimit <1 || MinER_EnterLimit > 0)                                            Calc_ER=true;
   if(UseKAMACross || UseKAMACrossExit || KAMAConfirmFilter)
   {
           Calc_ER=true;
           Calc_Kama=true ;
   }                                                                                    
}



void HistoryLoadMinimize()
{
   int Temphistory = 0;
   if(Calc_Special)     Temphistory = XbarsSpecial;
   if(Calc_SR)          Temphistory = fmax(Temphistory ,PeriodForSR ); 
   if(Calc_Trend)       Temphistory = fmax(Temphistory ,PeriodForTrend ); 
   if(Calc_Double)      Temphistory = fmax(Temphistory ,PeriodForDouble);
   if(Calc_GR)          Temphistory = fmax(Temphistory ,Ratio_CandlesCount );
   if(UseCandlesSL)     Temphistory = fmax(Temphistory ,SL_CandlesForTrailing );
   if(UseCandlesTrail)  Temphistory = fmax(Temphistory ,Trail_CandlesForTrailing );
   if(UseFastMoveTrail) Temphistory = fmax(Temphistory ,MinutesCountForFastTrailMove );
   history = fmax(Temphistory ,history );
   
   if(Calc_Special)                                                     Indicatorhistory = fmax(Indicatorhistory ,SpecialIndicatorPeriod );
   if(UseRSIDiv || UseRSIDivHide || UseRSIDivExit || UseRSIDivHideExit) Indicatorhistory = fmax(Indicatorhistory ,RSIDivLookBackPeriod );
   if(UseMFIDiv || UseMFIDivHide || UseMFIDivExit || UseMFIDivHideExit) Indicatorhistory = fmax(Indicatorhistory ,MFIDivLookBackPeriod );
   if(Calc_Kama || Calc_ER) Indicatorhistory = Indicatorhistory + ER_CandlesCount  ;
    
   Indicatorhistory = Indicatorhistory + historyBuffer;
   history = fmax(history ,Indicatorhistory ) ; // indicator require Price data
   
   history = history + historyBuffer;
   
   PrintMessage("Indicator history is: " + string(Indicatorhistory));
   PrintMessage("Prices history is: " + string(history));
}



void Initiate()
{
                                
    DrawLines = Draw_Lines;
    //if(MQLInfoInteger(MQL_TESTER)) DrawLines = false;
    LastTick=-1;
    PreviousHour = -1;
    PreviousDay = -1;
    Main_TF = ReturnTF(Main_TF_N);
    if (Main_TF_N==5) // daily candle -> no need for  hours control
    {
      FirstTradingHour_C = -1;
      LastTradingHour_C = 25;
    }
    else // not hour - can use
    {
      FirstTradingHour_C = FirstTradingHour;
      LastTradingHour_C = LastTradingHour;    
    }
    Secondary_TF = ReturnTF(Main_TF_N+Secondary_TF_Deviation);
    if (Secondary_TF_N > 6) ExpertRemove();
    Tester_Initiate();
    if(UseSpecial)                                                         InitiateSpecial(); 
    CalcInitiate();
    if(Calc_Kama)  for(int sym = 0 ; sym<NumberOfTradeableSymbols; sym++)  InitiateKAMA(sym); 
    HistoryLoadMinimize();
    Symbols_Initiate();
    InitiateDiagnostics();   
    
    SR_Initiate();
    //MS_Initiate();
          //For ATR:

   FillConfirmMatrix();
   FillPatternExitMatrix();
   ResetLastError();
   for(int s = 0 ; s<NumberOfTradeableSymbols; s++)
   {  
      MagicNumber[s] = RevMagicNumber + s + 1;
      PipValues[s] = 10*(SymbolInfoDouble(SymbolArray[s], SYMBOL_POINT)) ;
       
      ArraySetAsSeries(ATRBuffer[s].b,true);
      ATRHandle[s]=iATR(SymbolArray[s] , Main_TF , 14);
      ENUM_TIMEFRAMES TempTF = ReturnTF(Main_TF_N + 1);
      ArraySetAsSeries(ATRBuffer_Long[s].b,true);
      ATRHandle_Long[s]=iATR(SymbolArray[s] , TempTF , 50);
      if (Calc_MA) // for MA
      {
         ArraySetAsSeries(FastMABuffer[s].b,true);
         ArraySetAsSeries(SlowMABuffer[s].b,true);
         ArraySetAsSeries(LongMABuffer[s].b,true);   
         if (UseEMA)
         {
             LongMAHandle[s]=iMA(SymbolArray[s],Main_TF,LongMA,0,MODE_EMA,PRICE_CLOSE);
             SlowMAHandle[s]=iMA(SymbolArray[s],Main_TF,SlowMA,0,MODE_EMA,PRICE_CLOSE);
             FastMAHandle[s]=iMA(SymbolArray[s],Main_TF,FastMA,0,MODE_EMA,PRICE_CLOSE);         
         }
         else
         {
             LongMAHandle[s]=iMA(SymbolArray[s],Main_TF,LongMA,0,MODE_SMA,PRICE_CLOSE);
             SlowMAHandle[s]=iMA(SymbolArray[s],Main_TF,SlowMA,0,MODE_SMA,PRICE_CLOSE);
             FastMAHandle[s]=iMA(SymbolArray[s],Main_TF,FastMA,0,MODE_SMA,PRICE_CLOSE);
         }

      }
   
      if (Calc_BB) //for BB: 
      {
         ArraySetAsSeries(upperBandBuffer[s].b,true);
         ArraySetAsSeries(lowerBandBuffer[s].b,true);
         ArraySetAsSeries(middleBandBuffer[s].b,true);
         bandHandle[s]=iBands(SymbolArray[s],Main_TF,BBPeriod,0,BBDeviation,PRICE_CLOSE);
      }
   
       if (Calc_RSI) //for RSI:
       {
         ArraySetAsSeries(rsiBuffer[s].b,true);      
         rsiHandle[s] =   iRSI(SymbolArray[s] , Main_TF , RSIPeriod , PRICE_CLOSE);
      }
      if (Calc_MFI) //for MFI:
      {
         ArraySetAsSeries(mfiBuffer[s].b,true);      
         mfiHandle[s] =   iMFI(SymbolArray[s] , Main_TF , MFIPeriod , VOLUME_TICK);
      }

      for (int k=0 ; k<7 ; k++)
      {
               ArraySetAsSeries(Open[k].a[s].b,true);
               ArraySetAsSeries(Close[k].a[s].b,true);
               ArraySetAsSeries(High[k].a[s].b,true);
               ArraySetAsSeries(Low[k].a[s].b,true);     
      }    
   }  

   if (UseATRTP  || UseSRTP || UseRRTP || UseSpecialTP)                                                                          UseTP    = true;
   if (UseFastMoveTrail || UseMoveToBreakeven || UseATRTrail || UseCandlesTrail || UseSRTrail || UseTrendTrail || UseMATrail)    UseTrail = true;
                    
       CurrentRiskPerTrade = UserRisk;

   string TFTesxt;    
   
   switch(Main_TF)
  {
      case PERIOD_D1:
         TFTesxt = "PERIOD_D1";
         break;
      case PERIOD_H4:
         TFTesxt = "PERIOD_H4";
         break;
      case PERIOD_H1:
         TFTesxt = "PERIOD_H1";
         break;
      case PERIOD_M15:
         TFTesxt = "PERIOD_M15";
         break;
      case PERIOD_M5:
         TFTesxt = "PERIOD_M5";
         break;
      case PERIOD_M1:
         TFTesxt = "PERIOD_M1";
         break;
      default:
         TFTesxt = "Error";
        break;
  }
  
  CopyPriceBuffers();

  string StrText = MainStrategyName();

       
   Comment(
   "\nMagic: " ,   RevMagicNumber ,
   "\nRisk is: " ,   UserRisk ,
   "\nMain TF is: " ,   TFTesxt ,   
   "\nMaxOpenTrades is: " ,   MaxOpenTrades ,
   "\nMain strategy is: " ,   StrText ,
   "\nMartingale is: " ,   Martingale ,
   "\nDouble up martingale: " ,   DoubleUpMartingale ,
   "\nBuy Long: " ,   BuyLong ,
   "\nSell Short: " ,   SellShort , 
   "\nTrade Method: " ,   TradeMethod ,   
   "\nuse TP is: " ,   UseTP , 
   "\nuse Trail is: " ,   UseTrail 
    ) ;
}

void DeInitiate()
{
   for(int s = 0 ; s<NumberOfTradeableSymbols; s++)
   { 
      IndicatorRelease(ATRHandle[s]);
      IndicatorRelease(ATRHandle_Long[s]);
      IndicatorRelease(LongMAHandle[s]);
      IndicatorRelease(SlowMAHandle[s]);
      IndicatorRelease(FastMAHandle[s]);
      
      IndicatorRelease(rsiHandle[s]); 
      IndicatorRelease(mfiHandle[s]); 
      IndicatorRelease(bandHandle[s]);
      if(DrawLines)
      {
       //DeleteAllMarketStrcuture();
          DeleteAllSR(s);
          DeleteAllTrend(s);
          DeleteDoubleUpPoints(s);
          DeleteDoubleDownPoints(s);   
      }
  }
      
   Comment(" ") ;
   ObjectDelete(0,"MAsAlighn");
   ObjectDelete(0,"GR_R");
   FileClose(diganosticFileHandle);
}




void FillConfirmMatrix()
{
   int i=0;
   int j=0;
   ConfirmEnterMatrix[i][j] = Main_ColorPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Main_HHHCPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Main_EnglfPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Main_MarbPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Main_OutPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Main_InPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Main_HamPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Main_InvHamPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Main_FullKangoroPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Main_PartialKangoroPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Main_SameCandleCountPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Main_OpSameCandleCountPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Main_InsideBreakoutPattern; 
   
   i=1;
   j=0;
   ConfirmEnterMatrix[i][j] = Secondary_ColorPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Secondary_HHHCPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Secondary_EnglfPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Secondary_MarbPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Secondary_OutPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Secondary_InPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Secondary_HamPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Secondary_InvHamPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Secondary_FullKangoroPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Secondary_PartialKangoroPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Secondary_SameCandleCountPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Secondary_OpSameCandleCountPattern ;
   j++;
   ConfirmEnterMatrix[i][j] = Secondary_InsideBreakoutPattern; 
}




void FillPatternExitMatrix()
{
   int i=0;
   int j=0;
   PatternExitMatrix[i][j] = Main_ColorPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Main_HHHCPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Main_EnglfPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Main_MarbPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Main_OutPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Main_InPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Main_HamPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Main_InvHamPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Main_FullKangoroPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Main_PartialKangoroPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Main_SameCandleCountExit ;
   j++;
   PatternExitMatrix[i][j] = Main_OpSameCandleCountExit ;
   j++;
   PatternExitMatrix[i][j] = Main_InsideBreakoutExit;
   
   i=1;
   j=0;
   PatternExitMatrix[i][j] = Secondary_ColorPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Secondary_HHHCPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Secondary_EnglfPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Secondary_MarbPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Secondary_OutPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Secondary_InPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Secondary_HamPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Secondary_InvHamPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Secondary_FullKangoroPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Secondary_PartialKangoroPatternExit ;
   j++;
   PatternExitMatrix[i][j] = Secondary_SameCandleCountExit ;
   j++;
   PatternExitMatrix[i][j] = Secondary_OpSameCandleCountExit ;
   j++;
   PatternExitMatrix[i][j] = Secondary_InsideBreakoutExit;

}



