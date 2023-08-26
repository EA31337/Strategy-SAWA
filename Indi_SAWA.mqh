//+------------------------------------------------------------------+
//|                                      Copyright 2016-2023, EA31337 Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
 * This file is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

// Defines
#ifndef INDI_SAWA_PATH
#define INDI_SAWA_PATH "indicators-other\\PriceBands\\SAWA"
#endif

// Structs.

// Defines struct to store indicator parameter values.
struct IndiSAWAParams : public IndicatorParams {
  // Indicator params.
  int cci_period, rsi_period, ma_period, koef;
  // Struct constructors.
  void IndiSAWAParams(int _cci_period = 14, int _rsi_period = 14, int _ma_period = 2, int _koef = 8, int _shift = 0)
      : cci_period(_cci_period), rsi_period(_rsi_period), ma_period(_ma_period), koef(_koef) {
    max_modes = 2;
#ifdef __resource__
    custom_indi_name = "::" + INDI_SAWA_PATH;
#else
    custom_indi_name = "SAWA";
#endif
    shift = _shift;
    SetDataSourceType(IDATA_ICUSTOM);
    SetDataValueType(TYPE_DOUBLE);
  };
  void IndiSAWAParams(IndiSAWAParams &_params, ENUM_TIMEFRAMES _tf) {
    THIS_REF = _params;
    tf = _tf;
  }
  // Getters.
  int GetCCIPeriod() { return cci_period; }
  int GetRSIPeriod() { return rsi_period; }
  int GetMAPeriod() { return ma_period; }
  int GetKoef() { return koef; }
  int GetShift() { return shift; }
  // Setters.
  void SetCCIPeriod(int _value) { cci_period = _value; }
  void SetRSIPeriod(int _value) { rsi_period = _value; }
  void SetMAPeriod(int _value) { ma_period = _value; }
  void SetKoef(int _value) { koef = _value; }
  void SetShift(int _value) { shift = _value; }
};

/**
 * Implements indicator class.
 */
class Indi_SAWA : public Indicator<IndiSAWAParams> {
 public:
  /**
   * Class constructor.
   */
  Indi_SAWA(IndiSAWAParams &_p, IndicatorBase *_indi_src = NULL) : Indicator<IndiSAWAParams>(_p, _indi_src) {}
  Indi_SAWA(ENUM_TIMEFRAMES _tf = PERIOD_CURRENT) : Indicator(INDI_CUSTOM, _tf){};

  /**
   * Gets indicator's params.
   */
  // IndiSAWAParams GetIndiParams() const { return params; }

  /**
   * Returns the indicator's value.
   *
   */
  IndicatorDataEntryValue GetEntryValue(int _mode, int _shift = 1) {
    double _value = EMPTY_VALUE;
    int _ishift = _shift >= 0 ? _shift : iparams.GetShift();
    switch (iparams.idstype) {
      case IDATA_ICUSTOM:
        _value =
            iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                    iparams.custom_indi_name, iparams.GetCCIPeriod(), iparams.GetRSIPeriod(), iparams.GetMAPeriod(),
                    iparams.GetKoef(), ::SAWA_Indi_SAWA_Arrows, _mode, iparams.GetShift() + _shift);
        break;
      default:
        SetUserError(ERR_USER_NOT_SUPPORTED);
        _value = EMPTY_VALUE;
        break;
    }
    return _value;
  }
};
