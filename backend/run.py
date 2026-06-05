import socket
from flask_cors import CORS
from dotenv import load_dotenv
load_dotenv()

from app import create_app
app = create_app()

CORS(app, resources={r"/api/*": {"origins": "*"}})

def get_local_ip():
    try:
        # Create a dummy socket to find the local IP
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except Exception:
        return "127.0.0.1"

if __name__ == "__main__":
    local_ip = get_local_ip()
    print("\n" + "="*50)
    print(f" Servidor ejecutándose en:")
    print(f" Local:   http://localhost:5000")
    print(f" Red:     http://{local_ip}:5000")
    print("="*50 + "\n")

    app.run(host="0.0.0.0", port=5000, debug=True)