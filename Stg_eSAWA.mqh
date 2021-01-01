/**
 * @file
 * Implements eSAWA strategy based on the eSAWA indicator.
 */

// User input params.
INPUT float eSAWA_LotSize = 0;               // Lot size
INPUT int eSAWA_Shift = 0;                   // Shift (relative to the current bar, 0 - default)
INPUT int eSAWA_SignalOpenMethod = 0;        // Signal open method
INPUT int eSAWA_SignalOpenFilterMethod = 1;  // Signal open filter method
INPUT float eSAWA_SignalOpenLevel = 0.0f;    // Signal open level
INPUT int eSAWA_SignalOpenBoostMethod = 0;   // Signal open boost method
INPUT int eSAWA_SignalCloseMethod = 0;       // Signal close method
INPUT float eSAWA_SignalCloseLevel = 0.0f;   // Signal close level
INPUT int eSAWA_PriceStopMethod = 0;         // Price limit method
INPUT float eSAWA_PriceStopLevel = 2;        // Price limit level
INPUT int eSAWA_TickFilterMethod = 1;        // Tick filter method (0-255)
INPUT float eSAWA_MaxSpread = 4.0;           // Max spread to trade (in pips)
INPUT int eSAWA_OrderCloseTime = -20;        // Order close time in mins (>0) or bars (<0)

// Includes.
#include "Indi_eSAWA.mqh"

// Defines struct with default user strategy values.
struct Stg_eSAWA_Params_Defaults : StgParams {
  Stg_eSAWA_Params_Defaults()
      : StgParams(::eSAWA_SignalOpenMethod, ::eSAWA_SignalOpenFilterMethod, ::eSAWA_SignalOpenLevel,
                  ::eSAWA_SignalOpenBoostMethod, ::eSAWA_SignalCloseMethod, ::eSAWA_SignalCloseLevel,
                  ::eSAWA_PriceStopMethod, ::eSAWA_PriceStopLevel, ::eSAWA_TickFilterMethod, ::eSAWA_MaxSpread,
                  ::eSAWA_Shift, ::eSAWA_OrderCloseTime) {}
} stg_esawa_defaults;

// Defines struct to store indicator and strategy params.
struct Stg_eSAWA_Params {
  StgParams sparams;

  // Struct constructors.
  Stg_eSAWA_Params(StgParams &_sparams) : sparams(stg_esawa_defaults) { sparams = _sparams; }
};

// Loads pair specific param values.
#include "config/EURUSD_H1.h"
#include "config/EURUSD_H4.h"
#include "config/EURUSD_H8.h"
#include "config/EURUSD_M1.h"
#include "config/EURUSD_M15.h"
#include "config/EURUSD_M30.h"
#include "config/EURUSD_M5.h"

class Stg_eSAWA : public Strategy {
 public:
  Stg_eSAWA(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_eSAWA *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Indi_eSAWA_Params _indi_params(indi_esawa_defaults, _tf);
    StgParams _stg_params(stg_esawa_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<Indi_eSAWA_Params>(_indi_params, _tf, indi_esawa_m1, indi_esawa_m5, indi_esawa_m15, indi_esawa_m30,
                                       indi_esawa_h1, indi_esawa_h4, indi_esawa_h8);
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_esawa_m1, stg_esawa_m5, stg_esawa_m15, stg_esawa_m30, stg_esawa_h1,
                               stg_esawa_h4, stg_esawa_h8);
    }
    // Initialize indicator.
    _stg_params.SetIndicator(new Indi_eSAWA(_indi_params));
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_eSAWA(_stg_params, "eSAWA");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indicator *_indi = Data();
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

  /**
   * Gets price limit value for profit take or stop loss.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f) {
    // Indicator *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    // int _bar_count = (int)_level * 10;
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    // ENUM_APPLIED_PRICE _ap = _direction > 0 ? PRICE_HIGH : PRICE_LOW;
    switch (_method) {
      case 1:
        // Trailing stop here.
        break;
    }
    return (float)_result;
  }
};
