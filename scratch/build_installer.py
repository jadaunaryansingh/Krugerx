import os
import subprocess
import shutil

cs_code = """using System;
using System.IO;
using System.IO.Compression;
using System.Diagnostics;
using System.Reflection;
using System.Windows.Forms;

static class Program {
    [STAThread]
    static void Main() {
        try {
            string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            string installDir = Path.Combine(localAppData, "Programs", "KrugerX");
            Directory.CreateDirectory(installDir);

            Assembly asm = Assembly.GetExecutingAssembly();
            using (Stream s = asm.GetManifestResourceStream("app.zip")) {
                if (s != null) {
                    using (ZipArchive zip = new ZipArchive(s)) {
                        foreach (ZipArchiveEntry entry in zip.Entries) {
                            string destPath = Path.Combine(installDir, entry.FullName);
                            if (string.IsNullOrEmpty(entry.Name)) {
                                Directory.CreateDirectory(destPath);
                            } else {
                                Directory.CreateDirectory(Path.GetDirectoryName(destPath));
                                entry.ExtractToFile(destPath, overwrite: true);
                            }
                        }
                    }
                }
            }

            try {
                string desktopPath = Environment.GetFolderPath(Environment.SpecialFolder.DesktopDirectory);
                string shortcutPath = Path.Combine(desktopPath, "KrugerX.lnk");
                CreateShortcut(shortcutPath, Path.Combine(installDir, "krugerx.exe"));
            } catch {}

            string exePath = Path.Combine(installDir, "krugerx.exe");
            if (File.Exists(exePath)) {
                Process.Start(new ProcessStartInfo {
                    FileName = exePath,
                    WorkingDirectory = installDir
                });
            }

            MessageBox.Show("KrugerX has been successfully installed and launched!", "KrugerX Installer", MessageBoxButtons.OK, MessageBoxIcon.Information);

        } catch (Exception ex) {
            MessageBox.Show("Installation failed: " + ex.Message, "Error: " + ex.Message, MessageBoxButtons.OK, MessageBoxIcon.Error);
        }
    }

    static void CreateShortcut(string shortcutPath, string targetPath) {
        Type shellType = Type.GetTypeFromProgID("WScript.Shell");
        dynamic shell = Activator.CreateInstance(shellType);
        dynamic shortcut = shell.CreateShortcut(shortcutPath);
        shortcut.TargetPath = targetPath;
        shortcut.WorkingDirectory = Path.GetDirectoryName(targetPath);
        shortcut.Save();
    }
}
"""

os.makedirs('scratch', exist_ok=True)
cs_file = os.path.join('scratch', 'Installer.cs')
with open(cs_file, 'w', encoding='utf-8') as f:
    f.write(cs_code)

csc_path = r'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe'
zip_file = r'backend/Landingpage/static/downloads/krugerx-windows-x64.zip'
out_exe = r'backend/Landingpage/static/downloads/KrugerX-Setup-1.0.0-x64.exe'

cmd = [
    csc_path,
    '/target:winexe',
    '/r:System.Windows.Forms.dll',
    '/r:System.IO.Compression.dll',
    '/r:System.IO.Compression.FileSystem.dll',
    f'/res:{zip_file},app.zip',
    f'/out:{out_exe}',
    cs_file
]

res = subprocess.run(cmd, capture_output=True, text=True)
print('STDOUT:', res.stdout)
print('STDERR:', res.stderr)
print('Return code:', res.returncode)

if res.returncode == 0:
    shutil.copy(out_exe, r'backend/Landingpage/static/downloads/krugerx.exe')
    print('SUCCESS! Created KrugerX-Setup-1.0.0-x64.exe and updated static/downloads/krugerx.exe!')
