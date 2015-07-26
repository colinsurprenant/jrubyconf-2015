# encoding: utf-8

$: << File.expand_path("../../", __FILE__)

require "bundler/setup"
require "benchmark"
require "jruby-mmap-queues"
require "lib/bench"

# queue_wo.rb
# test queue write using N producers
# measure performance of only writing all data

Thread.abort_on_exception = true

ITEMS = 2_000_000
END_ITEM = "END"
# PAGE_SIZE = ITEMS * JRubyConf2015::BUFFERS[1].bytesize
PAGE_SIZE = JRubyConf2015::WRITE_SIZE

tps_results = []

puts("=begin")

[1, 2].each do |producers_count|

  definitions = [
    {
      :name => "Queue/PageCache",
      :queue => Mmap::Queue.new(:page_handler => Mmap::PageCache.new(File.join(JRubyConf2015::OUT_PATH, "cached_mapped_queue_benchmark-#{producers_count}"), :page_size => PAGE_SIZE, :cache_size => 1))
    },
  ]

  definitions.each do |definition|

    b = Benchmark.bm(50) do |x|
      x.report("producers=#{producers_count}, #{definition[:name]}") do

        queue = definition[:queue]
        queue.clear

        producers = producers_count.times.map do
          Thread.new do
            buffer = JRubyConf2015::BUFFERS[1]
            ITEMS.times.each{|data| queue.push(buffer)}
          end
        end

        producers.each(&:join)
        queue.purge
      end
    end

    tps = (ITEMS * producers_count) / b.first.real
    rate = (tps * JRubyConf2015::BUFFERS[1].bytesize) / (1024 * 1024)
    tps_results << "producers=#{producers_count}, #{definition[:name]} #{tps.to_i} TPS, #{rate.to_i}MB/s"
  end
end

tps_results.each do |result|
  puts(result)
end

puts("=end")
