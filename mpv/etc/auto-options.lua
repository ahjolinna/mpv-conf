-- Set options dynamically.
-- The script aborts without doing anything when you specified a `--vo` option
-- from command line. You can also use `--script-opts=ao-level=<level>`
-- to force a specific level from command line.
--
-- Upon start, `determine_level()` will select a level (o.uq/o.hq/o.mq/o.lq)
-- whose options will then be applied.
--
-- General mpv options can be defined in the `options` table while VO
-- sub-options are to be defined in `vo_opts`.
--
-- To adapt it for personal use one probably has to reimplement a few things.
-- Out of the used functions `determine_level()` is the most important one
-- requiring adjustments since it's pretty OS as well as user specific and
-- serves as an essential component. Other functions provide various, minor
-- supporting functionality, e.g. for use in option-specific sub-decisions.


-- Don't do anything when mpv was called with an explicitly passed --vo option

if mp.get_property_bool("option-info/vo/set-from-commandline") then
    return
end
local f = require 'auto-options-functions'
local opts = require 'mp.options'
local utils = require 'mp.utils'

-- Specify a VO for each level

local o = {
    hq = "high-quality",
    mq = "medium-quality",
    svp = "SmoothVideo",
    cuda = "NVDEC",
    lq = "low-quality",
    highres_threshold = "1920x1080@60.00hz",
    force_low_res = false,
    verbose = true,
    duration = 2,
    duration_err_mult = 2,
    
}
opts.read_options(o)


-- Specify mpv options for each level

local options = {
    [o.hq] = {
        ["vo"] = "opengl",
        ["scale"]  = "ewa_lanczossharp",
        ["cscale"] = "ewa_lanczossoft",
        ["dscale"] = "mitchell",
        ["tscale"] = "triangle",
        ["scale-antiring"] = "0.8",
        ["cscale-antiring"] = "0.9",
        ["scale-radius"]    = "3",
        ["interpolation"]     =  "yes",
        ["interpolation-threshold"] = "0.0001",        
        ["dither-depth"]        = "auto",
        ["scaler-resizes-only"] = "yes",
        ["sigmoid-upscaling"]   = "yes",
        ["correct-downscaling"] = "yes",
        ["opengl-waitvsync"]           = "yes",
        ["target-prim"]         = "bt.709",
        ["3dlut-size"]          = "256x256x256",
        ["blend-subtitles"]     = "video",
        ["icc-contrast"]            = "2000",
        ["icc-profile"]               = "/usr/share/color/icc/BT.709_Profiles/BT.709.icc",        
        ["hwdec"] = "auto",
        ["video-sync"] = "display-resample",
        ["vd-lavc-threads"] = "16",
        --["vf-add"] = "vdpaupp=sharpen=0.10:denoise=0.10:deint=yes:deint-mode=temporal-spatial:pullup:hqscaling=1",
    },

    [o.cuda] = {  
        ["vo"] = "opengl",
        ["scale"]  = "ewa_lanczossharp",
        ["cscale"] = "ewa_lanczossoft",
        ["dscale"] = "mitchell",
        ["tscale"] = "triangle",
        ["scale-antiring"]  = "0.8",
        ["cscale-antiring"] = "0.9",        
        ["interpolation"]     = "yes",
        ["interpolation-threshold"] = "0.0001",        
        ["dither-depth"]        = "auto",
        ["target-prim"]         = "bt.709",
        ["correct-downscaling"] = "yes",
        ["opengl-waitvsync"]           = "yes",
        ["vd-lavc-o=deint"] = "adaptive",        
        ["3dlut-size"]          = "256x256x256",
        ["blend-subtitles"]     = "video",                
        ["hwdec"] = "cuda",
        ["video-sync"] = "display-resample",

    },
    
  [o.svp] = {  
        ["vo"] = "opengl",
        ["scale"]  = "ewa_lanczossharp",
        ["cscale"] = "ewa_lanczossoft",
        ["dscale"] = "mitchell",
        ["tscale"] = "triangle",
        ["scale-antiring"]  = "0.8",
        ["cscale-antiring"] = "0.9",        
        ["dither-depth"]        = "auto",
        ["target-prim"]         = "bt.709",
        ["correct-downscaling"] = "yes",
        ["input-ipc-server"]  =   "/tmp/mpvpipe",        
        ["hwdec"] = "no",
        ["video-sync"] =  "display-resample",
    },
    
    [o.mq] = {
        ["vo"] = "opengl",
        ["scale"]  = "spline36",
        ["cscale"] = "spline36",
        ["dscale"] = "mitchell",
        ["tscale"] = "triangle",
        ["scale-antiring"]  = "0.8",
        ["cscale-antiring"] = "0.9",
        ["scale-radius"]    = "3",
        ["dither-depth"]        = "auto",
        ["scaler-resizes-only"] = "yes",
        ["sigmoid-upscaling"]   = "yes",
        ["blend-subtitles"]     = "yes",
        ["interpolation"]     =   "no",
        ["interpolation-threshold"] = "0.0001",
        ["correct-downscaling"] = "yes",
        ["deband"]            = "yes",
        ["opengl-waitvsync"]           = "yes",
        ["target-prim"]         = "bt.709",
        ["3dlut-size"]        = "256x256x256",
        ["blend-subtitles"]     = "yes",
        ["icc-contrast"]            = "2000",
        ["icc-profile"]               = "/usr/share/color/icc/BT.709_Profiles/BT.709.icc",        
        ["hwdec"] = "auto",
        ["video-sync"] = "display-resample",
    },

    [o.lq] = {
        ["vo"] = "opengl",
        ["scale"]  = "spline36",
        ["dscale"] = "mitchell",
        ["tscale"] = "triangle",
        ["dither-depth"]        = "auto",
        ["target-prim"]         = "bt.709",
        ["scaler-resizes-only"] = "yes",
        ["sigmoid-upscaling"]   = "yes",
        ["blend-subtitles"]     = "yes",
        ["opengl-waitvsync"]           = "yes",
        ["interpolation"]     = "no",
        ["blend-subtitles"]     = "yes",
        ["icc-contrast"]            = "2000",
        ["icc-profile"]               = "/usr/share/color/icc/BT.709_Profiles/BT.709.icc",
        ["hwdec"] = "no",
        ["video-sync"] = "audio",
        
    },
}


