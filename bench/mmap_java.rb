$: << File.expand_path("../../", __FILE__)

require "bundler/setup"
require "java"
require "lib/bench"

$CLASSPATH << JRubyConf2015::CLASSES_DIR unless $CLASSPATH.include?(JRubyConf2015::CLASSES_DIR)

java_import "com.jrubyconf2015.ByteBuffer"
java_import "java.nio.charset.StandardCharsets"

path = File.join(JRubyConf2015::OUT_PATH, "mmap.dat")
File.delete(path) rescue nil
out = ByteBuffer.new(path, JRubyConf2015::WRITE_SIZE)

# hint OS for best effort to ensure that this buffer content is resident in physical memory
out.load

# JRubyConf2015.bench("MMap Java: explicit java-side unboxing") do |write_count, buffer|
#   # seek to file start
#   out.position(0)

#   write_count.times.each do
#     out.put_ruby_string(buffer)
#   end
# end

# JRubyConf2015.bench("MMap Java: explicit ruby-side unboxing") do |write_count, buffer|
#   # seek to file start
#   out.position(0)

#   write_count.times.each do
#     out.put_bytes(buffer.to_java_bytes)
#   end
# end

JRubyConf2015.bench("MMap Java: implicit unboxing default charset") do |write_count, buffer|
  # seek to file start
  out.position(0)

  write_count.times.each do
    out.put_bytes(buffer)
  end
end

JRubyConf2015.bench("MMap Java: implicit unboxing ISO_8859_1") do |write_count, buffer|
  # seek to file start
  out.position(0)

  write_count.times.each do
    # assume data is correctly encoded, use ISO_8859_1 to avoid any transcoding in bytes extraction
    out.put_bytes(buffer, StandardCharsets::ISO_8859_1)
  end
end

out.close



