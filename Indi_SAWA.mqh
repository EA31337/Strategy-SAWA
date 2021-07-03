//+------------------------------------------------------------------+
//|                                      Copyright 2016-2021, EA31337 Ltd |
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

// Structs.

// Defines struct to store indicator parameter values.
struct Indi_SAWA_Params : public IndicatorParams {
  // Indicator params.
  int cci_period, rsi_period, ma_period, koef;
  // Struct constructors.
  void Indi_SAWA_Params(int _cci_period, int _rsi_period, int _ma_period, int _koef, int _shift = 0)
      : cci_period(_cci_period), rsi_period(_rsi_period), ma_period(_ma_period), koef(_koef) {
    max_modes = 3;
    custom_indi_name = "SAWA";
    shift = _shift;
    SetDataSourceType(IDATA_ICUSTOM);
    SetDataValueType(TYPE_DOUBLE);
  };
  void Indi_SAWA_Params(Indi_SAWA_Params &_params, ENUM_TIMEFRAMES _tf) {
    this = _params;
    _params.tf = _tf;
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
class Indi_SAWA : public Indicator {
 public:
  // Structs.
  Indi_SAWA_Params params;

  /**
   * Class constructor.
   */
  Indi_SAWA(Indi_SAWA_Params &_p)
      : params(_p.cci_period, _p.rsi_period, _p.ma_period, _p.koef, _p.shift), Indicator((IndicatorParams)_p) {
    params = _p;
  }
  Indi_SAWA(Indi_SAWA_Params &_p, ENUM_TIMEFRAMES _tf)
      : params(_p.cci_period, _p.rsi_period, _p.ma_period, _p.koef, _p.shift), Indicator(NULL, _tf) {
    params = _p;
  }

  /**
   * Gets indicator's params.
   */
  // Indi_SAWA_Params GetIndiParams() const { return params; }

  /**
   * Returns the indicator's value.
   *
   */
  double GetValue(int _mode, int _shift = 0) {
    ResetLastError();
    double _value = EMPTY_VALUE;
    switch (params.idstype) {
      case IDATA_ICUSTOM:
        _value = iCustom(istate.handle, Get<string>(CHART_PARAM_SYMBOL), Get<ENUM_TIMEFRAMES>(CHART_PARAM_TF),
                         params.custom_indi_name, params.GetCCIPeriod(), params.GetRSIPeriod(), params.GetMAPeriod(),
                         params.GetKoef(), ::SAWA_Indi_SAWA_Arrows, _mode, params.GetShift() + _shift);
        break;
      default:
        SetUserError(ERR_USER_NOT_SUPPORTED);
        _value = EMPTY_VALUE;
    }
    istate.is_changed = false;
    istate.is_ready = _LastError == ERR_NO_ERROR;
    return _value;
  }

  /**
   * Returns the indicator's struct value.
   */
  IndicatorDataEntry GetEntry(int _shift = 0) {
    long _bar_time = GetBarTime(_shift);
    unsigned int _position;
    IndicatorDataEntry _entry(params.max_modes);
    if (idata.KeyExists(_bar_time, _position)) {
      _entry = idata.GetByPos(_position);
    } else {
      _entry.timestamp = GetBarTime(_shift);
      for (int _mode = 0; _mode < (int)params.max_modes; _mode++) {
        _entry.values[_mode] = GetValue(_mode, _shift);
      }
      _entry.SetFlag(INDI_ENTRY_FLAG_IS_VALID, _entry.GetMin<double>() >= 0);
      if (_entry.IsValid()) {
        idata.Add(_entry, _bar_time);
      }
    }
    return _entry;
  }
};
