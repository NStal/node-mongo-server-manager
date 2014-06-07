EventEmitter = require("events").EventEmitter
mongodb = require "mongodb"
MongoClient = mongodb.MongoClient
fs = require "fs"
async = require "async"
child_process = require "child_process"
exports.createInstance = (config = {})->
    logPath = config.logPath
    dbPath = config.dbPath
    pidPath = config.pidPath
    port = config.port or 27017
    host = config.host or "localhost"
    binPath = config.binPath or "mongod"
    stdout = config.stdour or null
    stderr = config.stderr or null
    if not dbPath
        console.error "need dbPath"
        return null
    if not logPath
        console.error "need logPath"
        return null
    if not pidPath
        console.error "need pidPath"
        return null
    return new MongoDbInstance({
        logPath:logPath
        ,pidPath:pidPath
        ,dbPath:dbPath
        ,port:port
        ,host:host
        ,binPath:binPath
        ,stdout
        ,stderr})
    

class MongoDbInstance extends EventEmitter
    constructor:(@config)->

    isOnline:(callback)->
        MongoClient.connect "mongodb://#{@config.host}:#{@config.port}/test",(err,db)=>
            if err
                callback null,false
                return
            callback null,true
    # Note: checking daemon up will also kill invalid pid file
    isDaemonUp:(callback)->
        fs.exists @config.pidPath,(hasPidFile)=>
            if not hasPidFile
                callback null,false
                return
            fs.readFile @config.pidPath,(err,buffer)=>
                if err
                    callback err,false
                    return
                pid = parseInt buffer.toString()
                # NaN or 0 both invalid
                if pid
                    notExists = false
                    try
                        process.kill pid,0
                    catch e
                        notExists = true
                else
                    notExists = true
                if notExists
                    fs.unlink @config.pidPath,()=>
                        callback null,false
                else
                    callback null,pid
    isPortAvaiable:(callback)->
        scanner = require "portscanner"
        scanner.checkPortStatus @config.port,@config.host,(err,status)->
            if err
                callback err
                return
            if status is "open"
                callback null,false
            else
                callback null,true
    stop:(callback)->
        @isDaemonUp (err,pid)->
            if err
                callback err
                return
            if not pid
                callback null,"already stopped"
                return
            died = false
            test = ()=>
                return not died
            kill = (done)=>
                try
                    process.kill pid
                catch e
                    died = true
                setTimeout done,100
            async.whilst test,kill,(err)=>
                callback err
    start:(callback)->
        binPath = @config.binPath
        port = @config.port
        host = @config.host
        logPath = require("path").resolve @config.logPath
        dbPath = require("path").resolve @config.dbPath
        pidPath = require("path").resolve @config.pidPath
        args = [
            "--dbpath",dbPath
            ,"--port",port
            ,"--bind_ip",host
            ,"--logpath",logPath
            ,"--pidfilepath",pidPath
            ,"--fork"
        ]
        cp = child_process.spawn binPath,args,{cwd:@config.cwd or null}
        cp.on "error",(error)=>
            callback err
            callback = ()->
        cp.on "exit",(code)=>
            if code is 0
                callback()
                return
            callback {code:code}
            callback = ()->
            return
        if @config.stdout
            cp.stdout.pipe @config.stdout
        if @config.stderr
            cp.stderr.pipe @config.stderr

