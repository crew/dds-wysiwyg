
require 'objective-j'
require 'objective-j/bundletask'

if !ENV['CONFIG']
    ENV['CONFIG'] = 'Debug'
end

ObjectiveJ::BundleTask.new(:wysiwyg) do |t|
    t.name          = 'wysiwyg'
    t.identifier    = 'com.yourcompany.wysiwyg'
    t.version       = '1.0'
    t.author        = 'Your Company'
    t.email         = 'feedback @nospam@ yourcompany.com'
    t.summary       = 'wysiwyg'
    t.sources       = FileList['*.j']
    t.resources     = FileList['Resources/*']
    t.index_file    = 'index.html'
    t.info_plist    = 'Info.plist'
    t.build_path    = File.join('Build', ENV['CONFIG'], 'wysiwyg')
    t.flag          = '-DDEBUG' if ENV['CONFIG'] == 'Debug'
    t.flag          = '-O' if ENV['CONFIG'] == 'Release'
end

task :default => [:wysiwyg]
