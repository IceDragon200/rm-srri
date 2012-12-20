/*
 */
#include "rgx.h"

VALUE rgx_mRGX = Qnil;

void Init_rgx()
{
  rgx_mRGX = rb_define_module("RGX");

  Init_rgx_table();
  Init_rgx_rect();

  Init_rgx_color();
  Init_rgx_tone();

  // Init_rgx_font();

  // Init_rgx_bitmap();

  // Init_rgx_viewport();

  // Init_rgx_sprite();
  // Init_rgx_plane();
  // Init_rgx_tilemap();
  // Init_rgx_window();

  Init_chuchu();
}
