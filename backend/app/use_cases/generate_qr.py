from ..infrastructure.bd.models import Usuario, Reserva
from ..extensions import db
from ..infrastructure.qr.qr_generator import QRGeneratorService


class GenerateQR:
    def execute(self, usuario_id):
        usuario = Usuario.query.get(usuario_id)

        if not usuario:
            return {"error": "Usuario no encontrado"}, 404

        reserva = Reserva.query.filter_by(
            usuario_id=usuario_id,
            estado="activa"
        ).first()

        if not reserva:
            return {"error": "No tienes una reserva activa"}, 400

        qr_data = f"QR-RESERVA-{reserva.id}"

        qr_base64 = QRGeneratorService.generate_qr_base64(qr_data)

        usuario.qr_code = qr_base64
        db.session.commit()

        return {
            "message": "Código QR generado exitosamente",
            "qr_code": qr_data,
            "qr_code_base64": qr_base64,
            "reserva_id": reserva.id
        }, 200