//+------------------------------------------------------------------+
//|                                          Trend_Identifier_V2.mq4 |
//|                                  Copyright 2018, Roopsikha Yadav |
//|                              https://github.com/roopsikhayadav28 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Roopsikha Yadav"
#property link      "https://github.com/roopsikhayadav28"
#property version   "1.00"
#property strict
#define  MODE_PLUSVI            0
#define  MODE_MINUSVI           1

input ENUM_TIMEFRAMES FOLLOW_CHART_TIME_FRAME=PERIOD_M15;
input ENUM_TIMEFRAMES FOLLOW_STOCASHTIC_TIME_FRAME = PERIOD_M15;
input ENUM_TIMEFRAMES FOLLOW_ADX_TIME_FRAME = PERIOD_M15;

input string XXXXXXXXXXXXXXXXA = "**********************";
input int    MA_Slow_MovingPeriod = 200;
input int    MA_MovingPeriod_short  =4;
input int    MA_MovingPeriod_long  =8;
int    MA_MovingShift_short  = 0;
int    MA_MovingShift_long = 0;
input int VI_Length = 14;
input string XXXXXXXXXXXXXXXXB = "**********************";

double   Pivot_Point_P;
double   Support_S1;
double   Support_S2;
double   Resistance_R1;
double   Resistance_R2;   

int   Stochastic_Main;
int   Stochastic_Signal;
int   Stochastic_Main_1;
int   Stochastic_Signal_1;
double   VI_EnterTrendVal= 1.10;
double   VI_DownTrendVal= 0.90;


string strHeader= NULL,msgHeader = NULL;

string buy_H1= "BUY",sell_H1="Sell", msg, overBought = "OverBought", overSold = "OverSold",Slope_Up = "Up" , Slope_Down = "Down" , Slope_Neutral = "Neutral" , Up = "Up", Down = "Down";
bool sellVar, buyVar;
bool status[];
int SymbolTotal;

enum Enum_Trend_selection
  { 
     OverBought,
     OverSold,
     Buy ,
     Sell,
     All,
     EntryBuy,
     EntrySell
  };
  
input Enum_Trend_selection TREND_SELECTION = All;

enum ENUM_VORTEX_ENTRY
{
   CROSS,
   PointOne,
   MA
};

input ENUM_VORTEX_ENTRY VORTEX_ENTRY = CROSS;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
     OpenFile();
     SymbolTotal = SymbolsTotal(true);
     ArrayResize(status,SymbolTotal);
     ArrayInitialize(status,0);
     Alert("....................................  ..............................  ..........................\n");
     Alert("....................................  ..............................  ..........................\n");
//     msgHeader = "Symbol|Entry|Price|ADX|Stochastic\n";
//     msg = " ";
//     for(int i = 0; i < SymbolTotal; i++)
//     { 
//        lowVal = 0.0;
//        LTP_high= 0.0;
//        LTP_low = 0.0;
//        highVal = 0.0;
//        sellVar = FALSE;
//        buyVar = FALSE;
//        string CurrencyPair  =  SymbolName(i,true);
//        VortexPoints(CurrencyPair);
//        string strMsg = status[i]? "x":CheckForOpen(CurrencyPair);
//        if( strMsg != NULL && strMsg != "" ){
//             status[i] = True;
//          }
//            
//        if(strMsg == NULL)        
//            status[i] = False;    
//           // msg = msg + CurrencyPair+"\n"; 
//     }
   OnTick();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   CloseFile();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---     
     //int SymbolTotal = SymbolsTotal(true);

     msgHeader = "Symbol|Entry|Price|ADX|Stochastic|Momentum|Chart Time Frame\n";
     msg = " ";
     for(int i = 0; i < SymbolTotal; i++)
     { 
        sellVar = FALSE;
        buyVar = FALSE;
        string CurrencyPair  =  SymbolName(i,true);
        string strMsg = status[i]? "x":CheckForOpen(CurrencyPair);
        if( strMsg != NULL && strMsg != "" && !status[i] ){
             status[i] = True;
          }
            
        if(strMsg == NULL)
            status[i] = False;    
           // msg = msg + CurrencyPair+"\n"; 
     }
        
       //if(msg != NULL && msg != " ")
      // MessageBox(msgHeader+msg ,"TREND IDENTIFIER" ,0x00000040); 
                 
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check for open order conditions                                  |
//+------------------------------------------------------------------+
string CheckForOpen(string CurrencyPair)
  {
//--- go trading only for first tiks of new bar
   //if(Volume[0]>1) return;
   string str = NULL;
    if(Trend(CurrencyPair) == sell_H1)
    {
      str = EntrySell(CurrencyPair);
      return str;
    }
    else if(Trend(CurrencyPair) == buy_H1)
    {
      str = EntryBuy(CurrencyPair);
      return str;
    }
    return NULL;    
 }

