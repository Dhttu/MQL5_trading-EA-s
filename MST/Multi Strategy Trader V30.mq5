//+------------------------------------------------------------------+
//|                                    Multi Strategy Trader 320.mq5 |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"
#property version   "3.00"


#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\TerminalInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Expert\Money\MoneyFixedMargin.mqh>
#include <Expert\Money\MoneyFixedRisk.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\DealInfo.mqh>
#include <Math\Stat\Normal.mqh>





string rev = "MST V.30";


input const ulong RevMagicNumber = 930900000; 
ulong MagicNumber[]; 
double PipValues[];

// 930zxxxyy 
/*
if special entry -  xxx930zyy
930 - rev 3.0
z - time frame // 0 - M1, 1 - M5, 2 - M15, 3-H1, 4-H4, 5-D1, 6-W1
xxx - strategy number (indexed from 01 - 999)
yy - symbol number - changes per strategy (not constant per symbol) - ** no need to change **
*/

input bool LogDiagnotics = true;

input bool Draw_Lines = false;
bool DrawLines = false;


input group "Trding parameters"; 
input double UserRisk=0.1;
input int Main_TF_N = 5;
// 0 - M1, 1 - M5, 2 - M15, 3-H1, 4-H4, 5-D1, 6-W1
input int Secondary_TF_Deviation = 1;
input int MaxOpenTrades = 1;
input double Martingale = 1;
input double DoubleUpMartingale = 1;
input int FirstTradingHour = 2;
input int LastTradingHour = 22;
input bool UseFixedOS = true;
input bool BuyLong = true; 
input bool SellShort = true; 

input int TradeMethod = 1; 
// 1=market , 2 limit order , 3 stop order , 4 limit stop order
input int PendingOrdersExpirationBars = 10; 
input double PendingOrdersATRSlack = 1; 
input double StopLimitOrdersATRSlack = 1; 

double CurrentRiskPerTrade ;

input group "Stop Loss parameters"; 
input double Default_SL_ATR=10;
input bool UseCandlesSL = false;
input int SL_CandlesForTrailing=30;
input double SL_Candles_ATR_Slack = 0.1;
//Trend SL
input bool UseSRSL = false;
input double SL_SR_ATR_Slack = 0.1;
input bool UseTrendSL = false;
input double SL_Trend_ATR_Slack = 0.1;
input bool UseFixedSL = false;
input double SL_FixedSL = 100;



input group "Trail parameters"; 
input bool UseFastMoveTrail = false;
input int MinutesCountForFastTrailMove=0; 
input double FastMoveTrail_ATR_StarMultiplier=1;
input double FastMoveTrail_ATR_TrailMultiplier=1;   

input bool UseMoveToBreakeven = false;
input double BE_ATRs = 0.5;
input bool UseATRTrail = false;
input double ATRTrail_StartMultiplier=4.5; 
input double ATRTrail_TrailMultiplier=5.5;  
input bool UseCandlesTrail = false;
input double Trail_Candles_ATR_Slack = 0.1;
input int Trail_CandlesForTrailing=1;

// range trail:
input bool UseSRTrail = false;
input bool UseTrendTrail = false;




input group "Take Profit parameters"; 
// ********* USe TP needs to be calculated if one of the other TP is true
input bool UseATRTP = false;
input double ATRTP_ratio = 2;
input bool UseSRTP = false;
input double ATR_SR_TP_Slack=0.1; 
input bool UseRRTP = false;
input double RR_TP_Ratio=2; 



input group "Enter strategies Main Candle"; 
input bool UseRaw = false; 
input bool UseSpecial = false; 
//input bool UseMarketStructureTrend = false; 
//input bool UseMarketStructureSideways = false; 
input bool UseSR = false; 
input bool UseBreakOut = false; 
input bool UseFakeOut = false; 
input bool UseTrend = false; 
input bool UseTrendBreakOut = false; 
input bool UseDouble = false; 
input bool UseMACross = false;
input bool UseRSIDiv = false;
input bool UseRSIDivHide = false;
input bool UseRSIOver = false;
input bool UseRSIWith = false;
input bool UseMFIDiv = false;
input bool UseMFIDivHide = false;
input bool UseMFIOver = false;
input bool UseMFIWith = false;
input bool UseBBWith = false; 
input bool UseBBReturn = false;
input bool UseBBOver = false;
input bool UseGRRatio = false;
input bool UseKAMACross = false;


input group "Exit parameters"; 
input bool UseOpoositeTradeExit = true;
input bool UseOpoositeConfirmExit = false;
input bool DailyCloseOnlyInProfit = false;
input int DailyCloseAT = 22;
input int CloseAllAT = 25;

input bool UseBarsInTrade = false;
input int BarsInTrade = 5000;

