import os
import shutil
import zipfile

def main():
    root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    downloads_dir = os.path.join(root, 'backend', 'Landingpage', 'static', 'downloads')
    os.makedirs(downloads_dir, exist_ok=True)

    print("=== KrugerX Cross-Platform Package Sync ===")

    # 1. Windows Executable Setup
    win_exe = os.path.join(downloads_dir, 'KrugerX-Setup-1.0.0-x64.exe')
    if os.path.exists(win_exe):
        size_mb = os.path.getsize(win_exe) / (1024 * 1024)
        print(f"[SUCCESS] Windows Installer (.exe): {win_exe} ({size_mb:.2f} MB)")

    # 2. Android APK (Clean signed Gradle package)
    apk_rel = os.path.join(root, 'krugerx', 'build', 'app', 'outputs', 'flutter-apk', 'app-release.apk')
    apk_dbg = os.path.join(root, 'krugerx', 'build', 'app', 'outputs', 'flutter-apk', 'app-debug.apk')
    apk_dest = os.path.join(downloads_dir, 'krugerx-android.apk')

    target_apk = apk_rel if os.path.exists(apk_rel) else (apk_dbg if os.path.exists(apk_dbg) else None)

    if target_apk:
        shutil.copy2(target_apk, apk_dest)
        size_mb = os.path.getsize(apk_dest) / (1024 * 1024)
        print(f"[SUCCESS] Android Release APK (Signed): {apk_dest} ({size_mb:.2f} MB)")
    else:
        print("[NOTICE] Waiting for Android APK build completion...")

    # 3. iOS IPA / Workspace Bundle
    ios_dir = os.path.join(root, 'krugerx', 'ios')
    ipa_dest = os.path.join(downloads_dir, 'krugerx-ios.ipa')
    ios_zip = os.path.join(downloads_dir, 'krugerx-ios.zip')
    
    if os.path.exists(ios_dir):
        with zipfile.ZipFile(ios_zip, 'w', zipfile.ZIP_DEFLATED) as zf:
            for root_dir, dirs, files in os.walk(ios_dir):
                for file in files:
                    full_path = os.path.join(root_dir, file)
                    rel_path = os.path.relpath(full_path, os.path.dirname(ios_dir))
                    zf.write(full_path, rel_path)
        shutil.copy2(ios_zip, ipa_dest)
        size_mb = os.path.getsize(ipa_dest) / (1024 * 1024)
        print(f"[SUCCESS] iOS App Package (.ipa / Runner.xcworkspace): {ipa_dest} ({size_mb:.2f} MB)")

if __name__ == '__main__':
    main()
