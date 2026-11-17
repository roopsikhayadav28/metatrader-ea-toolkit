//+------------------------------------------------------------------+
//|                                        Increment_StopLoss_EA.mq4 |
//|                                  Copyright 2018, Roopsikha Yadav |
//|                              https://github.com/roopsikhayadav28 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Roopsikha Yadav"
#property link      "https://github.com/roopsikhayadav28"
#property version   "1.00"
#property strict
#include <ReadInputValues.mqh>
#include <labelUI.mqh>
#include <StopLossMgmt.mqh>
#include <ButtonCreate.mqh>
#define  MODE_PLUSVI            0
#define  MODE_MINUSVI           1

//+------------------------------------------------------------------+
//|Input Values from User                                            |
//+------------------------------------------------------------------+
 bool CURRENT_BUY_ORDER = 0;
 bool CURRENT_SELL_ORDER = 0;
 double PRICE_EXECUTED = 0;

 double EnterTrailingStopLoss=0;

//input ENUM_TIMEFRAMES FOLLOW_TIME_FRAME=PERIOD_H1;
input bool PIVOT_STOPLOSS = false;
input ENUM_TIMEFRAMES FOLLOW_CHART_TIME_FRAME=PERIOD_CURRENT;
input ENUM_TIMEFRAMES FOLLOW_STOCHASTIC_CHART_TIME_FRAME = PERIOD_CURRENT;

input int FILTER = 20;
int SLOPE = 1;
input string XXXXXXXXXXXXXXXXB = "**********************";
 int MA_Slow_MovingPeriod = 14;

int ADX_VeryStrongTrend_BTW_75_100= 75;
int ADX_StrongTrend_BTW_50_75 = 50;
int ADX_MediumTrend_BTW_40_50 = 40;
//use stocastic for exit and enter
int ADX_WeakTrend_BTW_25_40 = 25;
int ADX_VeryWeakTrend_Below_25 = 25;

input string XXXXXXXXXXXXXXXX = "**********MACD*************";
//--- Inputs MA
input ENUM_APPLIED_PRICE   PRICE_ACTION = PRICE_CLOSE;
int                  MA_FAST  =2;
int                  MA_SLOW  =200;

input ENUM_MA_METHOD       MA_METHOD = MODE_LWMA;
input int    MA_MovingShift_short  = 0;
input int    MA_MovingShift_long = 0;
//input double MA_DIFFERENCE = 0.03;

//input int ADX_BELOW_DO_NOT_ENTER = 20;
input int ADX_VALUE = 20;
int ADX_LIMIT =40;
int ST_DIFF = 4;
 double VI_DIFF = 0.05;
input string XXXXXXXXXXXXXXXXXXD = "***************ENTRY-EXIT*************";

  
double   PlusVI1;
double	PlusVI2;
double   MinusVI1;
double	MinusVI2;
double   VI_EnterTrendVal= 1.1;
double   VI_DownTrendVal= 0.9;
double lowVal = 0, highVal = 0;



bool   isFirstTime = TRUE,buy=FALSE, sell=FALSE, label_created = FALSE, isLabel_Hour_Created = FALSE, label_created_order=FALSE,label_created_ma =false,label_created_adx_slope = FALSE, label_created_adx = FALSE, buyVar,sellVar;
double LTP = 0;
string strHeader,strHeaderExit,finalString,Down = "DOWN", Up="UP",overBought = "OverBought", overSold = "OverSold",Slope_Up = "Up" , Slope_Down = "Down" , Slope_Neutral = "Neutral";
double ma_fast_current, ma_slow_current, ma_fast_prev, ma_slow_prev;
double ADX, ADX_MinusDI, ADX_PlusDI, ADX_1, ADX_2, ADX_MinusDI_1, ADX_MinusDI_2, ADX_PlusDI_1, ADX_PlusDI_2;
//---- input parameters
 int VI_Length = 14;

enum ENUM_ENTRY
{
   macdMA,
   candle,
   macd
};

enum ENUM_EXIT
{
   MA,
   CANDLE,
   MACDma,
   MACD
};

enum ENUM_STOP_LOSS
{
  ONE,
  TWO
};

input ENUM_STOP_LOSS STOP_LOSS = TWO;
input ENUM_ENTRY ENTRY_TYPE = macdMA;
input ENUM_EXIT EXIT_TYPE = MACD;

string buy_H1= "BUY",sell_H1="SELL";
color clrSell = clrRed, clrBuy = clrLawnGreen, clrNeutral = clrDarkTurquoise;
string const strNeutral="DO NOT TAKE FRESH ENTRY ";
string const strWaiting="WAITING FOR TICK, ";

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
     OnStartButtonBuy();
     OnStartButtonSell();
     OpenFileOnly(Symbol());
     InitialiseWebParam();
     string data[1][3];
     getSmartStopLoss(Symbol(),data);
     max_candle = data[0][0];
     decrement_candle = data[0][1];
     min_candle =data[0][2];
     ArrayFree(data);
      
     if(!VerifyMasterTableEntry(true))
     {
       return 0 ;
     }
     
     PivotPoints();
     CreateChart();
     while(!IsConnected())
     {
        Label("!!!No Connection!!!", clrCornflowerBlue);
        continue;
     }
    if(getForceExitTrue(Symbol()) == 1)
    {
        strHeader = "Force Exit Enabled, Cannot take Any Entry in " +Symbol();
        Label( strHeader,clrBuy);
        return false;
    } 

     buy_H1= "BUY";
     sell_H1="SELL";
     //sT=0.0;

 
     //buy  =  CURRENT_BUY_ORDER;
     //sell =  CURRENT_SELL_ORDER;          
 
     LTP=0;
         
     PrintCommentHeader("",DisplayOnScreen());
     //ShowADXValue(SHOW_VALUE);
     LabelHour();
    // if(VerifyOneWayTrendEntryByUser(true))
     {
       //return 0;
     }
     buy = false;
     sell = false;

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
  
    //OnTick();
//---
   return(INIT_SUCCEEDED);
  }
  
int max_candle, decrement_candle, min_candle;
     
