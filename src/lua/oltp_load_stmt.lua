
t = sysbench.sql.type
stmt_defs = {
    dml_cond_t01c01_pre = {
                    "select c1 from t1 where mod(rand(), 100) = 1 limit 16000;"},
    dml_cond_t01c02_pre = {
                    "select c2 from t1 where mod(rand(), 100) = 2 limit 10000;"},
    dml_cond_t01c03_pre = {
                    "select c3 from t1 where mod(rand(), 100) = 3 limit 8000;"},
    dml_cond_t01c12_pre = {
                    "select c12 from t1 where mod(rand(), 100) = 4 limit 2000;"},
    dml_cond_t03c01_pre = {
                    "select c1 from t3 where mod(rand(), 100000) = 2 limit 4000;"},
    dml_cond_t04c01_pre = {
                    "select c1 from t4 where mod(rand(), 100000) = 2 limit 10000;"},
    dml_cond_t04c02_pre = {
                    "select c1 from t4 where mod(rand(), 100000) = 3 limit 4000;"},
    dml_cond_t05c01_pre = {
                    "select c1 from t5 where mod(rand(), 100000) = 2 limit 4000;"},
    dml_cond_t06c01_pre = {
                    "select c1 from t6 where mod(rand(), 100000) = 2 limit 2000;"},
    dql_cond_t08c07_pre = {
                    "select c7 from t8 where mod(rand(), 10000) = 2 limit 2000;"},
    dql_cond_t09c02_pre = {
                    "select c2 from t9 where mod(rand(),100) = 2 limit 2000;"},
    dql_cond_t09c03_pre = {
                    "select c3 from t9 where mod(rand(),100) = 3 limit 2000;"},

    dml_t1001_pre = {
                    "select c1 from t1 where mod(rand(), 100) = 1 limit ?;", 
                    t.INT},
    dml_t1001 = {
                "update T1 set c8=? where c1=?;", 
                {t.CHAR, 1}, {t.CHAR, 64}},

    dml_t1002_pre = {
                    "select c1 from t1 where mod(rand(), 100) = 2 limit ?;", 
                    t.INT},
    dml_t1002 = {
                "update t1 set c4 = ? where c1 = ?;",
                {t.CHAR, 50}, {t.CHAR, 64}},

    dml_t1003_pre = {
                    "select c1 from t1 where mod(rand(), 100) = 3 limit ?;", 
                    t.INT},
    dml_t1003 = {
                "update T1 set c5=? where c1=?;", 
                {t.CHAR, 11}, {t.CHAR, 64}},

    dml_t1004_pre = {
                    "select c3 from t1 where mod(rand(), 100) = 2 limit ?;", 
                    t.INT},
    dml_t1004 = {
                "update T1 set c8=? where c8 = 0 and c3 =?;", 
                {t.CHAR, 1},{t.CHAR, 64}},

    dml_t1005_pre = {
                    "select c3 from t1 where mod(rand(), 100) = 3 limit ?;", 
                    t.INT},
    dml_t1005 = {
                "update T1 set c8 = '2' where c3 = ?;", 
                {t.CHAR, 64}},

    dml_t1006 = {
                "insert into T1 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12) " .. 
                "values(?,?,?,?,?,?,?,?,?,?,to_char(sysdate,'YYYY-mm-dd'),?);",
                {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 50}, 
                {t.CHAR, 11}, {t.CHAR, 1}, {t.CHAR, 100}, {t.CHAR, 1}, 
                {t.CHAR, 8}, {t.CHAR, 1}, {t.CHAR, 32}},

    dml_t1007_pre = {
                    "select c1 from t1 where mod(rand(), 100) = 4 limit ?;",
                    t.INT},
    dml_t1007 = {
                "update T1 set c1=?,c2=?,c3=?,c4=?,c5=?,c6=?,c7=?,c8=?,c9=?,c10=?," .. 
                "c11=to_char(sysdate,'YYYY-mm-dd'),c12=? where c1=?;",
                {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 50}, 
                {t.CHAR, 11}, {t.CHAR, 1}, {t.CHAR, 100}, {t.CHAR, 1}, 
                {t.CHAR, 8}, {t.CHAR, 1}, {t.CHAR, 32}, {t.CHAR, 64}},

    dml_t1008_pre = {
                    "select c3 from t1 where mod(rand(), 100) = 4 limit ?;",
                    t.INT},
    dml_t1008 = {
                "update T1 set c8 = '2' where c3 = ?;",
                {t.CHAR, 64}},

    dml_t1009 = {
                "insert into T1 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12) " .. 
                "values(?,?,?,?,?,?,?,?,?,?,to_char(sysdate,'YYYY-mm-dd'),?);",
                {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 50}, 
                {t.CHAR, 11}, {t.CHAR, 1}, {t.CHAR, 100}, {t.CHAR, 1}, 
                {t.CHAR, 8}, {t.CHAR, 1}, {t.CHAR, 32}},

    dml_t1010_pre = {
                    "select c1 from t1 where mod(rand(), 100) = 5 limit ?;",
                    t.INT},
    dml_t1010 = {
                "update T1 set c1=?,c2=?,c3=?,c4=?,c5=?,c6=?,c7=?,c8=?,c9=?,c10=?," ..
                "c11=to_char(sysdate,'YYYY-mm-dd'),c12=? where c1=?;",
                {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 50}, 
                {t.CHAR, 11}, {t.CHAR, 1}, {t.CHAR, 100}, {t.CHAR, 1}, 
                {t.CHAR, 8}, {t.CHAR, 1}, {t.CHAR, 32}, {t.CHAR, 64}},

    dml_t2001_pre = {
                    "select c2 from t1 where mod(rand(), 100) = 2 limit ?;",
                    t.INT},
    dml_t2001 = {
                "insert into T2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) " .. 
                "select SEQ_WZ20002000.Nextval,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11," ..
                "to_char(sysdate,'YYYY-mm-dd') from T1 where c2 =?;",
                {t.CHAR, 64}}, 

    dml_t2002_pre = {
                    "select c2 from t1 where mod(rand(), 100) = 3 limit ?;",
                    t.INT},
    dml_t2002 = {
                "insert into T2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) " ..
                "select SEQ_WZ20002000.Nextval,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11," .. 
                "to_char(sysdate,'YYYY-mm-dd') from T1 where c2 =?;", 
                {t.CHAR, 64}},

    dml_t2003_pre = {
                    "select c2 from t1 where mod(rand(), 100) = 4 limit ?;",
                    t.INT},
    dml_t2003 = {
                "insert into T2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) " ..
                "select SEQ_WZ20002000.Nextval,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11," ..
                "to_char(sysdate,'YYYY-mm-dd') from T1 where c2 =?;",
                {t.CHAR, 64}},

    dml_t2004_pre = {
                    "select c3 from t1 where mod(rand(), 100) = 5 limit ?;",
                    t.INT},
    dml_t2004 = {
                "insert into T2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) " .. 
                "select SEQ_WZ20002000.Nextval,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11," .. 
                "to_char(sysdate,'YYYY-mm-dd') from T1 where c8 = 1 and c3 =?;",
                {t.CHAR, 64}},

    dml_t2005_pre = {
                    "select c2 from t1 where mod(rand(), 100) = 5 limit ?;",
                    t.INT},
    dml_t2005 = {
                "insert into T2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) " .. 
                "select SEQ_WZ20002000.Nextval,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11," .. 
                "to_char(sysdate,'YYYY-mm-dd') from T1 where c2=?;",
                {t.CHAR, 64}},    

    dml_t2006_pre = {
                    "select c2 from t1 where mod(rand(), 100) = 6 limit ?;",
                    t.INT},
    dml_t2006 = {
                "insert into T2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) " .. 
                "select SEQ_WZ20002000.Nextval,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11," .. 
                "to_char(sysdate,'YYYY-mm-dd') from T1 where c2=?;",
                {t.CHAR, 64}}, 

    dml_t4001 = {
                "insert into T4(c1,c2,c3,c4,c5) values(?,?,?,?,?);",
                {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 1}, {t.CHAR, 8}},
    
    dml_t4002_pre = {
                    "select c1 from t4 where mod(rand(), 100000) = 2 limit ?;",
                    t.INT},
    dml_t4002 = {
                "update T4 set c1=?,c2=?,c3=?,c4=?,c5=? where c1=?;",
                {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 1}, {t.CHAR, 8},
                {t.CHAR, 64}},

    dml_t4003 = {
                "insert into T4(c1,c2,c3,c4,c5) values (?,?,?,?,?);",
                {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 1}, {t.CHAR, 8}},

    dml_t4004_pre = {
                    "select c1 from t4 where mod(rand(), 100000) = 3 limit ?;",
                    t.INT},
    dml_t4004 = {
                "update T4 set c1=?,c2=?,c3=?,c4=?,c5=? where c1=?;",
                {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 1}, {t.CHAR, 8},
                {t.CHAR, 64}},

    dml_t4005_pre = {
                    "select c1 from t4 where mod(rand(), 100000) = 4 limit ?;",
                    t.INT},
    dml_t4005 = {
                "update T4 set c2=? where c1=?;", 
                {t.CHAR, 64}, {t.CHAR, 64}},

    dml_t3001 = {
                "insert into T3(c1,c2,c3,c4) values(?,?,?,to_char(sysdate,'YYYY-mm-dd'));",
                {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 1}},

    dml_t3002_pre = {
                    "select c1 from t3 where mod(rand(), 100000) = 2 limit ?;",
                    t.INT},
    dml_t3002 = {
                "update T3 set c1=?,c2=?,c3=?,c4=to_char(sysdate,'YYYY-mm-dd') where c1=?;",
                {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 1}, {t.CHAR, 64}},

    dml_t5001 = {
                "insert into T5 (c1,c2,c3,c4) values (?,?,?,to_char(sysdate,'YYYY-mm-dd'));",
                {t.CHAR, 64}, {t.CHAR, 4000}, {t.CHAR, 1}},

    dml_t5002_pre = {
                    "select c1 from t5 where mod(rand(), 100000) = 2 limit ?;",
                    t.INT},
    dml_t5002 = {
                "update T5 set c1=?,c2=?,c3=?,c4=to_char(sysdate,'YYYY-mm-dd') where c1=?;",
                {t.CHAR, 64}, {t.CHAR, 4000}, {t.CHAR, 1}, {t.CHAR, 64}},

    dml_t6001 = {
                "insert into T6(c1,c2,c3,c4) values(?,?,?,to_char(sysdate,'YYYY-mm-dd'));",
                {t.CHAR, 64}, {t.CHAR, 4000}, {t.CHAR, 1}},

    dml_t6002_pre = {
                    "select c1 from t6 where mod(rand(), 100000) = 2 limit ?;",
                    t.INT},
    dml_t6002 = {
                "update T6 set c1=?,c2=?,c3=?,c4=to_char(sysdate,'YYYY-mm-dd') where c1=?;",
                {t.CHAR, 64}, {t.CHAR, 4000}, {t.CHAR, 1}, {t.CHAR, 64}},

    dml_t7001 = {
                "insert into T7 (c1,c2,c3) values (?,null,?);",
                {t.CHAR, 32}, {t.CHAR, 14}},

    dml_t8001 = {
                "insert into T8(c1,c2,c3,c4,c5,c6,c7,c8,c9) values(?,?,?,?,sysdate,?,?,?,?);",
                {t.CHAR, 32}, {t.CHAR, 64}, {t.CHAR, 8}, {t.CHAR, 200}, {t.CHAR, 1}, {t.CHAR, 64},   
                {t.CHAR, 50}, {t.CHAR, 64}},


   -- Query block
    dql_t8001_pre = {
                    "select c7 from t8 where mod(rand(), 10000) = 2 limit ?;", 
                    t.INT},
    dql_t8001 = {
                "select c1,c4 from t8 where c7=?;", 
                {t.CHAR, 64}},

    dql_t5001_pre = {
                    "select c1 from t5 where mod(rand(), 100000) = 3 limit ?;", 
                    t.INT},
    dql_t5001 = {
                "select c2,c3 from t5 where c1=?;", 
                {t.CHAR, 64}},

    dql_t3001_pre = {
                    "select c1 from t3 where mod(rand(), 100000) = 3 limit ?;", 
                    t.INT},
    dql_t3001 = {
                "select c2 from t3 where c1=?;", 
                {t.CHAR, 64}},

    dql_t4001_pre = {
                    "select c1 from t4 where mod(rand(), 100000) = 5 limit ?;", 
                    t.INT},
    dql_t4001 = {
                "select c3,c4 from t4 where c1=?;", 
                {t.CHAR, 64}},

    dql_t4002_pre = {
                    "select c2 from t4 where mod(rand(), 10000) = 2 limit ?;", 
                    t.INT},
    dql_t4002 = {
                "select c3 from t4 where c2=?;", 
                {t.CHAR, 64}},

    dql_t4003_pre = {
                    "select c2 from t4 where mod(rand(), 10000) = 2 limit ?;", 
                    t.INT},
    dql_t4003 = {
                "select c3 from t4 where c2=?;", 
                {t.CHAR, 64}},

    dql_t4004_pre = {
                    "select c1 from t4 where mod(rand(), 100000) = 6 limit ?;", 
                    t.INT},
    dql_t4004 = {
                "select c3,c4 from t4 where c1=?;", 
                {t.CHAR, 64}},

    dql_t9001_pre = {
                    "select c2 from t9 where mod(rand(),100) = 2 limit ?;", 
                    t.INT},
    dql_t9001 = {
                "select c1,c2 from t9 where c2=?;", 
                {t.CHAR, 64}},

    dql_t9002_pre = {
                    "select c3 from t9 where mod(rand(), 100) = 2 limit ?;", 
                    t.INT},
    dql_t9002 = {
                "select c1,c3 from t9 where c3=?;", 
                {t.CHAR, 64}},

    dql_t1001_pre = {
                    "select c12 from t1 where mod(rand(), 100) = 2 limit ?;", 
                    t.INT},
    dql_t1001 = {
                "select c4,c8,c2,c3,c9,c1,c12 from t1 where c12=?;", 
                {t.CHAR, 32}},

    dql_t1002_pre = {
                    "select c1 from t1 where mod(rand(), 100) = 6 limit ?;", 
                    t.INT},
    dql_t1002 = {
                "select c4,c8,c2,c3,c9,c1,c12 from t1 where c1=?;", 
                {t.CHAR, 64}},

    dql_t1003_pre = {
                    "select c1 from t1 where mod(rand(), 100) = 7 limit ?;", 
                    t.INT},
    dql_t1003 = {
                "select c4,c8,c2,c3,c9,c1,c12 from t1 where c1=?;",  
                {t.CHAR, 64}},

    dql_t1004_pre = {
                    "select c1 from t1 where mod(rand(), 100) = 8 limit ?;", 
                    t.INT},
    dql_t1004 = {
                "select c4,c8,c2,c3,c9,c1,c12 from t1 where c1=?;", 
                {t.CHAR, 64}}
}
