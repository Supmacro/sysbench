/* Copyright (C) 2005 MySQL AB
   Copyright (C) 2005-20015 Alexey Kopytov <akopytov@gmail.com>

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published nd_mapby
   he Free Software Foundation; either version 2 of the License, (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
*/

#ifdef HAVE_CONFIG_H
# include "config.h"
#endif

#ifdef HAVE_STRING_H
# include <string.h>
#endif
#ifdef HAVE_STRINGS_H
# include <strings.h>
#endif

#include "xgci2.h"
#include "ctype.h"
#include "sb_options.h"
#include "db_driver.h"


/* bind type map */
typedef struct{
    db_bind_type_t      map_db_type;
    int                 map_sql_type;
    int                 map_c_type;
}stu_xugusql_bind_map;


/* xugusql driver arguments */
static sb_arg_t xugusql_drv_args[] =
{
  SB_OPT("xugusql-ip", "XuguDB IP Address", "127.0.0.1", STRING),
  SB_OPT("xugusql-ips", "XuguDB Turn ip", "x.x.x.x", STRING),
  SB_OPT("xugusql-port", "XuguDB Port", "5138", INT),
  SB_OPT("xugusql-db", "XuguDB Name", "SYSTEM", STRING),
  SB_OPT("xugusql-uid", "XuguSQL user", "SYSDBA", STRING),
  SB_OPT("xugusql-pwd", "XuguSQL password", "SYSDBA", STRING),
  SB_OPT("xugusql-cursor", "Whether to enable server cursors", "0", STRING),
  SB_OPT("xugusql-auto-commit", "Automatic submission switch, default is auto-commit", "1", INT),

  SB_OPT_END  
};

static drv_caps_t xugusql_drv_caps = {
    1, /* 1 if database supports multi-row inserts */
    1, /* 1 if database supports prepared statements */
    1, /* 1 if database supports AUTO_INCREMENT clause */
    0, /* 1 if database needs explicit commit after INSERTs */
    1, /* 1 if database supports SERIAL clause */
    0  /* 1 if database supports UNSIGNED INTEGER types */
};

/* DB-to-xugusql bind type map */
stu_xugusql_bind_map xugusql_bind_map[] = {
    {DB_TYPE_TINYINT,   SQL_TINYINT,    XG_C_TINYINT},
    {DB_TYPE_SMALLINT,  SQL_SMALLINT,   XG_C_SHORT},
    {DB_TYPE_INT,       SQL_INTEGER,    XG_C_INTEGER},
    {DB_TYPE_BIGINT,    SQL_BIGINT,     XG_C_BIGINT},
    {DB_TYPE_FLOAT,     SQL_FLOAT,      XG_C_FLOAT},
    {DB_TYPE_DOUBLE,    SQL_DOUBLE,     XG_C_DOUBLE},
    {DB_TYPE_DATE,      SQL_DATE,       XG_C_DATE},
    {DB_TYPE_TIME,      SQL_TIME,       XG_C_TIME},
    {DB_TYPE_DATETIME,  SQL_DATETIME,   XG_C_DATETIME},
    {DB_TYPE_TIMESTAMP, SQL_DATETIME,   XG_C_DATETIME},
    {DB_TYPE_CHAR,      SQL_CHAR,       XG_C_CHAR},
    {DB_TYPE_VARCHAR,   SQL_CHAR,       XG_C_CHAR},
    {DB_TYPE_NONE,      0,              0},
};


