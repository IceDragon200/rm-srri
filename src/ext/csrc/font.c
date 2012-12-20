#include "rgx.h"

VALUE rgx_cFont = Qnil;

void Init_rgx_font()
{
  rgx_cFont = rb_define_class_under(rgx_mRGX, "Font", rb_cObject);
  //rb_define_method()
}
