# encoding: utf-8

$: << File.expand_path("../../", __FILE__)

require "bundler/setup"
require "benchmark"
require "jruby-mmap-queues"
require "lib/bench"

# sized_queue_rw.rb
# test queue read/write using N/M consumers/producers
# measure performance of completely writing and reading back all data

Thread.abort_on_exception = true

ITEMS = 500_000
END_ITEM = "END"
PERSIST = true
# PAGE_SIZE = ITEMS * JRubyConf2015::BUFFERS[1].bytesize
PAGE_SIZE = JRubyConf2015::WRITE_SIZE

tps_results = []

puts("=begin")

[[1, 1], [1, 2], [2, 1], [2, 2]].each do |consumers_count, producers_count|

  # puts("consumers=#{consumers_count}, producers=#{producers_count}")

  definitions = [
    {
      :name => "SizedQueue/PageCache",
      :queue => Mmap::SizedQueue.new(20, :page_handler => Mmap::PageCache.new(File.join(JRubyConf2015::OUT_PATH, "cached_mapped_queue_benchmark-#{consumers_count}-#{producers_count}"), :page_size => PAGE_SIZE, :cache_size => 2))
    },
    {
      :name => "SizedQueue/SinglePage",
      :queue => Mmap::SizedQueue.new(20, :page_handler => Mmap::SinglePage.new(File.join(JRubyConf2015::OUT_PATH, "single_mapped_queue_benchmark-#{consumers_count}-#{producers_count}"), :page_size => PAGE_SIZE))
    }
  ]

  definitions.each do |definition|

    b = Benchmark.bm(50) do |x|
      x.report("consumers=#{consumers_count}, producers=#{producers_count}, #{definition[:name]}") do

        # print("  #{definition[:name]}...")
        queue = definition[:queue]
        queue.clear

        consumers = consumers_count.times.map do
          Thread.new do
            while true
              data = queue.pop
              break if data == END_ITEM
            end
          end
        end

        producers = producers_count.times.map do
          Thread.new do
            buffer = JRubyConf2015::BUFFERS[1]
            ITEMS.times.each{|data| queue.push(buffer, PERSIST)}
          end
        end

        producers.each(&:join)
        consumers.each{queue.push(END_ITEM, PERSIST)}
        consumers.each(&:join)

        queue.purge
      end
    end

    tps = (ITEMS * producers_count) / b.first.real
    rate = (tps * JRubyConf2015::BUFFERS[1].bytesize) / (1024 * 1024)
    tps_results << "consumers=#{consumers_count}, producers=#{producers_count}, #{definition[:name]} #{tps.to_i} TPS, #{rate.to_i}MB/s"
  end
end

tps_results.each do |result|
  puts(result)
end

puts("=end")
