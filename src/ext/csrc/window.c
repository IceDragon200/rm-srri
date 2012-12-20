#include "rgx.h"

VALUE rgx_cWindow = Qnil;

void Init_rgx_window()
{
  rgx_cWindow = rb_define_class_under(rgx_mRGX, "Window", rb_cObject);
}
