import os
import httpx
from flask import Flask, render_template, request, flash, redirect, url_for, jsonify, send_from_directory

app = Flask(__name__)
app.config['SECRET_KEY'] = os.environ.get('SECRET_KEY', 'development-fallback-key-change-in-prod')

@app.route('/', methods=['GET'])
def index():
    return render_template('index.html')

@app.route('/download', methods=['GET'])
def download():
    return render_template('download.html')

@app.route('/download/exe', methods=['GET'])
@app.route('/download/krugerx.exe', methods=['GET'])
@app.route('/download/KrugerX-Setup-1.0.0-x64.exe', methods=['GET'])
def download_exe():
    return send_from_directory('static/downloads', 'KrugerX-Setup-1.0.0-x64.exe', as_attachment=True, download_name='KrugerX-Setup-1.0.0-x64.exe')

@app.route('/download/zip', methods=['GET'])
@app.route('/download/krugerx-windows-x64.zip', methods=['GET'])
def download_zip():
    return send_from_directory('static/downloads', 'krugerx-windows-x64.zip', as_attachment=True)

@app.route('/download/apk', methods=['GET'])
@app.route('/download/krugerx-android.apk', methods=['GET'])
def download_apk():
    return send_from_directory('static/downloads', 'krugerx-android.apk', as_attachment=True, download_name='KrugerX-1.0.0-Android.apk')

@app.route('/download/ios', methods=['GET'])
@app.route('/download/krugerx-ios.ipa', methods=['GET'])
def download_ios():
    return send_from_directory('static/downloads', 'krugerx-ios.ipa', as_attachment=True, download_name='KrugerX-1.0.0-iOS.ipa')

@app.route('/status', methods=['GET'])
def backend_status():
    """Ping the FastAPI backend health endpoint"""
    try:
        with httpx.Client(timeout=3.0) as client:
            response = client.get('http://localhost:8000/api/v1/health')
            if response.status_code == 200:
                return jsonify({"status": "online", "message": "All Systems Operational"})
            return jsonify({"status": "degraded", "message": "Backend Connectivity Issues"})
    except httpx.RequestError:
        return jsonify({"status": "offline", "message": "Backend Offline"})

if __name__ == '__main__':
    app.run(debug=True, port=5000)

