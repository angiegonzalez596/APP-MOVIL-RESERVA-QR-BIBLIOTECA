from flask import Blueprint, jsonify

bp = Blueprint('reservas', __name__, url_prefix='/reservas')

@bp.route('/', methods=['GET'])
def get_reservas():
    return jsonify([]), 200
