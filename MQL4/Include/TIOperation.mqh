//+------------------------------------------------------------------+
//|                                                  TIOperation.mqh |
//|                                  Copyright 2018, Roopsikha Yadav |
//|                              https://github.com/roopsikhayadav28 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Roopsikha Yadav"
#property link      "https://github.com/roopsikhayadav28"
#property strict
#include <SQLOperations.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+

#define  MODE_PLUSVI            0
#define  MODE_MINUSVI           1

input ENUM_TIMEFRAMES FOLLOW_CHART_TIME_FRAME=PERIOD_M15;
input ENUM_TIMEFRAMES FOLLOW_STOCASHTIC_TIME_FRAME = PERIOD_M15;
input ENUM_TIMEFRAMES FOLLOW_ADX_TIME_FRAME = PERIOD_M15;
input ENUM_APPLIED_PRICE applied_price = PRICE_CLOSE;
input string XXXXXXXXXXXXXXXXC = "*******MACD**********";
input int FILTER = 9;
input string XXXXXXXXXXXXXXXXA = "**********MA************";
input ENUM_APPLIED_PRICE   PRICE_ACTION = PRICE_CLOSE;
input int                  MA_FAST  =9;
input int                  MA_SLOW  =12;
input ENUM_MA_METHOD       MA_METHOD = MODE_LWMA;
input int    MA_MovingShift_short  = 0;
input int    MA_MovingShift_long = 0;
input int VI_Length = 14;
input string XXXXXXXXXXXXXXXXB = "**********************";
input string APPLY_TEMPLATE = "Online_template";


double   Pivot_Point_P;
double   Support_S1;
double   Support_S2;
double   Resistance_R1;
double   Resistance_R2;   

double   VI_EnterTrendVal= 1.10;
double   VI_DownTrendVal= 0.90;


string strHeader= NULL,msgHeader = NULL;

string buy_H1= "Buy",sell_H1="Sell", msg, overBought = "OverBought", overSold = "OverSold",Slope_Up = "Up" , Slope_Down = "Down" , Slope_Neutral = "Neutral" , Up = "Up", Down = "Down";

enum Enum_Trend_selection
  { 
     OverBought,
     OverSold,
     All,
     EntryBuy,
     EntrySell
  };
  
input Enum_Trend_selection TREND_SELECTION = All;
string getTrendSelectionString()
{
   switch(TREND_SELECTION)
   {
    case All:
      return "All";
    case EntryBuy:
      return "EntryBuy";
    case EntrySell:
      return "EntrySell";
    case OverSold:
      return "OverSold";
    case OverBought:
      return "OverBought";
    
    default:
       return "ERROR";
   }    
}
enum ENUM_ENTRY_TYPE
{
   CROSS,
   PointOne,
   MACDma
};

input ENUM_ENTRY_TYPE ENTRY_TYPE= MACDma;

bool BuyEntry(string sym)
{
   if(ENTRY_TYPE == MACDma   )
   {
      return true;
   }
   return false;
}

bool SellEntry(string sym) 
{  

  if(ENTRY_TYPE == MACDma   )
   {
      return true;
   }
   return false;
}


/*bool VortexCrossOverBuyEntry(string CurrencyPair)
{
   double PlusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,0);
   double MinusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,0);
   
   if( (ENTRY_TYPE == CROSS) && (PlusVI2 < MinusVI2 && PlusVI1 > MinusVI1 ) && ADXBuyEntry(CurrencyPair) )
   {
      return true;
   }
 
   if( (ENTRY_TYPE == PointOne) && (PlusVI1 > VI_EnterTrendVal) && ADXBuyEntry(CurrencyPair) )
   {
      return true;
   }
   
   if( ENTRY_TYPE == MA && ( MA_Entry(CurrencyPair) == buy_H1 && ADXBuyEntry(CurrencyPair) ) && ( MinusVI1 < PlusVI1 ) )
   {
      getMACrossOverCandleHighValue(CurrencyPair);
      return true;
   } 
   return false;
}



bool VortexCrossOverSellEntry(string CurrencyPair) 
{  
   double PlusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,0);
   double MinusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,0);
   
   if( ENTRY_TYPE == CROSS && PlusVI2 > MinusVI2 && PlusVI1 < MinusVI1 && ADXSellEntry(CurrencyPair) )
   {
      return true;
   }
   if(ENTRY_TYPE == PointOne && MinusVI1 > VI_EnterTrendVal && ADXSellEntry(CurrencyPair) )
   {
      return true;
   }
   if( ENTRY_TYPE == MA && ( MA_Entry(CurrencyPair) == sell_H1 && ADXSellEntry(CurrencyPair) ) && ( MinusVI1 > PlusVI1 ) )
   {
      getMACrossOverCandleLowValue(CurrencyPair);
      return true;
   }
   return false;
}*/

