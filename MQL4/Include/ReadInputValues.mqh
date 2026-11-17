//+------------------------------------------------------------------+
//|                                              ReadInputValues.mqh |
//|                                  Copyright 2018, Roopsikha Yadav |
//|                              https://github.com/roopsikhayadav28 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Roopsikha Yadav"
#property link      "https://github.com/roopsikhayadav28"
#property strict
#include <SQLOperations.mqh>
#include <Arrow_Stop_Buy.mqh>
#include <labelUI.mqh>
#include <StopLossMgmt.mqh>
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
#define MAGICMA  20131111
#define mobile1  9810261185
bool  weakTrend = False,Executed_flag  = false, hysDeActivated = false;
double exeLtp,hys,renko, candleSize, priceDifference;
int MinimumQuantity;
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

//+------------------------------------------------------------------+ 
//| Class for storing the name of a character                        | 
//+------------------------------------------------------------------+ 
/*class ReadInputValues 
{    
   private:
   void Buy(string symbol);
   void Sell(string symbol);

   public:
   string data[1,7];   
   double Rate,MinimumQuantity,IncrementQuantity,MaximumQuantity,IncrementPriceDiff;
   //--- parameters for writing data to file 
   string terminal_data_path ; 
   string InpDirectoryName ;     // Folder name
   
   ReadInputValues(){terminal_data_path = TerminalInfoString(TERMINAL_DATA_PATH); 
                     InpDirectoryName = terminal_data_path+"\\MQL4\\Files\\"; }
   ~ReadInputValues()
   {
      ArrayFree(data);
   };
   
   void readInpValues(string symbol ,string &data[][]);

   void CloseOrder();
   void CloseOrder(int OrderType);
   bool logFile(string symbol,string str);
   int OpenFile(string InpFileName,int file_handle);
   void CloseFile(int file_handle);
   void OpenPosition(string symbol,double MinimumQuantity,double MaximumQuantity);
}; */

struct ReadInputValues 
{    
   string data[1,7];   
   double Rate,MinimumQuantity,IncrementQuantity,MaximumQuantity,IncrementPriceDiff,StopLoss,Hystrisis,WeekTrend;
   
   ReadInputValues(){}
   ~ReadInputValues(){ 
      ArrayFree(data);
      }
};


void readInpValues(string symbol ,string &data[][])
  {
//---
    //string str;
    //Sleep(5000);
    if(ReadSymbol(symbol,data))
    {
       int x = ArrayRange(data,0);
       int y = ArrayRange(data,1);

       /*for(int i=0;i<y;i++)
       {
          str = str+ data[0][i]+":";
       }*/
      // showNotification(str);
    }  
  } 


bool Buy(string symbol)
{  
   ReadInputValues riv;    
   readInpValues(symbol,riv.data);
   string sym = riv.data[0][0];
   if(sym != NULL)
   { 
      riv.Rate = StringToDouble(riv.data[0][1]); 
      riv.MinimumQuantity = StringToDouble(riv.data[0][2]);
      riv.IncrementQuantity = StringToDouble(riv.data[0][3]);
      riv.MaximumQuantity = StringToDouble(riv.data[0][4]);
      riv.IncrementPriceDiff = StringToDouble(getPriceDiff(symbol));
      
      return OpenPosition(symbol,riv.MinimumQuantity,riv.IncrementQuantity,riv.MaximumQuantity,riv.IncrementPriceDiff,"Buy");
   }
   return false;
}
  
bool Sell(string symbol)
{
   ReadInputValues riv;
   readInpValues(symbol,riv.data);
   string sym = riv.data[0][0];
   if(sym != NULL)
   {
      riv.Rate = StringToDouble(riv.data[0][1]); 
      riv.MinimumQuantity = StringToDouble(riv.data[0][2]);
      riv.IncrementQuantity = StringToDouble(riv.data[0][3]);
      riv.MaximumQuantity = StringToInteger(riv.data[0][4]);
      riv.IncrementPriceDiff = StringToDouble(getPriceDiff(symbol));
      
      return OpenPosition(symbol,riv.MinimumQuantity,riv.IncrementQuantity,riv.MaximumQuantity,riv.IncrementPriceDiff,"Sell");
   }
   return false;
}

