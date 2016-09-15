Pod::Spec.new do |s|
  s.name     = 'SQLClient'
  s.version  = '0.1.3'
  s.license  = 'MIT'
  s.summary  = 'An Objective-C wrapper around the open-source FreeTDS library'
  s.homepage = 'http://htmlpreview.github.io/?https://github.com/martinrybak/SQLClient/blob/0.1.0/SQLClient/SQLClientDocs/html/index.html',
  s.authors  = { 'Martin Rybak' => 'martin.rybak@gmail.com' }
  s.source   = { :git => 'https://github.com/martinrybak/SQLClient.git', :tag => s.version.to_s }
  s.source_files = 'SQLClient/SQLClient/SQLClient/*.{h,m}'
  s.vendored_libraries = 'SQLClient/SQLClient/SQLClient/libfreetds.a'
  s.libraries = 'iconv'
  s.requires_arc = true

  s.ios.deployment_target = '7.0'
  s.tvos.deployment_target = '9.0'
end

