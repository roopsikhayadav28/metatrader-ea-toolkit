//+------------------------------------------------------------------+
//|                            Vortex-ADX_EA_Long_Trend_Currency.mq4 |
//|                                  Copyright 2018, Roopsikha Yadav |
//|                              https://github.com/roopsikhayadav28 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Roopsikha Yadav"
#property link      "https://github.com/roopsikhayadav28"
#property version   "1.00"
#property strict

#define MAGICMA  20131111
#define  MODE_PLUSVI            0
#define  MODE_MINUSVI           1

//+------------------------------------------------------------------+
//|Input Values from User                                            |
//+------------------------------------------------------------------+
input bool CURRENT_BUY_ORDER = 0;
input bool CURRENT_SELL_ORDER = 0;
input double PRICE_EXECUTED = 0;
input double ENTER_STOPLOSS_DIFF = 0.15;
input double EnterTrailingStopLoss=0;
//input ENUM_TIMEFRAMES FOLLOW_TIME_FRAME=PERIOD_H1;
input ENUM_TIMEFRAMES PIVOT_TIME_FRAME = PERIOD_H1;
input ENUM_TIMEFRAMES FOLLOW_CHART_TIME_FRAME=PERIOD_M15;
input string XXXXXXXXXXXXXXXXB = "**********************";
input int MA_Slow_MovingPeriod = 13;

int ADX_VeryStrongTrend_BTW_75_100= 75;
int ADX_StrongTrend_BTW_50_75 = 50;
int ADX_MediumTrend_BTW_40_50 = 40;
//use stocastic for exit and enter
int ADX_WeakTrend_BTW_25_40 = 25;
int ADX_VeryWeakTrend_Below_25 = 25;

input string XXXXXXXXXXXXXXXX = "***********************";
//--- Inputs MA
 double MA_Lots          =1;
 double stopLoss_percent=ENTER_STOPLOSS_DIFF;
 double takeProfit_percent=1.0;
 int    MA_Slippage      = 1;
//input int    MA_Slippage      = 1;
input int    MA_MovingPeriod_short  =5;
input int    MA_MovingPeriod_long  =8;
int    MA_MovingShift_short  = 0;
int    MA_MovingShift_long = 0;
//input double MA_DIFFERENCE = 0.03;
input string XXXXXXXXXXXXXXXXC = "***********************";
input bool RefreshGraph = True;
input bool SHOW_INDICATOR = FALSE;
input bool SHOW_VALUE = FALSE;
//input int ADX_BELOW_DO_NOT_ENTER = 20;
int ST_DIFF = 4;
/*input int DI_TREND_SHOULD_BE_GREATER_THAN= 30;
input int DI_TREND_SHOULD_BE_LESS_THAN=25;*/

double   Pivot_Point_P;
double   Support_S1;
double   Support_S2;
double   Resistance_R1;
double   Resistance_R2;   
double   PlusVI1;
double	PlusVI2;
double   MinusVI1;
double	MinusVI2;
double   VI_EnterTrendVal= 1.1;
double   VI_DownTrendVal= 0.9;
double lowVal = 0, highVal = 0;

//+------------------------------------------------------------------+
//|Label initialize values                                           |
//+------------------------------------------------------------------+

string          InpNameP="HLineP";     // Line name
string          InpNameS1="HLineS1";     // Line name 
string          InpNameS2="HLineS2";     // Line name 
string          InpNameR1="HLineR1";     // Line name 
string          InpNameR2="HLineR2";     // Line name 
string          InpNameSL="HlineSL";
string            InpName="Label";         // Label name
string            InpNameOrderLabel="LabelOrder";
string            InpNameADXLabel = "LabelADX";
string            InpNameADXSlopeLabel = "LabelADXSlope";
string            InpFont="Arial";         // Font
int               InpFontSize=14;          // Font size
double            InpAngle=0.0;            // Slope angle in degrees
ENUM_ANCHOR_POINT InpAnchor=ANCHOR_CENTER; // Anchor type
bool              InpBack=false;           // Background object
bool              InpSelection=true;       // Highlight to move
bool              InpHidden=true;          // Hidden in the object list
long              InpZOrder=0;             // Priority for mouse click

 ENUM_LINE_STYLE InpStyle=STYLE_DASH; // Line style 
 int             InpWidth=1;          // Line width 
 color           InpColorS=clrRed;

bool isNotFirstTime = FALSE,buy=FALSE, sell=FALSE,isLabel_Pivot_Created = FALSE, label_created = FALSE, isLabel_Hour_Created = FALSE, label_created_order=FALSE,label_created_adx_slope = FALSE, label_created_adx = FALSE, buyVar,sellVar;
double LTP = 0;
static double LTP_Suggested = 0;
string strHeader,strHeaderExit,finalString,Down = "DOWN", Up="UP";
double ma_fast_current, ma_slow_current, ma_fast_prev, ma_slow_prev;
double ADX, ADX_MinusDI, ADX_PlusDI, ADX_1, ADX_2, ADX_MinusDI_1, ADX_MinusDI_2, ADX_PlusDI_1, ADX_PlusDI_2;
//---- input parameters
input int VI_Length = 14;

enum ENUM_VORTEX_ENTRY
{
   CROSS,
   PointOne,
   MA
};

input ENUM_VORTEX_ENTRY VORTEX_ENTRY = CROSS;

string getPivotTimeFrameString()
{
   switch(PIVOT_TIME_FRAME)
   {
    case PERIOD_CURRENT:
      return "Current timeframe";
    case PERIOD_M1:
      return "1 minute";
    case PERIOD_M5:
      return "5 minutes";
    case PERIOD_M15:
      return "15 minutes";
    case PERIOD_M30:
      return "30 minutes";
    case PERIOD_H1:
      return "1 hour";
    case PERIOD_H4:
      return "4 hours";
    case PERIOD_D1:
      return "1 day";
    case PERIOD_W1:
      return "1 week";
    case PERIOD_MN1:
      return "1 month";
    default:
       return "NULL";
   }    
}

