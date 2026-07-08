import os
import re

podfile_path = 'ios/Podfile'

if not os.path.exists(podfile_path):
    print("Podfile does not exist. Creating a standard one.")
    standard_podfile = """platform :ios, '13.0'

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_install_global_ios_pods(ios_application_path = nil)
  # Refugee from old flutter installations
end

flutter_ios_podfile_path = File.expand_path(File.join('..', '.flutter-plugins-dependencies'), __FILE__)
directory = File.dirname(File.realpath(__FILE__))
load File.join(directory, '.symlinks', 'plugins', 'flutter_plugin_loader', 'ios', 'podhelper.rb')

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
"""
    os.makedirs('ios', exist_ok=True)
    with open(podfile_path, 'w') as f:
        f.write(standard_podfile)
else:
    print("Podfile exists. Updating platform and deployment targets.")
    with open(podfile_path, 'r') as f:
        content = f.read()
    
    # 1. Update platform line to iOS 13.0 (and ensure it is uncommented)
    if re.search(r'#?\s*platform\s+:ios\s*,\s*[\'"][^\'"]+[\'"]', content):
        content = re.sub(r'#?\s*platform\s+:ios\s*,\s*[\'"][^\'"]+[\'"]', "platform :ios, '13.0'", content)
    else:
        content = "platform :ios, '13.0'\n" + content
    
    # 2. Update post_install configuration to set IPHONEOS_DEPLOYMENT_TARGET to 13.0
    if "IPHONEOS_DEPLOYMENT_TARGET" not in content:
        pattern = r'(\s*)flutter_additional_ios_build_settings\(target\)'
        replacement = r"\1flutter_additional_ios_build_settings(target)\n\1target.build_configurations.each do |config|\n\1  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'\n\1end"
        content = re.sub(pattern, replacement, content)
        
    with open(podfile_path, 'w') as f:
        f.write(content)

print("Podfile processed successfully!")
