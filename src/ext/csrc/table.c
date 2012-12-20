/*

  table.c

  rgx_Table

  by IceDragon
  dc 18/11/2012
  dm 18/11/2012

  TODO:
    Add error handling.

 */
#include "rgx.h"

#define STRICT_TABLE false

#if STRICT_TABLE
  #define UNSTRICT_PROTECT
#endif

#if !STRICT_TABLE
  #define UNSTRICT_PROTECT \
    if(x >= xsize || y >= ysize || z >= zsize || index >= size) { \
      return INT2FIX(0);                                          \
    }
#endif

VALUE rb_cTable = Qnil;

static void
Table_free(RGXTable* table)
{
  free(table->data);
  table->data = NULL;
  free(table);
}

static VALUE
Table_alloc(VALUE klass)
{
  RGXTable* table = ALLOC(RGXTable);
  table->dim         = 0;
  table->xsize       = 1;
  table->ysize       = 1;
  table->zsize       = 1;
  table->size        = 1;
  table->data        = NULL;
  return Data_Wrap_Struct(klass, 0, Table_free, table);
}

static void
tb_check_size(int xsize, int ysize, int zsize)
{
  if (xsize < 1) {
    rb_raise(rb_eArgError, "xsize less than or equal to 0");
  }
  if (ysize < 1) {
    rb_raise(rb_eArgError, "ysize less than or equal to 0");
  }
  if (zsize < 1) {
    rb_raise(rb_eArgError, "zsize less than or equal to 0");
  }
}

static void
tb_check_index(int x, int y, int z, int xsize, int ysize, int zsize)
{
  if (x < 0) {
    rb_raise(rb_eArgError, "x less than or equal to 0");
  }
  if (y < 0) {
    rb_raise(rb_eArgError, "y less than or equal to 0");
  }
  if (z < 0) {
    rb_raise(rb_eArgError, "z less than or equal to 0");
  }
  if (STRICT_TABLE) {
    if (x >= xsize) {
      rb_raise(rb_eArgError, "x greater than or equal to xsize");
    }
    if (y >= ysize) {
      rb_raise(rb_eArgError, "y greater than or equal to ysize");
    }
    if (z >= zsize) {
      rb_raise(rb_eArgError, "z greater than or equal to zsize");
    }
  }
}

#define TABLE_SIZE_ARGV(xsize, ysize, zsize, rbXsize, rbYsize, rbZsize) \
  volatile VALUE rbXsize, rbYsize, rbZsize;   \
  rb_scan_args(argc, argv, "12",              \
               &rbXsize, &rbYsize, &rbZsize); \
  if(argc == 1)                               \
  {                                           \
    rbYsize = INT2FIX(1);                     \
    rbZsize = INT2FIX(1);                     \
  }                                           \
  else if(argc == 2)                          \
  {                                           \
    rbZsize = INT2FIX(1);                     \
  }                                           \
  const int xsize = FIX2INT(rbXsize);         \
  const int ysize = FIX2INT(rbYsize);         \
  const int zsize = FIX2INT(rbZsize);         \
  tb_check_size(xsize, ysize, zsize);


// Get
static VALUE
rb_tb_get(int argc, VALUE* argv, VALUE self)
{
  GET_TABLE(self, source_tb);

  volatile VALUE rbX, rbY, rbZ;
  rb_scan_args(argc, argv, "12",
               &rbX, &rbY, &rbZ);

  if(argc == 1)
  {
    rbY = INT2FIX(0);
    rbZ = INT2FIX(0);
  }
  else if(argc == 2)
  {
    rbZ = INT2FIX(0);
  }
  const int x = FIX2INT(rbX);
  const int y = FIX2INT(rbY);
  const int z = FIX2INT(rbZ);

  const int xsize = source_tb->xsize;
  const int ysize = source_tb->ysize;
  const int zsize = source_tb->zsize;
  const int size = source_tb->size;

  tb_check_index(x, y, z, xsize, ysize, zsize);

  int index = XYZ_TO_INDEX(x, y, z, xsize, ysize);

  UNSTRICT_PROTECT;

  return INT2FIX( source_tb->data[index]);
}

// Set
static VALUE
rb_tb_set(int argc, VALUE* argv, VALUE self)
{
  GET_TABLE(self, source_tb);

  volatile VALUE rbX, rbY, rbZ, rbValue;

  rb_scan_args(argc, argv, "22",
               &rbX, &rbY, &rbZ, &rbValue);

  if(argc == 2)
  {
    rbValue = rbY;
    rbY = INT2FIX(0);
    rbZ = INT2FIX(0);
  }
  else if(argc == 3)
  {
    rbValue = rbZ;
    rbZ = INT2FIX(0);
  }
  const int x = FIX2INT(rbX);
  const int y = FIX2INT(rbY);
  const int z = FIX2INT(rbZ);
  const int value = FIX2INT(rbValue);

  const int xsize = source_tb->xsize;
  const int ysize = source_tb->ysize;
  const int zsize = source_tb->zsize;
  const int size = source_tb->size;

  tb_check_index(x, y, z, xsize, ysize, zsize);

  int index = XYZ_TO_INDEX(x, y, z, xsize, ysize);

  UNSTRICT_PROTECT;

  source_tb->data[index] = value;
  return INT2FIX(source_tb->data[index]);
}

