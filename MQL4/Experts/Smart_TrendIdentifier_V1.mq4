//+------------------------------------------------------------------+
//|                                     Smart_TrendIdentifier_V1.mq4 |
//|                                  Copyright 2018, Roopsikha Yadav |
//|                              https://github.com/roopsikhayadav28 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Roopsikha Yadav"
#property link      "https://github.com/roopsikhayadav28"
#property version   "1.00"
#property strict
#include <SQLOperations.mqh>
#include <TIOperation.mqh>

int SymbolTotal;
bool sellVar, buyVar;

struct elements 
  { 
    string Var;
    double Value;
  };
  
int countInit = 0;

elements Array[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
    if(MessageBox("You Want to Delete Table and Refresh ? ","Trend Identifier", MB_YESNO ) == IDYES )
    {
       DeleteDataTable();
       ////Sleep(9000);
       CreateDataTable();
    
       ////Sleep(9000);
       CheckChartOpen();
       //checkGraph();
       SymbolTotal = SymbolsTotal(true);
       ArrayResize(Array,SymbolTotal);
       ////Sleep(9000);
       SQLOperationOnInit(); 
    }
    LabelActive("*****Trend Identifier Active*****", clrLimeGreen);
    Alert("*****Trend Identifier Active*****");
//---
    CheckChartOpen();
    long dbConnectSQLId = 0;
    ConnectSQL(dbConnectSQLId); // connect

    int hour = Hour();  

    OnTicks(dbConnectSQLId);     
     
    DisConnect(dbConnectSQLId); // disconnect

   return(INIT_SUCCEEDED);
  }
  
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason )
  {
//---
      LabelActive("*****Trend Identifier Removed*****", clrRed);
      deleteAllObjects();     
      Alert("TREND IDENTIFIER REMOVED");
  }
 
 void deleteAllObjects()
{
   int obj_total=ObjectsTotal(); 
   PrintFormat("Total %d objects",obj_total); 
   for(int i=obj_total-1;i>=0;i--) 
     { 
      string name=ObjectName(i); 
      PrintFormat("object %d: %s",i,name); 
      ObjectDelete(name); 
     }
   
    label_created = FALSE;
    label_created_active =FALSE; 
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
{
   long    dbConnectSQLId = 0 ;

   LabelActive("*****Trend Identifier Active*****", clrPink);
   if( Volume[0] > 5 )
   {
     Label("WAITING FOR NEXT CANDLE :: " + getChartTimeFrameString(PERIOD_CURRENT) +" " + TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS), clrPink);
     return;
   }
   
   if(IsStopped())
      return;
   ConnectSQL(dbConnectSQLId); // connect
   
   int hour = Hour();   

   OnTicks(dbConnectSQLId);     
     
   DisConnect(dbConnectSQLId); // disconnect

}

void OnTicks(long &dbConnectSQLId)
  {
//--- 
    //if(Volume[0] > 1 )
     // return;   
    CheckChartOpen();
    //checkGraph();
    SQLOperationOnTick(dbConnectSQLId);
    ////Sleep(9000);    
  }
  

void SQLOperationOnInit()
{
     for(int i = 0; i < SymbolTotal; i++)
     { 
     
        if(IsStopped())
          break;
        if(i > 50 )
          Sleep(5000);
          
        string symbol =SymbolName(i,true);
        string EntryType  = CheckForOpen(symbol);
        if( !checkFilter(symbol,"",EntryType) )
            continue;
            
        Label("INSERT " + symbol+ " ,** TREND SELECTION ** = " + getTrendSelectionString(),clrOrange );      
        InsertStringDataIntoMYSQL(symbol,"Symbol",symbol);
        InsertSymbolIntoMaster(symbol,"Symbol",symbol);
       // OpenFile(symbol);
              
     }
     
    /* for(int i = 0; i < SymbolsTotal(false); i++)
     { 
     
        if(IsStopped())
          break;
          
        string symbol =SymbolName(i,false);
        InsertSymbolIntoMaster(symbol,"Symbol",symbol);
       // OpenFile(symbol);
              
     }*/
    // SQLOperationOnTick();
}

