import os
import shutil

# 1. Rename the package directory if it exists
old_dir = 'android/app/src/main/kotlin/com/aistudio/uni_eats'
new_dir = 'android/app/src/main/kotlin/com/aistudio/unieats'

if os.path.exists(old_dir):
    print(f"Renaming {old_dir} to {new_dir}")
    if os.path.exists(new_dir):
        shutil.rmtree(new_dir)
    os.makedirs(os.path.dirname(new_dir), exist_ok=True)
    shutil.move(old_dir, new_dir)
else:
    print(f"Directory {old_dir} not found.")

# 2. Update package name in MainActivity.kt
main_activity_path = 'android/app/src/main/kotlin/com/aistudio/unieats/MainActivity.kt'
if os.path.exists(main_activity_path):
    print(f"Updating package name in {main_activity_path}")
    with open(main_activity_path, 'r') as f:
        content = f.read()
    content = content.replace('package com.aistudio.uni_eats', 'package com.aistudio.unieats')
    with open(main_activity_path, 'w') as f:
        f.write(content)
else:
    print(f"MainActivity.kt not found at {main_activity_path}")

# 3. Update namespace and applicationId in android/app/build.gradle
build_gradle_path = 'android/app/build.gradle'
if os.path.exists(build_gradle_path):
    print(f"Updating build.gradle: {build_gradle_path}")
    with open(build_gradle_path, 'r') as f:
        content = f.read()
    content = content.replace('com.aistudio.uni_eats', 'com.aistudio.unieats')
    with open(build_gradle_path, 'w') as f:
        f.write(content)
else:
    print(f"build.gradle not found at {build_gradle_path}")

print("Android modifications done successfully!")
