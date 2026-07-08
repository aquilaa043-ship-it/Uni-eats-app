import os
import shutil

print("Starting Android package renaming and clean up...")

# 1. Rename any package directories containing 'uni_eats' to 'unieats'
# We walk through android/app/src from bottom up to avoid path changes during iteration
for root, dirs, files in os.walk('android/app/src', topdown=False):
    for d in dirs:
        if d == 'uni_eats':
            old_path = os.path.join(root, d)
            new_path = os.path.join(root, 'unieats')
            print(f"Renaming package directory: {old_path} -> {new_path}")
            if os.path.exists(new_path):
                shutil.rmtree(new_path)
            os.rename(old_path, new_path)

# 2. Recursively replace any reference to 'com.aistudio.uni_eats' with 'com.aistudio.unieats'
# in all relevant source, config, and build files.
def replace_package_refs(directory):
    extensions = ('.gradle', '.kts', '.xml', '.kt', '.java', '.properties')
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(extensions):
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        content = f.read()
                    if 'com.aistudio.uni_eats' in content:
                        print(f"Updating package references in: {file_path}")
                        content = content.replace('com.aistudio.uni_eats', 'com.aistudio.unieats')
                        with open(file_path, 'w', encoding='utf-8') as f:
                            f.write(content)
                except Exception as e:
                    print(f"Error updating file {file_path}: {e}")

replace_package_refs('android')

print("Android configuration completed successfully!")
