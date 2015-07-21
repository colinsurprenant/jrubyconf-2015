require "java"

java_import "java.io.RandomAccessFile"
java_import "java.nio.channels.FileChannel"

module MmapPure
  class ByteBuffer
    def initialize(path, size)
      @channel = RandomAccessFile.new(Java::JavaIo::File.new(path), "rw").get_channel
      @buffer = @channel.map(FileChannel::MapMode::READ_WRITE, 0, size)
    end

    def load
      @buffer.load
    end

    def position=(pos)
      @buffer.position(pos)
    end

    def put_bytes(data)
      @buffer.put(data.to_java_bytes, 0, data.bytesize)
    end

    def close
      @channel.close
    end
  end
end