// Ruby Interface
// Resize
static VALUE
rb_tb_resize(int argc, VALUE* argv, VALUE self)
{
  TABLE_SIZE_ARGV(xsize, ysize, zsize, rbXsize, rbYsize, rbZsize);
  GET_TABLE(self, source_tb);

  const int orgsize = source_tb->size;
  const int size = xsize * ysize * zsize;

  int *orgtable = source_tb->data;
  int *temp = realloc(orgtable, size * sizeof(int));

  if(temp != NULL)
  {
    // table has expanded : Pad with 0s
    if(orgsize < size)
    {
      int i;
      for(i = orgsize; i < size; i++)
      {
        temp[i] = 0;
      }
    }
    // source_tb->dim
    source_tb->xsize = xsize;
    source_tb->ysize = ysize;
    source_tb->zsize = zsize;
    source_tb->size  = size;
    source_tb->data = temp;
  }
  else
  {
    free(orgtable);
    rb_raise(rb_eException, "Table could not be resized");
    return Qnil;
  }
  return self;
}

static VALUE rb_tb_datasize(VALUE self)
{
  GET_TABLE(self, source_tb);
  return INT2FIX(source_tb->size);
}

// Dimension
static VALUE rb_tb_dim(VALUE self)
{
  GET_TABLE(self, source_tb);
  return INT2FIX(source_tb->dim);
}

// nsize
static VALUE rb_tb_xsize(VALUE self)
{
  GET_TABLE(self, source_tb);
  return INT2FIX(source_tb->xsize);
}

static VALUE rb_tb_ysize(VALUE self)
{
  GET_TABLE(self, source_tb);
  return INT2FIX(source_tb->ysize);
}

static VALUE rb_tb_zsize(VALUE self)
{
  GET_TABLE(self, source_tb);
  return INT2FIX(source_tb->zsize);
}

// #initialize
static VALUE
rb_tb_initialize(int argc, VALUE* argv, VALUE self)
{
  TABLE_SIZE_ARGV(xsize, ysize, zsize, rbXsize, rbYsize, rbZsize);
  GET_TABLE(self, table);

  const int size = xsize * ysize * zsize;

  table->dim   = argc;
  table->xsize = xsize;
  table->ysize = ysize;
  table->zsize = zsize;
  table->size  = size;
  table->data  = ALLOC_N(int, size);
  MEMZERO(table->data, int, size);

  return Qnil;
}

static VALUE
rb_tb_to_a(VALUE self)
{
  GET_TABLE(self, source_tb);

  int size = source_tb->size;

  int* tb_data = source_tb->data;

  VALUE ary = rb_ary_new();

  int i;
  for(i = 0; i < size; i++){
    rb_ary_push(ary, INT2FIX(tb_data[i]));
  }

  return ary;
}

static VALUE
rb_tb_clear(VALUE self)
{
  GET_TABLE(self, source_tb);

  source_tb->data = ALLOC_N(int, source_tb->size);

  return self;
}

static VALUE
rb_tb_replace(VALUE self, VALUE rb_tb)
{
  GET_TABLE(self, target_tb);
  GET_TABLE(rb_tb, source_tb);

  int xs = source_tb->xsize;
  int ys = source_tb->ysize;
  int zs = source_tb->zsize;

  int size = source_tb->size;

  //rb_tb_resize(3,
  //             (VALUE*) {INT2NUM(xs), INT2NUM(ys), INT2NUM(zs)}, self);

  target_tb->dim = source_tb->dim;

  int *tb_data = target_tb->data;
  int *stb_data = source_tb->data;

  int i;
  for(i = 0; i < size; i++)
  {
    tb_data[i] = stb_data[i];
  }

  return self;
}

