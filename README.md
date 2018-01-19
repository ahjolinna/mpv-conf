#Ahjolinna's MPV conf build (⌐■_■) 

[on hold(/dead) until ffmpeg 3.5 arrives...sigh...or at least if mpv becomes compatible with current stable ffmpeg]
---input wanted

![mpv-conf Preview](http://i.imgur.com/5B881oX.png)

[![Discord](https://discordapp.com/api/guilds/111176699315556352/widget.png)](https://discord.gg/2E5WeVR)<br>

#### Summary : 
This is my own MPV premade conf files, with semi-automatic script to define what settings should be used

#### Basic features:
* ytdl works out of the box, there is A LOT "keyboard bindings", it should support every codec what mpv and ffmpeg has to offer (even non-free codecs)

* few different premade quality settings : hq, cuvid(/cuda), mq, lq & SVP/MVtools (uses medium quality because it's so CPU intensive). There is also the "normal" mpv.desktop file.

* You can also use `--script-opts=ao-level=<level>` to force a specific quality level from command line. Upon start will select a level (/hq/svp/mq/lq) whose options will then be applied.
```
    hq   = high-quality
    svp  = SmoothVideo
    cuda = NVDEC
    mq   = medium-quality
    lq   = low-quality
    
```

* the non-free codecs are now optional, you can disable them in the PKGBUILD easily

####ytdl info:
ytdl ("youtube and a like") support  was  added so it mpv will automatically work with without adding the additional '--ytdl' command, aka you only need to add/write mpv <link> nothing else.. nothing more
```
Example: mpv https://vimeo.com/148177620
```
Twitch live streaming info: If you want to watch some live twich.tv video streams you need to install ['streamlink'](https://streamlink.github.io/) (livestreamer fork) app, and to watch them with MPV you need to use this following command :
```
streamlink -p mpv <twitch link> <quality> --player-continuous-http
``` 
```
Example: streamlink -p mpv https://www.twitch.tv/saddummy best --player-continuous-http
```

#### side note:
the <quality> "command" is for the stream quality** 
**You can get the list of available quality formats using:  "youtube-dl <link>  --list-formats"

####NOTE:
if you want to use MVtools you need to install 'vapoursynth-plugin-mvtools' to use it, BUT remember it's really CPU demanding feature
```
    What Smooth Motion is not, is a frame interpolation system—it will not introduce the “soap opera effect” like you see on 120Hz+ TVs, or reduce 24p judder.

    Smooth Motion is designed to display content where the source framerate does not match up to any of the refresh rates that your display supports. For example, that would be 25/50fps content on a 60Hz-only display, or 24p content on a 60Hz-only display.

    It does not replace ReClock or VideoClock, and if your display supports 1080p24, 1080p50, and 1080p60 then you should not need to use Smooth Motion at all.

    Because Smooth Motion works by using frame blending you may see slight ghost images at the edge of moving objects—but this seems to be rare and dependent on the display you are using, and is definitely preferable to the usual judder from mismatched framerates/refresh rates.
```
##[SVP - SmoothVideo Project](https://www.svp-team.com/wiki/Main_Page)
SVP provides GPU acceleration and allows to watch FullHD 1080p-video recalculated to 60Hz in real-time using a mid-range CPU and almost any GPU hardware.
SVP is a proprietary project and its free for linux users but 15$ for win/mac version


there is more info about frame interpolation tech at mpv's [wiki page](https://github.com/mpv-player/mpv/wiki/Interpolation)

## (MPV) Requirements
* [`Adobe Source Sans Pro`](http://adobe-fonts.github.io/source-sans-pro/): used in OSD
* `youtube-dl`: youtube videos and a like
* `livestreamer`: to watch live video streams (twitch.tv)
* `vapoursynth`: for some script support like MVtools '--enable-vapoursynth' needs to be added in mpv build
* `vapoursynth-plugin-mvtools`: Realtime motion interpolating playback in mpv
* [`SVP4`](https://www.svp-team.com/) support, a "proprietary version of MVtools" that is way better
* `acpitool`: for "battery mode" detection
* `inxi`: HIDPI-detection
* `libvdpau or libva`: for hardware-acceleration support
* `CUDA/CUVID` support for nvidia users

`|-o-| ---FUTURE PLANS--- |-o-|`
```
1) use "full version" of MPV and ffmpeg (more or less) in PKGBUILD || DONE
2) make non-free codecs optional in PKGBUILD || Done
3) more "automatic" quality settings in the (lua) scripts || semi-DONE
4) adding laptop & desktop detection it has been added/changed to battery detection || DONE
5) better documentation when most of these features have been || semi-done
6) have same video quality setting what bomi-player uses (video->Quality Preset) || help-needed
```
`( ∙_∙) ( ∙_∙)>⌐■-■ (⌐■_■)`

