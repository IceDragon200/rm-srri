require '../local.rb'
# Table 1 Initialize
p t1 = Table.new(20)
p t1[1]

# Table 2 Initialize
p t2 = Table.new(20, 40)
p t2[1, 2]

# Table 3 Initialize
p t3 = Table.new(120, 120, 4)
p t3[1, 2, 3]

p table = Table.new(120, 120, 4).resize(24, 8, 2)
p table.xsize
p table.ysize
p table.zsize
p table.datasize

puts "Table set test 1"
table.clear
for x in 0...table.xsize
  for y in 0...table.ysize
    for z in 0...table.zsize
      table[x, y, z] = 0xFFFF
    end
  end
end

puts "Table set test after duplication"
table = table.dup
table.clear

for x in 0...table.xsize
  for y in 0...table.ysize
    for z in 0...table.zsize
      table[x, y, z] = 0xFFFF
    end
  end
end

puts "Table set test after dump: OOR test"
table = Marshal.load(Marshal.dump(table))
table.clear

for x in 0..(table.xsize + 12)
  for y in 0..(table.ysize + 12)
    for z in 0..(table.zsize + 12)
      table[x, y, z] = 0xFFFF
    end
  end
end

tables = 200.times.collect do
  [Table.new(10), Table.new(50, 4), Table.new(60, 80, 80)]
end

# Rect Duplication
p table1 = Table.new(23, 23, 4)
p table2 = table1.clone
p table1.datasize
p table1.to_a.size

p Marshal.load(Marshal.dump(table2))

tables = nil
table1 = nil
table2 = nil
table = nil
