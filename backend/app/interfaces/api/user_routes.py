from flask import Blueprint, jsonify, request
from ...extensions import db
from ...infrastructure.bd.models import Usuario

bp = Blueprint('users', __name__, url_prefix='/api/users')

# Rutas para gestionar usuarios
@bp.route('/profile', methods=['GET'])
def get_profile():
    user_id = request.args.get("user_id")

    if not user_id:
        return jsonify({"error": "user_id es obligatorio"}), 400

    usuario = Usuario.query.get(user_id)

    if not usuario:
        return jsonify({"error": "Usuario no encontrado"}), 404

    return jsonify({
        "id": usuario.id,
        "nombre": usuario.nombre,
        "email": usuario.email,
        "documento": usuario.documento,
        "codigo_estudiante": usuario.codigo_estudiante,
        "rol": usuario.rol,
        "estado": usuario.estado
    }), 200

#usuario por su ID
@bp.route('/<int:id>', methods=['GET'])
def get_user_by_id(id):
    usuario = Usuario.query.get(id)

    if not usuario:
        return jsonify({"error": "Usuario no encontrado"}), 404

    return jsonify({
        "id": usuario.id,
        "nombre": usuario.nombre,
        "email": usuario.email,
        "documento": usuario.documento,
        "codigo_estudiante": usuario.codigo_estudiante,
        "rol": usuario.rol,
        "estado": usuario.estado
    }), 200

@bp.route('/<int:id>', methods=['PUT'])
def actualizar_usuario(id):
    data = request.get_json() or {}

    usuario = Usuario.query.get(id)

    if not usuario:
        return jsonify({"error": "Usuario no encontrado"}), 404

    nombre = data.get("nombre")
    email = data.get("email")

    if nombre:
        usuario.nombre = nombre

    if email:
        usuario.email = email

    db.session.commit()

    return jsonify({
        "message": "Usuario actualizado correctamente",
        "usuario": {
            "id": usuario.id,
            "nombre": usuario.nombre,
            "email": usuario.email,
            "rol": usuario.rol
        }
    }), 200