bool ADXSellEntry(string CurrencyPair)
{
   double ADX_MinusDI=iADX(CurrencyPair,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MINUSDI,0);
   double ADX_PlusDI=iADX(CurrencyPair,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_PLUSDI,0);
   
  return !( ADX_PlusDI > ADX_MinusDI || DI_Plus_Slope(CurrencyPair) == Up || ( DI_Plus_Slope(CurrencyPair) == Up && DI_Minus_SLope(CurrencyPair) == Down ) );
}

bool ADXBuyEntry(string CurrencyPair)
{
   double ADX_MinusDI=iADX(CurrencyPair,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MINUSDI,0);
   double ADX_PlusDI=iADX(CurrencyPair,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_PLUSDI,0);
   
  return !( ADX_PlusDI < ADX_MinusDI || DI_Minus_SLope(CurrencyPair) == Up || ( DI_Plus_Slope(CurrencyPair) == Down && DI_Minus_SLope(CurrencyPair) == Up ));
}

string MA_Entry(string CurrencyPair)
{
   double ma_fast_current=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_FAST,MA_MovingShift_short,MA_METHOD,PRICE_ACTION,0);
   double ma_slow_current=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_SLOW,MA_MovingShift_long,MA_METHOD,PRICE_ACTION,0);

   if( /*ma_slow_prev > ma_fast_prev &*/ ma_fast_current > ma_slow_current )
      return buy_H1;
   if( /*ma_fast_prev > ma_slow_prev &&*/ ma_slow_current > ma_fast_current )
      return sell_H1;
      
   return NULL;  
}

double getMACrossOverCandleLowValue(string CurrencyPair)
{
   double lowVal = 0.0;
   for(int i=0; i<Bars ; i++ )
   {  
       double ma_plus_current=NormalizeDouble(iMA(CurrencyPair,0,MA_FAST,MA_MovingShift_short,MA_METHOD,PRICE_CLOSE,i),2);
       double ma_minus_current=NormalizeDouble(iMA(CurrencyPair,0,MA_SLOW,MA_MovingShift_long,MA_METHOD,PRICE_CLOSE,i),2);
       double ma_plus_prev=NormalizeDouble(iMA(CurrencyPair,0,MA_FAST,MA_MovingShift_short,MA_METHOD,PRICE_CLOSE,i+1),2);
       double ma_minus_prev=NormalizeDouble(iMA(CurrencyPair,0,MA_SLOW,MA_MovingShift_long,MA_METHOD,PRICE_CLOSE,i+1),2);
       if(ma_plus_prev > ma_minus_prev && ma_plus_current < ma_minus_current )
       {
           lowVal = iLow(CurrencyPair,FOLLOW_CHART_TIME_FRAME, i);
           break;
       }
   }
   
   return lowVal;
}

double getMACrossOverCandleHighValue(string CurrencyPair)
{
   double highVal = 0.0;
   for(int i=0; i<Bars ; i++ )
   {  
       double ma_plus_current=NormalizeDouble(iMA(CurrencyPair,0,MA_FAST,MA_MovingShift_short,MA_METHOD,PRICE_CLOSE,i),2);
       double ma_minus_current=NormalizeDouble(iMA(CurrencyPair,0,MA_SLOW,MA_MovingShift_long,MA_METHOD,PRICE_CLOSE,i),2);
       double ma_plus_prev=NormalizeDouble(iMA(CurrencyPair,0,MA_FAST,MA_MovingShift_short,MA_METHOD,PRICE_CLOSE,i+1),2);
       double ma_minus_prev=NormalizeDouble(iMA(CurrencyPair,0,MA_SLOW,MA_MovingShift_long,MA_METHOD,PRICE_CLOSE,i+1),2);
       if(ma_plus_prev < ma_minus_prev && ma_plus_current > ma_minus_current )
       {
           highVal = iHigh(CurrencyPair,FOLLOW_CHART_TIME_FRAME, i);
           break;
       }
   }
   return highVal;
}