string buy_H1= "BUY",sell_H1="SELL";
color clrSell = clrRed, clrBuy = clrLawnGreen, clrNeutral = clrDarkTurquoise;
string const strNeutral="DO NOT TAKE FRESH ENTRY ";
string const strWaiting="WAITING FOR TICK, ";
int file_handle;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
     calculateStopLoss();
     VerifyStopLossEntered(true);
     PivotPoints();
     CreateChart();
     while(!IsConnected())
     {
        Label("!!!No Connection!!!", clrCornflowerBlue);
        continue;
     }
     buy_H1= "BUY";
     sell_H1="SELL";
     sT=0.0;

 
     buy  =  CURRENT_BUY_ORDER;
     sell =  CURRENT_SELL_ORDER;          
 
     LTP=0;
         
     PrintCommentHeader("",DisplayOnScreen());
     LabelOrderStatus();
     ShowADXValue(SHOW_VALUE);
     LabelHour();
     if(VerifyOneWayTrendEntryByUser(true))
     {
       //return 0;
     }
     
     buyVar = buy;
     sellVar = sell;
     if((buy || sell) && PRICE_EXECUTED == 0.0)
     {
       ErrorMessage(" Please enter Price when placing order" );
       return 0;
     }
     else if(buy && sell){
       ErrorMessage(" You have entered Sell & Buy both true,\n Please set one of them true"  );
       return 0;
     }
     else if(sell == TRUE)
     {
        Label(strWaiting+ADXTrend(),clrSell);
     }
     else if(buy == TRUE)
     {
        Label(strWaiting+ADXTrend(),clrBuy);
     }
     else
        Label(strWaiting,clrNeutral); 
   
     file_handle=FileOpen(InpDirectoryName+"//"+InpFileName,FILE_READ|FILE_WRITE|FILE_CSV);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      //--- delete all objects 
      int obj_total=ObjectsTotal(); 
      PrintFormat("Total %d objects",obj_total); 
      for(int i=obj_total-1;i>=0;i--) 
        { 
         string name=ObjectName(i); 
         PrintFormat("object %d: %s",i,name); 
         ObjectDelete(name); 
        }
    isLabel_Hour_Created = FALSE;   
    label_created = FALSE;
    label_created_adx =FALSE;
    label_created_adx_slope = FALSE;
    label_created_order = FALSE;
    
    if(file_handle !=INVALID_HANDLE )
    {
          //--- close the file 
      FileClose(file_handle); 
      PrintFormat("Data is written, %s file is closed",InpFileName); 
    }
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
     while(!IsConnected())
     {
        Label("!!!No Connection!!!", clrCoral);
        continue;
     }
     PivotPoints();   
     LabelOrderStatus();
     calculateStopLoss();
     VerifyStopLossEntered(false);
     ShowADXValue(SHOW_VALUE); 
     LabelHour();  

     PrintCommentHeader("",DisplayOnScreen());
        
        //+------------------------------------------------------------------+
        //|NEUTRAL                                                           |
        //+------------------------------------------------------------------+  
        if(sell == FALSE && buy == FALSE)
        {
           if(!CheckForOpen())
             Label(strNeutral,clrNeutral);
             
           return;           
        }
        else if( sell && buy )
        {
          VerifyOneWayTrendEntryByUser(false);
          return;
        }
        else if(sell == TRUE)
        {
          //Check for Exit in sell loop
          if(!CheckForClose())
          {
             //Be in sell position       
             Label("CONTINUE SELL, "+ADXTrend(),clrSell);
          }
          return;
        }        
        else if(buy == TRUE)
        {
          //Check for Exit in sell loop
          if(!CheckForClose())
          {
             //Be in sell position       
             Label("CONTINUE BUY, "+ADXTrend(),clrBuy);
          }
          return;
        }   
  }

void VerifyStopLossEntered(bool OneTimeOnly)
{
   if(ENTER_STOPLOSS_DIFF == 0)
      Alert(Symbol()+" Enter Stoploss Diff");
      
   if(sell || buy)
   {
      if(EnterTrailingStopLoss == 0 && sT != 0 )
      {
        Alert(Symbol()+" Please Enter Stop Loss");
        return;
      }
      
      if(EnterTrailingStopLoss < sT + 0.2 && EnterTrailingStopLoss > sT -0.2 && sT !=0 && OneTimeOnly )
      {
        Alert(Symbol()+" You Have added Trailing StopLoss");
      }
      if( (EnterTrailingStopLoss > sT + 0.2 || EnterTrailingStopLoss < sT -0.2 ) && sT !=0 )
      {
        Alert(Symbol()+" !!!!!Check Trailing StopLoss Value");
      }
   }
}
 
bool VerifyOneWayTrendEntryByUser(bool showMsg)
{     
  if(Trend() == buy_H1 && CURRENT_SELL_ORDER == TRUE)
  {
     if(showMsg)
        ErrorMessage("Current Trend = " + Trend() +", You can only enter in current trend");
        
     Label("EA has been stopped, please enter correct values",clrRed);
     return true;
  }
  if(Trend() == sell_H1 && CURRENT_BUY_ORDER == TRUE)
  {
     if(showMsg)
        ErrorMessage("Current Trend = " + Trend() +", You can only enter in current trend");
        
     Label("EA has been stopped, please enter correct values",clrRed);
     return true;
  }
  return false;
}

//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
bool CheckForOpen()
  {
//--- go trading only for first tiks of new bar
   //if(Volume[0]>1) return;
   bool result = FALSE;
   
    if(Trend() == sell_H1)
    {
      result =  EntrySell();
    }
    else if(Trend() == buy_H1)
    {
      result =  EntryBuy();
    }
    return result;    
 }
 
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
bool CheckForClose()
  {
    bool result = FALSE;
    
    if( sell )
    {
      result = ExitSell();
    }
    else if( buy )
    {
      result = ExitBuy();
    }    
    return result;
}

bool EntrySell()
{
   RefreshRates();
   Refresh_MA_Value(); 

   if( VortexCrossOverSellEntry() && ( Close[0] < lowVal && lowVal != 0.0 ) && !sell && !sellVar )
     {

         isNotFirstTime = TRUE;
         sellVar = TRUE;
         LTP_Suggested = NormalizeDouble(LTP,2);
         strHeader = ADXTrend()+", Entry Sell, " +Symbol() +", "+ string(LTP_Suggested);
         Alert(strHeader);
         PlaySound("\\Files\\inform.wav");
         Label( strHeader,clrSell);
         logFile(strHeader);
         ShowStopLoss();     
         Sell(MA_Lots);
         //PrintCommentHeader(strHeader,DisplayOnScreen());

       return TRUE;
     }
     if( VortexCrossOverSellEntry() && ( Close[0] < lowVal && lowVal != 0.0) && !sell )
     {        
        //Alert(strHeader);
        return TRUE;
     }

   return FALSE;
}

//--- buy conditions
bool EntryBuy()
{
   RefreshRates();
   Refresh_MA_Value();   

   if( VortexCrossOverBuyEntry() && ( Close[0] > highVal ) && !buy  && !buyVar)
     {
         isNotFirstTime = TRUE;
         buyVar = TRUE;
         LTP_Suggested = (highVal);
         strHeader = ADXTrend()+", Entry Buy, " +Symbol() +", "+ DoubleToString(LTP_Suggested);
         Alert(strHeader);
         PlaySound("\\Files\\inform.wav");
         Label(strHeader, clrBuy);
         logFile(strHeader);
         ShowStopLoss();
         Buy(MA_Lots);
         //PrintCommentHeader(strHeader,DisplayOnScreen());
         return TRUE;  
     }
   if( VortexCrossOverBuyEntry() && ( Close[0] > highVal ) && !buy )
     {
        // Alert(strHeader);
         return TRUE;  
     } 
   return FALSE;  
//---
  }
  
