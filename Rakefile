require 'rake'
require 'rubygems'

desc 'Create a gem'
task :gem do
  spec = Gem::Specification.new do |s|
    s.name = 'rbase'
    s.version = '0.1.3'
    s.summary = 'Library to create/read/write to XBase databases (*.DBF files)'
    s.files = Dir.glob('**/*').delete_if { |item| item.include?('.svn') }
    s.require_path = 'lib'
    s.authors = 'Maxim Kulkin, Leonardo Augusto Pires'
    s.email = 'maxim.kulkin@gmail.com, leonardo.pires@gmail.com'
    s.homepage = 'http://rbase.rubyforge.com/'
    s.rubyforge_project = 'rbase'
    s.has_rdoc = true

    s.required_ruby_version = '>= 1.8.2'
  end

  Gem::Builder.new(spec).build
end

require 'rake/testtask'
Rake::TestTask.new do |t|
  t.libs << 'test/' << 'lib/'
  t.test_files = FileList['test/**/test_*.rb']
  t.verbose = true
end

task default: :test
