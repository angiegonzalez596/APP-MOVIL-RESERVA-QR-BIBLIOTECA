# APP RESERVA QR

## Descripción General

APP Reserva QR es una solución para la gestión de casilleros inteligentes mediante códigos QR. El sistema permite a los usuarios consultar lockers disponibles, realizar reservas, generar códigos QR asociados a sus reservas y validar el acceso mediante escaneo.

El proyecto está compuesto por un backend desarrollado en Flask y una aplicación móvil desarrollada en Flutter, utilizando PostgreSQL como base de datos alojada en Neon.

---

# Arquitectura del Proyecto

La solución se encuentra organizada en dos componentes principales:

```text
APP RESERVA QR/
│
├── backend/
│   ├── app/
│   │   ├── domain/
│   │   │   └── entities/
│   │   ├── infrastructure/
│   │   │   ├── bd/
│   │   │   ├── qr/
│   │   │   └── security/
│   │   ├── interfaces/
│   │   │   └── api/
│   │   ├── use_cases/
│   │   ├── config.py
│   │   ├── extensions.py
│   │   └── __init__.py
│   │
│   ├── .env
│   ├── requirements.txt
│   └── run.py
│
├── frontend/
│   └── mobile/
│       ├── android/
│       ├── ios/
│       ├── lib/
│       ├── test/
│       └── pubspec.yaml
│
├── docs/
├── .gitignore
└── README.md
```

---

# Tecnologías Utilizadas

## Backend

* Python 3.12
* Flask
* Flask SQLAlchemy
* PostgreSQL
* Neon Database
* bcrypt
* QRCode
* Pillow

## Frontend

* Flutter
* Dart

## Herramientas de Desarrollo

* Git
* GitHub
* Visual Studio Code
* Postman
* Thunder Client

---

# Configuración del Backend

## 1. Clonar el repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
```

## 2. Ingresar al backend

```bash
cd backend
```

## 3. Crear entorno virtual

```bash
py -3.12 -m venv .venv
```

## 4. Activar entorno virtual

### Windows PowerShell

```bash
.\.venv\Scripts\Activate.ps1
```

## 5. Instalar dependencias

```bash
pip install -r requirements.txt
```

## 6. Crear archivo .env

Crear un archivo denominado `.env` dentro de la carpeta backend:

```env
DATABASE_URL=postgresql+psycopg://usuario:password@host/database
SECRET_KEY=clave_segura
```

## 7. Ejecutar la aplicación

```bash
python run.py
```

La API quedará disponible en:

```text
http://127.0.0.1:5000
```

---

# Configuración del Frontend

## 1. Ingresar al proyecto Flutter

```bash
cd frontend/mobile
```

## 2. Descargar dependencias

```bash
flutter pub get
```

## 3. Ejecutar la aplicación

```bash
flutter run
```

---

# Endpoints Disponibles

## Autenticación

| Método | Endpoint                        |
| ------ | ------------------------------- |
| POST   | /api/auth/register              |
| POST   | /api/auth/login                 |
| POST   | /api/auth/generate-qr/<user_id> |

## Usuarios

| Método | Endpoint           |
| ------ | ------------------ |
| GET    | /api/users/profile |
| GET    | /api/users/<id>    |

## Lockers

| Método | Endpoint      |
| ------ | ------------- |
| GET    | /api/lockers/ |
| POST   | /api/lockers/ |

## Reservas

| Método | Endpoint                     |
| ------ | ---------------------------- |
| GET    | /api/reservas/               |
| POST   | /api/reservas/               |
| GET    | /api/reservas/<user_id>      |
| PUT    | /api/reservas/<id>/finalizar |

## QR

| Método | Endpoint         |
| ------ | ---------------- |
| POST   | /api/qr/generate |
| POST   | /api/qr/scan     |

---

# Modelo de Datos

El sistema se basa en las siguientes entidades principales:

* Usuario
* Locker
* Reserva
* Registro QR

Estas entidades permiten gestionar la asignación temporal de lockers y la validación de acceso mediante códigos QR.

---

# Estado Actual del Proyecto

Actualmente se encuentra implementado:

* Estructura base del backend.
* Integración con PostgreSQL Neon.
* API REST funcional.
* Gestión de usuarios.
* Gestión de lockers.
* Gestión de reservas.
* Generación y validación de códigos QR.

Pendiente por implementar:

* Integración completa con Flutter.
* Mejoras de autenticación y autorización.
* Validaciones avanzadas de negocio.
* Optimización de experiencia de usuario móvil.

---

# Equipo de Desarrollo

Proyecto académico para la gestión inteligente de lockers mediante códigos QR utilizando Flask, PostgreSQL y Flutter.