void CloseOrder(string symbol,string orderType)
{
   ReadInputValues riv;
   readInpValues(symbol,riv.data);
   string sym = riv.data[0][0];
   if(sym != NULL)
   {
      riv.Rate = StringToDouble(riv.data[0][1]); 
      riv.MinimumQuantity = StringToDouble(riv.data[0][2]);
      riv.IncrementQuantity = StringToDouble(riv.data[0][3]);
      riv.MaximumQuantity = StringToInteger(riv.data[0][4]);
      riv.IncrementPriceDiff = StringToDouble(getPriceDiff(symbol));

      CloseOrder(symbol,riv.MinimumQuantity,riv.MinimumQuantity,riv.MaximumQuantity,riv.IncrementPriceDiff,orderType);
    }
}

string exit = "Exit ";
void CloseOrder(string symbol, double MinQty, double IncQty, double MaxQty,double priceDiff,string orderType)
{
    //--- check order type
    ReadInputValues riv;
    string str = NULL, exitType = orderType;
   double price = 0,AvgPrice = 0,lTP = 0;//(Bid+Ask)/2;  
   
   StringReplace(exitType,"D",""); 
   StringReplace(exitType,"F","");
   StringReplace(exitType,"T","");
   StringReplace(orderType,"SellF","ForceExit");
   StringReplace(orderType,"BuyF","ForceExit");
   StringReplace(orderType,"SellT","StopLoss");
   StringReplace(orderType,"BuyT","StopLoss");
   StringReplace(orderType,"Sell","Exit");
   StringReplace(orderType,"Buy", "Exit");
   
   if(exitType == "Buy"  )
   {
     price = NormalizeDouble(Ask,2);
   }
   else if(exitType == "Sell")
   {
     price = NormalizeDouble(Bid,2);
   }
   
   if(!getCurrentOpenQuantity(symbol,riv.data))
   {
      return;
   }
   int currentQty = StrToInteger(riv.data[0][0]);

   string currentEntry = riv.data[0][1];
   lTP = StrToDouble(riv.data[0][3]);
   AvgPrice = StrToDouble(riv.data[0][2]);
   // lTP = StrToDouble(riv.data[0][3]);
   double balance = StrToDouble(riv.data[0][4]);
   double lastExecutedPrice = StrToDouble(riv.data[0][6]);
   
   if( currentQty == 0 || currentQty < 0 )
      return;
      
   if(exitType == "Sell" && currentEntry =="Sell" && currentQty > 0)
   {
      return ;
   }
   if(exitType == "Buy" && currentEntry =="Buy" && currentQty > 0)
   {
      return ;
   }

   if(currentQty > 0 && (orderType == "Exit" || orderType == "ForceExit" || orderType == "StopLoss" ) )/*&& currentQty > MinQty) */
   {
      str = exitType+" Signal produced in "+string(symbol)+" at "+string(price)+" Qty "+ string(currentQty);
      if(logFile(symbol,str)){
         showNotification(str);
         //LabelOrder(str,clrBlue);         
         DrawArrow(exitType,price,PERIOD_CURRENT,exit);
         InsertTradeBook(symbol,TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),TimeToStr( (iTime(symbol,PERIOD_CURRENT,0)),TIME_DATE|TIME_SECONDS),exitType,(currentQty),price,"Confirm",orderType);
         double b = getProfitnLoss(currentEntry,AvgPrice,price,balance,currentQty);
         
         AvgPrice = 0;//getCloseAvgPrice(AvgPrice,price,MinQty,currentQty);
         UpdateOpenPosition(symbol,0,0,0,0,"--",0);
         UpdateBalance(symbol , b);
         UpdateSMS(str,Executed_flag,mobile1);
         UpdateUnrealisedBalanceAmount(currentEntry , 0, currentQty, FALSE, Close[0]);
         hys = getHystrisis(symbol);
         hysDeActivated == false;
      }
      return;
   }
   else if( (currentQty >  0) && currentQty > IncQty && currentQty > MinQty && (orderType == "ExitD" )  )
   {        
      if(!priceDiffEntry(Close[0],lastExecutedPrice,priceDiff,exitType) )
        return;
      
      showNotification("Decrement "+orderType +" position" + Symbol());  
      str = exitType+" Signal produced in "+string(symbol)+" at "+string(price)+" Qty "+ string(IncQty);
      if(logFile(symbol,str)){
         showNotification(str);
         //LabelOrder(str,clrBlue);         
         DrawArrow(exitType,price,PERIOD_CURRENT,exit);
         AvgPrice = getCloseAvgPrice(AvgPrice,price,IncQty,currentQty);
         double b = getProfitnLoss(currentEntry,AvgPrice,price,balance,currentQty);
         UpdateOpenPosition(symbol,(currentQty-IncQty),AvgPrice,-1,currentEntry,price,-1);
         InsertTradeBook(symbol,TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),TimeToStr( (iTime(symbol,PERIOD_CURRENT,0)),TIME_DATE|TIME_SECONDS),exitType,IncQty,price,"Confirm","Decrement Exit");
         UpdateBalance(symbol , b);
         UpdateSMS(str,Executed_flag,mobile1);
      }
      return;
   }
}

