from flask import Blueprint, jsonify, request
from ...infrastructure.bd.models import Usuario

bp = Blueprint('users', __name__, url_prefix='/api/users')


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