string Momentum(string CurrencyPair)
{
    string Mslope = ",NEUTRAL",MAslope = ",NEUTRAL";
    double mo = iMomentum(CurrencyPair,FOLLOW_CHART_TIME_FRAME,12,PRICE_CLOSE,0);
    double ma = iMA(CurrencyPair,FOLLOW_CHART_TIME_FRAME,14,0,MODE_EMA,PRICE_WEIGHTED,0);
    MAslope = ( ma > mo)? " :Buy" : " :Sell";
       
    Mslope = ( mo > iMomentum(CurrencyPair,FOLLOW_CHART_TIME_FRAME,12,PRICE_CLOSE,1) )? ", UP":", DOWN";
    return DoubleToStr(mo,2)+Mslope+MAslope;
}

bool CandleOpenBuy(string CurrencyPair)
{
   return getOpenPrice(CurrencyPair,0) > getOpenPrice(CurrencyPair, 1) && getOpenPrice(CurrencyPair,1) > getOpenPrice(CurrencyPair,2) ;
}

bool CandleOpenSell(string CurrencyPair)
{
   return getOpenPrice(CurrencyPair,0) < getOpenPrice(CurrencyPair,1) && getOpenPrice(CurrencyPair,1) < getOpenPrice(CurrencyPair,2);
}
  
bool checkFilter( string symbol,string str, string entry)
{
  string st_status  = getCustomString(getStochasticStatus(symbol));
  if( ( entry == buy_H1 ) && (TREND_SELECTION == EntryBuy ) )
  {
     /*Alert*/( Modify( str) );
     /*Alert*/( Modify( msgHeader) );
     PlaySound("\\Files\\inform.wav");
     return true;
  }
  if( ( entry == sell_H1 ) && ( TREND_SELECTION == EntrySell ) )
  {
     /*Alert*/( Modify( str) );
     /*Alert*/( Modify( msgHeader) );
     PlaySound("\\Files\\inform.wav");
     return true;
  }
  
  if( TREND_SELECTION == All )
  {
     /*Alert*/( Modify( str) );
     /*Alert*/( Modify( msgHeader) );
     PlaySound("\\Files\\inform.wav");
     return true;
  }
  
  if(st_status != NULL )
  {
     if( st_status == overBought  && TREND_SELECTION == OverBought)
     {
        Modify( str);
        //*Alert*/*/( Modify( msgHeader) );
        PlaySound("\\Files\\inform.wav");
        return true;
     }
     if( st_status == overSold && TREND_SELECTION == OverSold )
     {
        /*Alert*/( Modify( str) );
        /*Alert*/( Modify( msgHeader) );
        PlaySound("\\Files\\inform.wav");
        return true;
     }
     ///*if( st_status == Up && TREND_SELECTION == Buy )
     //{
     //   /*Alert*/( Modify( str) );
     //   /*Alert*/( Modify( msgHeader) );
     //   PlaySound("\\Files\\inform.wav");
     //   return true;
     //}
     //if( st_status == Down && TREND_SELECTION == Sell )
     //{
     //   /*Alert*/( Modify( str) );
     //   /*Alert*/( Modify( msgHeader) );
     //   PlaySound("\\Files\\inform.wav");
     //   return true;
     //}*/
     //return false;
  }
     return false;
}  

double CheckLTP_H(double highVal, double LTP_High )
{
  double LTP = ( LTP_High == 0 || ENTRY_TYPE == CROSS )? highVal: LTP_High;
  return LTP;
}

double CheckLTP_L(double lowVal, double LTP_Low )
{
  double   LTP = ( LTP_Low == 0 || ENTRY_TYPE == CROSS )? lowVal: LTP_Low;
  return LTP;
}

  
void checkGraph()
{
  string sym[1][2],symbol;
  long chartID;
  bool result;
  if(CheckGraphStatusFromOrderBook(sym))
  {
    for(int i = 0 ; i< ArrayRange(sym,0); i++)
    {
      symbol = sym[i][0];
      chartID = sym[i][1];
      ChartWindowsIsVisible(result,chartID,0);   
      if(!result)
      {
         ChartOpen(symbol,FOLLOW_CHART_TIME_FRAME);
         Alert(symbol + " Symbol period ReOpened");
      }
    }
  }
}
  
void CheckChartOpen()
{
   string openSym[1][1];
    if( ReadSymbolFromOrderBook(openSym) )
    {
       if(ArrayRange(openSym,0) > 0)
       {
          double countAfter = ArrayRange(openSym,0);
          for( int i = 0; i< countAfter; i++)
             CreateChart( openSym[i][0] ); 
       }       
    }
    ArrayFree(openSym);
}

