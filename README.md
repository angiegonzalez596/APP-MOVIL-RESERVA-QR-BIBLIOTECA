# 📦 APP Reserva QR

Sistema de reserva inteligente de lockers mediante códigos QR, desarrollado con arquitectura limpia utilizando Flask, PostgreSQL y Flutter.

---

# 🚀 Descripción del proyecto

APP Reserva QR es una solución orientada a la gestión de casilleros inteligentes para instituciones educativas.

El sistema permite:

* Registro e inicio de sesión de usuarios.
* Gestión de lockers.
* Creación y finalización de reservas.
* Generación y escaneo de códigos QR.
* Registro de ingresos por validación QR.
* Consumo de API REST desde aplicación móvil Flutter.

---

# 🏗️ Arquitectura

El backend fue desarrollado siguiendo principios de Clean Architecture.

## Estructura del backend

```text
backend/
└── app/
    ├── domain/
    │   └── entities/
    ├── infrastructure/
    │   ├── bd/
    │   ├── qr/
    │   └── security/
    ├── interfaces/
    │   └── api/
    ├── use_cases/
    ├── config.py
    ├── extensions.py
    └── __init__.py
```

---

# 🛠️ Tecnologías utilizadas

## Backend

* Python 3.12
* Flask
* SQLAlchemy
* PostgreSQL
* Neon Database
* JWT
* bcrypt

## Frontend móvil

* Flutter
* Dart

## Herramientas

* Git
* GitHub
* Thunder Client / Postman
* VS Code

---

# ⚙️ Configuración del proyecto

## 1. Clonar repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
```

---

## 2. Crear entorno virtual

```bash
python -m venv venv
```

Activar entorno virtual:

### Windows

```bash
venv\Scripts\activate
```

---

## 3. Instalar dependencias

```bash
pip install -r requirements.txt
```

---

## 4. Configurar variables de entorno

Crear archivo `.env`

```env
DATABASE_URL=postgresql://usuario:password@host/database
SECRET_KEY=clave_segura
```

---

## 5. Ejecutar backend

```bash
python run.py
```

Servidor:

```text
http://127.0.0.1:5000
```

---

# 📌 Endpoints implementados

## 🔐 Autenticación

| Método | Endpoint                          |
| ------ | --------------------------------- |
| POST   | `/api/auth/register`              |
| POST   | `/api/auth/login`                 |
| POST   | `/api/auth/generate-qr/<user_id>` |

---

## 👤 Usuarios

| Método | Endpoint                       |
| ------ | ------------------------------ |
| GET    | `/api/users/profile?user_id=1` |
| GET    | `/api/users/<id>`              |

---

## 🧳 Lockers

| Método | Endpoint        |
| ------ | --------------- |
| GET    | `/api/lockers/` |
| POST   | `/api/lockers/` |

---

## 📅 Reservas

| Método | Endpoint                       |
| ------ | ------------------------------ |
| GET    | `/api/reservas/`               |
| POST   | `/api/reservas/`               |
| GET    | `/api/reservas/<user_id>`      |
| PUT    | `/api/reservas/<id>/finalizar` |

---

## 📱 QR e ingresos

| Método | Endpoint           |
| ------ | ------------------ |
| POST   | `/api/qr/generate` |
| POST   | `/api/qr/scan`     |

---

# 📲 Ejemplo de pruebas

## Registro de usuario

```http
POST /api/auth/register
```

```json
{
  "nombre": "Ronald",
  "email": "ronald@test.com",
  "password": "123456",
  "documento": "123456789",
  "codigo_estudiante": "EST001",
  "rol": "ESTUDIANTE"
}
```

---

## Crear locker

```http
POST /api/lockers/
```

```json
{
  "numero": 101,
  "estado": "DISPONIBLE"
}
```

---

## Crear reserva

```http
POST /api/reservas/
```

```json
{
  "usuario_id": 1,
  "locker_id": 1
}
```

---

# 🗄️ Base de datos

La base de datos utilizada es PostgreSQL alojada en Neon.

Modelos principales:

* Usuario
* Locker
* Reserva
* Ingreso

---

# 🔒 Seguridad

El proyecto incluye:

* Hash de contraseñas con bcrypt.
* Uso de JWT para autenticación.
* Validaciones de reservas activas.
* Control de lockers ocupados.

---

# 📱 Aplicación móvil Flutter

La carpeta `mobile/` contiene la aplicación Flutter encargada de consumir la API REST.

Funcionalidades previstas:

* Login móvil.
* Visualización de lockers.
* Reserva de lockers.
* Visualización de QR.
* Escaneo QR.

---

# 👨‍💻 Autores

Proyecto académico desarrollado para la gestión de reservas de lockers mediante QR.

Desarrollado con Flask + PostgreSQL + Flutter.
