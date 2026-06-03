from ..infrastructure.bd.repository import ReservaRepository, LockerRepository

class VerReservaActivaUseCase:
    @staticmethod
    def ejecutar(usuario_id):
        """
        Busca si el usuario tiene una reserva activa. 
        Si existe, devuelve sus detalles junto con la info del locker.
        """
        reserva = ReservaRepository.obtener_activa_por_usuario(usuario_id)
        
        if not reserva:
            return None # El usuario no tiene reservas activas en este momento

        # Buscamos los datos del locker asociado para darle contexto al usuario
        locker = LockerRepository.obtener_por_id(reserva.locker_id)

        return {
            "reserva_id": reserva.id,
            "usuario_id": reserva.usuario_id,
            "estado_reserva": reserva.estado,
            "fecha_inicio": reserva.fecha_inicio.isoformat(),
            "locker": {
                "id": locker.id,
                "numero": locker.numero,
                "codigo_qr": locker.codigo_qr
            }
        }