bool ExitSell()
{
   RefreshRates();
   Refresh_MA_Value();
   //exit sale
 
   ShowStopLoss();
      
   if( ( ( ADX_PlusDI > ADX_MinusDI ) || ( DI_Plus_Slope() == Up && DI_Minus_SLope() == Down ) ) && sell && sellVar )
   {      
      LTP_Suggested = NormalizeDouble(LTP,2);
      strHeaderExit = "Exit SELL Position," + Symbol()+", LTP = "+ string(LTP_Suggested);
      Label(strHeaderExit,clrSell);
      logFile(strHeaderExit);
      Alert(strHeaderExit);
      PlaySound("\\Files\\inform.wav");
      CloseOrder();       
      sellVar = FALSE;

      return TRUE;
   }
   
   if( ( (ADX_PlusDI > ADX_MinusDI) || (DI_Plus_Slope() == Up && DI_Minus_SLope() == Down) ) && sell )
   {      
     // Alert(strHeaderExit);           
      return TRUE;
   }
     
   return FALSE;
//---
}

 bool ExitBuy()
 {  
   RefreshRates();
   Refresh_MA_Value();
   //exit buy
   
   ShowStopLoss();
      
   if( ( (ADX_MinusDI > ADX_PlusDI) || (DI_Plus_Slope() == Down && DI_Minus_SLope() == Up) ) && buy && buyVar )
   {
      LTP_Suggested = NormalizeDouble(LTP,2);
      strHeaderExit = "Exit BUY Position, " + Symbol()+", LTP = "+ string(LTP_Suggested);
      Label(strHeaderExit,clrBuy);
      logFile(strHeaderExit);
      Alert(strHeaderExit);
      PlaySound("\\Files\\inform.wav");
      buyVar = FALSE;
      CloseOrder();        
      return TRUE;
    }
   if( ( (ADX_MinusDI > ADX_PlusDI) || (DI_Plus_Slope() == Down && DI_Minus_SLope() == Up) ) && buy)
   {
      //Alert(strHeaderExit);       
      return TRUE;
    }
          
    return FALSE;
}

void ShowStopLoss()
{
   if(!SHOW_INDICATOR)
      return;
   if(sellVar || sell)
   {
      //if(Close[0] > Resistance_R2 ) 
         LabelADX("StopLOSS  R2 = "+ string(Resistance_R2), clrDeepPink);
         
      if(Close[0] < Support_S2 )
         Label("Take Profit S2 Hit!,"+ string(Support_S2), clrMediumSpringGreen); 
      
      
      if(Close[0] > Resistance_R1 ) 
          LabelADX("StopLOSS R1 Hit!,"+ string(Resistance_R1), clrWhite);
          
      if(Close[0] < Support_S1 ) 
         Label("Take Partial Profit S1 Hit!,"+ string(Support_S1), clrMediumSpringGreen);
    }
    
    if(buyVar || buy)
    {
      //if(Close[0] < Support_S2 ) 
       LabelADX("StopLOSS S2 = "+ string(Support_S2), clrDeepPink);
         
      if(Close[0] > Resistance_R2 )
         LabelADX("Take Profit R2 Hit!,"+ string(Resistance_R2), clrMediumSpringGreen);   
       
      if(Close[0] < Support_S1 ) 
         LabelADX("StopLOSS S1 Hit!,"+ string(Support_S1), clrWhite);
      
      if(Close[0] > Resistance_R1 )
           LabelADX("Take Partial Profit  R1 Hit!,"+ string(Resistance_R1), clrMediumSpringGreen);
    }
}

double sT,Sb,S1,sL;

void calculateStopLoss()
{     
   if(PRICE_EXECUTED == 0)
      return;
   sL=ENTER_STOPLOSS_DIFF;
   if(sell )
   {
      if(Close[0] >= sT && sT != 0.0){
        Alert(Symbol()+":Stop Loss Hit !! SL = "+ string(sT) );
        LabelADXSlope("Stop Loss Hit !! SL = "+ DoubleToStr(sT), clrOrange );
     }
     
    // if(Volume[0] > 1)
     {
        string stopL = sT == 0.0 ? "Waiting for New Candle" : DoubleToStr(sT);
        LabelADXSlope("Trail Stoploss to =  " +string(stopL), clrOrange);
        //return;       
     }

      if( Close[0] < PRICE_EXECUTED && Open[0] < Open[1] && ( sT > Open[0] + sL || sT == 0 ) )
         S1 = Open[0]+sL;
      else if( Close[0] >= PRICE_EXECUTED && sT == 0)
         S1 = PRICE_EXECUTED + sL;  //StopLoss base Price for buy
      else if( Close[0] + sL < sT && sT == 0)
         S1 = Close[1] + sL ;
         
      StopLossIndicator();    
   }
      
   if(buy )
   {  
      if(Close[0] <= sT && sT != 0.0){
        Alert(Symbol()+":Stop Loss Hit !! SL = "+ DoubleToStr(sT) );
        LabelADXSlope("Stop Loss Hit !! SL = "+ DoubleToStr(sT), clrAquamarine );
     }
     
    // if(Volume[0] > 1)
     {
        string stopL = sT == 0.0 ? "Waiting for New Candle" : DoubleToStr(sT);
        LabelADXSlope("Trail Stoploss to =  " +string(stopL), clrOrange);
        //return;       
     }

      if( Close[0] > PRICE_EXECUTED && Open[0] > Open[1] && (sT < Open[0] - sL || sT == 0 )  )
         S1 = Open[0]-sL;
      else if( Close[0] <= PRICE_EXECUTED && sT == 0 )
         S1 = PRICE_EXECUTED - sL;  //StopLoss base Price for buy
      else if( Close[0] - sL > sT && sT == 0 )
         S1 = Close[1] - sL ;
         
      StopLossIndicator();    
   }
         
      sT = S1;
      StopLossIndicator();

}

//--- parameters for writing data to file 
string             InpFileName="loging.csv";      // File name 
string             InpDirectoryName="Data//"+Symbol();     // Folder name 

void logFile(string str)
{   
   string detail = string(TimeCurrent()) +"," + Symbol() + "," + str+ "\n";
   if(file_handle!=INVALID_HANDLE) 
     { 
      PrintFormat("%s file is available for writing",InpFileName); 
      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));      

      FileWrite(file_handle,str);
     } 
   else{
      PrintFormat("Failed to open %s file, Error code = %d",InpFileName,GetLastError());
      }
}
 

