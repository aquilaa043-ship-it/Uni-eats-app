import os
import re

podfile_path = 'ios/Podfile'

if os.path.exists(podfile_path):
    print("Podfile exists. Processing Podfile...")
    with open(podfile_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Update platform line to iOS 13.0 (or uncomment and update if it's commented out)
    # Match pattern like # platform :ios, '12.0' or platform :ios, '11.0'
    platform_pattern = r'#?\s*platform\s+:ios\s*,\s*[\'"][^\'"]+[\'"]'
    if re.search(platform_pattern, content):
        content = re.sub(platform_pattern, "platform :ios, '13.0'", content)
    else:
        # If no platform line found, prepend it
        content = "platform :ios, '13.0'\n" + content

    # 2. Modify post_install do |installer| block to explicitly set IPHONEOS_DEPLOYMENT_TARGET to 13.0 for all configurations of all targets.
    if 'post_install do |installer|' in content:
        if "IPHONEOS_DEPLOYMENT_TARGET" not in content:
            # We match the indentation and inject the config override.
            content = re.sub(
                r'(\s*)flutter_additional_ios_build_settings\(target\)',
                r"\1flutter_additional_ios_build_settings(target)\n\1target.build_configurations.each do |config|\n\1  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'\n\1end",
                content
            )
        else:
            # If it is already there, make sure any other numbers like '11.0', '12.0' are updated to '13.0'
            content = re.sub(
                r"config\.build_settings\['IPHONEOS_DEPLOYMENT_TARGET'\]\s*=\s*['\"][0-9.]+['\"]",
                "config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'",
                content
            )
            content = re.sub(
                r'config\.build_settings\["IPHONEOS_DEPLOYMENT_TARGET"\]\s*=\s*[\'"][0-9.]+[\'"]',
                "config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'",
                content
            )
    else:
        # If there's no post_install block, append one
        content += """
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
    end
  end
end
"""
    with open(podfile_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Podfile modified successfully!")
else:
    print("Podfile not found! This is unexpected because flutter create should generate it.")

# 3. Update IPHONEOS_DEPLOYMENT_TARGET in Runner.xcodeproj/project.pbxproj
pbxproj_path = 'ios/Runner.xcodeproj/project.pbxproj'
if os.path.exists(pbxproj_path):
    print("Modifying project.pbxproj deployment targets...")
    with open(pbxproj_path, 'r', encoding='utf-8', errors='ignore') as f:
        pbx_content = f.read()
    
    # Replace any IPHONEOS_DEPLOYMENT_TARGET = ...; with IPHONEOS_DEPLOYMENT_TARGET = 13.0;
    pbx_content = re.sub(
        r'IPHONEOS_DEPLOYMENT_TARGET\s*=\s*[0-9.]+;',
        'IPHONEOS_DEPLOYMENT_TARGET = 13.0;',
        pbx_content
    )
    
    with open(pbxproj_path, 'w', encoding='utf-8') as f:
        f.write(pbx_content)
    print("project.pbxproj updated successfully!")

