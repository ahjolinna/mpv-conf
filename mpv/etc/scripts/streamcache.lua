-- streamcache.lua

-- Configurable parameters:
--
-- speed will slowly be decreased towards streamcache_min_speed
--  as long as there is less data cached than required to bridge
--  "streamcache_cache_seconds_low" seconds of stalled transmission.
--
-- speed will slowly be increased towards 1.0 while there is more data
--  cached than required to bridge "streamcache_cache_seconds_high"
--  seconds of stalled transmission.
--
-- To keep replay speed adjustments below your attention threshold,
--  the replay speed factor will never be set below "streamcache_min_speed",
--  and this script will not change this factor by more than a factor of 
--  "streamcache_adjust_factor" per second.

streamcache_cache_seconds_low  = 20
streamcache_cache_seconds_high = 30
streamcache_min_speed = 0.98
streamcache_adjust_factor = 1.0005

streamcache_verbose = false

-- Changing replay speed by < 2% seems to cause less
--  distortion when not correcting audio pitch (via the scaletempo filter).
-- But you can try setting this to "yes" if you like - 
--  might be useful if you want to toy around with very low min_speed values.
mp.set_property("options/audio-pitch-correction", "no")

-- Notice that using this script with non-live streams, like podcasts,
--  does usually not improve buffering, as the server will usually 
--  send pre-buffering data individually to clients, anyway. But you can
--  still use this script for podcasts where the server sends less than
--  your desired amount of pre-buffering data.

-- Anything below this line is not meant for configuration.

streamcache_cache_low  = 500
streamcache_cache_high = 750

function streamcache_log(level, msg)
	if (streamcache_verbose) then
		mp.msg.log(level, msg)
	end
end

function streamcache_compute_cache_sizes()
	local vb = mp.get_property_native("video-bitrate")
	if (vb == nil) then
		vb = 0
	end
	
	local ab = mp.get_property_native("audio-bitrate")
	if (ab == nil) then
		ab = 0
	end
	
	local br = vb + ab
	if (br == 0) then
		-- when we do not have plausible information on the bitrate, we
		-- first make some midly pessimistic guess of 2 MBit/s
		br = 2000000
	end

	-- compute the cache size required per second in kb
	local kb_per_sec = br / (8 * 1024)	

	streamcache_log("info", "ab=" .. ab .. " vb=" .. vb .. " br=" .. br .. " kb_per_sec=" .. kb_per_sec)
	
	streamcache_cache_low  = streamcache_cache_seconds_low * kb_per_sec
	streamcache_cache_high = streamcache_cache_seconds_high * kb_per_sec
	
	if (streamcache_verbose or ab > 0 or vb > 0) then
		mp.msg.log("info", "assuming bitrate=" .. br/1024 .. "kbit/s, thresholds: cache_low=" .. streamcache_cache_low .. "kb cache_high=" .. streamcache_cache_high .. "kb")
	end
	
	if (ab > 0 or vb > 0) then
		-- possibly increase cache-size property only if at least some
		-- information on audio or video bitrate exists
		
		local new_cache_size = streamcache_cache_high * 2
		local cs = mp.get_property_native("cache-size")
		if (cs == nil) then
			cs = 0
		end
		if (new_cache_size > cs) then
			-- we do not shrink the cache, only expand it when necessary
			streamcache_log("info", "increased the cache-size to " .. new_cache_size .. "kb")
			mp.set_property("cache-size", new_cache_size)
		end
	end
end
mp.observe_property("audio-bitrate", "native", streamcache_compute_cache_sizes)
mp.observe_property("video-bitrate", "native", streamcache_compute_cache_sizes)

function streamcache_check_fill()
	local cache_used = mp.get_property_native("cache-used")
	if cache_used == nil then
 		cache_used = 0
	end
	
	local current_speed = mp.get_property_native("speed")
	if current_speed == nil then
 		current_speed = streamcache_min_speed
	end
	
	if (cache_used < streamcache_cache_low) then
		-- not enough in cache - so slowly deccelerate
		local new_speed = current_speed * 0.9995
		if (new_speed < streamcache_min_speed) then
			new_speed = streamcache_min_speed
		end
		streamcache_log("info", "cache_used=" .. cache_used .. " (< low), new_speed=" .. new_speed)
		mp.set_property("speed", new_speed)	
		return
	end
	
	if (cache_used > streamcache_cache_high) then
		if (current_speed >= 1.0) then
			-- all fine, nothing to do
			streamcache_log("info", "cache_used=" .. cache_used .. " (> high) current_speed >= 1.0 - do nothing")	
			return
		end
		
		-- current speed is < 1.0, but there's really enough in the cache, so slowly accelerate
		local new_speed = current_speed * 1.0005
		if (1.0 - new_speed < 0.0001) then
			new_speed = 1.0
		end
		streamcache_log("info", "cache_used=" .. cache_used .. " (> high), new_speed=" .. new_speed)
		mp.set_property("speed", new_speed)	
		return
	end
	
	-- cache_used is between low and high - don't change speed
	streamcache_log("info", "cache_used=" .. cache_used .. " (> low < high) no speed change")	
end

streamcache_timer = mp.add_periodic_timer(1.0, streamcache_check_fill)


function streamcache_on_loaded()
	mp.set_property("speed", streamcache_min_speed)
	streamcache_compute_cache_sizes()	
end

mp.register_event("file-loaded", streamcache_on_loaded)

