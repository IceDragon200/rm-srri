#include "rgx.h"

VALUE rgx_cColor = Qnil;

static RGXColor *col_struct_new(double cred, double cgreen, double cblue, double calpha)
{
  RGXColor *col;
  col = malloc(sizeof(RGXColor));

  ASSIGN_COLOR(col, cred, cgreen, cblue, calpha);

  return col;
}

static void col_free(void *p)
{
  free(p);
}

VALUE col_new(VALUE klass, VALUE cred, VALUE cgreen, VALUE cblue, VALUE calpha)
{
  VALUE argv[] = { cred, cgreen, cblue, calpha };
  RGXColor *ptr = col_struct_new(
    NUM2DBL(cred), NUM2DBL(cgreen), NUM2DBL(cblue), NUM2DBL(calpha));
  VALUE tdata = Data_Wrap_Struct(klass, 0, col_free, ptr);
  rb_obj_call_init(tdata, 4, argv);
  return tdata;
}

static VALUE col_initialize(VALUE self, VALUE cred, VALUE cgreen, VALUE cblue, VALUE calpha)
{
  return self;
}

static VALUE col_set(VALUE self, VALUE cred, VALUE cgreen, VALUE cblue, VALUE calpha)
{
  GET_COLOR(self, color);

  ASSIGN_COLOR(color, NUM2DBL(cred), NUM2DBL(cgreen), NUM2DBL(cblue), NUM2DBL(calpha));

  return self;
}

static VALUE col_set_red(VALUE self, VALUE cred)
{
  GET_COLOR(self, color);

  double val = CLAMP_COLOR_VALUE(NUM2DBL(cred));

  color->red = val;

  return DBL2NUM(color->red);
}

static VALUE col_set_green(VALUE self, VALUE cgreen)
{
  GET_COLOR(self, color);

  double val = CLAMP_COLOR_VALUE(NUM2DBL(cgreen));

  color->green = val;

  return DBL2NUM(color->green);
}

static VALUE col_set_blue(VALUE self, VALUE cblue)
{
  GET_COLOR(self, color);

  double val = CLAMP_COLOR_VALUE(NUM2DBL(cblue));

  color->blue = val;

  return DBL2NUM(color->blue);
}

static VALUE col_set_alpha(VALUE self, VALUE calpha)
{
  GET_COLOR(self, color);

  double val = CLAMP_COLOR_VALUE(NUM2DBL(calpha));

  color->alpha = val;

  return DBL2NUM(color->alpha);
}

static VALUE col_get_red(VALUE self)
{
  GET_COLOR(self, color);
  return DBL2NUM(color->red);
}

static VALUE col_get_green(VALUE self)
{
  GET_COLOR(self, color);
  return DBL2NUM(color->green);
}

static VALUE col_get_blue(VALUE self)
{
  GET_COLOR(self, color);
  return DBL2NUM(color->blue);
}

static VALUE col_get_alpha(VALUE self)
{
  GET_COLOR(self, color);
  return DBL2NUM(color->alpha);
}

static VALUE col_as_ary(VALUE self)
{
  GET_COLOR(self, color);

  VALUE ary = rb_ary_new();

  rb_ary_push(ary, DBL2NUM(color->red));
  rb_ary_push(ary, DBL2NUM(color->green));
  rb_ary_push(ary, DBL2NUM(color->blue));
  rb_ary_push(ary, DBL2NUM(color->alpha));

  return ary;
}

void Init_rgx_color()
{
  rgx_cColor = rb_define_class_under(rgx_mRGX, "Color", rb_cObject);

  rb_define_singleton_method(rgx_cColor, "new4", col_new, 4);

  rb_define_method(rgx_cColor, "initialize4", col_initialize, 4);

  rb_define_method(rgx_cColor, "set4", col_set, 4);

  rb_define_method(rgx_cColor, "red"  , col_get_red, 0);
  rb_define_method(rgx_cColor, "green", col_get_green, 0);
  rb_define_method(rgx_cColor, "blue" , col_get_blue, 0);
  rb_define_method(rgx_cColor, "alpha", col_get_alpha, 0);

  rb_define_method(rgx_cColor, "red="  , col_set_red, 1);
  rb_define_method(rgx_cColor, "green=", col_set_green, 1);
  rb_define_method(rgx_cColor, "blue=" , col_set_blue, 1);
  rb_define_method(rgx_cColor, "alpha=", col_set_alpha, 1);

  // Extended
  rb_define_method(rgx_cColor, "as_ary", col_as_ary, 0);
}
