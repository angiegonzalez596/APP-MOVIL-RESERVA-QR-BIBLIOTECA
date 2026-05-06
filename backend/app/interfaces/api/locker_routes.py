from flask import Blueprint, jsonify

bp = Blueprint('lockers', __name__, url_prefix='/lockers')

@bp.route('/', methods=['GET'])
def get_lockers():
    return jsonify([]), 200
