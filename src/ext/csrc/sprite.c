#include "rgx.h"

VALUE rgx_cSprite = Qnil;

void Init_rgx_sprite()
{
  rgx_cSprite = rb_define_class_under(rgx_mRGX, "Sprite", rb_cObject);
}
