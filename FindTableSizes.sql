SELECT
	o.name AS [table_name],
	SUM(p.reserved_page_count) * 8.0 /1024/1024 AS [size_in_gb],
	p.row_count AS [records]
FROM
 sys.dm_db_partition_stats AS p,
 sys.objects AS o
 WHERE
  p.object_id = o.object_id
  AND o.is_ms_shipped = 0

  GROUP BY o.name, p.row_count
  ORDER BY o.name DESC
