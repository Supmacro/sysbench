# sysbench

sysbench is a scriptable multi-threaded benchmark tool based on
LuaJIT. It is most frequently used for database benchmarks, but can also
be used to create arbitrarily complex workloads that do not involve a
database server. Here is just a copy of the source code, a derivative 
of sysbench, which adds drivers for the XUGU database. See 
[akopytov/sysbench](https://github.com/akopytov/sysbench) 
for the original version of sysbench

sysbench comes with the following bundled benchmarks:

- `oltp_*.lua`: a collection of OLTP-like database benchmarks
- `fileio`: a filesystem-level benchmark
- `cpu`: a simple CPU benchmark
- `memory`: a memory access benchmark
- `threads`: a thread-based scheduler benchmark
- `mutex`: a POSIX mutex benchmark

## Features

- extensive statistics about rate and latency is available, including
  latency percentiles and histograms;
- low overhead even with thousands of concurrent threads. sysbench is
  capable of generating and tracking hundreds of millions of events per
  second;
- new benchmarks can be easily created by implementing pre-defined hooks
  in user-provided Lua scripts;
- can be used as a general-purpose Lua interpreter as well, simply
  replace `#!/usr/bin/lua` with `#!/usr/bin/sysbench` in your script.


## Build and Install
``` shell
    ./autogen.sh
    # Add --with-xugusql to build with XuguSQL support
    # 
    ./configure [options...]
    # [example]Join xugu driver support:
    # ./configure --prefix=/opt/sysbench --without-mysql --with-xugusql --with-xugusql-libs=/usr/lib64 
    #             --with-xugusql-includes=/usr/include
    make 
    make install
```

## Running Syntax
``` shell
    # xuguSQL
    sysbench /opt/sysbench/share/sysbench/oltp_write_only.lua
    --xugusql-ip=127.0.0.1 --xugusql-port=5138 --xugusql-db=SYSTEM --xugusql-uid=SYSDBA --xugusql-pwd=SYSDBA 
    --xugusql-cursor=0 --xugusql-auto-commit=1 --threads=8 --tables=1 --table-size=10000000 --report-interval=10 --time=100
```


