#ifndef INC_RGX_COLOR

  #define INC_RGX_COLOR

  // Struct
  typedef struct
  {
    double red, green, blue, alpha;
  } RGXColor;

  // Constants
  #define COLOR_LIMIT_FLOOR 0.0
  #define COLOR_LIMIT_CEIL 255.0

  // MACROS
  #define GET_COLOR(self, color)            \
    RGXColor *color;                        \
    Data_Get_Struct(self, RGXColor, color);
  #define CLAMP_COLOR_VALUE(n)                          \
    (MAX(COLOR_LIMIT_FLOOR, MIN(COLOR_LIMIT_CEIL, n)));
  #define ASSIGN_COLOR(col, cred, cgreen, cblue, calpha) \
    col->red   = CLAMP_COLOR_VALUE(cred);                \
    col->green = CLAMP_COLOR_VALUE(cgreen);              \
    col->blue  = CLAMP_COLOR_VALUE(cblue);               \
    col->alpha = CLAMP_COLOR_VALUE(calpha);
  #define ASSIGN_COLOR_FROM_COLOR(trg_color, src_color) \
    trg_color->red   = src_color->red;                  \
    trg_color->green = src_color->green;                \
    trg_color->blue  = src_color->blue;                 \
    trg_color->alpha = src_color->alpha;

  VALUE rb_cColor;
  void Init_rgx_color();

#endif

