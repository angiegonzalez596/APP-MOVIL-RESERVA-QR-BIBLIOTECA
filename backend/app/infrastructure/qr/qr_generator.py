import qrcode
import io
import base64

class QRGeneratorService:
    @staticmethod
    def generate_qr_base64(data: str) -> str:
        """
        Genera un código QR a partir de una cadena de texto y lo devuelve como una cadena Base64.
        """
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(data)
        qr.make(fit=True)

        img = qr.make_image(fill_color="black", back_color="white")
        
        # Guardar la imagen en un buffer de memoria
        buffered = io.BytesIO()
        img.save(buffered, format="PNG")
        
        # Convertir a Base64
        return base64.b64encode(buffered.getvalue()).decode('utf-8')
