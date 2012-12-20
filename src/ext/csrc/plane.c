#include "rgx.h"

VALUE rgx_cPlane = Qnil;

void Init_rgx_plane()
{
  rgx_cPlane = rb_define_class_under(rgx_mRGX, "Plane", rb_cObject);
}