void CreateChart(string symbol)
 {
    bool result;
    long chartID = ChartOpen(symbol,FOLLOW_CHART_TIME_FRAME);
    //Sleep(1000);
    long chartOfflineID = ChartOpen( symbol,PERIOD_M2 );

    ChartWindowsIsVisible(result,chartID,0);
   
    if(result){
          //if(!ChartApplyTemplate(chartID,Symbol()+"_renko_template"))
          {
             //Alert("Applying Default Template");
            // ChartApplyTemplate(chartID, "renko_offline_template");
          }
             
          ChartApplyTemplate(chartOfflineID,APPLY_TEMPLATE);
          SetGraphStatus(symbol, chartID);
          Alert(symbol + " Symbol period set");
    }
 }
 
 //+------------------------------------------------------------------+ 
//| The function defines if the current chart window or subwindow    | 
//| is visible.                                                      | 
//+------------------------------------------------------------------+ 
bool ChartWindowsIsVisible(bool &result,const long chart_ID=0,const int sub_window=0) 
  { 
//--- prepare the variable to get the property value 
   long value; 
//--- reset the error value 
   ResetLastError(); 
//--- receive the property value 
   if(!ChartGetInteger(chart_ID,CHART_WINDOW_IS_VISIBLE,sub_window,value)) 
     { 
      //--- display the error message in Experts journal 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
     } 
//--- store the value of the chart property in memory 
   result=value; 
//--- successful execution 
   return(true); 
  }
 


//+--------------------------------------------------------------------------+ 
//| The function gets the total number of chart windows including indicator  | 
//| subwindows.                                                              | 
//+--------------------------------------------------------------------------+ 
int ChartWindowsTotal(const long chart_ID=0) 
  { 
//--- prepare the variable to get the property value 
   long result=-1; 
//--- reset the error value 
   ResetLastError(); 
//--- receive the property value 
   if(!ChartGetInteger(chart_ID,CHART_WINDOWS_TOTAL,0,result)) 
     { 
      //--- display the error message in Experts journal 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
     } 
//--- return the value of the chart property 
   return((int)result); 
  }
 


 
string getCustomString(string str)
{
   string to_split = str;
   string sep=" ";                // A separator as a character
   ushort u_sep;                  // The code of the separator character
   string result[];               // An array to get strings
   //--- Get the separator code
   u_sep=StringGetCharacter(sep,0);
   //--- Split the string to substrings
   int k=StringSplit(to_split,u_sep,result);
   if(k >0)
   {
     return result[0];
   }
   
   return NULL;
}

string Modify(string str)
{
   string to_split = str;
   string sep="|";                // A separator as a character
   ushort u_sep;                  // The code of the separator character
   string result[];               // An array to get strings
   int space = 20;
   //--- Get the separator code
   u_sep=StringGetCharacter(sep,0);
   //--- Split the string to substrings
   int k=StringSplit(to_split,u_sep,result);

   //--- Now output all obtained strings

   if(k>0)
     {
       str = NULL;
      for(int i=0;i<k;i++)
        {
           int length = StringLen(result[i]);
           for(int x=0; x < space-length ; x++)
                result[i] = result[i] + " ";
           str = str + result[i] + " | ";     
        }
     }
       
   return str;  
}

int OpenFile(string symbol)
{
    int file_h = 0;
    string inpFileName=symbol+"_Signal.text";      // File name
    PrintFormat("%s file exists!",inpFileName);
    file_h=FileOpen(inpFileName,FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_IS_TEXT|FILE_EXISTS);
    if(file_h!= INVALID_HANDLE)
       PrintFormat("%s file created!",inpFileName);
    
    CloseFile(file_h);  
    return file_h;     
}

void CloseFile(int file_h)
{
   if(file_h != INVALID_HANDLE)
   {
       //--- close the file 
   FileClose(file_h); 
   //PrintFormat("Data is written, %s file is closed",InpFileName); 
   }
}

