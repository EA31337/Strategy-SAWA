/**
 * @file
 * Implements indicator under MQL5.
 */

// Defines indicator properties.
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 2
#property indicator_color1 DeepSkyBlue
#property indicator_color2 Red
#property indicator_width1 2
#property indicator_width2 2

// Includes EA31337 framework.
#include <EA31337-classes/Draw.mqh>
#include <EA31337-classes/Indicator.mqh>
#include <EA31337-classes/Indicators/Indi_ATR.mqh>
#include <EA31337-classes/Indicators/Indi_CCI.mqh>
#include <EA31337-classes/Indicators/Indi_RSI.mqh>

// Defines macros.
#define Bars (ChartStatic::iBars(_Symbol, _Period))

// Custom indicator iteration function.
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
  // if (begin > 0) PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, begin + SvePeriod);
  // if (begin > 0) PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, begin + SvePeriod);
  // if (begin > 0) PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, begin + SvePeriod);
  int pos = fmax(0, prev_calculated - 1);
  IndicatorCounted(prev_calculated);
  start();
  return (rates_total);
}

// Includes the main file.
#include "SAWA.mq4"
