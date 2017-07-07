DEFINE QLOCAL('TEST.LOCAL.QUEUE') +
        DEFPSIST(YES) +
        MSGDLVSQ(FIFO) +
        MAXMSGL(104857600) +
        MAXDEPTH(10) +
        DESCR('Testing queues') +
        QDPHIEV(ENABLED) +
        NOREPLACE
