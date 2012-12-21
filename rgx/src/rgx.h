/*
  rgx3.h
 */
#ifndef INC_RGX_MAIN

  #define INC_RGX_MAIN

  // Definitions
  #define MAX(x, y) (((x) >= (y)) ? (x) : (y))
  #define MIN(x, y) (((x) <= (y)) ? (x) : (y))
  
  // Headers
  #include <math.h>
  #include <stdbool.h>
  #include <stdint.h>
  #include <stdio.h>
  #include <string.h>
  #include <time.h>
  #include <ruby.h>  

  #include "table.h" 
  #include "rect.h" 

  #include "color.h" 
  #include "tone.h" 
  
  #include "bitmap.h" 

  #include "viewport.h" 

  #include "sprite.h" 
  #include "plane.h" 
  #include "tilemap.h" 
  #include "window.h" 

  #include "chuchu.h"

  // FDec
  VALUE rgx_mRGX;

  void Init_rgx();

#endif
