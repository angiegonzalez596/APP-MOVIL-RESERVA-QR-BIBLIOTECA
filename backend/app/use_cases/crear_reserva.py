from ..infrastructure.bd.repository import ReservaRepository

class CrearReservaUseCase:
    @staticmethod
    def ejecutar(usuario_id):
        reserva_existente = ReservaRepository.obtener_activa_por_usuario(usuario_id)

        if reserva_existente:
            return {
                "error": "El usuario ya cuenta con una reserva activa."
            }, 400

        nueva_reserva = ReservaRepository.crear_reserva(usuario_id)

        return {
            "mensaje": "Reserva creada exitosamente.",
            "reserva_id": nueva_reserva.id,
            "estado": nueva_reserva.estado
        }, 201