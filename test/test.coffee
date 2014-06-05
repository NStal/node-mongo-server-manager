manager = require "../lib/mongoServerManager"
service = manager.createInstance {
    logPath:"./test/db/log"
    ,pidPath:"./test/db/mongod.pid"
    ,dbPath:"./test/db"
    ,port:12345
    ,host:"localhost"
    ,binPath:"mongod"
}

describe "test mongodb instance manager",()->
    it "check daemon up",(done)->
        service.isDaemonUp (err,up)->
            console.log err,up
            console.assert not up
            done()
    it "start service",(done)->
        console.log "start mongodb with a new db path may take a long time."
        console.log "wait patiently."
        service.start (err)->
            if err
                console.error err
                throw err 
            done()
    it "ensure daemon up",(done)->
        service.isDaemonUp (err,up)->
            console.assert !!up
            done()
    it "ensure daemon interactable",(done)->
        service.isOnline (err,online)->
            console.assert not err
            console.assert online
            done()
    it "stop service",(done)->
        service.stop (err)->
            if err
                throw err
            done()
    it "ensure daemon down",(done)->
        service.isDaemonUp (err,up)->
            console.assert not up
            done()
