//+------------------------------------------------------------------+
//|                                                  MST Symbols.mqh |
//|                                                     Roman Geyzer |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Roman Geyzer"
#property link      "https://www.mql5.com"



input group "Symbols"; 
input	int	TradeOnly1Symbol	 = 0; // 0 -> no change, 1-49 for optimization
input	bool	TradeForexi	 = true;
input	bool	AUDCADi	 = true; // AUDCAD - 1
input	bool	AUDCHFi	 = true; // AUDCHF - 2
input	bool	AUDJPYi	 = true; // AUDJPY - 3
input	bool	AUDNZDi	 = true; // AUDNZD - 4
input	bool	AUDUSDi	 = true; // AUDUSD - 5
input	bool	CADCHFi	 = true; // CADCHF - 6
input	bool	CADJPYi	 = true; // CADJPY - 7
input	bool	CHFJPYi	 = true; // CHFJPY - 8
input	bool	EURAUDi	 = true; // EURAUD - 9
input	bool	EURCADi	 = true; // EURCAD - 10
input	bool	EURCHFi	 = true; // EURCHF - 11
input	bool	EURGBPi	 = true; // EURGBP - 12
input	bool	EURJPYi	 = true; // EURJPY - 13
input	bool	EURNZDi	 = true; // EURNZD - 14
input	bool	EURUSDi	 = true; // EURUSD - 15
input	bool	GBPAUDi	 = true; // GBPAUD - 16
input	bool	GBPCADi	 = true; // GBPCAD - 17
input	bool	GBPCHFi	 = true; // GBPCHF - 18
input	bool	GBPJPYi	 = true; // GBPJPY - 19
input	bool	GBPNZDi	 = true; // GBPNZD - 20
input	bool	GBPUSDi	 = true; // GBPUSD - 21
input	bool	NZDCADi	 = true; // NZDCAD - 22
input	bool	NZDCHFi	 = true; // NZDCHF - 23
input	bool	NZDJPYi	 = true; // NZDJPY - 24
input	bool	NZDUSDi	 = true; // NZDUSD - 25
input	bool	USDCADi	 = true; // USDCAD - 26
input	bool	USDCHFi	 = true; // USDCHF - 27
input	bool	USDJPYi	 = true; // USDJPY - 28

input	bool	TradeIndexi	 = false;
input	bool	   SP500i	   = true;  // SP500 - 29
input	string	SP500_Si	 = "SP500m";
input	bool	   Dow30i	   = false; // Dow30 - 30
input	string	Dow30_Si	 = "DJI";
input	bool	   EURO50i	= false; // EURO50 - 31
input	string	EURO50_Si	 = "STOX50";
input	bool	   UK100i	= true; // UK100 - 32
input	string	UK100_Si	 = "UK100";
input	bool	   DAXi	= false; // DAX - 33
input	string	DAX_Si	 = "GDAXIm";
input	bool	   Nikkei225i	= false; // Nikkei225 - 34
input	string	Nikkei225_Si	 = "NI225";
input	bool	   AUS200i	= false; // AUS200 - 35
input	string	AUS200_Si	 = "AUS200";
input	bool	   CACi	= false; // CAC - 36
input	string	CAC_Si	 = "FCHI40";

input	bool	TradeMetalsi	 = false;
input	bool	   GOLDi	    = true; // GOLD - 37
input	string	GOLD_Si	 = "XAUUSD";
input	bool	   SILVERi	    = true; // SILVER - 38
input	string	SILVER_Si	 = "XAGUSD";
input	bool	   PLATINUMi	    = true; // PLATINUM - 39
input	string	PLATINUM_Si	 = "XPTUSD";
input	bool	   PALLADUIUMi	    = false; // PALLADUIUM - 40
input	string	PALLADUIUM_Si	 = "XPDUSD";

