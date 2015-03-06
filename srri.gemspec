lib = File.join(File.dirname(__FILE__), 'lib')
$:.unshift lib unless $:.include?(lib)

require 'srri/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'srri'
  s.summary     = 'RGSS3 implementation using StarRuby'
  s.description = 'A RGSS3 implementation using StarRuby backend'
  s.date        = Time.now.to_date.to_s
  s.version     = SRRI::Version::STRING
  s.homepage    = 'https://github.com/IceDragon200/srri'
  s.license     = 'MIT'

  s.authors = ['Corey Powell']
  s.email  = 'mistdragon100@gmail.com'

  s.add_runtime_dependency 'json',     '~> 1.8'
  s.add_runtime_dependency 'minitest', '~> 5.1'
  s.add_runtime_dependency 'rspec',    '~> 3.1'

  s.executables = Dir.glob('bin/**/*').map { |s| File.basename(s) }
  s.require_path = 'lib'
  s.files = Dir.glob('{bin,lib,spec,test,notes}/**/*')
  s.files << 'README.md'
end
