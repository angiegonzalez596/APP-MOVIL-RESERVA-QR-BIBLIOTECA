from ..infrastructure.bd.repository import LockerRepository

class ListarLockersDisponiblesUseCase:
    @staticmethod
    def ejecutar():
        """
        Obtiene los lockers con estado 'disponible' y los 
        mapea a una estructura limpia.
        """
        lockers = LockerRepository.obtener_disponibles()
        
        # Transformamos los objetos de la base de datos a diccionarios simples
        return [
            {
                "id": locker.id,
                "numero": locker.numero,
                "codigo_qr": locker.codigo_qr,
                "estado": locker.estado
            }
            for locker in lockers
        ]