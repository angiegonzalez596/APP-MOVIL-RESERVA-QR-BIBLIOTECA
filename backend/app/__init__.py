from flask import Flask
from .config import Config
from .extensions import db

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
            qr_routes
        )

        app.register_blueprint(auth_routes.bp)
        app.register_blueprint(locker_routes.bp)
        app.register_blueprint(reserva_routes.bp)
        app.register_blueprint(user_routes.bp)
        app.register_blueprint(qr_routes.bp)

        db.create_all()

    @app.route("/", methods=["GET"])
    def home():
        return {
            "message": "API Reserva QR funcionando",
            "endpoints": [
                "POST /api/auth/register",
                "POST /api/auth/login",
                "POST /api/auth/generate-qr/<user_id>",
                "GET /api/lockers/",
                "POST /api/lockers/",
                "GET /api/reservas/",
                "POST /api/reservas/",
                "GET /api/reservas/<user_id>",
                "PUT /api/reservas/<id>/finalizar",
                "GET /api/users/profile?user_id=1",
                "GET /api/users/<id>",
                "POST /api/qr/generate",
                "POST /api/qr/scan"
            ]
        }, 200

    return app