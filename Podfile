project 'GoodDaeri.xcodeproj'


# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'GoodDaeri' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  # Pods for GoodDaeri
  pod 'AFNetworking', '~> 3.0'
  pod 'SideMenu'
  pod 'PageMenu'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'

  target 'GoodDaeriTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'GoodDaeriUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

target 'GoodValet' do
  # Uncomment the next line if you're using Swift or would like to use dynamic frameworks
  use_frameworks!

  # Pods for GoodDaeri
  pod 'AFNetworking', '~> 3.0'
  pod 'SideMenu'
  pod 'PageMenu'
  pod 'Firebase/Core'
  pod 'Firebase/Messaging'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        if target.name == 'SideMenu'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '4.2'
            end
        end 
        if target.name == 'PageMenu'
            target.build_configurations.each do |config|
                config.build_settings['SWIFT_VERSION'] = '3.0'
            end
        end
    end
end
