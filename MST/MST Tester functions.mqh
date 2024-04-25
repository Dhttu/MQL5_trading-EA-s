//+------------------------------------------------------------------+
//|                                         MST Tester functions.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"



input group "Tester parameters"; 

input double MinYearlyTradesPerSymbol=4;
double MinTotalYearlyTrades;
double PreferedYearlyTradesTotal;
int SybolSQRT;
int MaxBarsTillProfit;
input double STDFilter=3;

int      PreviousHourlyTasksRun  = -1;          //Set to -1 so that hourly tasks run immediately
double   EquityHistoryArray[];                  //Used to store equity at intermittent time intervals when using the Strategy Tester in order to calculate CAGR/MeanDD perf metric
datetime BackTestFirstDate;                     //Used in the CAGR/MeanDD Calc
datetime BackTestFinalDate;                     //Used in the CAGR/MeanDD Calc

double BackTestDuration;

int BarsForFirstTrade;

input int MaxDurationMultiplier = 30;

double CAGRoverAvgDD = 0;
double CustomPerformanceMetric =0;

input bool WriteTesterDiagnosticsFile = true;
int currentArraySize;
int MinTradesForTest = 12;
int MinNormTradesForTest = 10;

void Tester_Initiate()
{
         MinTotalYearlyTrades = MinYearlyTradesPerSymbol * NumberOfTradeableSymbols;
         if (Main_TF_N == 5 ) MinTotalYearlyTrades = MinTotalYearlyTrades / 2 ; // daily candles -> trade at least once in 6 months
         if (Main_TF_N == 6 ) MinTotalYearlyTrades = MinTotalYearlyTrades / 4 ; // weekly candles -> trade at least once in a year
         PreferedYearlyTradesTotal = MinTotalYearlyTrades * 2; 
         SybolSQRT = int(ceil(sqrt(NumberOfTradeableSymbols)));
         currentArraySize=1;
         BackTestFirstDate = TimeCurrent();
         ArrayResize(EquityHistoryArray, 1);    
         EquityHistoryArray[0] = AccountInfoDouble(ACCOUNT_EQUITY); 
         
         switch(Main_TF)
        {
            case PERIOD_D1:
               BarsForFirstTrade = 60;
               break;
            case PERIOD_H4:
               BarsForFirstTrade = 250;
               break;
            case PERIOD_H1:
               BarsForFirstTrade = 1000;
               break;
            case PERIOD_M15:
               BarsForFirstTrade = 2500;
               break;
            case PERIOD_M5:
               BarsForFirstTrade = 10000;
               break;
            case PERIOD_M1:
               BarsForFirstTrade = 25000;
               break;
            default:
               BarsForFirstTrade = 3;
              break;
        }
        BarsForFirstTrade = int(ceil(BarsForFirstTrade / SybolSQRT));
        MaxBarsTillProfit = MaxDurationMultiplier * BarsForFirstTrade ; // Time is MaxDurationMultiplier times the min for first trade
} 
      

void BalanceOnNewCandle()
{
            currentArraySize++;
            ArrayResize(EquityHistoryArray, currentArraySize);  
            EquityHistoryArray[currentArraySize-1] = AccountInfoDouble(ACCOUNT_EQUITY);
            if (currentArraySize>BarsForFirstTrade)
            {
               HistorySelect(0,TimeCurrent());
               int TotalTrades=HistoryDealsTotal();
               if(TotalTrades ==0) ExpertRemove();
               double CurrentDD = 1-EquityHistoryArray[currentArraySize-1] / EquityHistoryArray[0] ;
               if(CurrentDD > 0.25) ExpertRemove(); // DD exceeded 25%
               if (currentArraySize > MaxBarsTillProfit)  
                  if(CurrentDD >0) // no profit after long time -> probabley not relevent iteration
                     ExpertRemove();
            }
}



