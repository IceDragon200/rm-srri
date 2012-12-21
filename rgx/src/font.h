/*

  font.h
  
 */

#ifndef INC_RGX_FONT

  #define INC_RGX_FONT

  typedef struct 
  {
    VALUE *name;
    int size;
    VALUE color, out_color;
    bool outline, shadow, italic, bold;
  } RGXFont;

  VALUE rgx_cFont;
  
  void Init_rgx_font();

#endif
