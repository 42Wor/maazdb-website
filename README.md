<div align="center">
  <img src="app/static/images/maazdb-ican.png" alt="MaazDB Logo" width="120" />
  
  # MaazDB Official Website
  
  **The ultra-fast, highly-concurrent database engine built for the modern web.**<br/>
  [Website](https://maazdb.com) • [Documentation](https://maazdb.com/docs) • [Ecosystem](https://maazdb.com/docs/ecosystem)
  
  ![Flask](https://img.shields.io/badge/flask-%23000.svg?style=for-the-badge&logo=flask&logoColor=white)
  ![Python](https://img.shields.io/badge/python-3670A0?style=for-the-badge&logo=python&logoColor=ffdd54)
  ![HTML5](https://img.shields.io/badge/html5-%23E34F26.svg?style=for-the-badge&logo=html5&logoColor=white)
  ![CSS3](https://img.shields.io/badge/css3-%231572B6.svg?style=for-the-badge&logo=css3&logoColor=white)
</div>

<br/>

This repository contains the source code for the official [MaazDB](https://maazdb.com) marketing website and documentation portal. It is built using a lightweight Python Flask stack.

## ⚡ About MaazDB
MaazDB is a highly-concurrent, high-performance database engine built for the modern web. It is engineered from the ground up to minimize network latency and maximize storage efficiency through advanced data structures.

### 🛠️ Key Engine Features
* **RAM-Speed Writes:** Utilizes Log-Structured Merge (LSM) Trees and MemTables for high-frequency in-memory writes.
* **Protocol v2 Multiplexing:** Asynchronous multiplexing over a single connection for zero Head-of-Line (HOL) blocking.
* **Zero-Cost Security:** Built-in TLS 1.3 with 0-RTT session resumption, replay protection, and cryptographic driver authentication.
* **Edge Optimized:** Automatic Zstd or LZ4 Smart Wire Compression for high-latency VPS & VPN channels.
* **Multi-Tenant Architecture:** A single MaazDB cluster can serve multiple different applications with complete data isolation using the `USE` command.
* **Native Cross-Platform:** Runs natively on Linux, macOS, and Windows without virtualization overhead.

### 🌐 Universal Connectivity Ecosystem
**MaazDB is more than a database engine.** Build applications faster with our native, high-performance client libraries that handle encryption, binary protocols, and connection pooling automatically.

We provide official, high-performance drivers for your favorite languages:
* 🐍 **MaazDB-Py** (Python)
* 🟩 **MaazDB-JS** (Node.js)
* 🦀 **MaazDB-RS** (Rust)
* 🐹 **MaazDB-GO** (Go)

---

## 💻 Tech Stack
* **Backend:** Python 3, Flask
* **Frontend:** Jinja2 Templates, HTML5, Vanilla CSS3 (no external CSS frameworks used)
* **Assets:** Custom glassmorphism UI, interactive CSS animations, FontAwesome

## 🚀 Getting Started

To run the website locally for development:

### 1. Prerequisites
Ensure you have Python 3.8+ installed.

### 2. Setup Environment
```bash
# Clone the repository
git clone https://github.com/42Wor/maazdb-website.git
cd maazdb-website

# Create and activate a virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows use: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt
```

### 3. Run the Development Server
```bash
flask --app run.py run
```
The website will now be accessible at `http://127.0.0.1:5000`.

## 📁 Project Structure
* `run.py` - Application entry point.
* `app/` - Core application directory.
  * `routes.py` - Flask URL routes.
  * `templates/` - Jinja2 HTML templates (`index.html`, `docs.html`, etc.).
  * `static/` - Static assets (`css/`, `js/`, `images/`).

## 🤝 Contributing
When contributing to the documentation, edit the corresponding templates in `app/templates/` and ensure your changes render correctly locally before submitting a pull request.
