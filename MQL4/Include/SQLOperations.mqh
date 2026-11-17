//+------------------------------------------------------------------+
//|                                                SQLOperations.mqh |
//|                                  Copyright 2018, Roopsikha Yadav |
//|                              https://github.com/roopsikhayadav28 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Roopsikha Yadav"
#property link      "https://github.com/roopsikhayadav28"
#property strict
#include <mql4-mysql.mqh>

input string h   = "localhost"; // MySQL host
input string u   = "";          // MySQL user
input string pwd = "";          // MySQL password
input string db  = "";          // MySQL database name

int     port1     = 3306;
int     socket1  = 0;
int     client1   = 0;

bool    goodConnect = false;


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


bool CreateDataTable()
{
  long    dbConnectId = 0;
  goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| Create Table
    //| 
    //+-------------------------------------------------------------------
   string Query1 = "CREATE TABLE TrendBook (Symbol VARCHAR(20) NOT NULL,PercentChange double,AdxValue double, DI_Plus double, DI_Minus double,AdxSlope VARCHAR(30),RSI double,Stockistic VARCHAR(30),STBuy double,STSell double,VWAP double,Momentum double,EntryValue double, LTP double,EntryType VARCHAR(10),UNIQUE KEY (Symbol));";
   string Alter1 = "ALTER TABLE TrendBook ADD COLUMN  S1 double, ADD COLUMN S2 double, ADD COLUMN S3 double, ADD COLUMN PivotPoint double,ADD COLUMN R1 double,ADD COLUMN R2 double,ADD COLUMN R3 double;";
   string Alter2 = "ALTER TABLE TrendBook ADD COLUMN TimeFrame VARCHAR(30),ADD COLUMN ProductType VARCHAR(20),ADD COLUMN ExecuteTrade VARCHAR(20),ADD COLUMN DateANDTime VARCHAR(30);";
      if ( MySQL_Query(dbConnectId, Query1) ) {
        Print("Table Created");
        //return true;
     }
     if ( MySQL_Query(dbConnectId, Alter1) ) {
        Print("Table Altered1");
        //return true;
    }
     if ( MySQL_Query(dbConnectId, Alter2) ) {
        Print("Table Altered2");
        //return true;
    }   
    
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId); 
  
    return false; 
}


bool DeleteDataTable()
{
  long    dbConnectId = 0;
  goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| Delete
    //| 
    //+-------------------------------------------------------------------
   string Query = "DROP TABLE TRENDBOOK;";
      if ( MySQL_Query(dbConnectId, Query) ) {
        Print("Data Deleted");
        return true;
    }    
    
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId); 
  
    return false; 
}