bool VortexCrossOverBuyEntry()
{
   if( (VORTEX_ENTRY == CROSS) && ADXBuyEntry() && ( PlusVI1 > MinusVI1 ) )
   {
      getCrossOverCandleHighValue();
      return true;
   }
 
   if( (VORTEX_ENTRY == PointOne) && (PlusVI1 > VI_EnterTrendVal) && ADXBuyEntry())
   {
      getCrossOverCandleHighValue();
      return true;
   }
    
   if( VORTEX_ENTRY == MA && ( MA_Entry() == buy_H1 && ADXBuyEntry() ) && ( MinusVI1 < PlusVI1 ) )
   {
      getMACrossOverCandleHighValue();
      return true;
   } 
   return false;
}

bool VortexCrossOverSellEntry() 
{  
   if( VORTEX_ENTRY == CROSS && ADXSellEntry() && PlusVI1 < MinusVI1 )
   {
      getCrossOverCandleLowValue();
      return true;
   }
   
   if( VORTEX_ENTRY == PointOne && MinusVI1 > VI_EnterTrendVal && ADXSellEntry() )
   {
      getCrossOverCandleLowValue();
      return true;
   }
   
   if( VORTEX_ENTRY == MA && ( MA_Entry() == sell_H1 && ADXSellEntry() ) && ( MinusVI1 > PlusVI1 ) )
   {
      getMACrossOverCandleLowValue();
      return true;
   }
   
   return false;
}

bool ADXSellEntry()
{
  return !( ADX_PlusDI > ADX_MinusDI ||  DI_Plus_Slope() == Up || ( DI_Plus_Slope() == Up && DI_Minus_SLope() == Down ) );
}

bool ADXBuyEntry()
{
  return !( ADX_PlusDI < ADX_MinusDI || DI_Minus_SLope() == Up || ( DI_Plus_Slope() == Down && DI_Minus_SLope() == Up ) );
}  

string MA_Entry()
{
   Refresh_MA_Value();
   if( ADXSlope() == Up )
   {
      if( ma_fast_current < ma_slow_current )
         return sell_H1;
      if( ma_fast_current > ma_slow_current )
         return buy_H1; 
    }
      
   return NULL;  
}
void PivotPoints()
{
   string CurrencyPair = Symbol();
   double Previous_High = iHigh(NULL,PIVOT_TIME_FRAME,1);
   double Previous_Low = iLow(NULL,PIVOT_TIME_FRAME,1);
   double Previous_Close = iClose(NULL,PIVOT_TIME_FRAME,1);
 
   Pivot_Point_P = (Previous_High + Previous_Low + Previous_Close)/3;

   Support_S1 = Pivot_Point_P * 2 - Previous_High;

   Support_S2 = Pivot_Point_P - (Previous_High - Previous_Low);

   Resistance_R1 = (Pivot_Point_P * 2) - Previous_Low;

   Resistance_R2 = Pivot_Point_P + (Previous_High - Previous_Low);
   
   PlusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,1);
	PlusVI2 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,2);
   MinusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,1);
   MinusVI2 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,2);
   PivotIndicator();
}

bool StochSlopeBuy()
{
  double st_main=iStochastic(NULL,FOLLOW_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,0);
  double st_signal=iStochastic(NULL,FOLLOW_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,0);
  
  return (st_main - st_signal >= ST_DIFF);
}

bool CandleOpenBuy()
{
   return Open[0] > Open[1] && Open[1] > Open[2] ;
}

bool StochSlopeSell()
{
  int st_main=iStochastic(NULL,FOLLOW_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,0);
  int st_signal=iStochastic(NULL,FOLLOW_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,0);
  
  return (st_signal - st_main >= ST_DIFF);
}

bool CandleOpenSell()
{
   return Open[0] < Open[1] && Open[1] < Open[2];
}
 
double LotsOptimized()
{
   return MA_Lots;
}

void LabelOrderStatus()
{
  string strMsg;
  if(buy || sell)
     strMsg = buy?  ("BUY_Executed at "+string(NormalizeDouble(PRICE_EXECUTED,2))+",Suggested " + string(NormalizeDouble(LTP_Suggested,2))) :(" SELL_EXECUTED at = "+string(NormalizeDouble(PRICE_EXECUTED,2))+",Suggested " + string(NormalizeDouble(LTP_Suggested,2)));
  if(!buy && !sell)
     strMsg ="BUY = "+string(buy)+", SELL = "+string(sell)+", Exit Suggested="+string(NormalizeDouble(LTP_Suggested, 2))+",Executed= " + string(NormalizeDouble(PRICE_EXECUTED,2)) ;
  
  LabelOrder(strMsg, clrHotPink);
}

void LabelOrder(string text, color clr)
{
  long x = 380;
  long y = 100;
    if(label_created_order)
      label_created_order = LabelTextColorChange(0,InpNameOrderLabel,text,clr);
   else
      label_created_order = ShowLabelOrder(text,clr, InpNameOrderLabel, x,y,CORNER_RIGHT_LOWER);
}

void LabelADX(string text, color clr)
{
    long x = 300;
    long y = 150;
    if(label_created_adx)
      label_created_adx = LabelTextColorChange(0,InpNameADXLabel,text,clr);
   else
      label_created_adx = ShowLabelOrder(text,clr, InpNameADXLabel,x ,y, CORNER_RIGHT_LOWER );
}

void LabelADXSlope(string text, color clr)
{
   long x = 350;
   long y = 200;
    if(label_created_adx_slope)
       label_created_adx_slope = LabelTextColorChange(0,InpNameADXSlopeLabel,text,clr);
   else
      label_created_adx_slope = ShowLabelOrder(text,clr, InpNameADXSlopeLabel,x ,y, CORNER_RIGHT_LOWER );
}

void LabelHour()
{
   if(isLabel_Hour_Created)
      isLabel_Hour_Created = Trend() == buy_H1? LabelTextColorChange(0,"hour_label","Follow Trend = " +PrintTrend(),clrYellow):LabelTextColorChange(0,"hour_label","Follow Trend = " +PrintTrend(),clrOrange);
   else   
      isLabel_Hour_Created = ShowHourTrendLabel(PrintTrend());  
}

void Label(string text, color clr)
{
    if(label_created)
      LabelTextColorChange(0,InpName,text,clr);
   else
      label_created = ShowLabel(text,clr);
}

