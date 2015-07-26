# encoding: utf-8

$: << File.expand_path("../../", __FILE__)

require "bundler/setup"
require "benchmark"
require "jruby-mmap-queues"
require "lib/bench"

# queue_rw.rb
# test queue read/write using N/M consumers/producers
# measure performance of completely writing and reading back all data

Thread.abort_on_exception = true

ITEMS = 2_000_000
END_ITEM = "END"
# PAGE_SIZE = ITEMS * JRubyConf2015::BUFFERS[1].bytesize
# PAGE_SIZE = JRubyConf2015::WRITE_SIZE
PAGE_SIZE = 512 * 1024 * 1024
tps_results = []

puts("=begin")

[[1, 1], [1, 2], [2, 1], [2, 2], [1, 3]].each do |consumers_count, producers_count|
# [[1, 3]].each do |consumers_count, producers_count|

  definitions = [
    {
      :name => "Queue/PageCache",
      :queue => Mmap::Queue.new(:page_handler => Mmap::PageCache.new(File.join(JRubyConf2015::OUT_PATH, "cached_mapped_queue_benchmark-#{consumers_count}-#{producers_count}"), :page_size => PAGE_SIZE, :cache_size => 4))
    },
  ]

  definitions.each do |definition|

    b = Benchmark.bm(50) do |x|
      x.report("consumers=#{consumers_count}, producers=#{producers_count}, #{definition[:name]}") do

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
            ITEMS.times.each{|data| queue.push(buffer)}
          end
        end

        producers.each(&:join)
        consumers.each{queue.push(END_ITEM)}
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