input	bool	TradeCommoditiesi	 = false;
input	bool	   OILi	    = false; // OIL - 41
input	string	OIL_Si	 = "XTIUSD";
input	bool	   COFFEEi	    = false; // COFFEE - 42
input	string	COFFEE_Si	 = "Coffee_Z0";
input	bool	   CORNi	    = false; // CORN - 43
input	string	CORN_Si	 = "Corn_U0";
input	bool	   CUTTONi	    = false; // CUTTON - 44
input	string	CUTTON_Si	 = "Cutton_Z0";
input	bool	   COCOAi	    = false; // COCOA - 45
input	string	COCOA_Si	 = "Cocoa_Z0";
input	bool	   OrangeJuicei	    = false; // OrangeJuice - 46
input	string	OrangeJuice_Si	 = "OJ_U0";
input	bool	   WHEATi	    = false; // WHEAT - 47
input	string	WHEAT_Si	 = "Wheat_Z0";
input	bool	   SOYBEANi	    = false; // SOYBEAN - 48
input	string	SOYBEAN_Si	 = "Soybean_U0";
input	bool	   SUGARi	    = false; // SUGAR - 49
input	string	SUGAR_Si	 = "Sugar_V0";


//changble variable
bool	TradeForex	;
bool	AUDCAD	;
bool	AUDCHF	;
bool	AUDJPY	;
bool	AUDNZD	;
bool	AUDUSD	;
bool	CADCHF	;
bool	CADJPY	;
bool	CHFJPY	;
bool	EURAUD	;
bool	EURCAD	;
bool	EURCHF	;
bool	EURGBP	;
bool	EURJPY	;
bool	EURNZD	;
bool	EURUSD	;
bool	GBPAUD	;
bool	GBPCAD	;
bool	GBPCHF	;
bool	GBPJPY	;
bool	GBPNZD	;
bool	GBPUSD	;
bool	NZDCAD	;
bool	NZDCHF	;
bool	NZDJPY	;
bool	NZDUSD	;
bool	USDCAD	;
bool	USDCHF	;
bool	USDJPY	;
		
bool	TradeIndex	;
bool	   SP500	;
string	SP500_S	;
bool	   Dow30	;
string	Dow30_S	;
bool	   EURO50	;
string	EURO50_S	;
bool	   UK100	;
string	UK100_S	;
bool	   DAX	;
string	DAX_S	;
bool	   Nikkei225	;
string	Nikkei225_S	;
bool	   AUS200	;
string	AUS200_S	;
bool	   CAC	;
string	CAC_S	;
		
bool	TradeMetals	;
bool	   GOLD	;
string	GOLD_S	;
bool	   SILVER	;
string	SILVER_S	;
bool	   PLATINUM	;
string	PLATINUM_S	;
bool	   PALLADUIUM	;
string	PALLADUIUM_S	;
		
bool	TradeCommodities	;
bool	   OIL	;
string	OIL_S	;
bool	   COFFEE	;
string	COFFEE_S	;
bool	   CORN	;
string	CORN_S	;
bool	   CUTTON	;
string	CUTTON_S	;
bool	   COCOA	;
string	COCOA_S	;
bool	   OrangeJuice	;
string	OrangeJuice_S	;
bool	   WHEAT	;
string	WHEAT_S	;
bool	   SOYBEAN	;
string	SOYBEAN_S	;
bool	   SUGAR	;
string	SUGAR_S	;


int PreviousHour , PreviousDay;
datetime CurrentTick=0 , LastTick=0;
 
 



int NumberOfTradeableSymbols = 1;
string   SymbolArray[];          
string TradeSymbolsToUse = "";

