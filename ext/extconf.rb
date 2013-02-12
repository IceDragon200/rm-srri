require 'mkmf'
src_dir = "./src"

$CFLAGS += " -std=c99"

create_makefile("rmsrri", src_dir)
