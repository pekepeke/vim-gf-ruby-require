#!/usr/bin/env ruby
# -*- coding: utf-8 -*-

# $:.push(File.join(File.dirname(__FILE__), 'lib'))
# require 'rubygems'

if __FILE__ == $0
  lib_filepath = nil
  lib_filename = "#{ARGV[0]}.rb"

  finder_proc = proc{|p|
    if File.exists? File.join(p, lib_filename)
      lib_filepath = File.join(p, lib_filename)
      true
    else
      false
    end
  }

  bundler_paths = [(require 'bundler'; Bundler.bundle_path.to_s)] rescue []
  (bundler_paths + Gem.default_path).compact.flatten.uniq.any? {|p|
    Dir.glob("#{p}/**/lib/").any? &finder_proc
    not lib_filepath.nil?
    # libs = Dir.glob("#{p}/**/lib/#{lib_filename}")
    # lib_filepath = libs.first unless libs.empty?
    # not libs.empty?
  }
  if lib_filepath.nil?
    $LOAD_PATH.grep(/ruby\/[\d\.]+$/).any? &finder_proc
  end
  puts lib_filepath unless lib_filepath.nil?
end
__END__
