import os
import re

podfile_path = 'ios/Podfile'

if os.path.exists(podfile_path):
    print("Podfile exists. Processing Podfile...")
    with open(podfile_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Update platform line to iOS 13.0 (or uncomment and update if it's commented out)
    platform_pattern = r'#?\s*platform\s+:ios\s*,\s*[\'"][^\'"]+[\'"]'
    if re.search(platform_pattern, content):
        content = re.sub(platform_pattern, "platform :ios, '13.0'", content)
    else:
        content = "platform :ios, '13.0'\n" + content

    # 2. Replace or inject custom comprehensive post_install block to disable code signing
    # and set deployment target for all CocoaPods dependencies.
    if 'post_install do |installer|' in content:
        # Find where 'post_install do |installer|' starts and truncate everything after it to replace it cleanly
        idx = content.find('post_install do |installer|')
        content = content[:idx]

    content += """
post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      config.build_settings['CODE_SIGNING_ALLOWED'] = 'NO'
      config.build_settings['CODE_SIGNING_REQUIRED'] = 'NO'
      config.build_settings['CODE_SIGN_IDENTITY'] = ''
      config.build_settings['DEVELOPMENT_TEAM'] = ''
    end
  end
end
"""

    with open(podfile_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Podfile modified successfully!")
else:
    print("Podfile not found! This is unexpected because flutter create should generate it.")

# 3. Update IPHONEOS_DEPLOYMENT_TARGET and signing settings in Runner.xcodeproj/project.pbxproj
pbxproj_path = 'ios/Runner.xcodeproj/project.pbxproj'
if os.path.exists(pbxproj_path):
    print("Modifying project.pbxproj deployment targets and signing settings...")
    with open(pbxproj_path, 'r', encoding='utf-8', errors='ignore') as f:
        pbx_content = f.read()
    
    # Replace any IPHONEOS_DEPLOYMENT_TARGET = ...; with IPHONEOS_DEPLOYMENT_TARGET = 13.0;
    pbx_content = re.sub(
        r'IPHONEOS_DEPLOYMENT_TARGET\s*=\s*[0-9.]+;',
        'IPHONEOS_DEPLOYMENT_TARGET = 13.0;',
        pbx_content
    )
    
    # Strip any existing code sign, team, or profile settings so they don't override our settings
    lines = pbx_content.splitlines()
    new_lines = []
    for line in lines:
        if re.search(r'^\s*(CODE_SIGN_IDENTITY|DEVELOPMENT_TEAM|PROVISIONING_PROFILE_SPECIFIER|PROVISIONING_PROFILE|CODE_SIGNING_REQUIRED|CODE_SIGNING_ALLOWED)\b', line):
            continue
        new_lines.append(line)
    pbx_content = "\n".join(new_lines)
    
    # Set ProvisioningStyle to Manual to prevent automatic certificate checks
    pbx_content = pbx_content.replace('ProvisioningStyle = Automatic;', 'ProvisioningStyle = Manual;')
    
    # Inject clean disabled code signing settings under buildSettings = {
    pbx_content = pbx_content.replace(
        'buildSettings = {',
        'buildSettings = {\n\t\t\t\tCODE_SIGNING_ALLOWED = NO;\n\t\t\t\tCODE_SIGNING_REQUIRED = NO;\n\t\t\t\tCODE_SIGN_IDENTITY = "";\n\t\t\t\tDEVELOPMENT_TEAM = "";'
    )
    
    with open(pbxproj_path, 'w', encoding='utf-8') as f:
        f.write(pbx_content)
    print("project.pbxproj updated successfully!")


