// Chart-object helper functions in this file are adapted from the MQL4 documentation examples.
//+------------------------------------------------------------------+
//|                                                      labelUI.mqh |
//|                                  Copyright 2018, Roopsikha Yadav |
//|                              https://github.com/roopsikhayadav28 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Roopsikha Yadav"
#property link      "https://github.com/roopsikhayadav28"
#property strict
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



double sT,Sb,sL;
double   Pivot_Point_P;
double   Support_S1;
double   Support_S2;
double   Resistance_R1;
double   Resistance_R2; 
input string XXXXXXXXXXXXXXXXC = "**********GRAPH*************";
input bool RefreshGraph = True;
input bool SHOW_INDICATOR = true;
input bool SHOW_VALUE = FALSE;

input ENUM_TIMEFRAMES PIVOT_TIME_FRAME = PERIOD_D1;
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
      Print("Failed to get the chart width! Error code = ",DoubleToString(GetLastError()));
      return 0;
     }
   if(!ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance))
     {
      Print("Failed to get the chart height! Error code = ",DoubleToString(GetLastError()));
      return 0;
     }
     //int x=(x_distance/2);
//--- check correctness of the input parameters
   if(InpX<0 || InpX>x_distance-1 || InpY<0 || InpY>y_distance-1)
     {
      Print("Error! Incorrects values of input parameters x & y! "+ text);
      return 0;
     }
     InpX = x_distance/2;
//--- prepare initial text for the label
   text=StringConcatenate(text);
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
      Print("Error! Incorrects values of input parameters! " + text);
      return 0;
     }
//--- prepare initial text for the label
   text=StringConcatenate(text);
//--- create a text label on the chart
   if(!LabelCreate(0,inpName,0,x,y,Position,text,InpFont,12,
      InpColor,InpAngle,InpAnchor,InpBack,InpSelection,InpHidden,InpZOrder))
     {
      Print("Failed to create Label! Error code = ",GetLastError());
      return 0;
     }
//--- redraw the chart and wait for half a second
   ChartRedraw();
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
      Print(__FUNCTION__,
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
   int InpX=250;
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
      Print("Error! Incorrects values of input parameters x & y !"+ text);
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
      Print(__FUNCTION__,
            ": failed to change the text! Error code = ",GetLastError());
      return(false);
     }     
     //--- set color
   ;
      if(!ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr))
     {
      Print(__FUNCTION__,
            ": failed to change the color! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
  
  void StopLossIndicator(double stopL)
  {
     if(HLineCreate(0,InpNameSL,0,stopL,clrOrange,STYLE_DASHDOTDOT,3,InpBack, 
      InpSelection,InpHidden,InpZOrder)) 
     { 
      //return; 
     }
     else
     {
        if(!HLineMove(0,InpNameSL,stopL))
           return;
     } 
  }
  string InpNameTP = "TAKE_PROFIT";
  
  void takeProfitIndicator(double stopL)
  {
     if(HLineCreate(0,InpNameTP,0,stopL,clrGreen,STYLE_DASHDOTDOT,5,InpBack, 
      InpSelection,InpHidden,InpZOrder)) 
     { 
      //return; 
     }
     else
     {
        if(!HLineMove(0,InpNameTP,stopL))
           return;
     } 
  }
  
   void HystrisisIndicator(color clr,string Name, double price)
  {
     if( price == -1 )
     {
       HLineDelete(0,Name);
       return;
     }
      
     if(HLineCreate(0,Name,0,price,clr,STYLE_DASHDOTDOT,1,InpBack, 
      InpSelection,InpHidden,InpZOrder)) 
     { 
      //return; 
     }
     else
     {
        if(!HLineMove(0,Name,price))
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
  
bool isLabel_Pivot_Created = FALSE;
void LabelPivot()
{
  long x = 150;
  long y = 100;
    if(isLabel_Pivot_Created)
       isLabel_Pivot_Created = LabelTextColorChange(0,"Label_Pivot","PivotTimeFrame="+getPivotTimeFrameString(),clrWhite);
   else
      isLabel_Pivot_Created = ShowLabelOrder("PivotTimeFrame="+getPivotTimeFrameString(),clrWhite, "Label_Pivot",x ,y, CORNER_LEFT_UPPER );

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
      ChartCommentSet("***Powered by ROOPSIKHA***",0);
      //--- Disable autoscroll 
      ChartSetInteger(handle,CHART_AUTOSCROLL,RefreshGraph); 
      //--- Set the indent of the right border of the chart 
      ChartSetInteger(handle,CHART_SHIFT,true); 
      //--- Display as candlesticks 
      ChartSetInteger(handle,CHART_MODE,CHART_BARS);
      ChartSetInteger(handle,CHART_MODE,CHART_BARS);
      //--- Scroll by 100 bars from the beginning of history 
      ChartNavigate(handle,CHART_CURRENT_POS,100); 
      //--- Set the tick volume display mode 
      ChartSetInteger(handle,CHART_SHOW_VOLUMES,CHART_VOLUME_TICK,1);
     }
 }
 
 //+------------------------------------------------------------------+ 
//| The function sets comment in the upper left corner of the        | 
//| chart.                                                           | 
//+------------------------------------------------------------------+ 
bool ChartCommentSet(const string str,const long chart_ID=0) 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- set property value 
   if(!ChartSetString(chart_ID,CHART_COMMENT,str)) 
     { 
      //--- display the error message in Experts journal 
      Print(__FUNCTION__+", Error Code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  }
 
 //+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="HLine", // line name 
               double       price=0)      // line price 
  { 
   if(!price || price <= 0)
   {
      HLineDelete(0,name);
      return false;
   }
      //price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- reset the error value 
   ResetLastError(); 
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price)) 
     { 
      if( GetLastError() == ERR_OBJECT_DOES_NOT_EXIST )
      {   return false;  }
         
      Print(__FUNCTION__, 
            ": failed to move the horizontal line! Error code = ",GetLastError()); 
      return(false); 
     }
    // else
     //Print( __FUNCTION__, "Moving Hor line " + name);
//--- successful execution 
   return(true); 
  } 
  
 //+------------------------------------------------------------------+ 
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="HLine") // line name 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- delete a horizontal line 
   if(!ObjectDelete(chart_ID,name)) 
     { 
      if (GetLastError() == ERR_OBJECT_DOES_NOT_EXIST )
      {
         return true;
      }
      
      Print(__FUNCTION__, 
            ": failed to delete a horizontal line! Error code = ",GetLastError()); 
      return(false); 
     }
     else 
     Print(__FUNCTION__, 
            ": deleted a horizontal line of" + name + " " + Symbol());
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
   if(!price || price <= 0) 
   {      
      HLineDelete(0,name);
      return false;
   }
   if(price == -1)
     HLineDelete(0,name);
      //price=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- reset the error value 
   ResetLastError(); 
//--- create a horizontal line  
 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price)) 
     { 
      if( GetLastError() == ERR_OBJECT_ALREADY_EXISTS )
         return false;
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