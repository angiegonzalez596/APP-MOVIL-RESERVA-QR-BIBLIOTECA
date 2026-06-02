from datetime import datetime
from flask import Blueprint, jsonify, request
from ...extensions import db
from ...infrastructure.bd.models import ConsultaIA, Locker, Reserva

bp = Blueprint('ia', __name__, url_prefix='/api/ia')

# Ruta para obtener una recomendación de IA basada en la disponibilidad de lockers
@bp.route('/recomendacion', methods=['POST'])
def recomendacion_ia():
    data = request.get_json()

    usuario_id = data.get("usuario_id")
    pregunta = data.get("pregunta")

    if not pregunta:
        return jsonify({"error": "La pregunta es obligatoria"}), 400

    lockers_disponibles = Locker.query.filter_by(estado="DISPONIBLE").count()
    reservas_activas = Reserva.query.filter_by(estado="ACTIVA").count()

    respuesta = (
        f"Actualmente hay {lockers_disponibles} lockers disponibles "
        f"y {reservas_activas} reservas activas. "
    )

    if lockers_disponibles > 0:
        respuesta += "Se recomienda realizar la reserva porque hay disponibilidad."
    else:
        respuesta += "No se recomienda intentar reservar en este momento porque no hay lockers disponibles."

    consulta = ConsultaIA(
        usuario_id=usuario_id,
        pregunta=pregunta,
        respuesta=respuesta,
        fecha=datetime.utcnow()
    )

    db.session.add(consulta)
    db.session.commit()

    return jsonify({
        "message": "Recomendación IA generada correctamente",
        "consulta_id": consulta.id,
        "pregunta": pregunta,
        "respuesta": respuesta
    }), 201