void SQLOperationOnTick(long &dbConnectSQLId)
{

  //char  sym[30];
     for(int i = 0; i < SymbolTotal; i++)
     { 
       if( IsStopped() )
           break;
      if(i > 50 )
          Sleep(5000); 
             
        string symbol =SymbolName(i,true);
        
        string EntryType  = CheckForOpen(symbol);
        if( !checkFilter(symbol,"",EntryType) )
            continue;
            
        Label("Updating " + symbol+ " ,** TREND SELECTION ** = " + getTrendSelectionString(),clrYellow );  
        
        UpdateStringDataTable(symbol,"EntryType",EntryType, dbConnectSQLId);
       
        double lowVal = getCrossOverCandleLowValue(symbol);
        PercentChange(dbConnectSQLId, symbol);
        UpdateADX(dbConnectSQLId, symbol);
        UpdateRSI(dbConnectSQLId, symbol);
        UpdateStringDataTable(symbol,"Stockistic",getStochasticStatus(dbConnectSQLId, symbol),dbConnectSQLId);
        UpdateVWAP(dbConnectSQLId , symbol);
        double Momentum   = NormalizeDouble(iMomentum(symbol,FOLLOW_CHART_TIME_FRAME,14,PRICE_WEIGHTED,0),2);
        UpdateDoubleDataTable( dbConnectSQLId, symbol,"Momentum",Momentum);
        
        double EntryValue = NormalizeDouble(iClose(symbol,PERIOD_D1,1),2);
        UpdateDoubleDataTable( dbConnectSQLId, symbol,"EntryValue",EntryValue);
        
        double LTP        = NormalizeDouble(iClose(symbol,FOLLOW_CHART_TIME_FRAME,0),2);
        UpdateDoubleDataTable( dbConnectSQLId, symbol,"LTP",LTP);
  
   
        UpdatePivotsPoints(dbConnectSQLId, symbol);

        string TimeFrame  = getChartTimeFrameString(FOLLOW_CHART_TIME_FRAME);
        UpdateStringDataTable(symbol,"TimeFrame",TimeFrame, dbConnectSQLId);
        
        string ProductType= "--";
        UpdateStringDataTable(symbol,"ProductType",ProductType, dbConnectSQLId);
        
        string ExecuteTrade="Execute Trade";        
        UpdateStringDataTable(symbol,"ExecuteTrade",ExecuteTrade, dbConnectSQLId);
        UpdateStringDataTable(symbol,"DateANDTime", TimeToStr(iTime(symbol,FOLLOW_CHART_TIME_FRAME,0),TIME_DATE|TIME_SECONDS), dbConnectSQLId);   //TimeLocal(),TIME_DATE|TIME_MINUTES)
        //UpdateDataTable(symbol,PercentChange,AdxValue,DI_Plus,DI_Minus,AdxSlope,RSI,Stockistic,VWAP,Momentum,EntryValue,LTP,EntryType,S1,S2,S3,TimeFrame,ProductType,ExecuteTrade);
        CheckChartOpen();
        //////Sleep(4000);
     }
    // ArrayFree(sym);
}

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
string CheckForOpen( string CurrencyPair)
  {
//--- go trading only for first tiks of new bar
   //if(Volume[0]>1) return;
   string str = "--";
    if(Trend(CurrencyPair) == sell_H1)
    {
      str = EntrySell( CurrencyPair);
      return str;
    }
    else if(Trend(CurrencyPair) == buy_H1)
    {
      str = EntryBuy( CurrencyPair);
      return str;
    }
    return str;    
 }

string EntrySell( string CurrencyPair)
{
   double lowVal = getCrossOverCandleLowValue(CurrencyPair);
   double closePrice = getClosePrice(CurrencyPair);
   double LTP_Low = CheckLTP_L(lowVal,LTPLow(CurrencyPair));

   if( SellEntry(CurrencyPair) )
     {
        sellVar = TRUE;
        strHeader =  sell_H1;
        //checkFilter( CurrencyPair,strHeader,sell_H1);
        return strHeader;
     }

   return "--";  
}
//--- buy conditions
string EntryBuy( string CurrencyPair)
{   
   double highVal = getCrossOverCandleHighValue(CurrencyPair);
   double closePrice = getClosePrice(CurrencyPair);
   double LTP_High = CheckLTP_H(highVal, LTPHigh(CurrencyPair));
   
   if( BuyEntry(CurrencyPair))
     {
         buyVar = TRUE;
         strHeader =  buy_H1;
         //checkFilter( CurrencyPair,strHeader,buy_H1);
         return strHeader;  
     }

     return "--";  
//---
  }


void InsertPercentChange(string symbol)
{
   double Op = iClose(symbol,PERIOD_D1,1);
   double Cp = iClose(symbol,FOLLOW_CHART_TIME_FRAME,0);
   double diff = Cp - Op;
   InsertDoubleDataIntoMYSQL(symbol,"PercentChange",NormalizeDouble((diff/Op)*100,2));   
}

