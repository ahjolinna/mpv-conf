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

local o = {
  hq = "high-quality",
  mq = "medium-quality",
  svp = "SmoothVideo",
  cuda = "cuvid",
  lq = "low-quality",
  highres_threshold = "1920x1080@60.00hz",
  force_low_res = false,
  verbose = true,
  duration = 2,
  duration_err_mult = 2,

}
opts.read_options(o)


-- Specify a VO for each level

vo = {
  [o.hq]    = "opengl-hq",
  [o.cuda]  = "opengl-hq",
  [o.svp]   = "opengl-hq",
  [o.mq]    = "opengl-hq",
  [o.lq]    = "opengl",
}


-- Specify VO sub-options for different levels
vo_opts = {
  [o.hq] = {
    ["scale"]                   = "ewa_lanczossharp",
    ["cscale"]                  = "ewa_lanczossoft",
    ["dscale"]                  = "mitchell",
    ["tscale"]                  = "oversample",
    ["scale-antiring"]          = "0.8",
    ["cscale-antiring"]         = "0.9",
    ["scale-radius"]            = "3",

    ["interpolation"]           =  function () return is_high_res(o) and "no" or "yes" end,
    ["interpolation-threshold"] = "0.0001",

    ["dither-depth"]            = "auto",
    ["scaler-resizes-only"]     = "yes",
    ["sigmoid-upscaling"]       = "yes",
    ["correct-downscaling"]     = "yes",
    ["opengl-waitvsync"]        = "yes",

    ["target-prim"]             = "bt.2020",
    ["target-trc"]              = "bt.1886",
    ["icc-3dlut-size"]          = "256x256x256",
    ["blend-subtitles"]         = "video",
    ["icc-contrast"]            = "2000",
    ["icc-profile"]             = "/usr/share/color/icc/BT.709_Profiles/BT.709.icc",
    ["spirv-compiler"]          = "auto",
  },

  [o.cuda] = {
    ["scale"]                   = "ewa_lanczossharp",
    ["cscale"]                  = "ewa_lanczossoft",
    ["dscale"]                  = "mitchell",
    ["tscale"]                  = "oversample",
    ["scale-antiring"]          = "0.8",
    ["cscale-antiring"]         = "0.9",

    ["interpolation"]           =  function () return is_high_res(o) and "no" or "yes" end,
    ["interpolation-threshold"] = "0.0001",

    ["dither-depth"]            = "auto",
    ["target-prim"]             = "bt.709",
    ["correct-downscaling"]     = "yes",
    ["opengl-waitvsync"]        = "yes",
    ["vd-lavc-o=deint"]         = "adaptive",

    ["target-prim"]             = "bt.2020",
    ["target-trc"]              = "bt.1886",
    ["icc-3dlut-size"]          = "256x256x256",
    ["blend-subtitles"]         = "video",
    ["spirv-compiler"]          = "nvidia",
  --["vulkan-swap-mode"]        = "mailbox",
  --["vulkan-queue-count"]      = "2",

  },

  [o.svp] = {
    ["scale"]                   = "ewa_lanczossharp",
    ["cscale"]                  = "ewa_lanczossoft",
    ["dscale"]                  = "mitchell",
    ["tscale"]                  = "triangle",
    ["scale-antiring"]          = "0.8",
    ["cscale-antiring"]         = "0.9",

    ["dither-depth"]            = "auto",
    ["target-prim"]             = "bt.709",
    ["correct-downscaling"]     = "yes",
    ["input-ipc-server"]        = "/tmp/mpvsocket",
  },

  [o.mq] = {
    ["scale"]                   = "spline36",
    ["cscale"]                  = "spline36",
    ["dscale"]                  = "mitchell",
    ["tscale"]                  = "oversample",
    ["scale-antiring"]          = "0.8",
    ["cscale-antiring"]         = "0.9",
    ["scale-radius"]            = "3",

    ["dither-depth"]            = "auto",
    ["scaler-resizes-only"]     = "yes",
    ["sigmoid-upscaling"]       = "yes",

    ["interpolation"]           =  function () return is_high_res(o) and "no" or "yes" end,
    ["interpolation-threshold"] = "0.0001",
    ["correct-downscaling"]     = "yes",
    ["deband"]                  = "yes",
    ["opengl-waitvsync"]        = "yes",

    ["target-prim"]             = "bt.2020",
    ["target-trc"]              = "bt.1886",
    ["icc-3dlut-size"]          = "256x256x256",
    ["blend-subtitles"]         = "yes",
    ["icc-contrast"]            = "2000",
    ["icc-profile"]             = "/usr/share/color/icc/BT.709_Profiles/BT.709.icc",
  },

  [o.lq] = {
    ["scale"]                   = "spline36",
    ["dscale"]                  = "mitchell",
    ["tscale"]                  = "oversample",

    ["dither-depth"]            = "auto",
    ["target-prim"]             = "bt.709",
    ["scaler-resizes-only"]     = "yes",
    ["sigmoid-upscaling"]       = "yes",
    ["blend-subtitles"]         = "yes",
    ["opengl-waitvsync"]        = "yes",

    ["interpolation"]           = function () return is_high_res(o) and "no" or "yes" end,
    ["blend-subtitles"]         = "yes",
    ["icc-contrast"]            = "2000",
    ["icc-profile"]             = "/usr/share/color/icc/BT.709_Profiles/BT.709.icc",
  },
}


