package com.jrubyconf2015;

import java.io.IOException;
import java.io.File;
import java.io.RandomAccessFile;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.StandardCharsets;
import java.nio.charset.Charset;

import org.jruby.RubyString;
import org.jruby.util.ByteList;


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

  public void load()
  {
    this.buffer.load();
  }

  public void put_ruby_string_copy(RubyString data) {
    this.buffer.put(data.getByteList().bytes());
  }

  public void put_ruby_string(RubyString data) {
    ByteList byteList = data.getByteList();
    this.buffer.put(byteList.unsafeBytes(), 0, byteList.length());
  }

  public void put_bytes(String data) {
    byte[] bytes = data.getBytes();
    this.buffer.put(bytes, 0, bytes.length);
  }

  public void put_bytes(String data, Charset charset) {
    byte[] bytes = data.getBytes(charset);
    this.buffer.put(bytes, 0, bytes.length);
  }

  public void put_bytes(byte[] data) {
    this.buffer.put(data, 0, data.length);
  }

  public void close()
    throws IOException
  {
    this.channel.close();
  }
}
