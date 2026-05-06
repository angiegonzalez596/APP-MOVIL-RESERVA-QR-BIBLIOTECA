from flask import Flask
from .config import Config
from .extensions import db

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    db.init_app(app)

    with app.app_context():
        # Import routes here to avoid circular imports
        from .interfaces.api import auth_routes, locker_routes, reserva_routes
        app.register_blueprint(auth_routes.bp)
        app.register_blueprint(locker_routes.bp)
        app.register_blueprint(reserva_routes.bp)

        # Create tables (for local dev or initial setup)
        db.create_all() 

    return app
