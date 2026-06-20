#!/usr/bin/env python3
"""
Upload Server untuk Toko Beras DzikDzak
Buka di browser, upload video, langsung masuk ke folder raw/
Cara jalanin: python3 upload_server.py
"""

import http.server
import os
import cgi
import urllib.parse

UPLOAD_DIR = os.path.join(os.path.dirname(__file__), "raw")
PORT = 8080

# Pastikan folder raw ada
os.makedirs(UPLOAD_DIR, exist_ok=True)

class UploadHandler(http.server.BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            self.send_response(200)
            self.send_header("Content-type", "text/html; charset=utf-8")
            self.end_headers()
            
            # List existing files
            files = os.listdir(UPLOAD_DIR)
            file_list = ""
            for f in files:
                size = os.path.getsize(os.path.join(UPLOAD_DIR, f))
                if size > 1024*1024:
                    size_str = f"{size/1024/1024:.1f} MB"
                elif size > 1024:
                    size_str = f"{size/1024:.1f} KB"
                else:
                    size_str = f"{size} B"
                file_list += f'<li>📁 {f} <span style="color:#888;font-size:12px">({size_str})</span></li>'
            
            if not files:
                file_list = '<li style="color:#888">Belum ada file</li>'
            
            html = f"""<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Video - Toko Beras DzikDzak</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
            background: #1a1a2e;
            color: #fff;
            max-width: 600px;
            margin: 0 auto;
            padding: 20px;
        }}
        .header {{
            text-align: center;
            padding: 20px 0;
            border-bottom: 1px solid #333;
        }}
        .header h1 {{
            color: #D4A017;
            margin: 0;
        }}
        .header p {{
            color: #888;
            margin: 5px 0 0;
        }}
        .upload-box {{
            background: #16213e;
            border: 2px dashed #D4A017;
            border-radius: 12px;
            padding: 40px 20px;
            text-align: center;
            margin: 20px 0;
        }}
        .upload-box input[type="file"] {{
            display: none;
        }}
        .upload-btn {{
            background: #D4A017;
            color: #1a1a2e;
            border: none;
            padding: 12px 30px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
        }}
        .upload-btn:hover {{
            background: #e6b422;
        }}
        .submit-btn {{
            background: #25D366;
            color: #fff;
            border: none;
            padding: 12px 30px;
            border-radius: 8px;
            font-size: 16px;
            font-weight: bold;
            cursor: pointer;
            margin-top: 10px;
        }}
        .submit-btn:hover {{
            background: #20bd5a;
        }}
        .file-list {{
            background: #16213e;
            border-radius: 12px;
            padding: 15px 20px;
            margin: 20px 0;
        }}
        .file-list h3 {{
            color: #D4A017;
            margin: 0 0 10px;
        }}
        .file-list ul {{
            list-style: none;
            padding: 0;
            margin: 0;
        }}
        .file-list li {{
            padding: 8px 0;
            border-bottom: 1px solid #333;
        }}
        .file-list li:last-child {{
            border-bottom: none;
        }}
        .status {{
            text-align: center;
            padding: 10px;
            border-radius: 8px;
            margin: 10px 0;
            display: none;
        }}
        .status.success {{
            background: #1b5e20;
            color: #81c784;
            display: block;
        }}
        .status.error {{
            background: #b71c1c;
            color: #ef9a9a;
            display: block;
        }}
        .note {{
            color: #666;
            font-size: 12px;
            text-align: center;
            margin-top: 30px;
        }}
    </style>
</head>
<body>
    <div class="header">
        <h1>🌾 DZIK & DZAK</h1>
        <p>Upload Video untuk Konten Sosial Media</p>
    </div>

    <div id="status" class="status"></div>

    <div class="upload-box">
        <form id="uploadForm" enctype="multipart/form-data" method="POST">
            <input type="file" id="fileInput" name="file" required accept="video/*,image/*">
            <div>
                <button type="button" class="upload-btn" onclick="document.getElementById('fileInput').click()">
                    📁 Pilih Video / Foto
                </button>
            </div>
            <div id="fileName" style="margin: 10px 0; color: #888;"></div>
            <button type="submit" class="submit-btn">🚀 Upload ke Raw</button>
        </form>
    </div>

    <div class="file-list">
        <h3>📂 File di Raw/</h3>
        <ul>{file_list}</ul>
    </div>

    <div class="note">
        File akan tersimpan di folder content/raw/ <br>
        Setelah upload, bilang ke Codebuff: "Proses video [nama_file]"
    </div>

    <script>
        document.getElementById('fileInput').onchange = function() {{
            var name = this.files[0]?.name || '';
            document.getElementById('fileName').textContent = name;
        }};

        document.getElementById('uploadForm').onsubmit = async function(e) {{
            e.preventDefault();
            var formData = new FormData(this);
            var status = document.getElementById('status');
            
            status.className = 'status';
            status.textContent = '⏳ Uploading...';
            status.style.display = 'block';

            try {{
                var res = await fetch('/upload', {{
                    method: 'POST',
                    body: formData
                }});
                var result = await res.text();
                
                if (res.ok) {{
                    status.className = 'status success';
                    status.textContent = '✅ ' + result + ' — Refresh halaman untuk lihat file';
                    setTimeout(() => location.reload(), 2000);
                }} else {{
                    status.className = 'status error';
                    status.textContent = '❌ Gagal: ' + result;
                }}
            }} catch(err) {{
                status.className = 'status error';
                status.textContent = '❌ Error: ' + err.message;
            }}
        }};
    </script>
</body>
</html>
"""
            self.wfile.write(html.encode())
        
        elif self.path == "/list":
            self.send_response(200)
            self.send_header("Content-type", "application/json")
            self.end_headers()
            files = os.listdir(UPLOAD_DIR)
            import json
            self.wfile.write(json.dumps(files).encode())
        
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not found")

    def do_POST(self):
        if self.path == "/upload":
            try:
                form = cgi.FieldStorage(
                    fp=self.rfile,
                    headers=self.headers,
                    environ={"REQUEST_METHOD": "POST", "CONTENT_TYPE": self.headers["Content-Type"]}
                )
                
                file_item = form["file"]
                if file_item.filename:
                    filename = os.path.basename(file_item.filename)
                    # Handle duplicate filename
                    base, ext = os.path.splitext(filename)
                    counter = 1
                    save_path = os.path.join(UPLOAD_DIR, filename)
                    while os.path.exists(save_path):
                        save_path = os.path.join(UPLOAD_DIR, f"{base}_{counter}{ext}")
                        counter += 1
                    
                    with open(save_path, "wb") as f:
                        f.write(file_item.file.read())
                    
                    size = os.path.getsize(save_path)
                    self.send_response(200)
                    self.send_header("Content-type", "text/plain")
                    self.end_headers()
                    self.wfile.write(f"Upload berhasil: {filename} ({size/1024:.1f} KB)".encode())
                else:
                    self.send_response(400)
                    self.send_header("Content-type", "text/plain")
                    self.end_headers()
                    self.wfile.write(b"Pilih file dulu!")
            except Exception as e:
                self.send_response(500)
                self.send_header("Content-type", "text/plain")
                self.end_headers()
                self.wfile.write(f"Error: {str(e)}".encode())
        else:
            self.send_response(404)
            self.end_headers()
            self.wfile.write(b"Not found")


if __name__ == "__main__":
    print("=" * 50)
    print("🌾 UPLOAD SERVER - TOKO BERAS DZIKDZAK")
    print("=" * 50)
    
    # Dapatkan IP
    import socket
    hostname = socket.gethostname()
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
    except:
        ip = "127.0.0.1"
    
    print(f"\n📤 Upload URL: http://{ip}:{PORT}")
    print(f"   Buka link ini di browser HP/laptop kamu!")
    print(f"\n📂 File akan tersimpan di: {UPLOAD_DIR}")
    print(f"\n⚠️  Tekan Ctrl+C untuk menghentikan server")
    print("=" * 50)
    
    server = http.server.HTTPServer(("0.0.0.0", PORT), UploadHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer dihentikan.")
        server.server_close()
