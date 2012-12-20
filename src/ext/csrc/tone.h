#ifndef INC_RGX_TONE

  #define INC_RGX_TONE
  
  #include <ruby.h>

  // Constants
  #define TONE_LIMIT_FLOOR -255.0
  #define TONE_LIMIT_CEIL 255.0

  // MACROS
  #define GET_TONE(self, tone) RGXTone *tone; Data_Get_Struct(self, RGXTone, tone)
  #define LIMIT_TONE_DOUBLE(dub) if(dub < TONE_LIMIT_FLOOR) { dub = TONE_LIMIT_FLOOR; } else if(dub > TONE_LIMIT_CEIL) { dub = TONE_LIMIT_CEIL; }

  typedef struct rgx_tone 
  {
    double red, green, blue, grey;
  } RGXTone;

  VALUE rgx_cTone;

  void Init_rgx_tone();

#endif  
