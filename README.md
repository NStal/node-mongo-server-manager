# Install
```bash
npm install mongo-server-manager
```
# Test
require coffee-script and mocha to be installed.

```bash
npm test
```
# Usage

I use this module to manage a mongod instance for a desktop application as an embeded database.

```coffee-script
# all option is critical
# though port and host will fallback to 27017 and localhost
# if not provided.
service = manager.createInstance {
    logPath:"./test/db/log"
    ,pidPath:"./test/db/mongod.pid"
    ,dbPath:"./test/db"
    ,port:12345
    ,host:"localhost"
    ,binPath:"mongod"
}
service.isDaemonUp (err,pid)->
    # if daemonis up return pid
    # or pid is false
    if not pid
        service.start (err)->
	    # shouldn't has err
            service.isOnline (err,online)->
	        # online should be true 
		service.stop (err)->
		    process.exit()
```

Difference between isDaemonUp and isOnline is that isDaemonUp will only check the pid file and corresponding process is running, wile isOnline will only try to connection to the host and port and make sure it's a mongodb service.

