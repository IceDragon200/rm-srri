#ifndef INC_RGX_RECT

  #define INC_RGX_RECT

  // MACROS
  #define GET_RECT(self, rect) RGXRect *rect; Data_Get_Struct(self, RGXRect, rect)

  VALUE rect_new(VALUE klass, VALUE sx, VALUE sy, VALUE swidth, VALUE sheight);

  VALUE rb_cRect;

  // Struct
  typedef struct
  {
    int x, y, width, height;
  } RGXRect ;

  // static VALUE
  void Init_rgx_rect();

#endif