input int ExitTradeOnXATRsMove = 20;
input int ExitTradeOnXATRsOpositeMove = 20;
input int MinutesCountForATRsMove = 1;
// positive number is with the trade direction , negative is against
input bool UseExitGRRatioExit = false;
input bool UseERHighNoiseExit = false;




input group "Exit strategies Main Candle"; 
input int WaitXBarsBeforeExit = 1;
//input bool UseMarketStructureTrendExit = false; 
//input bool UseMarketStructureSidewaysExit = false; 
input bool UseSpecialExit = false; 
input bool UseSRExit = false; 
input bool UseBreakOutExit = false; 
input bool UseFakeOutExit = false; 
input bool UseTrendExit = false; 
input bool UseTrendBreakOutExit = false; 
input bool UseDoubleExit = false; 
input bool UseMACrossExit = false;
input bool UseRSIDivExit = false;
input bool UseRSIDivHideExit = false;
input bool UseRSIOverExit = false;
input bool UseRSIWithExit = false;
input bool UseMFIDivExit = false;
input bool UseMFIDivHideExit = false;
input bool UseMFIOverExit = false;
input bool UseMFIWithExit = false;
input bool UseBBWithExit = false; 
input bool UseBBReturnExit = false;
input bool UseBBOverExit = false;
input bool BB_Expending_Against_Exit = false;
input bool BB_Contracting_Exit = false;
input bool UseGRRatioExit = false;
input bool UseERLowNoiseAgainstExit = false;
input bool UseKAMACrossExit = false;

input group "Confirm entery" ; 
//Legend:
//Color Pattern 0 - N/A . 1-G , 2-GGG , 3- GGR , 4-GRG , 5-GRR , 6-RGG , 7-RGR , 8-RRG , 9-RRR , 10-R (this is for buy , sell is opposite)
//Candle pattern: 0 - N/A , 1 - Yes , 2 - No
//Same candle count: 0 - N/A , positive x number - must for entery , negative x number - acts as filter 
//opSame candle count: 0 - N/A , positive x number - must for entery , negative x number - acts as filter 
int ConfirmEnterMatrix [2][13];

input int Main_ColorPattern = 0;
input int Main_HHHCPattern = 0;
input int Main_EnglfPattern = 0;
input int Main_MarbPattern = 0;
input int Main_OutPattern = 0;
input int Main_InPattern = 0;
input int Main_HamPattern = 0;
input int Main_InvHamPattern = 0;
input int Main_FullKangoroPattern = 0;
input int Main_PartialKangoroPattern = 0;
input int Main_FakeoutPattern = 0;
input int Main_SameCandleCountPattern = 0;
input int Main_OpSameCandleCountPattern = 0;
input int Main_InsideBreakoutPattern = 0;

input int Secondary_ColorPattern = 0;
input int Secondary_HHHCPattern = 0;
input int Secondary_EnglfPattern = 0;
input int Secondary_MarbPattern = 0;
input int Secondary_OutPattern = 0;
input int Secondary_InPattern = 0;
input int Secondary_HamPattern = 0;
input int Secondary_InvHamPattern = 0;
input int Secondary_FullKangoroPattern = 0;
input int Secondary_PartialKangoroPattern = 0;
input int Secondary_FakeoutPattern = 0;
input int Secondary_SameCandleCountPattern = 0;
input int Secondary_OpSameCandleCountPattern = 0;
input int Secondary_InsideBreakoutPattern = 0;


input group "Exit Patterns Candles"; 
//Legend:
//Color Pattern 0 - N/A . 1-G , 2-GGG , 3- GGR , 4-GRG , 5-GRR , 6-RGG , 7-RGR , 8-RRG , 9-RRR , 10-R (this is for buy , sell is opposite)
//Candle pattern: 0 - N/A , 1 - Yes , 2 - No
//Same candle count: 0 - N/A ,   positive x number -  exit trade candles with    the direction of trade
//opSame candle count: 0 - N/A , positive x number -  exit trade candles against the direction of trade
int PatternExitMatrix [2][13];

input int Main_ColorPatternExit = 0;
input int Main_HHHCPatternExit = 0;
input int Main_EnglfPatternExit = 0;
input int Main_MarbPatternExit = 0;
input int Main_OutPatternExit = 0;
input int Main_InPatternExit = 0;
input int Main_HamPatternExit = 0;
input int Main_InvHamPatternExit = 0;
input int Main_FullKangoroPatternExit = 0;
input int Main_PartialKangoroPatternExit = 0;
input int Main_FakeoutPatternExit = 0;
input int Main_SameCandleCountExit = 0;
input int Main_OpSameCandleCountExit = 0;
input int Main_InsideBreakoutExit = 0;

