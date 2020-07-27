//+------------------------------------------------------------------+
//|                                                         eSAWA.mq4|
//|                                                         indicator|
//|                                              http://fx.essawa.com|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016 | eSAWA.com"
#property link " http://fx.essawa.com"
#property version "1.002"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2

// Includes.
#include <EA31337-classes/Chart.mqh>
#include <EA31337-classes/DateTime.mqh>
#include <EA31337-classes/Draw.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_ATR.mqh>
#include <EA31337-classes/Indicators/Indi_CCI.mqh>
#include <EA31337-classes/Indicators/Indi_MA.mqh>
#include <EA31337-classes/Indicators/Indi_RSI.mqh>

//---- input parameters
extern int CCI_per = 14;
extern int RSI_per = 14;
extern int Ma_Period = 2;
extern int Koef = 8;
extern bool arrows = true;

double a = 0, a1 = 0, a2 = 0, a3 = 0, a4 = 0, a5 = 0, a6 = 0, a7 = 0, a8 = 0;
double b = 0, b1 = 0, b2 = 0, b3 = 0, b4 = 0, b5 = 0, b6 = 0, b7 = 0, b8 = 0;
double tt1max = 0, tt2min = 0;
int koef = Koef;

//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];
string sPrefix;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  //---- indicators
  SetIndexStyle4(0, DRAW_LINE, 0, 2);
  SetIndexBuffer(0, ExtMapBuffer1);
  SetIndexStyle4(1, DRAW_LINE, 0, 2);
  SetIndexBuffer(1, ExtMapBuffer2);

  SetIndexBuffer(2, ExtMapBuffer3);
  SetIndexBuffer(3, ExtMapBuffer4);

  Draw::SetIndexLabel(0, "CCI-RSI");
  Draw::SetIndexLabel(1, "RSI-CCI");
  if (koef > 8 || koef < 0) koef = 8;
  sPrefix = "eSAWA(" + (string)CCI_per + ", " + (string)RSI_per + ": " + (string)koef + " )";
  IndicatorShortName4(sPrefix);
  //----
  return (0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {
  DelOb();
  return (0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  int i, limit = rates_total - prev_calculated;

  for (i = limit - 3; i >= 0; i--) {
    a = iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i) - iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i);
    if (i - 1 >= 0)
      a1 = (iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i - 1) - iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i + 1));
    if (i - 2 >= 0)
      a2 = (iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i - 2) - iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i + 2));
    if (i - 3 >= 0)
      a3 = (iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i - 3) - iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i + 3));
    if (i - 4 >= 0)
      a4 = (iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i - 4) - iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i + 4));
    if (i - 5 >= 0)
      a5 = (iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i - 5) - iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i + 5));
    if (i - 6 >= 0)
      a6 = (iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i - 6) - iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i + 6));
    if (i - 7 >= 0)
      a7 = (iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i - 7) - iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i + 7));
    if (i - 8 >= 0)
      a8 = (iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i - 8) - iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i + 8));

    b = iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i) - iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i);
    if (i - 1 >= 0)
      b1 = (iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i - 1) - iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i + 1));
    if (i - 2 >= 0)
      b2 = (iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i - 2) - iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i + 2));
    if (i - 3 >= 0)
      b3 = (iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i - 3) - iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i + 3));
    if (i - 4 >= 0)
      b4 = (iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i - 4) - iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i + 4));
    if (i - 5 >= 0)
      b5 = (iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i - 5) - iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i + 5));
    if (i - 6 >= 0)
      b6 = (iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i - 6) - iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i + 6));
    if (i - 7 >= 0)
      b7 = (iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i - 7) - iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i + 7));
    if (i - 8 >= 0)
      b8 = (iRSI4(NULL, 0, RSI_per, PRICE_TYPICAL, i - 8) - iCCI4(NULL, 0, CCI_per, PRICE_TYPICAL, i + 8));

    switch (koef) {
      case 0:
        tt1max = a;
        tt2min = b;
        break;
      case 1:
        tt1max = a + a1;
        tt2min = b + b1;
        break;
      case 2:
        tt1max = a + a1 + a2;
        tt2min = b + b1 + b2;
        break;
      case 3:
        tt1max = a + a1 + a2 + a3;
        tt2min = b + b1 + b2 + b3;
        break;
      case 4:
        tt1max = a + a1 + a2 + a3 + a4;
        tt2min = b + b1 + b2 + b3 + b4;
        break;
      case 5:
        tt1max = a + a1 + a2 + a3 + a4 + a5;
        tt2min = b + b1 + b2 + b3 + b4 + b5;
        break;
      case 6:
        tt1max = a + a1 + a2 + a3 + a4 + a5 + a6;
        tt2min = b + b1 + b2 + b3 + b4 + b5 + b6;
        break;
      case 7:
        tt1max = a + a1 + a2 + a3 + a4 + a5 + a6 + a7;
        tt2min = b + b1 + b2 + b3 + b4 + b5 + b6 + b7;
        break;
      case 8:
        tt1max = a + a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8;
        tt2min = b + b1 + b2 + b3 + b4 + b5 + b6 + b7 + b8;
        break;
      default:
        tt1max = a + a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8;
        tt2min = b + b1 + b2 + b3 + b4 + b5 + b6 + b7 + b8;
    }

    ExtMapBuffer3[i] = tt1max;
    ExtMapBuffer4[i] = tt2min;
  }

  for (i = 0; i < limit; i++) {
    ExtMapBuffer1[i] = iMAOnArray4(ExtMapBuffer3, rates_total, Ma_Period, 0, MODE_SMA, i);
    ExtMapBuffer2[i] = iMAOnArray4(ExtMapBuffer4, rates_total, Ma_Period, 0, MODE_SMA, i);
  }
  for (i = 0; i < limit - 1; i++) {
    if (arrows) {
      if (ExtMapBuffer1[i] >= ExtMapBuffer2[i] && ExtMapBuffer1[i + 1] < ExtMapBuffer2[i + 1]) {
        DrawAr("up", i);
      }
      if (ExtMapBuffer1[i] <= ExtMapBuffer2[i] && ExtMapBuffer1[i + 1] > ExtMapBuffer2[i + 1]) {
        DrawAr("dn", i);
      }
    }
  }
  return (0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DelOb() {
  int n = ObjectsTotal4();
  for (int i = n - 1; i >= 0; i--) {
    string sName = ObjectName4(i);
    if (StringFind(sName, sPrefix) == 0) {
      ObjectDelete4(sName);
    }
  }
}
//----------------------------------------------------------------------
void DrawAr(string ssName, int i) {
  string sName = sPrefix + " " + ssName + " " + TimeToStr4(Time[i], TIME_DATE | TIME_MINUTES);
  ObjectDelete4(sName);
  ObjectCreate4(sName, OBJ_ARROW, 0, Time[i], 0);
  double gap = 3.0 * (iATR4(NULL, 0, 20, i) / 4.0);
  if (ssName == "up") {
    ObjectSet4(sName, OBJPROP_ARROWCODE, 225);
    ObjectSet4(sName, OBJPROP_PRICE1, Low[i] - gap);
    ObjectSet4(sName, OBJPROP_COLOR, DeepSkyBlue);
  }
  if (ssName == "dn") {
    ObjectSet4(sName, OBJPROP_ARROWCODE, 226);
    ObjectSet4(sName, OBJPROP_PRICE1, High[i] + gap * 3.0);
    ObjectSet4(sName, OBJPROP_COLOR, Red);
  }
  ObjectSet4(sName, OBJPROP_WIDTH, 2);
}
//+------------------------------------------------------------------+
