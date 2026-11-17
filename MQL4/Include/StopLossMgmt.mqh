//+------------------------------------------------------------------+
//|                                                 StopLossMgmt.mqh |
//|                                  Copyright 2018, Roopsikha Yadav |
//|                              https://github.com/roopsikhayadav28 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Roopsikha Yadav"
#property link      "https://github.com/roopsikhayadav28"
#property strict

#include <SQLOperations.mqh>
#include <labelUI.mqh>
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

static int RISK = -1;
int curr_candle_risk = 0,count; 
double sVar= 0;

double stopLossBuy(double price_executed, double candle_size, double &stopLoss)
{
   int candleCount = getCurrentCandleBuy(candle_size);
   if(candleCount == -1)
     return 0;
    
   string data[1][3];
   getSmartStopLoss(Symbol(),data);
   int sl_max_candle = data[0][0];
   int sl_decrement_candle = data[0][1];
   int min_candle =data[0][2];
   ArrayFree(data);
   double prevStopLoss = prevStopLoss(Symbol());
     if( Close[0] < price_executed && stopLoss == 0 &&  prevStopLoss == 0) // if price is btw less than close price or high price of current csndle if stoploos is 0
      {
          Alert(Symbol() + "stoploss is = " + stopLoss + " Prev = "+ prevStopLoss);
          sVar = sl_max_candle * candle_size;
          stopLoss = price_executed - sVar;
          UpdateStoploss(Symbol(),stopLoss, candleCount);
          Print("StopLoss 1 = "+ stopLoss + " price_executed= "+price_executed+ " CloseP= " + Close[0]+" " + Symbol());
          StopLossIndicator(stopLoss);   //StopLoss base Price for buy
          RISK = sl_max_candle;
          UpdateRiskCandle(Symbol(),RISK);
          count = candleCount;
          InsertLogs(Symbol(),"Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", stoploss = "+stopLoss+ ", PrevStoploss = "+prevStopLoss+ " , Price executed = "+ price_executed);
             //SendNotificationToMobile(Symbol()+ " Candle Count = " + count );      
      }
     else if( price_executed < Close[0] )
     {           
         curr_candle_risk = candleCount/sl_decrement_candle;;
         sVar = ( sl_max_candle - curr_candle_risk )* candle_size;
         double newStoploss = Open[0] - sVar;
         if( sVar < 1 ){
            sVar = candle_size*min_candle;
            newStoploss = Open[0] - sVar;
            //Alert(Symbol() + " MIN RISK");
          } 
                      
         if(  sVar > 0 && newStoploss > prevStopLoss )  // new stoploss > prev stoploss
         { 
             stopLoss = newStoploss;
             UpdateStoploss(Symbol(),stopLoss, candleCount);
             StopLossIndicator(stopLoss);   //StopLoss base Price for buy
             count = candleCount;
             RISK =  sVar/candle_size;;
             UpdateRiskCandle(Symbol(),RISK);        
            // Alert(Symbol()+ "StopLoss Candle Count = " + count + ", candle Risk left = " + string(RISK)  ); 
             LabelOpen("Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(RISK), clrLightBlue );
             string logs= " Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(RISK)+ ", stoploss = "+stopLoss+ ", PrevStoploss = "+prevStopLoss+ " , Open Price executed = "+ getOpenPriceExecuted(Symbol());
             InsertLogs(Symbol(),logs);          
         }
         else
            stopLoss = prevStopLoss;
           
        /* else if( (candleCount < sl_decrement_candle && stopLoss == 0 ) )
         {
            sVar = sl_max_candle * candle_size;
            stopLoss = price_executed - sVar;
            UpdateStoploss(Symbol(),stopLoss, candleCount);
            Print("StopLoss 3 = "+ stopLoss + " price_executed= "+price_executed+ " CloseP= " + Close[0]+" " + Symbol());
            StopLossIndicator(stopLoss);   //StopLoss base Price for buy  
            int count = candleCount;
             //SendNotificationToMobile(Symbol()+ " Candle Count = " + count ); 
         }*/
     } 
     
     //if(Volume[0] < 1)
     {
     count = candleCount;
     string risk= RISK == -1 ? "Not calculated" : string(getPrevCandleRisk(Symbol()));
     LabelOpen("Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(risk), clrPink );
     }
     return stopLoss;
}

double stopLossSell(double price_executed, double candle_size,double &stopLoss)
{   
   int candleCount = getCurrentCandleSell(candle_size);
   if(candleCount == -1)
     return 0 ;
     
    string data[1][3];
   getSmartStopLoss(Symbol(),data);
   int sl_max_candle = data[0][0];
   int sl_decrement_candle = data[0][1];
   int min_candle =data[0][2];
   ArrayFree(data);
   double prevStopLoss = prevStopLoss(Symbol());  
     if( Close[0] > price_executed && stopLoss == 0 && prevStopLoss== 0  ) // if price is btw less than close price or high price of current csndle if stoploos is 0
      {
          Alert(Symbol() + "stoploss is = " + stopLoss + " Prev = "+ prevStopLoss);
          sVar = sl_max_candle * candle_size;
          stopLoss = price_executed + sVar;
          UpdateStoploss(Symbol(),stopLoss, candleCount);
          Print("StopLoss 1 = "+ stopLoss + " price_executed= "+price_executed+ " CloseP= " + Close[0]+" " + Symbol());
          RISK = sl_max_candle;
          UpdateRiskCandle(Symbol(),RISK);
          StopLossIndicator(stopLoss);   //StopLoss base Price for buy
          count = candleCount;
           InsertLogs(Symbol(),"Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", stoploss = "+stopLoss+ ", PrevStoploss = "+prevStopLoss+ ", Price Executed= "+ price_executed);
             //SendNotificationToMobile(Symbol()+ " Candle Count = " + count ); 
      }
     else if( price_executed > Close[0] )
     {         
         curr_candle_risk = candleCount/sl_decrement_candle;;
         sVar = ( sl_max_candle - curr_candle_risk )* candle_size;
         double newStoploss = Open[0] + sVar;
         if( sVar < 1 ){
            sVar = candle_size*min_candle;
            newStoploss = Open[0] + sVar;
            //Alert(Symbol() + " MIN RISK");
          }          
         if(  sVar > 0 && newStoploss < prevStopLoss )  // new stoploss < prev stoploss
         { 
             stopLoss = newStoploss;
             UpdateStoploss(Symbol(),stopLoss, candleCount);
             StopLossIndicator(stopLoss);   //StopLoss base Price for buy
             count = candleCount;             
            // Alert(Symbol()+ "StopLoss Candle Count = " + count + ", candle Risk left = " + string(RISK)  );
             RISK =  sVar/candle_size;
             UpdateRiskCandle(Symbol(),RISK);
             LabelOpen("Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(RISK), clrLightPink );
             string logs= " Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(RISK)+ ", stoploss = "+stopLoss+ ", PrevStoploss = "+prevStopLoss+ " , Open Price executed = "+ getOpenPriceExecuted(Symbol());
             InsertLogs(Symbol(),logs);;         
         }
         else
            stopLoss = prevStopLoss;
         /*else if( (candleCount < sl_decrement_candle && stopLoss == 0 ) )
         {
            sVar = sl_max_candle * candle_size;
            stopLoss = price_executed + sVar;
            UpdateStoploss(Symbol(),stopLoss,candleCount);
            Print("StopLoss 3 = "+ stopLoss + " price_executed= "+price_executed+ " CloseP= " + Close[0]+" " + Symbol());
            StopLossIndicator(stopLoss);   //StopLoss base Price for buy
            int count = candleCount;
            //SendNotificationToMobile(Symbol()+ " Candle Count = " + count );
         }*/
     } 
     //if(Volume[0] < 1)
     {
        count = candleCount;
        string risk= RISK == -1 ? "Not calculated" : string(getPrevCandleRisk(Symbol()) );
        LabelOpen("Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(risk), clrPink );
     }
     return stopLoss;
}

void getIncrementStopLossBuy(double price_executed, double candle_size, double &stopLoss)
{
   int candleCount = getCurrentCandleBuy(candle_size);
   if(candleCount == -1)
       return;
    
   string data[1][3];
   getSmartStopLoss(Symbol(),data);
   int sl_max_candle = data[0][0];
   int sl_decrement_candle = data[0][1];
   int sl_min_candle =data[0][2];
   ArrayFree(data);
    
   curr_candle_risk = candleCount/sl_decrement_candle;
   
   if( curr_candle_risk == 0 && stopLoss == 0 && prevStopLoss(Symbol()) == 0)
   {
      sVar = sl_min_candle * candle_size;
      stopLoss = Open[0] - sVar;
      RISK =  sl_min_candle;
      UpdateRiskCandle(Symbol(),RISK);
      UpdateStoploss(Symbol(),stopLoss,candleCount);
      StopLossIndicator(stopLoss);
      LabelOpen("Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(RISK), clrLightBlue );
      string logs= " Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(RISK)+ ", stoploss = "+stopLoss+ ", PrevStoploss = "+prevStopLoss(Symbol())+ " , Open Price executed = "+ getOpenPriceExecuted(Symbol());
      InsertLogs(Symbol(),logs);
      return;
   }                   
   else if(  curr_candle_risk > 0 && curr_candle_risk+sl_min_candle < sl_max_candle && curr_candle_risk+sl_min_candle > getPrevCandleRisk(Symbol()) )  // new stoploss > prev stoploss
   { 
       sVar = ( sl_min_candle + curr_candle_risk ) * candle_size;
       stopLoss = Open[0]-sVar;
       StopLossIndicator(stopLoss);   //StopLoss base Price for buy
       count = candleCount;
       RISK =  sVar/candle_size;
       UpdateStoploss(Symbol(),stopLoss, candleCount);
       UpdateRiskCandle(Symbol(),RISK);        
      // Alert(Symbol()+ "StopLoss Candle Count = " + count + ", candle Risk left = " + string(RISK)  ); 
       LabelOpen("Candle:Inc= " + (count)+",Max Risk= " +sl_max_candle+", current Risk= "+(RISK), clrLightBlue );
       string logs= " Candle:Inc= " + (count)+",Max Risk= " +sl_max_candle+", current Risk= "+(RISK)+ ", stoploss = "+stopLoss+ ", PrevStoploss = "+prevStopLoss(Symbol())+ " , Open Price executed = "+ getOpenPriceExecuted(Symbol());
       InsertLogs(Symbol(),logs);
       return;       
   }
   else if( curr_candle_risk+sl_min_candle > sl_max_candle )
   {
      sVar = sl_min_candle * candle_size;
      stopLoss = Open[0] - sVar;
      RISK =  sl_min_candle;
      UpdateRiskCandle(Symbol(),RISK);
      UpdateStoploss(Symbol(),stopLoss,candleCount);
      StopLossIndicator(stopLoss);
      LabelOpen("Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(RISK), clrLightBlue );
      string logs= " Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(RISK)+ ", stoploss = "+stopLoss+ ", PrevStoploss = "+prevStopLoss(Symbol())+ " , Open Price executed = "+ getOpenPriceExecuted(Symbol());
      InsertLogs(Symbol(),logs);
      return;
   }
   else
      stopLoss = prevStopLoss(Symbol());

 
     //if(Volume[0] < 1)
     {
     count = candleCount;
     int risk =  getPrevCandleRisk(Symbol());
     LabelOpen("Candle:Inc= " + getCurrentCandleBuy(candle_size)+",Max Risk= " +sl_max_candle+", current Risk= "+risk, clrPink );
     
     
     double newStoploss = Open[0] - (risk*candle_size);         
      if(  risk > 0 && newStoploss > prevStopLoss(Symbol()) )  // new stoploss < prev stoploss
      { 
          stopLoss = newStoploss;
          UpdateStoploss(Symbol(),stopLoss, candleCount);
          StopLossIndicator(stopLoss);   //StopLoss base Price for buy     
      }
     }
}

void getIncrementStopLossSell(double price_executed, double candle_size,double &stopLoss)
{   
 int candleCount = getCurrentCandleSell(candle_size);
   if(candleCount == -1)
     return ;
    
   string data[1][3];
   getSmartStopLoss(Symbol(),data);
   int sl_max_candle = data[0][0];
   int sl_decrement_candle = data[0][1];
   int sl_min_candle =data[0][2];
   ArrayFree(data);
   double prevStopLoss = prevStopLoss(Symbol());         
   curr_candle_risk = candleCount/sl_decrement_candle;
   
   if( curr_candle_risk == 0 && stopLoss == 0 && prevStopLoss(Symbol()) == 0)
   {
      sVar = sl_min_candle * candle_size;
      stopLoss = Open[0] + sVar;
      RISK =  sl_min_candle;
      UpdateRiskCandle(Symbol(),RISK);
      UpdateStoploss(Symbol(),stopLoss,candleCount);
      StopLossIndicator(stopLoss);
      LabelOpen("Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(RISK), clrLightBlue );
      string logs= " Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(RISK)+ ", stoploss = "+stopLoss+ ", PrevStoploss = "+prevStopLoss(Symbol())+ " , Open Price executed = "+ getOpenPriceExecuted(Symbol());
      InsertLogs(Symbol(),logs);
      return;
   }                   
   else if(  curr_candle_risk > 0 && (curr_candle_risk+sl_min_candle) < sl_max_candle && (curr_candle_risk+sl_min_candle) > getPrevCandleRisk(Symbol()) )  // new stoploss > prev stoploss
   { 
       sVar = ( sl_min_candle + curr_candle_risk ) * candle_size;
       stopLoss = Open[0]+sVar;
       UpdateStoploss(Symbol(),stopLoss, candleCount);
       StopLossIndicator(stopLoss);   //StopLoss base Price for buy
       count = candleCount;
       RISK =  sVar/candle_size;
       UpdateRiskCandle(Symbol(),RISK);        
      // Alert(Symbol()+ "StopLoss Candle Count = " + count + ", candle Risk left = " + string(RISK)  ); 
       LabelOpen("Candle:Inc= " + (count)+",Max Risk= " +sl_max_candle+", current Risk= "+(RISK), clrLightBlue );
       string logs= " Candle:Inc= " + (count)+",Max Risk= " +sl_max_candle+", current Risk= "+(RISK)+ ", stoploss = "+stopLoss+ ", PrevStoploss = "+prevStopLoss(Symbol())+ " , Open Price executed = "+ getOpenPriceExecuted(Symbol());
       InsertLogs(Symbol(),logs);
       return;       
   }
   else if( curr_candle_risk+sl_min_candle > sl_max_candle )
   {
       sVar = sl_min_candle * candle_size;
      stopLoss = Open[0] - sVar;
      RISK =  sl_min_candle;
      UpdateRiskCandle(Symbol(),RISK);
      UpdateStoploss(Symbol(),stopLoss,candleCount);
      StopLossIndicator(stopLoss);
      LabelOpen("Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(RISK), clrLightBlue );
      string logs= " Candle:Inc= " + string(count)+",Max Risk= " +sl_max_candle+", current Risk= "+string(RISK)+ ", stoploss = "+stopLoss+ ", PrevStoploss = "+prevStopLoss(Symbol())+ " , Open Price executed = "+ getOpenPriceExecuted(Symbol());
      InsertLogs(Symbol(),logs);
      return;
   }
   else
      stopLoss = prevStopLoss(Symbol());
 
     
     //if(Volume[0] < 1)
     {
     
     int risk = getPrevCandleRisk(Symbol());
     LabelOpen("Candle:Inc= " + (getCurrentCandleSell(candle_size))+",Max Risk= " +sl_max_candle+", current Risk= "+(risk), clrPink );      

     double newStoploss = Open[0] + risk * candle_size;         
      if(  risk > 0 && newStoploss < prevStopLoss(Symbol()) )  // new stoploss < prev stoploss
      { 
          stopLoss = newStoploss;
          UpdateStoploss(Symbol(),stopLoss, candleCount);
          StopLossIndicator(stopLoss);   //StopLoss base Price for sell      
      }
    } 
}


int getCurrentCandleBuy(double candle_size )
{
   double executed_open_price  = getOpenPriceExecuted(Symbol());
   if(executed_open_price == 0 || executed_open_price == -1)
   {
     Alert(Symbol() + "Price Executed  = " + executed_open_price);
      return -1 ;
   }
      
   double priceDiff = Open[0]- executed_open_price;
   if( candle_size == 0 )
      return -1;
      
   return priceDiff/candle_size;   
}

int getCurrentCandleSell(double candle_size)
{
   double executed_open_price  = getOpenPriceExecuted(Symbol());
   if(executed_open_price == 0 || executed_open_price == -1 )
   {
      Alert(Symbol() + " Price Executed  = " + executed_open_price);
      return -1 ;
   }
   double priceDiff = executed_open_price - Open[0];
   if( candle_size == 0 )
      return -1;
      
   return priceDiff/candle_size;   
}

void SendNotificationToMobile( string str ) 
{
  Alert("Mobile:" +str);
  SendNotification(str);
}

 bool label_open_diff = false;
 string InpNameStopLossInfo = "InpNameStopLossInfo";
void LabelOpen(string text, color clr)
{
   long x = 350;
   long y = 300;
    if(label_open_diff)
       label_open_diff = LabelTextColorChange(0,InpNameStopLossInfo,text,clr);
   else
      label_open_diff = ShowLabelOrder(text,clr, InpNameStopLossInfo,x ,y, CORNER_RIGHT_LOWER );
}