/*
  table.h

 */
#ifndef INC_RGX_TABLE

  #define INC_RGX_TABLE

  // MACROS
  #define GET_TABLE(self, ptr)                            \
    RGXTable *ptr; Data_Get_Struct(self, RGXTable, ptr)
  #define XYZ_TO_INDEX(x, y, z, xsize, ysize) (x + (y * xsize) + (z * ysize))

  // Forward Decl.
  typedef struct
  {
    int dim, xsize, ysize, zsize, size;
    int *data;
  } RGXTable;

  void Init_rgx_table();

#endif
