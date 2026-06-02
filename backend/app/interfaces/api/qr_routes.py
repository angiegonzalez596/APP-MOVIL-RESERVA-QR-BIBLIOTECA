from datetime import datetime
from flask import Blueprint, jsonify, request
from ...extensions import db
from ...infrastructure.bd.models import Usuario, Locker, Reserva, Ingreso

bp = Blueprint("qr", __name__, url_prefix="/api/qr")


@bp.route("/generate", methods=["POST"])
def generate_qr():
    data = request.get_json() or {}

    usuario_id = data.get("usuario_id")

    if not usuario_id:
        return jsonify({"error": "usuario_id es obligatorio"}), 400

    usuario = Usuario.query.get(usuario_id)

    if not usuario:
        return jsonify({"error": "Usuario no encontrado"}), 404

    reserva = Reserva.query.filter_by(
        usuario_id=usuario.id,
        estado="ACTIVA"
    ).first()

    if not reserva:
        return jsonify({
            "error": "El usuario no tiene una reserva activa"
        }), 404

    locker = Locker.query.get(reserva.locker_id)

    if not locker:
        return jsonify({"error": "Locker asociado no encontrado"}), 404

    qr_code = f"QR-RESERVA-{reserva.id}-USUARIO-{usuario.id}-LOCKER-{locker.id}"

    usuario.qr_code = qr_code
    db.session.commit()

    return jsonify({
        "message": "QR generado correctamente",
        "qr_code": qr_code,
        "reserva": {
            "id": reserva.id,
            "estado": reserva.estado,
            "fecha_inicio": reserva.fecha_inicio.isoformat() if reserva.fecha_inicio else None,
            "fecha_fin": reserva.fecha_fin.isoformat() if reserva.fecha_fin else None
        },
        "usuario": {
            "id": usuario.id,
            "nombre": usuario.nombre,
            "documento": usuario.documento,
            "codigo_estudiante": usuario.codigo_estudiante
        },
        "locker": {
            "id": locker.id,
            "numero": locker.numero,
            "estado": locker.estado
        }
    }), 201


@bp.route("/scan", methods=["POST"])
def scan_qr():
    data = request.get_json() or {}

    qr_code = data.get("qr_code")
    vigilante_id = data.get("vigilante_id")

    if not qr_code or not vigilante_id:
        return jsonify({
            "error": "qr_code y vigilante_id son obligatorios"
        }), 400

    usuario = Usuario.query.filter_by(qr_code=qr_code).first()

    if not usuario:
        return jsonify({
            "acceso": False,
            "error": "QR inválido"
        }), 404

    vigilante = Usuario.query.get(vigilante_id)

    if not vigilante:
        return jsonify({
            "acceso": False,
            "error": "Vigilante no encontrado"
        }), 404
    
    if vigilante.rol != "VIGILANTE":
        return jsonify({
            "acceso": False,
            "error": "El usuario que valida el QR no tiene rol de vigilante"
        }), 403

    reserva = Reserva.query.filter_by(
        usuario_id=usuario.id,
        estado="ACTIVA"
    ).first()

    if not reserva:
        return jsonify({
            "acceso": False,
            "error": "El usuario no tiene una reserva activa"
        }), 403

    locker = Locker.query.get(reserva.locker_id)

    if not locker:
        return jsonify({
            "acceso": False,
            "error": "Locker asociado no encontrado"
        }), 404

    ingreso = Ingreso(
        usuario_id=usuario.id,
        vigilante_id=vigilante.id,
        fecha_ingreso=datetime.utcnow()
    )

    db.session.add(ingreso)
    db.session.commit()

    return jsonify({
        "acceso": True,
        "message": "Acceso validado correctamente",
        "ingreso": {
            "id": ingreso.id,
            "fecha_ingreso": ingreso.fecha_ingreso.isoformat()
        },
        "usuario": {
            "id": usuario.id,
            "nombre": usuario.nombre,
            "documento": usuario.documento,
            "codigo_estudiante": usuario.codigo_estudiante
        },
        "reserva": {
            "id": reserva.id,
            "estado": reserva.estado,
            "fecha_inicio": reserva.fecha_inicio.isoformat() if reserva.fecha_inicio else None,
            "fecha_fin": reserva.fecha_fin.isoformat() if reserva.fecha_fin else None
        },
        "locker": {
            "id": locker.id,
            "numero": locker.numero,
            "estado": locker.estado
        },
        "vigilante": {
            "id": vigilante.id,
            "nombre": vigilante.nombre
        }
    }), 201