void LabelPivot()
{
  long x = 150;
  long y = 100;
    if(isLabel_Pivot_Created)
       isLabel_Pivot_Created = LabelTextColorChange(0,"Label_Pivot","PivotTimeFrame="+getPivotTimeFrameString(),clrWhite);
   else
      isLabel_Pivot_Created = ShowLabelOrder("PivotTimeFrame="+getPivotTimeFrameString(),clrWhite, "Label_Pivot",x ,y, CORNER_LEFT_UPPER );

}

//+------------------------------------------------------------------+
//|SHOWLABEL_FUNC                                                    |
//+------------------------------------------------------------------+
bool ShowLabel(string text, color InpColor)
  {

//--- store the label's coordinates in the local variables
    int InpX =200;
    int InpY=50;
//--- chart window size
   long x_distance;
   long y_distance;
//--- set window size
   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance))
     {
      MessageBox("Failed to get the chart width! Error code = ",DoubleToString(GetLastError()));
      return 0;
     }
   if(!ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance))
     {
      MessageBox("Failed to get the chart height! Error code = ",DoubleToString(GetLastError()));
      return 0;
     }
     //int x=(x_distance/2);
//--- check correctness of the input parameters
   if(InpX<0 || InpX>x_distance-1 || InpY<0 || InpY>y_distance-1)
     {
      MessageBox("Error! Incorrect values of input parameters!");
      return 0;
     }
     InpX = x_distance/2;
//--- prepare initial text for the label
   text=StringConcatenate(text);
   if(sell || buy )
      logFile(text);
//--- create a text label on the chart
   if(!LabelCreate(0,InpName,0,InpX,InpY,CORNER_RIGHT_UPPER,text,InpFont,InpFontSize,
      InpColor,InpAngle,InpAnchor,InpBack,InpSelection,InpHidden,InpZOrder))
     {
      return 0;
     }
//--- redraw the chart and wait for half a second
   ChartRedraw();
   Sleep(500);
   return 1;
 } 
 
 long get_X_Distance()
 {
   //--- chart window size
   long x_distance;
//--- set window size
   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance))
     {
      Print("Failed to get the chart width! Error code = ",GetLastError());
      return 0;
     }
     
     return x_distance;
 }
 
 long get_Y_Distance()
 { 
    long y_distance;
    //--- check correctness of the input parameters
   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,y_distance))
     {
      Print("Failed to get the chart width! Error code = ",GetLastError());
      return 0;
     }
     
     return y_distance;
 }
 bool ShowLabelOrder(string text, color InpColor, string inpName,long x, long y, ENUM_BASE_CORNER Position )
  {
  
     long x_distance;
//--- set window size
   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance))
     {
      Print("Failed to get the chart width! Error code = ",GetLastError());
      return 0;
     }
     
    long y_distance;
    //--- check correctness of the input parameters
   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,y_distance))
     {
      Print("Failed to get the chart width! Error code = ",GetLastError());
      return 0;
     }
//--- check correctness of the input parameters
   if(x<0 || x>x_distance-1 || y<0 || y>y_distance-1)
     {
      Print("Error! Incorrect values of input parameters!");
      return 0;
     }
//--- prepare initial text for the label
   text=StringConcatenate(text);
//--- create a text label on the chart
   if(!LabelCreate(0,inpName,0,x,y,Position,text,InpFont,12,
      InpColor,InpAngle,InpAnchor,InpBack,InpSelection,InpHidden,InpZOrder))
     {
      return 0;
     }
//--- redraw the chart and wait for half a second
   ChartRedraw();
   Sleep(500);
   return 1;
 } 
 
  bool LabelCreate(const long              chart_ID=0,               // chart's ID
                 const string            name="Label",             // label name
                 const int               sub_window=0,             // subwindow index
                 const int               x=0,                      // X coordinate
                 const int               y=0,                      // Y coordinate
                 const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring
                 const string            text="Label",             // text
                 const string            font="Arial",             // font
                 const int               font_size=10,             // font size
                 const color             clr=clrRed,               // color
                 const double            angle=0.0,                // text slope
                 const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER, // anchor type
                 const bool              back=false,               // in the background
                 const bool              selection=false,          // highlight to move
                 const bool              hidden=true,              // hidden in the object list
                 const long              z_order=0)                // priority for mouse click
  {
//--- reset the error value
   ResetLastError();
//--- create a text label
   if(!ObjectCreate(chart_ID,name,OBJ_LABEL,sub_window,0,0))
     {
      MessageBox(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
     }
//--- set label coordinates
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
//--- set the chart's corner, relative to which point coordinates are defined
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
//--- set the text
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
//--- set text font
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
//--- set font size
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
//--- set the slope angle of the text
   ObjectSetDouble(chart_ID,name,OBJPROP_ANGLE,angle);
//--- set anchor type
   ObjectSetInteger(chart_ID,name,OBJPROP_ANCHOR,anchor);
//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
}

bool ShowHourTrendLabel(string text)
  {
//--- store the label's coordinates in the local variables
   int InpX=180;
   int InpY=50;
//--- chart window size
   long x_distance;
   long y_distance;
//--- set window size
   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance))
     {
      Print("Failed to get the chart width! Error code = ",GetLastError());
      return 0;
     }
   if(!ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance))
     {
      Print("Failed to get the chart height! Error code = ",GetLastError());
      return 0;
     }
//--- check correctness of the input parameters
   if(InpX<0 || InpX>x_distance-1 || InpY<0 || InpY>y_distance-1)
     {
      Print("Error! Incorrect values of input parameters!");
      return 0;
     }
//--- prepare initial text for the label
   text=StringConcatenate("Following Trend = "+text);
//--- create a text label on the chart
   if(!LabelCreate(0,"hour_label",0,InpX,InpY,CORNER_RIGHT_LOWER,text,InpFont,InpFontSize,
      clrAntiqueWhite,InpAngle,InpAnchor,InpBack,InpSelection,InpHidden,InpZOrder))
     {
      return 0;
     }
//--- redraw the chart and wait for half a second
   ChartRedraw();
   Sleep(500);
   return 1;
 } 
  
