from flask import Flask
from dotenv import load_dotenv

from .config import Config
from .extensions import db

load_dotenv()

def create_app(config_class=Config):
    app = Flask(__name__)
    app.config.from_object(config_class)

    db.init_app(app)

    with app.app_context():
        from .interfaces.api import (
            auth_routes,
            locker_routes,
            reserva_routes,
            user_routes,
            qr_routes,
            ia_routes,
            reporte_routes
        )

        app.register_blueprint(auth_routes.bp)
        app.register_blueprint(locker_routes.bp)
        app.register_blueprint(reserva_routes.bp)
        app.register_blueprint(user_routes.bp)
        app.register_blueprint(qr_routes.bp)
        app.register_blueprint(ia_routes.bp)
        app.register_blueprint(reporte_routes.bp)

        db.create_all()

    @app.route("/", methods=["GET"])
    def home():
        return {
            "message": "API Reserva QR funcionando"
        }, 200

    return app