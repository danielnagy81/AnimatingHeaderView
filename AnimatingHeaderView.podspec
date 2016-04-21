Pod::Spec.new do |s|
  s.name = 'AnimatingHeaderView'
  s.version = '1.0'  
  s.summary = 'A UIView subclass with animating image content.'
  s.module_name = "AnimatingHeaderView"
  s.homepage = 'https://github.com/danielnagy81/AnimatingHeaderView'
  s.license = 'MIT'
  s.authors = { 'Daniel Nagy' => 'danielnagy81@gmail.com' }
  s.ios.deployment_target = '9.0'
  s.source = { :git => 'https://github.com/danielnagy81/AnimatingHeaderView.git', :branch => 'master', :tag => s.version }
  s.source_files = 'AnimatingHeaderImage.swift'
end