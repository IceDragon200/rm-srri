#include "rgx.h"

VALUE rgx_cTilemap = Qnil;

void Init_rgx_tilemap()
{
  rgx_cTilemap = rb_define_class_under(rgx_mRGX, "Tilemap", rb_cObject);
}
