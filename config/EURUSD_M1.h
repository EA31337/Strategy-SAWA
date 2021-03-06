/*
 * @file
 * Defines strategy's and indicator's default parameter values
 * for the given pair symbol and timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_SAWA_Params_M1 : Indi_SAWA_Params {
  Indi_SAWA_Params_M1() : Indi_SAWA_Params(indi_sawa_defaults, PERIOD_M1) { shift = 0; }
} indi_sawa_m1;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_SAWA_Params_M1 : StgParams {
  // Struct constructor.
  Stg_SAWA_Params_M1() : StgParams(stg_sawa_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0;
    price_stop_method = 0;
    price_stop_level = (float)2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_sawa_m1;
