create database campersdb;

use campersdb;

CREATE TABLE Camper (
    id_camper INT AUTO_INCREMENT PRIMARY KEY,
    identificacion VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    nivel_riesgo VARCHAR(20)
);



CREATE TABLE Direccion (
    id_direccion INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    calle VARCHAR(100),
    ciudad VARCHAR(50),
    departamento VARCHAR(50),
    codigo_postal VARCHAR(10),
    pais VARCHAR(30)
);

CREATE TABLE Empresa (
    id_empresa INT AUTO_INCREMENT PRIMARY KEY,
    nombre_empresa VARCHAR(100) NOT NULL,
    nit VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE Tipo_Sede (
    id_tipo_sede INT AUTO_INCREMENT PRIMARY KEY,
    tipo_sede VARCHAR(50) NOT NULL  -- Ejemplo: 'Central', 'Regional', etc.
);

CREATE TABLE Acudiente (
    id_acudiente INT AUTO_INCREMENT PRIMARY KEY,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    telefono VARCHAR(15),
    email VARCHAR(80),
    parentesco VARCHAR(30)
);


CREATE TABLE Estado_Inscripcion (
    id_estado_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(50) NOT NULL,
    estado_inscripcion ENUM('Activa', 'Completada', 'Cancelada') DEFAULT 'Activa'
);


CREATE TABLE Usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre_usuario VARCHAR(30) NOT NULL,
    contrasena VARCHAR(128) NOT NULL,
    rol ENUM('admin','entrenador','camper','acudiente') NOT NULL,
    email VARCHAR(80)
);

CREATE TABLE Telefono_Camper (
    id_telefono INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(20) NOT NULL,
    tipo ENUM('movil', 'fijo', 'trabajo', 'otro') DEFAULT 'movil',
    es_principal BOOLEAN DEFAULT FALSE
);

CREATE TABLE Telefono_Trainner (
    id_telefono INT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(20) NOT NULL,
    tipo ENUM('movil', 'fijo', 'trabajo', 'otro') DEFAULT 'movil',
    es_principal BOOLEAN DEFAULT FALSE
);

CREATE TABLE Salon (
    id_salon INT AUTO_INCREMENT PRIMARY KEY,
    Nombre_salon VARCHAR(50) NOT NULL,
    Capacidad INT DEFAULT 33
);


CREATE TABLE Area_Entrenamiento (
    id_area INT AUTO_INCREMENT PRIMARY KEY,
    nombre_area VARCHAR(80) NOT NULL,
    descripcion VARCHAR(200),
    capacidad_maxima INT DEFAULT 33,  
    estado ENUM('Activo', 'Inactivo', 'Mantenimiento') DEFAULT 'Activo',
    ocupacion_actual INT DEFAULT 0,
    CONSTRAINT chk_ocupacion CHECK (ocupacion_actual <= capacidad_maxima)
);



CREATE TABLE Horario_Clase (
    id_horario INT AUTO_INCREMENT PRIMARY KEY,
    descripcion VARCHAR(100),  -- Ejemplo: "08:00-12:00"
    hora_inicio TIME,
    hora_fin TIME,
    dia_semana ENUM('Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes', 'Sabado', 'Domingo')
);


CREATE TABLE Estado_camper (
    id_estado int AUTO_INCREMENT PRIMARY KEY,
    nombre_estado ENUM('Egresado', 'Activo', 'Inactivo', 'Retirado', 'Graduado') DEFAULT 'Activo'
);

CREATE TABLE Ruta_BD(
    id_rutaBD int AUTO_INCREMENT PRIMARY KEY,
    BD VARCHAR(20) UNIQUE NOT NULL
);

CREATE TABLE Ruta_Entrenamiento (
    id_ruta INT AUTO_INCREMENT PRIMARY KEY,
    nombre_ruta VARCHAR(50) NOT NULL,
    sgdb_principal int not null,
    FOREIGN KEY (sgdb_principal) REFERENCES Ruta_BD(id_rutaBD)
);

