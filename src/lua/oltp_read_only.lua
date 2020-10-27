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

    -- The top 13 elements in the queue must all be 'DQL' --
    local j
    for j=1, 13 do
        
        prepare_read_where_cond(queue[j]) 
        prepare_for_each_table(queue[j])
    end

end


function event()

    -- 1 query per transaction --
    local rng = sysbench.rand.default(1, 1000)
    local no = rng%13 + 1

    if(queue[no] ~= nil) then
        local relt = execute_point_selects(queue[no])
        if(relt ~= nil) then
            relt:free()
        end
    end


    --[[  -- 13 query per transaction --
   
    local j
    for j=1, 13 do 
        local relt = execute_point_selects(queue[j])
        if relt ~= nil then
            relt:free()
        end
    end

    -----END ]]

end