void InitialiseWebParam()
{
     if(isFirstTime)
     {
       isFirstTime = FALSE;
       deleteAllObjects();
       RemoveHys();
       MA_FAST = getMA_Fast(Symbol());
       MA_SLOW = getMA_Slow(Symbol());
       string txtMAparam = "MA_FAST = " + MA_FAST + ", MA_SLOW = " + MA_SLOW+", MACD_FILTER = " + FILTER; 
       LabelMAParam( txtMAparam, clrLime);
     }
     
     MA_FAST = getMA_Fast(Symbol());
     MA_SLOW = getMA_Slow(Symbol());
     string txtMAparam = "MA_FAST = " + MA_FAST + ", MA_SLOW = " + MA_SLOW+", MACD_FILTER = " + FILTER;
     LabelMAParam( txtMAparam, clrLime);
     //Print( txtMAparam + Symbol());
     
     weakTrend = getWeekTrendVal(Symbol());
     sL=getStopLossDiff(Symbol());
     hys = getHystrisis(Symbol());
     string arr[1][7];
     getCurrentOpenQuantity(Symbol(),arr);
     exeLtp = NormalizeDouble(StrToDouble(arr[0][6]), 2); // LTP at which price was executed
     ArrayFree(arr);
     renko = getRenko(Symbol());
     candleSize = MathAbs(Open[1]-Close[1]);
     priceDifference = getPriceDiff(Symbol());
     string masterTableInfo = "hys= " + hys+" webVal= " + renko + ", IncP= " + priceDifference + ",candle=" + NormalizeDouble(candleSize, 2)+"--"+NormalizeDouble(MathAbs(High[1]-Low[1]),1)+", eLTP = " + exeLtp;
     LabelMaterTableInfo(masterTableInfo , clrYellow );
     string data[1][3];
//     
//     int candle_risk, curr_risk ;
//     if( buy ){
//         getSmartStopLoss(Symbol(),data);
//         max_candle = data[0][0];
//         decrement_candle = data[0][1];
//         min_candle =data[0][2];
//         
//        PRICE_EXECUTED = getOpenPriceExecuted(Symbol());
//        int count = getCurrentCandleBuy(renko);
//        candle_risk = count/decrement_candle;;
//        int risk = ( max_candle - candle_risk );
//        double newStoploss = Open[0] - risk;
//        if(newStoploss > prevStopLoss(Symbol())){
//            curr_risk = risk;            
//            LabelOpen("Candle:Inc= " + string(count)+",Max Risk= " +max_candle+", current Risk= "+curr_risk, clrLightBlue );
//          }
//        }
//     else if( sell )
//     {
//       getSmartStopLoss(Symbol(),data);
//       max_candle = data[0][0];
//       decrement_candle = data[0][1];
//       min_candle =data[0][2];
//       
//       PRICE_EXECUTED = getOpenPriceExecuted(Symbol());
//       int count = getCurrentCandleSell(renko);
//       candle_risk = count/decrement_candle;;
//       int risk = ( max_candle - candle_risk );
//       double newStoploss = Open[0] - risk;
//       if(newStoploss < prevStopLoss(Symbol()) ){
//           curr_risk = risk;             
//       LabelOpen("Candle:Inc= " + string(count)+",Max Risk= " +max_candle+", current Risk= "+curr_risk, clrOrangeRed );
//     }
//     else
//      LabelOpen("Candle:max= " +max_candle+",decrement= "+decrement_candle+" min= " + min_candle, clrYellow );
     
     ArrayFree(data);
}
  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
      //--- delete all objects 
    //deleteAllObjects();
    showNotification("Expert Advisor Removed" + Symbol() );
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
    isLabel_Hour_Created = FALSE;   
    label_created = FALSE;
    label_created_adx =FALSE;
    label_created_adx_slope = FALSE;
    label_created_ma = FALSE;
    label_created_order = FALSE; 
    label_price_diff = FALSE;
    label_open_diff=FALSE;
    OnStartButtonBuy();
    OnStartButtonSell();
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
     InitialiseWebParam();
     while(!IsConnected())
     {
        Label("!!!No Connection!!!", clrCoral);
        continue;
     } 
    if(!VerifyMasterTableEntry(true))
    {
       return;
    }    
    LabelHour();
    PivotIndicator();
    
    PrintCommentHeader("",DisplayOnScreen());
    CheckForOpen(); 
    CheckForClose(); 
    if(getForceExitTrue(Symbol()) == 1)
    {
        strHeader = "Force Exit Enabled, Cannot take Any Entry in " +Symbol();
        Label( strHeader,clrBuy);
        return ;
    }  
        //+------------------------------------------------------------------+
        //|NEUTRAL                                                           |
        //+------------------------------------------------------------------+  
        if(sell == FALSE && buy == FALSE)
        {
           if(!CheckForOpen())
             Label(strNeutral+getWeakTrend(),clrNeutral);
           else
             Label("Started.., "+ADXTrend(),clrSell);  
             
          // return;           
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

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
     string res = ChartEvent(id, sparam);
     if( res != NULL)
     {
       // UpdateForceExitToFalse(Symbol());
        if(res == buy_H1)
           Buy(Symbol());
        if(res == sell_H1);
           Sell(Symbol());  
     } 
  }
//+------------------------------------------------------------------+


string getWeakTrend()
{
    string str = weakTrend == 1 ?  " :Weak Trend Enabled":" :Strong Trend Enabled";
    return str;
}
void VerifyStopLossEntered(bool OneTimeOnly)
{
   if(sL == 0)
      showNotification(Symbol()+" Enter Stoploss Diff");
      
   if(sell || buy)
   {
      if(EnterTrailingStopLoss == 0 && sT != 0 )
      {
        showNotification(Symbol()+" Please Enter Stop Loss");
        return;
      }
      
      if(EnterTrailingStopLoss < sT + 0.2 && EnterTrailingStopLoss > sT -0.2 && sT !=0 && OneTimeOnly )
      {
        showNotification(Symbol()+" You Have added Trailing StopLoss");
      }
      if( (EnterTrailingStopLoss > sT + 0.2 || EnterTrailingStopLoss < sT -0.2 ) && sT !=0 )
      {
        showNotification(Symbol()+" !!!!!Check Trailing StopLoss Value");
      }
   }
}

bool VerifyMasterTableEntry(bool showMsg)
{    
  string val = getMissingVal();
  if(showMsg && val != NULL)
  {
    Label(Symbol()+" EA STOPPED , Please Check " + val , clrOrangeRed);
    return false;
  }
        
  return true;
}

string getMissingVal()
{  
   /*string data[1][3];
   getSmartStopLoss(Symbol(),data);
   int max_candle = data[0][0];
   int decrement_candle = data[0][1];
   int min_candle =data[0][2];
   ArrayFree(data);*/
   string val = NULL;
  if( max_candle == 0)
  {
     val = "SL_MAX";
  }
  else if(renko == 0 )
  {
     val = "WEB CANDLE" ;
  }
  else if(decrement_candle == 0)
  {
     val = "SL_DECREMENT_CANDLE";
  }
  else if( priceDifference == 0)
  {
    val = "PRICE DIFFERENCE";
  }
  else if( renko !=  NormalizeDouble(candleSize, 2) ) 
  {
     val = "WEBCANDLE MISMATCH";
  }
  return val;
 }
 
bool VerifyOneWayTrendEntryByUser(bool showMsg)
{     
     if(showMsg)
        ErrorMessage(" You can only enter in current trend");
        
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
   string sym = Symbol();
   string trade = EnterTradeManually(sym);
   if(trade == "SELL"  )
   {         
     if(Trend() == sell_H1)
     {
       result =  EntrySell();
     }
   }
   if( trade == "BUY" )
   {
     if( Trend() == buy_H1)
     {
       result =  EntryBuy();
     }
   }
  if( trade == "BOTH")
  {
     if(Trend() == sell_H1)
     {
       result =  EntrySell();
     } 
     if( Trend() == buy_H1)
     {
       result =  EntryBuy();
     }
  }   
   if( trade == "NO" )
   {
     Label("Check Orderbook , No order selected!", clrTan);
     showNotification(Symbol()+" Check Orderbook , No order selected!");
   } 
    return result;    
 }
 
