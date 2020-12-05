-- Copyright (C) 2006-2018 Alexey Kopytov <akopytov@gmail.com>

-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA

-- -----------------------------------------------------------------------------
-- Common code for OLTP benchmarks.
-- -----------------------------------------------------------------------------

require("oltp_load_stmt")

function init()
    assert(event ~= nil,
          "this script is meant to be included by other OLTP scripts and " ..
             "should not be called directly.")
end

if sysbench.cmdline.command == nil then
    error("Command is required. Supported commands: prepare, prewarm, run, " ..
            "cleanup, help")
end

-- Command line options
sysbench.cmdline.options = {
    table_size = {"Number of rows per table", 10000},
    range_size = {"Range size for range SELECT queries", 100},
    tables = {"Number of tables", 1},

    point_selects = 
        {"Number of point SELECT queries per transaction", 10},
    simple_ranges =
        {"Number of simple range SELECT queries per transaction", 1},
    sum_ranges =
        {"Number of SELECT SUM() queries per transaction", 1},
    order_ranges =
        {"Number of SELECT ORDER BY queries per transaction", 1},
    distinct_ranges =
        {"Number of SELECT DISTINCT queries per transaction", 1},
    index_updates =
        {"Number of UPDATE index queries per transaction", 1},
    non_index_updates =
        {"Number of UPDATE non-index queries per transaction", 1},
    delete_inserts =
        {"Number of DELETE/INSERT combinations per transaction", 1},
    range_selects =
        {"Enable/disable all range SELECT queries", true},
    auto_inc =
        {"Use AUTO_INCREMENT column as Primary Key (for MySQL), " ..
        "or its alternatives in other DBMS. When disabled, use " ..
        "client-generated IDs", false},
    skip_trx =
        {"Don't start explicit transactions and execute all queries " ..
          "in the AUTOCOMMIT mode", true},
    secondary =
        {"Use a secondary index in place of the PRIMARY KEY", false},
    create_secondary =
        {"Create a secondary index in addition to the PRIMARY KEY", true},
    mysql_storage_engine =
        {"Storage engine, if MySQL is used", "innodb"},
    pgsql_variant =
        {"Use this PostgreSQL variant when running with the " ..
          "PostgreSQL driver. The only currently supported " ..
          "variant is 'redshift'. When enabled, " ..
          "create_secondary is automatically disabled, and " ..
          "delete_inserts is set to 0"
        }
}

-- Template strings of random digits with 11-digit groups separated by dashes

-- 10 groups, 119 characters
local c_value_template = "###########-###########-###########-" ..
    "###########-###########-###########-" ..
    "###########-###########-###########-" ..
    "###########"

-- 5 groups, 59 characters
local pad_value_template = "###########-###########-###########-" ..
    "###########-###########"


function prepare_begin()
   stmt.begin = con:prepare("BEGIN")
end


function prepare_commit()
   stmt.commit = con:prepare("COMMIT")
end


function prepare_for_each_table(key)

    if(stmt[key] ~= nil) then
        return false 
    end

    stmt[key] = con:prepare(string.format(stmt_defs[key][1]))
    local nparam = #stmt_defs[key] - 1
    if nparam > 0 then
        param[key] = {}
    end

    for p = 1, nparam do
        local btype = stmt_defs[key][p+1]
        local len

        if type(btype) == "table" then
            len = btype[2]
            btype = btype[1]
        end

        if btype == sysbench.sql.type.VARCHAR or
                btype == sysbench.sql.type.CHAR then
            param[key][p] = stmt[key]:bind_create(btype, len)
        else
            param[key][p] = stmt[key]:bind_create(btype)
        end
    end

    if nparam > 0 then
        stmt[key]:bind_param(unpack(param[key]))
    end

    return true 
   
end


function thread_init()
    drv = sysbench.sql.driver()
    con = drv:connect()

    -- Create global nested tables for prepared statements and their
    -- parameters. We need a statement and a parameter set for each combination
    -- of connection/table/query
    stmt = {}
    param = {}

    qcap = #dql
    mcap = #dml

    increno = 1
    -- This function is a 'callback' defined by individual benchmark scripts
    prepare_statements()
end


-- Close prepared statements
function close_statements()
    for k, s in pairs(stmt) do
        stmt[k]:close()
    end
end


function thread_done()
    close_statements()
    con:disconnect()
end


function cleanup()
    --local drv = sysbench.sql.driver()
    --local con = drv:connect()

    --for i = 1, sysbench.opt.tables do
    --   print(string.format("Dropping table 'sbtest%d'...", i))
    --   con:query("DROP TABLE sbtest" .. i )
    --end
end

--return sysbench.rand.uniform(min, max)
--return sysbench.rand.default(min, max)


function begin()
    stmt.begin:execute()
end


function commit()
    stmt.commit:execute()
end


local m8, m11 = "@@@@@@@@", "@@@@@@@@@@@"

local m32 = "#####-@@@@@@@@-@@@@@@@@-@@@@@@@@"
local m50 = "#####-@@@@@@@@-@@@@@@@@-@@@@@@@@-cccccccc-cccccccc"
local m64 = "#####-@@@@@@@@-@@@@@@@@-@@@@@@@@-cccccccc-cccccccc-cccccccc-cccc"
local m14 = "#####-@@@@@@@@"

