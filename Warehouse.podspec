Pod::Spec.new do |s|
s.name = 'Warehouse'
s.version = '0.1.0'
s.license = 'MIT'
s.summary = 'You can use easily NSFileManager.'
s.homepage = 'http://www.muukii.me/'
s.social_media_url = 'http://twitter.com/muukii0803'
s.authors = { 'Muukii' => 'muukii.muukii@gmail.com' }
s.source = { :git => 'https://github.com/muukii0803/Warehouse.git', :tag => s.version }

s.ios.deployment_target = '8.0'

s.source_files = 'Warehouse/Source/*.swift'

s.requires_arc = true
end
