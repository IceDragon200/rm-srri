/*

  tone.c

 */
#include "rgx.h"

VALUE rgx_cTone = Qnil;

static void tn_set_struct(RGXTone *tn, double cred, double cgreen, double cblue, double cgrey)
{
  LIMIT_TONE_DOUBLE(cred);
  LIMIT_TONE_DOUBLE(cgreen);
  LIMIT_TONE_DOUBLE(cblue);
  LIMIT_TONE_DOUBLE(cgrey);

  tn->red = cred;
  tn->green = cgreen;
  tn->blue = cblue;
  tn->grey = cgrey;
}

static RGXTone *tn_struct_new(double cred, double cgreen, double cblue, double cgrey)
{
  RGXTone *tn;
  tn = malloc(sizeof(RGXTone));

  tn_set_struct(tn, cred, cgreen, cblue, cgrey);

  return tn;
}

static void tn_free(void *p)
{
  free(p);
}

static VALUE tn_new(VALUE klass, VALUE cred, VALUE cgreen, VALUE cblue, VALUE cgrey)
{
  VALUE argv[] = { cred, cgreen, cblue, cgrey };
  RGXTone *ptr = tn_struct_new(NUM2DBL(cred), NUM2DBL(cgreen), NUM2DBL(cblue), NUM2DBL(cgrey));
  VALUE tdata = Data_Wrap_Struct(klass, 0, tn_free, ptr);
  rb_obj_call_init(tdata, 4, argv);
  return tdata;
}

static VALUE tn_initialize(VALUE self, VALUE cred, VALUE cgreen, VALUE cblue, VALUE cgrey)
{
  return self;
}

static VALUE tn_set(VALUE self, VALUE cred, VALUE cgreen, VALUE cblue, VALUE cgrey)
{
  GET_TONE(self, tone);

  tn_set_struct(tone, NUM2DBL(cred), NUM2DBL(cgreen), NUM2DBL(cblue), NUM2DBL(cgrey));

  return self;
}

static VALUE tn_set_red(VALUE self, VALUE cred)
{
  GET_TONE(self, tone);

  double val = NUM2DBL(cred);
  LIMIT_TONE_DOUBLE(val);

  tone->red = val;

  return DBL2NUM(tone->red);
}

static VALUE tn_set_green(VALUE self, VALUE cgreen)
{
  GET_TONE(self, tone);

  double val = NUM2DBL(cgreen);
  LIMIT_TONE_DOUBLE(val);

  tone->green = val;

  return DBL2NUM(tone->green);
}

static VALUE tn_set_blue(VALUE self, VALUE cblue)
{
  GET_TONE(self, tone);

  double val = NUM2DBL(cblue);
  LIMIT_TONE_DOUBLE(val);

  tone->blue = val;

  return DBL2NUM(tone->blue);
}

static VALUE tn_set_grey(VALUE self, VALUE cgrey)
{
  GET_TONE(self, tone);

  double val = NUM2DBL(cgrey);
  LIMIT_TONE_DOUBLE(val);

  tone->grey = val;

  return DBL2NUM(tone->grey);
}

static VALUE tn_get_red(VALUE self)
{
  GET_TONE(self, tone);
  return DBL2NUM(tone->red);
}

static VALUE tn_get_green(VALUE self)
{
  GET_TONE(self, tone);
  return DBL2NUM(tone->green);
}

static VALUE tn_get_blue(VALUE self)
{
  GET_TONE(self, tone);
  return DBL2NUM(tone->blue);
}

static VALUE tn_get_grey(VALUE self)
{
  GET_TONE(self, tone);
  return DBL2NUM(tone->grey);
}

static VALUE tn_as_ary(VALUE self)
{
  GET_TONE(self, tone);

  VALUE ary = rb_ary_new();

  rb_ary_push(ary, DBL2NUM(tone->red));
  rb_ary_push(ary, DBL2NUM(tone->green));
  rb_ary_push(ary, DBL2NUM(tone->blue));
  rb_ary_push(ary, DBL2NUM(tone->grey));

  return ary;
}

void Init_rgx_tone()
{
  rgx_cTone = rb_define_class_under(rgx_mRGX, "Tone", rb_cObject);

  rb_define_singleton_method(rgx_cTone, "new4", tn_new, 4);
  rb_define_method(rgx_cTone, "initialize4", tn_initialize, 4);

  rb_define_method(rgx_cTone, "set4", tn_set, 4);

  rb_define_method(rgx_cTone, "red", tn_get_red, 0);
  rb_define_method(rgx_cTone, "green", tn_get_green, 0);
  rb_define_method(rgx_cTone, "blue", tn_get_blue, 0);
  rb_define_method(rgx_cTone, "grey", tn_get_grey, 0);

  rb_define_method(rgx_cTone, "red=", tn_set_red, 1);
  rb_define_method(rgx_cTone, "green=", tn_set_green, 1);
  rb_define_method(rgx_cTone, "blue=", tn_set_blue, 1);
  rb_define_method(rgx_cTone, "grey=", tn_set_grey, 1);

  rb_define_method(rgx_cTone, "as_ary", tn_as_ary, 0);
}
