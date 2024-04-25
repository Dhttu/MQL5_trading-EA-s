//+------------------------------------------------------------------+
//|                                     MST Manage Order Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"



   double   Acountprofit; 
   double  CanlesTrailValue, SRTrailValue ,TrendTrailValue, UserTrailValue ;
   double   FinalTrailValue; 
   
   double CurrentPrice, OpenPrice  ; 
   double CompSLPrice ; 

void HandleOpenPositions(int sym) // only called afer a new TF bar
{
  ManageExitTradeDueToXATRsMove(sym);
  if(PositionsTotalForSymbol(sym)==0)    return;  
  ManageExitPatterns(sym);
  if(PositionsTotalForSymbol(sym)==0)    return;

  if (New_TF_Candle(Main_TF))
  {
     if(UseBarsInTrade)     manage_timed_exit(sym);

     if(PositionsTotalForSymbol(sym)==0)    return;
     if(UseOpoositeConfirmExit)       manage_OpConfirm_exit(sym);
     if(PositionsTotalForSymbol(sym)==0)    return;
     ManageExitStrategies_Main(sym);
     if(PositionsTotalForSymbol(sym)==0)    return;
     if (UseExitGRRatioExit) ManageExitGRRatioExit(sym);
     if(PositionsTotalForSymbol(sym)==0)    return;  
     if( UseERHighNoiseExit) ManageERHighNoiseExit(sym);
     if(PositionsTotalForSymbol(sym)==0)    return;   
     if(UsePriceCrossMAExit) ManagePriceCrossMAExit(sym);
     if(PositionsTotalForSymbol(sym)==0)    return;   
     
            
   }//end of TF candle
   if (dt_struct.hour != PreviousHour )
   {
        if(DailyCloseOnlyInProfit) 
          if(dt_struct.hour == DailyCloseAT)
             Manage_Daily_Exit(sym) ;
             
        if(dt_struct.hour == CloseAllAT) 
        {
                  CloseAllTrades(1,sym);
                  CloseAllTrades(-1,sym);
                  return;
        }
   }  //end of new hour     
}    

    

void ManageExitTradeDueToXATRsMove(int sym)
{
  double MinutesMax = High[0].a[sym].b[iHighest(SymbolArray[sym] , PERIOD_M1 , MODE_HIGH , MinutesCountForATRsMove , 1)];
  double MinutesMin =  Low[0].a[sym].b[iLowest (SymbolArray[sym] , PERIOD_M1 , MODE_LOW ,  MinutesCountForATRsMove , 1)];
  
  double UpMove = (Open[0].a[sym].b[0] - MinutesMin) ;
  double DownMove = (MinutesMax - Open[0].a[sym].b[0]) ;
  
  double UpMoveATRs =   UpMove    / ATRBuffer[sym].b[1];
  double DownMoveATRs = DownMove  / ATRBuffer[sym].b[1];  

  if(UpMoveATRs   > ExitTradeOnXATRsMove)         CloseAllTrades(1,sym);
  if(UpMoveATRs   > ExitTradeOnXATRsOpositeMove)  CloseAllTrades(-1,sym);
  if(DownMoveATRs > ExitTradeOnXATRsMove)         CloseAllTrades(-1,sym);
  if(DownMoveATRs > ExitTradeOnXATRsOpositeMove)  CloseAllTrades(1,sym);
}