void CopyInputsSymbols()
{
      TradeForex	=	TradeForexi	;
      AUDCAD	=	AUDCADi	;
      AUDCHF	=	AUDCHFi	;
      AUDJPY	=	AUDJPYi	;
      AUDNZD	=	AUDNZDi	;
      AUDUSD	=	AUDUSDi	;
      CADCHF	=	CADCHFi	;
      CADJPY	=	CADJPYi	;
      CHFJPY	=	CHFJPYi	;
      EURAUD	=	EURAUDi	;
      EURCAD	=	EURCADi	;
      EURCHF	=	EURCHFi	;
      EURGBP	=	EURGBPi	;
      EURJPY	=	EURJPYi	;
      EURNZD	=	EURNZDi	;
      EURUSD	=	EURUSDi	;
      GBPAUD	=	GBPAUDi	;
      GBPCAD	=	GBPCADi	;
      GBPCHF	=	GBPCHFi	;
      GBPJPY	=	GBPJPYi	;
      GBPNZD	=	GBPNZDi	;
      GBPUSD	=	GBPUSDi	;
      NZDCAD	=	NZDCADi	;
      NZDCHF	=	NZDCHFi	;
      NZDJPY	=	NZDJPYi	;
      NZDUSD	=	NZDUSDi	;
      USDCAD	=	USDCADi	;
      USDCHF	=	USDCHFi	;
      USDJPY	=	USDJPYi	;
      			
      TradeIndex	=	TradeIndexi	;
         SP500	=	   SP500i	;
      SP500_S	=	SP500_Si	;
         Dow30	=	   Dow30i	;
      Dow30_S	=	Dow30_Si	;
         EURO50	=	   EURO50i	;
      EURO50_S	=	EURO50_Si	;
         UK100	=	   UK100i	;
      UK100_S	=	UK100_Si	;
         DAX	=	   DAXi	;
      DAX_S	=	DAX_Si	;
         Nikkei225	=	   Nikkei225i	;
      Nikkei225_S	=	Nikkei225_Si	;
         AUS200	=	   AUS200i	;
      AUS200_S	=	AUS200_Si	;
         CAC	=	   CACi	;
      CAC_S	=	CAC_Si	;
      			
      TradeMetals	=	TradeMetalsi	;
         GOLD	=	   GOLDi	;
      GOLD_S	=	GOLD_Si	;
         SILVER	=	   SILVERi	;
      SILVER_S	=	SILVER_Si	;
         PLATINUM	=	   PLATINUMi	;
      PLATINUM_S	=	PLATINUM_Si	;
         PALLADUIUM	=	   PALLADUIUMi	;
      PALLADUIUM_S	=	PALLADUIUM_Si	;
      			
      TradeCommodities	=	TradeCommoditiesi	;
         OIL	=	   OILi	;
      OIL_S	=	OIL_Si	;
         COFFEE	=	   COFFEEi	;
      COFFEE_S	=	COFFEE_Si	;
         CORN	=	   CORNi	;
      CORN_S	=	CORN_Si	;
         CUTTON	=	   CUTTONi	;
      CUTTON_S	=	CUTTON_Si	;
         COCOA	=	   COCOAi	;
      COCOA_S	=	COCOA_Si	;
         OrangeJuice	=	   OrangeJuicei	;
      OrangeJuice_S	=	OrangeJuice_Si	;
         WHEAT	=	   WHEATi	;
      WHEAT_S	=	WHEAT_Si	;
         SOYBEAN	=	   SOYBEANi	;
      SOYBEAN_S	=	SOYBEAN_Si	;
         SUGAR	=	   SUGARi	;
      SUGAR_S	=	SUGAR_Si	;
}



void CurrenciesInitiate()
{
      if (!TradeForex)
      {
             	AUDCAD	 = false;
             	AUDCHF	 = false;
             	AUDJPY	 = false;
             	AUDNZD	 = false;
             	AUDUSD	 = false;
             	CADCHF	 = false;
             	CADJPY	 = false;
             	CHFJPY	 = false;
             	EURAUD	 = false;
             	EURCAD	 = false;
             	EURCHF	 = false;
             	EURGBP	 = false;
             	EURJPY	 = false;
             	EURNZD	 = false;
             	EURUSD	 = false;
             	GBPAUD	 = false;
             	GBPCAD	 = false;
             	GBPCHF	 = false;
             	GBPJPY	 = false;
             	GBPNZD	 = false;
             	GBPUSD	 = false;
             	NZDCAD	 = false;
             	NZDCHF	 = false;
             	NZDJPY	 = false;
             	NZDUSD	 = false;
             	USDCAD	 = false;
             	USDCHF	 = false;
             	USDJPY	 = false;
      }
}

