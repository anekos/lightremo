#!/usr/bin/ruby

#  Copyright (c) 2012 Yoichi Imai, All rights reserved.
#  
#  Permission is hereby granted, free of charge, to any person obtaining
#  a copy of this software and associated documentation files (the
#  "Software"), to deal in the Software without restriction, including
#  without limitation the rights to use, copy, modify, merge, publish,
#  distribute, sublicense, and/or sell copies of the Software, and to
#  permit persons to whom the Software is furnished to do so, subject to
#  the following conditions:
#  
#  The above copyright notice and this permission notice shall be
#  included in all copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
#  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
#  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
#  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


require 'serialport'

class RemoSta
  Device = '/dev/remosta0'

  CodeBlinkLed = 0x69
  CodeReceive = 0x72
  CodeSend = 0x74
  CodeChannelAYellow = 0x31
  
  SignalLength = 240
  
  CodeLedResult1 = 0x4f
  CodeLedResult2 = 0x59
  
  CodeReceiveResult = 0x59
  CodeReceiveDataStart = 0x53
  CodeReceiveDataEnd = 0x45
  
  CodeSendResult = 0x59
  CodeChannelResult = 0x59
  CodeSendDataResult = 0x45
  
  def initialize
    @sp = SerialPort.new("/dev/remosta0", 115200, 8, 1, SerialPort::NONE)
  end
  
  def request(code)
    @sp.write([code].pack("C"))
    return @sp.read(1).unpack("C")[0]
  end
  
  def recv
    retval = request(CodeBlinkLed)
    raise "BlinkLed error: 0x#{"%x" % retval}" unless retval == CodeLedResult1 || retval == CodeLedResult2
    
    retval = request(CodeReceive)
    raise "Receive error: 0x#{"%x" % retval}" unless retval == CodeReceiveResult
    
    startval = @sp.read(1).unpack("C")[0]
    raise "Receive Start error: 0x#{"%x" % startval}" unless startval == CodeReceiveDataStart
    
    signal = @sp.read(SignalLength)
    
    endval = @sp.read(1).unpack("C")[0]
    raise "Receive End error: 0x#{"%x" % retval}" unless endval == CodeReceiveDataEnd
    
    signal.unpack("H*")
  end
  
  def send(data)
    data_raw = [data].pack("H*")
    
    raise "Signal length is not valid: #{data_raw.length}." unless data_raw.length == SignalLength

    retval = request(CodeBlinkLed)
    raise "Blink LED error: 0x#{"%x" % retval}" unless retval == CodeLedResult1 || retval == CodeLedResult2
    
    retval = request(CodeSend)
    raise "Send error: 0x#{"%x" % retval}" unless retval == CodeSendResult
    
    retval = request(CodeChannelAYellow)
    raise "Channel error: 0x#{"%x" % retval}" unless retval == CodeChannelResult
    
    signal = @sp.write(data_raw)
    retval = @sp.read(1).unpack("C")[0]
    raise "Send Data error: 0x#{"%x" % retval}" unless retval == CodeSendDataResult
  end
end

if __FILE__ == $0 then
  if ARGV.length == 0 then
    $stderr.puts "usage: #$0 recv"
    $stderr.puts "usage: #$0 send hexdata..."
    exit 1
  end
  
  case ARGV[0]
  when "recv"
    $stderr.puts "Receiving."
    rs1 = RemoSta.new
    puts rs1.recv()
    $stderr.puts "Received."
  when "send"
    $stderr.puts "Sending."
    rs1 = RemoSta.new
    rs1.send(ARGV[1])
    $stderr.puts "Sent."
  else
    $stderr.puts "No such subcommand: #{ARGV[0]}"
  end
end