void manage_SL(int sym) //check if SL needs to be updated, if yes: call on function update SL
{
   //if(CopyBuffer(ATRHandle[sym],0,0,ATR+2,ATRBuffer[sym].b)<0) {PrintFormat("Error loading ATR data, code %d",GetLastError()); return ;}
   PT = PositionsTotalForSymbol(sym);
   while(PT>=0)    //manage buy orders:
   {
         if(posInfo.SelectByIndex(PT))
            if(PositionGetInteger(POSITION_MAGIC)==MagicNumber[sym]) 
            {
               CurrentPrice = PositionGetDouble(POSITION_PRICE_CURRENT);
               OpenPrice = PositionGetDouble(POSITION_PRICE_OPEN) ;
               SLPrice = PositionGetDouble(POSITION_SL) ; 
               if(posInfo.PositionType()==POSITION_TYPE_BUY)
               {
                  
                   CompSLPrice = SLPrice +  PipValues[sym];
                   if(UseFastMoveTrail)
                   {
                        double MinutesMin =  Low[0].a[sym].b[iLowest (SymbolArray[sym] , PERIOD_M1 , MODE_LOW ,  1+MinutesCountForFastTrailMove , 1)];
                        double UpMove = CurrentPrice - MinutesMin ;
                      if(UpMove >  FastMoveTrail_ATR_StarMultiplier * ATRBuffer[sym].b[1] )
                      {
                          FinalTrailValue = CurrentPrice - FastMoveTrail_ATR_TrailMultiplier*ATRBuffer[sym].b[1];
                          if(FinalTrailValue > CompSLPrice  && CurrentPrice > FinalTrailValue) 
                          {  
                                 Update_SL(); 
                                 return;
                          }
                      }
                   }               
                   if(UseATRTrail)
                   {
                      if(CurrentPrice > OpenPrice +ATRTrail_StartMultiplier*ATRBuffer[sym].b[1] )
                      {
                          FinalTrailValue = CurrentPrice -ATRTrail_TrailMultiplier*ATRBuffer[sym].b[1];
                          if(FinalTrailValue > CompSLPrice && CurrentPrice > FinalTrailValue)  
                          { 
                                 Update_SL(); 
                                 return;
                          }
                      }
                   }
                   if(UseMoveToBreakeven) 
                   {
                     FinalTrailValue = OpenPrice + PipValues[sym] ;
                     if(FinalTrailValue > CompSLPrice)
                          if(CurrentPrice > OpenPrice + BE_ATRs*ATRBuffer[sym].b[1] && CurrentPrice > FinalTrailValue)
                          {                         
                                 Update_SL(); 
                                 return;
                          }
                   }
                   if(New_TF_Candle(Main_TF))   
                   {    
                      if(UseCandlesTrail)
                      {
                        int MinLow = iLowest(SymbolArray[sym] , Main_TF , MODE_LOW , Trail_CandlesForTrailing , 0);
                        FinalTrailValue = Open[Main_TF_N].a[sym].b[MinLow] - Trail_Candles_ATR_Slack*ATRBuffer[sym].b[1];
                        if(FinalTrailValue > CompSLPrice && CurrentPrice > FinalTrailValue)
                        {                         
                                 Update_SL(); 
                                 return;
                        }                
                      }

                     if(UseSRTrail)
                     {
                        FinalTrailValue = CurrentPrice + Calculate_SR_Long_SL(Main_TF_N , CurrentPrice,sym);
                        if(FinalTrailValue > CompSLPrice && CurrentPrice > FinalTrailValue)    
                        {                         
                                 Update_SL(); 
                                 return;
                        }       
                     }
                     
                     if(UseTrendTrail)
                     {
                        FinalTrailValue = CurrentPrice + Calculate_Trend_Long_SL(Main_TF_N , CurrentPrice,sym);
                        if(FinalTrailValue > CompSLPrice && CurrentPrice > FinalTrailValue)
                        {                         
                                 Update_SL(); 
                                 return;
                        }    
                     }     
                     if(UseMATrail)
                     {
                        FinalTrailValue = LongMABuffer[sym].b[1];
                        if(FinalTrailValue > CompSLPrice && CurrentPrice > FinalTrailValue)
                        {                         
                                 Update_SL(); 
                                 return;
                        }              
                     }     
                   } // end of new TF candle
               }  // end of Buy       
               else // sell position
               {
                   CompSLPrice = SLPrice -  PipValues[sym];
                   if(UseFastMoveTrail)
                   {
                        double MinutesMax =  High[0].a[sym].b[iHighest (SymbolArray[sym] , PERIOD_M1 , MODE_HIGH ,  1+MinutesCountForFastTrailMove , 1)];
                        double DownMove = MinutesMax - CurrentPrice ;
                      if(DownMove >  FastMoveTrail_ATR_StarMultiplier * ATRBuffer[sym].b[1] )
                      {
                          FinalTrailValue = CurrentPrice + FastMoveTrail_ATR_TrailMultiplier*ATRBuffer[sym].b[1];
                          if(FinalTrailValue < CompSLPrice && CurrentPrice < FinalTrailValue )   
                          {              
                                 Update_SL(); 
                                 return;
                          }  
                      }
                   }    
                   if(UseATRTrail)
                   {
                      FinalTrailValue = CurrentPrice +ATRTrail_TrailMultiplier*ATRBuffer[sym].b[1];
                      if(CurrentPrice < OpenPrice -ATRTrail_StartMultiplier*ATRBuffer[sym].b[1] )
                          if(FinalTrailValue < CompSLPrice && CurrentPrice < FinalTrailValue) 
                          {                         
                                 Update_SL(); 
                                 return;
                          }  
                   }
                   if(UseMoveToBreakeven) 
                   {
                      FinalTrailValue = OpenPrice - PipValues[sym] ;
                      if( FinalTrailValue < CompSLPrice)
                          if(CurrentPrice < OpenPrice - BE_ATRs*ATRBuffer[sym].b[1] && CurrentPrice < FinalTrailValue)
                          {                         
                                 Update_SL(); 
                                 return;
                          }  
                   }

                   if(New_TF_Candle(Main_TF))      
                   { 
                      if(UseCandlesTrail)
                      {
                        int MaxHigh = iHighest(SymbolArray[sym] , Main_TF , MODE_HIGH , Trail_CandlesForTrailing , 0);
                        FinalTrailValue = Open[Main_TF_N].a[sym].b[MaxHigh] + Trail_Candles_ATR_Slack*ATRBuffer[sym].b[1];
                        if(FinalTrailValue < CompSLPrice && CurrentPrice < FinalTrailValue)
                        {                         
                                 Update_SL(); 
                                 return;
                        }                 
                      }
                     if(UseSRTrail)
                     {
                        FinalTrailValue = CurrentPrice - Calculate_SR_Short_SL(Main_TF_N , CurrentPrice,sym);
                        if(FinalTrailValue < CompSLPrice && CurrentPrice < FinalTrailValue)
                        {                         
                                 Update_SL(); 
                                 return;
                        }     
                     }
                     
                     if(UseTrendTrail)
                     {
                        FinalTrailValue = CurrentPrice -Calculate_Trend_Short_SL(Main_TF_N , CurrentPrice,sym);
                        if(FinalTrailValue < CompSLPrice && CurrentPrice < FinalTrailValue)
                        {                         
                                 Update_SL(); 
                                 return;
                        }     
                     } 
                     if(UseMATrail)
                     {
                        FinalTrailValue = LongMABuffer[sym].b[1];
                        if(FinalTrailValue < CompSLPrice && CurrentPrice < FinalTrailValue)
                        {                         
                                 Update_SL(); 
                                 return;
                        }            
                     }         
                  } // end of new TF candle
             } // end of sell
          } // end of current Postioin
          PT = PT-1;
   } // end of while
   return ;
}




   
void Manage_Daily_Exit(int sym)
{
         PT = PositionsTotalForSymbol(sym);
         while(PT>=0)  
         {
            if(posInfo.SelectByIndex(PT))
            {   
               if(PositionGetInteger(POSITION_MAGIC)==MagicNumber[sym]) 
               {
                  if (iBarShift(SymbolArray[sym] , PERIOD_D1 , PositionGetInteger(POSITION_TIME) , false) >=  DaysInTradeForPorfitClose) // count days in trade
                  {
                     if (PositionGetDouble(POSITION_PROFIT)>0)      
                     {            
                              trade.PositionClose(PositionGetTicket(PT));
                     }
                   }
                 }
            }
            PT--;
         }
}


