from ..infrastructure.bd.models import Usuario
from ..extensions import db
from ..infrastructure.security.hash_service import HashService


class RegisterUser:
    def execute(self, data):
        rol = data.get("rol", "ESTUDIANTE").upper()
        codigo_estudiante = data.get("codigo_estudiante")

        if rol not in ["ESTUDIANTE", "VIGILANTE", "ADMIN"]:
            return {"error": "Rol no válido"}, 400

        if rol == "ESTUDIANTE" and not codigo_estudiante:
            return {"error": "El codigo_estudiante es obligatorio para estudiantes"}, 400

        if rol in ["VIGILANTE", "ADMIN"]:
            codigo_estudiante = None

        if Usuario.query.filter_by(email=data.get("email")).first():
            return {"error": "El email ya está registrado"}, 400

        if Usuario.query.filter_by(documento=data.get("documento")).first():
            return {"error": "El documento ya está registrado"}, 400

        hashed_password = HashService.hash_password(data.get("password"))

        nuevo_usuario = Usuario(
            nombre=data.get("nombre"),
            email=data.get("email"),
            password=hashed_password,
            codigo_estudiante=codigo_estudiante,
            documento=data.get("documento"),
            rol=rol,
            estado=True
        )

        db.session.add(nuevo_usuario)
        db.session.commit()

        return {
            "message": "Usuario registrado exitosamente",
            "id": nuevo_usuario.id,
            "rol": nuevo_usuario.rol
        }, 201