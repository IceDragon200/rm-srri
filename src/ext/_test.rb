require_relative 'chuchu'
require_relative 'table'
require_relative 'rect'
require_relative 'color'
require_relative 'tone'
#require_relative 'color-ext'


def get_table_specs(table)
  "x: #{table.xsize}, y: #{table.ysize}, z: #{table.zsize} datasize: #{table.datasize}"
end

def test_block(name)
  begin
    puts ">> Starting #{name} test"
    yield
    puts ">> #{name} test passed"
  rescue(Exception) => ex
    puts ">> #{name} test failed"
    p ex   
  end
end

test_block("ChuChu") do 
  i = 0
  60.times do 
    i = ChuChu.next_frame(60, i)
    print(i)
    #puts "Frame: #{i}"
  end  
end

test_block("Table") do 
  #puts "Table 0 Test"
  #puts table0 = Table.new()

  puts "Table 1 Test"
  puts table1 = Table.new(40)
  puts get_table_specs(table1)

  puts "Table 2 Test"
  puts table2 = Table.new(60, 60)
  puts get_table_specs(table2)

  puts "Table 3 Test"
  puts table3 = Table.new(100, 100, 4)
  puts get_table_specs(table3)

  puts "Final table test"
  puts "Table 1: #{get_table_specs(table1)}"

  puts "x0: #{table1[0]} x1: #{table1[1]}"
  for x in 0...table1.xsize
    table1[x] = x + 10
  end
  puts "x0: #{table1[0]} x1: #{table1[1]} (should be 10, 11)"

  puts "Table 2: #{get_table_specs(table2)}"
  puts "x0: #{table2[0]} x1: #{table2[1]}"
  str = ""
  for x in 0...table2.xsize
    for y in 0...table2.ysize
      table2[x, y] = x + y * table2.xsize
      #str += "x: #{x} y: #{y} = #{table2[x, y]} \n"
    end  
  end
  #puts str

  puts "Table 3: #{get_table_specs(table3)}"
  str = ""
  for x in 0...table3.xsize
    for y in 0...table3.ysize
      for z in 0...table3.zsize
        table3[x, y, z] = x + (y * table3.xsize) + (z * table3.zsize)
        #str += "x: #{x} y: #{y} z: #{z} = #{table3[x, y, z]} \n"
      end  
    end  
  end
  #puts str

  puts "Extension Tests:"
  puts "clear"
  puts "#{table1[0]}"
  table1.clear()
  puts "#{table1[0]}"

  puts "resize"
  puts table1.xsize
  table1.resize(12)
  puts table1.xsize

  puts "to_a"
  puts "table-size: #{table2.datasize}"
  puts "array-size: #{table2.to_a.size}"

  puts "dimension"
  puts table2.dimension

  puts "replace"
  puts table1.dimension
  table1.replace(table2)
  puts table1.dimension

end  

test_block("Rect") do
  rect = Rect.new(32, 32, 128, 128);
  puts rect
  rect.set()
end