CREATE TABLE Skill (
    id_skill INT AUTO_INCREMENT PRIMARY KEY,
    nombre_skill VARCHAR(50) NOT NULL,
    descripcion VARCHAR(200),
    id_ruta INT,
    FOREIGN KEY (id_ruta) REFERENCES Ruta_Entrenamiento(id_ruta)
);

CREATE TABLE Modulo_Aprendizaje (
    id_modulo INT AUTO_INCREMENT PRIMARY KEY,
    id_skill INT,
    nombre_modulo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (id_skill) REFERENCES Skill(id_skill)
);

CREATE TABLE Trainner (
    id_trainner int AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR (50) NOT NULL,
    apellido VARCHAR (50) NOT NULL,
    especialidad VARCHAR (50) NOT NULL,
    id_telefono int NOT NULL,
    FOREIGN KEY (id_telefono) REFERENCES Telefono_Trainner(id_telefono)
);



CREATE TABLE Asignacion_Salon_Horario (
    id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
    id_salon INT,
    id_horario INT,
    id_area INT,
    FOREIGN KEY (id_salon) REFERENCES Salon(id_salon),
    FOREIGN KEY (id_horario) REFERENCES Horario_Clase(id_horario),
    FOREIGN KEY (id_area) REFERENCES Area_Entrenamiento(id_area)

);

CREATE TABLE Asignacion_Trainner (
    id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
    id_trainner INT,
    id_ruta INT,
    id_area INT,
    FOREIGN KEY (id_ruta) REFERENCES Ruta_Entrenamiento(id_ruta),
    FOREIGN KEY (id_trainner) REFERENCES Trainner(id_trainner),
    FOREIGN KEY (id_area) REFERENCES Area_Entrenamiento(id_area) 

);

CREATE TABLE DATOS_CAMPER(
    id_datoscamper INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    id_acudiente int not null,
    id_estado int NOT NULL,
    id_direccion int NOT NULL,
    id_telefono int NOT NULL,
    id_usuario int NOT NULL,
    FOREIGN KEY (id_camper) REFERENCES Camper(id_camper),
    FOREIGN KEY (id_acudiente) REFERENCES Acudiente(id_acudiente),
    FOREIGN KEY (id_estado) REFERENCES Estado_camper(id_estado),
    FOREIGN KEY (id_direccion) REFERENCES Direccion(id_direccion),
    FOREIGN KEY (id_telefono) REFERENCES Telefono_Camper(id_telefono),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);



CREATE TABLE Inscripcion (
    id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_datoscamper INT,
    id_ruta INT,
    fecha_inscripcion DATE NOT NULL,
    id_estado_inscripcion INT,
    FOREIGN KEY (id_ruta) REFERENCES Ruta_Entrenamiento(id_ruta),
    FOREIGN KEY (id_datoscamper) REFERENCES DATOS_CAMPER(id_datoscamper),
    FOREIGN KEY (id_estado_inscripcion) REFERENCES Estado_Inscripcion(id_estado_inscripcion)
);