string getStochasticStatus( string CurrencyPair)
{
   double Stochastic_Main=iStochastic(CurrencyPair,FOLLOW_STOCASHTIC_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,0);
   double Stochastic_Signal=iStochastic(CurrencyPair,FOLLOW_STOCASHTIC_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,0);
   
   double Stochastic_Main_1=iStochastic(CurrencyPair,FOLLOW_STOCASHTIC_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,1);
   double Stochastic_Signal_1=iStochastic(CurrencyPair,FOLLOW_STOCASHTIC_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,1);
   
   if( Stochastic_Main > 80 && Stochastic_Signal > 80 )
   {
      return overBought;
   }
   else if( Stochastic_Main < 20 && Stochastic_Signal < 20 )
   {
      return overSold;
   }
   else if( Stochastic_Main > Stochastic_Main_1 && Stochastic_Signal > Stochastic_Signal_1 )
   {
     return Slope_Up;
   }
   else if( Stochastic_Main < Stochastic_Main_1 && Stochastic_Signal < Stochastic_Signal_1 )
   {
     return Slope_Down;
   }
   else
   {
     return Slope_Neutral;
   }
}

string getStochasticStatus(long &dbConnectSQLId, string CurrencyPair)
{
   double Stochastic_Main=iStochastic(CurrencyPair,FOLLOW_STOCASHTIC_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,0);
   double Stochastic_Signal=iStochastic(CurrencyPair,FOLLOW_STOCASHTIC_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,0);
   
   double Stochastic_Main_1=iStochastic(CurrencyPair,FOLLOW_STOCASHTIC_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,1);
   double Stochastic_Signal_1=iStochastic(CurrencyPair,FOLLOW_STOCASHTIC_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,1);
   
   UpdateDoubleDataTable(dbConnectSQLId,CurrencyPair,"STBuy",NormalizeDouble(Stochastic_Main,2));
   UpdateDoubleDataTable(dbConnectSQLId, CurrencyPair,"STSell",NormalizeDouble(Stochastic_Signal,2));
   
   if( Stochastic_Main > 80 && Stochastic_Signal > 80 )
   {
      return overBought;
   }
   else if( Stochastic_Main < 20 && Stochastic_Signal < 20 )
   {
      return overSold;
   }
   else if( Stochastic_Main > Stochastic_Main_1 && Stochastic_Signal > Stochastic_Signal_1 )
   {
     return Slope_Up;
   }
   else if( Stochastic_Main < Stochastic_Main_1 && Stochastic_Signal < Stochastic_Signal_1 )
   {
     return Slope_Down;
   }
   else
   {
     return Slope_Neutral;
   }
}

string ADXTrend(string CurrencyPair)
{
    double ADX=NormalizeDouble(iADX(CurrencyPair,FOLLOW_ADX_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,0),0);
    double ADX_1=iADX(CurrencyPair,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,1);
    string str/*Alert*/;
    //*********entry*****************
    str/*Alert*/ = ADXSlope(ADX,ADX_1 );
    
    return str/*Alert*/;;
 }

double getCrossOverCandleLowValue(string CurrencyPair)
{
   double lowVal = 0.0;
   for(int i=0; i<Bars ; i++ )
   {
      double t_PlusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,i);
      double t_PlusVI2 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,i+1);
      double t_MinusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,i);
      double t_MinusVI2 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,i+1);
      
      if(t_PlusVI2 > t_MinusVI2 && t_PlusVI1 < t_MinusVI1 )
      {
         lowVal =  iLow(CurrencyPair,FOLLOW_CHART_TIME_FRAME, i); 
         break;
      }
   }
   return lowVal;
}

string ADXSlope(double ADX, double ADX_1)
{
   if(ADX > ADX_1 /*&& ADX_1 > ADX_2*/)
      return Up;
   else if( ADX < ADX_1 /*&& ADX_1 < ADX_2*/)
      return Down;
   else 
      return "NEUTRAL";         
}

string DI_Minus_SLope(string CurrencyPair)
{ 
   double ADX_MinusDI=iADX(CurrencyPair,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MINUSDI,0);
   double ADX_MinusDI_1=iADX(CurrencyPair,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MINUSDI,1);

   if(ADX_MinusDI > ADX_MinusDI_1 /*&& ADX_MinusDI_1 > ADX_MinusDI_2*/)
      return Up;
   else if(ADX_MinusDI < ADX_MinusDI_1 /*&& ADX_MinusDI_1 < ADX_MinusDI_2*/)
      return Down;
   else 
      return "NEUTRAL";      
}

string DI_Plus_Slope(string CurrencyPair)
{
   double ADX_PlusDI=iADX(CurrencyPair,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_PLUSDI,0);
   double ADX_PlusDI_1=iADX(CurrencyPair,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_PLUSDI,1);
   
   if(ADX_PlusDI > ADX_PlusDI_1 /*&& ADX_PlusDI_1 > ADX_PlusDI_2*/)
      return Up;
   else if(ADX_PlusDI < ADX_PlusDI_1 /*&& ADX_PlusDI_1 < ADX_PlusDI_2*/)
      return Down;
   else 
     return "NEUTRAL";      
}