void manage_timed_exit(int sym)
{
         PT = PositionsTotalForSymbol(sym);
         while(PT>=0)  
         {
            if(posInfo.SelectByIndex(PT))
               if(PositionGetInteger(POSITION_MAGIC)==MagicNumber[sym]) 
                     if (iBarShift(SymbolArray[sym] , Main_TF , PositionGetInteger(POSITION_TIME) , false) >=  BarsInTrade)                 
                              trade.PositionClose(PositionGetTicket(PT));
            PT--;
         }
}



void Update_SL() // update SL
{                             
      trade.PositionModify(posInfo.Ticket() ,FinalTrailValue , PositionGetDouble(POSITION_TP));    
}  


void CloseAllTrades (int Direc,int sym)
{
     if (Direc == 1) //close buy trades
     {
         PrintMessage(sym, "close opposite trades" , "close all buy trades");
         for(int k=PositionsTotalForSymbol(sym);k>=0;k--)
           {   
           if(posInfo.SelectByIndex(k))
              if(PositionGetInteger(POSITION_MAGIC)==MagicNumber[sym]) 
                  if ( posInfo.PositionType()==POSITION_TYPE_BUY ) 
                       trade.PositionClose(PositionGetTicket(k));
           }
     }
     else //close sell trades
     {
         PrintMessage(sym, "close opposite trades" , "close all sell trades");
         for(int k=PositionsTotalForSymbol(sym);k>=0;k--)
           {
                if(posInfo.SelectByIndex(k))
                    if(PositionGetInteger(POSITION_MAGIC)==MagicNumber[sym]) 
                           if ( posInfo.PositionType()==POSITION_TYPE_SELL ) 
                                  trade.PositionClose(PositionGetTicket(k));
           }
     }     
}

