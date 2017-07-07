$! Simple DCL script to build SAVEQMGR.EXE on VMS
$!
$ SvVerify = F$Verify(1)
$ define mqs_include sys$share:[mqs_include]
$ CFlags = "/decc /warnings=(enable=all, " + -
                "disable=(misalgndstrct, switchlong, ignorecallval), noinform) " + -
                "/include_directory=mqs_include:"
$ CC 'CFlags' SaveQmgr
$ CC 'CFlags' Channel
$ CC 'CFlags' MqUtils
$ CC 'CFlags' Process
$ CC 'CFlags' NameList
$ CC 'CFlags' AuthInfo
$ CC 'CFlags' Qmgr
$ CC 'CFlags' Queue
$ CC 'CFlags' Archive
$ CC 'CFlags' cfstruct
$ CC 'CFlags' listener
$ CC 'CFlags' log
$ CC 'CFlags' system
$ CC 'CFlags' usage
$ CC 'CFlags' oam
$ CC 'CFlags' services
$ CC 'CFlags' stgclass
$ CC 'CFlags' args
$!
$ Open/Write Tmp saveqmgr.opt
$ Write Tmp "sys$share:mqm/share"
$ Close Tmp
$!
$ Link /Trace /Nomap /Executable=SaveQmgr.exe SaveQmgr.Obj, -
        Channel.Obj, MqUtils.Obj, Process.Obj, NameList.Obj,-
        Qmgr.Obj,services.obj,stgclass.obj,Queue.Obj,-
        AuthInfo.Obj, Archive.Obj, cfstruct.obj, listener.obj,-
        log.obj,system.obj,usage.obj,oam.obj,args.obj, SaveQmgr/Options
$!
$ If .Not. SvVerify Then $ Set Noverify
$ Exit