static VALUE
rb_tb_dump(VALUE self, VALUE depth)
{
/*
  def _dump(d = 0)
    s = [@dim, @xsize, @ysize, @zsize, @xsize * @ysize * @zsize].pack('LLLLL')
    a = []
    ta = []
    @data.each do |d|
      if d.is_a?(Fixnum) && (d < 32768 && d >= 0)
        s << [d].pack("S")
      else
        s << [ta].pack("S#{ta.size}")
        ni = a.size
        a << d
        s << [0x8000|ni].pack("S")
      end
    end
    if a.size > 0
      s << Marshal.dump(a)
    end
    s
  end
*/
  // dim, xsize, ysize, zsize, size, data
  GET_TABLE(self, table);

  volatile VALUE header_ary = rb_ary_new();
  rb_ary_push(header_ary, INT2FIX(table->dim));
  rb_ary_push(header_ary, INT2FIX(table->xsize));
  rb_ary_push(header_ary, INT2FIX(table->ysize));
  rb_ary_push(header_ary, INT2FIX(table->zsize));
  rb_ary_push(header_ary, INT2FIX(table->size));

  const ID sym_pack = rb_intern("pack");

  VALUE header_str = rb_funcall(
    header_ary, sym_pack, 1, rb_str_new2("L5\0"));

  int i;
  int size = table->size;
  int* data = table->data;
  VALUE a  = rb_ary_new();
  VALUE ta = rb_ary_new();
  volatile VALUE vstr;

  for(i = 0; i < size; i++)
  {
    int d = data[i];
    if(d <= 0x7FFF && d >= 0)
    {
      VALUE ary = rb_ary_new();
      rb_ary_push(ary, INT2FIX(d));

      vstr = rb_funcall(
        ary, sym_pack, 1, rb_str_new2("S\0"));

      rb_str_concat(header_str, vstr);
    }
    else
    {
      VALUE ary = rb_ary_new();
      VALUE ary2 = rb_ary_new();
      rb_ary_push(ary, ta);

      vstr = rb_funcall(ary, sym_pack, 1, rb_str_new2("S0\0"));
      int ni = NUM2INT(rb_funcall(a, rb_intern("size"), 0));
      rb_ary_push(a, INT2FIX(d));

      rb_ary_push(ary2, INT2FIX(0x8000 | ni));

      vstr = rb_funcall(ary2, sym_pack, 1, rb_str_new2("S\0"));

      rb_str_concat(header_str, vstr);
    }
  }

  int sz = NUM2INT(rb_funcall(a, rb_intern("size"), 0));

  if(sz > 0)
  {
    vstr = rb_marshal_dump(a, Qnil);
    rb_str_concat(header_str, vstr);
  }

  return header_str;
}

static VALUE
rb_tb_load(VALUE klass, VALUE rbStr)
{
/*
  def self._load(s)
    size, nx, ny, nz, items = *s[0, 20].unpack('LLLLL')
    t = Table.new(*[nx, ny, nz][0,size])
    d = s[20, items * 2].unpack("S#{items}")
    if s.length > (20+items*2)
      a = Marshal.load(s[(20+items*2)...s.length])
      d.collect! do |i|
        if i & 0x8000 == 0x8000
          a[i&~0x8000]
        else
          i
        end
      end
    end
    t.data = d
    t
  end
*/
  return Qnil;
}

/*
static VALUE
rb_tb_ary_to_table(int argc, VALUE* argv, VALUE klass)
{
  VALUE rbAry, rbDim, rbXsize, rbYsize, rbXsize;
  rb_scan_args(argc, argv, "50",
               rbAry, rbDim, rbXsize, rbYsize, rbZsize);

  rb_
  return
}
*/

static VALUE
rb_tb_ary_to_data(VALUE self, VALUE ary)
{
  GET_TABLE(self, table);

  int i;
  int size = table->size;

  for(i = 0; i < size; i++)
  {
    table->data[i] = FIX2INT(rb_ary_pop(ary));
  }

  return self;
}

void Init_rgx_table()
{
  rb_cTable = rb_define_class_under(rgx_mRGX, "Table", rb_cObject);
  rb_define_singleton_method(rb_cTable, "_load", rb_tb_load, 1);

  rb_define_alloc_func(rb_cTable, Table_alloc);

  rb_define_method(rb_cTable, "initialize", rb_tb_initialize, -1);

  rb_define_method(rb_cTable, "xsize", rb_tb_xsize, 0);
  rb_define_method(rb_cTable, "ysize", rb_tb_ysize, 0);
  rb_define_method(rb_cTable, "zsize", rb_tb_zsize, 0);

  rb_define_method(rb_cTable, "[]", rb_tb_get, -1);
  rb_define_method(rb_cTable, "[]=", rb_tb_set, -1);
  rb_define_method(rb_cTable, "resize", rb_tb_resize, -1);

  // Extended
  rb_define_method(rb_cTable, "clear", rb_tb_clear, 0);
  rb_define_method(rb_cTable, "dimension", rb_tb_dim, 0);
  rb_define_method(rb_cTable, "datasize", rb_tb_datasize, 0);

  rb_define_method(rb_cTable, "to_a", rb_tb_to_a, 0);

  rb_define_method(rb_cTable, "_dump", rb_tb_dump, 1);
  rb_define_method(rb_cTable, "write_ary_to_data", rb_tb_ary_to_data, 1);
  //rb_define_method(rb_cTable, "replace", rb_tb_replace, 1);
}