//+------------------------------------------------------------------+
//| Check for close order conditions                                 |
//+------------------------------------------------------------------+
bool CheckForClose()
  {
  
   // if(Volume[0] > 1 ) 
      //return false;
      
    string arr[1][7];
    bool result = FALSE;
    uint donotupdate = 2;
    
    if(!getCurrentOpenQuantity(Symbol(),arr))
    {
      sell = false;
      buy = false;
      Print( "NO ENTRY IN OPENPOSITION TABLE " + Symbol());
      return false;
    }
    
    int currentQty = StrToInteger(arr[0][0]);  
    string currentEntry = arr[0][1];
    double AvgPrice = StrToDouble(arr[0][2]);
    double lastexeLTP = StrToDouble(arr[0][5]); // LTP at which price was executed
    bool forceExit = getForceExitTrue(Symbol());
    PRICE_EXECUTED = getOpenPriceExecuted(Symbol());
    UpdateUnrealisedBalanceAmount(currentEntry , AvgPrice, currentQty, donotupdate, Close[0]);
    //if( currentQty == MinimumQuantity && MinimumQuantity != 0)
        exeLtp = lastexeLTP;  // only update hystrisis when order is placed first time and do change LTP when there is Increment entry.
    
    // entrytype is sell from database
    if( currentEntry == "Sell" && currentQty > 0 )
    {
      sell = true; buy = false;
      result = ExitSell(forceExit);
    }
    else if( currentEntry == "Buy" && currentQty > 0 )  // entrytype is buy from database
    {
      sell = false; buy = true;
      result = ExitBuy(forceExit);
      //Print("Buy entry " + Symbol());
    }
    else if( currentQty == 0 )
    { 
      sell = false; buy = false;
     // Print( "NO ENTRY " + Symbol());
    }
    
    updateLTPLabel(lastexeLTP);
    ArrayFree(arr);  
    return result;
}

void updateLTPLabel(double lep)
{
     if(lep == 0 || lep == NULL)
       return;
       
     string showP = "price: "+Close[0]+"lastLTP: "+lep;
     LabelPriceDifference(showP + ",PriceDiff = " + ( lep-Close[0]), clrLightPink);
}


bool EntrySell()
{
   RefreshRates();
   Refresh_MA_Value();
   RefreshADXValue();
   
   if( SellEntry() ) ///*&& !sell && !sellVar*/ )
     {
       if(getForceExitTrue(Symbol()) == 1)
       {
           strHeader = "Force Exit Enabled, Cannot take Sell Entry " +Symbol();
           Label( strHeader,clrSell);
           return false;
       }
           
         sell = TRUE;
         buy = false;
         strHeader = ADXTrend()+", Entry Sell, " +Symbol() +", "+ string(Bid);
         Label( strHeader,clrSell);
         //Alert( strHeader);
         Sell(Symbol());
         //SmartStopLossSell();
         Sleep(1000);
       return TRUE;
     }


   return FALSE;
}

//--- buy conditions
bool EntryBuy()
{
   RefreshRates();
   Refresh_MA_Value();
   RefreshADXValue();

   if( BuyEntry() )
     {      
       if(getForceExitTrue(Symbol()) == 1)
       {
           strHeader = "Force Exit Enabled, Cannot take Buy Entry " +Symbol();
           Label( strHeader,clrBuy);
           return false;
       }   
         buy = TRUE;
         sell = false;
         strHeader = ADXTrend()+", Entry Buy, " +Symbol() +", "+ DoubleToString(Ask);
         Label(strHeader, clrBuy);
         Buy(Symbol());

         //SmartStopLossBuy();
         Sleep(1000);     
         return TRUE;  
     }
 
   return FALSE;  
//---
  }

double const multiplierHalf = 0.5;
bool ExitSell( bool forceExit)
{
   if( !(Close[0] < exeLtp+hys && Close[0] > exeLtp-hys) )
   {
       //hys = 0;// we want to deactivate hystrisis after price has crossed hystrisis in favour direction.
       hysDeActivated = true;  
   }
      
   RefreshRates();
   Refresh_MA_Value();
   RefreshADXValue();
   
   //exit sale

   if(/*stopLossCalculateSell(exeLtp) &&*/ StopLossSell() && PIVOT_STOPLOSS)
   {
      strHeaderExit = "STOPLOSS SELL!!!, " + Symbol()+", LTP = "+ string(Ask);
      Label(strHeaderExit,clrSell);
      showNotification(strHeaderExit);
      
      //buyVar = FALSE;
      CloseOrder(Symbol(),"Buy");
      return true;
   }

   if(  isExitSell() )
   {     
      if( !(Close[0] < exeLtp+hys && Close[0] > exeLtp-hys)|| hysDeActivated == true  )
      {     
         if( exeLtp == 0 ) showNotification(" exeLTP == 0 " + Symbol() );
         strHeaderExit = "Exit SELL Position," + Symbol()+" Close<--->Hystrisis "+Close[0]+"--"+  exeLtp+hys;
         Label(strHeaderExit,clrSell);
         showNotification(strHeaderExit);
         
         CloseOrder(Symbol(),"Buy");
         deleteAllObjects();
         RemoveHys(); 
         sT = 0;
         sell = false;
         return TRUE;
       }
   }
   
   if( forceExit )
   {
      strHeaderExit = " Force Exit SELL Position," + Symbol();
      Label(strHeaderExit,clrSell);
      showNotification(strHeaderExit);
      sell = false;
      
      CloseOrder(Symbol(),"BuyF");
      deleteAllObjects();
      sT = 0;
      UpdateStoploss(Symbol(),0,0);
      UpdateRiskCandle(Symbol(),0);
      RemoveHys();
      return true;
   }
   if( ADXSlope() == Down && ADX_MinusDI > ADX_PlusDI )
   {              
      //CloseOrder(Symbol(),"BuyD");          
      //return TRUE;
   }
   
   //if(hysDeActivated )
   { 
     //Print("StopLoss " + Symbol() ) ;
     //IncrementStopLossSell();
     takeProfitSell(); 
   }

   HystrisisIndicator( clrLightBlue,"Range1", exeLtp+ hys);
   HystrisisIndicator( clrLightBlue,"Range2", exeLtp-hys );
   UpdateCurrentTime(Symbol());
   return FALSE;
//---
}

 bool ExitBuy( bool forceExit)
 {   
   if( !(Close[0] > exeLtp-hys && Close[0] < exeLtp+hys) )
   {
       //hys = 0;// getHystrisis( Symbol() );
       hysDeActivated = true;
   }

   RefreshRates();
   Refresh_MA_Value();
   RefreshADXValue();
  
   //exit buy

   if(/*stopLossCalculateBuy(exeLtp) &&*/ StopLossBuy() && PIVOT_STOPLOSS)
   {
      strHeaderExit = "STOPLOSS Buy!!!, " + Symbol()+", LTP = "+ string(Bid);
      Label(strHeaderExit,clrBuy);
      showNotification(strHeaderExit);
      
      //buyVar = FALSE;
      CloseOrder(Symbol(),"Sell");
      return true;
   }
                      // Envelop for Hystrisis 
   if( isExitBuy() )
   {     
      if( !(Close[0] > exeLtp-hys && Close[0] < exeLtp+hys) ||  hysDeActivated == true )
      {
         if( exeLtp == 0 ) showNotification(" exeLTP == 0 " + Symbol() );
         strHeaderExit = "Exit BUY Position, " + Symbol()+", Close<--->Hystrisis "+Close[0]+"--"+  (exeLtp-hys);
         Label(strHeaderExit,clrBuy);
         showNotification(strHeaderExit);
         
         //buyVar = FALSE;
         CloseOrder(Symbol(),"Sell");
         deleteAllObjects();
         RemoveHys();
         sT = 0;      
         buy = false;
         return TRUE;
       }
    }
     
   if( forceExit  )
   {
      strHeaderExit = " Force Exit BUY Position," + Symbol();
      Label(strHeaderExit,clrBuy);
      Alert(strHeaderExit);
      buy = false;
      
      CloseOrder(Symbol(),"SellF");
      deleteAllObjects();
      sT = 0;  
      UpdateStoploss(Symbol(),0,0);
      UpdateRiskCandle(Symbol(),0);
      RemoveHys();
      return true;
   }
   if( ADXSlope() == Down && ADX_MinusDI < ADX_PlusDI )
   {
       //CloseOrder(Symbol(),"SellD");    
       //return TRUE;
    }
    
    //if( hysDeActivated)
    {
     // IncrementStopLossBuy();
      takeProfitBuy();
    }

    HystrisisIndicator( clrLightBlue,"Range1", exeLtp- hys);
    HystrisisIndicator( clrLightBlue,"Range2", exeLtp+hys );
    UpdateCurrentTime(Symbol()); 
   return FALSE;
}