string EntrySell(string CurrencyPair)
{
   Refresh_Stochastic_Value(CurrencyPair);
   double lowVal = getCrossOverCandleLowValue(CurrencyPair);
   double closePrice = getClosePrice(CurrencyPair);
   double LTP_Low = CheckLTP_L(lowVal,LTPLow(CurrencyPair));
   if(CandleOpenSell(CurrencyPair))
   {
      if( VortexCrossOverSellEntry( CurrencyPair ) && ( closePrice < lowVal && lowVal !=0 ) && !sellVar )
        {
           sellVar = TRUE;
           strHeader =  CurrencyPair + "|" + "Entry Sell|" + DoubleToStr(LTP_Low,2) +  "|" + string(ADXTrend(CurrencyPair)) +"|" + string(getStochasticStatus())+"|"+Momentum(CurrencyPair)+"|"+getChartTimeFrameString(FOLLOW_CHART_TIME_FRAME) ;
           checkFilter(strHeader,sell_H1);
           return strHeader;
        }
     }
   return NULL;  
}
//--- buy conditions
string EntryBuy(string CurrencyPair)
{   
   Refresh_Stochastic_Value(CurrencyPair);
   double highVal = getCrossOverCandleHighValue(CurrencyPair);
   double closePrice = getClosePrice(CurrencyPair);
   double LTP_High = CheckLTP_H(highVal, LTPHigh(CurrencyPair));
   if(CandleOpenBuy(CurrencyPair) )
   {
      if( VortexCrossOverBuyEntry( CurrencyPair ) && ( closePrice > highVal && highVal !=0 ) && !buyVar)
        {
            buyVar = TRUE;
            strHeader =  CurrencyPair + "|" +"Entry Buy|"  + DoubleToStr(LTP_High,2)+  "|" + string(ADXTrend(CurrencyPair)) +"|" + string(getStochasticStatus())+"|"+Momentum(CurrencyPair)+"|"+getChartTimeFrameString(FOLLOW_CHART_TIME_FRAME)  ;
            checkFilter(strHeader,buy_H1);
            return strHeader;  
        }
     }
     return NULL;  
//---
  }
  
bool VortexCrossOverBuyEntry(string CurrencyPair)
{
   double PlusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,0);
   double MinusVI1 = iCustom(CurrencyPair,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,0);
   
   if( (VORTEX_ENTRY == CROSS) && (/*PlusVI2 < MinusVI2 &&*/ PlusVI1 > MinusVI1 ) && ADXBuyEntry(CurrencyPair) )
   {
      return true;
   }
 
   if( (VORTEX_ENTRY == PointOne) && (PlusVI1 > VI_EnterTrendVal) && ADXBuyEntry(CurrencyPair) )
   {
      return true;
   }
   
   if( VORTEX_ENTRY == MA && ( MA_Entry(CurrencyPair) == buy_H1 && ADXBuyEntry(CurrencyPair) ) && ( MinusVI1 < PlusVI1 ) )
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
   
   if( VORTEX_ENTRY == CROSS && /*PlusVI2 > MinusVI2 &&*/ PlusVI1 < MinusVI1 && ADXSellEntry(CurrencyPair) )
   {
      return true;
   }
   if(VORTEX_ENTRY == PointOne && MinusVI1 > VI_EnterTrendVal && ADXSellEntry(CurrencyPair) )
   {
      return true;
   }
   if( VORTEX_ENTRY == MA && ( MA_Entry(CurrencyPair) == sell_H1 && ADXSellEntry(CurrencyPair) ) && ( MinusVI1 > PlusVI1 ) )
   {
      getMACrossOverCandleLowValue(CurrencyPair);
      return true;
   }
   return false;
}

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
   double ma_fast_current=iMA(CurrencyPair,FOLLOW_CHART_TIME_FRAME,MA_MovingPeriod_short,MA_MovingShift_short,MODE_EMA,PRICE_OPEN,0);
   double ma_slow_current=iMA(CurrencyPair,FOLLOW_CHART_TIME_FRAME,MA_MovingPeriod_long,MA_MovingShift_long,MODE_EMA,PRICE_OPEN,0);
   double ma_fast_prev=iMA(CurrencyPair,FOLLOW_CHART_TIME_FRAME,MA_MovingPeriod_short,MA_MovingShift_short,MODE_EMA,PRICE_OPEN,1);
   double ma_slow_prev=iMA(CurrencyPair,FOLLOW_CHART_TIME_FRAME,MA_MovingPeriod_long,MA_MovingShift_long,MODE_EMA,PRICE_OPEN,1);
   
   double ADX=NormalizeDouble(iADX(CurrencyPair,FOLLOW_ADX_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,0),0);
   double ADX_1=NormalizeDouble(iADX(CurrencyPair,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,1),0);
   if( ADXSlope(ADX,ADX_1) == Up )
   {
      if( ma_fast_current < ma_slow_current )
         return sell_H1;
      if( ma_fast_current > ma_slow_current )
         return buy_H1; 
    }
      
   return NULL;  
}