-- Select the options level appropriate for this computer
function determine_level(o, options)
    -- Default level
    local level = o.lq

    -- Overwrite level from command line with --script-opts=ao-level=<level>
    local overwrite = mp.get_opt("ao-level")
    if overwrite then
        if not options[overwrite] then
            print("Forced level does not exist: " .. overwrite)
            return level
        end
        return overwrite
    end

    -- Call an external bash function determining whether this is a desktop or laptop
    local loc = exec({"/usr/bin/acpitool", "-b", "| grep AC adapter",})
        if loc.status == "<not available>." then
        level = o.lq
        else
        level = o.hq
 end

    return level
end


-- Determine if the currently used resolution is higher than o.highres_threshold
function high_res_desktop(o)
    sp_ret =  exec({"/usr/bin/inxi", "-xSGI", "| grep Resolution", "compare", o.highres_threshold})
    return not sp_ret.error and sp_ret.status > 2
end


function high_res_video(o)
    print("TODO: high_res_video(o)")
    return false
end


function exec(process)
    p_ret = utils.subprocess({args = process})
    if p_ret.error and p_ret.error == "init" then
        print("ERROR executable not found: " .. process[1])
    end
    return p_ret
end


function set_ASS(b)
    return mp.get_property_osd("osd-ass-cc/" .. (b and "0" or "1"))
end


function red_border(s)
    return set_ASS(true) .. "{\\bord1}{\\3c&H3300FF&}{\\3a&H20&}" .. s .. "{\\r}" .. set_ASS(false)
end


function print_status(name, value, o)
    if not value or not o.level then
        return
    end

    if o.err_occ then
        print("Error setting level: " .. o.level)
        mp.osd_message(red_border("Error setting level: ") .. o.level, o.duration * o.duration_err_mult)
    else
        print("Active level: " .. o.level)
        mp.osd_message(o.level
             .. (high_res_desktop(o) and "\n↳ desktop: high res" or "")
             .. (high_res_video(o) and "\n↳ video: high res" or ""), o.duration)
    end
    mp.unobserve_property(print_status)
end


-- Print status information to VO window and terminal
mp.observe_property("vo-configured", "bool",
                    function (name, value) print_status(name, value, o) end)


-- Determined level and apply the appropriate options
function main()
    o.level = determine_level(o, options)
    o.err_occ = false
    for k, v in pairs(options[o.level]) do
        if type(v) == "function" then
            v = v()
        end
        success, err = mp.set_property(k, v)
        o.err_occ = o.err_occ or not (o.err_occ or success)
        if success and o.verbose then
            print("Set '" .. k .. "' to '" .. v .. "'")
        elseif o.verbose then
            print("Failed to set '" .. k .. "' to '" .. v .. "'")
            print(err)
        end
    end
end

main()
