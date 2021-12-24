clickhouse-client --query="CREATE DATABASE IF NOT EXISTS lab8"
clickhouse-client --query="CREATE TABLE IF NOT EXISTS lab8.userlog
    (
        day UInt16,
        ticktime Float32,
        speed Float32
    ) ENGINE=MergeTree()
    ORDER BY (day, ticktime, speed)"