void manage_OpConfirm_exit(int sym)
{
         PT = PositionsTotalForSymbol(sym);
         while(PT>=0)  
         {
            if(posInfo.SelectByIndex(PT))
               if(PositionGetInteger(POSITION_MAGIC)==MagicNumber[sym]) 
               {
                     if ( posInfo.PositionType()==POSITION_TYPE_BUY ) 
                        if(ConfirmIsSell(sym))
                           trade.PositionClose(PositionGetTicket(PT));
                            
                     if ( posInfo.PositionType()==POSITION_TYPE_SELL ) 
                        if(ConfirmIsBuy(sym))
                           trade.PositionClose(PositionGetTicket(PT));
               }
            PT--;
         }
}

void ManageExitPatterns(int sym)
{
         PT = PositionsTotalForSymbol(sym);
         while(PT>=0)  
         {
            if(posInfo.SelectByIndex(PT)) 
               if(PositionGetInteger(POSITION_MAGIC)==MagicNumber[sym]) 
               {
                     if ( posInfo.PositionType()==POSITION_TYPE_BUY ) 
                        if(CheckExitPatternForBuy(sym))
                           trade.PositionClose(PositionGetTicket(PT));
                            
                     if ( posInfo.PositionType()==POSITION_TYPE_SELL ) 
                        if(CheckExitPatternForSell(sym))
                           trade.PositionClose(PositionGetTicket(PT));
               }
            PT--;
         }
}



