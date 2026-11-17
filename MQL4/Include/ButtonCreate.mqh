// Chart-object helper functions in this file are adapted from the MQL4 documentation examples.
#property strict 
//--- description 
#property description "Script creates the button on the chart." 
//--- display window of the input parameters during the script's launch 
#property script_show_inputs 
//--- input parameters of the script 
input string           BBInpName="ButtonBuy";            // Button name 
input string           BSInpName="ButtonSell";            // Button name 
input ENUM_BASE_CORNER BInpCorner=CORNER_LEFT_LOWER; // Chart corner for anchoring 
input string           BInpFont="Arial";             // Font 
input int              BInpFontSize=13;              // Font size 
input color            BInpColor=clrBlack;           // Text color 
input color            BInpBackColor=C'236,233,216'; // Background color 
input color            BInpBorderColor=clrWhite;      // Border color 
input bool             BInpState=false;              // Pressed/Released 
input bool             BInpBack=false;               // Background object 
input bool             BInpSelection=false;          // Highlight to move 
input bool             BInpHidden=false;              // Hidden in the object list 
input long             BInpZOrder=0;                 // Priority for mouse click 
//+------------------------------------------------------------------+ 
//| Create the button                                                | 
//+------------------------------------------------------------------+ 
bool ButtonCreate(const long              chart_ID=0,               // chart's ID 
                  const string            name="Button",            // button name 
                  const int               sub_window=0,             // subwindow index 
                  const int               x=0,                      // X coordinate 
                  const int               y=0,                      // Y coordinate 
                  const int               width=50,                 // button width 
                  const int               height=18,                // button height 
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER, // chart corner for anchoring 
                  const string            text="Button",            // text 
                  const string            font="Arial",             // font 
                  const int               font_size=10,             // font size 
                  const color             clr=clrBlack,             // text color 
                  const color             back_clr=C'236,233,216',  // background color 
                  const color             border_clr=clrNONE,       // border color 
                  const bool              state=false,              // pressed/released 
                  const bool              back=false,               // in the background 
                  const bool              selection=false,          // highlight to move 
                  const bool              hidden=true,              // hidden in the object list 
                  const long              z_order=0)                // priority for mouse click 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- create the button 
   if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0)) 
     { 
      Print(__FUNCTION__, 
            ": failed to create the button! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- set button coordinates 
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y); 
//--- set button size 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,60); 
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,50); 
//--- set the chart's corner, relative to which point coordinates are defined 
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner); 
//--- set the text 
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text); 
//--- set text font 
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font); 
//--- set font size 
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size); 
//--- set text color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
//--- set background color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr); 
//--- set border color 
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr); 
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back); 
//--- set button state 
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state); 
//--- enable (true) or disable (false) the mode of moving the button by mouse 
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
//| Move the button                                                  | 
//+------------------------------------------------------------------+ 
bool ButtonMove(const long   chart_ID=0,    // chart's ID 
                const string name="Button", // button name 
                const int    x=0,           // X coordinate 
                const int    y=0)           // Y coordinate 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- move the button 
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x)) 
     { 
      Print(__FUNCTION__, 
            ": failed to move X coordinate of the button! Error code = ",GetLastError()); 
      return(false); 
     } 
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y)) 
     { 
      Print(__FUNCTION__, 
            ": failed to move Y coordinate of the button! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Change button size                                               | 
//+------------------------------------------------------------------+ 
bool ButtonChangeSize(const long   chart_ID=0,    // chart's ID 
                      const string name="Button", // button name 
                      const int    width=50,      // button width 
                      const int    height=18)     // button height 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- change the button size 
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width)) 
     { 
      Print(__FUNCTION__, 
            ": failed to change the button width! Error code = ",GetLastError()); 
      return(false); 
     } 
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height)) 
     { 
      Print(__FUNCTION__, 
            ": failed to change the button height! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Change corner of the chart for binding the button                | 
//+------------------------------------------------------------------+ 
bool ButtonChangeCorner(const long             chart_ID=0,               // chart's ID 
                        const string           name="Button",            // button name 
                        const ENUM_BASE_CORNER corner=CORNER_LEFT_UPPER) // chart corner for anchoring 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- change anchor corner 
   if(!ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner)) 
     { 
      Print(__FUNCTION__, 
            ": failed to change the anchor corner! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Change button text                                               | 
//+------------------------------------------------------------------+ 
bool ButtonTextChange(const long   chart_ID=0,    // chart's ID 
                      const string name="Button", // button name 
                      const string text="Text")   // text 
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
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Delete the button                                                | 
//+------------------------------------------------------------------+ 
bool ButtonDelete(const long   chart_ID=0,    // chart's ID 
                  const string name="Button") // button name 
  { 
//--- reset the error value 
   ResetLastError(); 
//--- delete the button 
   if(!ObjectDelete(chart_ID,name)) 
     { 
      Print(__FUNCTION__, 
            ": failed to delete the button! Error code = ",GetLastError()); 
      return(false); 
     } 
//--- successful execution 
   return(true); 
  } 
//+------------------------------------------------------------------+ 
//| Script program start function                                    | 
//+------------------------------------------------------------------+ 
void OnStartButtonBuy() 
  { 
//--- chart window size 
   long x_distance; 
   long y_distance; 
//--- set window size 
   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance)) 
     { 
      Print("Failed to get the chart width! Error code = ",GetLastError()); 
      return; 
     } 
   if(!ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance)) 
     { 
      Print("Failed to get the chart height! Error code = ",GetLastError()); 
      return; 
     } 

//--- set the button coordinates and its size 
   int x=(int)x_distance/32; 
   int y=(int)y_distance/32+50; 
   int x_size=(int)2; 
   int y_size=(int)2; 
//--- create the button 
   if(!ButtonCreate(0,BBInpName,0,x,y,x_size,y_size,BInpCorner,"Buy",BInpFont,BInpFontSize, 
      clrBlack,clrGreen,BInpBorderColor,BInpState,BInpBack,BInpSelection,BInpHidden,BInpZOrder)) 
     { 
      return; 
     } 
//--- redraw the chart 
   ChartRedraw(); 
   }