void RemoveHys()
{  
   // HystrisisIndicator( clrLightBlue,"Range1", -1);
   // HystrisisIndicator( clrLightBlue,"Range2", -1 );
}

bool StopLossSell()
{
   if(Resistance_R1 == 0 || Resistance_R2 == 0 ){
      PivotPoints();
      return false;
      }
   UpdateStoploss(Symbol(),Resistance_R2,getCurrentCandleSell(renko));
   StopLossIndicator(Resistance_R2);   
   if( Close[0] > Resistance_R2  && STOP_LOSS == TWO)
   {
      Label("StopLOSS  R2 Hit= "+ string(Resistance_R2), clrDeepPink);
      showNotification("StopLOSS  R2 Hit= "+ string(Resistance_R2));
      UpdateStoploss(Symbol(),Resistance_R2,getCurrentCandleSell(renko));
      return true;
   }
      
   /*if(Close[0] < Support_S2 )
      Label("Take Profit S2 Hit!,"+ string(Support_S2), clrMediumSpringGreen); */
   
   
   if(Close[0] > Resistance_R1 && STOP_LOSS == ONE)
   {
       Label("StopLOSS R1 Hit!,"+ string(Resistance_R1), clrWhite);
       showNotification("StopLOSS R1 Hit!,"+ string(Resistance_R1));
       UpdateStoploss(Symbol(),Resistance_R1,getCurrentCandleSell(renko));
       return true;
   }
   
   return false;
       
  /* if(Close[0] < Support_S1 ) 
      Label("Take Partial Profit S1 Hit!,"+ string(Support_S1), clrMediumSpringGreen);*/
 }
 
 bool StopLossBuy()
 {
    if(Support_S1 == 0 || Support_S2 == 0 ){
      PivotPoints();
      return false;
      }
   UpdateStoploss(Symbol(),Support_S2,getCurrentCandleBuy(renko));
   StopLossIndicator(Support_S2);   
   if(Close[0] < Support_S2 &&  STOP_LOSS == TWO )
   {
      Label("StopLOSS S2 = "+ string(Support_S2), clrDeepPink);
      showNotification("StopLOSS S2 = "+ string(Support_S2));
      return true;
   }
      
   /*if(Close[0] > Resistance_R2 )
      LabelADX("Take Profit R2 Hit!,"+ string(Resistance_R2), clrMediumSpringGreen);*/   
    
   if(Close[0] < Support_S1 && STOP_LOSS == ONE ) 
   {
      Label("StopLOSS S1 Hit!,"+ string(Support_S1), clrWhite);
      showNotification("StopLOSS S1 Hit!,"+ string(Support_S1));
      return true;
   }
   
  /* if(Close[0] > Resistance_R1 )
        LabelADX("Take Partial Profit  R1 Hit!,"+ string(Resistance_R1), clrMediumSpringGreen);*/
        
   return false;
}

bool  stopLossCalculateSell(double executedPrice)
{
   if(Open[0] < Open[1] && Close[0] < executedPrice)
   {
      PivotPoints();
      return true;
   }
   return true;
}

bool  stopLossCalculateBuy(double executedPrice)
{
   if(Open[0] > Open[1] && Close[0] > executedPrice)
   {
      PivotPoints();
      return true;
   }
   return true;
}

void calculateStopLossSell()
{     
   if(PRICE_EXECUTED == 0)
      return;

   //if(sell )
   {
      if(Close[0] >= sT && sT != 0.0)
     {
        CloseOrder(Symbol(),"BuyT");
        showNotification(Symbol()+":Stop Loss Hit !! SL = "+ string(sT)+":Open= " + Open[0]+ " Close= " + Close[0]);
        deleteAllObjects();
        LabelADXSlope("Stop Loss Hit !! SL = "+ DoubleToStr(sT), clrOrange );
        sT = 0;
        sell = false;
     }
     
    // if(Volume[0] > 1)
     {
        string stopL = sT == 0 ? "Waiting for New Candle" : DoubleToStr(sT)+ ":Open= " + Open[0]+ "Close= " + Close[0];
        LabelADXSlope("Trail Stoploss to =  " +string(stopL), clrOrange);
        //return;       
     }

      if( Close[0] < PRICE_EXECUTED && Open[0] < Open[1] && ( sT > Open[0] + sL || sT == 0 ) )
      {
          sT = Open[0]+sL;
          Print("StopLoss = 1"+ sT +  " OpenP= "+Open[0]+" CloseP= " + Close[0]+" " + Symbol());
          StopLossIndicator(sT);  
      }
      else if( ( (Close[0] > PRICE_EXECUTED) || (Close[0] == PRICE_EXECUTED) )&& sT == 0 )
      {
          sT = PRICE_EXECUTED + sL;  
          Print("StopLoss = 2 "+ sT + " PRICE_EXECUTED= "+PRICE_EXECUTED+ " CloseP= " + Close[0]+ " " + Symbol());
          StopLossIndicator(sT);  //StopLoss base Price for buy
      }
      else if( Close[0] + sL < sT && sT == 0)
      {
          sT = Open[1] + sL ;
          Print("StopLoss 3 = "+ sT + " OpenP= "+Open[1]+ " CloseP= " + Close[0]+ " " + Symbol());
          StopLossIndicator(sT); 
      }  
    
   }
 }


void IncrementStopLossBuy()
{
   if(PRICE_EXECUTED == 0)
     return;
   
   sT = prevStopLoss(Symbol());
   getIncrementStopLossBuy(PRICE_EXECUTED, renko,  sT);

      if(Close[0] <= sT && sT != 0.0){
        CloseOrder(Symbol(),"SellT");
        showNotification(Symbol()+"Buy:Smart Stop Loss Hit !! SL = "+ DoubleToStr(sT)+ ":Open= " + Open[0]+ " Close= " + Close[0] );
        deleteAllObjects();
        LabelADXSlope("Buy:StopLoss Hit !! SL = "+ DoubleToStr(sT), clrAquamarine );
        sT = 0;
        UpdateStoploss(Symbol(),0,0);
        UpdateRiskCandle(Symbol(),0);
        buy = false;
     }
     
    // if(Volume[0] > 1)
     {
        string stopL = sT == 0 ? "Waiting for New Candle" : DoubleToStr(sT)+ ":Open= " + Open[0]+ " Close= " + Close[0];
        LabelADXSlope("Trail Stoploss to =  " +string(stopL), clrOrange);
        //return;       
     }  
     StopLossIndicator(sT); 
}

void IncrementStopLossSell()
{
   if(PRICE_EXECUTED == 0)
     return;
     
   sT = prevStopLoss(Symbol());    
   getIncrementStopLossSell(PRICE_EXECUTED, renko , sT);
   StopLossIndicator(sT); 

      if(Close[0] >= sT && sT != 0.0){ 
        CloseOrder(Symbol(),"BuyT");
        showNotification(Symbol()+"Sell:Smart Stop Loss Hit !! SL = "+ DoubleToStr(sT)+ ":Open= " + Open[0]+ " Close= " + Close[0] );
        InsertLogs(Symbol(),"Place buy order:Smart Stop Loss Hit !! SL = "+ DoubleToStr(sT)+ ":Open= " + Open[0]+ " Close= " + Close[0] );
        deleteAllObjects();
        LabelADXSlope("Stop Loss Hit !! SL = "+ DoubleToStr(sT), clrAquamarine );
        sT = 0;
        UpdateStoploss(Symbol(),0,0);
        UpdateRiskCandle(Symbol(),0);
        sell = false;
     }
     
    // if(Volume[0] > 1)
     {
        string stopL = sT == 0 ? "Waiting for New Candle" : DoubleToStr(sT)+ ":Open= " + Open[0]+ " Close= " + Close[0];
        LabelADXSlope("Trail Stoploss to =  " +string(stopL), clrOrange);
        //return;       
     }  

} 

