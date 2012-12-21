/*
  color.c

  vr 1.0
 */

#include "rgx.h"

VALUE rgx_cColor = Qnil;

#define COLOR_ATTR_SETTER(name)                     \
  static VALUE                                      \
  rb_color_set_ ## name(VALUE self, VALUE name)     \
  {                                                 \
    GET_COLOR(self, color);                         \
    color->name = CLAMP_COLOR_VALUE(NUM2DBL(name)); \
    return DBL2NUM(color->name);                    \
  }

#define COLOR_ATTR_GETTER(name)     \
  static VALUE                      \
  rb_color_get_ ## name(VALUE self) \
  {                                 \
    GET_COLOR(self, color);         \
    return DBL2NUM(color->name);    \
  }

COLOR_ATTR_SETTER(red);
COLOR_ATTR_SETTER(green);
COLOR_ATTR_SETTER(blue);
COLOR_ATTR_SETTER(alpha);

COLOR_ATTR_GETTER(red);
COLOR_ATTR_GETTER(green);
COLOR_ATTR_GETTER(blue);
COLOR_ATTR_GETTER(alpha);

static VALUE
rb_color_set(int argc, VALUE* argv, VALUE self)
{
  volatile VALUE rbRed, rbGreen, rbBlue, rbAlpha;

  if(argc == 0)
  {
    rbRed   = DBL2NUM(255.0);
    rbGreen = DBL2NUM(255.0);
    rbBlue  = DBL2NUM(255.0);
    rbAlpha = DBL2NUM(255.0);
  }
  else if(argc == 1)
  {
    volatile VALUE rbColor;
    rb_scan_args(argc, argv, "10",
                 &rbColor);
    GET_COLOR(rbColor, src_color);

    rbRed   = DBL2NUM(src_color->red);
    rbGreen = DBL2NUM(src_color->green);
    rbBlue  = DBL2NUM(src_color->blue);
    rbAlpha = DBL2NUM(src_color->alpha);
  }
  else
  {
    rb_scan_args(argc, argv, "31",
               &rbRed, &rbGreen, &rbBlue, &rbAlpha);
    if(rbAlpha == Qnil)
      rbAlpha = DBL2NUM(255.0);
  }
  GET_COLOR(self, color);

  ASSIGN_COLOR(color,
    NUM2DBL(rbRed), NUM2DBL(rbGreen), NUM2DBL(rbBlue), NUM2DBL(rbAlpha));

  return self;
}

VALUE
rb_color_as_ary(VALUE self)
{
  GET_COLOR(self, color);

  VALUE ary = rb_ary_new();

  rb_ary_push(ary, DBL2NUM(color->red));
  rb_ary_push(ary, DBL2NUM(color->green));
  rb_ary_push(ary, DBL2NUM(color->blue));
  rb_ary_push(ary, DBL2NUM(color->alpha));

  return ary;
}

static VALUE
rb_color_dump(VALUE self, VALUE rbDepth)
{
  VALUE ary = rb_color_as_ary(self);

  return rb_funcall(ary, rb_intern("pack"), 1, rb_str_new2("l4\0"));
}

static VALUE
rb_color_load(VALUE klass, VALUE rbDStr)
{
  volatile VALUE rbUAry = rb_funcall(
    rbDStr, rb_intern("unpack"), 1, rb_str_new2("l4\0"));

  VALUE rbArgv[4] = {
    rb_ary_entry(rbUAry, 0), // red
    rb_ary_entry(rbUAry, 1), // green
    rb_ary_entry(rbUAry, 2), // blue
    rb_ary_entry(rbUAry, 3)  // alpha
  };

  return rb_class_new_instance(4, rbArgv, klass);
}

static void
Color_free(RGXColor* color)
{
  free(color);
}

static VALUE
Color_alloc(VALUE klass)
{
  RGXColor* color = ALLOC(RGXColor);
  ASSIGN_COLOR(color, 0.0, 0.0, 0.0, 0.0);
  return Data_Wrap_Struct(klass, 0, Color_free, color);
}

static VALUE
rb_color_init_copy(VALUE self, VALUE rbColor)
{
  GET_COLOR(rbColor, src_color);
  GET_COLOR(self, trg_color);
  ASSIGN_COLOR_FROM_COLOR(trg_color, src_color);
  return Qnil;
}

void Init_rgx_color()
{
  rb_cColor = rb_define_class_under(rgx_mRGX, "Color", rb_cObject);
  rb_define_alloc_func(rb_cColor, Color_alloc);

  rb_define_method(rb_cColor, "initialize_copy", rb_color_init_copy, 1);

  // Since they essentially do the same thing
  rb_define_method(rb_cColor, "initialize", rb_color_set, -1);
  rb_define_method(rb_cColor, "set", rb_color_set, -1);

  rb_define_method(rb_cColor, "red"  , rb_color_get_red, 0);
  rb_define_method(rb_cColor, "green", rb_color_get_green, 0);
  rb_define_method(rb_cColor, "blue" , rb_color_get_blue, 0);
  rb_define_method(rb_cColor, "alpha", rb_color_get_alpha, 0);

  rb_define_method(rb_cColor, "red="  , rb_color_set_red, 1);
  rb_define_method(rb_cColor, "green=", rb_color_set_green, 1);
  rb_define_method(rb_cColor, "blue=" , rb_color_set_blue, 1);
  rb_define_method(rb_cColor, "alpha=", rb_color_set_alpha, 1);

  // Extended
  rb_define_method(rb_cColor, "as_ary", rb_color_as_ary, 0);
}