double getMACrossOverCandleLowValue(string CurrencyPair)
{
   double lowVal = 0.0;
   for(int i=0; i<Bars ; i++ )
   {  
       double ma_plus_current=NormalizeDouble(iMA(CurrencyPair,0,MA_MovingPeriod_short,MA_MovingShift_short,MODE_LWMA,PRICE_CLOSE,i),2);
       double ma_minus_current=NormalizeDouble(iMA(CurrencyPair,0,MA_MovingPeriod_long,MA_MovingShift_long,MODE_LWMA,PRICE_CLOSE,i),2);
       double ma_plus_prev=NormalizeDouble(iMA(CurrencyPair,0,MA_MovingPeriod_short,MA_MovingShift_short,MODE_LWMA,PRICE_CLOSE,i+1),2);
       double ma_minus_prev=NormalizeDouble(iMA(CurrencyPair,0,MA_MovingPeriod_long,MA_MovingShift_long,MODE_LWMA,PRICE_CLOSE,i+1),2);
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
       double ma_plus_current=NormalizeDouble(iMA(CurrencyPair,0,MA_MovingPeriod_short,MA_MovingShift_short,MODE_LWMA,PRICE_CLOSE,i),2);
       double ma_minus_current=NormalizeDouble(iMA(CurrencyPair,0,MA_MovingPeriod_long,MA_MovingShift_long,MODE_LWMA,PRICE_CLOSE,i),2);
       double ma_plus_prev=NormalizeDouble(iMA(CurrencyPair,0,MA_MovingPeriod_short,MA_MovingShift_short,MODE_LWMA,PRICE_CLOSE,i+1),2);
       double ma_minus_prev=NormalizeDouble(iMA(CurrencyPair,0,MA_MovingPeriod_long,MA_MovingShift_long,MODE_LWMA,PRICE_CLOSE,i+1),2);
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
  
void checkFilter(string str, string entry)
{
  string st_status  = getCustomString(getStochasticStatus());
  if( ( entry == buy_H1 ) && (TREND_SELECTION == EntryBuy ) )
  {
     Alert( Modify( str) );
     Alert( Modify( msgHeader) );
     PlaySound("\\Files\\inform.wav");
     return;
  }
  if( ( entry == sell_H1 ) && ( TREND_SELECTION == EntrySell ) )
  {
     Alert( Modify( str) );
     Alert( Modify( msgHeader) );
     PlaySound("\\Files\\inform.wav");
     return;
  }
  
  if( TREND_SELECTION == All )
  {
     Alert( Modify( str) );
     Alert( Modify( msgHeader) );
     PlaySound("\\Files\\inform.wav");
     return;
  }
  
  if(st_status != NULL )
  {
     if( st_status == overBought  && TREND_SELECTION == OverBought)
     {
        Alert( Modify( str) );
        Alert( Modify( msgHeader) );
        PlaySound("\\Files\\inform.wav");
        return;
     }
     if( st_status == overSold && TREND_SELECTION == OverSold )
     {
        Alert( Modify( str) );
        Alert( Modify( msgHeader) );
        PlaySound("\\Files\\inform.wav");
        return;
     }
     if( st_status == Up && TREND_SELECTION == Buy )
     {
        Alert( Modify( str) );
        Alert( Modify( msgHeader) );
        PlaySound("\\Files\\inform.wav");
        return;
     }
     if( st_status == Down && TREND_SELECTION == Sell )
     {
        Alert( Modify( str) );
        Alert( Modify( msgHeader) );
        PlaySound("\\Files\\inform.wav");
        return;
     }
  }
}  
  
double CheckLTP_H(double highVal, double LTP_High )
{
  double LTP = ( LTP_High == 0 || VORTEX_ENTRY == CROSS )? highVal: LTP_High;
  return LTP;
}

double CheckLTP_L(double lowVal, double LTP_Low )
{
  double   LTP = ( LTP_Low == 0 || VORTEX_ENTRY == CROSS )? lowVal: LTP_Low;
  return LTP;
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

string getStochasticStatus()
{
   if( Stochastic_Main > 80 && Stochastic_Signal > 80 )
   {
      return overBought+ " , +" + string(Stochastic_Main)+", -"+string(Stochastic_Signal);
   }
   else if( Stochastic_Main < 20 && Stochastic_Signal < 20 )
   {
      return overSold + " , +" +string(Stochastic_Main)+", -"+string(Stochastic_Signal);
   }
   else if( Stochastic_Main > Stochastic_Main_1 && Stochastic_Signal > Stochastic_Signal_1 )
   {
     return Slope_Up+ " , +" + string(Stochastic_Main)+", -"+string(Stochastic_Signal);
   }
   else if( Stochastic_Main < Stochastic_Main_1 && Stochastic_Signal < Stochastic_Signal_1 )
   {
     return Slope_Down+ " , +" + string(Stochastic_Main)+", -"+string(Stochastic_Signal);
   }
   else
   {
     return Slope_Neutral+ " , +" + string(Stochastic_Main)+", -"+string(Stochastic_Signal);
   }
}

string ADXTrend(string CurrencyPair)
{
    double ADX=NormalizeDouble(iADX(CurrencyPair,FOLLOW_ADX_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,0),0);
    double ADX_1=iADX(CurrencyPair,FOLLOW_CHART_TIME_FRAME,14,PRICE_CLOSE,MODE_MAIN,1);
    string strAlert;
    //*********entry*****************
    strAlert = ADXSlope(ADX,ADX_1 )+", "+ string(ADX);
    
    return strAlert;;
 }

void Refresh_Stochastic_Value(string CurrencyPair)
{
   Stochastic_Main=iStochastic(CurrencyPair,FOLLOW_STOCASHTIC_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,0);
   Stochastic_Signal=iStochastic(CurrencyPair,FOLLOW_STOCASHTIC_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,0);
   
   Stochastic_Main_1=iStochastic(CurrencyPair,FOLLOW_STOCASHTIC_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,1);
   Stochastic_Signal_1=iStochastic(CurrencyPair,FOLLOW_STOCASHTIC_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,1);
}

double getCrossOverCandleLowValue(string CurrencyPair)
{
   int lowVal = 0.0;
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
   string trend = NULL;
   double closePrice = getClosePrice(CurrencyPair);
   double MA_Slow=iMA(CurrencyPair,FOLLOW_CHART_TIME_FRAME,MA_Slow_MovingPeriod,0,MODE_SMA,PRICE_OPEN,0);
   
   if( closePrice > MA_Slow )
   {
     trend = buy_H1;
   }
   else if( closePrice < MA_Slow )
   {
     trend = sell_H1;
   }
   if(trend == NULL)
      return "";
   else 
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

//--- parameters for writing data to file 
string             InpFileName="loging.csv";      // File name
string InpDirectoryName="Data//TrendIdentifier";     // Folder name
int file_handle;

void logFile(string str)
{  
   string detail = string(TimeCurrent()) +","+ str;
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
void OpenFile()
{
    file_handle=FileOpen(InpDirectoryName+"//"+InpFileName,FILE_READ|FILE_WRITE|FILE_CSV);
}
void CloseFile()
{
   if(file_handle != INVALID_HANDLE)
   {
       //--- close the file 
   FileClose(file_handle); 
   PrintFormat("Data is written, %s file is closed",InpFileName); 
   }
}

