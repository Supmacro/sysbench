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

function prepare_statements(tid)
    if not sysbench.opt.skip_trx then
        prepare_begin()
        prepare_commit()
    end

    -- READ 
    for k, v in pairs(dql) do
        prepare_for_each_table(v[1])
    end

    -- WRITE 
    for k, v in pairs(dml) do
        prepare_for_each_table(v[1])
    end

end


function event(tid)

    if not sysbench.opt.skip_trx then
        begin()
    end

    local no = tid % mcap + 1
    local j = no

    execute_index_update(dml[j][1], dml[j][2], dml[j][3], dml[j][4])

    no = tid % 5 + 1
    for j = no, no+8 do
        local row = execute_point_selects(dql[j][1], dql[j][2], dql[j][3])
        row:free()
    end

    if not sysbench.opt.skip_trx then
        commit()
    end

end

