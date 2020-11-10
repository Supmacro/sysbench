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


function thread_init(tid)
    drv = sysbench.sql.driver()
    con = drv:connect()

    -- Create global nested tables for prepared statements and their
    -- parameters. We need a statement and a parameter set for each combination
    -- of connection/table/query
    stmt = {}
    param = {}

    cnt = #queue
    increno = 1
    -- This function is a 'callback' defined by individual benchmark scripts
    prepare_statements(tid)
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


local M8,M11,M32,M50,M64 = "@@@@@@@@", "@@@@@@@@xxx",
                           "@@@@@@@@xxxxxxxx-xxxxxxxxxxxxxxx",
                           "@@@@@@@@xxxxxxxx-xxxxxxxxxxxxxxxx-" ..
                           "xxxxxxxxxxxxxxxx",
                           "@@@@@@@@xxxxxxxx-xxxxxxxxxxxxxxxx-" ..
                           "xxxxxxxxxxxxxxxx-xxxxxxxxxxxxx"

local M14,M100 ="########xxxxxx", 
                "@@@@@@@@xxxxxxxx-xxxxxxxxxxxxxxxx-" ..
                "xxxxxxxxxxxxxxxx-xxxxxxxxxxxxxxxx-" ..
                "xxxxxxxxxxxxxxxx-xxxxxxxxxxxxxxx" 

local NC = "const"


queue = {{"dml_t1001", true, {"2"}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t2001", true, {}},
         {"dml_t1002", true, {M50}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t2002", true, {}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t1003", true, {M11}},
         {"dml_t2003", true, {}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t1004", true, {"1"}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t2004", true, {}},
         {"dml_t1005", true, {}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t1006", false,{M64, M64, M64, M50, M11,"0", M100,"1", M8 , "1", M32}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t2005", true, {}},
         {"dml_t1007", true, {NC, M64, M64, M50, M11,"0", M100,"1", M8 , "1", M32}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t1008", true, {}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t1009", false,{M64, M64, M64, M50, M11,"0", M100,"1", M8 , "1", M32}},
         {"dml_t2006", true, {}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t1010", true, {NC, M64, M64, M50, M11,"0", M100,"1", M8 , "1", M32}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t4001", false,{M64, M64, M64, "0", M8}},
         {"dml_t4002", true, {NC, M64, M64, "1", M8}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t3001", false,{M64, M64, "0"}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t3002", true, {NC, M64, "0"}},
         {"dml_t4003", false,{M64, M64, M64, "0", M8}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t4004", true, {NC, M64, M64, "1", M8}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t4005", true, {M64}},
         {"dml_t5001", false,{M64, M100, "0"}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t5002", true, {NC, M100, "1"}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t6001", false,{M64, M100, "0"}},
         {"dml_t6002", true, {NC, M100, "1"}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t7001", false,{M32, M14}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004",
         {"dml_t8001", false,{M32, M64, M8, M100, "0", M64, M50, M64}},
         "dql_t8001", "dql_t5001", "dql_t3001", "dql_t4001","dql_t4002", "dql_t9001", "dql_t9002", 
         "dql_t1001", "dql_t4003", "dql_t1002", "dql_t1003", "dql_t1004", "dql_t4004"}


--[[ queue = {
    "dml_cond_t01c01",
    "dml_cond_t01c02",
    "dml_cond_t01c03",
    "dml_cond_t01c12",
    "dml_cond_t03c01",
    "dml_cond_t04c01",
    "dml_cond_t04c02",
    "dml_cond_t05c01",
    "dml_cond_t06c01",
    "dql_cond_t08c07",
    "dql_cond_t09c02",
    "dql_cond_t09c03"
}
--]]

cache_top = "/usr/local/share/sysbench/cache_data/"
function _IO(name, mode)

    local fd = io.open(
                string.format("%swhere_cache_%s.txt", cache_top, name),
                mode)
    return fd
end

function _EOF(strv)

    if(string.sub(strv, 1, 1) ~= '\000') then
        return false 
    end
            
   return true
end


max = {}
min = 1 
cap = 2000
where_set = {}

--Read data from the cache file, these data are generally column data 
--that needs to be conditionally indexed later
function prepare_read_where_cond(key)

    local fd = _IO(key, "r")
    if(fd == nil) then
        return nil
    end

    local line = ""
    local j = 1
    where_set[key] = {}

    repeat

        line = fd:read("l")
        if(line ~= nil) 
        then
            where_set[key][j] = line
            j = j +1
        end

    until(line == nil)

    max[key] = #where_set[key]
    fd:close()

end


-- Prepare the dataset. This command supports parallel execution, i.e. will
-- benefit from executing with --threads > 1 as long as --tables > 1
function cmd_prepare()

    os.execute(string.format("mkdir -p %s", cache_top))
    drv = sysbench.sql.driver()
    con = drv:connect()

    param = {}
    stmt = {}

    for k, v in pairs(queue) do

        local lable
        if(type(v) == "table") then
            lable = v[1] .. "_pre"
        else
            lable = v .. "_pre"
        end

        if(stmt_defs[lable] == nil) 
        then
            goto unit
        end

        prepare_for_each_table(lable)
        --param[lable][1]:set(cap)

        local relt = stmt[lable]:execute()
        if (relt ~= nil) 
        then
            local j
            local name

            if(type(v) == "table") then
                name = v[1]
            else
                name = v
            end

            local fd = _IO(name, "w+")

            if(fd ~= nil) then
                fd:close()
            end

            fd = _IO(name, "a+")
            if(fd ~= nil) 
            then
                for j = 1, 16000 do
                    local res = relt:fetch_row()
                    if(res == nil or res[1] == nil) then
                        break    
                    end

                    local bool = _EOF(res[1])
                    if(not bool) then
                        fd:write(string.format("%s\n", res[1]))
                    end

                end

                fd:close()
            end

            io.flush()
            relt:free()
        end

::unit::

    end

    close_statements()
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


-- +------------------------------------------------+
-- |  DQL: POINT SELECT                             |
-- +------------------------------------------------+
function execute_point_selects(key)

    local seq = sysbench.rand.default(min, max[key])
    if(where_set[key][seq] == nil) then
        return nil
    end

    param[key][1]:set(where_set[key][seq])
    relt = stmt[key]:execute()
    local res = relt:fetch_row()
    return relt 

end

-- +------------------------------------------------+
-- |  DML: UPDATE                                   |
-- +------------------------------------------------+
function execute_index_update(tid, key, bool, mode)

    local seq,i,j = tid+1, 0, 0

    for j = 1, #mode do
        if(j == 1 and mode[j] == NC) then
            if(where_set[key][seq] == nil) then
                return nil
            end

            param[key][j]:set(where_set[key][seq])
        else
            param[key][j]:set_rand_str(mode[j])
        end
        
        i = i + 1
    end

    if(bool) then
        if(where_set[key][seq] == nil) then
            return nil
        end

        j = i + 1
        param[key][j]:set(where_set[key][seq])
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


