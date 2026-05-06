from flask import Blueprint, request, jsonify
from ...use_cases.register_user import RegisterUser

from ...use_cases.generate_qr import GenerateQR

bp = Blueprint('auth', __name__, url_prefix='/auth')

@bp.route('/generate-qr/<int:user_id>', methods=['POST'])
def generate_qr(user_id):
    use_case = GenerateQR()
    result, status_code = use_case.execute(user_id)
    return jsonify(result), status_code

@bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    
    # Validaciones básicas
    required_fields = ['nombre', 'email', 'password', 'documento']
    for field in required_fields:
        if not data.get(field):
            return jsonify({"error": f"El campo {field} es obligatorio"}), 400

    use_case = RegisterUser()
    result, status_code = use_case.execute(data)
    
    return jsonify(result), status_code

@bp.route('/login', methods=['POST'])
def login():
    # Pendiente de implementar en el siguiente paso
    return jsonify({"message": "Login funcional próximamente"}), 200
