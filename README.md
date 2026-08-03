# MaazDB Official Website

This repository contains the source code for the official [MaazDB](https://maazdb.com) marketing website and documentation portal. It is built using a lightweight Python Flask stack.

## Tech Stack
* **Backend:** Python 3, Flask
* **Frontend:** Jinja2 Templates, HTML5, Vanilla CSS3 (no external CSS frameworks used)
* **Assets:** Custom glassmorphism UI, interactive CSS animations, FontAwesome

## Getting Started

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

## Project Structure
* `run.py` - Application entry point.
* `app/` - Core application directory.
  * `routes.py` - Flask URL routes.
  * `templates/` - Jinja2 HTML templates (`index.html`, `docs.html`, etc.).
  * `static/` - Static assets (`css/`, `js/`, `images/`).

## Contributing
When contributing to the documentation, edit the corresponding templates in `app/templates/` and ensure your changes render correctly locally before submitting a pull request.
