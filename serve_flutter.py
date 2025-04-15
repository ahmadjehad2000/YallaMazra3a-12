import http.server
import socketserver
import os
import subprocess
from pathlib import Path

PORT = 5000

# Start the Flutter build process for web
print("Starting Flutter web build process...")
try:
    subprocess.run(["flutter", "build", "web", "--web-renderer", "html"], check=True)
    print("Flutter build completed successfully!")
except subprocess.CalledProcessError as e:
    print(f"Error building Flutter app: {e}")
    exit(1)

# Change directory to the build/web folder
web_dir = Path("build/web")
if not web_dir.exists():
    print(f"Error: {web_dir} does not exist. Make sure the Flutter build was successful.")
    exit(1)

os.chdir(web_dir)
print(f"Serving content from {os.getcwd()} on port {PORT}")

# Set up the web server
Handler = http.server.SimpleHTTPRequestHandler
Handler.extensions_map.update({
    '.dart': 'application/javascript',
    '.js': 'application/javascript',
    '': 'application/octet-stream',
})

with socketserver.TCPServer(("0.0.0.0", PORT), Handler) as httpd:
    print(f"Serving at http://0.0.0.0:{PORT}")
    httpd.serve_forever()