void takeProfitBuy()
{  
   if(PRICE_EXECUTED == 0)
     return;
    PivotPoints();
   //int sl_max_candle = takeProfit(Symbol());
   //if(sl_max_candle == 0)
   //  return;
     
   //int tP = sl_max_candle;//getTakeProfit(Symbol());
   double macd_curr = iMACD(Symbol(),FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_MAIN,0);
   double macd_prev = iMACD(Symbol(),FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_MAIN,1);
   double macd_prev_2 = iMACD(Symbol(),FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_MAIN,2);

   //double  takeProfit = (tP * renko);
      if( (  Open[0] < Open[1]) && Close[0] >= Resistance_R2 ){
        CloseOrder(Symbol(),"Sell");
        showNotification(Symbol()+"Buy:Smart Take Proft Hit !! TP = "+ DoubleToStr(Resistance_R2)+ ":Open= " + Open[0]+ " Close= " + Close[0] );
        deleteAllObjects();
        LabelADXSlope("Buy:Take Profit Hit !! TP = "+ DoubleToStr(Resistance_R2), clrAquamarine );
        sT = 0;
        UpdateStoploss(Symbol(),0,0);
        UpdateRiskCandle(Symbol(),0);
        buy = false;
        UpdateForceExit(Symbol());
     }
    LabelADXSlope("TP = "+ DoubleToStr(Resistance_R2)+" ST= "+ DoubleToStr(Support_S2), clrAquamarine );
   takeProfitIndicator(Resistance_R2);    
}

void takeProfitSell()
{
   if(PRICE_EXECUTED == 0)
     return;
   PivotPoints(); 
  // int sl_max_candle = takeProfit(Symbol());
   //if(sl_max_candle == 0)
     //return;
     
   //int tP = sl_max_candle;//getTakeProfit(Symbol());
   double macd_curr = iMACD(Symbol(),FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_MAIN,0);
   double macd_prev = iMACD(Symbol(),FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_MAIN,1);
   double macd_prev_2 = iMACD(Symbol(),FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_MAIN,2);  

   //double takeProfit = (tP * renko);
      if( (Open[0] > Open[1] )  && Close[0] <= Support_S2 ){ 
        CloseOrder(Symbol(),"Buy");
        showNotification(Symbol()+"Sell:Take Profit Hit !! TP = "+ DoubleToStr(Support_S2)+ ":Open= " + Open[0]+ " Close= " + Close[0] );
        InsertLogs(Symbol(),"Sell: Take Profit Hit !! TP = "+ DoubleToStr(Support_S2)+ ":Open= " + Open[0]+ " Close= " + Close[0] );
        deleteAllObjects();
        LabelADXSlope("Sell!Take Profit Hit !! TP = "+ DoubleToStr(Support_S2), clrAquamarine );
        sT = 0;
        UpdateStoploss(Symbol(),0,0);
        UpdateRiskCandle(Symbol(),0);
        sell = false;
        UpdateForceExit(Symbol());
     }
     LabelADXSlope("TP = "+ DoubleToStr(Support_S2)+" ST= "+ DoubleToStr(Resistance_R2), clrAquamarine );
   takeProfitIndicator(Support_S2);
} 

 
 void calculateStopLossBuy()
 {   
   if(PRICE_EXECUTED == 0)
      return;
   sL=getStopLossDiff(Symbol());  
   //if(buy )
   {  
      if(Close[0] <= sT && sT != 0.0){
        CloseOrder(Symbol(),"SellT");
        showNotification(Symbol()+":Stop Loss Hit !! SL = "+ DoubleToStr(sT)+ ":Open= " + Open[0]+ " Close= " + Close[0] );
        InsertLogs(Symbol(),"Place buy order:Smart Stop Loss Hit !! SL = "+ DoubleToStr(sT)+ ":Open= " + Open[0]+ " Close= " + Close[0] );
        deleteAllObjects();
        LabelADXSlope("Stop Loss Hit !! SL = "+ DoubleToStr(sT), clrAquamarine );
        sT = 0;
        buy = false;
     }
     
    // if(Volume[0] > 1)
     {
        string stopL = sT == 0 ? "Waiting for New Candle" : DoubleToStr(sT)+ ":Open= " + Open[0]+ " Close= " + Close[0];
        LabelADXSlope("Trail Stoploss to =  " +string(stopL), clrOrange);
        //return;       
     }

      if( Close[0] > PRICE_EXECUTED && Open[0] > Open[1] && (sT < Open[0] - sL || sT == 0 )  )
      {
          sT = Open[0]-sL;
          Print("StopLoss 1= "+ sT + " OpenP= "+Open[0]+ " CloseP= " + Close[0]+" " + Symbol());
          StopLossIndicator(sT);
      }
      else if( Close[0] <= PRICE_EXECUTED && sT == 0 )
      {
          sT = PRICE_EXECUTED - sL;
          Print("StopLoss 2 = "+ sT + " PRICE_EXECUTED= "+PRICE_EXECUTED+ " CloseP= " + Close[0]+" " + Symbol());
          StopLossIndicator(sT);   //StopLoss base Price for buy
      }
      else if( Close[0] - sL > sT && sT == 0 )
      {
          sT = Open[1] - sL ;
          Print("StopLoss 3 = "+ sT + " OpenP= "+Open[1]+ " CloseP= " + Close[0]+ " " + Symbol());
          StopLossIndicator(sT);
      }
   
   }
}

bool BuyEntry()
{
   /*if(ENTRY_TYPE == ADX_CENTER  && ADXStrongBuy() )
   { 
      return true;
   }
   
   if( (ENTRY_TYPE == CROSS)   && ( PlusVI1 > MinusVI1 )  ) 
   {
      getCrossOverCandleHighValue();
      if(Close[0] > highVal)
         return true;
         
      return true;
   }

   if( (ENTRY_TYPE == PointOne) && (PlusVI1 > VI_EnterTrendVal) && ADXBuyEntry())
   {
      getCrossOverCandleHighValue();
      return true;
   }
    
   if( ENTRY_TYPE == MA && ( MA_Entry() == buy_H1) )// && ADXBuyEntry() ) && ( MinusVI1 < PlusVI1 ) )
   {
      getMACrossOverCandleHighValue();
      return true;
   }*/
   if( ENTRY_TYPE == candle && CandleOpenBuy() ) // && MathAbs(PlusVI1 - MinusVI1) > 0.2 && ADX > ADX_VALUE )
   {      
      if( ADX <= ADX_VALUE )
        return true;
      if(ADX > ADX_VALUE)
       return true; 
   }

   if( ENTRY_TYPE == macdMA   )
   {
     //if(!buy)
        
        
     // HystrisisIndicator(clrLimeGreen,"CandleMid", Bid);
      //if( Bid >= CandleMid())
      {
         HystrisisIndicator(clrLimeGreen,"CandleMid", Ask);         
      }
      if( Close[0] < Resistance_R2 && CandleOpenBuyEntry() )
      {
         Label("BUY CANDLE FORMED!!!!!"+Symbol(),clrLightSkyBlue);
         return true;
      }
      else if( !sell) {
         Label("WAITING FOR BUY CANDLE "+Symbol() , clrLightSkyBlue);
      }
   }
   return false;
}