/* driver operations definition  */
static int xugusql_drv_init(void);
static int xugusql_drv_thread_init(int);
static int xugusql_drv_describe(drv_caps_t *);
static int xugusql_drv_connect(db_conn_t *);
static int xugusql_drv_disconnect(db_conn_t *);
static int xugusql_drv_reconnect(db_conn_t *);
static int xugusql_drv_prepare(db_stmt_t *, const char *, size_t);
static int xugusql_drv_bind_param(db_stmt_t *, db_bind_t *, size_t);
static int xugusql_drv_bind_result(db_stmt_t *, db_bind_t *, size_t);
static int xugusql_drv_fetch(db_result_t *);
static int xugusql_drv_fetch_row(db_result_t *, db_row_t *);
static int xugusql_drv_free_results(db_result_t *);
static int xugusql_drv_close(db_stmt_t *);
static int xugusql_drv_thread_done(int);
static int xugusql_drv_done(void);
static db_error_t xugusql_drv_query(db_conn_t *, const char *, size_t, db_result_t *);
static db_error_t xugusql_drv_execute(db_stmt_t *, db_result_t *);


/* xugusql driver definition */
static db_driver_t xugusql_driver = 
{
    .sname = "xugusql",
    .lname = "xugusql driver",
    .args = xugusql_drv_args,
    .ops = 
    {
        .init = xugusql_drv_init,
        .thread_init = xugusql_drv_thread_init,
        .describe = xugusql_drv_describe,
        .connect = xugusql_drv_connect,
        .disconnect = xugusql_drv_disconnect,
        .reconnect = xugusql_drv_reconnect,
        .prepare = xugusql_drv_prepare,
        .bind_param = xugusql_drv_bind_param,
        .bind_result = xugusql_drv_bind_result,
        .execute = xugusql_drv_execute,
        .fetch = xugusql_drv_fetch,
        .fetch_row = xugusql_drv_fetch_row,
        .free_results = xugusql_drv_free_results,
        .close = xugusql_drv_close,
        .query = xugusql_drv_query,
        .thread_done = xugusql_drv_thread_done,
        .done = xugusql_drv_done
    }
};


/* register xugusql driver */
int register_driver_xugusql(sb_list_t *drivers)
{
    SB_LIST_ADD_TAIL(&xugusql_driver.listitem, drivers);

    return 0;
}


/* context handle initial attribute */
typedef struct {
    int     attr_version;
    int     attr_conn_pool;
    int     attr_time_out;
    int     attr_iso_level;
    int     attr_ssl;
    int     attr_charset;
    int     attr_autocommit;
}stu_init_attr;


/* xugusql driver initialization parameters */
typedef struct {
    int     arg_port_number;
    int     ck;
    char    *arg_ip_address;
    char    *arg_db_name;
    char    *arg_user_id;
    char    *arg_password;
}stu_xugusql_args;


/* context handle */
typedef struct {
    XGCIHANDLE  environment;
    XGCIHANDLE  server;
    XGCIHANDLE  session;
}stu_xugusql_conn;


/* statement struct */
typedef struct {
    XGCIHANDLE  stmt;
    int         use_server_cursor;
    size_t      param_cnt;
}stu_xugusql_stmt;


/* global varable */
static stu_xugusql_args glob_args;
static stu_init_attr    glob_attr;
static int              glob_use_ps = 0;
/* local function */
static stu_xugusql_bind_map get_bind_type(db_bind_type_t type);
static sb_counter_type_t get_query_type(const char *query);


/* initializate driver */
int xugusql_drv_init(void)
{
    char            model[] = "x.x.x.x";
    char           *server_sock_ips, *server_sock_ip;


    if(db_globals.ps_mode != DB_PS_MODE_DISABLE){
        glob_use_ps = 1;
    }

    server_sock_ip = sb_get_value_string("xugusql-ip");
    server_sock_ips = sb_get_value_string("xugusql-ips");
    glob_args.arg_port_number = sb_get_value_int("xugusql-port");
    glob_args.arg_db_name = sb_get_value_string("xugusql-db");
    glob_args.arg_user_id = sb_get_value_string("xugusql-uid");
    glob_args.arg_password = sb_get_value_string("xugusql-pwd");
    glob_attr.attr_autocommit = sb_get_value_int("xugusql-auto-commit");

    if(!strcmp(server_sock_ips, model)){
        glob_args.ck = 0;
        glob_args.arg_ip_address = server_sock_ip;
    }else{
        glob_args.ck = 1;
        glob_args.arg_ip_address = server_sock_ips;
    }

    glob_attr.attr_version = XGCI_ATTR_ENV_VERSION;
    glob_attr.attr_conn_pool = 0;
    glob_attr.attr_time_out = 30;
    glob_attr.attr_iso_level = XGCI_ISO_READCOMMIT;
    glob_attr.attr_ssl = XGCI_USESSL_FALSE;
    glob_attr.attr_charset = XGCI_CHARSET_GBK;

    return 0;
}


