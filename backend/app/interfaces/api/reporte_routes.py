from flask import Blueprint, jsonify
from ...infrastructure.bd.models import Usuario, Locker, Reserva, Ingreso, ConsultaIA

bp = Blueprint("reportes", __name__, url_prefix="/api/reportes")


@bp.route("/resumen", methods=["GET"])
def resumen():
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
    consultas_ia = ConsultaIA.query.count()

    return jsonify({
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
        },
        "ia": {
            "consultas": consultas_ia
        }
    }), 200