input int Secondary_ColorPatternExit = 0;
input int Secondary_HHHCPatternExit = 0;
input int Secondary_EnglfPatternExit = 0;
input int Secondary_MarbPatternExit = 0;
input int Secondary_OutPatternExit = 0;
input int Secondary_InPatternExit = 0;
input int Secondary_HamPatternExit = 0;
input int Secondary_InvHamPatternExit = 0;
input int Secondary_FullKangoroPatternExit = 0;
input int Secondary_PartialKangoroPatternExit = 0;
input int Secondary_FakeoutPatternExit = 0;
input int Secondary_SameCandleCountExit = 0;
input int Secondary_OpSameCandleCountExit = 0;
input int Secondary_InsideBreakoutExit = 0;


input group "Trade filters"; 

input double MaxMainPrevCandleSizeInATR = 10;
input double MinMainPrevCandleSizeInATR = 0.001;

input bool Mon = true;
input bool Tue = true;
input bool Wed = true;
input bool Thur = true;
input bool Fri = true;

input bool BarsWithTrendFilter = false; 
input bool BarsAgainstTrendFilter = false; 
input int BarsTrendXBars = 30;

input double Max_MaintoLong_ATR = 10;
input double Min_MaintoLong_ATR = 0.00001;

input double Max_GR_R = 2;

input double MaxER_EnterLimit = 1;
input double MinER_EnterLimit = 0;

input bool MaxSRFilter = false;
input int ATR_SlackForSRFilter = 2;


input bool MALongSlopeFilter = false;
// mak sure MA slope is with the direction
input bool MAsAlighnFilter = false;
input int  MAsAlighnFilterValue = 0;
// 1 is with the direction, -1 is against --> 1 will be for buy ==1 , for sell ==-1
input int  LongMAConfirmFilter = 0;
// 1 is with the direction(above for buy, below for sell) , -1 is against , 0 no impact *****

input bool RSI_OverBought_Allowed = true;
input bool RSI_Positive_Not_OverBought_Allowed = true;
input bool RSI_OverSold_Allowed = true;
input bool RSI_Negative_Not_OverSold_Allowed = true;

input bool MFI_OverBought_Allowed = true;
input bool MFI_Positive_Not_OverBought_Allowed = true;
input bool MFI_OverSold_Allowed = true;
input bool MFI_Negative_Not_OverSold_Allowed = true;

input bool BB_Expending_Allowed = true;
input bool BB_Contracting_Allowed = true;
input bool BB_Expending_Must = false;
input bool BB_Contracting_Must = false;

input bool  KAMAConfirmFilter = false;


#include <MST30 include files\MST Base Functions Include.mqh>
#include <MST30 include files\MST Tester functions.mqh>
#include <MST30 include files\MST Symbols.mqh>
#include <MST30 include files\MST Initiate.mqh>
#include <MST30 include files\MST Open Orders Include.mqh>
#include <MST30 include files\MST Manage Order Include.mqh>
#include <MST30 include files\MST Candle Patterns Include.mqh>
#include <MST30 include files\MST Range Include.mqh>
#include <MST30 include files\MST Trend Strategies Include.mqh>
#include <MST30 include files\MST Double Include.mqh>
#include <MST30 include files\MST MA Include.mqh>
#include <MST30 include files\MST RSI Include.mqh>
#include <MST30 include files\MST MFI Include.mqh>
#include <MST30 include files\MST BB Include.mqh>
#include <MST30 include files\MST GR Include.mqh>
#include <MST30 include files\MST Noise Strategies Include.mqh>
#include <MST30 include files\MST Digaonostics Logs Include.mqh>
#include <MST30 include files\MST Special Include.mqh>

/*******************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*******************************************************************************************************************************
//+------------------------------------------------------------------+
//|                                                                  |
//| Main Body                                                         |
//|                                                                  |
//+------------------------------------------------------------------+
*********************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*********************************************************************************************************************************
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
*********************************************************************************************************************************/

int OnInit() 
  { 
      Initiate();
      HandleNewBar();
      PrintMessage("Init succedded");
      return(INIT_SUCCEEDED);
  }


void OnDeinit(const int reason)  {   DeInitiate() ;  }

bool NewDay = false;

void OnTick()
{
    if(isNewBar())           
    {
       HandleNewBar();
       for(int s = 0 ; s<NumberOfTradeableSymbols; s++)
       {
          if(PositionsTotalForSymbol(s)>0)    HandleOpenPositions(s); 
       }
       if (UseTrail)   // double duu to update of hour - support runtime optimization
            for(int s = 0 ; s<NumberOfTradeableSymbols; s++)
               if(PositionsTotalForSymbol(s)>0)
                  manage_SL(s);         

        if (PreviousHour != dt_struct.hour)
        {
            if(LogDiagnotics) WriteBalancePerformanceFile();
            PreviousHour = dt_struct.hour;
            PreviousDay   = dt_struct.day;
        }
    }
    if (UseTrail)  
      for(int s = 0 ; s<NumberOfTradeableSymbols; s++)
         if(PositionsTotalForSymbol(s)>0)
            manage_SL(s);         

    
}
 


double OnTester()
{
   return (Calacule_tester());
}





