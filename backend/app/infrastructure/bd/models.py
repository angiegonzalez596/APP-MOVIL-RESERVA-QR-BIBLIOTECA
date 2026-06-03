from datetime import datetime
from ...extensions import db

class Usuario(db.Model):
    __tablename__ = 'usuario'
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100))
    email = db.Column(db.String(100), unique=True)
    password = db.Column(db.String(255))
    codigo_estudiante = db.Column(db.String(50))
    documento = db.Column(db.String(50))
    rol = db.Column(db.String(20))
    qr_code = db.Column(db.Text)
    estado = db.Column(db.Boolean)
    
    reservas = db.relationship('Reserva', backref='usuario', lazy=True)
    ingresos = db.relationship('Ingreso', foreign_keys='Ingreso.usuario_id', backref='usuario', lazy=True)

class Locker(db.Model):
    __tablename__ = 'locker'
    id = db.Column(db.Integer, primary_key=True)
    numero = db.Column(db.Integer, nullable=False)
    estado = db.Column(db.String(20), default="disponible") # disponible o ocupado
    codigo_qr = db.Column(db.String(100), unique=True, nullable=True)
    
    reservas = db.relationship('Reserva', backref='locker', lazy=True)

class Reserva(db.Model):
    __tablename__ = 'reserva'
    id = db.Column(db.Integer, primary_key=True)
    usuario_id = db.Column(db.Integer, db.ForeignKey('usuario.id'), nullable=False) # 💡 OPTIMIZADO: No puede ser nulo
    locker_id = db.Column(db.Integer, db.ForeignKey('locker.id'), nullable=False)   # 💡 OPTIMIZADO: No puede ser nulo
    fecha_inicio = db.Column(db.DateTime, default=datetime.utcnow, nullable=False)   # 💡 OPTIMIZADO: Fecha automática al crear
    fecha_fin = db.Column(db.DateTime, nullable=True) # Es nulo hasta que se finaliza la reserva
    estado = db.Column(db.String(20), default="activa") # 💡 OPTIMIZADO: "activa" o "finalizada"

class Ingreso(db.Model):
    __tablename__ = 'ingreso'
    id = db.Column(db.Integer, primary_key=True)
    usuario_id = db.Column(db.Integer, db.ForeignKey('usuario.id'))
    vigilante_id = db.Column(db.Integer, db.ForeignKey('usuario.id'))
    fecha_ingreso = db.Column(db.DateTime, default=datetime.utcnow)
    fecha_salida = db.Column(db.DateTime)
    
    # Relationships for clarification
    vigilante = db.relationship('Usuario', foreign_keys=[vigilante_id], backref='ingresos_supervisados')

class ConsultaIA(db.Model):
    __tablename__ = 'consulta_ia'

    id = db.Column(db.Integer, primary_key=True)
    usuario_id = db.Column(db.Integer, db.ForeignKey('usuario.id'), nullable=True)
    pregunta = db.Column(db.Text, nullable=False)
    respuesta = db.Column(db.Text, nullable=False)
    fecha = db.Column(db.DateTime, default=datetime.utcnow)

    usuario = db.relationship('Usuario', backref='consultas_ia')

class AperturaLocker(db.Model):
    __tablename__ = 'apertura_locker'

    id = db.Column(db.Integer, primary_key=True)
    usuario_id = db.Column(db.Integer, db.ForeignKey('usuario.id'), nullable=False)
    locker_id = db.Column(db.Integer, db.ForeignKey('locker.id'), nullable=False)
    fecha = db.Column(db.DateTime, default=datetime.utcnow)

    usuario = db.relationship('Usuario', backref='aperturas')
    locker = db.relationship('Locker', backref='aperturas')