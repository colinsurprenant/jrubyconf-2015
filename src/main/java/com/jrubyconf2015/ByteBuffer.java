package com.jrubyconf2015;

import java.io.IOException;
import java.io.File;
import java.io.RandomAccessFile;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;

import org.jruby.RubyString;

public class ByteBuffer {
  private final long size;
  private final FileChannel channel;
  private MappedByteBuffer buffer;

  public ByteBuffer(String path, long size)
    throws IOException
  {
    this.size = size;
    File file = new File(path);
    this.channel = new RandomAccessFile(file, "rw").getChannel();
    this.buffer = this.channel.map(FileChannel.MapMode.READ_WRITE, 0, size);
  }

  public void position(int pos)
    throws IOException
  {
    this.buffer.position(pos);
  }

  public void put_bytes_copy(RubyString data) {
    this.buffer.put(data.getByteList().bytes());
  }

  public void put_bytes(RubyString data) {
    this.buffer.put(data.getByteList().unsafeBytes());
  }

  public void put_bytes(String data) {
    this.buffer.put(data.getBytes());
  }

  public void put_bytes(byte[] data) {
    this.buffer.put(data);
  }

  public void close()
    throws IOException
  {
    this.channel.close();
  }
}
