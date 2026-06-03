from flask import Blueprint, jsonify, request
from ...extensions import db
from ...infrastructure.bd.models import Locker

bp = Blueprint('lockers', __name__, url_prefix='/api/lockers')

# Listado Get de lockers
@bp.route('/', methods=['GET'])
def get_lockers():
    # Sincronizado: Asegura ordenar correctamente por número
    lockers = Locker.query.order_by(Locker.numero.asc()).all()

    result = []
    for locker in lockers:
        result.append({
            "id": locker.id,
            "numero": locker.numero,
            "estado": locker.estado,
            "codigo_qr": locker.codigo_qr  # 💡 Añadido: Recuerda que agregamos código QR al modelo
        })

    return jsonify(result), 200

# Lockers disponibles
@bp.route('/disponibles', methods=['GET'])
def get_lockers_disponibles():
    # Filtramos directamente en la base de datos los que están "disponible"
    lockers_libres = Locker.query.filter_by(estado="disponible").all()
    
    result = []
    for locker in lockers_libres:
        result.append({
            "id": locker.id,
            "numero": locker.numero,
            "estado": locker.estado
        })
        
    return jsonify(result), 200

# Creación de lockers
# Creación de lockers en locker_routes.py
@bp.route('/', methods=['POST'])
def create_locker():
    data = request.get_json() or {}
    numero = data.get("numero")

    if not numero:
        return jsonify({"error": "El número del locker es obligatorio"}), 400

    # Validar si el número de locker ya existe
    if Locker.query.filter_by(numero=numero).first():
        return jsonify({"error": f"El locker número {numero} ya existe"}), 400

    locker = Locker(
        numero=numero,
        estado=data.get("estado", "disponible").lower()
    )

    db.session.add(locker)
    db.session.commit()

    return jsonify({
        "message": "Locker creado correctamente",
        "locker": {
            "id": locker.id,
            "numero": locker.numero,
            "estado": locker.estado
        }
    }), 201