void InsertADX(string symbol)
{
   double AdxValue   = NormalizeDouble(iADX(symbol,FOLLOW_ADX_TIME_FRAME,14,applied_price,MODE_MAIN,0),2);
   double DI_Plus    = NormalizeDouble(iADX(symbol,FOLLOW_ADX_TIME_FRAME,14,applied_price,MODE_PLUSDI,0),2);
   double DI_Minus   = NormalizeDouble(iADX(symbol,FOLLOW_ADX_TIME_FRAME,14,applied_price,MODE_MINUSDI,0),2);
   string AdxSlope   = ADXTrend(symbol);
   
   InsertDoubleDataIntoMYSQL(symbol,"AdxValue",AdxValue);
   
   InsertDoubleDataIntoMYSQL(symbol,"DI_Plus",DI_Plus);
   
   InsertDoubleDataIntoMYSQL(symbol,"DI_Minus",DI_Minus);
   
   InsertStringDataIntoMYSQL(symbol,"AdxSlope",AdxSlope);
}

void InsertRSI(string symbol)
{
   double RSI        = NormalizeDouble(iRSI(symbol,FOLLOW_STOCASHTIC_TIME_FRAME,14,applied_price,0),2);
   InsertDoubleDataIntoMYSQL(symbol,"RSI",RSI);
}

void InsertVWAP(string symbol)
{
    double VWAP       = NormalizeDouble(iMA(symbol,FOLLOW_CHART_TIME_FRAME,MA_SLOW,0,MODE_EMA,PRICE_WEIGHTED,0),2);
    InsertDoubleDataIntoMYSQL(symbol,"VWAP",VWAP);
}

//********Update**************//
void PercentChange(long &dbConnectSQLId, string symbol)
{
   if(TimeDay(TimeCurrent()) != TimeDay( iTime(symbol,PERIOD_D1,0)) )
   {
     UpdateDoubleDataTable( dbConnectSQLId,symbol,"PercentChange",NULL);
     return;
   }
   double Op = iClose(symbol,PERIOD_D1,1);
   double Cp = iClose(symbol,FOLLOW_CHART_TIME_FRAME,0);
   double diff = Cp - Op;
   if(Op == 0){
     UpdateDoubleDataTable( dbConnectSQLId,symbol,"PercentChange",NormalizeDouble(999,2)); 
     return;
     }
   double p = (diff/Op)*100;
   UpdateDoubleDataTable( dbConnectSQLId,symbol,"PercentChange",NormalizeDouble(p,2));    
}

void UpdateADX(long &dbConnectSQLId, string symbol)
{
   double AdxValue   = NormalizeDouble(iADX(symbol,FOLLOW_ADX_TIME_FRAME,14,applied_price,MODE_MAIN,0),2);
   double DI_Plus    = NormalizeDouble(iADX(symbol,FOLLOW_ADX_TIME_FRAME,14,applied_price,MODE_PLUSDI,0),2);
   double DI_Minus   = NormalizeDouble(iADX(symbol,FOLLOW_ADX_TIME_FRAME,14,applied_price,MODE_MINUSDI,0),2);
   string AdxSlope   = ADXTrend(symbol);
   
   UpdateDoubleDataTable( dbConnectSQLId,symbol,"AdxValue",AdxValue);
   
   UpdateDoubleDataTable( dbConnectSQLId,symbol,"DI_Plus",DI_Plus);
   
   UpdateDoubleDataTable( dbConnectSQLId,symbol,"DI_Minus",DI_Minus);
   
   UpdateStringDataTable(symbol,"AdxSlope",AdxSlope,dbConnectSQLId);
}

void UpdateRSI(long &dbConnectSQLId, string symbol)
{
   double RSI        = NormalizeDouble(iRSI(symbol,FOLLOW_STOCASHTIC_TIME_FRAME,14,applied_price,0),2);
   UpdateDoubleDataTable( dbConnectSQLId,symbol,"RSI",RSI);
}

void UpdateVWAP( long &dbConnectSQLId, string symbol)
{
    double VWAP       = NormalizeDouble(iMA(symbol,FOLLOW_CHART_TIME_FRAME,MA_SLOW,0,MODE_EMA,PRICE_WEIGHTED,0),2);
    UpdateDoubleDataTable( dbConnectSQLId,symbol,"VWAP",VWAP);
}
