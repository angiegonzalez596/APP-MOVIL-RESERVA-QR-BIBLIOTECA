from ..infrastructure.bd.models import Usuario
from ..infrastructure.security.hash_service import HashService
from ..infrastructure.security.jwt_handler import JWTHandler

class LoginUser:
    def execute(self, email, password):
        usuario = Usuario.query.filter_by(email=email).first()

        if not usuario:
            return {"error": "Usuario no encontrado"}, 404

        if not HashService.verify_password(password, usuario.password):
            return {"error": "Contraseña incorrecta"}, 401

        if not usuario.estado:
            return {"error": "Usuario inactivo"}, 403

        token = JWTHandler.generate_token(usuario.id, usuario.rol)

        return {
            "message": "Login exitoso",
            "token": token,
            "usuario": {
                "id": usuario.id,
                "nombre": usuario.nombre,
                "email": usuario.email,
                "rol": usuario.rol
            }
        }, 200