bool InsertDoubleDataIntoMYSQL( string symbol, string column, double value ) {
     long    dbConnectId = 0;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| INSERT
    //| 
    //+-------------------------------------------------------------------

    string insertQuery  = "INSERT INTO TrendBook ("+string(column)+") VALUES ("+string(value)+") WHERE Symbol =" + symbol +";";                   
    
    if ( !MySQL_Query(dbConnectId, insertQuery) ) {
        Print("insert bad "+column);
         deinit_MySQL(dbConnectId);
        return false;
    }
  
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

bool InsertSymbolIntoMaster( string symbol, string column, string value ) {
     long    dbConnectId = 0;
     goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
     if ( !goodConnect ) {
        return false; // bad connect
     }
    //+-------------------------------------------------------------------
    //| INSERT
    //| 
    //+-------------------------------------------------------------------
    string insertQuery = "INSERT INTO MasterRecord ("+column+") VALUES ('"+value+"');";         
    
    if ( ! MySQL_Query(dbConnectId, insertQuery) ) {
        Print("insert bad InsertSymbolIntoMaster");
         deinit_MySQL(dbConnectId);
        return false;
    }
  
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

bool InsertStringDataIntoMYSQL( string symbol, string column, string value ) {
     long    dbConnectId = 0;
     goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
     if ( !goodConnect ) {
        return false; // bad connect
     }
    //+-------------------------------------------------------------------
    //| INSERT
    //| 
    //+-------------------------------------------------------------------
    string insertQuery = "INSERT INTO TrendBook ("+column+") VALUES ('"+value+"');";         
    
    if ( ! MySQL_Query(dbConnectId, insertQuery) ) {
        Print("insert bad InsertStringDataIntoMYSQL");
         deinit_MySQL(dbConnectId);
        return false;
    }
  
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

bool UpdateDoubleDataTable( long &dbConnectSQLId, string symbol,string column, double value  ) 
{

    //+-------------------------------------------------------------------
    //| UPDATE
    //| 
    //+-------------------------------------------------------------------
    
    string updateQuery ="UPDATE TrendBook SET "+column +"= '"+string(value)+"' where Symbol = '"+string(symbol)+"';";
    //string insertQuery = "UPDATE TREND_IDENTIFIER SET PercentChange
    if (!MySQL_Query(dbConnectSQLId, updateQuery) ) {
        Print("update bad UpdateDoubleDataTable");
            // deinit_MySQL(dbConnectId);
            return false;
    }

    return true;
}

bool ConnectSQL(long &dbConnectSQLId) 
{
    
      goodConnect = init_MySQL(dbConnectSQLId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    return true;
}
    //+-------------------------------------------------------------------
    //| INSERT
    //| 
    //+-------------------------------------------------------------------
bool UpdateStringDataTable( string symbol,string column, string value , long &dbConnectSQLId ) 
{    
    string updateQuery ="UPDATE TrendBook SET "+column +"= '"+value+"' where Symbol = '"+symbol+"';";
    if ( !MySQL_Query(dbConnectSQLId, updateQuery) ) {
        Print("update bad UpdateStringDataTable");
            //deinit_MySQL(dbConnectSQLId);
            return false;
    }
    return true;
}  

bool DisConnect(long &dbConnectSQLId)
{    
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectSQLId);
    return true;
}

bool UpdateSMS(string msgTxt , bool executed_flag, int mobile)
{
    long    dbConnectId = 0;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| UPDATE
    //| 
    //+-------------------------------------------------------------------
   string updateQuery = "Update SMSTABLE SET Message = '" + string(msgTxt) +"',ExecutedFlag = '" + string(executed_flag)+"',MobileNo = '" + string(mobile) +"';"; 
       if ( !MySQL_Query(dbConnectId, updateQuery) ) {
        Print("update bad UpdateSMS");
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;  
}

bool UpdateBalance(string symbol , double balance)
{
    long    dbConnectId = 0;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| UPDATE
    //| 
    //+-------------------------------------------------------------------
   string updateQuery = "Update OpenPosition SET RealisedBalance = " + string(balance) + " where Symbol = '"+string(symbol) +"';"; 
       if ( !MySQL_Query(dbConnectId, updateQuery) ) {
        Print("update bad UpdateBalance");
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;  
}


bool UpdateUnrealisedBalance(string symbol , double balance, int forceExit, double ltp)
{
    long    dbConnectId = 0;
    string updateQuery;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| UPDATE
    //| 
    //+-------------------------------------------------------------------
    //if( forceExit == 2)
    {
       updateQuery  = "Update OpenPosition SET UnrealisedBalance = " + string(balance) + ", LTP = "+ DoubleToStr(ltp) +" where Symbol = '"+string(symbol) +"';";
    }
   /* else
       updateQuery = "Update OpenPosition SET UnrealisedBalance = " + string(balance) + ",ForceExit = " + string(forceExit) +", stoploss = "+ DoubleToStr(stopL)+" where Symbol = '"+string(symbol) +"';";*/
     
       if ( !MySQL_Query(dbConnectId, updateQuery) ) {
        Print("update bad UpdateUnRealisedBalance and force exit");
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

bool enableforceExit(string symbol)
{
    long    dbConnectId = 0;
    string updateQuery;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| UPDATE
    //| 
    //+-------------------------------------------------------------------
  
    updateQuery  = "Update OrderBook SET ForceExit = " + string(1) +" where Symbol = '"+string(symbol) +"';";

       if ( !MySQL_Query(dbConnectId, updateQuery) ) {
        Alert("update bad enableforceExit");
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

bool updateToStrongTrend(string symbol)
{
    long    dbConnectId = 0;
    string updateQuery;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| UPDATE
    //| 
    //+-------------------------------------------------------------------
  
    updateQuery  = "Update Orderbook SET WeekTrend = " + string(0) +" where Symbol = '"+string(symbol) +"';";

       if ( !MySQL_Query(dbConnectId, updateQuery) ) {
        Alert("update bad updateToStrongTrend");
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}
bool ReadSymbol(string symbol,string &data[][])
{
   long    dbConnectId = 0;

   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ
    //| 
    //+-------------------------------------------------------------------
 
    string readQuery = "select Symbol,Rate,MinimumQty,IncrementQty,MaximumQty from orderbook where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,data ) <= 0 ) 
    {
        Print("read bad Read symbol");
        SendNotification("Symbol not found in orderbook "+Symbol() );
        //InsertLogs(symbol,"Symbol not found in orderbook "+Symbol());
        deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

bool getMAParam(string symbol,string &data[][])
{
   long    dbConnectId = 0;

   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ
    //| 
    //+-------------------------------------------------------------------
 
    string readQuery = "select MA_Slow,MA_Fast from masterrecord  where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,data ) < 0 ) 
    {
        Print("read bad MAParam symbol");
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

double getMA_Fast(string symbol)
{
  string data[1][2];
  double ma_fast;
  getMAParam(symbol , data);
  ma_fast = StrToDouble(data[0][1]);
  return ma_fast;
}

double getMA_Slow(string symbol)
{
  string data[1][2];
  double ma_slow;
  getMAParam(symbol , data);
  ma_slow = StrToDouble(data[0][0]);
  return ma_slow;
}

double getPriceDiff(string symbol)
{
   long    dbConnectId = 0;

   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ
    //| 
    //+-------------------------------------------------------------------
    string data[1][1];
    string readQuery = "select PriceDifference from MasterRecord where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,data ) < 0 ) 
    {
        Print("read bad Read symbol");
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    double priceDiff = StrToDouble(data[0][0]);
    deinit_MySQL(dbConnectId);    
    ArrayFree(data);
    return priceDiff;
}

double getRenko(string symbol)
{
   long    dbConnectId = 0;

   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ
    //| 
    //+-------------------------------------------------------------------
    string data[1][1];
    string readQuery = "select candleSize from MasterRecord where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,data ) < 0 ) 
    {
        Print("read bad Read symbol");
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    double candleS = StrToDouble(data[0][0]);
    deinit_MySQL(dbConnectId);
    ArrayFree(data);
    return candleS;
}

bool ReadUserInp(string symbol,string &data[][])
{
   long    dbConnectId = 0;

   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ USER INPUT
    //| 
    //+-------------------------------------------------------------------
 
    string readQuery = "select StopLoss,Hystrisis from MasterRecord where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,data ) < 0 ) 
    {
        Print("read bad Read symbol");
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

bool ReadUserInpWeekTrend(string symbol,string &data[][])
{
   long    dbConnectId = 0;

   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ USER INPUT
    //| 
    //+-------------------------------------------------------------------
 
    string readQuery = "select WeekTrend from orderbook where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,data ) < 0 ) 
    {
        Print("read bad Read symbol");
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

bool ReadSymbolFromOrderBook(string &data[][])
{
   long    dbConnectId = 0;

   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| INSERT
    //| 
    //+-------------------------------------------------------------------
 
    string readQuery = "select Symbol from orderbook where GraphStatus = '0';" ;
    int res = MySQL_FetchArray(dbConnectId, readQuery,data );
    if ( res < 0 ) 
    {
        Print("read bad ReadSymbolFromOrderBook");
         deinit_MySQL(dbConnectId);
        return false;
    }
    if( res == 0 )
    {
         deinit_MySQL(dbConnectId);
        return false;
    }  
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

bool CheckGraphStatusFromOrderBook( string &data[][])
{
   long    dbConnectId = 0;

   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| INSERT
    //| 
    //+-------------------------------------------------------------------

    string readQuery = "select Symbol, ChartID from orderbook where GraphStatus = '1';" ;
    int res = MySQL_FetchArray(dbConnectId, readQuery,data );
    if ( res < 0 ) 
    {
        Print("read bad ReadSymbolFromOrderBook");
          
        deinit_MySQL(dbConnectId);
        return false;
    }
    if( res == 0 )
    {
        
          deinit_MySQL(dbConnectId);
        return false;
    } 
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

/*long ReadChartID( string symbol)
{
   long    dbConnectId = 0;

   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| INSERT
    //| 
    //+-------------------------------------------------------------------
    string chartID[1][1];
    string readQuery = "Select ChartID from orderbook where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,chartID ) < 0 ) 
    {
        Print("read good");
         deinit_MySQL(dbConnectId);
        return StringToDouble(chartID[0][0]);
    }
    else
      Print("Read bad");
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return -1;
}*/

bool SetGraphStatus( string data , long chartID)
{
  long    dbConnectId = 0;

   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
     string insertQuery = "update orderbook SET GraphStatus = '1',ChartID = '"+string(chartID)+"' where Symbol = '" + data+"';";
    if ( !MySQL_Query(dbConnectId, insertQuery ) ) 
    {
        Print("Orderbook :update bad  SetGraphStatus");
         deinit_MySQL(dbConnectId);
        return false;
    }
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true; 
}

bool InsertTradeBook(string symbol,string OrderDate, string GraphDate ,string orderType ,double Quantity ,double Rate ,string OrderStatus,string ProductType)
{
   long    dbConnectId = 0;
   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| INSERT Trade Book
    //+-------------------------------------------------------------------

    string insertQuery = "insert into TradeBook (Symbol ,OrderDate,GraphDate ,OrderType ,Quantity ,Rate ,OrderStatus ,ProductType ) VALUES ( '"+symbol+"' ,'"+OrderDate+"' ,'"+GraphDate+"' ,'"+orderType+"','"+string(Quantity)+"','"+string(Rate)+"','"+OrderStatus+"','"+ProductType+"');";
    if ( !MySQL_Query(dbConnectId, insertQuery ) ) 
    {
        Print("TradeBook:read bad InsertTradeBook");
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;    
}

bool UpdateCurrentTime( string symbol)
{
  long    dbConnectId = 0;
   string updateQuery;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| UPDATE
    //+-------------------------------------------------------------------

    updateQuery ="UPDATE OpenPosition SET LastUpdateTime= '"+TimeToStr(TimeLocal())+"' where Symbol = '"+string(symbol)+"';";
    
    if ( !MySQL_Query(dbConnectId, updateQuery) ) {
         Print("UpdateCurrentTime bad "+symbol);
          deinit_MySQL(dbConnectId);
         return false;
    }
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;  
}

  
bool UpdateOpenPosition(string symbol, double Quantity, double AvgPrice,double ltp, string EntryType , double lastExecutedPrice, double executedOpenPosition)
{
   long    dbConnectId = 0;
   string updateQuery;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| UPDATE
    //+-------------------------------------------------------------------
    if( executedOpenPosition == -1)
       updateQuery ="UPDATE OpenPosition SET Quantity= '"+string(Quantity)+"', AvgPrice = '"+string(AvgPrice)+"', LTP = '"+string(ltp)+"',EntryType = '"+string(EntryType)+"',LastExecutedPrice = '"+string(lastExecutedPrice)+"' where Symbol = '"+string(symbol)+"';";
    else 
        updateQuery ="UPDATE OpenPosition SET Quantity= '"+string(Quantity)+"', AvgPrice = '"+string(AvgPrice)+"', LTP = '"+string(ltp)+"',EntryType = '"+string(EntryType)+"',LastExecutedPrice = '"+string(lastExecutedPrice)+"',executedOpenPosition = '"+string(executedOpenPosition)+"' where Symbol = '"+string(symbol)+"';";
        
    if ( !MySQL_Query(dbConnectId, updateQuery) ) {
         Print("UpdateOpenPosition bad "+symbol);
          deinit_MySQL(dbConnectId);
         return false;
    }
    //+-------------------------------------------------------------------
     deinit_MySQL(dbConnectId);
    return true;  
}


bool InsertOpenPosition(string symbol, double Quantity, double AvgPrice, double ltp, string EntryType, double executedOpenPosition)
{
   long    dbConnectId = 0;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| INSERT
    //+-------------------------------------------------------------------
    string insertQuery = "INSERT INTO OPENPOSITION (Symbol,Quantity,AvgPrice,LastExecutedPrice,EntryType, executedOpenPosition) VALUES ('"+string(symbol)+"','"+string(Quantity)+"','"+string(AvgPrice)+"','"+string(ltp)+"','"+EntryType+"','"+string(executedOpenPosition)+"');";
     if ( !MySQL_Query(dbConnectId, insertQuery) ) {
         Print("InsertOpenPosition bad "+symbol);
          deinit_MySQL(dbConnectId);
         return false;
     }
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;  
}

bool InsertLogs(string symbol, string str)
{
   long    dbConnectId = 0;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| INSERT
    //+-------------------------------------------------------------------
    string insertQuery = "INSERT INTO TRADELOGS (Symbol,DateAndTime, ErrorLogs) VALUES ('"+string(symbol)+"','"+TimeToStr(TimeCurrent(),TIME_DATE|TIME_SECONDS)+"','"+string(str)+"');";
     if ( !MySQL_Query(dbConnectId, insertQuery) ) {
         Print("InsertLogs bad "+symbol);
          deinit_MySQL(dbConnectId);
         return false;
     }
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;  
}

bool getCurrentOpenQuantity(string symbol, string &data[][])
{
   long    dbConnectId = 0;
   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ OPEN QUANTITY
    //+-------------------------------------------------------------------
      
    string readQuery = "select Quantity,EntryType,AvgPrice ,LTP,realisedBalance,LastExecutedPrice  from OpenPosition where Symbol = '"+ symbol +"';" ;
    int res = MySQL_FetchArray(dbConnectId, readQuery,data );
    string str = "Not able to read function "+ __FUNCTION__ +symbol;
    if ( res < 0 ) 
    {
        Print(str);
         deinit_MySQL(dbConnectId);
        return false;
    }
    if( res == 0)
    {
        //Print("getCurrentOpenQuantity "+symbol);
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

double getOpenPriceExecuted(string symbol )
{
   long    dbConnectId = 0;
   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ OPEN QUANTITY
    //+-------------------------------------------------------------------
    string data[1][1];
    string readQuery = "select executedOpenPosition  from OpenPosition where Symbol = '"+ symbol +"';" ;
    int res = MySQL_FetchArray(dbConnectId, readQuery,data );
    string str = "Not able to read function "+ __FUNCTION__ +symbol;
    if ( res < 0 ) 
    {
        Print(str);
         deinit_MySQL(dbConnectId);
        return false;
    }
    if( res == 0)
    {
        //Print("getCurrentOpenQuantity "+symbol);
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return StrToDouble(data[0][0]);
}

int getForceExitTrue(string symbol)
{
   long    dbConnectId = 0;
   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ OPEN QUANTITY
    //+-------------------------------------------------------------------
    string data[1][1];
    string readQuery = "select ForceExit from Orderbook where Symbol = '"+ symbol +"';" ;
    int res = MySQL_FetchArray(dbConnectId, readQuery,data );
    string str = "Not able to read function "+ __FUNCTION__ +symbol;
    if ( res < 0 ) 
    {
        Print(str);
        deinit_MySQL(dbConnectId);
        return -1;
    }
    if( res == 0)
    {
        //Print("getCurrentOpenQuantity "+symbol);
         deinit_MySQL(dbConnectId);
        return -1;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return StrToInteger(data[0][0]);
}


string EnterTradeManually(string symbol)
{
   long    dbConnectId = 0;
   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return NULL; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ OPEN QUANTITY
    //+-------------------------------------------------------------------
    string data[1][1];
    string readQuery = "select ManualEntry from OrderBook where Symbol = '"+ symbol +"';" ;
    int res = MySQL_FetchArray(dbConnectId, readQuery,data );
    string str = " Read bad "+ __FUNCTION__+ symbol;
    if ( res < 0 ) 
    {
        Print(str);
         deinit_MySQL(dbConnectId);
        return NULL;
    }
    if( res == 0)
    {
         deinit_MySQL(dbConnectId);
        return NULL;
    }
    string enterTradeManually = data[0][0];
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    ArrayFree(data);
    return enterTradeManually;
}

bool GetPriceForArrow(string symbol ,string &data[][])
{
   long    dbConnectId = 0;
   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ PRICE, DATE AND TIME
    //+-------------------------------------------------------------------
      
    string readQuery = "select rate, GraphDate, OrderType, ProductType from tradebook where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,data ) < 1 ) 
    {
        Print("TradeBook : read BAD ,arrow "+symbol);
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true;
}

void UpdateForceExit( string symbol )
{
   long    dbConnectId = 0;
   string updateQuery;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return ; // bad connect
    }
    //+-------------------------------------------------------------------
    //| UPDATE
    //+-------------------------------------------------------------------

    updateQuery ="UPDATE Orderbook SET ForceExit= '1' where Symbol = '"+string(symbol)+"';";
        
    if ( !MySQL_Query(dbConnectId, updateQuery) ) {
         string str = "UpdateForceExit bad "+symbol;
         Print(str);
          deinit_MySQL(dbConnectId);
         return ;
    }
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return ;  
}

bool getSmartStopLoss(string symbol,string &data[][])
{
    long    dbConnectId = 0;
   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return false; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ PRICE, DATE AND TIME
    //+-------------------------------------------------------------------
      
    string readQuery = "select  SL_Max, SL_Candle_Dec, SL_Min from masterrecord where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,data ) < 1 ) 
    {
        Print("TradeBook : read BAD ,arrow "+symbol);
         deinit_MySQL(dbConnectId);
        return false;
    }
   
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return true; 
}

int takeProfit(string symbol)
{
    long    dbConnectId = 0;
   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return 0; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ PRICE, DATE AND TIME
    //+-------------------------------------------------------------------
    string data[1][1];  
    string readQuery = "select  Profit from masterrecord where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,data ) < 1 ) 
    {
        Print("TradeBook : read BAD ,arrow "+symbol);
         deinit_MySQL(dbConnectId);
        return 0;
    }
   double takeProfit = StrToInteger(data[0][0]);
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return takeProfit; 
}

double getLotSize(string symbol)
{
    long    dbConnectId = 0;
   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return 1; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ PRICE, DATE AND TIME
    //+-------------------------------------------------------------------
    string data[1][1];
    string readQuery = "select LotSize from masterrecord where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,data ) < 1 ) 
    {
        Print("read BAD " + __FUNCTION__+ symbol);
         deinit_MySQL(dbConnectId);
        return false;
    }
    int lotsize = StringToInteger(data[0][0]);
    ArrayFree(data);
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return lotsize; 
}

double prevStopLoss(string symbol ) 
{
      long    dbConnectId = 0;
   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return -1; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ PRICE, DATE AND TIME
    //+-------------------------------------------------------------------
    string data[1][1];
    string readQuery = "select StopLoss from OpenPosition where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,data ) < 1 ) 
    {
        Alert("prevStopLoss : read BAD "+symbol);
         deinit_MySQL(dbConnectId);
        return -1;
    }
   double st = StringToDouble(data[0][0]);
   ArrayFree(data);
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return st;
}

int getPrevCandleRisk(string symbol ) 
{
      long    dbConnectId = 0;
   goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return -1; // bad connect
    }
    //+-------------------------------------------------------------------
    //| READ PRICE, DATE AND TIME
    //+-------------------------------------------------------------------
    string data[1][1];
    string readQuery = "select riskcandle from OpenPosition where Symbol = '"+ symbol +"';" ;
    if ( MySQL_FetchArray(dbConnectId, readQuery,data ) < 1 ) 
    {
        Alert(__FUNCTION__+": read BAD "+symbol);
         deinit_MySQL(dbConnectId);
        return -1;
    }
   int risk_candle = StringToInteger(data[0][0]);
   ArrayFree(data);
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return risk_candle;
}

void UpdateStoploss( string symbol ,double stoploss, double  IncrementCandle)
{
   long    dbConnectId = 0;
   string updateQuery;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return ; // bad connect
    }
    //+-------------------------------------------------------------------
    //| UPDATE
    //+-------------------------------------------------------------------

    updateQuery ="UPDATE OpenPosition SET  IncrementCandle= '"+ IncrementCandle+"', stoploss= '"+stoploss+"' where Symbol = '"+string(symbol)+"';";
        
    if ( !MySQL_Query(dbConnectId, updateQuery) ) {
         string str = "UpdateStopLoss bad "+symbol;
         Print(str);
          deinit_MySQL(dbConnectId);
         return ;
    }
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return ;
}

void UpdateRiskCandle( string symbol ,double riskCandle)
{
   long    dbConnectId = 0;
   string updateQuery;
      goodConnect = init_MySQL(dbConnectId, h, u, pwd, db, port1, socket1, client1);
    
    if ( !goodConnect ) {
        return ; // bad connect
    }
    //+-------------------------------------------------------------------
    //| UPDATE
    //+-------------------------------------------------------------------

    updateQuery ="UPDATE OpenPosition SET   RISKCANDLE= '"+ riskCandle+"' where Symbol = '"+string(symbol)+"';";
        
    if ( !MySQL_Query(dbConnectId, updateQuery) ) {
         string str = __FUNCTION__+" bad "+symbol;
         Alert(str);
          deinit_MySQL(dbConnectId);
         return ;
    }
    //+-------------------------------------------------------------------
    deinit_MySQL(dbConnectId);
    return ;
}