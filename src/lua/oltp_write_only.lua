#!/usr/bin/env sysbench
-- Copyright (C) 2006-2017 Alexey Kopytov <akopytov@gmail.com>

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

-- ----------------------------------------------------------------------
-- Read/Write OLTP benchmark
-- ----------------------------------------------------------------------

require("oltp_common")

function prepare_statements()
    if not sysbench.opt.skip_trx then
        prepare_begin()
        prepare_commit()
    end

    for k, v in pairs(queue) do
        
        if type(v) == "table" then
            prepare_read_where_cond(v[1]) 
            prepare_for_each_table(v[1])
             
        end
        
    end
end


function event(tid)

    local rng = sysbench.rand.default(1, 1000)
    local no = rng%29 + 14 
        
    if(queue[no] ~= nil and type(queue[no]) == "table") 
    then
        if not sysbench.opt.skip_trx then
            begin()
        end

        execute_index_update(tid, queue[no][1], 
                                  queue[no][2], queue[no][3])
        if not sysbench.opt.skip_trx then
            commit()
        end
    end

end