string entry = "Entry ";
bool OpenPosition(string symbol,double MinimumQty,double IncQty,double MaximumQty, double priceDiff,string EntryType)
{
   ReadInputValues riv;
   string str = NULL,arrow;
   color clr;
   double price = 0,AvgPrice = 0, lTP = 0, lastExecutedPrice;
   if( MinimumQty == 0)
      return 0;
      
   if(EntryType == "Buy"  )
   {
     price = NormalizeDouble(Ask,2);
     arrow = "ArrowBuy";
     clr = clrAliceBlue;
   }
   else if(EntryType == "Sell")
   {
     price = NormalizeDouble(Bid,2);
      arrow = "ArrowSell";
      clr = clrRed;
   }
   
   if(!getCurrentOpenQuantity(symbol,riv.data))
   {
      str = EntryType+" Signal produced in "+string(symbol)+" at "+string(price)+" Qty "+ string(MinimumQty);
      if(logFile(symbol,str)){
         showNotification(str);
         //LabelOrder(str,clrBlue);
         
         AvgPrice = price;
         DrawArrow(EntryType,price,PERIOD_CURRENT,entry);
         InsertTradeBook(symbol,TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),TimeToStr( (iTime(symbol,PERIOD_CURRENT,0)),TIME_DATE|TIME_SECONDS),EntryType,MinimumQty,price,"Confirm","Entry");
         
         InsertOpenPosition(symbol,MinimumQty,AvgPrice,price,EntryType, Open[0]);
         UpdateSMS(str,Executed_flag,mobile1);
         hysDeActivated = false;
      }
      return 1;
   }
   
   int currentQty = StrToInteger(riv.data[0][0]);
   
   if(currentQty == 0)
   {
      str = EntryType+" Signal produced in "+string(symbol)+" at "+string(price)+" Qty "+ string(MinimumQty);
      if(logFile(symbol,str)){
         showNotification(str);
         //LabelOrder(str,clrBlue);
         
         AvgPrice = price;
         DrawArrow(EntryType,price,PERIOD_CURRENT,entry);
         InsertTradeBook(symbol,TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),TimeToStr( (iTime(symbol,PERIOD_CURRENT,0)),TIME_DATE|TIME_SECONDS),EntryType,MinimumQty,price,"Confirm","Entry");
         UpdateOpenPosition(symbol,MinimumQty,AvgPrice,price,EntryType, price, Open[0]);
         UpdateSMS(str,Executed_flag,mobile1);
         hysDeActivated = false;
      }
      return 1;
   }
   string currentEntry = riv.data[0][1];
   AvgPrice = StrToDouble(riv.data[0][2]);
   lTP = StrToDouble(riv.data[0][3]);
   lastExecutedPrice = StrToDouble(riv.data[0][6]);
   MinimumQuantity = MinimumQty;
     
   string showP = "price: "+Close[0]+"lastLTP: "+lastExecutedPrice;
   LabelPriceDifference(showP + "Price Diff = " + ( lastExecutedPrice-Close[0]), clrChartreuse);
     
   if(IncQty == 0 ||  currentQty == 0)
   {
     Print(symbol + "Inc qty = 0 " );
     return 0;
   }  
   if(lastExecutedPrice == 0 || lastExecutedPrice == NULL )
   {
     LabelPriceDifference(symbol + " Last executed price not found ! ERROR !!!" , clrRed);
     return 0;
   }
   if(EntryType == "Buy" && currentEntry =="Sell" && currentQty > 0)
   {
      return 0;
   }
   if(EntryType == "Sell" && currentEntry =="Buy" && currentQty > 0)
   {
      return 0;
   }   
   
   if(!priceDiffEntry(Close[0],lastExecutedPrice,priceDiff,EntryType) )
   {
     //Print(Symbol() + " No increment Price difference = " + showP);
     return 1;
   } 

   if( (currentQty < MaximumQty) && (IncQty < MaximumQty) && (MaximumQty-currentQty >= IncQty ) )
   {
      str = EntryType+" Signal produced in "+string(symbol)+" at "+string(price)+" Qty "+ string(IncQty);
      if(logFile(symbol,str)){
         showNotification(str);
         //LabelOrder(str,clrBlue);
         showNotification("Increment " + EntryType + " Price "+ symbol + Close[0]) ;
         DrawArrow(EntryType,price,PERIOD_CURRENT,entry);
         AvgPrice = getOpenAvgPrice(AvgPrice,price,MinimumQty,currentQty);
         UpdateOpenPosition(symbol,currentQty+IncQty,AvgPrice,price,EntryType, price,-1);
         InsertTradeBook(symbol,TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),TimeToStr( (iTime(symbol,PERIOD_CURRENT,0)),TIME_DATE|TIME_SECONDS),EntryType,IncQty,price,"Confirm","Increment Entry");
         UpdateSMS(str,Executed_flag,mobile1);
      }
      return 1;
   }
   else if( MaximumQty-currentQty == 0)
   {
      return 0;
   }
  /* else
   {
      /*MinimumQty = MaximumQty-currentQty;
      str = EntryType+" Signal produced in ("+string(symbol)+") at ("+string(price)+") Qty ("+ string(MinimumQty) +")";
      if(logFile(symbol,str)){
         showNotification(str);
         ////LabelOrder(str,clrBlue); 
         AvgPrice = getOpenAvgPrice(AvgPrice,price,MinimumQty,currentQty);
         DrawArrow(EntryType,price,PERIOD_CURRENT,entry);
         UpdateOpenPosition(symbol,currentQty+MinimumQty,AvgPrice,price,EntryType, price);
         InsertTradeBook(symbol,TimeToStr(TimeLocal(),TIME_DATE|TIME_SECONDS),TimeToStr( (iTime(symbol,PERIOD_CURRENT,0)),TIME_DATE|TIME_SECONDS),EntryType,MinimumQty,price,"Confirm","Increment Entry");
         UpdateSMS(str,Executed_flag,mobile1);*/
      //}
      return 1;
   //}
}

