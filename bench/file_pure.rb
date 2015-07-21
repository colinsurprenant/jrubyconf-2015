require "bundler/setup"
require "benchmark"
require_relative "buffers"

# create file once before all tests
path = File.join(JRubyConf2015::OUT_PATH, "ruby_file.dat")
File.delete(path) rescue nil
out = File.new(path, "w+")

# pre allocate file, for the sake of mimic'ing mmap behaviour
(JRubyConf2015::WRITE_SIZE / JRubyConf2015::BUFFERS[16].bytesize).times.each do
  out.write(JRubyConf2015::BUFFERS[16])
end

JRubyConf2015.bench("Ruby File IO") do |write_count, buffer|
  # seek to file start
  out.seek(0)

  write_count.times.each do
    out.write(buffer)
  end
end


# non block not very interesting since File IO does not do non blocking
# see https://github.com/jruby/jruby/blob/master/core/src/main/java/org/jruby/util/io/ChannelStream.java#L1306-L1324

# JRubyConf2015.bench("Ruby File IO non-block") do |write_count, buffer|
#   # seek to file start
#   out.seek(0)
#   required = buffer.bytesize

#   write_count.times.each do
#     result = out.write_nonblock(buffer)
#     raise("invalid result size") if result != required
#   end
# end


# syswrite not very interesting, slower for 1k, about the same for 4/16k

# JRubyConf2015.bench("Ruby File IO syswrite") do |write_count, buffer|
#   # seek to file start
#   out.seek(0)

#   write_count.times.each do
#     out.syswrite(buffer)
#   end
# end

out.close