/* connect to database */
int xugusql_drv_connect(db_conn_t *sb_conn)
{
    int                  snl, attr_server_sock;
    stu_xugusql_conn    *db_conn;

    db_conn = (stu_xugusql_conn *)calloc(1, sizeof(stu_xugusql_conn));
    if(db_conn == NULL){
        return 1;
    }

    attr_server_sock = XGCI_ATTR_SRV_IP;
    if(glob_args.ck){
        attr_server_sock = XGCI_ATTR_SRV_TURN_IPS;
    }

    snl = XGCIHandleAlloc(NULL, &db_conn->environment, HT_ENV);
    snl = XGCIHandleAttrSet(db_conn->environment, XGCI_ATTR_ENV_VERSION, &glob_attr.attr_version, XGCI_NTS);
    snl = XGCIHandleAttrSet(db_conn->environment, XGCI_ATTR_ENV_USE_POOL, &glob_attr.attr_conn_pool, XGCI_NTS);
    snl = XGCIHandleAlloc(db_conn->environment, &db_conn->server, HT_SERVER);
    snl = XGCIHandleAttrSet(db_conn->server, attr_server_sock, glob_args.arg_ip_address, XGCI_NTS);
    snl = XGCIHandleAttrSet(db_conn->server, XGCI_ATTR_SRV_PORT, &glob_args.arg_port_number, XGCI_NTS);
    snl = XGCIHandleAttrSet(db_conn->server, XGCI_ATTR_SRV_DBNAME, glob_args.arg_db_name, XGCI_NTS);
    snl = XGCIHandleAlloc(db_conn->server, &db_conn->session, HT_SESSION);
    snl = XGCIHandleAttrSet(db_conn->session, XGCI_ATTR_SESS_TIMEOUT, &glob_attr.attr_time_out, XGCI_NTS);
    snl = XGCIHandleAttrSet(db_conn->session, XGCI_ATTR_SESS_ISOLEVEL, &glob_attr.attr_iso_level, XGCI_NTS);
    snl = XGCIHandleAttrSet(db_conn->session, XGCI_ATTR_SESS_SSL, &glob_attr.attr_ssl, XGCI_NTS);
    snl = XGCIHandleAttrSet(db_conn->session, XGCI_ATTR_SESS_CHARSET, &glob_attr.attr_charset, XGCI_NTS);
    snl = XGCIHandleAttrSet(db_conn->session, XGCI_ATTR_SESS_AUTO_COMMIT, &glob_attr.attr_autocommit, XGCI_NTS);
    snl = XGCIHandleAttrSet(db_conn->session, XGCI_ATTR_SESS_TIMEZONE, "GTM+08:00", XGCI_NTS);
    snl = XGCIHandleAttrSet(db_conn->session, XGCI_ATTR_SESS_ENCRYPTOR, NULL, XGCI_NTS);

    snl = XGCISessionBegin(db_conn->session, glob_args.arg_user_id, glob_args.arg_password);
    if(snl != XGCI_SUCCESS && snl != XGCI_SUCCESS_WITH_INFO){
        return 1;
    }

    sb_conn->ptr = (void*)db_conn;

    return 0;
}


/* disconnect from database */
int xugusql_drv_disconnect(db_conn_t *sb_conn)
{
    int                  snl;
    stu_xugusql_conn    *db_conn;

    if(sb_conn->ptr == NULL) {
        return 1;
    }

    db_conn = (stu_xugusql_conn *)sb_conn->ptr;

    snl = XGCISessionEnd(db_conn->session);
    snl = XGCIHandleFree(db_conn->session);
    snl = XGCIHandleFree(db_conn->server);
    snl = XGCIHandleFree(db_conn->environment);

    (void)snl;

    free(db_conn);
    sb_conn->ptr = NULL;

    return 0;
}