void updateStrongTrendInOrderBook( double newBal, double currentBal )
{
   //if(  newBal <= currentBal )
   //{
   //   //sendNotificationToMobile( Symbol() + " Enabling Force Exit in Openposition");
   //   //enableforceExit(Symbol());
   //}
  /* if( newBal <= currentBal )
   {
      sendNotificationToMobile( Symbol() + " Updating Strong Trend in OrderBook");
      updateToStrongTrend(Symbol());
   }*/
   
   UpdateForceExit(Symbol());
} 

double getProfitnLoss(string entryType,double avgPrice, double exitPrice,double balance, int currentQty)
{
  double profit;
  int lotSize;
  lotSize = getLotSize(Symbol());
  if(entryType == "Sell")
  {
     profit = avgPrice* currentQty  - exitPrice * currentQty;
     balance = balance + profit;
     if(balance == 0)
     {
       showNotification("Balance ="+ balance );
     }
     if(avgPrice == 0)
     {
       showNotification("AvgPrice ="+ avgPrice );
     }
     sendNotificationToMobile( Symbol() + " Profit Generated = " + string(profit*lotSize ) );
     return balance;
  }
  if(entryType == "Buy")
  {
     profit = exitPrice * currentQty - avgPrice * currentQty;
     balance = balance + profit;
     sendNotificationToMobile( Symbol() + " Profit Generated = " + string(profit*lotSize) );
     return balance;
  }  
  
  return balance;
}

void UpdateUnrealisedBalanceAmount(string currentEntry ,double avgPrice, int currentQty, int resetForceExit , double ltp)
{
  double balance = 0;
   
  if(avgPrice == 0)
  {
    UpdateUnrealisedBalance(Symbol(),0,  resetForceExit, ltp );
    return; 
  }
  if(currentEntry == "Sell")
  {
     balance = avgPrice* currentQty  - ((Ask+Bid)/2) * currentQty;    
  }
  if(currentEntry == "Buy")
  {
     balance = ((Ask+Bid)/2)  * currentQty - avgPrice * currentQty;
  }  
  
   UpdateUnrealisedBalance(Symbol(),balance, resetForceExit, ltp );
}

double getStopLossDiff( string sym )
{
   ReadInputValues riv;
   ReadUserInp(sym , riv.data );
   
   riv.StopLoss = StrToDouble(riv.data[0][0]);
   
   return riv.StopLoss;
}

