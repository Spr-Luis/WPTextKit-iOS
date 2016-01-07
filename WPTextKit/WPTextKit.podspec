Pod::Spec.new do |s|
  s.name             = "WPTextKit"
  s.version          = "0.1"
  s.summary      = "A TextKit library"

  s.description  = <<-DESC
                   A TextKit library
                   DESC

  s.homepage     = "http://apps.wordpress.org"
  s.license      = 'GPLv2'
  s.author       = { "Eric Johnosn" => "eric@automattic.com" }
  s.platform     = :ios, '9.0'
  s.requires_arc = true
#  s.source       = { :git => "https://github.com/wordpress-mobile/WPTextKit.git", :tag => s.version.to_s }
  s.source       = { :path => '.' }
  s.source_files = 'WPTextKit/*.{swift,h,m}'
#  s.header_dir = 'WPTextKit'
end