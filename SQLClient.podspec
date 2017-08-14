Pod::Spec.new do |s|
  s.name     = 'SQLClient'
  s.version  = '1.0.0'
  s.license  = 'MIT'
  s.summary  = 'An Objective-C wrapper around the open-source FreeTDS library'
  s.homepage = 'https://github.com/martinrybak/SQLClient'
  s.authors  = { 'Martin Rybak' => 'martin.rybak@gmail.com' }
  s.source   = { :git => 'https://github.com/martinrybak/SQLClient.git', :tag => s.version.to_s }
  s.source_files = 'SQLClient/SQLClient/SQLClient/*.{h,m}'
  s.vendored_libraries = 'SQLClient/SQLClient/SQLClient/libsybdb.a'
  s.libraries = 'iconv'
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.tvos.deployment_target = '9.0'
end

