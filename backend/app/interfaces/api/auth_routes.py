from flask import Blueprint, request, jsonify
from ...use_cases.register_user import RegisterUser
from ...use_cases.login_user import LoginUser
from ...use_cases.generate_qr import GenerateQR
from ...extensions import db


bp = Blueprint('auth', __name__, url_prefix='/api/auth')

# Endpoint para generar QR de acceso

@bp.route('/generate-qr/<int:user_id>', methods=['POST'])
def generate_qr(user_id):
    use_case = GenerateQR()
    result, status_code = use_case.execute(user_id)
    return jsonify(result), status_code


# Registro de usuario
@bp.route('/register', methods=['POST'])
def register():
    data = request.get_json() or {}

    rol = data.get("rol", "ESTUDIANTE").upper()
    data["rol"] = rol

    required_fields = ['nombre', 'email', 'password', 'documento']

    for field in required_fields:
        if not data.get(field):
            return jsonify({"error": f"El campo {field} es obligatorio"}), 400

    if rol == "ESTUDIANTE" and not data.get("codigo_estudiante"):
        return jsonify({
            "error": "El campo codigo_estudiante es obligatorio para estudiantes"
        }), 400

    if rol == "VIGILANTE":
        data["codigo_estudiante"] = None

    use_case = RegisterUser()
    result, status_code = use_case.execute(data)

    return jsonify(result), status_code


# Login de usuario
@bp.route('/login', methods=['POST'])
def login():
    data = request.get_json() or {}

    email = data.get("email")
    password = data.get("password")

    if not email or not password:
        return jsonify({"error": "Email y password son obligatorios"}), 400

    use_case = LoginUser()
    result, status_code = use_case.execute(email, password)

    return jsonify(result), status_code

@bp.route('/<int:id>', methods=['PUT'])
def actualizar_usuario(id):
    data = request.get_json() or {}

    usuario = Usuario.query.get(id)

    if not usuario:
        return jsonify({"error": "Usuario no encontrado"}), 404

    nombre = data.get("nombre")
    email = data.get("email")

    if nombre:
        usuario.nombre = nombre

    if email:
        usuario.email = email

    db.session.commit()

    return jsonify({
        "message": "Usuario actualizado correctamente",
        "usuario": {
            "id": usuario.id,
            "nombre": usuario.nombre,
            "email": usuario.email,
            "rol": usuario.rol
        }
    }), 200