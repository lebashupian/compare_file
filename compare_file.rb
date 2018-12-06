#!/usr/bin/env ruby
# coding: utf-8

require 'find'
require 'digest'
require 'wxl_process_bar'

####################################
# 帮助，例子：
# ./compare_file.rb /tmp/abc/a/ /tmp/abc/b/
#####################################
(puts "
帮助，例子：
./compare_file.rb /tmp/abc/a/ /tmp/abc/b/
";exit) if ARGV[0] == 'help' or ARGV[0] == '--help'

ARGV[0] ||= "/etc"
ARGV[1] ||= "/etc"
ARGV[2] ||= 'nodebug'

路径1=ARGV[0]
路径2=ARGV[1]



开始时间=Time.new

数据集1=[]
Dir.chdir(路径1)
循环总数1=0
puts "计算文件总量..."
Find.find("./") {
	循环总数1 += 1
}
进度条1=C_进度条.new 循环总数1
循环数1=1
puts "开始遍历#{路径1}"
Find.find("./") do |path|
	tmp=[]
  if File.file?(path) or File.symlink?(path)
  	begin
  		sha256 =  Digest::SHA256.file path
	    tmp << path
	    tmp << sha256.hexdigest
	    数据集1 << tmp
  	rescue Errno::ENOENT
		puts "#{path}软连接文件，但是找不到连接到的目标文件" if ARGV[2] == 'debug'
  	rescue Errno::EISDIR
	   	tmp << path
	  	tmp << 'this is a link to directory'
  	end
  elsif File.directory?(path)
  	tmp << path
  	tmp << 'this is a directory'
  else
  	puts "文件类型特殊，不在比较范围之内" if ARGV[2] == 'debug'
  	p path if ARGV[2] == 'debug'
  	p File.ftype(path) if ARGV[2] == 'debug'
  end
  进度条1.更新
end


数据集2=[]
Dir.chdir(路径2)
循环总数2=0
puts "计算文件总量..."
Find.find("./") {
	循环总数2 += 1
}
进度条2=C_进度条.new 循环总数2
循环数2=1
puts "开始遍历#{路径2}"
Find.find("./") do |path|
	tmp=[]
  if File.file?(path) or File.symlink?(path)
  	begin
  		sha256 =  Digest::SHA256.file path
	    tmp << path
	    tmp << sha256.hexdigest
	    数据集2 << tmp
  	rescue Errno::ENOENT
		#puts "#{path}软连接文件，但是找不到连接到的目标文件"
  	rescue Errno::EISDIR
	   	tmp << path
	  	tmp << 'this is a link to directory'
  	end
  elsif File.directory?(path)
  	tmp << path
  	tmp << 'this is a directory'
  else
  	#puts "文件类型特殊，不在比较范围之内"
  	#p path
  	#p File.ftype(path);
  end
  进度条2.更新
end

##########################
# 表示双方无发别数据
数据交集 = 数据集1 & 数据集2


##########################
# 表示有意义数据
差异1 = 数据集1 - 数据交集
差异2 = 数据集2 - 数据交集

##########################
# 将数据的摘要值去掉
i=0
差异1.each{
	差异1[i][1] = nil;
	i += 1;
}

i=0
差异2.each{
	差异2[i][1] = nil;
	i += 1;
}

#############################
# 重新计算差异
差异文件= 差异1 & 差异2
多出来的文件1 = 差异1 - 差异文件
多出来的文件2 = 差异2 - 差异文件


if 差异文件.size == 0 and 多出来的文件1.size == 0 and 多出来的文件2.size == 0;
	puts "没有发现差异"
else
  if 差异文件.size != 0
	 puts "------------------------两边都存在，但是数据文件内容有差异：--------------------------"
	 差异文件.each {|x| puts "#{x[0]}"}
  end
  if 多出来的文件1.size != 0
	 puts "------------------------#{路径1}存在，#{路径2}不存在:---------------------------------"
	 多出来的文件1.each {|x| puts "#{x[0]}"}
  end
  if 多出来的文件2.size != 0
	 puts "------------------------#{路径2}存在，#{路径1}不存在:---------------------------------" 
	 多出来的文件2.each {|x| puts "#{x[0]}"}
  end
end

结束时间=Time.new
puts "@@@@@@@@@@@@@@@@@@@@@@@ 分析完成，花费#{ (结束时间 - 开始时间).to_i.to_s+'秒'}  @@@@@@@@@@@@@@@@@@@@@"