-- Specify general mpv options for different levels

options = {
  [o.hq] = {
    ["options/vo"]              = vo_opts[o.hq],
    ["options/hwdec"]           = "auto-copy",
    ["options/video-sync"]      = function () return is_high_res(o) and "audio" or "display-resample" end,
    ["options/vd-lavc-threads"] = "32",
    ["options/vf"]              = "vdpaupp=sharpen=0.10:denoise=0.10:deint=yes:deint-mode=temporal-spatial:pullup:hqscaling=1",
    ["options/gpu-api"]         = "auto",
  },
  [o.cuda] = {
    ["options/vo"]              = vo_opts[o.mq],
    ["options/video-sync"]      = function () return is_high_res(o) and "audio" or "display-resample" end,
    ["options/vd-lavc-threads"] = "32",
    ["options/hwdec"]           = "cuda-copy",
    ["options/gpu-api"]         = "auto",
  },
  [o.svp] = {
    ["options/vo"]              = vo_opts[o.mq],
    ["options/video-sync"]      = function () return is_high_res(o) and "audio" or "display-resample" end,
    ["options/vd-lavc-threads"] = "32",
    ["options/hwdec"]           = "auto-copy",
    ["options/gpu-api"]         = "opengl",
  },
  [o.mq] = {
    ["options/vo"]              = vo_opts[o.mq],
    ["options/video-sync"]      = function () return is_high_res(o) and "audio" or "display-resample" end,
    ["options/vd-lavc-threads"] = "16",
    ["options/hwdec"]           = "auto-copy",
    ["options/gpu-api"]         = "opengl",
  },

  [o.lq] = {
    ["options/vo"]              = vo_opts[o.lq],
    ["options/video-sync"]      = "audio",
    ["options/hwdec"]           = "auto-copy",
    ["options/gpu-api"]         = "opengl",
  },
}


-- Print status information to VO window and terminal

mp.observe_property("vo-configured", "bool",
function (name, value) print_status(name, value, o) end)

-- Determined level and set the appropriate options

function main()
  o.force_low_res = mp.get_opt("ao-flr")
  o.level = determine_level(o, vo, vo_opts, options)
  o.err_occ = false
  for k, v in pairs(options[o.level]) do
    if type(v) == "table" then
     for property, value in pairs(v) do
        set_property(property, value, o)
     end
    else
      set_property(k, v, o)
    end
  end
end

main()