bool SellEntry() 
{  
  /* if(ENTRY_TYPE == ADX_CENTER  && ADXStrongSell() )
   { 
      return true;
   }
   
   if( ENTRY_TYPE == CROSS && ( MinusVI1 > PlusVI1 ) /* > VI_DIFF  )   //  /*&& ( getStochasticStatus(Symbol()) == Slope_Down  || getStochasticStatus(Symbol()) == overBought )  )*/
  /* {
      getCrossOverCandleLowValue();
      if( Close[0] <= lowVal && lowVal != 0.0 )
        return true;
       
      return true;
   }

   if( ENTRY_TYPE == PointOne && MinusVI1 > VI_EnterTrendVal && ADXSellEntry() )
   {
      getCrossOverCandleLowValue();
      return true;
   }
   
   if( ENTRY_TYPE == MA && ( MA_Entry() == sell_H1 ) ) // && ADXSellEntry() ) && ( MinusVI1 > PlusVI1 ) )
   {
      getMACrossOverCandleLowValue();
      return true;
   }*/
   
   if( ENTRY_TYPE == candle  && CandleOpenSellEntry() )//&& MathAbs(PlusVI1 - MinusVI1) > 0.2 && ADX > ADX_VALUE  )
   {    
      if( ADX <= ADX_VALUE && ADXSlope() == Up )
        return true;
      if(ADX > ADX_VALUE )
       return true;  
   }
   if( ENTRY_TYPE == macd   )
   {
      return true;
   }
   if( ENTRY_TYPE == macdMA   )
   {
        
     // HystrisisIndicator(clrLimeGreen,"CandleMid", Bid);
      //if( Bid >= CandleMid())

         HystrisisIndicator(clrLimeGreen,"CandleMid", Bid);
         
      if( Close[0] > Support_S2 && CandleOpenSellEntry() )
      {
         Label(CandleOpenSellEntry()+" SELL CANDLE FORMED!!!!!"+Symbol(), clrRed);
         return true;
      }
      else if( !buy){
         Label(CandleOpenSellEntry()+" WAITING FOR SELL CANDLE "+Symbol() , clrRed);
        }
   }
   return false;
}

bool isExitBuy()
{
  /* if(EXIT_TYPE == ADX_CENTER  && CandleOpenSell() )
   { 
      return true;
   }
   
   if( EXIT_TYPE == CROSS && MinusVI1 > VI_DownTrendVal && PlusVI1 < VI_EnterTrendVal ) //( ADX_MinusDI - ADX_PlusDI > 1 ||  MinusVI1 - PlusVI1 > VI_DIFF  ) )
   {     
       return true;
   }

   if( EXIT_TYPE == PointOne && ( ADX_MinusDI - ADX_PlusDI > 1 || PlusVI1 < MinusVI1  ) )
   {
      return true;
   }*/
   
   if( EXIT_TYPE == CANDLE && CandleOpenSell() ) //&& TrendExit() == sell_H1 )
   {    
       return true;  
   }
   
   if( EXIT_TYPE == MACDma &&  TrendExit() == sell_H1 )
   {
      return true;
   }
   
   if( EXIT_TYPE == MACD && ( MACDExit() == sell_H1 || MA_Exit() == sell_H1 ) )
   {
      return true;
   }
   
   if( EXIT_TYPE == MA &&  MA_Exit() == sell_H1 )
   {
      return true;
   }
   return false;
}
bool isExitSell()
{
  /* if(EXIT_TYPE == ADX_CENTER  && CandleOpenBuy() )
   { 
      return true;
   }
   
   if( EXIT_TYPE == CROSS && PlusVI1 > VI_DownTrendVal && MinusVI1 < VI_EnterTrendVal) //( ADX_PlusDI - ADX_MinusDI > 1 || PlusVI1 - MinusVI1 > VI_DIFF ) )
   {     
      return true;
   }

   if( EXIT_TYPE == PointOne && (  ADX_PlusDI - ADX_MinusDI > 1 || PlusVI1 > MinusVI1 ) )
   {
      return true;
   }*/
   
   if( EXIT_TYPE == CANDLE &&  CandleOpenBuy() ) // && TrendExit() == buy_H1)
   {    
       return true;  
   }
   
   if( EXIT_TYPE == MACDma &&  TrendExit() == buy_H1)
   {
      return true;
   }
   
   if( EXIT_TYPE == MACD &&  (MACDExit() == buy_H1 || MA_Exit() == buy_H1 ) )
   {
      return true;
   }
   
   if( EXIT_TYPE == MA &&  MA_Exit() == buy_H1 )
   {
      return true;
   }
   return false;
}
bool ADXStrongBuy()
{
   return ( ADXSlope() == Up && DI_Plus_Slope() == Up && DI_Minus_SLope() == Down  && ( ADX_PlusDI - ADX > 2 ) && ( ADX - ADX_MinusDI > 2 ) );
}

bool ADXStrongSell()
{
   return ( ADXSlope() == Up && DI_Plus_Slope() == Down && DI_Minus_SLope() == Up && ( ADX_MinusDI - ADX > 2 ) && ( ADX - ADX_PlusDI > 2 ) );
}
bool ADXBuyEntry()
{
  return ( ADX_PlusDI > ADX_MinusDI ||  DI_Plus_Slope() == Up || ( DI_Plus_Slope() == Up && DI_Minus_SLope() == Down ) );
}

bool ADXSellEntry()
{
  return ( ADX_PlusDI < ADX_MinusDI || DI_Minus_SLope() == Up || ( DI_Plus_Slope() == Down && DI_Minus_SLope() == Up ) );
}  

string MA_Entry()
{
   Refresh_MA_Value();

   if( /*ma_fast_prev > ma_slow_prev &&*/ ma_slow_current > ma_fast_current )
      return sell_H1;
   if( /*ma_slow_prev > ma_fast_prev &&*/ ma_fast_current > ma_slow_current )
      return buy_H1; 
      
   return NULL;  
}

string MA_Exit()
{
   Refresh_MA_Value();

   if( /*ma_slow_prev > ma_fast_prev &*/ ma_fast_current > ma_slow_current )
      return buy_H1;
   if( /*ma_fast_prev > ma_slow_prev &&*/ ma_slow_current > ma_fast_current )
      return sell_H1; 
      
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
   

   PivotIndicator();
}

bool StochSlopeBuy()
{
  double st_main=iStochastic(NULL,FOLLOW_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,0);
  double st_signal=iStochastic(NULL,FOLLOW_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,0);
  
  return (st_main - st_signal >= ST_DIFF);
}

/*double CandleMid()
{
  return (Open[0]+Close[0])/2;
}*/

bool CandleOpenBuy()
{
//if( Open[0] > Open[1])
//    LabelOpen( Open[0]-Open[1] + " Buy  " + Symbol(), clrAliceBlue);
    
   return  Open[0] > Open[1] ;// exit for sell
   //( (NormalizeDouble(Open[0],2) > NormalizeDouble(Open[1],2)) );//|| ( NormalizeDouble(Open[0]-Open[1] , 2) == 0) ) ; // &&
}

bool CandleOpenBuyEntry()
{
   return Open[0] > Open[1] ;
}