double Calacule_tester()
{
    double Profit = TesterStatistics(STAT_PROFIT);

    BackTestFinalDate = TimeCurrent();
    BackTestDuration = double(BackTestFinalDate - BackTestFirstDate);        //This is the back test duration in seconds, but cast to double to avoid problems below...
    BackTestDuration = ((((BackTestDuration / 60.0) / 60.0) / 24.0) / 365.0);       //... so convert to years
    
    double Score=0;
    int numNormTrades = ModifiedProfitFactor();
    int numTrades = CagrOverMeanDD();
    if(Profit <=0) return 0;   
    if(numTrades <MinTradesForTest)     return 0;
    if(numNormTrades <MinNormTradesForTest) return 0;          

    Print("CAGRoverAvgDD is: " , CAGRoverAvgDD);
    Print("Modified Profit facotr is: " , CustomPerformanceMetric);     

   if(BackTestDuration == 0) return 0;
      if(numNormTrades / BackTestDuration < PreferedYearlyTradesTotal) CustomPerformanceMetric = CustomPerformanceMetric * ((PreferedYearlyTradesTotal-(numTrades / BackTestDuration))/PreferedYearlyTradesTotal); // Punish less trades
      else  CustomPerformanceMetric = MathPow( 1+ CustomPerformanceMetric ,2); // increase the ratio for higher trades so get's higher value      
      
    Score = CAGRoverAvgDD * CustomPerformanceMetric;
    Score = Score * log10(numNormTrades); // add more leverage for more trades
    
    Score = log10(1+Score)+1;

    return Score;
}



