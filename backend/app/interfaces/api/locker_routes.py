from flask import Blueprint, jsonify, request
from ...extensions import db
from ...infrastructure.bd.models import Locker

bp = Blueprint('lockers', __name__, url_prefix='/api/lockers')

#Listado Get de lockers
@bp.route('/', methods=['GET'])
def get_lockers():
    lockers = Locker.query.order_by(Locker.numero.asc()).all()

    result = []
    for locker in lockers:
        result.append({
            "id": locker.id,
            "numero": locker.numero,
            "estado": locker.estado
        })

    return jsonify(result), 200

#Creación de lockers
@bp.route('/', methods=['POST'])
def create_locker():
    data = request.get_json()

    if not data.get("numero"):
        return jsonify({"error": "El número del locker es obligatorio"}), 400

    locker = Locker(
        numero=data.get("numero"),
        estado=data.get("estado", "DISPONIBLE")
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