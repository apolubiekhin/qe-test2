WITH sigs_with_filters AS (
   SELECT c.query as query,
          c.doc_id,
          q.filters_s as filters,
          c.type,
          c.ref_time,
          coalesce(c.count_i,1) as count_i,
          c.timestamp_tdt,
          greatest(coalesce(c.weight_d,0.1),0.0) as weight_d
     FROM ${inputCollection} c
 LEFT JOIN (SELECT id, filters_s FROM ${inputCollection} WHERE type='response') q ON q.id = c.fusion_query_id
    WHERE c.type IN (${signalTypes}) AND c.timestamp_tdt >= c.catchup_timestamp_tdt
 ), signal_type_groups AS (
     SELECT SUM(count_i) AS typed_aggr_count_i,
            query,
            doc_id,
            type,
            filters,
            time_decay(count_i, timestamp_tdt, "30 days", ref_time, weight_d) AS typed_weight_d
       FROM sigs_with_filters
   GROUP BY doc_id, query, filters, type
 ) SELECT concat_ws('|', query, doc_id, filters) as id,
          SUM(typed_aggr_count_i) AS aggr_count_i,
          query AS query_s,
          query AS query_t,
          doc_id AS doc_id_s,
          filters AS filters_s,
          SPLIT(filters, ' \\$ ') AS filters_ss,
          weighted_sum(typed_weight_d, type, '${signalTypeWeights}') AS weight_d
     FROM signal_type_groups
 GROUP BY query, doc_id, filters
