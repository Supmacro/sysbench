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


md = {
    s0032 = {"S", "00000-00000000-00000000-00000000"},
    r0032 = {"R", "00000-########-########-########"},   
    s0050 = {"S", "00000-00000000-00000000-00000000-00000000-00000000"},
    r0064 = {"R", "00000-########-########-########-########-########-########-####"},
    s0064 = {"S", "00000-00000000-00000000-00000000-00000000-00000000-00000000-0000"},
    s0014 = {"S", "00000-00000000"},
    s0100 = {"S", "00000-00000000-00000000-00000000-00000000-00000000-00000000" ..
                                "-00000000-00000000-00000000-00000000-00000000"
            },
    s0008 = {"S", "00000-00"},
    s0011 = {"S", "00000-00000"},
    s0200 = {"S", "00000-00000000-00000000-00000000-00000000-00000000-00000000" ..
                  "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                  "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                  "-00000000-00000000-00000000-0000"
            },
    s4000 = {"S", "00000-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" ..
                       "-00000000-00000000-00000000-00000000-00000000-00000000" 
   },

    c0002 = {"S", "2"},
    c0001 = {"S", "1"},
    c0000 = {"S", "0"},
    p0000 = {"P", "?"},
}


dql = {
            {"q8001", 1000000000, 1328284687},
            {"q5001", 1000000000, 1320000000},
            {"q3001", 1000000000, 2580904251},
            {"q4001", 1000000000, 2912919966},
            {"q4002", 1000000000, 2912919966},
            {"q9001", 1000000000, 1000428158},
            {"q9002", 1000000000, 1000428158},
            {"q1001", 1000000000, 1001928805},
            {"q4003", 1000000000, 2912919966},
            {"q1002", 1000000000, 1001928805},
            {"q1003", 1000000000, 1001928805},
            {"q1004", 1000000000, 1001928805},
            {"q4004", 1000000000, 2912919966}}


dml = {
            {"m1001", 1000000000, 1001928805, {"c0002", "p0000"}},
            {"m2001", 1000000000, 1001928805, {"p0000"}},
            {"m1002", 1000000000, 1001928805, {"s0050", "p0000"}},
            {"m2002", 1000000000, 1001928805, {"p0000"}},
            {"m1003", 1000000000, 1001928805, {"s0011", "p0000"}},
            {"m2003", 1000000000, 1001928805, {"p0000"}},
            {"m1004", 1000000000, 1001928805, {"c0001", "p0000"}},
            {"m2004", 1000000000, 1001928805, {"p0000"}},
            {"m1005", 1000000000, 1001928805, {"p0000"}},
            {"m1006", 1001928806, 1100000000,
                {
                    "r0064", "s0064", "s0064", "s0050", "s0011", 
                    "c0000", "s0100", "c0001", "s0008", "c0001", 
                    "r0032"
                }
            },
            {"m2005", 1000000000, 1001928805, {"p0000"}},
            {"m1007", 1000000000, 1001928805, 
                {
                    "p0000", "s0064", "s0064", "s0050", "s0011", 
                    "c0000", "s0100", "c0001", "s0008", 
                    "c0001", "s0032", "p0000"
                }
            },
            {"m1008", 1000000000, 1001928805, {"p0000"}},
            {"m1009", 1001928806, 1200000000,
                {
                    "r0064", "s0064", "s0064", "s0050", "s0011", 
                    "c0000", "s0100", "c0001", "s0008", "c0001", 
                    "r0032"
                }
            },
            {"m2006", 1000000000, 1001928805, {"p0000"}},
            {"m1010", 1000000000, 1001928805, 
                {
                    "p0000", "s0064", "s0064", "s0050", "s0011", 
                    "c0000", "s0100", "c0001", "s0008", "c0001", 
                    "s0032", "p0000"
                }
            },
            {"m4001", 1, 1000000000, 
                {
                    "r0064", "s0064", "s0064", "c0000", "s0008"
                }
            },
            {"m4002", 1000000000, 2912919966, 
                {
                    "p0000", "s0064", "s0064", "c0001", "s0008", 
                    "p0000"
                }
            },
            {"m3001", 1, 1000000000, {"r0064", "s0064", "c0000"}},
            {"m3002", 1000000000, 2580904251, 
                {
                    "p0000", "s0064", "c0000", "p0000"
                }
            },
            {"m4003", 1, 1000000000, 
                {
                    "r0064", "s0064", "s0064", "c0000", "s0008"
                }
            },
            {"m4004", 1000000000, 2912919966, 
                {
                    "p0000", "s0064", "s0064", "c0001", "s0008", 
                    "p0000"
                }
            },
            {"m4005", 1000000000, 2912919966, {"s0064", "p0000"}},
            {"m5001", 1, 1000000000, {"r0064", "s4000", "c0000"}},
            {"m5002", 1000000000, 1320000000, 
                {
                    "p0000", "s4000", "c0001", "p0000"
                }
            },
            {"m6001", 1, 1000000000, {"r0064", "s4000", "c0000"}},
            {"m6002", 1000000000, 1320000000, 
                {
                    "p0000", "s4000", "c0001", "p0000"
                }
            },
            {"m7001", 1, 1000000000, {"r0032", "s0014"}},
            {"m8001", 1, 1000000000, 
                {
                    "r0032", "s0064", "s0008", "s0200", "c0000", 
                    "r0064", "s0050", "s0064"
                }
            }
    }


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
function execute_point_selects(K, IMIN, IMAX)
   
    local Inx

    if K == "q1001" then
        Inx = string.format("%032d", 
                sysbench.rand.uniform(IMIN, IMAX))
    else
        Inx = string.format("%064d", 
                sysbench.rand.uniform(IMIN, IMAX))
    end

    param[K][1]:set(Inx)
    row = stmt[K]:execute()

    local res = row:fetch_row()

    return row
end


--update index, insert 
function execute_index_update(kv, IMIN, IMAX, tab)

    local Inx = string.format("%064d", 
                sysbench.rand.uniform(IMIN, IMAX))

    for j=1, #tab 
    do
        if md[tab[j]][1] == "S" then
            param[kv][j]:set(md[tab[j]][2])
        elseif md[tab[j]][1] == "P" then
            param[kv][j]:set(Inx)
        else
            param[kv][j]:set_rand_str(md[tab[j]][2])
        end

    end

    stmt[kv]:execute()
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


