# RM-SRRI : RM - StarRuby Interface
## Version 0.7.0

## Introduction
```
A wrapper for StarRuby, which implements most of the RGSS3
functionalities
```

## TODO
- Make a sample game
- Actually use the Test suite instead of this hax-ish stuff

## Missing
Since I've been a bit too busy, or in-experienced, some functionality is missing
from the interface.

### Modules
Audio (methods)
```
bgs_*
  Currently the method calls will do absolutely nothing

me_*
  Currently the method calls will do absolutely nothing

setup_midi
```

Graphics (methods)
```
frame_reset
  Its a kinda pointless method anyway

play_movie
  Its possible
```

### Classes
Tilemap
```
Currently Tilemap has not been inplemented, since its the most complicated class
in RGSS2/3
```

Plane
```
#color, and #tone have a few problems in rendering
```

Viewport, Sprite
```
#color (rendering)
#tone (rendering)
#flash
```

## Credits
- CaptainJet (https://github.com/CaptainJet)
- StarRuby (https://github.com/hajimehoshi/starruby)
- Enterbrain

## Changes
29/03/2013
  Moved all Interfaces under the SRRI module
27/03/2013
  Fixed fps being nil in Graphics, if it wasn't initialized

