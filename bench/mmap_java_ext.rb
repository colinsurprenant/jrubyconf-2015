$: << File.expand_path("../../", __FILE__)

require "bundler/setup"
require "jruby-mmap"
require "lib/bench"

path = File.join(JRubyConf2015::OUT_PATH, "mmap.dat")
File.delete(path) rescue nil
out = Mmap::ByteBuffer.new(path, JRubyConf2015::WRITE_SIZE)

# hint OS for best effort to ensure that this buffer content is resident in physical memory
out.load

JRubyConf2015.bench("MMap Java Ext: unsafe", 16) do |write_count, buffer|
  # seek to file start
  out.position = 0

  write_count.times.each do
    out.put_bytes(buffer)
  end
end

JRubyConf2015.bench("MMap Java Ext: safe", 16) do |write_count, buffer|
  # seek to file start
  out.position = 0

  write_count.times.each do
    out.put_bytes_copy(buffer)
  end
end

out.close