/* reconnect with the same parameters */
int xugusql_drv_reconnect(db_conn_t *sb_conn)
{
    int                  snl;
    stu_xugusql_conn    *db_conn;

    if(sb_conn->ptr == NULL) {
        return 1;
    }
    
    db_conn = (stu_xugusql_conn *)sb_conn->ptr;

    snl = XGCISessionBegin(db_conn->session, glob_args.arg_user_id, glob_args.arg_password);
    if(snl != XGCI_SUCCESS && snl != XGCI_SUCCESS_WITH_INFO){
        return 1;
    }

    return 0;
}


/* prepare statement */
int xugusql_drv_prepare(db_stmt_t *stmt, const char *query, size_t len)
{
    int                  snl, i;
    size_t               param_cnt;
    db_conn_t           *sb_conn;
    stu_xugusql_conn    *db_conn;
    stu_xugusql_stmt    *db_stmt;

    (void)len;

    if((sb_conn = stmt->connection) == NULL){
        return 1;
    }

    db_conn = (stu_xugusql_conn *)sb_conn->ptr;
    if(db_conn == NULL) {
        return 1;
    }

    if(query == NULL || strlen(query) == 0) {
        return 1;
    }

    db_stmt = (stu_xugusql_stmt *)calloc(1, sizeof(stu_xugusql_stmt));
    if (db_stmt == NULL){
        return 1;
    }

    for(i = 0, param_cnt = 0; query[i] != '\0'; i++){
        if(query[i] != '?'){
           continue;
        }
        param_cnt++;
    }

    snl = XGCIHandleAlloc(db_conn->session, &db_stmt->stmt, HT_STATEMENT);
    db_stmt->param_cnt = param_cnt;

    if(stmt->query == NULL && (stmt->query = strdup(query)) == NULL){
        return 1;
    }

    if(glob_use_ps) 
    {   
        stmt->counter = get_query_type(query);
        if(SB_CNT_READ == stmt->counter){
            if(sb_get_value_int("xugusql-cursor")){
                db_stmt->use_server_cursor = USE_SERVER_CURSOR;
            }else{
                db_stmt->use_server_cursor = USE_NOT_SERVER_CUR;
            }

            snl = XGCIHandleAttrSet(db_stmt->stmt, 
                XGCI_ATTR_STMT_PREPARE_WITH_SERVER_CURSOR, 
                    &db_stmt->use_server_cursor, XGCI_NTS);
        }

        if(SB_CNT_OTHER == stmt->counter){
            goto next;
        }

        snl = XGCIPrepare(db_stmt->stmt, stmt->query, XGCI_NTS);
        if(snl != XGCI_SUCCESS && snl != XGCI_SUCCESS_WITH_INFO){
            return 1;
        }
    }
next:
    stmt->ptr = (void*)db_stmt;

    return 0;
}


/* execute non-prepared statement */
db_error_t xugusql_drv_query(db_conn_t *sb_conn, 
                const char *query, size_t len, db_result_t *rs)
{
    int                  snl;
    XGCIHANDLE           statement;
    stu_xugusql_conn    *db_conn;

    (void)len;

    if((db_conn = (stu_xugusql_conn *)sb_conn->ptr) == NULL){
        return DB_ERROR_FATAL;
    }

    rs->counter = get_query_type(query);

    snl = XGCIHandleAlloc(db_conn->session, &statement, HT_STATEMENT);
    snl = XGCIExecDirect(statement, (char*)query, XGCI_NTS);
    if(snl != XGCI_SUCCESS && snl != XGCI_SUCCESS_WITH_INFO){
        rs->counter = SB_CNT_ERROR;
    }

    snl = XGCIHandleFree(statement);

    return DB_ERROR_NONE;
}


