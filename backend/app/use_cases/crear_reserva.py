from ..infrastructure.bd.repository import ReservaRepository, LockerRepository

class CrearReservaUseCase:
    @staticmethod
    def ejecutar(usuario_id, locker_id):
        """
        Regla: El usuario no debe tener reservas activas.
        Regla: El locker debe estar disponible.
        """
        # 1. Validar si el usuario ya tiene un casillero ocupado
        reserva_existente = ReservaRepository.obtener_activa_por_usuario(usuario_id)
        if reserva_existente:
            return {"error": "El usuario ya cuenta con una reserva activa."}, 400

        # 2. Intentar crear la reserva en el repositorio
        nueva_reserva = ReservaRepository.crear_reserva(usuario_id, locker_id)
        if not nueva_reserva:
            return {"error": "El locker no se encuentra disponible o no existe."}, 400

        return {
            "mensaje": "Reserva creada exitosamente.",
            "reserva_id": nueva_reserva.id,
            "locker_id": nueva_reserva.locker_id,
            "estado": nueva_reserva.estado  # 💡 Sincronizado: Cambiado de estado_reserva a estado
        }, 201