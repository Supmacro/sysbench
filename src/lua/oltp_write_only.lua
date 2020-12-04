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
-- Write OLTP benchmark
-- ----------------------------------------------------------------------

require("oltp_common")

function prepare_statements()
    if not sysbench.opt.skip_trx then
        prepare_begin()
        prepare_commit()
    end

    for k, v in pairs(dml) do
            
        prepare_for_each_table(v[1])
    end

end


function event(tid)
    
    if not sysbench.opt.skip_trx then
        begin()
    end

    local no = tid % mcap + 1;

    -- update and insert SQL
    execute_index_update(dml[no][1], dml[no][2], dml[no][3])
    
    if not sysbench.opt.skip_trx then
        commit()
    end

end

