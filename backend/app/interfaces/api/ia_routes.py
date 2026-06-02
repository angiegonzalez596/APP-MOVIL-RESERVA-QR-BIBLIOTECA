from datetime import datetime
import os

from flask import Blueprint, jsonify, request
import google.generativeai as genai

from ...extensions import db
from ...infrastructure.bd.models import ConsultaIA, Locker, Reserva, Ingreso, Usuario

bp = Blueprint("ia", __name__, url_prefix="/api/ia")


@bp.route("/recomendacion", methods=["POST"])
def recomendacion_ia():
    data = request.get_json() or {}

    usuario_id = data.get("usuario_id")
    pregunta = data.get("pregunta")

    if not pregunta:
        return jsonify({"error": "La pregunta es obligatoria"}), 400

    api_key = os.environ.get("GEMINI_API_KEY")

    if not api_key:
        return jsonify({
            "error": "GEMINI_API_KEY no está configurada en el archivo .env"
        }), 500

    total_usuarios = Usuario.query.count()
    total_estudiantes = Usuario.query.filter_by(rol="ESTUDIANTE").count()
    total_vigilantes = Usuario.query.filter_by(rol="VIGILANTE").count()

    total_lockers = Locker.query.count()
    lockers_disponibles = Locker.query.filter_by(estado="DISPONIBLE").count()
    lockers_ocupados = Locker.query.filter_by(estado="OCUPADO").count()

    total_reservas = Reserva.query.count()
    reservas_activas = Reserva.query.filter_by(estado="ACTIVA").count()
    reservas_finalizadas = Reserva.query.filter_by(estado="FINALIZADA").count()

    ingresos_registrados = Ingreso.query.count()

    contexto = f"""
Eres un asistente de análisis para un sistema académico de reserva de lockers mediante QR.

Datos actuales del sistema:
- Total de usuarios: {total_usuarios}
- Estudiantes: {total_estudiantes}
- Vigilantes: {total_vigilantes}
- Total de lockers: {total_lockers}
- Lockers disponibles: {lockers_disponibles}
- Lockers ocupados: {lockers_ocupados}
- Total de reservas: {total_reservas}
- Reservas activas: {reservas_activas}
- Reservas finalizadas: {reservas_finalizadas}
- Ingresos registrados por QR: {ingresos_registrados}

Pregunta del usuario:
{pregunta}

Responde en español, de forma breve, clara y útil.
No inventes datos que no estén en el contexto.
Da recomendaciones prácticas para la administración de lockers.
"""

    try:
        genai.configure(api_key=api_key)

        model = genai.GenerativeModel("gemini-2.5-flash")
        response = model.generate_content(contexto)

        respuesta = response.text.strip()

        consulta = ConsultaIA(
            usuario_id=usuario_id,
            pregunta=pregunta,
            respuesta=respuesta,
            fecha=datetime.utcnow()
        )

        db.session.add(consulta)
        db.session.commit()

        return jsonify({
            "message": "Recomendación generada correctamente con IA",
            "consulta_id": consulta.id,
            "pregunta": pregunta,
            "respuesta": respuesta,
            "datos_analizados": {
                "usuarios": {
                    "total": total_usuarios,
                    "estudiantes": total_estudiantes,
                    "vigilantes": total_vigilantes
                },
                "lockers": {
                    "total": total_lockers,
                    "disponibles": lockers_disponibles,
                    "ocupados": lockers_ocupados
                },
                "reservas": {
                    "total": total_reservas,
                    "activas": reservas_activas,
                    "finalizadas": reservas_finalizadas
                },
                "ingresos": {
                    "total": ingresos_registrados
                }
            }
        }), 201

    except Exception as e:
        return jsonify({
            "error": "No fue posible generar la recomendación con IA",
            "detalle": str(e)
        }), 500

@bp.route('/historial', methods=['GET'])
def historial_ia():

    consultas = ConsultaIA.query.order_by(
        ConsultaIA.fecha.desc()
    ).all()

    resultado = []

    for consulta in consultas:
        resultado.append({
            "id": consulta.id,
            "usuario_id": consulta.usuario_id,
            "pregunta": consulta.pregunta,
            "respuesta": consulta.respuesta,
            "fecha": consulta.fecha.isoformat()
        })

    return jsonify(resultado), 200