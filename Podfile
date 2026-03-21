# Uncomment the next line to define a global platform for your project
# platform :ios, '18.0'

platform :ios, '17.4'

post_install do |installer|
  installer.pods_project.targets.each do |target|
    if target.name == 'SocketRocket'
      target.build_configurations.each do |config|
        config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
      end
    end
  end
end

target 'ranchat' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ranchat
  pod "StompClientLib"
  pod "Alamofire"
  pod "AlertToast"

  target 'ranchatTests' do
    inherit! :search_paths
  end
end