//+------------------------------------------------------------------+
//| Change the object text                                           |
//+------------------------------------------------------------------+
bool LabelTextColorChange(const long   chart_ID=0,   // chart's ID
                     const string name="Label", // object name
                     const string text="Text",
                     const color  clr= clrAntiqueWhite)  // text
  {
//--- reset the error value
   ResetLastError();
//--- change object text
   if(!ObjectSetString(chart_ID,name,OBJPROP_TEXT,text))
     {
      MessageBox(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }     
     //--- set color
   ;
      if(!ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr))
     {
      MessageBox(__FUNCTION__,
            ": failed to change the color! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
  
  void StopLossIndicator()
  {
     if(HLineCreate(0,InpNameSL,0,sT,clrOrange,STYLE_DASHDOTDOT,3,InpBack, 
      InpSelection,InpHidden,InpZOrder)) 
     { 
      //return; 
     }
     else
     {
        if(!HLineMove(0,InpNameSL,sT))
           return;
     } 
  }
  
  void PivotIndicator() 
  { 
      //--- create a horizontal line     
      if(!SHOW_INDICATOR)
         return;

      LabelPivot();
//--- create a horizontal line 
   if(HLineCreate(0,InpNameP,0,Pivot_Point_P,clrGreenYellow,STYLE_SOLID,InpWidth,InpBack, 
      InpSelection,InpHidden,InpZOrder)) 
     { 
      //return; 
     }
     else
     {
        if(!HLineMove(0,InpNameP,Pivot_Point_P))
           return;
     }   
     
     //--- create a horizontal line 
   if(HLineCreate(0,InpNameS1,0,Support_S1,InpColorS,InpStyle,2,InpBack, 
      InpSelection,InpHidden,InpZOrder)) 
     { 
      //return; 
     }
     else
     {
        if(!HLineMove(0,InpNameS1,Support_S1))
           return;
     }
     
     //--- create a horizontal line 
   if(HLineCreate(0,InpNameS2,0,Support_S2,InpColorS,InpStyle,3,InpBack, 
      InpSelection,InpHidden,InpZOrder)) 
     { 
      //return; 
     }
   else
    {
       if(!HLineMove(0,InpNameS2,Support_S2))
          return;
    }
     
     //--- create a horizontal line 
   if( HLineCreate(0,InpNameR1,0,Resistance_R1,clrYellow,InpStyle,2,InpBack, 
      InpSelection,InpHidden,InpZOrder)) 
     { 
      //return; 
     }
   else
   {
      if(!HLineMove(0,InpNameR1,Resistance_R1))
         return;
   }
     
     //--- create a horizontal line 
   if( HLineCreate(0,InpNameR2,0,Resistance_R2,clrYellow,InpStyle,3,InpBack, 
      InpSelection,InpHidden,InpZOrder)) 
     { 
      //return; 
     }
   else
    {
       if(!HLineMove(0,InpNameR2,Resistance_R2))
          return;
    }     
//--- redraw the chart and wait for 1 second 
   ChartRedraw(); 
   Sleep(1000); 
//--- now, move the line 
     // if(!HLineMove(0,InpName,price[p])) 
       //  return; 
      //--- check if the script's operation has been forcefully disabled 
      if(IsStopped()) 
         return; 
  }

  int ShowMessage(string msg ,string strategy)
  {
     return MessageBox( 
        msg,             // message text 
        strategy,     // box header 
        MB_OKCANCEL           // defines set of buttons in the box 
   );
  }
  
  int ErrorMessage(string msg)
  {
     return MessageBox( 
        Symbol()+","+msg,             // message text 
        "Follow Hourly Trend",     // box header 
        MB_ICONWARNING           // defines set of buttons in the box 
   );
  }
  
    string getStrHeader(string strH)
  {
     string space1 = "";
     int n1 = 50;
     for(int i=0;i< n1;i++)
     {
       space1 = space1+" ";
     }
     strH = space1+strH;
     
     return strH;
  }
  
  double calculateLTP()
  {     
     return NormalizeDouble((Close[1] + Open[1])/2, 2);
  }
  
void getCrossOverCandleLowValue()
{
   for(int i=0; i<Bars ; i++ )
   {
      double t_PlusVI1 = iCustom(Symbol(),0,"vortex-indicator",VI_Length,MODE_PLUSVI,i);
      double t_PlusVI2 = iCustom(Symbol(),0,"vortex-indicator",VI_Length,MODE_PLUSVI,i+1);
      double t_MinusVI1 = iCustom(Symbol(),0,"vortex-indicator",VI_Length,MODE_MINUSVI,i);
      double t_MinusVI2 = iCustom(Symbol(),0,"vortex-indicator",VI_Length,MODE_MINUSVI,i+1);
      
      if(t_PlusVI2 > t_MinusVI2 && t_PlusVI1 < t_MinusVI1 )
      {
         lowVal =  iLow(Symbol(),FOLLOW_CHART_TIME_FRAME, i);
         break;
      }
   }
}

void getMACrossOverCandleLowValue()
{
   for(int i=0; i<Bars ; i++ )
   {  
       double ma_plus_current=NormalizeDouble(iMA(NULL,0,MA_MovingPeriod_short,MA_MovingShift_short,MODE_LWMA,PRICE_CLOSE,i),2);
       double ma_minus_current=NormalizeDouble(iMA(NULL,0,MA_MovingPeriod_long,MA_MovingShift_long,MODE_LWMA,PRICE_CLOSE,i),2);
       double ma_plus_prev=NormalizeDouble(iMA(NULL,0,MA_MovingPeriod_short,MA_MovingShift_short,MODE_LWMA,PRICE_CLOSE,i+1),2);
       double ma_minus_prev=NormalizeDouble(iMA(NULL,0,MA_MovingPeriod_long,MA_MovingShift_long,MODE_LWMA,PRICE_CLOSE,i+1),2);
       if(ma_plus_prev > ma_minus_prev && ma_plus_current < ma_minus_current )
       {
           lowVal = iLow(Symbol(),FOLLOW_CHART_TIME_FRAME, i);
           break;
       }
   }
}

void getMACrossOverCandleHighValue()
{

   for(int i=0; i<Bars ; i++ )
   {  
       double ma_plus_current=NormalizeDouble(iMA(NULL,0,MA_MovingPeriod_short,MA_MovingShift_short,MODE_LWMA,PRICE_CLOSE,i),2);
       double ma_minus_current=NormalizeDouble(iMA(NULL,0,MA_MovingPeriod_long,MA_MovingShift_long,MODE_LWMA,PRICE_CLOSE,i),2);
       double ma_plus_prev=NormalizeDouble(iMA(NULL,0,MA_MovingPeriod_short,MA_MovingShift_short,MODE_LWMA,PRICE_CLOSE,i+1),2);
       double ma_minus_prev=NormalizeDouble(iMA(NULL,0,MA_MovingPeriod_long,MA_MovingShift_long,MODE_LWMA,PRICE_CLOSE,i+1),2);
       if(ma_plus_prev < ma_minus_prev && ma_plus_current > ma_minus_current )
       {
           highVal = iHigh(Symbol(),FOLLOW_CHART_TIME_FRAME, i);
           break;
       }
   }
}

void getCrossOverCandleHighValue()
{
   for(int i=0; i<Bars ; i++ )
   {
      double t_PlusVI1 = iCustom(Symbol(),0,"vortex-indicator",VI_Length,MODE_PLUSVI,i);
      double t_PlusVI2 = iCustom(Symbol(),0,"vortex-indicator",VI_Length,MODE_PLUSVI,i+1);
      double t_MinusVI1 = iCustom(Symbol(),0,"vortex-indicator",VI_Length,MODE_MINUSVI,i);
      double t_MinusVI2 = iCustom(Symbol(),0,"vortex-indicator",VI_Length,MODE_MINUSVI,i+1);
      
      if(t_PlusVI2 < t_MinusVI2 && t_PlusVI1 > t_MinusVI1 )
      {
         highVal =  iHigh(Symbol(),FOLLOW_CHART_TIME_FRAME, i);
         break;
      }
   }
}
 
  string space()
  {
     string space;
     int n = 270;
     for(int i=0;i< n;i++)
     {
       space = space+" ";
     }
     return space;
  }
  
  void PrintCommentHeader(string header,string strC)
  {    
    Comment( "\n*****MADE BY ROOPSIKHA*****"+"\n"+getStrHeader(header)+"\n"+strC);
  }
  
 /* string DisplayInputValues()
  {  
     string str;
     str = "\n\nADX_VeryStrongTrend_BTW_75_100     = " +string(ADX_VeryStrongTrend_BTW_75_100)+
           "\n\nADX_StrongTrend_BTW_50_75            = "+string( ADX_StrongTrend_BTW_50_75)+
           "\n\nADX_MediumTrend_BTW_40_50            = "+string(ADX_MediumTrend_BTW_40_50)+
           "\n\nADX_WeakTrend_BTW_25_40              = "+string(ADX_WeakTrend_BTW_25_40)+
           "\n\nADX_VeryWeakTrend_Below_25           = "+string(ADX_VeryWeakTrend_Below_25);
     return str;
  }*/
  string DisplayOnScreen()
  {
     RefreshADXValue();
     int Stochastic_Main=iStochastic(NULL,PERIOD_H1,5,3,3,MODE_EMA,0,MODE_MAIN,0);
     int Stochastic_Signal=iStochastic(NULL,PERIOD_H1,5,3,3,MODE_EMA,0,MODE_SIGNAL,0);
     //--- get Moving Average 
     ma_fast_current=NormalizeDouble(iMA(NULL,0,MA_MovingPeriod_short,MA_MovingShift_short,MODE_LWMA,PRICE_CLOSE,0),2);
     ma_slow_current=NormalizeDouble(iMA(NULL,0,MA_MovingPeriod_long,MA_MovingShift_long,MODE_LWMA,PRICE_CLOSE,0),2);
     ma_fast_prev=NormalizeDouble(iMA(NULL,0,MA_MovingPeriod_short,MA_MovingShift_short,MODE_LWMA,PRICE_CLOSE,1),2);
     ma_slow_prev=NormalizeDouble(iMA(NULL,0,MA_MovingPeriod_long,MA_MovingShift_long,MODE_LWMA,PRICE_CLOSE,1),2);
     double MA_Slow=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_Slow_MovingPeriod,MA_MovingShift_long,MODE_SMA,PRICE_OPEN,0);
     double diff_candle = NormalizeDouble(Open[0],2)- NormalizeDouble(Open[1],2);
     int st_diff = Stochastic_Main-Stochastic_Signal;
     
     string strC = NULL;

     LTP=calculateLTP();

     /*if( -10 < st_diff && st_diff> 10)
     {
       strC= space()+"ST_DIFF            = "+ string(st_diff);
     }*/
      
     if(!SHOW_VALUE)
       return "";
      
      strC = strC+       
  "\n\n"+space()+"LTP                              = "+ string(NormalizeDouble(LTP,2))+
  "\n\n"+space()+"PlusVI1                         = "+ string(NormalizeDouble(PlusVI1,2))+
  "\n\n"+space()+"MinusVI1                        = "+ string(NormalizeDouble(MinusVI1,2))+
  "\n\n"+space()+"MA_Slow                         = "+  string(NormalizeDouble(MA_Slow,2))+
   "\n\n"+space()+"LowVal                        = "+ string(NormalizeDouble(lowVal,2))+
   "\n\n"+space()+"HighVal                        = "+ string(NormalizeDouble(highVal,2))+
   "\n\n"+space()+"MA Diff                        = "+ string(NormalizeDouble(ma_fast_current - ma_slow_current,2));
                
     if(  -0.1 < diff_candle < 0.1 )
     strC = strC+"\n\n"+space()+"Diff_Candle                = "+ string(diff_candle);
    
    return strC;
  }
  
  void ShowADXValue(bool show)
  {
    string strText = 
      " ADX = "+ string(NormalizeDouble(ADX,2))+       
      ", +DI  = "+ string(NormalizeDouble(ADX_PlusDI,2)) +
      ", -DI  = "+ string(NormalizeDouble(ADX_MinusDI,2)) ;
      
    string strTextSlope =
    " Slope, ADX = "+ ADXSlope() +
    ", (+)DI = "+ DI_Plus_Slope() +    
    ", (-)DI = "+ DI_Minus_SLope();
    
   if(show){         
      LabelADX( strText, clrMagenta );
      LabelADXSlope( strTextSlope , clrMediumSpringGreen);
      }
  }
  
void RefreshADXValue()
{
   ADX_2=iADX(NULL,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,2);
   ADX_1=iADX(NULL,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,1);
   ADX=iADX(NULL,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,0);
   
   ADX_PlusDI=iADX(NULL,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_PLUSDI,0);
   ADX_MinusDI=iADX(NULL,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MINUSDI,0);
   
   ADX_PlusDI_1=iADX(NULL,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_PLUSDI,1);
   ADX_MinusDI_1=iADX(NULL,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MINUSDI,1);
   
   ADX_PlusDI_2=iADX(NULL,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_PLUSDI,2);
   ADX_MinusDI_2=iADX(NULL,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MINUSDI,2);
}

void Refresh_MA_Value()
{
   ma_fast_current=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_MovingPeriod_short,MA_MovingShift_short,MODE_EMA,PRICE_OPEN,0);
   ma_slow_current=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_MovingPeriod_long,MA_MovingShift_long,MODE_EMA,PRICE_OPEN,0);
   ma_fast_prev=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_MovingPeriod_short,MA_MovingShift_short,MODE_EMA,PRICE_OPEN,1);
   ma_slow_prev=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_MovingPeriod_long,MA_MovingShift_long,MODE_EMA,PRICE_OPEN,1);
}