/* bind params for prepared statement */
int xugusql_drv_bind_param(db_stmt_t *stmt, db_bind_t *params, size_t len)
{
    int                    snl;
    int                    rcode;
    unsigned int           i;
    stu_xugusql_stmt      *db_stmt;
    stu_xugusql_bind_map   bind_map;

    if((db_stmt = (stu_xugusql_stmt *)stmt->ptr) == NULL){
        return 1;
    }

    if(db_stmt->param_cnt != len){
       log_text(LOG_ALERT, " Wrong number of parameters in prepared statement ");
       log_text(LOG_DEBUG, " Counted: %lu, passed to bind_param(): %lu",db_stmt->param_cnt, len);
       return 1;
    }

    for(i = 0; i != len; i++){
        bind_map = get_bind_type(params[i].type);
        if(bind_map.map_db_type == DB_TYPE_NONE){
            return 1;
        }

        snl = XGCIBindParamByPos(db_stmt->stmt, i+1, PARAM_IN, params[i].buffer, params[i].max_len,
            bind_map.map_c_type, &rcode, (int32*)params[i].data_len, bind_map.map_sql_type);
        if(snl != XGCI_SUCCESS && snl != XGCI_SUCCESS_WITH_INFO){
            return 1;
        }
    }

    return 0;
}


/* execute prepared statement */
db_error_t xugusql_drv_execute(db_stmt_t *stmt, db_result_t *rs)
{
    int                    snl;
    unsigned int           rcode;
    stu_xugusql_stmt      *db_stmt;
    db_row_t              *row;

    if((db_stmt = (stu_xugusql_stmt *)stmt->ptr)  == NULL){
        return DB_ERROR_FATAL;
    }

    if(stmt->query == NULL){
        return DB_ERROR_FATAL;
    }

    if(SB_CNT_OTHER == stmt->counter){
        snl = XGCIExecDirect(db_stmt->stmt, stmt->query, XGCI_NTS);
    }else{
        snl = XGCIExecute(db_stmt->stmt);
    }

    if (snl != XGCI_SUCCESS && snl != XGCI_SUCCESS_WITH_INFO){
        rs->counter = SB_CNT_ERROR;
        return DB_ERROR_NONE;
    }

    if(glob_use_ps){
        rs->counter = stmt->counter;
    } else {
        rs->counter = get_query_type(stmt->query);
    }
    
    row = &(rs->row);
    if(rs->counter == SB_CNT_READ && row->values == NULL){
        snl = XGCIAttrGet(db_stmt->stmt, HT_STATEMENT, &rs->nfields, &rcode, XGCI_ATTR_COL_COUNT);
        snl = XGCIAttrGet(db_stmt->stmt, HT_STATEMENT, &rs->nrows, &rcode, XGCI_ATTR_COL_COUNT);
    }

    return DB_ERROR_NONE;
}


/* close prepared statement */
int xugusql_drv_close(db_stmt_t *stmt)
{
    int                    snl;
    stu_xugusql_stmt      *db_stmt;

    if(stmt == NULL || (db_stmt = (stu_xugusql_stmt *)stmt->ptr)  == NULL){
        return 1;
    }

    if(db_stmt->stmt){
        snl = XGCIHandleFree(db_stmt->stmt);
        db_stmt->stmt = NULL;
    }

    free(db_stmt);
    stmt->ptr = NULL;

    (void)snl;

    return 0;
}


/* thread-local driver initialization */
int xugusql_drv_thread_init(int tls_id)
{
    (void)tls_id;

    return 0;
}


/* bind results for prepared statement */
int xugusql_drv_bind_result(db_stmt_t *stmt, db_bind_t *params, size_t len)
{
    (void)stmt;
    (void)params;
    (void)len;

    return 0;
}


/* free result set */
int xugusql_drv_free_results(db_result_t *rs)
{
    uint32_t               i;

    if(rs->row.ptr != NULL){
        free(rs->row.ptr);
        rs->row.ptr = NULL;
    }

    if(rs->row.values == NULL){
        return 1;
    }

    for(i = 0; i != rs->nfields; i++){
        if(rs->row.values[i].ptr != NULL){
            free((void*)rs->row.values[i].ptr);
        }
    }

    return 0;
}


