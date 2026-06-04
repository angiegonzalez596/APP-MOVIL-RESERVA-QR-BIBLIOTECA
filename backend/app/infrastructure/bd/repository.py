from ...extensions import db
from .models import Locker, Reserva
from datetime import datetime

class LockerRepository:
    @staticmethod
    def obtener_disponibles():
        """
        Tarea: Listar lockers y disponibilidad.
        Retorna todos los lockers cuyo estado sea 'disponible'.
        """
        return Locker.query.filter_by(estado="disponible").all()

    @staticmethod
    def obtener_por_id(locker_id):
        """Busca un locker específico por su ID."""
        return Locker.query.get(locker_id)

    @staticmethod
    def obtener_por_qr(codigo_qr):
        """Busca un locker usando el string del código QR escaneado."""
        return Locker.query.filter_by(codigo_qr=codigo_qr).first()


class ReservaRepository:
    @staticmethod
    def obtener_activa_por_usuario(usuario_id):
        """
        Tarea: Ver reserva activa.
        Busca si el usuario tiene una reserva con estado_reserva 'activa'.
        """
        return Reserva.query.filter_by(
            usuario_id=usuario_id, 
            estado="activa"
        ).first()

    @staticmethod
    def obtener_por_id(reserva_id):
        """Busca una reserva específica por su ID."""
        return Reserva.query.get(reserva_id)

    @staticmethod
    def crear_reserva(usuario_id):
        """
        Crea una reserva activa sin locker asignado.
        El locker será asignado después por el vigilante.
        """
        nueva_reserva = Reserva(
            usuario_id=usuario_id,
            locker_id=None,
            estado="activa"
        )

        db.session.add(nueva_reserva)
        db.session.commit()
        return nueva_reserva

    @staticmethod
    def finalizar_reserva(reserva_id):
        """
        Tarea: Finalizar reserva.
        Coloca la fecha de fin, cambia el estado a 'finalizada' y libera el locker.
        """
        reserva = Reserva.query.get(reserva_id)
        if not reserva or reserva.estado != "activa":
            return False # No existe la reserva activa
            
        # 1. Finalizar la reserva
        reserva.estado = "finalizada"
        reserva.fecha_fin = datetime.utcnow()

        # 2. Liberar el locker asociado
        locker = Locker.query.get(reserva.locker_id)
        if locker:
            locker.estado = "disponible"

        db.session.commit()
        return True