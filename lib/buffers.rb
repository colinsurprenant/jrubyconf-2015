# encoding: utf-8

module JRubyConf2015
  extend self

  BUFFER_SIZES = [1, 4, 16]
  BUFFERS = BUFFER_SIZES.inject({}){|r, size| r[size] = ("abcdefg\n" * ( size * 1024 / 8)).force_encoding(Encoding::ASCII_8BIT); r}

  # safety check for byte sizes
  BUFFER_SIZES.each do |size|
    raise("invalid size for #{size * 1024}B != #{BUFFERS.fetch(size).bytesize}B") if BUFFERS.fetch(size).bytesize != size * 1024
  end

  # I previously had tests with Java String and Java byte[] but these are not realistically usable from a JRuby
  # context so I removed them.
  #
  # JAVA_STRING_1K = Java::JavaLang::String.new(STRING_1K)
  # BYTES_1K = STRING_1K.to_java_bytes

  REPORT_WIDTH = 50
  WRITE_SIZE = 2 * 1000 * 1024 * 1024
  WRITE_SIZE_MB = 2 * 1000
  REPEAT = 4
  OUT_PATH = File.expand_path("../out", __FILE__)

  Dir.mkdir(OUT_PATH) unless File.directory?(OUT_PATH)


  def bench(header, repeat = REPEAT, &block)

    # aggregate results for all defined buffer sizes
    results = BUFFER_SIZES.map do |buffer_kb_size|

      b = Benchmark.bmbm(REPORT_WIDTH) do |x|

        # grab a buffer and compute how many times we need to write it to reach WRITE_SIZE
        buffer = BUFFERS.fetch(buffer_kb_size)
        write_count = WRITE_SIZE / buffer.bytesize

        x.report("#{header} #{repeat} x #{write_count} x #{buffer_kb_size}KB (#{repeat}x#{write_count * buffer.bytesize}B)") do

          # execute repeat times out writing out write_count times the buffer
          # in other words execute repeat times writing out a WRITE_SIZE file
          repeat.times.each do
            yield(write_count, buffer)
          end
        end
      end

      # use "real" or wallclock time since we are benchmarking IO we need to account
      # for the IO wait time which is not reprensented in user/system times whicb
      # are CPU only times
      [buffer_kb_size, b.first.real]
    end

    puts("\n#{header} rates")
    results.each do |size, real|
      rate = (repeat * WRITE_SIZE_MB) / real
      puts("> #{size}KB rate #{"%.2f" % rate}MB/sec")
    end
  end
end