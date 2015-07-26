begin
  require 'ant'
rescue
  puts("error: unable to load Ant, make sure Ant is installed, in your PATH and $ANT_HOME is defined properly")
  puts("\nerror details:\n#{$!}")
  exit(1)
end

require_relative "lib/bench"

task :setup do
  ant.mkdir :dir => "target/classes"
  ant.path :id => 'classpath' do
    fileset :dir => "target/classes"
  end
end

desc "compile Java classes"
task :build => [:setup] do |t, args|
  ant.javac(
    :srcdir => "src/",
    :destdir => JRubyConf2015::CLASSES_DIR,
    :classpathref => "classpath",
    :debug => true,
    :includeantruntime => "no",
    :verbose => false,
    :listfiles => true,
    :source => "1.8",
    :target => "1.8",
  ) {}
end

desc "run benchmarks"
task :bench do
  out = IO.popen("ruby -v")
  puts(out.readlines)
  out.close

  out = IO.popen("java -version")
  puts(out.readlines)
  out.close

  Dir["bench/*.rb"].each do |fname|
    out = IO.popen("ruby #{fname} 2>&1")
    puts(out.readlines)
    out.close
  end
end

desc "produce graphs"
task :graph do
  require "bundler/setup"
  require "gruff"

  g = Gruff::Bar.new(1024)
  g.labels = {
    0 => "1k",
    1 => "4k",
    2 => "16k"
  }
  g.legend_font_size = 10
  g.theme_37signals


  Dir["bench/*.rb"].each do |fname|
    out = IO.popen("ruby #{fname} 2>&1")
    lines = out.read
    puts(lines)
    results = eval("[\n#{lines.chomp}\n]").compact
    # puts("result=#{result.inspect}")
    # puts("header=#{result[:header]}, data=#{result[:results].map(&:to_i)}")
    results.each do |result|
      g.data(result[:header], result[:results].map(&:to_i))
    end
  end

  # add a space "zero" column
  g.data("", [0, 0, 0])

  g.minimum_value = 0
  g.write("t.png")
end
