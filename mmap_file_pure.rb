require "bundler/setup"
require "benchmark"
require_relative "buffers"
require_relative "mmap_pure"

path = File.join(JRubyConf2015::OUT_PATH, "mmap_file_pure.dat")
File.delete(path) rescue nil
out = MmapPure::ByteBuffer.new(path, JRubyConf2015::WRITE_SIZE)

# hint OS for best effort to ensure that this buffer content is resident in physical memory
out.load

JRubyConf2015.bench("Pure MMap IO") do |write_count, buffer|
  # seek to file start
  out.position = 0

  write_count.times.each do
    out.put_bytes(buffer)
  end
end

out.close
