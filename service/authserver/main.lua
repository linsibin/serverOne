local skynet = require "skynet"
local cluster_monitor = require "cluster_monitor"
local sproto_helper = require "sproto_helper"
local redis_config = require "config.redis_config"
local cluster_config = require "config.cluster_config"
local watchdog_port = skynet.getenv("watchdog_port")

skynet.start(function()
  	local cluster_reids_id = tonumber(skynet.getenv("cluster_redis_id"))
	local cluster_server_id = tonumber(skynet.getenv("cluster_server_id"))
	
	cluster_monitor.start(redis_config[cluster_reids_id], cluster_config[cluster_server_id])

	sproto_helper.register_protos()

	local watchdog = skynet.newservice("watchdog")
	skynet.call(watchdog, "lua", "start", {
		port = watchdog_port, 
		maxclient = max_client,
		nodelay = true,
    })
    
    skynet.uniqueservice("auth")

	cluster_monitor.open()
 	skynet.error("******************** authserver start ok ********************")

end)