/* fetch row for prepared statement */
int xugusql_drv_fetch(db_result_t *rs){
    int                    snl;
    stu_xugusql_stmt      *db_stmt;
    
    if(rs->statement == NULL){
        return 1;
    } 

    db_stmt = (stu_xugusql_stmt *)rs->statement->ptr;
    if(db_stmt == NULL){
        return 1;
    }

    snl = XGCIFetch(db_stmt->stmt);
 
    (void)snl;

    return 0;
}


/* fetch row for queries */
int xugusql_drv_fetch_row(db_result_t *rs, db_row_t *row)
{
    int                    snl, rc, acl;
    uint32_t               i;
    unsigned int           rcode;
    void                  *tmp;
    int                   *ctype;
    db_stmt_t             *stmt;
    stu_xugusql_stmt      *db_stmt;

    if((stmt = rs->statement) == NULL){
        return 1;
    }

    if((db_stmt = (stu_xugusql_stmt *)stmt->ptr) == NULL){
        return 1;
    }

    if(rs->nrows == 0 || rs->nfields == 0){
        return 1;
    } 

    if(row->ptr == NULL)
    {
        row->ptr = calloc(rs->nfields, sizeof(int));
        if(row->ptr == NULL)
            return 1;
    }
    
    db_value_t  *pval = row->values;

    for(i = 0; i != rs->nfields; i++){
        snl = XGCIParamGet(db_stmt->stmt, HT_STATEMENT, &tmp, i+1);
        snl = XGCIAttrGet((XGCIHANDLE)tmp, XGCI_DTYPE_PARAM, 
                (void *)((int *)row->ptr+i), &rcode, XGCI_ATTR_DATA_TYPE);
        snl = XGCIAttrGet((XGCIHANDLE)tmp, XGCI_DTYPE_PARAM, 
                &(pval[i].len), &rcode, XGCI_ATTR_DATA_SIZE);

        if(pval[i].ptr == NULL)
        {
            pval[i].ptr = calloc(1, pval[i].len + 1);
            if(pval[i].ptr == NULL)
                return 1;
        }else{
            bzero(pval[i].ptr, pval[i].len);
        }
    }

    ctype = (int *)row->ptr;
    for(i = 0; i != rs->nfields; i++){
        snl = XGCIDefineByPos(db_stmt->stmt, i+1, (void *)pval[i].ptr, 
            pval[i].len+1, ctype[i], &rc, &acl);
    }

    snl = XGCIFetch(db_stmt->stmt);
    

    (void)snl;

    return 0;
}


/* thread-local driver deinitialization */
int xugusql_drv_thread_done(int tls_id)
{

    (void)tls_id; /* no use */

    return 0;
}


/* uninitialize driver */
int xugusql_drv_done(void)
{
    return 0;
}


/* describe database capabilities */
int xugusql_drv_describe(drv_caps_t *caps)
{
    *caps = xugusql_drv_caps;

    return 0;
}


/* get query type */
sb_counter_type_t get_query_type(const char *query)
{
    while (isspace(*query)){
        query++;
    }

    if (!strncasecmp(query, "select", 6)){
        return SB_CNT_READ;
    }

    if (!strncasecmp(query, "insert", 6) ||
        !strncasecmp(query, "update", 6) ||
        !strncasecmp(query, "delete", 6)){
        return SB_CNT_WRITE;
    }

    return SB_CNT_OTHER;
}


/* get bind type map */
stu_xugusql_bind_map get_bind_type(db_bind_type_t type)
{
    unsigned int           i;

    for(i = 0; xugusql_bind_map[i].map_db_type != DB_TYPE_NONE; i++){
        if(xugusql_bind_map[i].map_db_type != type){
            continue;
        }
        
        return xugusql_bind_map[i];
    }

    return xugusql_bind_map[i];
}
