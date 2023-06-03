---
title: "PostgreSQL 11 Administration Summary"
date: 2020-05-22 09:48:49 +0300
tags:
- postgresql
- cheatsheet
---

<!-- vim-markdown-toc Marked -->

* [PostgreSQL Administration Cheatsheet](#postgresql-administration-cheatsheet)
  * [Intro](#intro)
  * [New In PostgreSQL 11](#new-in-postgresql-11)
    * [WAL Size](#wal-size)
    * [CREATE STATISTICS](#create-statistics)
    * [INCLUDE indexes](#include-indexes)
    * [CREATE INDEX in parallel](#create-index-in-parallel)
    * [pg_prewarm](#pg_prewarm)
    * [Updated WINDOW Functions](#updated-window-functions)
    * [JIT Compilation](#jit-compilation)
    * [Better Partitioning](#better-partitioning)
      * [Default Partition](#default-partition)
      * [Partition Key Updating](#partition-key-updating)
      * [Hash Partitioning](#hash-partitioning)
      * [Index Created on Parent Table](#index-created-on-parent-table)
    * [Better Support Of Stored Procedures](#better-support-of-stored-procedures)
    * [Faster ALTER TABLE](#faster-alter-table)
  * [Locks and Transactions](#locks-and-transactions)
    * [now() function](#now()-function)
    * [SAVEPOINT](#savepoint)
    * [DDL commands are transaction safe](#ddl-commands-are-transaction-safe)
    * [Explicit Locking](#explicit-locking)
    * [FOR SHARE and FOR UPDATE](#for-share-and-for-update)
      * [SKIP LOCKED](#skip-locked)
    * [Using CTE with RETURNING](#using-cte-with-returning)
    * [FOR SHARE and FOR UPDATE](#for-share-and-for-update)
      * [FOR ... clauses by locking strength](#for-...-clauses-by-locking-strength)
      * [FOR UPDATE SKIP LOCKED](#for-update-skip-locked)
    * [Recommended Locks](#recommended-locks)
  * [VACUUM](#vacuum)
    * [autovacuum](#autovacuum)
    * [Transaction ID Wraparound](#transaction-id-wraparound)
    * [Transaction Duration](#transaction-duration)
  * [Indexing](#indexing)
    * [Costs Model](#costs-model)

<!-- vim-markdown-toc -->

# PostgreSQL Administration Cheatsheet

## Intro

This cheatsheet is based on the great
[book about PostgreSQL 11 Administration](https://www.packtpub.com/product/mastering-postgresql-11-second-edition/9781789537819)

Big thanks to it's author - Hans-Jürgen Schönig.

## New In PostgreSQL 11

### WAL Size

Default WAL size is: **16M**

To change size during setup: `initdb -D /pgdata --wal-segsize=32`

### CREATE STATISTICS

**Note:** _This actually from PostgreSQL 10._

_CREATE STATISTICS will create a new extended statistics object tracking data about the specified table, foreign table or materialized view. The statistics object will be created in the current database and will be owned by the user issuing the command._

The great thing is that statistics collected by every column you need.

References:

- [CREATE STATISTICS](https://www.postgresql.org/docs/10/sql-createstatistics.html)
- [The Postgres 10 feature you didn't know about: CREATE STATISTICS ](https://www.citusdata.com/blog/2018/03/06/postgres-planner-and-its-usage-of-statistics/)

### INCLUDE indexes

In addition to the indexed column, the index can contain an additional column.
This can be useful to avoid table scan and use only index scan.

`CREATE UNIQUE INDEX some_name ON person USING btree (id) INCLUDE (name);`

Note: Always select only those columns you need. When using `SELECT *` you gathering all data from table and that hurts your performance.

### CREATE INDEX in parallel

PostgreSQL can build indexes while leveraging multiple CPUs in order to process the table rows faster. This feature is known as parallel index build. For index methods that support building indexes in parallel (currently, only B-tree), [maintenance_work_mem](https://www.postgresql.org/docs/11/runtime-config-resource.html#GUC-MAINTENANCE-WORK-MEM) specifies the maximum amount of memory that can be used by each index build operation as a whole, regardless of how many worker processes were started. Generally, a cost model automatically determines how many worker processes should be requested, if any.

Parallel index builds may benefit from increasing maintenance_work_mem where an equivalent serial index build will see little or no benefit. Note that maintenance_work_mem may influence the number of worker processes requested, since parallel workers must have at least a 32MB share of the total maintenance_work_mem budget. There must also be a remaining 32MB share for the leader process. Increasing [max_parallel_maintenance_workers](https://www.postgresql.org/docs/11/runtime-config-resource.html#GUC-MAX-PARALLEL-WORKERS-MAINTENANCE) may allow more workers to be used, which will reduce the time needed for index creation, so long as the index build is not already I/O bound. Of course, there should also be sufficient CPU capacity that would otherwise lie idle.

References:

- [CREATE INDEX](https://www.postgresql.org/docs/11/sql-createindex.html)
- [PostgreSQL: Parallel CREATE INDEX for better performance](https://www.cybertec-postgresql.com/en/postgresql-parallel-create-index-for-better-performance/)

### pg_prewarm

```SQL
CREATE EXTENSION pg_prewarm;
SELECT pg_prewarm('tablename');
```

References:

- [Prewarming PostgreSQL I/O caches](https://www.cybertec-postgresql.com/en/prewarming-postgresql-i-o-caches/)

### Updated WINDOW Functions

- [RANGE BETWEEN](https://www.postgresqltutorial.com/postgresql-between/)
- EXCLUDE
  - `EXCLUDE CURRENT ROW`
  - `EXCLUDE TIES`

References:

- [Timeseries: EXCLUDE TIES, CURRENT ROW and GROUP](https://www.cybertec-postgresql.com/en/timeseries-exclude-ties-current-row-and-group/)
- [Window Functions](https://www.postgresql.org/docs/11/tutorial-window.html)

### JIT Compilation

Just-in-Time (JIT) compilation is the process of turning some form of interpreted program evaluation into a native program, and doing so at run time. For example, instead of using general-purpose code that can evaluate arbitrary SQL expressions to evaluate a particular SQL predicate like WHERE a.col = 3, it is possible to generate a function that is specific to that expression and can be natively executed by the CPU, yielding a speedup.

PostgreSQL has builtin support to perform JIT compilation using LLVM when PostgreSQL is built with --with-llvm.

References:

- [JIT Reason](https://www.postgresql.org/docs/11/jit-reason.html)

### Better Partitioning

#### Default Partition

If row does not match any partition already created, it's now can be moved to the default partition.

```sql
CREATE TABLE default_part PARTITION OF another_table DEFAULT;
```

#### Partition Key Updating

Now when updating the value of partition key, row is moved to another partition by PostgreSQL automatically.

#### Hash Partitioning

```sql
CREATE TABLE tab(i int, i text) PARTITION BY HASH (i);
CREATE TABLE tab_0 PARTITION OF tab FOR VALUES WITH (MODULUS 4, REMAINDER 0);
```

#### Index Created on Parent Table

Now when creating index on parent table it automatically created on all child\`s tables.
Also, creating "global" unique index on parent table creates unique index on all child\`s table.

References:

- [A Guide to Partitioning Data In PostgreSQL](https://severalnines.com/database-blog/guide-partitioning-data-postgresql)
- [How to Take Advantage of the New Partitioning Features in PostgreSQL 11](https://severalnines.com/database-blog/how-take-advantage-new-partitioning-features-postgresql-11)
- [Table Partitioning](https://www.postgresql.org/docs/11/ddl-partitioning.html)

### Better Support Of Stored Procedures

Main difference between functions ans procedures in PostgreSQL is that function is a part of transaction.
But procedure may contain multiple transactions.

```sql
CREATE PROCEDURE test_proc()
  LANGUAGE plpgsql
  AS $$
    BEGIN
      CREATE TABLE a (aid int);
      CREATE TABLE b (bid int);
      COMMIT;
      CREATE TABLE c (cid int);
      ROLLBACK;
    END;
  $$;
```

### Faster ALTER TABLE

To add a column to the table we can use such command:

```sql
ALTER TABLE x ADD COLUMN y int;
ALTER TABLE x ADD COLUMN z int DEFAULT 57;
```

First command will work fast always, because it simply updates system catalog.
Second command will work fast only in PostgreSQL 11 and newer versions.
In the PG10 this will lead table to be rewritten which may be slow.

## Locks and Transactions

### now() function

`now()` function returns time of the transaction beginning. So calling it twice in one transaction will return the same data. If you need the real time, you have to use function `clock_timestamp()`

### [SAVEPOINT](https://www.postgresql.org/docs/11/sql-savepoint.html)

In long transaction which may fail in the middle of process it's possible to use savepoint and rollback to it saving the job that already completed successfully.

```sql
postgres=# BEGIN;
BEGIN
postgres=# SELECT 1;
 ?column?
----------
        1
(1 row)

postgres=# SAVEPOINT a;
SAVEPOINT
postgres=# SELECT 1 / 0;
ERROR:  division by zero
postgres=# SELECT 2;
ERROR:  current transaction is aborted, commands ignored until end of transaction block
postgres=# ROLLBACK TO SAVEPOINT a;
ROLLBACK
postgres=# SELECT 3;
 ?column?
----------
        3
(1 row)

postgres=# COMMIT;
COMMIT
```

### DDL commands are transaction safe

It's possible to create and modify tables in transaction then rollback all changes during error.

```sql
postgres=# CREATE DATABASE test;
CREATE DATABASE
postgres=# \c test
You are now connected to database "test" as user "postgres".
test=# \d
Did not find any relations.
test=# BEGIN;
BEGIN
test=# CREATE TABLE t_test (id int);
CREATE TABLE
test=# ALTER TABLE t_test ALTER COLUMN id TYPE int8;
ALTER TABLE
test=# \d t_test;
              Table "public.t_test"
 Column |  Type  | Collation | Nullable | Default
--------+--------+-----------+----------+---------
 id     | bigint |           |          |

test=# ROLLBACK;
ROLLBACK
test=# \d
Did not find any relations.
```

### Explicit Locking

Sometime it's needed to use locks to fix this kind of errors:

| Transaction 1                            | Transaction 2                            |
|------------------------------------------|------------------------------------------|
| BEGIN;                                   | BEGIN;                                   |
| SELECT max(id) FROM product;             | SELECT max(id) FROM product;             |
| -- query returned 17                     | -- query returned 17                     |
| -- user added product 18                 | -- user added product 18                 |
| INSERT INTO product ... VALUES (18, ...) | INSERT INTO product ... VALUES (18, ...) |
| COMMIT;                                  | COMMIT;                                  |

This error can be avoided this way:

```sql
BEGIN;
LOCK TABLE product in ACCESS EXCLUSIVE MODE;
INSERT INTO product SELECT max(id) + 1, ... FROM product;
COMMIT;
```

But this is very bad for performance reasons.
Alternative solutions is to separate tables in this way:

```sql
CREATE TABLE t_invoice (id int PRIMARY KEY);
CREATE TABLE t_watermark (id int);
INSERT INTO t_watermark VALUES (0);
WITH x AS (UPDATE t_watermark SET id = id + 1 RETURNING id)
  INSERT INTO t_invoice
  SELECT * FROM x RETURNING id;
```

Only one UPDATE can be occurred at once but this does not blocks SELECT queries.

References:

- [Explicit Locking](https://www.postgresql.org/docs/11/explicit-locking.html)

### FOR SHARE and FOR UPDATE

This is **wrong**:

```sql
BEGIN;
SELECT * FROM invoice WHERE processed = false;
-- now make some work with returned data
UPDATE invoice SET processed = true ...
COMMIT;
```

Multiple requests can select the same data and then try to insert updated data.
`SELECT FOR UPDATE` for the rescue.

```sql
BEGIN;
SELECT * FROM invoice WHERE processed = false FOR UPDATE;
-- now processing data with modifications
UPDATE invoice SET processed = true;
COMMIT;
```

When running multiple transactions on the same rows the second one will wait until the first one will end. But we can skip them with `NOWAIT`.

| Transaction 1                                      | Transaction 2                                           |
|----------------------------------------------------|---------------------------------------------------------|
| BEGIN;                                             | BEGIN;                                                  |
| SELECT ... FROM table WHERE ... FOR UPDATE NOWAIT; |                                                         |
| -- processing                                      | SELECT ... FROM tab WHERE ... FOR UPDATE NOWAIT;        |
| -- still processing                                | ERROR: could not obtain lock on row in relation "table" |

There is also parameter `lock_timeout` to set how long we are ready to wait lock.

```sql
SET lock_timeout TO 5000; -- set timeout to 5 seconds
```

#### SKIP LOCKED

`SELECT FOR UDATE` can block others requests for UPDATE

| Transaction 1                             | Transaction 2                             |
|-------------------------------------------|-------------------------------------------|
| BEING;                                    | BEING;                                    |
| SELECT ... FROM table LIMIT 1 FOR UPDATE; |                                           |
| -- waiting for user action                | SELECT ... FROM table LIMIT 1 FOR UPDATE; |
| -- waiting for user action                | -- waiting Transaction 1                  |

To fix that we can use `SKIP LOCKED`.

| Transaction 1                                       | Transaction 2                                       |
|-----------------------------------------------------|-----------------------------------------------------|
| BEGIN;                                              | BEGIN;                                              |
| SELECT * FROM table LIMIT 2 FOR UPDATE SKIP LOCKED; | SELECT * FROM table LIMIT 2 FOR UPDATE SKIP LOCKED; |
| -- returns first pair of not locked rows            | -- returns second pair of not locked rows           |

**Note**:
When using `FOR UPDATE` on table with `FOREIGN KEY`, both tables will be blocked.

### Using CTE with RETURNING

When you need to update record and use result value and don't want to use explicit blocking or long transaction, it's possible to use CTE and UPDATE with RETURNING statement.

**Example:**
```sql
test=# CREATE TABLE t_order (id int PRIMARY KEY);
CREATE TABLE

test=# CREATE TABLE t_room (id int);
CREATE TABLE

test=# INSERT INTO t_room VALUES (0);
INSERT 0

test=# WITH x AS (UPDATE t_room SET id = id + 1 RETURNING *)
        INSERT INTO t_order
        SELECT * FROM x RETURNING *;

 id
____
  1
```

---

### FOR SHARE and FOR UPDATE

To select some data for database, process it and then update this data in database there is a SELECT FOR UPDATE  statement for that.


#### FOR ... clauses by locking strength

The locking clause has general form:

```sql
FOR [lock_strength] [ OF table_name [, ...] ] [ NOWAIT | SKIP LOCKED ]
```

where *lock_strength* can be one of:

- **UPDATE** (when we definitely want to update record, most strong lock)
- **NO KEY UPDATE** (the lock is weaker and can coexist with **SELECT FOR SHARE**)
- **SHARE** (this type lock can be handled by multiple transactions)
- **KEY SHARE** (like **SHARE** lock but weaker. this lock conflicts with **FOR UPDATE** but can coexist with **FOR NO KEY UPDATE**)

See more details [here](https://www.postgresql.org/docs/11/sql-select.html)

---

#### FOR UPDATE SKIP LOCKED

```sql
test=# CREATE TABLE t_room AS
        SELECT * FROM generate_series(1, 200) AS id;
SELECT 200
```

| Transaction 1                                          | Transaction 2                                          |
|--------------------------------------------------------|--------------------------------------------------------|
| `BEGIN;`                                               | `BEGIN;`                                               |
| `SELECT * FROM t_room LIMIT 2 FOR UPDATE SKIP LOCKED;` | `SELECT * FROM t_room LIMIT 2 FOR UPDATE SKIP LOCKED;` |
| # **returns 1, 2**                                     | # **returns 3, 4**                                     |


This only works well if there is no [REFERENCES](https://www.postgresqltutorial.com/postgresql-foreign-key/) in the table. If table have [REFERENCES](https://www.postgresqltutorial.com/postgresql-foreign-key/) second transaction with UPDATE will be blocked till first transaction will end.

---

### Recommended Locks

It's possible to use locks for applications synchronization.
In this case you lock not rows but numbers instead.

| Transaction 1                    | Transaction 2                  |
|----------------------------------|--------------------------------|
| `BEGIN;`                         |                                |
| `SELECT pg_advisory_lock(15);`   |                                |
|                                  | `SELECT pg_advisory_lock(15);` |
|                                  | waiting for lock...            |
|                                  | waiting for lock...            |
| `COMMIT;`                        | waiting for lock...            |
| `SELECT pg_advisory_unlock(15);` | waiting for lock...            |
|                                  |  lock granted!                 |

Handy functions:
 - `pg_advisory_unlock_all()` - unlock all previous locks
 - `pg_try_advisory_lock()` - get lock if possible

 More details in [documentation](https://www.postgresql.org/docs/11/functions-admin.html)

---

## VACUUM
### autovacuum

[Options](https://www.postgresql.org/docs/11/runtime-config-autovacuum.html):
 - **autovacuum_naptime**: Specifies the minimum delay between autovacuum runs on any given database. The delay is measured in seconds, and the default is one minute (1min).
 - **autovacuum_vacuum_threshold**: Specifies the minimum number of updated or deleted tuples needed to trigger a VACUUM in any one table. The default is 50 tuples.
 - **autovacuum_analyze_threshold**: Specifies the minimum number of inserted, updated or deleted tuples needed to trigger an ANALYZE in any one table. The default is 50 tuples.
 - **autovacuum_vacuum_scale_factor**: Specifies a fraction of the table size to add to autovacuum_vacuum_threshold when deciding whether to trigger a VACUUM. The default is 0.2 (20% of table size).
 - **autovacuum_analyze_scale_factor**: Specifies a fraction of the table size to add to autovacuum_analyze_threshold when deciding whether to trigger an ANALYZE. The default is 0.1 (10% of table size).

---

### Transaction ID Wraparound

[Options](https://www.postgresql.org/docs/11/runtime-config-autovacuum.html):
 - **autovacuum_freeze_max_age**: Specifies the maximum age (in transactions) that a table's pg_class.relfrozenxid field can attain before a VACUUM operation is forced to prevent transaction ID wraparound within the table. Note that the system will launch autovacuum processes to prevent wraparound even when autovacuum is otherwise disabled.
 - **autovacuum_multixact_freeze_max_age**: Specifies the maximum age (in multixacts) that a table's pg_class.relminmxid field can attain before a VACUUM operation is forced to prevent multixact ID wraparound within the table. Note that the system will launch autovacuum processes to prevent wraparound even when autovacuum is otherwise disabled.

Wraparound References:
  - https://www.postgresql.org/docs/11/routine-vacuuming.html#VACUUM-FOR-WRAPAROUND
  - https://www.cybertec-postgresql.com/en/autovacuum-wraparound-protection-in-postgresql/

---

### Transaction Duration

**old_snapshot_threshold**: Sets the minimum time that a snapshot can be used without risk of a snapshot too old error occurring when using the snapshot. This parameter can only be set at server start.

Beyond the threshold, old data may be vacuumed away. This can help prevent bloat in the face of snapshots which remain in use for a long time. To prevent incorrect results due to cleanup of data which would otherwise be visible to the snapshot, an error is generated when the snapshot is older than this threshold and the snapshot is used to read a page which has been modified since the snapshot was built. [More details](https://www.postgresql.org/docs/11/runtime-config-resource.html#GUC-OLD-SNAPSHOT-THRESHOLD).

## Indexing

### Costs Model

Costs formula for `Seq Scan`:

```
(blocks to read * seq_page_cost) \
  + (rows scanned * cpu_tuple_cost + rows scanned * cpu_operator_cost)
```

To get sum of block per table:

```sql
SELECT pg_relation_size('table_name') / 8192.0;
```

Useful [options](https://www.postgresql.org/docs/11/runtime-config-query.html):
  - [random_page_cost](https://www.postgresql.org/docs/11/runtime-config-query.html#GUC-RANDOM-PAGE-COST): Sets the planner's estimate of the cost of a non-sequentially-fetched disk page. The default is 4.0.
  - [cpu_index_tuple_cost](https://www.postgresql.org/docs/11/runtime-config-query.html#GUC-CPU-INDEX-TUPLE-COST): Sets the planner's estimate of the cost of processing each index entry during an index scan. The default is 0.005.

For parallel jobs:
  - [parallel_tuple_cost](https://www.postgresql.org/docs/11/runtime-config-query.html#GUC-PARALLEL-TUPLE-COST): Sets the planner's estimate of the cost of transferring one tuple from a parallel worker process to another process. The default is 0.1.
  - [parallel_setup_cost](https://www.postgresql.org/docs/11/runtime-config-query.html#GUC-PARALLEL-SETUP-COST): Sets the planner's estimate of the cost of launching parallel worker processes. The default is 1000.
  - [min_parallel_table_scan_size](https://www.postgresql.org/docs/11/runtime-config-query.html#GUC-MIN-PARALLEL-TABLE-SCAN-SIZE): Sets the minimum amount of table data that must be scanned in order for a parallel scan to be considered. The default is 8 megabytes (8MB).
  - [min_parallel_index_scan_size](https://www.postgresql.org/docs/11/runtime-config-query.html#GUC-MIN-PARALLEL-INDEX-SCAN-SIZE): Sets the minimum amount of index data that must be scanned in order for a parallel scan to be considered. The default is 512 kilobytes (512kB).

References:

- https://www.postgresql.org/docs/11/runtime-config-query.html
- https://www.postgresql.org/docs/11/index-cost-estimation.html

<style>
table{
  border-collapse: collapse;
  border-spacing: 0;
  border:2px solid #000000;
}

th{
  border:2px solid #000000;
}

td{
  border:1px solid #000000;
}
</style>

