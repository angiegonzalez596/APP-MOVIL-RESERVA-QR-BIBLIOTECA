from ..infrastructure.bd.models import Usuario
from ..extensions import db
from ..infrastructure.security.hash_service import HashService

class RegisterUser:
    def execute(self, data):
        # Verificar si el usuario ya existe
        if Usuario.query.filter_by(email=data.get('email')).first():
            return {"error": "El email ya está registrado"}, 400
        
        if Usuario.query.filter_by(documento=data.get('documento')).first():
            return {"error": "El documento ya está registrado"}, 400

        hashed_password = HashService.hash_password(data.get('password'))
        
        nuevo_usuario = Usuario(
            nombre=data.get('nombre'),
            email=data.get('email'),
            password=hashed_password,
            codigo_estudiante=data.get('codigo_estudiante'),
            documento=data.get('documento'),
            rol=data.get('rol', 'estudiante'),
            estado=True
        )

        db.session.add(nuevo_usuario)
        db.session.commit()

        return {"message": "Usuario registrado exitosamente", "id": nuevo_usuario.id}, 201