double getCrossOverCandleHighValue(string CurrencyPair)
{
   double highVal = 0.0;
   for(int i=0; i<Bars ; i++ )
   {
      double t_PlusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,i);
      double t_PlusVI2 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,i+1);
      double t_MinusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,i);
      double t_MinusVI2 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,i+1);
      
      if(t_PlusVI2 < t_MinusVI2 && t_PlusVI1 > t_MinusVI1 )
      {
         highVal =  iHigh(CurrencyPair,FOLLOW_CHART_TIME_FRAME, i);
         break;
      }
   }
   
   return highVal;
}

double LTPHigh(string CurrencyPair)
{    
   double LTP_high = 0.0;
   for(int i=0; i<Bars ; i++ )
   {
     double t_PlusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,i);
     
      if(t_PlusVI1 > VI_EnterTrendVal )
      {  
         LTP_high = iHigh(CurrencyPair, FOLLOW_CHART_TIME_FRAME, i);
         break;
      } 
   }
   return LTP_high;
}

double LTPLow(string CurrencyPair)
{    
   double LTP_low = 0.0;
   for(int i=0; i<Bars ; i++ )
   {      
      double t_MinusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,i);

      if(t_MinusVI1 > VI_EnterTrendVal )
      {  
         LTP_low = iLow(CurrencyPair, FOLLOW_CHART_TIME_FRAME, i);
         break;
      }
   }
   return LTP_low;
}

double MinusVI(string CurrencyPair)
{
   double t_MinusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,0);
   return t_MinusVI1;
}

double PlusVI(string CurrencyPair)
{
   double t_PlusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,0);
   return t_PlusVI1;
}

/*void VortexPoints(string Symbols)
{  
   PlusVI1 = iCustom(Symbols,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,1);
	PlusVI2 = iCustom(Symbols,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,2);
   MinusVI1 = iCustom(Symbols,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,1);
   MinusVI2 = iCustom(Symbols,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,2);
}*/

/*void RefreshADXValue(string CurrencyPair)
{
   //ADX_2=iADX(CurrencyPair,FOLLOW_CURRENT_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,2);
   ADX_1=iADX(CurrencyPair,FOLLOW_CURRENT_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,1);
   ADX=iADX(CurrencyPair,FOLLOW_CURRENT_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,0);
   
   ADX_PlusDI=iADX(CurrencyPair,FOLLOW_CURRENT_TIME_FRAME,14,PRICE_CLOSE,MODE_PLUSDI,0);
   ADX_MinusDI=iADX(CurrencyPair,FOLLOW_CURRENT_TIME_FRAME,14,PRICE_CLOSE,MODE_MINUSDI,0);
   
   ADX_PlusDI_1=iADX(CurrencyPair,FOLLOW_CURRENT_TIME_FRAME,14,PRICE_CLOSE,MODE_PLUSDI,1);
   ADX_MinusDI_1=iADX(CurrencyPair,FOLLOW_CURRENT_TIME_FRAME,14,PRICE_CLOSE,MODE_MINUSDI,1);
   
   ADX_PlusDI_2=iADX(CurrencyPair,FOLLOW_CURRENT_TIME_FRAME,14,PRICE_CLOSE,MODE_PLUSDI,2);
   ADX_MinusDI_2=iADX(CurrencyPair,FOLLOW_CURRENT_TIME_FRAME,14,PRICE_CLOSE,MODE_MINUSDI,2);
}*/

double getClosePrice(string CurrencyPair)
{
   return iClose(CurrencyPair,FOLLOW_CHART_TIME_FRAME,0);
}