local m100 = "#####-@@@@@@@@-@@@@@@@@-@@@@@@@@-cccccccc-cccccccc-cccccccc" ..
                "-cccccccc-cccccccc-cccccccc-cccccccc-cccc"

local m200 = "#####-@@@@@@@@-@@@@@@@@-@@@@@@@@-cccccccc-cccccccc-cccccccc" ..
                  "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                  "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                  "-cccccccc-cccccccc-cccccccc-cccc"

local m4000 = "#####-@@@@@@@@-@@@@@@@@-@@@@@@@@-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc-cccccccc" ..
                   "-cccccccc-cccccccc-cccccccc-cccc"

local i641 = 1001928805
local i642 = 1000100316
local i643 = 1580904251
local i644 = 1912919966
local i645 = 1320000000
local i646 = 1320000000
local i647 = 1000225858
local i648 = 1328284687
local i649 = 1000428158
local i32 = 1000000000


dql = {
            {"q8001", i648},
            {"q5001", i645},
            {"q3001", i643},
            {"q4001", i644},
            {"q4002", i644},
            {"q9001", i649},
            {"q9002", i649},
            {"q1001", i641},
            {"q4003", i644},
            {"q1002", i641},
            {"q1003", i641},
            {"q1004", i641},
            {"q4004", i644}}


dml = {
            {"m1001", i641, {"2", "?"}},
            {"m2001", i642, {"?"}},
            {"m1002", i641, {m50, "?"}},
            {"m2002", i642, {"?"}},
            {"m1003", i641, {m11, "?"}},
            {"m2003", i642, {"?"}},
            {"m1004", i641, {"1", "?"}},
            {"m2004", i642, {"?"}},
            {"m1005", i641, {"?"}},
            {"m1006", i32,
                {m64, m64, m64, m50, m11,"0", m100,"1", m8 , "1", m32}
            },
            {"m2005", i642, {"?"}},
            {"m1007", i641, 
                {"?", m64, m64, m50, m11, "0", m100,"1", m8 , "1", m32, "?"}
            },
            {"m1008", i641, {"?"}},
            {"m1009", i32,
                {m64, m64, m64, m50, m11, "0", m100, "1", m8, "1", m32}
            },
            {"m2006", i642, {"?"}},
            {"m1010", i641, 
                {"?", m64, m64, m50, m11, "0", m100, "1", m8, "1", m32, "?"}
            },
            {"m4001", i32, {m64, m64, m64, "0", m8}},
            {"m4002", i644, {"?", m64, m64, "1", m8, "?"}},
            {"m3001", i32, {m64, m64, "0"}},
            {"m3002", i643, {"?", m64, "0", "?"}},
            {"m4003", i32, {m64, m64, m64, "0", m8}},
            {"m4004", i644, {"?", m64, m64, "1", m8, "?"}},
            {"m4005", i644, {m64, "?"}},
            {"m5001", i32, {m64, m4000, "0"}},
            {"m5002", i645, {"?", m4000, "1", "?"}},
            {"m6001", i32, {m64, m4000, "0"}},
            {"m6002", i646, {"?", m4000, "1", "?"}},
            {"m7001", i32, {m32, m14}},
            {"m8001", i32,
                {m32, m64, m8, m200, "0", m64, m50, m64}
            }}


-- Prepare the dataset. This command supports parallel execution, i.e. will
-- benefit from executing with --threads > 1 as long as --tables > 1
function cmd_prepare()

    drv = sysbench.sql.driver()
    con = drv:connect()

    con:disconnect() 

end

-- Preload the dataset into the server cache. This command supports parallel
-- execution, i.e. will benefit from executing with --threads > 1 as long as
-- --tables > 1
--
-- PS. Currently, this command is only meaningful for MySQL/InnoDB benchmarks
--function cmd_prewarm()
--end


-- Implement parallel prepare and prewarm commands
sysbench.cmdline.commands = {
    prepare = {cmd_prepare, sysbench.cmdline.PARALLEL_COMMAND},
    prewarm = {cmd_prewarm, sysbench.cmdline.PARALLEL_COMMAND}
}


--point select  
function execute_point_selects(K, I)
    
    local Inx = string.format("%064d", 
                sysbench.rand.uniform(1000000000, I))

    param[K][1]:set(Inx)
    row = stmt[K]:execute()

    local res = row:fetch_row()
    return row
end


--update index, insert 
function execute_index_update(kv, bv, tab)

    local Inx = string.format("%064d", 
                sysbench.rand.uniform(1000000000, I))

    for j=1, #tab 
    do
        if tab[j] == "?" then
            param[kv][j]:set(Inx)
        else
            param[kv][j]:set_rand_str(tab[j])
        end

    end

    stmt[key]:execute()
end


-- Re-prepare statements if we have reconnected, which is possible when some of
-- the listed error codes are in the --mysql-ignore-errors list
function sysbench.hooks.before_restart_event(errdesc)
   if errdesc.sql_errno == 2013 or -- CR_SERVER_LOST
      errdesc.sql_errno == 2055 or -- CR_SERVER_LOST_EXTENDED
      errdesc.sql_errno == 2006 or -- CR_SERVER_GONE_ERROR
      errdesc.sql_errno == 2011    -- CR_TCP_CONNECTION
   then
      close_statements()
      prepare_statements()
   end
end