double getHystrisis( string sym )
{
   ReadInputValues riv;
   ReadUserInp(sym , riv.data );

   riv.Hystrisis = StrToDouble(riv.data[0][1]);
   return riv.Hystrisis;
}

bool getWeekTrendVal( string sym )
{
   ReadInputValues riv;
   ReadUserInpWeekTrend(sym , riv.data );

   riv.WeekTrend = StrToInteger(riv.data[0][0]);
   
   return riv.WeekTrend;
}


double getOpenAvgPrice(double avgPrice , double price, double minQty, double currentQty)
{
   double num = (avgPrice*currentQty) + (minQty*price);
   double den = currentQty + minQty;
   
   return (num/den);
}

double getCloseAvgPrice(double avgPrice , double price, double minQty, double currentQty)
{
   double num = (avgPrice*currentQty) - (price * minQty);
   double den = currentQty - minQty;
   if(den == 0)
     return 0;
     
   return (num/den);
}

bool priceDiffEntry(double price,double lastLTP, double priceDiff, string EntryType)
{
   if(EntryType == "Buy")
      return priceDiffBuyEntry( price, lastLTP, priceDiff);
   else if(EntryType == "Sell")
      return priceDiffSellEntry(price, lastLTP, priceDiff);
      
      return false;         
}

bool priceDiffBuyEntry(double price, double lastLTP, double priceDiff )
{
   string str = "price: "+price+"lastLTP: "+lastLTP;
  // showNotification(str+" Price Diff = " + IntegerToString( price-lastLTP) );
   LabelPriceDifference(str+ " Price Diff = " + IntegerToString( price-lastLTP),clrLightYellow);   
   return ( price > lastLTP + priceDiff);   
}
bool priceDiffSellEntry(double price, double lastLTP, double priceDiff )
{
   string str = "price: "+price+"lastLTP: "+lastLTP;
   //showNotification(str+" Price Diff = " + IntegerToString( lastLTP-price) );
   LabelPriceDifference(str + "Price Diff = " + IntegerToString( lastLTP-price), clrLightYellow);
   return (lastLTP > price + priceDiff);  
}

bool logFile(string symbol,string str)
{  
   string InpFileName=symbol+"_Signal.text";      // File name
   int file_handle = INVALID_HANDLE;
   file_handle = OpenFile(symbol+"_Signal.text",file_handle);
   if(file_handle!=INVALID_HANDLE) 
     { 
      PrintFormat("%s file is available for writing",InpFileName); 
      PrintFormat("File path: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));
      //FileWrite(file_handle,"");
      if(FileWrite(file_handle,str)){
          CloseFile(file_handle);
          return true;
       }
       else
         showNotification("Failed to write %s file, Error code = "+InpFileName+GetLastError());
     } 
   else{
      showNotification("Failed to open %s file, Error code = " + InpFileName+GetLastError());
      }
      
    CloseFile(file_handle);
    
    return false;
}
int OpenFile(string InpFileName,int file_handle)
{
    if(FileIsExist(InpFileName,0))
    {
         PrintFormat("%s file exists!",InpFileName);
         file_handle=FileOpen(InpFileName,FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_IS_TEXT|FILE_EXISTS);
         return file_handle;
    }
    else
    {
         PrintFormat("%s Creating File!",InpFileName);
         file_handle=FileOpen(InpFileName,FILE_READ|FILE_WRITE|FILE_SHARE_READ|FILE_IS_TEXT|FILE_EXISTS);
         return file_handle;
    }
         
    return file_handle;     
}

int OpenFileOnly(string symbol)
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

void CloseFile(int file_handle)
{
   if(file_handle != INVALID_HANDLE)
   {
       //--- close the file 
   FileClose(file_handle); 
   //PrintFormat("Data is written, %s file is closed",InpFileName); 
   }
}

void showNotification( string str ) 
{
  Alert(str);
  //SendNotification(str);
}

void sendNotificationToMobile( string str ) 
{
  Alert("Mobile:" +str);
  SendNotification(str);
}

bool label_price_diff= false;
string InpNamePriceDiffLabel = "InpPriceDiff";
void LabelPriceDifference(string text, color clr)
{
   long x = 150;
   long y = 300;
    if(label_price_diff)
       label_price_diff = LabelTextColorChange(0,InpNamePriceDiffLabel,text,clr);
   else
      label_price_diff = ShowLabelOrder(text,clr, InpNamePriceDiffLabel,x ,y, CORNER_LEFT_LOWER );
}

