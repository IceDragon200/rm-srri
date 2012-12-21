#ifndef INC_RGX_TONE

  #define INC_RGX_TONE

  // Struct
  typedef struct
  {
    double red, green, blue, grey;
  } RGXTone;

  // Constants
  #define TONE_LIMIT_FLOOR -255.0
  #define TONE_LIMIT_CEIL 255.0

  // MACROS
  #define GET_TONE(self, tone)            \
    RGXTone *tone;                        \
    Data_Get_Struct(self, RGXTone, tone);
  #define CLAMP_TONE_VALUE(n)                          \
    (MAX(TONE_LIMIT_FLOOR, MIN(TONE_LIMIT_CEIL, n)));
  #define ASSIGN_TONE(col, cred, cgreen, cblue, cgrey) \
    col->red   = CLAMP_TONE_VALUE(cred);                \
    col->green = CLAMP_TONE_VALUE(cgreen);              \
    col->blue  = CLAMP_TONE_VALUE(cblue);               \
    col->grey = CLAMP_TONE_VALUE(cgrey);
  #define ASSIGN_TONE_FROM_TONE(trg_tone, src_tone) \
    trg_tone->red   = src_tone->red;                  \
    trg_tone->green = src_tone->green;                \
    trg_tone->blue  = src_tone->blue;                 \
    trg_tone->grey = src_tone->grey;

  VALUE rb_cTone;
  void Init_rgx_tone();

#endif

