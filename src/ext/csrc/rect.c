/*

  RGXRect

 */
#include "rgx.h"

VALUE rb_cRect = Qnil;

static VALUE
rb_rect_get_x(VALUE self)
{
  GET_RECT(self, rect);
  return INT2NUM(rect->x);
}

static VALUE
rb_rect_get_y(VALUE self)
{
  GET_RECT(self, rect);
  return INT2NUM(rect->y);
}

static VALUE
rb_rect_get_width(VALUE self)
{
  GET_RECT(self, rect);
  return INT2NUM(rect->width);
}

static VALUE
rb_rect_get_height(VALUE self)
{
  GET_RECT(self, rect);
  return INT2NUM(rect->height);
}

static VALUE
rb_rect_set_x(VALUE self, VALUE sx)
{
  GET_RECT(self, rect);
  rect->x = NUM2INT(sx);
  return INT2NUM(rect->x);
}

static VALUE
rb_rect_set_y(VALUE self, VALUE sy)
{
  GET_RECT(self, rect);
  rect->y = NUM2INT(sy);
  return INT2NUM(rect->y);
}

static VALUE
rb_rect_set_width(VALUE self, VALUE swidth)
{
  GET_RECT(self, rect);
  rect->width = NUM2INT(swidth);
  return INT2NUM(rect->width);
}

static VALUE
rb_rect_set_height(VALUE self, VALUE sheight)
{
  GET_RECT(self, rect);
  rect->height = NUM2INT(sheight);
  return INT2NUM(rect->height);
}

static VALUE
rb_rect_initialize(int argc, VALUE* argv, VALUE self)
{
  volatile VALUE rbX, rbY, rbWidth, rbHeight;

  if(argc == 0)
  {
    rbX      = INT2NUM(0);
    rbY      = INT2NUM(0);
    rbWidth  = INT2NUM(0);
    rbHeight = INT2NUM(0);
  }
  else if(argc == 1)
  {
    volatile VALUE rbRect;
    rb_scan_args(argc, argv, "10",
                 &rbRect);

    GET_RECT(rbRect, src_rect);


    rbX = INT2NUM(src_rect->x);
    rbY = INT2NUM(src_rect->y);
    rbWidth = INT2NUM(src_rect->width);
    rbHeight = INT2NUM(src_rect->height);
  }
  else
  {
    rb_scan_args(argc, argv, "40",
                 &rbX, &rbY, &rbWidth, &rbHeight);
  }
  GET_RECT(self, rect);

  rect->x = NUM2INT(rbX);
  rect->y = NUM2INT(rbY);
  rect->width = NUM2INT(rbWidth);
  rect->height = NUM2INT(rbHeight);

  return Qnil;
}

static VALUE
rb_rect_set(int argc, VALUE* argv, VALUE self)
{
  volatile VALUE rbX, rbY, rbWidth, rbHeight;

  if(argc == 0)
  {
    VALUE zero = INT2NUM(0);
    rbX      = zero;
    rbY      = zero;
    rbWidth  = zero;
    rbHeight = zero;
  }
  else if(argc == 1)
  {
    volatile VALUE rbRect;
    rb_scan_args(argc, argv, "10",
                 &rbRect);
    GET_RECT(rbRect, src_rect);

    rbX = INT2NUM(src_rect->x);
    rbY = INT2NUM(src_rect->y);
    rbWidth = INT2NUM(src_rect->width);
    rbHeight = INT2NUM(src_rect->height);
  }
  else
  {
    rb_scan_args(argc, argv, "40",
               &rbX, &rbY, &rbWidth, &rbHeight);
  }
  GET_RECT(self, rect);

  rect->x = NUM2INT(rbX);
  rect->y = NUM2INT(rbY);
  rect->width = NUM2INT(rbWidth);
  rect->height = NUM2INT(rbHeight);

  return self;
}

