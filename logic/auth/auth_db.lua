local db_mgr = require "common.db_mgr"
local skynet = require "skynet"
local utils = require "utils"
local json = require "json"  
local auth_db = {}

local IncrPlayerIdKey = "incr_player_id"
local AuthInfoKey = "auth_info"
local function get_auth_info_key()
	return AuthInfoKey
end

function auth_db.incr_player_id(id)
	local redisdb = db_mgr.get_redis_db()
	local player_id = tonumber(redisdb:incr(IncrPlayerIdKey))
	return player_id
end

function auth_db.get_normal_account(id, account)
	local mysqldb = db_mgr.get_mysql_db()
	local result = mysqldb:query(string.format("select * from tb_normal_account where account = '%s'", account))
	if result.err then
		error(result.err)
	end
	return result[1]
end

function auth_db.create_normal_account(id, account_info)
	local mysqldb = db_mgr.get_mysql_db()
	local sql = string.format("insert into tb_normal_account(player_id, telephone, account, password, create_time) values(%d, '%s', '%s', '%s', %d);",
		account_info.player_id, account_info.telephone, account_info.account, account_info.password, account_info.create_time)
	local result = mysqldb:query(sql)
	if result.err then
		error(result.err)
	end
	return
end

function auth_db.create_player(id, player_info)
	local mysqldb = db_mgr.get_mysql_db()
	local sql = string.format("insert into tb_player(player_id, head_id, head_url, nickname, sex, gold, create_time) values(%d, %d, '%s', '%s', %d, %d, %d);",
		player_info.player_id, player_info.head_id, player_info.head_url, player_info.nickname, player_info.sex, player_info.gold, player_info.create_time)
	local result = mysqldb:query(sql)
	if result.err then
		error(result.err)
	end
	return
end

function auth_db.get_player(id)
	local mysqldb = db_mgr.get_mysql_db()
	local sql = string.format("select * from tb_player where player_id = %d;", id)
	local result = mysqldb:query(sql)
	if result.err then
		error(result.err)
	end
	return result[1]
end

function auth_db.get_visitor_account(id, token)
	local mysqldb = db_mgr.get_mysql_db()
	local sql = string.format("select * from tb_visitor_account where visit_token = '%s';", token)
	local result = mysqldb:query(sql)
	if result.err then
		error(result.err)
	end
	return result[1]
end

function auth_db.create_visitor_account(id, visitor_info)
	local mysqldb = db_mgr.get_mysql_db()
	local sql = string.format("insert into tb_visitor_account(player_id, visit_token, create_time) values(%d, '%s', %d)", 
		visitor_info.player_id, visitor_info.visit_token, visitor_info.create_time)
	local result = mysqldb:query(sql)
	if result.err then
		error(result.err)
	end
end

function auth_db.get_weixin_account(id,  union_id)
	local mysqldb = db_mgr.get_mysql_db()
	local sql = string.format("select * from tb_weixin_account where union_id = '%s';", union_id)
	 local result = mysqldb:query(sql)
	if result.err then
		error(result.err)
	end
	return result[1]
end

function auth_db.create_weixin_account(id, weixin_info)
	local mysqldb = db_mgr.get_mysql_db()
	local sql = string.format("insert into tb_weixin_account(player_id, union_id, create_time) values(%d, '%s', %d)", 
		weixin_info.player_id, weixin_info.union_id, weixin_info.create_time)
	local result = mysqldb:query(sql)
	if result.err then
		error(result.err)
	end
end
--------------------------------------- auth info
function auth_db.set_auth_info(userinfo, auth_info)
	local field = userinfo.user
	local redisdb = db_mgr.get_redis_db()
	redisdb:hset(get_auth_info_key(), field, json.encode(auth_info))
end

function auth_db.get_auth_info(userinfo)
	local field = userinfo.user
	local redisdb = db_mgr.get_redis_db()
	local data = redisdb:hget(get_auth_info_key(), field)
	local auth_info = json.decode(data)
	if auth_info then
		auth_info.login_addr = tonumber(auth_info.login_addr)
		auth_info.subid = tonumber(auth_info.subid)
		auth_info.waitsecond = tonumber(auth_info.waitsecond)
		auth_info.secret = auth_info.secret
	end
	return auth_info
end

--function auth_db.get_auth_num()

return auth_db