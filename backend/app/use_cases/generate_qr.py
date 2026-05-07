from ..infrastructure.bd.models import Usuario
from ..extensions import db
from ..infrastructure.qr.qr_generator import QRGeneratorService

class GenerateQR:
    def execute(self, usuario_id):
        usuario = Usuario.query.get(usuario_id)
        if not usuario:
            return {"error": "Usuario no encontrado"}, 404

        # El contenido del QR podría ser el documento o un ID único
        qr_data = f"USER_ID:{usuario.id}|DOC:{usuario.documento}"
        
        qr_base64 = QRGeneratorService.generate_qr_base64(qr_data)
        
        # Guardar el QR generado en el campo qr_code de la tabla usuario
        usuario.qr_code = qr_base64
        db.session.commit()

        return {
            "message": "Código QR generado exitosamente",
            "qr_code_base64": qr_base64
        }, 200