bool StochSlopeSell()
{
  double st_main=iStochastic(NULL,FOLLOW_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,0);
  double st_signal=iStochastic(NULL,FOLLOW_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,0);
  
  return (st_signal - st_main >= ST_DIFF);    //please put > and == in seperate condition
}

bool CandleOpenSell()
{
   //if( Open[1] > Open[0])
   //   LabelOpen( Open[1]-Open[0] + " Sell " + Symbol(), clrAliceBlue);
      
   return  Open[0] < Open[1];//exit for buy
   // ( (NormalizeDouble(Open[0], 2) < NormalizeDouble(Open[1], 2)) );//|| ( NormalizeDouble(Open[0]-Open[1], 2) == 0 ) ) ;//
}

bool CandleOpenSellEntry()
{
   return Open[0] <  Open[1];
}

void LabelOrderStatus()
{
  string strMsg;
  if(buy || sell)
     strMsg = buy?  ("BUY_Executed at "+string(NormalizeDouble(PRICE_EXECUTED,2))+",Suggested " + string(NormalizeDouble(Ask,2))) :(" SELL_EXECUTED at = "+string(NormalizeDouble(PRICE_EXECUTED,2))+",Suggested " + string(NormalizeDouble(Ask,2)));
  if(!buy && !sell)
     strMsg ="BUY = "+string(buy)+", SELL = "+string(sell)+", Exit Suggested="+string(NormalizeDouble(Ask, 2))+",Executed= " + string(NormalizeDouble(PRICE_EXECUTED,2)) ;
  
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

/*void LabelADX(string text, color clr)
{
    long x = 300;
    long y = 150;
    if(label_created_adx)
      label_created_adx = LabelTextColorChange(0,InpNameADXLabel,text,clr);
   else
      label_created_adx = ShowLabelOrder(text,clr, InpNameADXLabel,x ,y, CORNER_RIGHT_LOWER );
}*/

void LabelMaterTableInfo(string text, color clr)
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

string            InpNameMALabel = "LabelMA";
void LabelMAParam(string text, color clr)
{
   long x = 150;
   long y = 300;
    if(label_created_ma)
       label_created_ma = LabelTextColorChange(0,InpNameMALabel,text,clr);
   else
      label_created_ma = ShowLabelOrder(text,clr, InpNameMALabel,x ,y, CORNER_RIGHT_LOWER );
}

void LabelHour()
{
    string hysStatus = NULL;
   if( hysDeActivated == true ) 
       hysStatus = " Hyst Deactivated " ;
   else if( hysDeActivated == false ) 
       hysStatus = " Hyst Active";    
  
   if(isLabel_Hour_Created)
      isLabel_Hour_Created = Trend() == buy_H1? LabelTextColorChange(0,"hour_label","Trend = " +PrintTrend()+hysStatus,clrLightBlue):LabelTextColorChange(0,"hour_label","Trend = " +PrintTrend()+hysStatus,clrRed);
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
         //LabelADX("Low = " + lowVal,clrYellow);
         break;
      }
   }
}

void getMACrossOverCandleLowValue()
{
   for(int i=0; i<Bars ; i++ )
   {  
       double ma_plus_current=NormalizeDouble(iMA(NULL,0,MA_FAST,MA_MovingShift_short,MA_METHOD,PRICE_CLOSE,i),2);
       double ma_minus_current=NormalizeDouble(iMA(NULL,0,MA_SLOW,MA_MovingShift_long,MA_METHOD,PRICE_CLOSE,i),2);
       double ma_plus_prev=NormalizeDouble(iMA(NULL,0,MA_FAST,MA_MovingShift_short,MA_METHOD,PRICE_CLOSE,i+1),2);
       double ma_minus_prev=NormalizeDouble(iMA(NULL,0,MA_SLOW,MA_MovingShift_long,MA_METHOD,PRICE_CLOSE,i+1),2);
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
       double ma_plus_current=NormalizeDouble(iMA(NULL,0,MA_FAST,MA_MovingShift_short,MA_METHOD,PRICE_CLOSE,i),2);
       double ma_minus_current=NormalizeDouble(iMA(NULL,0,MA_SLOW,MA_MovingShift_long,MA_METHOD,PRICE_CLOSE,i),2);
       double ma_plus_prev=NormalizeDouble(iMA(NULL,0,MA_FAST,MA_MovingShift_short,MA_METHOD,PRICE_CLOSE,i+1),2);
       double ma_minus_prev=NormalizeDouble(iMA(NULL,0,MA_SLOW,MA_MovingShift_long,MA_METHOD,PRICE_CLOSE,i+1),2);
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
         //LabelADX("High = " + highVal,clrYellow);
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
    Comment( "\n\n\n\n*****POWERED BY ROOPSIKHA*****"+"\n"+getStrHeader(header)+"\n"+strC);
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
     double Stochastic_Main=iStochastic(NULL,PERIOD_H1,5,3,3,MODE_EMA,0,MODE_MAIN,0);
     double Stochastic_Signal=iStochastic(NULL,PERIOD_H1,5,3,3,MODE_EMA,0,MODE_SIGNAL,0);
     //--- get Moving Average 
     ma_fast_current=NormalizeDouble(iMA(NULL,0,MA_FAST,MA_MovingShift_short,MA_METHOD,PRICE_CLOSE,0),2);
     ma_slow_current=NormalizeDouble(iMA(NULL,0,MA_SLOW,MA_MovingShift_long,MA_METHOD,PRICE_CLOSE,0),2);
     ma_fast_prev=NormalizeDouble(iMA(NULL,0,MA_FAST,MA_MovingShift_short,MA_METHOD,PRICE_CLOSE,1),2);
     ma_slow_prev=NormalizeDouble(iMA(NULL,0,MA_SLOW,MA_MovingShift_long,MA_METHOD,PRICE_CLOSE,1),2);
     double MA_Slow=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_Slow_MovingPeriod,MA_MovingShift_long,MODE_SMA,PRICE_OPEN,0);
     double diff_candle = NormalizeDouble(Open[0],2)- NormalizeDouble(Open[1],2);
     double st_diff = Stochastic_Main-Stochastic_Signal;
     
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
    
   /*if(show){         
      LabelADX( strText, clrMagenta );
      LabelADXSlope( strTextSlope , clrMediumSpringGreen);
      }*/
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
   
   PlusVI1 = iCustom(NULL,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,0);
	PlusVI2 = iCustom(NULL,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_PLUSVI,1);
   MinusVI1 = iCustom(NULL,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,0);
   MinusVI2 = iCustom(NULL,FOLLOW_CHART_TIME_FRAME,"vortex-indicator",VI_Length,MODE_MINUSVI,1);
}

void Refresh_MA_Value()
{
   ma_fast_current=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_FAST,MA_MovingShift_short,MODE_EMA,PRICE_ACTION,0);
   ma_slow_current=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_SLOW,MA_MovingShift_long,MODE_EMA,PRICE_ACTION,0);
   ma_fast_prev=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_FAST,MA_MovingShift_short,MODE_EMA,PRICE_ACTION,1);
   ma_slow_prev=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_SLOW,MA_MovingShift_long,MODE_EMA,PRICE_ACTION,1);
}

string ADXSlope()
{
   if(ADX - ADX_1 > SLOPE && ADX_1 > ADX_2)
      return Up;
   else if( ADX_1 - ADX > SLOPE && ADX_1 < ADX_2)
      return Down;
   else 
      return "NEUTRAL";         
}

string DI_Minus_SLope()
{
   if(ADX_MinusDI - ADX_MinusDI_1 > SLOPE /*&& ADX_MinusDI_1 > ADX_MinusDI_2*/)
      return Up;
   else if(ADX_MinusDI_1 - ADX_MinusDI > SLOPE /*&& ADX_MinusDI_1 < ADX_MinusDI_2*/)
      return Down;
   else 
      return "NEUTRAL";      
}

