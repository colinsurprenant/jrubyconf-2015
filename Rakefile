begin
  require 'ant'
rescue
  puts("error: unable to load Ant, make sure Ant is installed, in your PATH and $ANT_HOME is defined properly")
  puts("\nerror details:\n#{$!}")
  exit(1)
end

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
    :destdir => "target/classes/",
    :classpathref => "classpath",
    :debug => true,
    :includeantruntime => "no",
    :verbose => false,
    :listfiles => true,
    :source => "1.8",
    :target => "1.8",
  ) {}
end
