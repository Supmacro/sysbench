sysbench /usr/local/share/sysbench/oltp_read_write.lua \
         --xugusql-ips=192.168.30.222,192.168.30.223,192.168.30.224,192.168.30.225,192.168.30.226,192.168.30.227 \
         --xugusql-port=12345 \
         --xugusql-db=d1 \
         --xugusql-uid=u1 \
         --xugusql-pwd=testtest \
         --xugusql-cursor=0 \
         --xugusql-auto-commit=0 \
         --threads=1000 \
         --report-interval=10 \
         --time=300 $1