string DI_Plus_Slope()
{
   if(ADX_PlusDI - ADX_PlusDI_1 > SLOPE /*&& ADX_PlusDI_1 > ADX_PlusDI_2*/)
      return Up;
   else if(ADX_PlusDI_1 - ADX_PlusDI > SLOPE /*&& ADX_PlusDI_1 < ADX_PlusDI_2*/)
      return Down;
   else 
     return "NEUTRAL";      
}
string getStochasticStatus(string CurrencyPair)
{
   double Stochastic_Main=iStochastic(CurrencyPair,FOLLOW_STOCHASTIC_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,0);
   double Stochastic_Signal=iStochastic(CurrencyPair,FOLLOW_STOCHASTIC_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,0);
   
   double Stochastic_Main_1=iStochastic(CurrencyPair,FOLLOW_STOCHASTIC_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,1);
   double Stochastic_Signal_1=iStochastic(CurrencyPair,FOLLOW_STOCHASTIC_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,1);

   
   if( Stochastic_Main > 80 && Stochastic_Signal > 80 )
   {
      //LabelADX(overBought,clrAliceBlue);
      return overBought;     
   }
   else if( Stochastic_Main < 20 && Stochastic_Signal < 20 )
   {
      //LabelADX(overSold,clrAliceBlue);
      return overSold;      
   }
   else if( Stochastic_Main > Stochastic_Main_1 && Stochastic_Signal > Stochastic_Signal_1 )
   {
     //LabelADX(Slope_Up,clrAliceBlue);
     return Slope_Up;
   }
   else if( Stochastic_Main < Stochastic_Main_1 && Stochastic_Signal < Stochastic_Signal_1 )
   {
    // LabelADX(Slope_Down,clrAliceBlue);
     return Slope_Down;
   }
   else
   {
     //LabelADX(Slope_Neutral,clrAliceBlue);
     return Slope_Neutral;
   }
}
string PrintTrend()
{
   //double MA_Slow=iMA(NULL,FOLLOW_CHART_TIME_FRAME,MA_Slow_MovingPeriod,0,MODE_SMA,PRICE_OPEN,0);
   string trend = NULL ,sym = Symbol();
   double Stochastic_Main=iStochastic(NULL,FOLLOW_STOCHASTIC_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_MAIN,0);
   double Stochastic_Signal=iStochastic(NULL,FOLLOW_STOCHASTIC_CHART_TIME_FRAME,5,3,3,MODE_EMA,0,MODE_SIGNAL,0);
   
   double macd = NormalizeDouble(iMACD(sym,FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_MAIN,0),3);
   double macd_signal = NormalizeDouble(iMACD(sym,FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_SIGNAL,0),3);
   double macd_diff = DoubleToStr(macd-macd_signal,2);
   Refresh_MA_Value();
   //if( EXIT_TYPE == MACDma  )
   {
      
   }
   if( EXIT_TYPE == MACD )
   {
     trend = MACDExit();
   }
   if( EXIT_TYPE == MA )
   {
     trend = MA_Exit();
   }
   if( EXIT_TYPE == CANDLE)
   {
      if( CandleOpenBuy() )
      {
        Label("BUY CANDLE", clrAqua);
      }
      if( CandleOpenSell() )
      {
        Label("SELL CANDLE", clrAqua);
      }
   }
    
   
   trend = Trend();
   /* if( (Stochastic_Signal > Stochastic_Main) && (getStochasticStatus(sym) == overBought || getStochasticStatus(sym) == Slope_Down) ) //Trend() == sell_H1)
    {
       trend = sell_H1;
    }
    else if( (Stochastic_Main > Stochastic_Signal ) && (getStochasticStatus(sym) == overSold || getStochasticStatus(sym) == Slope_Up) )//Trend() == buy_H1)
    {
       trend = buy_H1;
    }
    else 
        trend = Slope_Neutral;
   /*if( Close[0] > MA_Slow )
   {
     trend = buy_H1;
   }
   else if( Close[0] < MA_Slow )
   {
     trend = sell_H1;
   }*/
  string ma_diff = DoubleToStr((ma_fast_current - ma_slow_current),2);
   if(trend == NULL)
      return "Search(MACD = "+(macd_diff)+ ",MA = " + ma_diff+ trend+")";
   else 
     return trend+"(MACD = " + (macd_diff)+" " + ",MA = " + ma_diff+")";   
}


string Trend()
{
   string trend = NULL,sym = Symbol();
   
   double macd = iMACD(sym,FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_MAIN,0);
   double macd_signal = iMACD(sym,FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_SIGNAL,0);
   

   if( macd > 0 && macd_signal > 0 && macd_signal < macd && MA_Entry() == buy_H1 )
   {
       trend = buy_H1;
   }
   else if( macd > 0 && macd_signal > 0 && macd_signal > macd && MA_Entry() == sell_H1 && weakTrend )
   {
       trend = sell_H1;
   }
   else if( macd < 0 && macd_signal < 0 && MathAbs(macd_signal) < MathAbs(macd) && MA_Entry() == sell_H1 )
   {
       trend = sell_H1;
   }   
   else if( macd < 0 && macd_signal < 0 && MathAbs(macd_signal) > MathAbs(macd) && MA_Entry() == buy_H1  && weakTrend)
   {
       trend = buy_H1;
   }
   
   return trend;   
}

string MACDExit()
{
   string trend = NULL,sym = Symbol();
   
   double macd = iMACD(sym,FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_MAIN,0);
   double macd_signal = iMACD(sym,FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_SIGNAL,0);
    
   if( macd > 0  && macd_signal > 0 && macd_signal < macd )
   {
     trend = buy_H1;
   }
   else if( macd > 0 && macd_signal > 0 && macd_signal > macd ) // &&  )
   {
     trend = sell_H1;
   }
   else if( macd < 0 && macd_signal < 0 && MathAbs(macd_signal) < MathAbs(macd) )
   {
     trend = sell_H1;
   }   
   else if( macd < 0 && macd_signal < 0 && MathAbs(macd_signal) > MathAbs(macd) ) // && )
   {
      trend = buy_H1;
   }
   
  return trend;
  
}

string TrendExit()
{
   string trend = NULL,sym = Symbol();
   
   double macd = iMACD(sym,FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_MAIN,0);
   double macd_signal = iMACD(sym,FOLLOW_CHART_TIME_FRAME,38,120,FILTER,PRICE_CLOSE,MODE_SIGNAL,0);
   
   //if( MathAbs(macd_signal) < 1
   //double macd_hys = getHystrisis(sym);
   if(  macd_signal > 0 && macd_signal < macd && MA_Exit() == buy_H1 )
   {
       trend = buy_H1;
   }
   if(  macd_signal > 0 && macd_signal > macd && MA_Exit() == sell_H1 ) // &&  )
   {
       trend = sell_H1;
   }
   if( macd_signal < 0 && MathAbs(macd_signal) < MathAbs(macd) && MA_Exit() == sell_H1)
   {
       trend = sell_H1;
   }   
   if(  macd_signal < 0 && MathAbs(macd_signal) > MathAbs(macd)&& MA_Exit() == buy_H1 ) // && )
   {
       trend = buy_H1;
   }
   
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

 
/*void Buy(double Lots)
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
  }*/
  
/*void Sell(double Lots)
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
}*/

/*void CloseOrder()
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
*/
//+------------------------------------------------------------------+