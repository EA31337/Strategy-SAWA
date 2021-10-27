/**
 * @file
 * Implements SAWA strategy based on the SAWA indicator.
 */

// Includes indicator class.
#include "Indi_SAWA.mqh"

// User input params.
INPUT_GROUP("SAWA strategy: strategy params");
INPUT float SAWA_LotSize = 0;                // Lot size
INPUT short SAWA_Shift = 0;                  // Shift (relative to the current bar, 0 - default)
INPUT int SAWA_SignalOpenMethod = 0;         // Signal open method
INPUT int SAWA_SignalOpenFilterMethod = 32;  // Signal open filter method
INPUT int SAWA_SignalOpenFilterTime = 3;     // Signal open filter time
INPUT float SAWA_SignalOpenLevel = 0.0f;     // Signal open level
INPUT int SAWA_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int SAWA_SignalCloseMethod = 0;        // Signal close method
INPUT int SAWA_SignalCloseFilter = 0;        // Signal close filter (-127-127)
INPUT float SAWA_SignalCloseLevel = 0.0f;    // Signal close level
INPUT int SAWA_PriceStopMethod = 1;          // Price limit method
INPUT float SAWA_PriceStopLevel = 2;         // Price limit level
INPUT int SAWA_TickFilterMethod = 32;        // Tick filter method (0-255)
INPUT float SAWA_MaxSpread = 4.0;            // Max spread to trade (in pips)
INPUT float SAWA_OrderCloseLoss = 80;        // Order close loss
INPUT float SAWA_OrderCloseProfit = 80;      // Order close profit
INPUT int SAWA_OrderCloseTime = -30;         // Order close time in mins (>0) or bars (<0)
INPUT_GROUP("SAWA strategy: SAWA indicator params");
INPUT int SAWA_Indi_SAWA_CCIPeriod = 14;  // CCI period
INPUT int SAWA_Indi_SAWA_RSIPeriod = 14;  // RSI period
INPUT int SAWA_Indi_SAWA_MAPeriod = 14;   // MA period
INPUT int SAWA_Indi_SAWA_Koef = 8;        // Koef
INPUT bool SAWA_Indi_SAWA_Arrows = true;  // Show arrows
INPUT int SAWA_Indi_SAWA_Shift = 0;       // Shift

// Structs.

// Defines struct with default user strategy values.
struct Stg_SAWA_Params_Defaults : StgParams {
  Stg_SAWA_Params_Defaults()
      : StgParams(::SAWA_SignalOpenMethod, ::SAWA_SignalOpenFilterMethod, ::SAWA_SignalOpenLevel,
                  ::SAWA_SignalOpenBoostMethod, ::SAWA_SignalCloseMethod, ::SAWA_SignalCloseFilter,
                  ::SAWA_SignalCloseLevel, ::SAWA_PriceStopMethod, ::SAWA_PriceStopLevel, ::SAWA_TickFilterMethod,
                  ::SAWA_MaxSpread, ::SAWA_Shift) {
    Set(STRAT_PARAM_LS, SAWA_LotSize);
    Set(STRAT_PARAM_OCL, SAWA_OrderCloseLoss);
    Set(STRAT_PARAM_OCP, SAWA_OrderCloseProfit);
    Set(STRAT_PARAM_OCT, SAWA_OrderCloseTime);
    Set(STRAT_PARAM_SOFT, SAWA_SignalOpenFilterTime);
  }
};

// Defines struct with default user indicator values.
struct Stg_SAWA_IndiSAWAParams_Defaults : IndiSAWAParams {
  Stg_SAWA_IndiSAWAParams_Defaults()
      : IndiSAWAParams(::SAWA_Indi_SAWA_CCIPeriod, ::SAWA_Indi_SAWA_RSIPeriod, ::SAWA_Indi_SAWA_MAPeriod,
                       ::SAWA_Indi_SAWA_Koef, ::SAWA_Indi_SAWA_Shift) {}
} stg_sawa_indi_sawa_defaults;

#ifdef __config__
// Loads pair specific param values.
#include "config/H1.h"
#include "config/H4.h"
#include "config/H8.h"
#include "config/M1.h"
#include "config/M15.h"
#include "config/M30.h"
#include "config/M5.h"
#endif

class Stg_SAWA : public Strategy {
 public:
  Stg_SAWA(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_SAWA *Init(ENUM_TIMEFRAMES _tf = NULL) {
    // Initialize strategy initial values.
    IndiSAWAParams _indi_params(stg_sawa_indi_sawa_defaults, _tf);
    Stg_SAWA_Params_Defaults stg_sawa_defaults;
    StgParams _stg_params(stg_sawa_defaults);
#ifdef __config__
    SetParamsByTf<IndiSAWAParams>(_indi_params, _tf, indi_sawa_m1, indi_sawa_m5, indi_sawa_m15, indi_sawa_m30,
                                  indi_sawa_h1, indi_sawa_h4, indi_sawa_h8);
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_sawa_m1, stg_sawa_m5, stg_sawa_m15, stg_sawa_m30, stg_sawa_h1,
                             stg_sawa_h4, stg_sawa_h8);
#endif
    // Initialize indicator.
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams;
    Strategy *_strat = new Stg_SAWA(_stg_params, _tparams, _cparams, "SAWA");
    _strat.SetIndicator(new Indi_SAWA(_indi_params));
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indi_SAWA *_indi = GetIndicator();
    bool _result = _indi.GetFlag(INDI_ENTRY_FLAG_IS_VALID, _shift);
    if (!_result) {
      // Returns false when indicator data is not valid.
      return false;
    }
    double _value0 = _indi[_shift][0];
    double _value1 = _indi[_shift][1];
    IndicatorSignal _signals = _indi.GetSignals(4, _shift);
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buy signal.
        _result &= _indi[_shift][0] > _indi[_shift][1];
        _result &= _indi.IsIncreasing(1, 0, _shift);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
      case ORDER_TYPE_SELL:
        // Sell signal.
        _result &= _indi[_shift][0] < _indi[_shift][1];
        _result &= _indi.IsDecreasing(1, 0, _shift);
        _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
        break;
    }
    return _result;
  }
};
