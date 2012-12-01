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

require 'cgi'
require 'erb'
require 'remosta'

SIGNAL_ON = 'ffffff070000e03fc07f80ff00ff0100f80f00807f0000fc0700e03fc07f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'
SIGNAL_OFF = 'ffffff070000e03fc07f80ff0000f807f00f00807f0000fc07f80f00c07f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f0ffff3f000000fe01fc03f80700c07f80ff0000fc0700c03f807f0000fc0300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000'

cgi = CGI.new

message = nil
case cgi["sw"]
when "off"
  begin
    rs1 = RemoSta.new
    rs1.send(SIGNAL_OFF)
  rescue => ex
    message = ex.to_s
  end
  message = "Light Off" unless message

when "on"
  begin
    rs1 = RemoSta.new
    rs1.send(SIGNAL_ON)
  rescue => ex
    message = ex.to_s
  end
  message = "Light On" unless message
end

cgi.out do
  erb = ERB.new(DATA.read)
  erb.result
end

__END__
<html>
  <head>
    <title>Light Controller</title>
    <style type="text/css">
      input { width: 120px; height: 60px; }
    </style>
  </head>
<body>
<h1>Light Controller</h1>

<div class="message">
  <%= message %>
</div>

<form method="post">
  <input name="sw" type="submit" value="on" />
  <input name="sw" type="submit" value="off" />
</form>

</body>
</html>

