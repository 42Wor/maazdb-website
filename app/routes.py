import os
from flask import Blueprint, render_template, current_app, abort, send_from_directory

bp = Blueprint('main', __name__)

@bp.route('/')
def index():
    # We pass the version info to the HTML
    return render_template('index.html', 
                           version=current_app.config['LATEST_VERSION'],
                           win_file=current_app.config['INSTALLER_WIN'],
                           linux_file=current_app.config['INSTALLER_LINUX'],
                           mac_file=current_app.config['INSTALLER_MAC'])

# Serve Unix Shell Script with correct text/plain mimetype
@bp.route('/install.sh')
def serve_install_sh():
    static_dir = os.path.join(current_app.root_path, 'static', 'installers')
    return send_from_directory(static_dir, 'install.sh', mimetype='text/plain')

# Serve Windows PowerShell Script with correct text/plain mimetype
@bp.route('/install.ps1')
def serve_install_ps1():
    static_dir = os.path.join(current_app.root_path, 'static', 'installers')
    return send_from_directory(static_dir, 'install.ps1', mimetype='text/plain')


@bp.context_processor
def inject_global_vars():
    return dict(version=current_app.config['LATEST_VERSION'])
@bp.route('/docs')
def docs():
    return render_template('docs.html')
@bp.route('/docs/ecosystem')
def overview():
    return render_template('ecosystem/ecosystem.html')

@bp.route('/docs/cli')
def cli():
    return render_template('cli.html')

@bp.route('/docs/insert')
def insert():
    return render_template('command/insert.html')

@bp.route('/docs/update')
def update():
    return render_template('command/update.html')
@bp.route('/docs/delete')
def delete():
    return render_template('command/delete.html')       
@bp.route('/docs/select')
def select():   
    return render_template('command/select.html')
@bp.route('/command/create-table')
def create_table():
    # This forces a 404 error when the user clicks the link
    abort(404)



@bp.route('/install')
def install():
    # Pass the version variable so it updates automatically in the text
    return render_template('install.html', version=current_app.config['LATEST_VERSION'])

#404
@bp.app_errorhandler(404)
def page_not_found(e):
    return render_template('404.html'), 404