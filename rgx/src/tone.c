/*
  tone.c

  vr 1.0
 */

#include "rgx.h"

VALUE rgx_cTone = Qnil;

#define TONE_ATTR_SETTER(name)                     \
  static VALUE                                      \
  rb_tone_set_ ## name(VALUE self, VALUE name)     \
  {                                                 \
    GET_TONE(self, tone);                         \
    tone->name = CLAMP_TONE_VALUE(NUM2DBL(name)); \
    return DBL2NUM(tone->name);                    \
  }

#define TONE_ATTR_GETTER(name)     \
  static VALUE                      \
  rb_tone_get_ ## name(VALUE self) \
  {                                 \
    GET_TONE(self, tone);         \
    return DBL2NUM(tone->name);    \
  }

TONE_ATTR_SETTER(red);
TONE_ATTR_SETTER(green);
TONE_ATTR_SETTER(blue);
TONE_ATTR_SETTER(grey);

TONE_ATTR_GETTER(red);
TONE_ATTR_GETTER(green);
TONE_ATTR_GETTER(blue);
TONE_ATTR_GETTER(grey);

static VALUE
rb_tone_set(int argc, VALUE* argv, VALUE self)
{
  volatile VALUE rbRed, rbGreen, rbBlue, rbGrey;

  if(argc == 0)
  {
    rbRed   = DBL2NUM(0.0);
    rbGreen = DBL2NUM(0.0);
    rbBlue  = DBL2NUM(0.0);
    rbGrey = DBL2NUM(0.0);
  }
  else if(argc == 1)
  {
    volatile VALUE rbTone;
    rb_scan_args(argc, argv, "10",
                 &rbTone);
    GET_TONE(rbTone, src_tone);

    rbRed   = DBL2NUM(src_tone->red);
    rbGreen = DBL2NUM(src_tone->green);
    rbBlue  = DBL2NUM(src_tone->blue);
    rbGrey = DBL2NUM(src_tone->grey);
  }
  else
  {
    rb_scan_args(argc, argv, "31",
               &rbRed, &rbGreen, &rbBlue, &rbGrey);
    if(rbGrey == Qnil)
      rbGrey = DBL2NUM(0.0);
  }
  GET_TONE(self, tone);

  ASSIGN_TONE(tone,
    NUM2DBL(rbRed), NUM2DBL(rbGreen), NUM2DBL(rbBlue), NUM2DBL(rbGrey));

  return self;
}

VALUE
rb_tone_as_ary(VALUE self)
{
  GET_TONE(self, tone);

  VALUE ary = rb_ary_new();

  rb_ary_push(ary, DBL2NUM(tone->red));
  rb_ary_push(ary, DBL2NUM(tone->green));
  rb_ary_push(ary, DBL2NUM(tone->blue));
  rb_ary_push(ary, DBL2NUM(tone->grey));

  return ary;
}

static VALUE
rb_tone_dump(VALUE self, VALUE rbDepth)
{
  VALUE ary = rb_tone_as_ary(self);

  return rb_funcall(ary, rb_intern("pack"), 1, rb_str_new2("l4\0"));
}

static VALUE
rb_tone_load(VALUE klass, VALUE rbDStr)
{
  volatile VALUE rbUAry = rb_funcall(
    rbDStr, rb_intern("unpack"), 1, rb_str_new2("l4\0"));

  VALUE rbArgv[4] = {
    rb_ary_entry(rbUAry, 0), // red
    rb_ary_entry(rbUAry, 1), // green
    rb_ary_entry(rbUAry, 2), // blue
    rb_ary_entry(rbUAry, 3)  // grey
  };

  return rb_class_new_instance(4, rbArgv, klass);
}

static void
Tone_free(RGXTone* tone)
{
  free(tone);
}

static VALUE
Tone_alloc(VALUE klass)
{
  RGXTone* tone = ALLOC(RGXTone);
  ASSIGN_TONE(tone, 0.0, 0.0, 0.0, 0.0);
  return Data_Wrap_Struct(klass, 0, Tone_free, tone);
}

static VALUE
rb_tone_init_copy(VALUE self, VALUE rbTone)
{
  GET_TONE(rbTone, src_tone);
  GET_TONE(self, trg_tone);
  ASSIGN_TONE_FROM_TONE(trg_tone, src_tone);
  return Qnil;
}

void Init_rgx_tone()
{
  rb_cTone = rb_define_class_under(rgx_mRGX, "Tone", rb_cObject);
  rb_define_alloc_func(rb_cTone, Tone_alloc);

  rb_define_method(rb_cTone, "initialize_copy", rb_tone_init_copy, 1);

  // Since they essentially do the same thing
  rb_define_method(rb_cTone, "initialize", rb_tone_set, -1);
  rb_define_method(rb_cTone, "set", rb_tone_set, -1);

  rb_define_method(rb_cTone, "red"  , rb_tone_get_red, 0);
  rb_define_method(rb_cTone, "green", rb_tone_get_green, 0);
  rb_define_method(rb_cTone, "blue" , rb_tone_get_blue, 0);
  rb_define_method(rb_cTone, "grey", rb_tone_get_grey, 0);

  rb_define_method(rb_cTone, "red="  , rb_tone_set_red, 1);
  rb_define_method(rb_cTone, "green=", rb_tone_set_green, 1);
  rb_define_method(rb_cTone, "blue=" , rb_tone_set_blue, 1);
  rb_define_method(rb_cTone, "grey=", rb_tone_set_grey, 1);

  // Extended
  rb_define_method(rb_cTone, "as_ary", rb_tone_as_ary, 0);
}