void IndicesInitiate()
{
      if (!TradeIndex)
      {
         	   SP500	      = false;
         	   Dow30	      = false;
         	   EURO50	   = false;
         	   UK100     	= false;
         	   DAX	      = false;
         	   Nikkei225	= false;
         	   AUS200	   = false;
         	   CAC	      = false;
      }
}

void MetalsInitiate()
{
      if (!TradeMetals)
      {
         GOLD	     = false;
         SILVER	  = false;
         PLATINUM	  = false;
         PALLADUIUM = false;
      }
}

void CommoditiesInitiate()
{
      if (!TradeCommodities)
      {
         OIL	    = false;
         COFFEE	    = false;
         CORN	    = false;
         CUTTON	    = false;
         COCOA	    = false;
         OrangeJuice	    = false;
         WHEAT	    = false;
         SOYBEAN	    = false;
         SUGAR	    = false;
      }
}


void PopulateSymbolsString()
{
   TradeSymbolsToUse = "";
   string TempArr[];
   if(	AUDCAD	)	StringAdd (TradeSymbolsToUse , 	"AUDCAD,"	);
   if(	AUDCHF	)	StringAdd (TradeSymbolsToUse , 	"AUDCHF,"	);
   if(	AUDJPY	)	StringAdd (TradeSymbolsToUse , 	"AUDJPY,"	);
   if(	AUDNZD	)	StringAdd (TradeSymbolsToUse , 	"AUDNZD,"	);
   if(	AUDUSD	)	StringAdd (TradeSymbolsToUse , 	"AUDUSD,"	);
   if(	CADCHF	)	StringAdd (TradeSymbolsToUse , 	"CADCHF,"	);
   if(	CADJPY	)	StringAdd (TradeSymbolsToUse , 	"CADJPY,"	);
   if(	CHFJPY	)	StringAdd (TradeSymbolsToUse , 	"CHFJPY,"	);
   if(	EURAUD	)	StringAdd (TradeSymbolsToUse , 	"EURAUD,"	);
   if(	EURCAD	)	StringAdd (TradeSymbolsToUse , 	"EURCAD,"	);
   if(	EURCHF	)	StringAdd (TradeSymbolsToUse , 	"EURCHF,"	);
   if(	EURGBP	)	StringAdd (TradeSymbolsToUse , 	"EURGBP,"	);
   if(	EURJPY	)	StringAdd (TradeSymbolsToUse , 	"EURJPY,"	);
   if(	EURNZD	)	StringAdd (TradeSymbolsToUse , 	"EURNZD,"	);
   if(	EURUSD	)	StringAdd (TradeSymbolsToUse , 	"EURUSD,"	);
   if(	GBPAUD	)	StringAdd (TradeSymbolsToUse , 	"GBPAUD,"	);
   if(	GBPCAD	)	StringAdd (TradeSymbolsToUse , 	"GBPCAD,"	);
   if(	GBPCHF	)	StringAdd (TradeSymbolsToUse , 	"GBPCHF,"	);
   if(	GBPJPY	)	StringAdd (TradeSymbolsToUse , 	"GBPJPY,"	);
   if(	GBPNZD	)	StringAdd (TradeSymbolsToUse , 	"GBPNZD,"	);
   if(	GBPUSD	)	StringAdd (TradeSymbolsToUse , 	"GBPUSD,"	);
   if(	NZDCAD	)	StringAdd (TradeSymbolsToUse , 	"NZDCAD,"	);
   if(	NZDCHF	)	StringAdd (TradeSymbolsToUse , 	"NZDCHF,"	);
   if(	NZDJPY	)	StringAdd (TradeSymbolsToUse , 	"NZDJPY,"	);
   if(	NZDUSD	)	StringAdd (TradeSymbolsToUse , 	"NZDUSD,"	);
   if(	USDCAD	)	StringAdd (TradeSymbolsToUse , 	"USDCAD,"	);
   if(	USDCHF	)	StringAdd (TradeSymbolsToUse , 	"USDCHF,"	);
   if(	USDJPY	)	StringAdd (TradeSymbolsToUse , 	"USDJPY,"	);

   if(	SP500	)
   {
   	        StringAdd (TradeSymbolsToUse ,SP500_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	Dow30	){
   	        StringAdd (TradeSymbolsToUse ,Dow30_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	EURO50	){
   	        StringAdd (TradeSymbolsToUse ,EURO50_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	UK100	){
   	        StringAdd (TradeSymbolsToUse ,UK100_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	DAX	){
   	        StringAdd (TradeSymbolsToUse ,DAX_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	Nikkei225	){
   	        StringAdd (TradeSymbolsToUse ,Nikkei225_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	AUS200	){
   	        StringAdd (TradeSymbolsToUse ,AUS200_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	CAC	){
   	        StringAdd (TradeSymbolsToUse ,CAC_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	GOLD	){
   	        StringAdd (TradeSymbolsToUse ,GOLD_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	SILVER	){
   	        StringAdd (TradeSymbolsToUse ,SILVER_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	PLATINUM	){
   	        StringAdd (TradeSymbolsToUse ,PLATINUM_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	PALLADUIUM	){
   	        StringAdd (TradeSymbolsToUse ,PALLADUIUM_S);
   	        StringAdd (TradeSymbolsToUse ,	",");} 
   if(	OIL	){
   	        StringAdd (TradeSymbolsToUse ,OIL_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	COFFEE	){
   	        StringAdd (TradeSymbolsToUse ,COFFEE_S);
   	        StringAdd (TradeSymbolsToUse ,	",");} 
   if(	CORN	){
   	        StringAdd (TradeSymbolsToUse ,CORN_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	CUTTON	){
   	        StringAdd (TradeSymbolsToUse ,CUTTON_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	COCOA	){
   	        StringAdd (TradeSymbolsToUse ,COCOA_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	OrangeJuice	){
   	        StringAdd (TradeSymbolsToUse ,OrangeJuice_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}     
   if(	WHEAT	){
   	        StringAdd (TradeSymbolsToUse ,WHEAT_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}
   if(	SOYBEAN	){
   	        StringAdd (TradeSymbolsToUse ,SOYBEAN_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}  
   if(	SUGAR	){
   	        StringAdd (TradeSymbolsToUse ,SUGAR_S);
   	        StringAdd (TradeSymbolsToUse ,	",");}

   NumberOfTradeableSymbols = StringSplit(TradeSymbolsToUse, ',' , TempArr);
   NumberOfTradeableSymbols = NumberOfTradeableSymbols-1;
   PrintMessage("Number Of Tradeable Symbols is: " + string(NumberOfTradeableSymbols));
   PrintMessage("Tradeable Symbols are: " + string(TradeSymbolsToUse));
   ArrayResize(SymbolArray, NumberOfTradeableSymbols);
   
   int i=0;
   if(	AUDCAD	){
   	SymbolArray[i] = "AUDCAD" ;
   	i++;}
   if(	AUDCHF	){
      	SymbolArray[i] = "AUDCHF" ;	
      	i++;}   	
   if(	AUDJPY	){
         SymbolArray[i] = "AUDJPY" ;	
      	i++;}
   
   if(	AUDNZD	){
         SymbolArray[i] = "AUDNZD" ;	
      	i++;}
   if(	AUDUSD	){
         SymbolArray[i] = "AUDUSD" ;	
      	i++;}
   if(	CADCHF	){
            SymbolArray[i] = "CADCHF" ;	
      	i++;}
   if(	CADJPY	){
         SymbolArray[i] = "CADJPY" ;	
      	i++;}
   if(	CHFJPY	){
         SymbolArray[i] = "CHFJPY" ;	
      	i++;}	
   if(	EURAUD	){
         SymbolArray[i] = "EURAUD" ;	
      	i++;}	
   if(	EURCAD	){
   	   SymbolArray[i] = "EURCAD" ;	
      	i++;}	
   if(	EURCHF	){
      	SymbolArray[i] = "EURCHF" ;	
      	i++;}	
   if(	EURGBP	){
      	SymbolArray[i] = "EURGBP" ;	
      	i++;}	  
   if(	EURJPY	){
         SymbolArray[i] = "EURJPY" ;	
      	i++;}	  
   if(	EURNZD	){
         SymbolArray[i] = "EURNZD" ;	
      	i++;}	     
   if(	EURUSD	){
         SymbolArray[i] = "EURUSD" ;	
      	i++;}	        
   if(	GBPAUD	){
         SymbolArray[i] = "GBPAUD" ;	
      	i++;}	     
   if(	GBPCAD	){
         SymbolArray[i] = "GBPCAD" ;	
      	i++;}	    
   if(	GBPCHF	){
         SymbolArray[i] = "GBPCHF" ;	
      	i++;}		    	     	
   if(	GBPJPY	){
         SymbolArray[i] = "GBPJPY" ;	
      	i++;}		
   if(	GBPNZD	){
         SymbolArray[i] = "GBPNZD" ;	
      	i++;}		
   if(	GBPUSD	){
         SymbolArray[i] = "GBPUSD" ;	
      	i++;}		
   if(	NZDCAD	){
         SymbolArray[i] = "NZDCAD" ;	
      	i++;}		
   if(	NZDCHF	){
         SymbolArray[i] = "NZDCHF" ;	
      	i++;}		
   if(	NZDJPY	){
         SymbolArray[i] = "NZDJPY" ;	
      	i++;}		
   if(	NZDUSD	){
         SymbolArray[i] = "NZDUSD" ;	
      	i++;}		
   if(	USDCAD	){
         SymbolArray[i] = "USDCAD" ;	
      	i++;}		
   if(	USDCHF	){
         SymbolArray[i] = "USDCHF" ;	
      	i++;}		
   if(	USDJPY	){
         SymbolArray[i] = "USDJPY" ;	
      	i++;}		  
   
   if(	SP500	){
         SymbolArray[i] = SP500_S ;	
      	i++;}		
   if(	Dow30	){
         SymbolArray[i] = Dow30_S ;	
      	i++;}		
   if(	EURO50	){
         SymbolArray[i] = EURO50_S ;	
      	i++;}		  
   if(	UK100	){
         SymbolArray[i] = UK100_S ;	
      	i++;}		
   if(	DAX	){
         SymbolArray[i] = DAX_S ;	
      	i++;}		
   if(	Nikkei225	){
         SymbolArray[i] = Nikkei225_S ;	
      	i++;}		
   if(	AUS200	){
         SymbolArray[i] = AUS200_S ;	
      	i++;}		
   if(	CAC	){
         SymbolArray[i] = CAC_S ;	
      	i++;}		
   if(	GOLD	){
         SymbolArray[i] = GOLD_S ;	
      	i++;}		
   if(	SILVER	){
         SymbolArray[i] = SILVER_S ;	
      	i++;}		
   if(	PLATINUM	){
         SymbolArray[i] = PLATINUM_S ;	
      	i++;}		
   if(	PALLADUIUM	){
         SymbolArray[i] = PALLADUIUM_S ;	
      	i++;}		   
   if(	OIL	){
         SymbolArray[i] = OIL_S ;	
      	i++;}		
   if(	COFFEE	){
         SymbolArray[i] = COFFEE_S ;	
      	i++;}		  
   if(	CORN	){
         SymbolArray[i] = CORN_S ;	
      	i++;}		  
   if(	CUTTON	){
         SymbolArray[i] = CUTTON_S ;	
      	i++;}		
   if(	COCOA	){
         SymbolArray[i] = COCOA_S ;	
      	i++;}		
   if(	OrangeJuice	){
         SymbolArray[i] = OrangeJuice_S ;	
      	i++;}		   
   if(	WHEAT	){
         SymbolArray[i] = WHEAT_S ;	
      	i++;}		
   if(	SOYBEAN	){
         SymbolArray[i] = SOYBEAN_S ;	
      	i++;}		   
   if(	SUGAR	){
         SymbolArray[i] = SUGAR_S ;	
      	i++;}		
   PrintMessage(("Number Of Tradeable Symbols is: " + string(NumberOfTradeableSymbols)));
}


void PopulateSingleSymbol()
{
   switch(TradeOnly1Symbol)
  {
      case	1	:		
			AUDCAD	= true; 
			         break;	
      case	2	:		
			AUDCHF	= true; 
			         break;	
      case	3	:		
			AUDJPY	= true; 
			         break;	
      case	4	:		
			AUDNZD	= true; 
			         break;	
      case	5	:		
			AUDUSD	= true; 
			         break;	
      case	6	:		
			CADCHF	= true; 
			         break;	
      case	7	:		
			CADJPY	= true; 
			         break;	
      case	8	:		
			CHFJPY	= true; 
			         break;	
      case	9	:		
			EURAUD	= true; 
			         break;	
      case	10	:		
			EURCAD	= true; 
			         break;	
      case	11	:		
			EURCHF	= true; 
			         break;	
      case	12	:		
			EURGBP	= true; 
			         break;	
      case	13	:		
			EURJPY	= true; 
			         break;	
      case	14	:		
			EURNZD	= true; 
			         break;	
      case	15	:		
			EURUSD	= true; 
			         break;	
      case	16	:		
			GBPAUD	= true; 
			         break;	
      case	17	:		
			GBPCAD	= true; 
			         break;	
      case	18	:		
			GBPCHF	= true; 
			         break;	
      case	19	:		
			GBPJPY	= true; 
			         break;	
      case	20	:		
			GBPNZD	= true; 
			         break;	
      case	21	:		
			GBPUSD	= true; 
			         break;	
      case	22	:		
			NZDCAD	= true; 
			         break;	
      case	23	:		
			NZDCHF	= true; 
			         break;	
      case	24	:		
			NZDJPY	= true; 
			         break;	
      case	25	:		
			NZDUSD	= true; 
			         break;	
      case	26	:		
			USDCAD	= true; 
			         break;	
      case	27	:		
			USDCHF	= true; 
			         break;	
      case	28	:		
			USDJPY	= true; 
			         break;	
      case	29	:		
			SP500	= true; 
			         break;	
      case	30	:		
			Dow30	= true; 
			         break;	
      case	31	:		
			EURO50	= true; 
			         break;	
      case	32	:		
			UK100	= true; 
			         break;	
      case	33	:		
			DAX	= true; 
			         break;	
      case	34	:		
			Nikkei225	= true; 
			         break;	
      case	35	:		
			AUS200	= true; 
			         break;	
      case	36	:		
			CAC	= true; 
			         break;	
      case	37	:		
			GOLD	= true; 
			         break;	
      case	38	:		
			SILVER	= true; 
			         break;	
      case	39	:		
			PLATINUM	= true; 
			         break;	
      case	40	:		
			PALLADUIUM	= true; 
			         break;	
      case	41	:		
			OIL	= true; 
			         break;	
      case	42	:		
			COFFEE	= true; 
			         break;	
      case	43	:		
			CORN	= true; 
			         break;	
      case	44	:		
			CUTTON	= true; 
			         break;	
      case	45	:		
			COCOA	= true; 
			         break;	
      case	46	:		
			OrangeJuice	= true; 
			         break;	
      case	47	:		
			WHEAT	= true; 
			         break;	
      case	48	:		
			SOYBEAN	= true; 
			         break;	
      case	49	:		
			SUGAR	= true; 
			         break;	
      default:
        Print("TradeOnly1Symbol got wrong paremeter, parameter is: " , TradeOnly1Symbol);
        break;
  }
}



void Symbols_Initiate()
{
         CopyInputsSymbols();
         if (TradeOnly1Symbol >0) //use following code to false all
         {
            TradeForex =false;
            TradeIndex=false;
            TradeMetals=false;
            TradeCommodities=false;
         }
         CurrenciesInitiate();
         IndicesInitiate();
         MetalsInitiate();
         CommoditiesInitiate();
         if (TradeOnly1Symbol >0) PopulateSingleSymbol();// add true to only 1 symbol
         PopulateSymbolsString();
         ResizeAllArrays();
         PrintMessage(("EA will process: " + TradeSymbolsToUse));
         PrintMessage( "SymbolArray printout: ");
         for (int s=0; s<NumberOfTradeableSymbols;s++)
         {
            Print(SymbolArray[s]);
         }
}


