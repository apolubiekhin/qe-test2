WITH session_agg AS (
     SELECT COUNT(1) AS activity_count,
            MIN(timestamp_tdt) AS start,
            MAX(timestamp_tdt) AS end,
            timediff(MAX(timestamp_tdt), MIN(timestamp_tdt), "MINUTES") AS duration,
            'session' AS type,
            first(user_id) AS user,
            session_keywords(query) AS keywords,
            session
       FROM ${inputCollection}
      WHERE timestamp_tdt IS NOT NULL
        AND type != 'session'
        AND session IS NOT NULL
        AND session NOT IN (SELECT session FROM ${inputCollection} WHERE type = 'session' AND session IS NOT NULL)
   GROUP BY session
     HAVING timediff(current_timestamp(), MAX(timestamp_tdt), "SECONDS") >= ${elapsedSecsSinceLastActivity} OR timediff(current_timestamp(), MIN(timestamp_tdt), "SECONDS") >= ${elapsedSecsSinceSessionStart})
 SELECT activity_count, start, end, duration, type, user, keywords, session FROM session_agg