double getOpenPrice(string CurrencyPair, int shift)
{
   return iOpen(CurrencyPair,FOLLOW_CHART_TIME_FRAME,shift);
}
string Trend(string CurrencyPair)
{
   string trend = NULL,sym =CurrencyPair;
   
   double macd = iMACD(sym,FOLLOW_CHART_TIME_FRAME,12,26,FILTER,PRICE_CLOSE,MODE_MAIN,0);
   double macd_signal = iMACD(sym,FOLLOW_CHART_TIME_FRAME,12,26,FILTER,PRICE_CLOSE,MODE_SIGNAL,0);
   
   if( macd > 0  && macd_signal > 0 && macd_signal < macd )//&& MA_Entry(sym) == buy_H1 )
   {
     trend = buy_H1;
   }
   if( macd > 0 && macd_signal > 0 && macd_signal > macd )//&& MA_Entry(sym) == sell_H1 ) // &&  )
   {
     trend = sell_H1;
   }
   if( macd < 0 && macd_signal < 0 && MathAbs(macd_signal) < MathAbs(macd) )// && MA_Entry(sym) == sell_H1)
   {
     trend = sell_H1;
   }   
   if( macd < 0 && macd_signal < 0 && MathAbs(macd_signal) > MathAbs(macd) ) //&& MA_Entry(sym) == buy_H1 ) // && )
   {
      trend = buy_H1;
   }
   
     return trend;   
}

