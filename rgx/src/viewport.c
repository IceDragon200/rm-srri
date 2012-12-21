#include "rgx.h"

VALUE rgx_cViewport = Qnil;

void Init_rgx_viewport()
{
  rgx_cViewport = rb_define_class_under(rgx_mRGX, "Viewport", rb_cObject);
}
