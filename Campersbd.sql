create database campersdb;

use campersdb;

CREATE TABLE Camper (
    id_camper INT AUTO_INCREMENT PRIMARY KEY,
    identificacion VARCHAR(20) UNIQUE NOT NULL,
    nombres VARCHAR(50) NOT NULL,
    apellidos VARCHAR(50) NOT NULL,
    direccion VARCHAR(50        ),
    acudiente VARCHAR(50),
    telefono_contacto VARCHAR(20),
    id_estado int NOT NULL,
    nivel_riesgo VARCHAR(20),
    FOREIGN KEY (id_estado) REFERENCES Estado_camper(id_estado)
);

CREATE TABLE Ruta_Entrenamiento (
    id_ruta INT AUTO_INCREMENT PRIMARY KEY,
    nombre_ruta VARCHAR(50) NOT NULL,
    sgdb_principal VARCHAR(50),
    FOREIGN KEY (sgdb_principal) REFERENCES Ruta_BD(id_rutaBD)
);

CREATE TABLE Modulo_Aprendizaje (
    id_modulo INT AUTO_INCREMENT PRIMARY KEY,
    id_ruta INT,
    nombre_modulo VARCHAR(100) NOT NULL,
    descripcion TEXT,
    FOREIGN KEY (id_ruta) REFERENCES Ruta_Entrenamiento(id_ruta)
);

CREATE TABLE Trainner (
    id_trainner int AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR (50) NOT NULL,
    apellido VARCHAR (50) NOT NULL,
    especialidad VARCHAR (50) NOT NULL
);

CREATE TABLE Inscripcion (
    id_inscripcion INT AUTO_INCREMENT PRIMARY KEY,
    id_camper INT,
    id_ruta INT,
    fecha_inscripcion DATE NOT NULL,
    FOREIGN KEY (id_camper) REFERENCES Camper(id_camper) ,
    FOREIGN KEY (id_ruta) REFERENCES Ruta_Entrenamiento(id_ruta) 
);


CREATE TABLE Area_Entrenamiento (
    id_area INT AUTO_INCREMENT PRIMARY KEY,
    capacidad_maxima INT DEFAULT 33,
    horario_clases TIME NOT NULL
);

CREATE TABLE Salon (
    id_salon INT AUTO_INCREMENT PRIMARY KEY,
    id_area INT,
    Nombre_salon VARCHAR(50) NOT NULL,
    Capacidad INT DEFAULT 33,
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
CREATE TABLE Estado_camper (
    id_estado int AUTO_INCREMENT PRIMARY KEY,
    nombre_estado VARCHAR(50 UNIQUE NOT NULL)
);

CREATE TABLE Ruta_BD(
    id_rutaBD int AUTO_INCREMENT PRIMARY KEY,
    BD VARCHAR(20) UNIQUE NOT NULL
)