string getChartTimeFrameString(int FOLLOW_CURERENT_CHART_TIME_FRAME)
{
   switch(FOLLOW_CURERENT_CHART_TIME_FRAME)
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


void InsertPivotsPoints(string symbol)
{
   double Previous_High = iHigh(symbol,FOLLOW_CHART_TIME_FRAME,1);
   double Previous_Low = iLow(symbol,FOLLOW_CHART_TIME_FRAME,1);
   double Previous_Close = iClose(symbol,FOLLOW_CHART_TIME_FRAME,1);
 
   Pivot_Point_P = (Previous_High + Previous_Low + Previous_Close)/3;
   InsertDoubleDataIntoMYSQL(symbol,"PivotPoint",NormalizeDouble(Pivot_Point_P,2));

   Support_S1 = ( Pivot_Point_P * 2 - Previous_High);
   InsertDoubleDataIntoMYSQL(symbol,"S1",NormalizeDouble(Support_S1,2));

   Support_S2 = Pivot_Point_P - (Previous_High - Previous_Low);
   InsertDoubleDataIntoMYSQL(symbol,"S2",NormalizeDouble(Support_S2,2));
   
   //To DO: Update S3
   InsertDoubleDataIntoMYSQL(symbol,"S3",NormalizeDouble(Support_S2,2));

   Resistance_R1 = (Pivot_Point_P * 2) - Previous_Low;
   InsertDoubleDataIntoMYSQL(symbol,"R1",NormalizeDouble(Resistance_R1,2));

   Resistance_R2 = Pivot_Point_P + (Previous_High - Previous_Low);
   InsertDoubleDataIntoMYSQL(symbol,"R2",NormalizeDouble(Resistance_R2,2));
   
   //To DO: Update R3
   InsertDoubleDataIntoMYSQL(symbol,"R3",NormalizeDouble(Resistance_R2,2));
}

void UpdatePivotsPoints(long &dbConnectSQLId, string symbol)
{
   double Previous_High = iHigh(symbol,FOLLOW_CHART_TIME_FRAME,1);
   double Previous_Low = iLow(symbol,FOLLOW_CHART_TIME_FRAME,1);
   double Previous_Close = iClose(symbol,FOLLOW_CHART_TIME_FRAME,1);
 
   Pivot_Point_P = (Previous_High + Previous_Low + Previous_Close)/3;
   UpdateDoubleDataTable(dbConnectSQLId, symbol,"PivotPoint",NormalizeDouble(Pivot_Point_P,2));

   Support_S1 = ( Pivot_Point_P * 2 - Previous_High);
   UpdateDoubleDataTable(dbConnectSQLId, symbol,"S1",NormalizeDouble(Support_S1,2));

   Support_S2 = Pivot_Point_P - (Previous_High - Previous_Low);
   UpdateDoubleDataTable(dbConnectSQLId, symbol,"S2",NormalizeDouble(Support_S2,2));
   
   //To DO: Update S3
   UpdateDoubleDataTable(dbConnectSQLId, symbol,"S3",NormalizeDouble(Support_S2,2));

   Resistance_R1 = (Pivot_Point_P * 2) - Previous_Low;
   UpdateDoubleDataTable(dbConnectSQLId, symbol,"R1",NormalizeDouble(Resistance_R1,2));

   Resistance_R2 = Pivot_Point_P + (Previous_High - Previous_Low);
   UpdateDoubleDataTable(dbConnectSQLId, symbol,"R2",NormalizeDouble(Resistance_R2,2));
   
   //To DO: Update R3
   UpdateDoubleDataTable(dbConnectSQLId ,symbol,"R3",NormalizeDouble(Resistance_R2,2));
} 
 
double S_1(string symbol)
{
   double Previous_High = iHigh(NULL,FOLLOW_CHART_TIME_FRAME,1);
   double Previous_Low = iLow(NULL,FOLLOW_CHART_TIME_FRAME,1);
   double Previous_Close = iClose(NULL,FOLLOW_CHART_TIME_FRAME,1);
 
   Pivot_Point_P = (Previous_High + Previous_Low + Previous_Close)/3;

   return ( Pivot_Point_P * 2 - Previous_High);

   Support_S2 = Pivot_Point_P - (Previous_High - Previous_Low);

   Resistance_R1 = (Pivot_Point_P * 2) - Previous_Low;

   Resistance_R2 = Pivot_Point_P + (Previous_High - Previous_Low);
}
double S_2(string symbol)
{
   double Previous_High = iHigh(NULL,FOLLOW_CHART_TIME_FRAME,1);
   double Previous_Low = iLow(NULL,FOLLOW_CHART_TIME_FRAME,1);
   double Previous_Close = iClose(NULL,FOLLOW_CHART_TIME_FRAME,1);
 
   Pivot_Point_P = (Previous_High + Previous_Low + Previous_Close)/3;

   Support_S1 = Pivot_Point_P * 2 - Previous_High;

   return Pivot_Point_P - (Previous_High - Previous_Low);

   Resistance_R1 = (Pivot_Point_P * 2) - Previous_Low;

   Resistance_R2 = Pivot_Point_P + (Previous_High - Previous_Low);
}
double R_1(string symbol)
{
   double Previous_High = iHigh(NULL,FOLLOW_CHART_TIME_FRAME,1);
   double Previous_Low = iLow(NULL,FOLLOW_CHART_TIME_FRAME,1);
   double Previous_Close = iClose(NULL,FOLLOW_CHART_TIME_FRAME,1);
 
   Pivot_Point_P = (Previous_High + Previous_Low + Previous_Close)/3;

   Support_S1 = Pivot_Point_P * 2 - Previous_High;

   Support_S2 = Pivot_Point_P - (Previous_High - Previous_Low);

   return (Pivot_Point_P * 2) - Previous_Low;

   Resistance_R2 = Pivot_Point_P + (Previous_High - Previous_Low);
}

double R_2(string symbol)
{
   double Previous_High = iHigh(NULL,FOLLOW_CHART_TIME_FRAME,1);
   double Previous_Low = iLow(NULL,FOLLOW_CHART_TIME_FRAME,1);
   double Previous_Close = iClose(NULL,FOLLOW_CHART_TIME_FRAME,1);
 
   Pivot_Point_P = (Previous_High + Previous_Low + Previous_Close)/3;

   Support_S1 = Pivot_Point_P * 2 - Previous_High;

   Support_S2 = Pivot_Point_P - (Previous_High - Previous_Low);

   Resistance_R1 = (Pivot_Point_P * 2) - Previous_Low;

   return (Pivot_Point_P + (Previous_High - Previous_Low));
} 
bool label_created = false;

void Label(string text, color clr)
{
    if(label_created)
      LabelTextColorChange(0,InpName,text,clr);
   else
      label_created = ShowLabel(text,clr,InpName);
}

bool label_created_active = false;

void LabelActive(string text, color clr)
{
    if(label_created_active)
      LabelTextColorChange(0,InpNameS1,text,clr);
   else
      label_created_active = ShowLabel(text,clr,InpNameS1);
}

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
string            InpNameMALabel = "LabelMA";
string            InpFont="Arial";         // Font
int               InpFontSize=14;          // Font size
double            InpAngle=0.0;            // Slope angle in degrees
ENUM_ANCHOR_POINT InpAnchor=ANCHOR_CENTER; // Anchor type
bool              InpBack=false;           // Background object
bool              InpSelection=true;       // Highlight to move
bool              InpHidden=true;          // Hidden in the object list
long              InpZOrder=0;             // Priority for mouse click 
//+------------------------------------------------------------------+
//|SHOWLABEL_FUNC                                                    |
//+------------------------------------------------------------------+
bool ShowLabel(string text, color InpColor, string inpName)
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
      MessageBox("Error! Incorrect values of input parameters! InpX");
      return 0;
     }
     InpX = x_distance/2;
//--- prepare initial text for the label
   text=StringConcatenate(text);
//--- create a text label on the chart
   if(!LabelCreate(0,inpName,0,InpX,InpY,CORNER_RIGHT_UPPER,text,InpFont,InpFontSize,
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
  
  