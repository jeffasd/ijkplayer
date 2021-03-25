#!/usr/bin/env ruby
require 'fileutils'

find = false
schemes =  `xcodebuild -list`.lines.select{|m| find = (find || (m =~ /Schemes:/))}
puts schemes

puts ">>>>>"
schemes.shift
puts schemes
puts ">>>>>"

schemes = schemes.map {|m| m.strip}.delete_if {|m| m.strip.size == 0}
puts schemes

puts schemes

schemes = ['IJKMediaFramework']

puts schemes

def getsdk(*args)
	ret = []
	args.each do |m|
		ret << "#{m}#{`xcrun -sdk #{m} --show-sdk-version`}".strip
	end
	ret
end

#sdks = getsdk 'iphoneos', 'iphonesimulator'
sdks = getsdk 'iphonesimulator'

schemes.each do |m|
	sdks.each do |n|
		['Debug', 'Release'].each { |b|
			puts "xcodebuild -scheme #{m} -configuration #{b} -sdk #{n} -derivedDataPath build"
			system "xcodebuild -scheme #{m} -configuration #{b} -sdk #{n} -derivedDataPath build"
		}
	end
end

