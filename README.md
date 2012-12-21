# RM-SRRI : RM - StarRuby Interface
## Version 0.70

## Introduction
```
A wrapper for StarRuby, which implements most of the RGSS3
functionalities
```

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