void OnStartButtonSell() 
  { 
//--- chart window size 
   long x_distance; 
   long y_distance; 
//--- set window size 
   if(!ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0,x_distance)) 
     { 
      Print("Failed to get the chart width! Error code = ",GetLastError()); 
      return; 
     } 
   if(!ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0,y_distance)) 
     { 
      Print("Failed to get the chart height! Error code = ",GetLastError()); 
      return; 
     } 

//--- set the button coordinates and its size 
   int x=(int)x_distance/20+100; 
   int y=(int)y_distance/32+50; 
   int x_size=(int)x_distance/10; 
   int y_size=(int)y_distance/10; 
//--- create the button 
   if(!ButtonCreate(0,BSInpName,0,x,y,x_size,y_size,BInpCorner,"Sell",BInpFont,BInpFontSize, 
      clrBlack,clrRed,BInpBorderColor,BInpState,BInpBack,BInpSelection,BInpHidden,BInpZOrder)) 
     { 
      return; 
     } 
//--- redraw the chart 
   ChartRedraw(); 
   }

string ChartEvent(const int id,const string &sparam)
{
   string p_buy = "BUY", p_sell = "SELL";
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam==BBInpName)
       {
            string txt;
            txt="Click on Yes to open BUY trades "+Symbol();
            int ret=MessageBox(txt,"CONFIRM OPEN NEW TRADES", MB_YESNO); // Message box
            if(ret ==IDYES)
            {
                ObjectSetInteger(0,BBInpName,OBJPROP_STATE,false);
                return p_buy;
            }    
            ObjectSetInteger(0,BBInpName,OBJPROP_STATE,false);        
            return NULL;
         }
        if(sparam==BSInpName)
         {
            string txt;
            txt="Click on Yes to open SELL trades "+Symbol();
            int ret=MessageBox(txt,"CONFIRM OPEN NEW TRADES", MB_YESNO); // Message box
            if(ret ==IDYES)
            {
                ObjectSetInteger(0,BSInpName,OBJPROP_STATE,false);
                return p_sell;
            }
            ObjectSetInteger(0,BSInpName,OBJPROP_STATE,false);
            return NULL;
         }
     }
     
     return NULL;
}
 


