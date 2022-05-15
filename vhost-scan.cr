# /*
#  * @Author: YZ.Huang
#  * @Date: 2022-05-13 09:40:31
#  * @Ver: v0.1
#  * @Last Modified by: 黄耘峥
#  * @Last Modified time: 2022-05-13 10:50:57
#  */
require "http/client"
require "crypto/bcrypt"
require "base64"
require "yaml"

puts("██╗   ██╗██╗  ██╗ ██████╗ ███████╗████████╗   ███████╗ ██████╗ █████╗ ███╗   ██╗
██║   ██║██║  ██║██╔═══██╗██╔════╝╚══██╔══╝   ██╔════╝██╔════╝██╔══██╗████╗  ██║
██║   ██║███████║██║   ██║███████╗   ██║█████╗███████╗██║     ███████║██╔██╗ ██║
╚██╗ ██╔╝██╔══██║██║   ██║╚════██║   ██║╚════╝╚════██║██║     ██╔══██║██║╚██╗██║
 ╚████╔╝ ██║  ██║╚██████╔╝███████║   ██║      ███████║╚██████╗██║  ██║██║ ╚████║
  ╚═══╝  ╚═╝  ╚═╝ ╚═════╝ ╚══════╝   ╚═╝      ╚══════╝ ╚═════╝╚═╝  ╚═╝╚═╝  ╚═══╝

by YZ.Huang
v0.1
2022
Use vhost-scan.yml Configure
####################################
")

# 爆破之前按需修改源码
# 然后运行 crystal.exe run vhost-scan.cr
# 线程数
THREAD          = 3
# 主机名
URI_HOST        = "127.0.0.1"
# WEB端口
URI_PORT        = "80"
# WEB资源路径,可设置成其他文件
URI_GET_IP_PATH = "/"
# User-Agent
USER_AGETN      = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36 Edg/100.0.1185.50"
# 连接超时时间, 秒
CONNECT_TIMEOUT = 5
# 请求方法
METHOD          = "GET"

# 没有找到有效站点的返回状态码，可以留空
FLAG_NOFOUND_STATUS_CODE = 304
# 找到有效站点的返回状态码，可以留空
FLAG_FOUND_STATUS_CODE   = 200

# 没有找到有效站点时候，HTTP Response 包含的以下内容，可以为空
FLAG_NOFOUND = "phpstudy安装目录/www/站点域名/</dd>"
# 找到有效站点时候，HTTP Response 包含的以下内容，可以为空
FLAG_FOUND   = "test crystal on phpstudy"

VHOSTNAME_FILE = "vhost_name.dict"
VHOSTNAME_DICT = File.read_lines(VHOSTNAME_FILE)
# pp VHOSTNAME_DICT
# exit

# TODO
# 按返回内容长度判断是否成功
FLAG_NOFUND_LEN = nil
FLAG_FUND_LEN   = nil

# -----------------------------------------------------------------------

# CONFIG={"THREAD"=>3, "URI_HOST"=>"127.0.0.1", "URI_PORT"=>80, "URI_GET_IP_PATH"=>"/", "USER_AGETN"=>"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/537.36 Edg/100.0.1185.50", "CONNECT_TIMEOUT"=>"5", "METHOD"=>"GET", "FLAG_NOFOUND_STATUS_CODE"=>"304", "FLAG_FOUND_STATUS_CODE"=>"200", "FLAG_NOFOUND"=>"phpstudy安装目录/www/站点域名/</dd>", "FLAG_FOUND"=>"test crystal on phpstudy", "FLAG_NOFUND_LEN"=>nil, "FLAG_FUND_LEN"=>nil,}
# File.open("config.yml", "w") { |f| YAML.dump(CONFIG, f) }
# CONFIG=YAML.parse(File.read("./config2.yml"))

# TODO
# 添加resp返回内容打印输出，开关

# TODO
# 添加resp返回内容 title 打印输出，开关

# TODO
# 添加路径字典(/robots.txt index.htm index.html index.php index.jsp site.xml 等)

# TODO
# 匹配多种状态才证明存在 FLAG_FOUND || (!FLAG_NOFOUND_STATUS_CODE 或者 FLAG_FOUND_STATUS_CODE)
# 匹配多种状态证明不存在

def check_host(method, ip, uri_port, uri_get_ip_path, timeout, user_agent, host_name)
  # puts FLAG_FOUND
  # puts FLAG_NOFOUND_STATUS_CODE
  # puts FLAG_FOUND_STATUS_CODE

  client = HTTP::Client.new(ip, uri_port)
  client.read_timeout = client.connect_timeout = timeout
  begin
    response = client.exec(method, uri_get_ip_path, headers: HTTP::Headers{"host" => host_name,"User-Agent"=>"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/101.0.4951.54 Safari/537.36 Edg/101.0.1210.39","Accept"=>"text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9","Accept-Encoding"=>"gzip, deflate","Accept-Language"=>"zh-CN,zh;q=0.9,en;q=0.8,en-GB;q=0.7,en-US;q=0.6","Cache-Control"=>"max-age=0","Dnt"=>"1","If-Modified-Since"=>"Tue, 03 Sep 2019 06:30:48 GMT","If-None-Match"=>"\"903-591a03aa15600\"","Upgrade-Insecure-Requests"=>"1"})
    # response = client.exec(method, uri_get_ip_path, headers: HTTP::Headers{"User-Agent" => user_agent, "host" => host_name})

    # pp response
    # pp response.status_code
    resp = response.body
    # puts "resp ok?=>"
    # pp resp
    # pp "==========="

    # 进入返回状态码判断环节
    # pp !FLAG_FOUND_STATUS_CODE.nil?
    # pp !FLAG_NOFOUND_STATUS_CODE.nil?
    # pp response.status_code
    if !FLAG_FOUND_STATUS_CODE.nil? || !FLAG_NOFOUND_STATUS_CODE.nil?
      # puts "Fucking Status Code Error!!!"
      if !FLAG_FOUND_STATUS_CODE.nil? && FLAG_FOUND_STATUS_CODE == response.status_code
        puts "Found=>[" + host_name + "]=> " + response.status_code.to_s
        return true
      elsif !FLAG_NOFOUND_STATUS_CODE.nil? && FLAG_NOFOUND_STATUS_CODE == response.status_code
        return false
      end
      # 发现意料之外的内容，判定为发现新的信息，所以返回true
      puts "Found=>[" + host_name + "]=> " + response.status_code.to_s + " Need Check By Manual"
      return true
    end

    # pp "+++++++++++++"
    # # pp resp.nil?
    # resp = response.body_io.gets # => "<!doctype html>"
    # 进入返回内容判断环节
    if !FLAG_FOUND.nil? || !FLAG_NOFOUND.nil?
      if resp.nil?
        puts "请求失败=>Getip 出错"
        resp
      else
        # pp FLAG_FOUND.nil?
        if !FLAG_FOUND.nil? && resp.includes?(FLAG_FOUND.to_s)
          puts "Found=>[" + host_name + "]"
          return true
        elsif !FLAG_NOFOUND.nil? && resp.includes?(FLAG_NOFOUND.to_s)
          # puts "Not Found=>[" + host_name + "]"
          # 发现存在"不存在"的标识， 判定为失败
          return false
        end

        # 发现意料之外的内容，判定为发现新的信息，所以返回true
        puts "Found=>[" + host_name + "] Need Check By Manual"
        return true
      end
    end
  rescue IO::TimeoutError
    puts "请求失败=>Getip timeout!"
  rescue NilAssertionError
    puts "请求失败=>Response is Nil!"
  rescue ex
    puts "请求失败=>" + ex.message.to_s
  end
  # pp "resp=>[" + resp.to_s + "]"
  client.close
  resp
end

# check_host(METHOD, URI_HOST, URI_PORT, URI_GET_IP_PATH, CONNECT_TIMEOUT, USER_AGETN, "hack.cr")
# check_host(METHOD, URI_HOST, URI_PORT, URI_GET_IP_PATH, CONNECT_TIMEOUT, USER_AGETN, "baidu.com")
# check_host(METHOD, URI_HOST, URI_PORT, URI_GET_IP_PATH, CONNECT_TIMEOUT, USER_AGETN, "test.cr")

# VHOSTNAME_DICT = ["baidu888.com", "test1.no", "fuckingccp.cn", "hack.cr", "test.cr", "google.com", "1.com", "baid.com", "google.com", "yahoo.com", "bing.com"]
# VHOSTNAME_DICT = ["baidu888.com", "test1.no"]

module Counter
  @@times = 0
  property times2 : Int32 = 0

  def self.set(num : Int32)
    @@times = num
  end

  def self.dec
    @@times = @@times - 1
  end

  def self.inc
    @@times = @@times + 1
  end

  def self.times
    @@times
  end

  def to_s
    puts "Job"
  end
end

Counter.set(VHOSTNAME_DICT.size)

def test(host_name)
  CHANNEL.receive
  # a=rand(10)
  a = rand(3)
  a = 3
  puts host_name + "-> " + a.to_s
  sleep(a)
  puts host_name + "<- " + a.to_s

  CHANNEL.send(nil)
  Counter.dec
end

def brute(vhost_name)
  CHANNEL.receive
  # a=rand(10)
  check_host(METHOD, URI_HOST, URI_PORT, URI_GET_IP_PATH, CONNECT_TIMEOUT, USER_AGETN, vhost_name)
  CHANNEL.send(nil)
  Counter.dec
end


CHANNEL = Channel(Nil).new(3)
# pp CHANNEL

THREAD.times do
  CHANNEL.send(nil)
end
VHOSTNAME_DICT.each do |vhost_name|
  spawn do
    # test(host)
    brute(vhost_name)
  end
end
# pp CHANNEL.receive
while Counter.times > 0
  # puts "Bugu Bugu !!!"
  sleep(2)
end

# puts "Gulu Gulu !!!"

THREAD.times do
  CHANNEL.receive
end

# VHOSTNAME_DICT.size.times do
#   CHANNEL.receive
# end