int CagrOverMeanDD()
{
      HistorySelect(0, TimeCurrent());   
      int numTrades = 0;

      //##########################
      //ASCERTAIN NUMBER OF TRADES (USED TO ELIMINATE PARAMETER VALUES WITH STATISTICAL SIGNIFCANCE ISSUES)
      //##########################
      
      for(int dealID = 0; dealID < HistoryDealsTotal(); dealID++) 
      { 
         ulong dealTicket = HistoryDealGetTicket(dealID); 
         
         if(HistoryDealGetInteger(dealTicket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
            numTrades++;                       
      } 
      
      //###################################
      //CAGR OVER MEAN DRAWDOWN CALCULATION
      //###################################
      
      int numEquityValues = ArraySize(EquityHistoryArray);
      
      double startingEquity   = EquityHistoryArray[0];
      double finalEquity      = EquityHistoryArray[numEquityValues-1];  
      double currentEquity    = EquityHistoryArray[0];   //Gets overwritten as loop below progresses
      double maxEquity        = EquityHistoryArray[0];   //Gets overwritten as loop below progresses
      double sumDDValues      = 0.0;
      int    numDDValues      = 0;
      
      //Loop through equity array in time order
      for(int arrayLoop = 1; arrayLoop < numEquityValues; arrayLoop++)
      {
         currentEquity = EquityHistoryArray[arrayLoop];
         
         if(currentEquity > maxEquity)
            maxEquity = currentEquity;
         
         sumDDValues += ((maxEquity - currentEquity) / maxEquity) * 100.0;
         numDDValues++;
      }
      
      finalEquity = currentEquity;
      
      //On rare occasions, MetaTrader allows the final equity to pass below zero and become negative before the test ceases. When this happens it causes major issues with the CAGR calculation. So we set to zero manually when this is the case.
      if(finalEquity < 0.0)   finalEquity = 0.0;
      if(numTrades / BackTestDuration < MinTotalYearlyTrades) return 0; // no statatistical signicinse
      double cagr = (MathPow((finalEquity / startingEquity), (1 / BackTestDuration)) - 1) * 100.0;
      double meanDD = 0.0;
      
      if(numDDValues == 0)  return 0;
      meanDD = sumDDValues / numDDValues;
      //Remember CAGRoverAvgDD passed in by ref
      CAGRoverAvgDD = 0.0;
      if(meanDD == 0.0) return 0;
         CAGRoverAvgDD = cagr / meanDD;
      return numTrades;
}  
   
   

int ModifiedProfitFactor()
{

   HistorySelect(0, TimeCurrent());   
   int numDeals = HistoryDealsTotal();  
   double sumProfit = 0.0;
   double sumLosses = 0.0;
   int numTrades = 0;
   
 
   //OUTPUT DIAGNOSTIC DEAL DATA
   int outputFileHandle = INVALID_HANDLE;
   if(WriteTesterDiagnosticsFile)
   {
      string outputFileName = "DEAL_DIAGNOSTIC_INFO\\deal_log.csv";
      outputFileHandle = FileOpen(outputFileName, FILE_WRITE|FILE_CSV, "\t");
      //FileWrite(outputFileHandle, "LIST OF DEALS IN BACKTEST");   
      FileWrite(outputFileHandle, "TICKET", "DEAL_ORDER", "DEAL_POSITION_ID", "DEAL_SYMBOL", "DEAL_TYPE", 
                                    "DEAL_ENTRY", "DEAL_REASON", "DEAL_TIME", "DEAL_VOLUME", "DEAL_PRICE", 
                                    "DEAL_COMMISSION", "DEAL_SWAP", "DEAL_PROFIT", "DEAL_MAGIC", "DEAL_COMMENT");
   }

   
   //LOOP THROUGH DEALS IN DATETIME ORDER 
   int positionCount = 0;
   double positionNetProfit[];
   double positionVolume[];
   
   for(int dealID = 0; dealID < numDeals; dealID++) 
   { 
      //GET THIS DEAL'S TICKET NUMBER 
      ulong dealTicket = HistoryDealGetTicket(dealID); 
      
      if(HistoryDealGetInteger(dealTicket, DEAL_ENTRY) == DEAL_ENTRY_OUT)
      {
         positionCount++;
         ArrayResize(positionNetProfit, positionCount);
         ArrayResize(positionVolume, positionCount);
         
         positionNetProfit[positionCount - 1] = HistoryDealGetDouble(dealTicket, DEAL_PROFIT) + HistoryDealGetDouble(dealTicket, DEAL_SWAP);
                                               // ( HistoryDealGetDouble(dealTicket, DEAL_COMMISSION)) - not paying comissions on MQL5 demo
         
         positionVolume[positionCount - 1] = HistoryDealGetDouble(dealTicket, DEAL_VOLUME);
      }
      
      //######################
      //OUTPUT DEAL PROPERTIES
      //###################### 
      
      if(WriteTesterDiagnosticsFile)
      {
         FileWrite(outputFileHandle, IntegerToString(dealTicket), 
                                     IntegerToString(HistoryDealGetInteger(dealTicket, DEAL_ORDER)),
                                     IntegerToString(HistoryDealGetInteger(dealTicket, DEAL_POSITION_ID)),
                                     HistoryDealGetString(dealTicket, DEAL_SYMBOL),
                                     EnumToString((ENUM_DEAL_TYPE)HistoryDealGetInteger(dealTicket, DEAL_TYPE)),
                                     EnumToString((ENUM_DEAL_ENTRY)HistoryDealGetInteger(dealTicket, DEAL_ENTRY)),
                                     EnumToString((ENUM_DEAL_REASON)HistoryDealGetInteger(dealTicket, DEAL_REASON)),
                                     TimeToString((datetime)HistoryDealGetInteger(dealTicket, DEAL_TIME), TIME_DATE|TIME_SECONDS),
                                     DoubleToString(HistoryDealGetDouble(dealTicket, DEAL_VOLUME), 2),
                                     DoubleToString(HistoryDealGetDouble(dealTicket, DEAL_PRICE), 5),
                                     DoubleToString(HistoryDealGetDouble(dealTicket, DEAL_COMMISSION), 2),
                                     DoubleToString(HistoryDealGetDouble(dealTicket, DEAL_SWAP), 2),
                                     DoubleToString(HistoryDealGetDouble(dealTicket, DEAL_PROFIT), 2),
                                     IntegerToString(HistoryDealGetInteger(dealTicket, DEAL_MAGIC)),
                                     HistoryDealGetString(dealTicket, DEAL_COMMENT)
                                     );
      }
                                     
   } 
   
   //###################################
   //1. CALCULATE STANDARD PROFIT FACTOR
   //###################################
   
   double sumOfProfit = 0;
   double sumOfLosses = 0;
   
   for(int positionNum = 1; positionNum <= positionCount; positionNum++)
   {
      if(positionNetProfit[positionNum - 1] > 0)
         sumOfProfit += positionNetProfit[positionNum - 1];
      else
         sumOfLosses += positionNetProfit[positionNum - 1];
   }
   
   double standardProfitFactor = NULL;
   
   if(sumOfLosses != 0)
      standardProfitFactor = MathAbs(sumOfProfit / sumOfLosses);
   
   //WRITE OUT INTERMEDITE DIAGNOSTIC DATA
    if(WriteTesterDiagnosticsFile)  FileWrite(outputFileHandle, "\nPROFIT FACTOR (STANDARD CALCULATION)", standardProfitFactor);
   
   //###################################
   //2. CALCULATE RELATIVE PROFIT FACTOR (INTERMEDIATE STEP)
   //################################### 
   
   sumOfProfit = 0;
   sumOfLosses = 0;   
   
   for(int positionNum = 1; positionNum <= positionCount; positionNum++)
   {
      positionNetProfit[positionNum - 1] /= positionVolume[positionNum - 1];
      
      if(positionNetProfit[positionNum - 1] > 0)
         sumOfProfit += positionNetProfit[positionNum - 1];
      else
         sumOfLosses += positionNetProfit[positionNum - 1];
   }                          
   
   double relativeProfitFactor = NULL;
   
   if(sumOfLosses != 0)
      relativeProfitFactor = MathAbs(sumOfProfit / sumOfLosses);
      
   //WRITE OUT INTERMEDITE DIAGNOSTIC DATA
     if(WriteTesterDiagnosticsFile) FileWrite(outputFileHandle, "\nPROFIT FACTOR (MODIFIED CALCULATION)", relativeProfitFactor);
   
   //#########################
   //3. EXCLUDE EXTREME TRADES
   //#########################
   
   double MeanRelNetProfit = MathMean(positionNetProfit);
   double StdDevRelNetProfit = MathStandardDeviation(positionNetProfit);
   
   double stdDevExcludeMultiple = STDFilter; //Exclude trades that have values in excess of STDFilter  from the mean
   int numExcludedTrades = 0;
   sumOfProfit = 0;
   sumOfLosses = 0;
   
   for(int positionNum = 1; positionNum <= positionCount; positionNum++)
   {
      if(positionNetProfit[positionNum - 1] < MeanRelNetProfit-(stdDevExcludeMultiple*StdDevRelNetProfit)  ||  
         positionNetProfit[positionNum - 1] > MeanRelNetProfit+(stdDevExcludeMultiple*StdDevRelNetProfit))
      {
         numExcludedTrades++;
      }
      else
      {
         if(positionNetProfit[positionNum - 1] > 0)
            sumOfProfit += positionNetProfit[positionNum - 1];
         else
            sumOfLosses += positionNetProfit[positionNum - 1];
      }
   }
   
   CustomPerformanceMetric = NULL;
   
   if(sumOfLosses != 0)
      CustomPerformanceMetric = MathAbs(sumOfProfit / sumOfLosses);
   
   //WRITE OUT FINAL DIAGNOSTIC DATA
   if(WriteTesterDiagnosticsFile)
   {
      FileWrite(outputFileHandle, "\nEXCLUDING EXTREME (NEWS AFFECTED) TRADES:");
      FileWrite(outputFileHandle, "TOTAL TRADES BEFORE EXCLUSIONS", positionCount);
      FileWrite(outputFileHandle, "MEAN RELATIVE NET PROFIT", MeanRelNetProfit);
      FileWrite(outputFileHandle, "STD DEV RELATIVE NET PROFIT", StdDevRelNetProfit);
      FileWrite(outputFileHandle, "NUM TRADES EXCLUDED (> " + DoubleToString(stdDevExcludeMultiple, 1) + " SD)", numExcludedTrades, DoubleToString(((double)numExcludedTrades/positionCount)*100.0) + "%");
      FileWrite(outputFileHandle, "MODIFIED PROFIT FACTOR", CustomPerformanceMetric);
      
      FileClose(outputFileHandle);
   }
      Print("TOTAL TRADES BEFORE EXCLUSIONS ", positionCount);
      Print("MEAN RELATIVE NET PROFIT ", MeanRelNetProfit);
      Print( "STD DEV RELATIVE NET PROFIT ", StdDevRelNetProfit);
      Print( "NUM TRADES EXCLUDED  " , numExcludedTrades);
      Print( "% TRADES EXCLUDED  " , (double)numExcludedTrades/positionCount*100.0);
      Print( "MODIFIED PROFIT FACTOR ", CustomPerformanceMetric);
   return positionCount;
}


