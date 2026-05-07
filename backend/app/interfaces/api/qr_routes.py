from datetime import datetime
from flask import Blueprint, jsonify, request
from ...extensions import db
from ...infrastructure.bd.models import Usuario, Ingreso

bp = Blueprint('qr', __name__, url_prefix='/api/qr')


@bp.route('/generate', methods=['POST'])
def generate_qr():
    data = request.get_json()

    user_id = data.get("user_id")

    if not user_id:
        return jsonify({"error": "user_id es obligatorio"}), 400

    usuario = Usuario.query.get(user_id)

    if not usuario:
        return jsonify({"error": "Usuario no encontrado"}), 404

    qr_code = f"QR-USUARIO-{usuario.id}-{usuario.documento}"

    usuario.qr_code = qr_code
    db.session.commit()

    return jsonify({
        "message": "QR generado correctamente",
        "user_id": usuario.id,
        "qr_code": qr_code
    }), 201


@bp.route('/scan', methods=['POST'])
def scan_qr():
    data = request.get_json()

    qr_code = data.get("qr_code")
    vigilante_id = data.get("vigilante_id")

    if not qr_code or not vigilante_id:
        return jsonify({
            "error": "qr_code y vigilante_id son obligatorios"
        }), 400

    usuario = Usuario.query.filter_by(qr_code=qr_code).first()

    if not usuario:
        return jsonify({"error": "QR inválido"}), 404

    vigilante = Usuario.query.get(vigilante_id)

    if not vigilante:
        return jsonify({"error": "Vigilante no encontrado"}), 404

    ingreso = Ingreso(
        usuario_id=usuario.id,
        vigilante_id=vigilante.id,
        fecha_ingreso=datetime.utcnow()
    )

    db.session.add(ingreso)
    db.session.commit()

    return jsonify({
        "message": "Ingreso registrado correctamente",
        "ingreso_id": ingreso.id,
        "usuario_id": usuario.id,
        "vigilante_id": vigilante.id,
        "fecha_ingreso": ingreso.fecha_ingreso.isoformat()
    }), 201