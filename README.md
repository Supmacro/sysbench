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
    # you must either specify file locations explicitly using
    # --with-xugusql-includes and --with-xugusql-libs options
    # 
    ./configure
    make 
    make install
```

## Running Syntax
``` shell
    # xuguSQL
    sysbench /opt/sysbench/share/sysbench/oltp_write_only.lua
    --xugusql-ip=127.0.0.1 --xugusql-port=5138 --xugusql-db=SYSTEM
    --xugusql-uid=SYSDBA --xugusql-pwd=SYSDBA
    --threads=8 --xugusql-cursor=0 --tables=1 --table-size=10000000
    --report-interval=10 --time=100
```


## General Command Line Options

The table below lists the supported common options, their descriptions and default values:

*Option*              | *Description* | *Default value*
----------------------|---------------|----------------
| `--threads`           | The total number of worker threads to create                                                                                                                                                                                                                                                                                                                                                                                                                            | 1               |
| `--events`            | Limit for total number of requests. 0 (the default) means no limit                                                                                                                                                                                                                                                                                                                                                                                                      | 0               |
| `--time`              | Limit for total execution time in seconds. 0 means no limit                                                                                                                                                                                                                                                                                                                                                                                                             | 10              |
| `--rate`              | Average transactions rate. The number specifies how many events (transactions) per seconds should be executed by all threads on average. 0 (default) means unlimited rate, i.e. events are executed as fast as possible                                                                                                                                                                                                                                                                 | 0               |
| `--thread-stack-size` | Size of stack for each thread                                                                                                                                                                                                                                                                                                                                                                                                                                           | 32K             |
| `--report-interval`   | Periodically report intermediate statistics with a specified interval in seconds. Note that statistics produced by this option is per-interval rather than cumulative. 0 disables intermediate reports                                                                                                                                                                                                                                                                  | 0               |
| `--debug`             | Print more debug info                                                                                                                                                                                                                                                                                                                                                                                                                                                   | off             |
| `--validate`          | Perform validation of test results where possible                                                                                                                                                                                                                                                                                                                                                                                                                       | off             |
| `--help`              | Print help on general syntax or on a test mode specified with --test, and exit                                                                                                                                                                                                                                                                                                                                                                                          | off             |
| `--verbosity`         | Verbosity level (0 - only critical messages, 5 - debug)                                                                                                                                                                                                                                                                                                                                                                                                                 | 4               |
| `--percentile`        | sysbench measures execution times for all processed requests to display statistical information like minimal, average and maximum execution time. For most benchmarks it is also useful to know a request execution time value matching some percentile (e.g. 95% percentile means we should drop 5% of the most long requests and choose the maximal value from the remaining ones). This option allows to specify a percentile rank of query execution times to count | 95              |

Note that numerical values for all *size* options (like `--thread-stack-size` in this table) may be specified by appending the corresponding multiplicative suffix (K for kilobytes, M for megabytes, G for gigabytes and T for terabytes).

