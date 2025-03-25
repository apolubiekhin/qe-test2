SELECT concat_ws('|', query_s, doc_id_s, filters_s) as id,
  query_s,
  query_s as query_t,
  doc_id_s,
  filters_s,
  first(aggr_type_s) AS aggr_type_s,
  SPLIT(filters_s, ' \\$ ') AS filters_ss,
  SUM(weight_d) AS weight_d,
  SUM(aggr_count_i) AS aggr_count_i
  FROM x_configuration_signals_aggr
  GROUP BY query_s, doc_id_s, filters_s
