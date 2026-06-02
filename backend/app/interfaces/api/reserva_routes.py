from datetime import datetime
from flask import Blueprint, jsonify, request
from ...extensions import db
from ...infrastructure.bd.models import Reserva, Locker, Usuario

bp = Blueprint('reservas', __name__, url_prefix='/api/reservas')

# Rutas para gestionar reservas de lockers
@bp.route('/', methods=['GET'])
def get_reservas():
    reservas = Reserva.query.all()

    result = []
    for reserva in reservas:
        result.append({
            "id": reserva.id,
            "usuario_id": reserva.usuario_id,
            "locker_id": reserva.locker_id,
            "fecha_inicio": reserva.fecha_inicio.isoformat() if reserva.fecha_inicio else None,
            "fecha_fin": reserva.fecha_fin.isoformat() if reserva.fecha_fin else None,
            "estado": reserva.estado,
            "usuario": reserva.usuario.nombre if reserva.usuario else None,
            "locker": reserva.locker.numero if reserva.locker else None
        })

    return jsonify(result), 200

# Ruta para crear una nueva reserva
@bp.route('/', methods=['POST'])
def create_reserva():
    data = request.get_json()

    usuario_id = data.get("usuario_id")
    locker_id = data.get("locker_id")

    if not usuario_id or not locker_id:
        return jsonify({"error": "usuario_id y locker_id son obligatorios"}), 400

    usuario = Usuario.query.get(usuario_id)
    if not usuario:
        return jsonify({"error": "Usuario no encontrado"}), 404

    locker = Locker.query.get(locker_id)
    if not locker:
        return jsonify({"error": "Locker no encontrado"}), 404

    if locker.estado == "OCUPADO":
        return jsonify({"error": "El locker ya está ocupado"}), 400

    reserva_activa = Reserva.query.filter_by(
        usuario_id=usuario_id,
        estado="ACTIVA"
    ).first()

    if reserva_activa:
        return jsonify({"error": "El usuario ya tiene una reserva activa"}), 400

    reserva = Reserva(
        usuario_id=usuario_id,
        locker_id=locker_id,
        fecha_inicio=datetime.utcnow(),
        estado="ACTIVA"
    )

    locker.estado = "OCUPADO"

    db.session.add(reserva)
    db.session.commit()

    return jsonify({
        "message": "Reserva creada correctamente",
        "reserva": {
            "id": reserva.id,
            "usuario_id": reserva.usuario_id,
            "locker_id": reserva.locker_id,
            "fecha_inicio": reserva.fecha_inicio.isoformat(),
            "estado": reserva.estado
        }
    }), 201

# reservas de un usuario específico
@bp.route('/<int:user_id>', methods=['GET'])
def get_reservas_by_user(user_id):
    reservas = Reserva.query.filter_by(usuario_id=user_id).all()

    result = []
    for reserva in reservas:
        result.append({
            "id": reserva.id,
            "usuario_id": reserva.usuario_id,
            "locker_id": reserva.locker_id,
            "fecha_inicio": reserva.fecha_inicio.isoformat() if reserva.fecha_inicio else None,
            "fecha_fin": reserva.fecha_fin.isoformat() if reserva.fecha_fin else None,
            "estado": reserva.estado,
            "usuario": reserva.usuario.nombre if reserva.usuario else None,
            "locker": reserva.locker.numero if reserva.locker else None
        })

    return jsonify(result), 200

# Ruta para finalizar una reserva
@bp.route('/<int:id>/finalizar', methods=['PUT'])
def finalizar_reserva(id):
    reserva = Reserva.query.get(id)

    if not reserva:
        return jsonify({"error": "Reserva no encontrada"}), 404

    if reserva.estado != "ACTIVA":
        return jsonify({"error": "Solo se pueden finalizar reservas activas"}), 400

    reserva.estado = "FINALIZADA"
    reserva.fecha_fin = datetime.utcnow()

    locker = Locker.query.get(reserva.locker_id)
    if locker:
        locker.estado = "DISPONIBLE"

    db.session.commit()

    return jsonify({
        "message": "Reserva finalizada correctamente",
        "reserva": {
            "id": reserva.id,
            "usuario_id": reserva.usuario_id,
            "locker_id": reserva.locker_id,
            "fecha_inicio": reserva.fecha_inicio.isoformat() if reserva.fecha_inicio else None,
            "fecha_fin": reserva.fecha_fin.isoformat() if reserva.fecha_fin else None,
            "estado": reserva.estado
        }
    }), 200
