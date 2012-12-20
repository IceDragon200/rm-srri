#include "rgx.h"

VALUE rgx_cBitmap = Qnil;

/*
typedef struct
{
  int width, height;
  Texture
} RGXRect;
*/

// Functions
static VALUE bmp_new1(VALUE klass, VALUE path)
{
  return Qnil;
}

static VALUE bmp_new2(VALUE klass, VALUE width, VALUE height)
{
  return Qnil;
}

static VALUE bmp_initialize2(VALUE self, VALUE width, VALUE height)
{
  return self;
}

static VALUE bmp_initialize1(VALUE self, VALUE path)
{
  return self;
}

static VALUE bmp_dispose(VALUE self)
{
  return Qnil;
}

static VALUE bmp_was_disposed(VALUE self)
{
  return Qfalse;
}

static VALUE bmp_get_width(VALUE self)
{
  return INT2NUM(0);
}

static VALUE bmp_get_height(VALUE self)
{
  return INT2NUM(0);
}

static VALUE bmp_get_rect(VALUE self)
{
  return rect_new(rb_cRect,
    INT2NUM(0), INT2NUM(0),
    bmp_get_width(self), bmp_get_height(self)
  );
}

static VALUE bmp_blit5(VALUE self,
  VALUE x, VALUE y, VALUE src_bitmap, VALUE src_rect, VALUE opacity)
{
  return Qnil;
}

static VALUE bmp_stretch_blt4(VALUE self,
  VALUE dest_rect, VALUE src_bitmap, VALUE src_rect, VALUE opacity)
{
  return Qnil;
}

static VALUE bmp_fill_rect5(VALUE self,
  VALUE x, VALUE y, VALUE width, VALUE height, VALUE color)
{
  return Qnil;
}

static VALUE bmp_fill_rect2(VALUE self,
  VALUE rect, VALUE color)
{
  return Qnil;
}

static VALUE bmp_gradient_fill_rect7(VALUE self,
  VALUE x, VALUE y, VALUE width, VALUE height,
  VALUE color1, VALUE color2, VALUE vertical)
{
  return Qnil;
}

static VALUE bmp_gradient_fill_rect4(VALUE self,
  VALUE rect, VALUE color1, VALUE color2, VALUE vertical)
{
  return Qnil;
}

static VALUE bmp_clear(VALUE self)
{
  return Qnil;
}

static VALUE bmp_clear_rect4(VALUE self,
  VALUE x, VALUE y, VALUE width, VALUE height)
{
  return Qnil;
}

static VALUE bmp_clear_rect1(VALUE self, VALUE rect)
{
  return Qnil;
}

static VALUE bmp_get_pixel(VALUE self, VALUE x, VALUE y)
{
  return Qnil;
}

static VALUE bmp_set_pixel(VALUE self, VALUE x, VALUE y, VALUE color)
{
  return Qnil;
}

static VALUE bmp_hue_change(VALUE self, VALUE hue)
{
  return Qnil;
}

static VALUE bmp_blur(VALUE self, VALUE blur)
{
  return Qnil;
}

static VALUE bmp_radial_blur(VALUE self, VALUE angle, VALUE division)
{
  return Qnil;
}

static VALUE bmp_draw_text6(VALUE self,
  VALUE x, VALUE y, VALUE width, VALUE height, VALUE str, VALUE align)
{
  return Qnil;
}

static VALUE bmp_draw_text3(VALUE self, VALUE rect, VALUE str, VALUE align)
{
  return Qnil;
}

static VALUE bmp_text_size(VALUE self, VALUE str)
{
  return Qnil;
}

// Property
static VALUE bmp_get_font(VALUE self)
{
  return Qnil;
}

void Init_rgx_bitmap()
{
  rgx_cBitmap = rb_define_class_under(rgx_mRGX, "Bitmap", rb_cObject);

  rb_define_singleton_method(rgx_cBitmap, "new2", bmp_new2, 2);
  rb_define_singleton_method(rgx_cBitmap, "new1", bmp_new1, 1);

  rb_define_method(rgx_cBitmap, "initialize2", bmp_initialize2, 2);
  rb_define_method(rgx_cBitmap, "initialize1", bmp_initialize1, 1);
  //rb_define_method(rgx_cBitmap, "initialize", bmp_initialize, 1);

  rb_define_method(rgx_cBitmap, "dispose", bmp_dispose, 0);
  rb_define_method(rgx_cBitmap, "disposed?", bmp_was_disposed, 0);

  rb_define_method(rgx_cBitmap, "width", bmp_get_width, 0);
  rb_define_method(rgx_cBitmap, "height", bmp_get_height, 0);
  rb_define_method(rgx_cBitmap, "rect", bmp_get_rect, 0);

  rb_define_method(rgx_cBitmap, "blit5", bmp_blit5, 5);
  rb_define_method(rgx_cBitmap, "stretch_blt4", bmp_stretch_blt4, 4);
  rb_define_method(rgx_cBitmap, "fill_rect5", bmp_fill_rect5, 5);
  rb_define_method(rgx_cBitmap, "fill_rect2", bmp_fill_rect2, 2);
  rb_define_method(
    rgx_cBitmap, "gradient_fill_rect7", bmp_gradient_fill_rect7, 7);
  rb_define_method(
    rgx_cBitmap, "gradient_fill_rect4", bmp_gradient_fill_rect4, 4);

  rb_define_method(rgx_cBitmap, "clear", bmp_clear, 0);
  rb_define_method(rgx_cBitmap, "clear_rect4", bmp_clear_rect4, 4);
  rb_define_method(rgx_cBitmap, "clear_rect1", bmp_clear_rect1, 1);

  rb_define_method(rgx_cBitmap, "get_pixel", bmp_get_pixel, 2);
  rb_define_method(rgx_cBitmap, "set_pixel", bmp_set_pixel, 3);

  rb_define_method(rgx_cBitmap, "hue_change", bmp_hue_change, 1);

  rb_define_method(rgx_cBitmap, "blur", bmp_blur, 0);
  rb_define_method(rgx_cBitmap, "radial_blur", bmp_radial_blur, 2);

  rb_define_method(rgx_cBitmap, "draw_text6", bmp_draw_text6, 6);
  rb_define_method(rgx_cBitmap, "draw_text3", bmp_draw_text3, 3);

  rb_define_method(rgx_cBitmap, "text_size", bmp_text_size, 1);

  // Property
  rb_define_method(rgx_cBitmap, "get_font", bmp_get_font, 0);
}