bool CheckExitPatternForBuy(int sym)
{

   int j=0;
   int Tempi = Main_TF_N;
   for (int i=0 ; i<2 ; i++)
   {

      if(i==1) Tempi = Secondary_TF_N;
      j=0;
      if (PatternExitMatrix[i][j] >0)
         if (CheckCandlePattern(Tempi , PatternExitMatrix[i][j] , sym))
            return true;
      j++;
      if (PatternExitMatrix[i][j] ==1)
         if (HHHCLLL_C(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!HHHCLLL_C(1, Tempi , sym))
            return true;  
      j++;
      if (PatternExitMatrix[i][j] ==1)
         if (Engulf(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!Engulf(1, Tempi , sym))
            return true;  
      j++;      
      if (PatternExitMatrix[i][j] ==1)
         if (Is_Marbouzo(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!Is_Marbouzo(1, Tempi , sym))
            return true;  
      j++;
      if (PatternExitMatrix[i][j] ==1)
         if (Out(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!Out(1, Tempi , sym))
            return true;  
      j++;
      if (PatternExitMatrix[i][j] ==1)
         if (InBar(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!InBar(1, Tempi , sym))
            return true;  
      j++;
      if (PatternExitMatrix[i][j] ==1)
         if (Ham(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!Ham(1, Tempi , sym))
            return true;  
      j++; 
      if (PatternExitMatrix[i][j] ==1)
         if (InvHam(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!InvHam(1, Tempi , sym))
            return true;  
      j++;    
      if (PatternExitMatrix[i][j] ==1)
         if (KangoroTail(Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!KangoroTail(Tempi , sym))
            return true;  
      j++; 
      if (PatternExitMatrix[i][j] ==1)
         if (ShortPartialKangoro(Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!ShortPartialKangoro(Tempi , sym))
            return true;  
      j++;    
      if (PatternExitMatrix[i][j] >0)
         if (CountGreenCandles(1 , Tempi , sym) >= PatternExitMatrix[i][j] )
            return true;
      j++; 
      if (PatternExitMatrix[i][j] >0)
         if (CountRedCandles(1 , Tempi , sym) < PatternExitMatrix[i][j] )
            return true;
      j++;    
      if (PatternExitMatrix[i][j] ==1)
         if (!InsideBreakout_check_is_sell(Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (InsideBreakout_check_is_sell(Tempi , sym))
            return true;                                
   }
   return false;
}


bool CheckExitPatternForSell( int sym)
{
   int j=0;
   int Tempi = Main_TF_N;
   for (int i=0 ; i<2 ; i++)
   {

      if(i==1) Tempi = Secondary_TF_N;
      j=0;
      if (PatternExitMatrix[i][j] >0)
         if (CheckCandlePattern(Tempi , PatternExitMatrix[i][j] , sym))
            return true;
      j++;
      if (PatternExitMatrix[i][j] ==1)
         if (HHHCLLL_C(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!HHHCLLL_C(1, Tempi , sym))
            return true;  
      j++;
      if (PatternExitMatrix[i][j] ==1)
         if (Engulf(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!Engulf(1, Tempi , sym))
            return true;  
      j++;      
      if (PatternExitMatrix[i][j] ==1)
         if (Is_Marbouzo(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!Is_Marbouzo(1, Tempi , sym))
            return true;  
      j++;
      if (PatternExitMatrix[i][j] ==1)
         if (Out(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!Out(1, Tempi , sym))
            return true;  
      j++;
      if (PatternExitMatrix[i][j] ==1)
         if (InBar(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!InBar(1, Tempi , sym))
            return true;  
      j++;
      if (PatternExitMatrix[i][j] ==1)
         if (Ham(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!Ham(1, Tempi , sym))
            return true;  
      j++; 
      if (PatternExitMatrix[i][j] ==1)
         if (InvHam(1, Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!InvHam(1, Tempi , sym))
            return true;  
      j++;    
      if (PatternExitMatrix[i][j] ==1)
         if (KangoroTail(Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!KangoroTail(Tempi , sym))
            return true;  
      j++; 
      if (PatternExitMatrix[i][j] ==1)
         if (ShortPartialKangoro(Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (!ShortPartialKangoro(Tempi , sym))
            return true;  
      j++;    
      if (PatternExitMatrix[i][j] >0)
         if (CountRedCandles(1 , Tempi , sym) >= PatternExitMatrix[i][j] )
            return true;
      j++; 
      if (PatternExitMatrix[i][j] >0)
         if (CountGreenCandles(1 , Tempi , sym) >= PatternExitMatrix[i][j] )
            return true;
      j++;    
      if (PatternExitMatrix[i][j] ==1)
         if (!InsideBreakout_check_is_sell(Tempi , sym))
            return true;
      if (PatternExitMatrix[i][j] ==2)
         if (InsideBreakout_check_is_sell(Tempi , sym))
            return true;                                
   }
   return false;
}



void ManageExitStrategies_Main( int sym)
{
         PT = PositionsTotalForSymbol(sym);
         while(PT>=0)  
         {
            if(posInfo.SelectByIndex(PT))
               if(PositionGetInteger(POSITION_MAGIC)==MagicNumber[sym]) 
                     if (WaitXBarsBeforeExit <= iBarShift(SymbolArray[sym] , Main_TF ,PositionGetInteger(POSITION_TIME) , false))       
                     {         
                 //             if( UseMarketStructureTrendExit)               ManageMarketStructureTrendExit(PT ,  sym); 
                  //            if( UseMarketStructureSidewaysExit)            ManageMarketStructureSidewaysExit(PT ,  sym);
                              if( UseSpecialExit)       ManageSpecialExit(PT ,  sym); 
                              if( UseSRExit)            ManageSRExit(PT ,  sym); 
                              if( UseBreakOutExit)      ManageBreakoutExit(PT ,  sym); 
                              if( UseFakeOutExit)       ManageFakeoutExit(PT ,  sym); 
                              if( UseTrendExit)         ManageTrendExit(PT ,  sym);
                              if( UseTrendBreakOutExit) ManageTrendBreakOutExit(PT ,  sym);  
                              if( UseDoubleExit)        ManageDoubleExit(PT ,  sym); 
                              if( UseMACrossExit)       ManageMAExit(PT ,  sym);
                              if( UseRSIDivExit)        ManageRSIDivExit(PT ,  sym);
                              if( UseRSIDivHideExit)    ManageRSIDivHideExit(PT ,  sym);
                              if( UseRSIOverExit)       ManageRSIOverExit(PT ,  sym);
                              if( UseRSIWithExit)       ManageRSIWithExit(PT ,  sym);
                              if( UseMFIDivExit)        ManageMFIDivExit(PT ,  sym);
                              if( UseMFIDivHideExit)    ManageMFIDivHideExit(PT ,  sym);
                              if( UseMFIOverExit)       ManageMFIOverExit(PT ,  sym);
                              if( UseMFIWithExit)       ManageMFIWithExit(PT ,  sym);
                              if( UseBBWithExit)        ManageBBWithExit(PT ,  sym); 
                              if( UseBBReturnExit)      ManageBBReturnExit(PT ,  sym);
                              if( BB_Expending_Against_Exit)      ManageBB_Expending_Against_Exit(PT ,  sym);
                              if( BB_Contracting_Exit)            ManageBB_Contracting_Exit(PT ,  sym);
                              if( UseGRRatioExit)                 ManageGRRatioExit(PT ,  sym);
                              if( UseERLowNoiseAgainstExit)       ManageERLowNoiseAgainstExit(PT ,  sym); 
                              if( UseKAMACrossExit)     ManageKAMAExit(PT ,  sym);
                     }
            
            PT--;
        }
}


