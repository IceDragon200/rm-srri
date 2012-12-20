#include "rgx.h"

VALUE c_ChuChu = Qnil;

void Init_chuchu() 
{
  c_ChuChu = rb_define_class_under(rgx_mRGX, "ChuChu", rb_cObject);

  rb_define_singleton_method(c_ChuChu, "next_frame", chuchu_next_frame_s, 2);
}

VALUE chuchu_next_frame_s(VALUE self, VALUE frame_rate, VALUE last_frame)
{
  struct timespec tim, tim2;
  tim.tv_sec = 0;
  tim.tv_nsec = 1000000000 / NUM2LONG(frame_rate);

  nanosleep(&tim, &tim2);

  return LONG2NUM(NUM2LONG(last_frame) + 1);
}
