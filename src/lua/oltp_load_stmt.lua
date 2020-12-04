
t = sysbench.sql.type

stmt_defs = {

    m1001 = {
            "update T1 set c8=? where c1=?;", {t.CHAR, 1}, {t.CHAR, 64}
    },

    m1002 = {
            "update t1 set c4 = ? where c1 = ?;",{t.CHAR,50},{t.CHAR,64}
    },

    m1003 = {
            "update T1 set c5=? where c1=?;",{t.CHAR,11},{t.CHAR, 64}
    },

    m1004 = {
            "update T1 set c8=? where c8 = 0 and c3 =?;", 
            {t.CHAR, 1},{t.CHAR, 64}
    },

    m1005 = {
            "update T1 set c8 = '2' where c3 = ?;", {t.CHAR, 64}
    },

    m1006 = {
            "insert into T1 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12) " .. 
            "values(?,?,?,?,?,?,?,?,?,?,to_char(sysdate,'YYYY-mm-dd'),?);",
             {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 50}, 
             {t.CHAR, 11}, {t.CHAR, 1}, {t.CHAR, 100}, {t.CHAR, 1}, 
             {t.CHAR, 8}, {t.CHAR, 1}, {t.CHAR, 32}
    },

    m1007 = {
            "update T1 set c1=?,c2=?,c3=?,c4=?,c5=?,c6=?,c7=?,c8=?,c9=?," .. 
            "c10=?,c11=to_char(sysdate,'YYYY-mm-dd'),c12=? where c1=?;",
            {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 50}, 
            {t.CHAR, 11}, {t.CHAR, 1}, {t.CHAR, 100}, {t.CHAR, 1}, 
            {t.CHAR, 8}, {t.CHAR, 1}, {t.CHAR, 32}, {t.CHAR, 64}
    },

    m1008 = {"update T1 set c8 = '2' where c3 = ?;",{t.CHAR, 64}},

    m1009 = {
            "insert into T1 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12) " .. 
            "values(?,?,?,?,?,?,?,?,?,?,to_char(sysdate,'YYYY-mm-dd'),?);",
            {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 50}, 
            {t.CHAR, 11}, {t.CHAR, 1}, {t.CHAR, 100}, {t.CHAR, 1}, 
            {t.CHAR, 8}, {t.CHAR, 1}, {t.CHAR, 32}
    },

    m1010 = {
            "update T1 set c1=?,c2=?,c3=?,c4=?,c5=?,c6=?,c7=?,c8=?,c9=?," ..
            "c10=?,c11=to_char(sysdate,'YYYY-mm-dd'),c12=? where c1=?;",
            {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 50}, 
            {t.CHAR, 11}, {t.CHAR, 1}, {t.CHAR, 100}, {t.CHAR, 1}, 
            {t.CHAR, 8}, {t.CHAR, 1}, {t.CHAR, 32}, {t.CHAR, 64}
    },

    m2001 = {
            "insert into T2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) " .. 
            "select SEQ_WZ20002000.Nextval,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10," .. 
            "c11,to_char(sysdate,'YYYY-mm-dd') from T1 where c2 =?;",
            {t.CHAR, 64}
    }, 

    m2002 = {
            "insert into T2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) " ..
            "select SEQ_WZ20002000.Nextval,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10," .. 
            "c11,to_char(sysdate,'YYYY-mm-dd') from T1 where c2 =?;", 
            {t.CHAR, 64}
    },

    m2003 = {
            "insert into T2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) " ..
            "select SEQ_WZ20002000.Nextval,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10," ..
            "c11,to_char(sysdate,'YYYY-mm-dd') from T1 where c2 =?;",
            {t.CHAR, 64}
    },

    m2004 = {
            "insert into T2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) " .. 
            "select SEQ_WZ20002000.Nextval,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10," ..
            "c11,to_char(sysdate,'YYYY-mm-dd') from T1 where c8 = 1 and c3 =?;",
            {t.CHAR, 64}
    },

    m2005 = {
            "insert into T2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) " .. 
            "select SEQ_WZ20002000.Nextval,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10," ..
            "c11,to_char(sysdate,'YYYY-mm-dd') from T1 where c2=?;",
            {t.CHAR, 64}
    },    

    m2006 = {
            "insert into T2 (c1,c2,c3,c4,c5,c6,c7,c8,c9,c10,c11,c12,c13) " .. 
            "select SEQ_WZ20002000.Nextval,c1,c2,c3,c4,c5,c6,c7,c8,c9,c10," ..
            "c11,to_char(sysdate,'YYYY-mm-dd') from T1 where c2=?;",
            {t.CHAR, 64}
    }, 

    m4001 = {
            "insert into T4(c1,c2,c3,c4,c5) values(?,?,?,?,?);",
            {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 1}, {t.CHAR, 8}
    },
    
    m4002 = {
            "update T4 set c1=?,c2=?,c3=?,c4=?,c5=? where c1=?;",
            {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 1}, {t.CHAR, 8},
            {t.CHAR, 64}
    },

    m4003 = {
            "insert into T4(c1,c2,c3,c4,c5) values (?,?,?,?,?);",
            {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 1}, {t.CHAR, 8}
    },

    m4004 = {
            "update T4 set c1=?,c2=?,c3=?,c4=?,c5=? where c1=?;",
            {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 1}, {t.CHAR, 8},
            {t.CHAR, 64}
    },

    m4005 = {
            "update T4 set c2=? where c1=?;", {t.CHAR, 64}, {t.CHAR, 64}
    },

    m3001 = {
            "insert into T3(c1,c2,c3,c4) values(?,?,?,to_char(sysdate," ..
            "'YYYY-mm-dd'));",
            {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 1}
    },

    m3002 = {
            "update T3 set c1=?,c2=?,c3=?,c4=to_char(sysdate,'YYYY-mm-dd')" ..
            " where c1=?;",
            {t.CHAR, 64}, {t.CHAR, 64}, {t.CHAR, 1}, {t.CHAR, 64}
    },

    m5001 = {
            "insert into T5 (c1,c2,c3,c4) values (?,?,?,to_char(sysdate," ..
            "'YYYY-mm-dd'));",
            {t.CHAR, 64}, {t.CHAR, 4000}, {t.CHAR, 1}
    },

    m5002 = {
            "update T5 set c1=?,c2=?,c3=?,c4=to_char(sysdate,'YYYY-mm-dd')" ..
            " where c1=?;",
            {t.CHAR, 64}, {t.CHAR, 4000}, {t.CHAR, 1}, {t.CHAR, 64}
    },

    m6001 = {
            "insert into T6(c1,c2,c3,c4) values(?,?,?,to_char(sysdate," ..
            "'YYYY-mm-dd'));",
            {t.CHAR, 64}, {t.CHAR, 4000}, {t.CHAR, 1}
    },

    m6002 = {
            "update T6 set c1=?,c2=?,c3=?,c4=to_char(sysdate,'YYYY-mm-dd') " ..
            "where c1=?;",
            {t.CHAR, 64}, {t.CHAR, 4000}, {t.CHAR, 1}, {t.CHAR, 64}
    },

    m7001 = {
            "insert into T7 (c1,c2,c3) values (?,null,?);",
            {t.CHAR, 32}, {t.CHAR, 14}
    },

    m8001 = {
            "insert into T8(c1,c2,c3,c4,c5,c6,c7,c8,c9) values(?,?,?,?," ..
            "sysdate,?,?,?,?);",
            {t.CHAR, 32}, {t.CHAR, 64}, {t.CHAR, 8}, {t.CHAR, 200}, 
            {t.CHAR, 1}, {t.CHAR, 64}, {t.CHAR, 50}, {t.CHAR, 64}
    },

   -- Query block
    q8001 = {"select c1,c4 from t8 where c7=?;", {t.CHAR, 64}},
    q5001 = {"select c2,c3 from t5 where c1=?;", {t.CHAR, 64}},
    q3001 = {"select c2 from t3 where c1=?;", {t.CHAR, 64}},

    q4001 = {"select c3,c4 from t4 where c1=?;", {t.CHAR, 64}},
    q4002 = {"select c3 from t4 where c2=?;", {t.CHAR, 64}},
    q4003 = {"select c3 from t4 where c2=?;", {t.CHAR, 64}},

    q4004 = {"select c3,c4 from t4 where c1=?;", {t.CHAR, 64}},
    q9001 = {"select c1,c2 from t9 where c2=?;", {t.CHAR, 64}},
    q9002 = {"select c1,c3 from t9 where c3=?;", {t.CHAR, 64}},

    q1001 = {
            "select c4,c8,c2,c3,c9,c1,c12 from t1 where c12=?;", 
            {t.CHAR, 32}},

    q1002 = {
            "select c4,c8,c2,c3,c9,c1,c12 from t1 where c1=?;", 
            {t.CHAR, 64}},

    q1003 = {
            "select c4,c8,c2,c3,c9,c1,c12 from t1 where c1=?;",  
            {t.CHAR, 64}},

    q1004 = {
            "select c4,c8,c2,c3,c9,c1,c12 from t1 where c1=?;", 
            {t.CHAR, 64}}
}