static VALUE
rb_rect_empty(VALUE self)
{
  GET_RECT(self, rect);

  rect->x = 0;
  rect->y = 0;
  rect->width = 0;
  rect->height = 0;

  return self;
}

static VALUE
rb_rect_is_empty(VALUE self)
{
  GET_RECT(self, rect);
  return (rect->width == 0 || rect->height == 0) ? Qtrue : Qfalse;
}

static VALUE
rb_rect_as_ary(VALUE self)
{
  GET_RECT(self, rect);

  VALUE ary = rb_ary_new();

  rb_ary_push(ary, INT2NUM(rect->x));
  rb_ary_push(ary, INT2NUM(rect->y));
  rb_ary_push(ary, INT2NUM(rect->width));
  rb_ary_push(ary, INT2NUM(rect->height));

  return ary;
}

static VALUE
rb_rect_dump(VALUE self, VALUE rbDepth)
{
  GET_RECT(self, rect);

  VALUE rbX = INT2NUM(rect->x);
  VALUE rbY = INT2NUM(rect->y);
  VALUE rbW = INT2NUM(rect->width);
  VALUE rbH = INT2NUM(rect->height);

  VALUE ary = rb_ary_new();
  rb_ary_push(ary, rbX);
  rb_ary_push(ary, rbY);
  rb_ary_push(ary, rbW);
  rb_ary_push(ary, rbH);

  return rb_funcall(ary, rb_intern("pack"), 1, rb_str_new2("l4\0"));
}

static VALUE
rb_rect_load(VALUE klass, VALUE rbDStr)
{
  volatile VALUE rbUAry = rb_funcall(
    rbDStr, rb_intern("unpack"), 1, rb_str_new2("l4\0"));

  VALUE rbArgv[4] = {
    rb_ary_entry(rbUAry, 0), rb_ary_entry(rbUAry, 1), // x, y
    rb_ary_entry(rbUAry, 2), rb_ary_entry(rbUAry, 3)  // width, height
  };

  return rb_class_new_instance(4, rbArgv, klass);
}

static void
Rect_free(RGXRect* rect)
{
  free(rect);
}

static VALUE
Rect_alloc(VALUE klass)
{
  RGXRect* rect = ALLOC(RGXRect);
  rect->x      = 0;
  rect->y      = 0;
  rect->width  = 0;
  rect->height = 0;
  return Data_Wrap_Struct(klass, 0, Rect_free, rect);
}

void Init_rgx_rect()
{
  rb_cRect = rb_define_class_under(rgx_mRGX, "Rect", rb_cObject);

  rb_define_alloc_func(rb_cRect, Rect_alloc);

  rb_define_method(rb_cRect, "initialize", rb_rect_initialize, -1);

  rb_define_method(rb_cRect, "set", rb_rect_set, -1);

  rb_define_method(rb_cRect, "empty", rb_rect_empty, 0);

  rb_define_method(rb_cRect, "x", rb_rect_get_x, 0);
  rb_define_method(rb_cRect, "y", rb_rect_get_y, 0);
  rb_define_method(rb_cRect, "width", rb_rect_get_width, 0);
  rb_define_method(rb_cRect, "height", rb_rect_get_height, 0);

  rb_define_method(rb_cRect, "x=", rb_rect_set_x, 1);
  rb_define_method(rb_cRect, "y=", rb_rect_set_y, 1);
  rb_define_method(rb_cRect, "width=", rb_rect_set_width, 1);
  rb_define_method(rb_cRect, "height=", rb_rect_set_height, 1);

  rb_define_singleton_method(rb_cRect, "_load", rb_rect_load, 1);
  rb_define_method(rb_cRect, "_dump", rb_rect_dump, 1);

  // Extended
  rb_define_method(rb_cRect, "empty?", rb_rect_is_empty, 0);
  rb_define_method(rb_cRect, "as_ary", rb_rect_as_ary, 0);


}