string ADXSlope()
{
   if(ADX > ADX_1 /*&& ADX_1 > ADX_2*/)
      return Up;
   else if( ADX < ADX_1 /*&& ADX_1 < ADX_2*/)
      return Down;
   else 
      return "NEUTRAL";         
}

string DI_Minus_SLope()
{
   if(ADX_MinusDI > ADX_MinusDI_1 && ADX_MinusDI_1 > ADX_MinusDI_2)
      return Up;
   else if(ADX_MinusDI < ADX_MinusDI_1 /*&& ADX_MinusDI_1 < ADX_MinusDI_2*/)
      return Down;
   else 
      return "NEUTRAL";      
}

string DI_Plus_Slope()
{
   if(ADX_PlusDI > ADX_PlusDI_1 && ADX_PlusDI_1 > ADX_PlusDI_2)
      return Up;
   else if(ADX_PlusDI < ADX_PlusDI_1 /*&& ADX_PlusDI_1 < ADX_PlusDI_2*/)
      return Down;
   else 
     return "NEUTRAL";      
}

string PrintTrend()
{
   double MA_Slow=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_Slow_MovingPeriod,0,MODE_SMA,PRICE_OPEN,0);
   string trend = NULL;
   if( Close[0] > MA_Slow )
   {
     trend = buy_H1;
   }
   else if( Close[0] < MA_Slow )
   {
     trend = sell_H1;
   }
  
   if(trend == NULL)
      return "Searching("+string(MA_Slow)+")";
   else 
     return trend;   
}

