from flask import Blueprint, jsonify
from sqlalchemy import func
from ...infrastructure.bd.models import Usuario, Locker, Reserva, Ingreso, ConsultaIA, AperturaLocker

bp = Blueprint("reportes", __name__, url_prefix="/api/reportes")

@bp.route("/resumen", methods=["GET"])
def resumen():
    # Usuarios
    total_usuarios = Usuario.query.count()
    total_estudiantes = Usuario.query.filter_by(rol="ESTUDIANTE").count()
    total_vigilantes = Usuario.query.filter_by(rol="VIGILANTE").count()
    total_admins = Usuario.query.filter_by(rol="ADMIN").count()

    # Lockers
    total_lockers = Locker.query.count()
    lockers_disponibles = Locker.query.filter_by(estado="DISPONIBLE").count()
    lockers_ocupados = Locker.query.filter_by(estado="OCUPADO").count()

    # Reservas
    total_reservas = Reserva.query.count()
    reservas_activas = Reserva.query.filter_by(estado="ACTIVA").count()
    reservas_finalizadas = Reserva.query.filter_by(estado="FINALIZADA").count()

    # Ingresos (Últimos 10 para ver actividad reciente)
    ingresos_registrados = Ingreso.query.count()
    ultimos_ingresos = Ingreso.query.order_by(Ingreso.fecha_ingreso.desc()).limit(10).all()
    lista_ingresos = []
    for ing in ultimos_ingresos:
        lista_ingresos.append({
            "estudiante": ing.usuario.nombre if ing.usuario else "Desconocido",
            "fecha": ing.fecha_ingreso.isoformat(),
            "vigilante": ing.vigilante.nombre if ing.vigilante else "Sistema"
        })

    # Aperturas de Lockers (NUEVO)
    ultimas_aperturas = AperturaLocker.query.order_by(AperturaLocker.fecha.desc()).limit(10).all()
    lista_aperturas = []
    for ap in ultimas_aperturas:
        lista_aperturas.append({
            "estudiante": ap.usuario.nombre if ap.usuario else "Desconocido",
            "locker": ap.locker.numero if ap.locker else 0,
            "fecha": ap.fecha.isoformat()
        })

    # IA y lo que buscan (Análisis de tendencias)
    consultas_ia = ConsultaIA.query.count()
    ultimas_consultas = ConsultaIA.query.order_by(ConsultaIA.fecha.desc()).limit(5).all()
    lista_ia = []
    for c in ultimas_consultas:
        lista_ia.append({
            "pregunta": c.pregunta,
            "respuesta_corta": (c.respuesta[:100] + '...') if len(c.respuesta) > 100 else c.respuesta,
            "fecha": c.fecha.isoformat()
        })

    return jsonify({
        "usuarios": {
            "total": total_usuarios,
            "estudiantes": total_estudiantes,
            "vigilantes": total_vigilantes,
            "administradores": total_admins
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
            "total": ingresos_registrados,
            "recientes": lista_ingresos
        },
        "aperturas": {
            "recientes": lista_aperturas
        },
        "ia": {
            "total_consultas": consultas_ia,
            "busquedas_recientes": lista_ia
        }
    }), 200