CREATE TABLE DATOS_TRAINNER(
    id_datos_trainner INT AUTO_INCREMENT PRIMARY KEY,
    id_trainner INT,
    id_telefono int NOT NULL,
    id_usuario int NOT NULL,
    FOREIGN KEY (id_trainner) REFERENCES Trainner(id_trainner),
    FOREIGN KEY (id_telefono) REFERENCES Telefono_Trainner(id_telefono),
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Historial_estado_camper(
    id_historialEstado int AUTO_INCREMENT PRIMARY KEY,
    id_camper int NOT NULL,
    id_estado int NOT NULL,
    fecha_modificacion DATE NOT NULL,
    FOREIGN KEY (id_camper) REFERENCES Camper(id_camper),
    FOREIGN KEY (id_estado) REFERENCES Estado_camper(id_estado)
);

CREATE TABLE Material_Ruta (
    id_material INT AUTO_INCREMENT PRIMARY KEY,
    id_modulo INT,
    titulo VARCHAR(150),
    descripcion TEXT,
    url_material VARCHAR(255),
    FOREIGN KEY (id_modulo) REFERENCES Modulo_Aprendizaje(id_modulo)
);

CREATE TABLE Ubicacion_Sede (
    id_ubicacion_sede INT AUTO_INCREMENT PRIMARY KEY,
    id_empresa INT,
    id_tipo_sede INT,
    ciudad VARCHAR(50) NOT NULL,
    direccion VARCHAR(150) NOT NULL,
    region VARCHAR(50),
    FOREIGN KEY (id_empresa) REFERENCES Empresa(id_empresa),
    FOREIGN KEY (id_tipo_sede) REFERENCES Tipo_Sede(id_tipo_sede)
);

CREATE TABLE Evaluacion (
    id_evaluacion INT AUTO_INCREMENT PRIMARY KEY,
    id_inscripcion INT,
    id_modulo INT,
    fecha_evaluacion DATE,
    nota_teorica DECIMAL(5,2),         
    nota_practica DECIMAL(5,2),        
    nota_trabajos_quizzes DECIMAL(5,2),  
    calificacion_final DECIMAL(5,2),    
    Estado ENUM('Aprobado', 'Reprobado'),
    FOREIGN KEY (id_inscripcion) REFERENCES Inscripcion(id_inscripcion),
    FOREIGN KEY (id_modulo) REFERENCES Modulo_Aprendizaje(id_modulo),
    CONSTRAINT chk_nota_teorica CHECK (nota_teorica >= 0 AND nota_teorica <= 100),
    CONSTRAINT chk_nota_practica CHECK (nota_practica >= 0 AND nota_practica <= 100),
    CONSTRAINT chk_nota_quizzes CHECK (nota_trabajos_quizzes >= 0 AND nota_trabajos_quizzes <= 100)
);

CREATE TABLE Notificacion (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    mensaje TEXT,
    fecha_notificacion DATETIME,
    leido BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_usuario) REFERENCES Usuario(id_usuario)
);

CREATE TABLE Notificacion_Trainer (
    id_notificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_datosentrenador INT,
    id_ruta INT,
    mensaje TEXT,
    fecha_notificacion DATETIME,
    leido BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (id_datosentrenador) REFERENCES DATOS_TRAINNER(id_datos_trainner),
    FOREIGN KEY (id_ruta) REFERENCES Ruta_Entrenamiento(id_ruta)
);

CREATE TABLE Grupo_Campers (
    id_grupo INT AUTO_INCREMENT PRIMARY KEY,
    nombre_grupo VARCHAR(50) NOT NULL,
    id_ruta INT NOT NULL,
    fecha_creacion DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (id_ruta) REFERENCES Ruta_Entrenamiento(id_ruta)
);


CREATE TABLE Grupo_Camper_Asignacion (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_grupo INT NOT NULL,
    id_camper INT NOT NULL,
    fecha_asignacion DATE DEFAULT (CURRENT_DATE),
    FOREIGN KEY (id_grupo) REFERENCES Grupo_Campers(id_grupo),
    FOREIGN KEY (id_camper) REFERENCES Camper(id_camper),
    UNIQUE (id_grupo, id_camper)
);

CREATE TABLE Asignacion_Entrenador_Grupo (
    id_asignacion INT AUTO_INCREMENT PRIMARY KEY,
    id_entrenador INT NOT NULL,
    id_grupo INT NOT NULL,
    id_area INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    FOREIGN KEY (id_entrenador) REFERENCES Trainner(id_trainner),
    FOREIGN KEY (id_grupo) REFERENCES Grupo_Campers(id_grupo),
    FOREIGN KEY (id_area) REFERENCES Area_Entrenamiento(id_area)
);


