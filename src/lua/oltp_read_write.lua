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

    local bool
    for k, v in pairs(queue) do
        if(v ~= nil and type(v) == "table") then
            
            bool = prepare_for_each_table(v[1])
            if bool then
                prepare_read_where_cond(v[1])
            end
        else
            bool = prepare_for_each_table(v)
            if bool then
                prepare_read_where_cond(v)
            end
        end
    end

end


function event(tid)

    if not sysbench.opt.skip_trx then
        begin()
    end

    local j = increno%cnt + 1
    if(queue[j] ~= nil and type(queue[j]) == "table") then
        execute_index_update(tid, queue[j][1], 
                                  queue[j][2], queue[j][3])
    else
        local relt = execute_point_selects(queue[j])
        if(relt ~= nil) then
            relt:free()
        end
    end
    
    if not sysbench.opt.skip_trx then
        commit()
    end

    increno = increno + 1
    if increno >= 999999999 then
        increno = 0 
    end

end

