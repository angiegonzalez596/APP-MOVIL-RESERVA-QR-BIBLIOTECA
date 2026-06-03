from datetime import datetime
from flask import Blueprint, jsonify, request
from ...extensions import db
from ...infrastructure.bd.models import Reserva, Locker, Usuario, AperturaLocker

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
            "estado": reserva.estado, # ✅ Sincronizado
            "usuario": reserva.usuario.nombre if reserva.usuario else None,
            "locker": reserva.locker.numero if reserva.locker else None
        })

    return jsonify(result), 200

# Ruta para crear una nueva reserva
@bp.route('/', methods=['POST'])
def create_reserva():
    data = request.get_json() or {}

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

    # Comparar estado en minúsculas
    if locker.estado == "ocupado":
        return jsonify({"error": "El locker ya está ocupado"}), 400

    # ✅ CORREGIDO: Se cambió 'estado_reserva' por 'estado'
    reserva_activa = Reserva.query.filter_by(
        usuario_id=usuario_id,
        estado="activa"
    ).first()

    if reserva_activa:
        return jsonify({"error": "El usuario ya tiene una reserva activa"}), 400

    # ✅ CORREGIDO: Instancia con el atributo 'estado'
    reserva = Reserva(
        usuario_id=usuario_id,
        locker_id=locker_id,
        fecha_inicio=datetime.utcnow(),
        estado="activa" 
    )

    locker.estado = "ocupado" 

    db.session.add(reserva)
    db.session.commit()

    return jsonify({
        "message": "Reserva creada correctamente",
        "reserva": {
            "id": reserva.id,
            "usuario_id": reserva.usuario_id,
            "locker_id": reserva.locker_id,
            "fecha_inicio": reserva.fecha_inicio.isoformat(),
            "estado": reserva.estado # ✅ Sincronizado
        }
    }), 201

# reservas de un usuario específico
@bp.route('/usuario/<int:user_id>', methods=['GET'])
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
            "estado": reserva.estado, # ✅ Sincronizado
            "usuario": reserva.usuario.nombre if reserva.usuario else None,
            "locker": reserva.locker.numero if reserva.locker else None
        })

    return jsonify(result), 200

# Ruta para finalizar una reserva por código de locker (Escaneo QR del locker)
@bp.route("/finalizar-por-codigo-locker", methods=["POST"])
def finalizar_por_codigo_locker():
    data = request.get_json() or {}
    codigo_locker = data.get("codigo_locker") # Formato: LOCKER-1
    usuario_id = data.get("usuario_id")

    if not codigo_locker or not usuario_id:
        return jsonify({"error": "codigo_locker y usuario_id son obligatorios"}), 400

    # Extraer número de locker del código (Ej: LOCKER-5 -> 5)
    try:
        numero_locker_str = codigo_locker.replace("LOCKER-", "")
        numero_locker = int(numero_locker_str)
    except:
        return jsonify({"error": "Formato de código de locker inválido"}), 400

    locker = Locker.query.filter_by(numero=numero_locker).first()
    if not locker:
        return jsonify({"error": "Locker no encontrado"}), 404

    reserva = Reserva.query.filter_by(
        usuario_id=usuario_id,
        locker_id=locker.id,
        estado="activa"
    ).first()

    if not reserva:
        return jsonify({"error": "No tienes una reserva activa en este locker"}), 404

    # Finalizar reserva y liberar locker
    reserva.estado = "finalizada"
    reserva.fecha_fin = datetime.utcnow()
    locker.estado = "disponible"

    # Registrar la apertura en el historial
    apertura = AperturaLocker(
        usuario_id=usuario_id,
        locker_id=locker.id,
        fecha=datetime.utcnow()
    )
    db.session.add(apertura)

    db.session.commit()

    return jsonify({
        "message": "🔓 Locker abierto. Por favor, retire sus pertenencias y asegúrese de dejarlo cerrado.",
        "reserva_id": reserva.id,
        "locker_numero": locker.numero
    }), 200

# Ruta para registrar ingreso (Llamada por el vigilante)
@bp.route('/registrar-ingreso', methods=['POST'])
def registrar_ingreso():
    data = request.get_json() or {}
    reserva_id_raw = data.get("reserva_id")
    locker_id = data.get("locker_id")

    if not reserva_id_raw or not locker_id:
        return jsonify({"error": "reserva_id y locker_id son obligatorios"}), 400

    # Intentar extraer ID numérico si viene con formato QR-RESERVA-X...
    reserva_id = reserva_id_raw
    if isinstance(reserva_id_raw, str) and "QR-RESERVA-" in reserva_id_raw:
        try:
            reserva_id = int(reserva_id_raw.split("-")[2])
        except (IndexError, ValueError):
            return jsonify({"error": "Formato de QR inválido"}), 400

    reserva = Reserva.query.get(reserva_id)
    if not reserva:
        return jsonify({"error": "Reserva no encontrada"}), 404

    locker = Locker.query.get(locker_id)
    if not locker:
        return jsonify({"error": "Locker no encontrado"}), 404

    if locker.estado == "ocupado":
        return jsonify({"error": "El locker ya está ocupado"}), 400

    # Actualizar reserva con el nuevo locker asignado por el vigilante si es necesario
    reserva.locker_id = locker_id
    reserva.estado = "activa"
    locker.estado = "ocupado"

    db.session.commit()

    return jsonify({
        "message": "Ingreso registrado correctamente",
        "reserva_id": reserva.id,
        "locker_numero": locker.numero
    }), 200

# Ruta para finalizar una reserva por ID de locker
@bp.route('/finalizar-por-locker', methods=['PUT'])
def finalizar_por_locker():
    data = request.get_json() or {}
    locker_id = data.get("locker_id")

    if not locker_id:
        return jsonify({"error": "locker_id es obligatorio"}), 400

    reserva = Reserva.query.filter_by(locker_id=locker_id, estado="activa").first()
    if not reserva:
        return jsonify({"error": "No hay reserva activa para este locker"}), 404

    reserva.estado = "finalizada"
    reserva.fecha_fin = datetime.utcnow()

    locker = Locker.query.get(locker_id)
    if locker:
        locker.estado = "disponible"

    db.session.commit()

    return jsonify({
        "message": "Reserva finalizada correctamente",
        "reserva_id": reserva.id
    }), 200

# Ruta para finalizar una reserva
@bp.route('/<int:id>/finalizar', methods=['PUT'])
def finalizar_reserva(id):
    reserva = Reserva.query.get(id)

    if not reserva:
        return jsonify({"error": "Reserva no encontrada"}), 404

    # ✅ CORREGIDO: Se cambió 'estado_reserva' por 'estado'
    if reserva.estado != "activa":
        return jsonify({"error": "Solo se pueden finalizar reservas activas"}), 400

    reserva.estado = "finalizada" # ✅ Sincronizado
    reserva.fecha_fin = datetime.utcnow()

    locker = Locker.query.get(reserva.locker_id)
    if locker:
        locker.estado = "disponible" 

    db.session.commit()

    return jsonify({
        "message": "Reserva finalizada correctamente",
        "reserva": {
            "id": reserva.id,
            "usuario_id": reserva.usuario_id,
            "locker_id": reserva.locker_id,
            "fecha_inicio": reserva.fecha_inicio.isoformat() if reserva.fecha_inicio else None,
            "fecha_fin": reserva.fecha_fin.isoformat() if reserva.fecha_fin else None,
            "estado": reserva.estado # ✅ Sincronizado
        }
    }), 200