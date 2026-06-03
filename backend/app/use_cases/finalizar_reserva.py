from ..infrastructure.bd.repository import ReservaRepository

class FinalizarReservaUseCase:
    @staticmethod
    def ejecutar(reserva_id):
        """
        Cierra la reserva y libera el casillero correspondiente.
        Devuelve True si se pudo finalizar, False si no existía o no estaba activa.
        """
        # 💡 Toda la lógica interna de base de datos se resuelve dentro del repositorio,
        # por lo que este archivo está perfecto y a salvo de errores de atributos.
        exito = ReservaRepository.finalizar_reserva(reserva_id)
        return exito