string Trend()
{
   string trend = NULL;
   double MA_Slow=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_Slow_MovingPeriod,0,MODE_SMA,PRICE_OPEN,0);
   
   if( Close[0] > MA_Slow )
   {
     trend = buy_H1;
   }
   else if( Close[0] < MA_Slow )
   {
     trend = sell_H1;
   }
   if(trend == NULL)
      return "";
   else 
     return trend;   
}

string ADXTrend()
{
    ADX=NormalizeDouble(iADX(NULL,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,0),0);
    string strAlert;
    //*********entry*****************
    if( /*buy == 0 && sell == 0 &&*/ OrdersTotal() == 0 )
    {
       if(ADX > ADX_VeryStrongTrend_BTW_75_100 && ADX <= 100)
       {
           strAlert = "Very Strong Trend,ADX = "+string(ADX);
           //return strAlert;  
       }
       else if(ADX > ADX_StrongTrend_BTW_50_75 && ADX <= ADX_VeryStrongTrend_BTW_75_100)
       {
           strAlert = "Strong Trend,ADX = "+string(ADX);
           //return strAlert;
       }
       else if(ADX > ADX_MediumTrend_BTW_40_50 && ADX <= ADX_StrongTrend_BTW_50_75)
       {
           strAlert = "Medium Trend,ADX = " + string(ADX);
           //return strAlert;
       }
       else if(ADX > ADX_WeakTrend_BTW_25_40 && ADX <= ADX_MediumTrend_BTW_40_50)//use stocastic for exit and enter
       {
           strAlert = "Weak Trend,ADX = " + string(ADX);
           //return strAlert;
       }
       else if(ADX <= ADX_VeryWeakTrend_Below_25 && ADX > 0)
       {
           strAlert = "Very Weak Trend,ADX =" + string(ADX);       
           //return strAlert;
       }
       return strAlert+"("+ADXSlope()+")";
     }
    return NULL;
 }
 
 void Check_RES_Val(int res)
 {
     if(res == 1)
       Print("Order Placed");
     else
        Print("Error Placing Order");
 }
 
 void CheckConnection()
 {
    if(!IsConnected()) 
    { 
        ErrorMessage("No connection!"); 
        return; 
    } 
 }
 
 void CreateChart()
 {
    //--- Get the handle of the current chart 
   long handle=ChartID();
   PivotIndicator();
   if(handle>0) // If it succeeded, additionally customize 
     { 
      //--- Disable autoscroll 
      ChartSetInteger(handle,CHART_AUTOSCROLL,RefreshGraph); 
      //--- Set the indent of the right border of the chart 
      ChartSetInteger(handle,CHART_SHIFT,true); 
      //--- Display as candlesticks 
      ChartSetInteger(handle,CHART_MODE,CHART_BARS); 
      //--- Scroll by 100 bars from the beginning of history 
      ChartNavigate(handle,CHART_CURRENT_POS,100); 
      //--- Set the tick volume display mode 
      ChartSetInteger(handle,CHART_SHOW_VOLUMES,CHART_VOLUME_TICK);
     }
 }
 
 //+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="HLine", // line name 
               double       price=0)      // line price 
  { 
//--- if the line price is not set, move it to the current Bid price level 
   if(!price) 
      return false;
      //price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- reset the error value 
   ResetLastError(); 
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to move the horizontal line! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=0,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=true,    // highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  { 
//--- if the price is not set, set it at the current Bid price level 
   if(!price) 
      return false;
      
      //price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- reset the error value 
   ResetLastError(); 
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create a horizontal line! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection); 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection); 
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden); 
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order); 
//--- successful execution 
   return(true); 
  }
 
void Buy(double Lots)
  {
       RefreshRates();
       int res = OrderSend(Symbol(),OP_BUY,Lots,Ask,MA_Slippage,LTP-stopLoss_percent,LTP+takeProfit_percent,"buy",MAGICMA,0,clrBlue);
       if(res == 1)
       {
         buy = true;
         buyVar = True;
       }
       else{
         //PrintComment(GetLastError());
         return;
       }
  }
  
void Sell(double Lots)
{
  RefreshRates();
  int res = OrderSend(Symbol(),OP_SELL,Lots,Bid,MA_Slippage,LTP+stopLoss_percent,LTP-takeProfit_percent,"sell",MAGICMA,0,clrRed);
  if(res == 1 && res == 0) 
  {
     sell = true;
     sellVar = true;
  }
  else{
    //PrintComment(GetLastError());
    return;
  }
}

void CloseOrder()
  {
     for(int i=0;i<OrdersTotal();i++)
             {
                 if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
                 if(OrderMagicNumber()!=MAGICMA || OrderSymbol()!=Symbol()) continue;
                 //--- check order type 
                 CloseOrder(OrderType()); 
              } 
  }
void CloseOrder(int OrderType)
{
    //--- check order type 
    if(OrderType==OP_SELL)
    {
       int res = OrderClose(OrderTicket(),OrderLots(),Ask,3,clrYellow);
       if(res != 1)
       {
          Print("OrderClose error ",GetLastError());
       }
       else if( 1)
       {
         sell = false;
         sellVar = false;             
       }
    }
    if(OrderType==OP_BUY)
    {
       int res = OrderClose(OrderTicket(),OrderLots(),Bid,3,clrYellow);
       if(res != 1)
       {
          Print("OrderClose error ",GetLastError());
       }
       else if(res == 1)
       {
         buy = false;
         buyVar = false ;                         
       }
    }
}
//+------------------------------------------------------------------+
