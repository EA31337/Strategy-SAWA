/**
 * @file
 * Implements SAWA strategy based on the SAWA indicator.
 */

// Includes indicator class.
#include "Indi_SAWA.mqh"

// User input params.
INPUT float SAWA_LotSize = 0;                // Lot size
INPUT short SAWA_Shift = 0;                  // Shift (relative to the current bar, 0 - default)
INPUT int SAWA_SignalOpenMethod = 2;         // Signal open method
INPUT int SAWA_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT float SAWA_SignalOpenLevel = 0.0f;     // Signal open level
INPUT int SAWA_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int SAWA_SignalCloseMethod = 2;        // Signal close method
INPUT float SAWA_SignalCloseLevel = 0.0f;    // Signal close level
INPUT int SAWA_PriceStopMethod = 1;          // Price limit method
INPUT float SAWA_PriceStopLevel = 2;         // Price limit level
INPUT int SAWA_TickFilterMethod = 1;         // Tick filter method (0-255)
INPUT float SAWA_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT int SAWA_OrderCloseTime = -20;         // Order close time in mins (>0) or bars (<0)
INPUT string __SAWA_Indi_SAWA_Params__ =
    "-- SAWA strategy: SAWA indicator params --";  // >>> SAWA strategy: SAWA indicator <<<
INPUT int SAWA_Indi_SAWA_CCIPeriod = 14;           // CCI period
INPUT int SAWA_Indi_SAWA_RSIPeriod = 14;           // RSI period
INPUT int SAWA_Indi_SAWA_MAPeriod = 14;            // MA period
INPUT int SAWA_Indi_SAWA_Koef = 8;                 // Koef
INPUT bool SAWA_Indi_SAWA_Arrows = true;           // Show arrows
INPUT int SAWA_Indi_SAWA_Shift = 0;                // Shift

// Structs.

// Defines struct with default user indicator values.
struct Indi_SAWA_Params_Defaults : Indi_SAWA_Params {
  Indi_SAWA_Params_Defaults()
      : Indi_SAWA_Params(::SAWA_Indi_SAWA_CCIPeriod, ::SAWA_Indi_SAWA_RSIPeriod, ::SAWA_Indi_SAWA_MAPeriod,
                         ::SAWA_Indi_SAWA_Koef, ::SAWA_Indi_SAWA_Shift) {}
} indi_sawa_defaults;

// Defines struct with default user strategy values.
struct Stg_SAWA_Params_Defaults : StgParams {
  Stg_SAWA_Params_Defaults()
      : StgParams(::SAWA_SignalOpenMethod, ::SAWA_SignalOpenFilterMethod, ::SAWA_SignalOpenLevel,
                  ::SAWA_SignalOpenBoostMethod, ::SAWA_SignalCloseMethod, ::SAWA_SignalCloseLevel,
                  ::SAWA_PriceStopMethod, ::SAWA_PriceStopLevel, ::SAWA_TickFilterMethod, ::SAWA_MaxSpread,
                  ::SAWA_Shift, ::SAWA_OrderCloseTime) {}
} stg_sawa_defaults;

// Defines struct to store indicator and strategy params.
struct Stg_SAWA_Params {
  StgParams sparams;

  // Struct constructors.
  Stg_SAWA_Params(StgParams &_sparams) : sparams(stg_sawa_defaults) { sparams = _sparams; }
};

// Loads pair specific param values.
#include "config/EURUSD_H1.h"
#include "config/EURUSD_H4.h"
#include "config/EURUSD_H8.h"
#include "config/EURUSD_M1.h"
#include "config/EURUSD_M15.h"
#include "config/EURUSD_M30.h"
#include "config/EURUSD_M5.h"

class Stg_SAWA : public Strategy {
 public:
  Stg_SAWA(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_SAWA *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Indi_SAWA_Params _indi_params(indi_sawa_defaults, _tf);
    StgParams _stg_params(stg_sawa_defaults);
#ifdef __config__
    SetParamsByTf<Indi_SAWA_Params>(_indi_params, _tf, indi_sawa_m1, indi_sawa_m5, indi_sawa_m15, indi_sawa_m30,
                                    indi_sawa_h1, indi_sawa_h4, indi_sawa_h8);
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_sawa_m1, stg_sawa_m5, stg_sawa_m15, stg_sawa_m30, stg_sawa_h1,
                             stg_sawa_h4, stg_sawa_h8);
#endif
    // Initialize indicator.
    _stg_params.SetIndicator(new Indi_SAWA(_indi_params));
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams(_magic_no, _log_level);
    Strategy *_strat = new Stg_SAWA(_stg_params, _tparams, _cparams, "SAWA");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indicator *_indi = GetIndicator();
    bool _is_valid = _indi[_shift].IsValid();
    bool _result = _is_valid;
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double _value = _indi[_shift][0];
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buy signal.
        _result = _indi[_shift][0] < _indi[_shift + 1][0];
        break;
      case ORDER_TYPE_SELL:
        // Sell signal.
        _result = _indi[_shift][0] < _indi[_shift + 1][0];
        break;
    }
    return _result;
  }
};
