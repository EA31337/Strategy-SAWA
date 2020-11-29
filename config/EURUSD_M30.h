/*
 * @file
 * Defines strategy's and indicator's default parameter values
 * for the given pair symbol and timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_eSAWA_Params_M30 : Indi_eSAWA_Params {
  Indi_eSAWA_Params_M30() : Indi_eSAWA_Params(indi_esawa_defaults, PERIOD_M30) { shift = 0; }
} indi_esawa_m30;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_eSAWA_Params_M30 : StgParams {
  // Struct constructor.
  Stg_eSAWA_Params_M30() : StgParams(stg_esawa_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = 0;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = 0;
    price_stop_method = 0;
    price_stop_level = 2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_esawa_m30;
