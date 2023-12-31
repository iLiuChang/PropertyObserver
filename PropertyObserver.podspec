Pod::Spec.new do |s|
  s.name         = "PropertyObserver"
  s.version      = "1.0.0"
  s.summary      = "swift property observer"
  s.homepage     = "https://github.com/iLiuChang/PropertyObserver"
  s.license      = "MIT"
  s.authors      = { "iLiuChang" => "iliuchang@foxmail.com" }
  s.platform     = :ios, "11.0"
  s.source       = { :git => "https://github.com/iLiuChang/PropertyObserver.git", :tag => s.version }
  s.requires_arc = true
  s.swift_version = "5.0"
  s.source_files = "Source/*.{swift}"
end
