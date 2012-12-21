#ifndef INC_RGX_BITMAP
  
  #define INC_RGX_BITMAP

  void Init_rgx_bitmap();

  // Functions
  static VALUE bmp_new1(VALUE klass, VALUE path);
  static VALUE bmp_new2(VALUE klass, VALUE width, VALUE height);

  static VALUE bmp_initialize2(VALUE self, VALUE width, VALUE height);
  static VALUE bmp_initialize1(VALUE self, VALUE path);

  static VALUE bmp_dispose(VALUE self);
  static VALUE bmp_was_disposed(VALUE self);

  static VALUE bmp_get_width(VALUE self);
  static VALUE bmp_get_height(VALUE self);
  static VALUE bmp_get_rect(VALUE self);

  static VALUE bmp_blit5(VALUE self, 
    VALUE x, VALUE y, VALUE src_bitmap, VALUE src_rect, VALUE opacity);
  static VALUE bmp_stretch_blt4(VALUE self, 
    VALUE dest_rect, VALUE src_bitmap, VALUE src_rect, VALUE opacity);
  static VALUE bmp_fill_rect5(VALUE self, 
    VALUE x, VALUE y, VALUE width, VALUE height, VALUE color);
  static VALUE bmp_fill_rect2(VALUE self, 
    VALUE rect, VALUE color);
  static VALUE bmp_gradient_fill_rect7(VALUE self, 
    VALUE x, VALUE y, VALUE width, VALUE height, 
    VALUE color1, VALUE color2, VALUE vertical);
  static VALUE bmp_gradient_fill_rect4(VALUE self,
    VALUE rect, VALUE color1, VALUE color2, VALUE vertical);

  static VALUE bmp_clear(VALUE self);
  static VALUE bmp_clear_rect4(VALUE self, 
    VALUE x, VALUE y, VALUE width, VALUE height);
  static VALUE bmp_clear_rect1(VALUE self, VALUE rect);

  static VALUE bmp_get_pixel(VALUE self, VALUE x, VALUE y);
  static VALUE bmp_set_pixel(VALUE self, VALUE x, VALUE y, VALUE color);

  static VALUE bmp_hue_change(VALUE self, VALUE hue);

  static VALUE bmp_blur(VALUE self, VALUE blur);
  static VALUE bmp_radial_blur(VALUE self, VALUE angle, VALUE division);

  static VALUE bmp_draw_text6(VALUE self, 
    VALUE x, VALUE y, VALUE width, VALUE height, VALUE str, VALUE align);
  static VALUE bmp_draw_text3(VALUE self, VALUE rect, VALUE str, VALUE align);

  static VALUE bmp_text_size(VALUE self, VALUE str);

  // Property
  static VALUE bmp_get_font(VALUE self);

#endif  
