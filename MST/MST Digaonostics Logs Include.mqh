//+------------------------------------------------------------------+
//|                                MST Digaonostics Logs Include.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"

int diganosticFileHandle = INVALID_HANDLE;
string diganosticFileName;


int CalculateTotalOpenTradesForEA()
{
   int Counter=0;
   int Looper = PositionsTotal();
   while(Looper>0 &&  Counter < 10)   
   { 
         if(posInfo.SelectByIndex(Looper-1))
         {
            for(int s = 0 ; s<NumberOfTradeableSymbols; s++)
            {
               if(PositionGetInteger(POSITION_MAGIC)==MagicNumber[s]) 
               {
                             Counter ++; 
                             break; // found the trade so no need to continue looping   
               }
            }
        }
      Looper --;
   }
   return (Counter);
}

void InitiateDiagnostics()
{
  StringConcatenate(diganosticFileName , IntegerToString(RevMagicNumber) , "_Performance_deal_log.txt");
  diganosticFileHandle = FileOpen(diganosticFileName, FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT, "\t");
  FileWrite(diganosticFileHandle, "Date", "Time", "Balance", "Equity", "P/L",
                                 "Margin", "Free_Margin", "Margin_Level_%", "Number_of_Open_orders");  
  if(!MQLInfoInteger(MQL_TESTER))   FileClose(diganosticFileHandle); // if testing keep file open                                 
}
  
void WriteBalancePerformanceFile()
{
   if(!MQLInfoInteger(MQL_TESTER)) FileOpen(diganosticFileName, FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT, "\t");
   string str_now = TimeToString (TimeCurrent(), TIME_MINUTES);
   string Hour = StringSubstr(str_now,0 , 2);
   FileSeek(diganosticFileHandle,0,SEEK_END);
   FileWrite(diganosticFileHandle,TimeToString (TimeCurrent(), TIME_DATE) , Hour, DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE)),
               DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY)), DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT)),       
                                  DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN)), DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE)),
                                    DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)), IntegerToString(CalculateTotalOpenTradesForEA())); 
    if(!MQLInfoInteger(MQL_TESTER)) FileClose(diganosticFileHandle)  ;             
    
                       
  //FileWrite(diganosticFileHandle, "Date", "Time", "Balance", "Equity", "P/L", 
  //                                  "Margin", "Free_Margin", "Margin_Level_%", "Number_of_Open_orders");     
                                 
}

void WriteEAlogFile(string fileName, string message)
{
   int logFileHandle = FileOpen(fileName, FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT, "\t"); 
   FileSeek(logFileHandle,0,SEEK_END);
   FileWrite(logFileHandle,message)  ; 
   FileClose(logFileHandle)  ; 

}

//   *******     excel version   *******
/*
void InitiateDiagnostics()
{
  StringConcatenate(diganosticFileName , "Performance_DIAGNOSTIC_INFO\\" ,  IntegerToString(RevMagicNumber) , "_Performance_deal_log.csv");
  diganosticFileHandle = FileOpen(diganosticFileName, FILE_WRITE|FILE_CSV, "\t");
  FileWrite(diganosticFileHandle, "Date", "Time", "Balance", "Equity", "P/L",
                                 "Margin", "Free_Margin", "Margin_Level_%", "Number_of_Open_orders");  
  if(!MQLInfoInteger(MQL_TESTER))   FileClose(diganosticFileHandle); // if testing keep file open                                 
}
  
void WriteBalancePerformanceFile()
{
   string str_now = TimeToString (TimeCurrent(), TIME_MINUTES);
   string Hour = StringSubstr(str_now,0 , 2);
   
  FileWrite(diganosticFileHandle,TimeToString (TimeCurrent(), TIME_DATE) , Hour, DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE)),
               DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY)), DoubleToString(AccountInfoDouble(ACCOUNT_PROFIT)),       
                                  DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN)), DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_FREE)),
                                    DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)), IntegerToString(CalculateTotalOpenTradesForEA())); 
                                      
  //FileWrite(diganosticFileHandle, "Date", "Time", "Balance", "Equity", "P/L", 
  //                                  "Margin", "Free_Margin", "Margin_Level_%", "Number_of_Open_orders");     
                                 
}
*/