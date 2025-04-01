-- 1.Insert into Camper
INSERT INTO Camper (identificacion, nombres, apellidos, nivel_riesgo)
VALUES 
    ('CAMP001', 'Juan', 'Pérez', 'Bajo'),
    ('CAMP002', 'Maria', 'Gomez', 'Moderado'),
    ('CAMP003', 'Carlos', 'Martinez', 'Bajo'),
    ('CAMP004', 'Laura', 'Hernandez', 'Alto'),
    ('CAMP005', 'Luis', 'Rodriguez', 'Bajo'),
    ('CAMP006', 'Isabel', 'Gonzalez', 'Moderado'),
    ('CAMP007', 'Ricardo', 'Lopez', 'Alto'),
    ('CAMP008', 'Patricia', 'Diaz', 'Bajo'),
    ('CAMP009', 'Miguel', 'Sanchez', 'Moderado'),
    ('CAMP010', 'Ana', 'Fernandez', 'Alto');


-- 2.Insert into Direccion (Bogotá, Bucaramanga, Tibú)
INSERT INTO Direccion (id_camper, calle, ciudad, departamento, codigo_postal, pais)
VALUES 
    (1, 'Carrera 10 #20-30', 'Bogotá', 'Cundinamarca', '110001', 'Colombia'),
    (2, 'Calle 45 #15-67', 'Bogotá', 'Cundinamarca', '110111', 'Colombia'),
    (3, 'Avenida El Dorado #68-90', 'Bogotá', 'Cundinamarca', '110051', 'Colombia'),
    (4, 'Carrera 50 #30-45', 'Bucaramanga', 'Santander', '680001', 'Colombia'),
    (5, 'Calle 40 #25-18', 'Bucaramanga', 'Santander', '680002', 'Colombia'),
    (6, 'Avenida La Rosita #21-33', 'Bucaramanga', 'Santander', '680003', 'Colombia'),
    (7, 'Calle 12 #9-19', 'Tibú', 'Norte de Santander', '542001', 'Colombia'),
    (8, 'Carrera 5 #7-16', 'Tibú', 'Norte de Santander', '542002', 'Colombia'),
    (9, 'Calle 6 #10-50', 'Tibú', 'Norte de Santander', '542003', 'Colombia'),
    (10, 'Calle 25 #5-60', 'Bogotá', 'Cundinamarca', '110071', 'Colombia');

-- 3.Insert into Empresa
INSERT INTO Empresa (nombre_empresa, nit) 
VALUES ('Campuslands Inc.', '123456789');

-- 4.Insert into Tipo_Sede
INSERT INTO Tipo_Sede (tipo_sede)
VALUES ('Central'), 
('Sucursal'),
('Regional');

-- 5.Insert into Acudiente
INSERT INTO Acudiente (nombres, apellidos, telefono, email, parentesco) 
VALUES 
    ('Maria', 'Lopez', '3001234567', 'maria.lopez@email.com', 'Madre'),
    ('Carlos', 'Gomez', '3002345678', 'carlos.gomez@email.com', 'Padre'),
    ('Juan', 'Perez', '3003456789', 'juan.perez@email.com', 'Hermano'),
    ('Ana', 'Santos', '3004567890', 'ana.santos@email.com', 'Madre'),
    ('Luis', 'Martinez', '3005678901', 'luis.martinez@email.com', 'Padre'),
    ('Roberto', 'Jimenez', '3006789012', 'roberto.jimenez@email.com', 'Tio'),
    ('Patricia', 'Rodriguez', '3007890123', 'patricia.rodriguez@email.com', 'Madre'),
    ('Isabel', 'Fernandez', '3008901234', 'isabel.fernandez@email.com', 'Hermana'),
    ('Ricardo', 'Ramirez', '3009012345', 'ricardo.ramirez@email.com', 'Padre'),
    ('Clara', 'Gonzalez', '3000123456', 'clara.gonzalez@email.com', 'Madre');

-- 6.Insert into Estado_Inscripcion
INSERT INTO Estado_Inscripcion (descripcion, estado_inscripcion)
VALUES 
    ('Inscripción activa en Python', 'Activa'),
    ('Inscripción completada en Java', 'Completada'),
    ('Inscripción cancelada en Ruby', 'Cancelada'),
    ('Inscripción activa en C++', 'Activa'),
    ('Inscripción completada en JavaScript', 'Completada'),
    ('Inscripción activa en SQL', 'Activa'),
    ('Inscripción cancelada en HTML', 'Cancelada'),
    ('Inscripción completada en CSS', 'Completada'),
    ('Inscripción activa en React', 'Activa'),
    ('Inscripción completada en Angular', 'Completada');

-- 7.Insert into Usuario
INSERT INTO Usuario (nombre_usuario, contrasena, rol, email)
VALUES 
    ('juanperez', 'password123', 'camper', 'juanperez@email.com'),
    ('admin1', 'adminpass', 'admin', 'admin@email.com'),
    ('entrenador1', 'trainerpass', 'entrenador', 'entrenador1@email.com'),
    ('camper123', 'passcamper', 'camper', 'camper123@email.com'),
    ('admin2', 'adminpass2', 'admin', 'admin2@email.com'),
    ('entrenador2', 'trainerpass2', 'entrenador', 'entrenador2@email.com'),
    ('juanita', 'juanpass', 'camper', 'juanita@email.com'),
    ('mario', 'mariopass', 'camper', 'mario@email.com'),
    ('trainer123', 'trainerpass123', 'entrenador', 'trainer123@email.com'),
    ('acudiente1', 'acudientepass', 'acudiente', 'acudiente1@email.com');

-- 8.Insert into Telefono_Camper
INSERT INTO Telefono_Camper (numero, tipo, es_principal)
VALUES 
    ('3007654321', 'movil', TRUE),
    ('3009876543', 'fijo', FALSE),
    ('3006543210', 'trabajo', FALSE),
    ('3001234567', 'movil', TRUE),
    ('3002345678', 'movil', FALSE),
    ('3003456789', 'movil', TRUE),
    ('3004567890', 'fijo', FALSE),
    ('3005678901', 'movil', TRUE),
    ('3006789012', 'trabajo', FALSE),
    ('3007890123', 'movil', TRUE);

-- 9.Insert into Telefono_Trainner
INSERT INTO Telefono_Trainner (numero, tipo, es_principal)
VALUES 
    ('3205551212', 'movil', TRUE),
    ('3205551213', 'fijo', FALSE),
    ('3205551214', 'trabajo', FALSE),
    ('3205551215', 'movil', TRUE),
    ('3205551216', 'movil', TRUE),
    ('3205551217', 'movil', FALSE),
    ('3205551218', 'trabajo', FALSE),
    ('3205551219', 'fijo', TRUE),
    ('3205551220', 'movil', TRUE),
    ('3205551221', 'movil', TRUE);

-- 10.Insert into Salon
INSERT INTO Salon (Nombre_salon, Capacidad)
VALUES 
    ('Salon A', 33),
    ('Salon B', 25),
    ('Salon C', 40),
    ('Salon D', 50),
    ('Salon E', 30),
    ('Salon F', 20),
    ('Salon G', 15),
    ('Salon H', 35),
    ('Salon I', 45),
    ('Salon J', 60);

-- Insert into Area_Entrenamiento (Updated for a Programming School)
INSERT INTO Area_Entrenamiento (nombre_area, descripcion, capacidad_maxima, estado, ocupacion_actual)
VALUES 
    ('Desarrollo Web', 'Aprende a crear sitios web interactivos usando HTML, CSS y JavaScript.', 33, 'Activo', 15),
    ('Desarrollo Móvil', 'Desarrolla aplicaciones para Android e iOS con tecnologías como React Native y Flutter.', 33, 'Activo', 30),
    ('Bases de Datos', 'Domina el uso de bases de datos SQL y NoSQL, incluyendo MySQL, MongoDB, y PostgreSQL.', 33, 'Activo', 21),
    ('Inteligencia Artificial', 'Estudia los fundamentos de IA y Machine Learning utilizando Python y TensorFlow.', 33, 'Activo', 28),
    ('Desarrollo de Videojuegos', 'Crea videojuegos con motores como Unity y Unreal Engine.', 33, 'Activo', 11),
    ('Ciberseguridad', 'Aprende a proteger sistemas y redes de ataques cibernéticos.', 33, 'Activo', 18),
    ('DevOps', 'Aprende a automatizar los procesos de desarrollo y despliegue usando herramientas como Docker y Kubernetes.', 33, 'Activo', 22),
    ('Cloud Computing', 'Domina los servicios de la nube utilizando AWS, Azure y Google Cloud.', 33, 'Activo', 31),
    ('Programación Backend', 'Desarrolla aplicaciones backend usando lenguajes como Node.js, Python y Java.', 33, 'Activo', 9),
    ('Programación Frontend', 'Desarrolla interfaces de usuario interactivas utilizando tecnologías como React, Vue.js y Angular.', 33, 'Activo', 12);


-- Insert into Horario_Clase
INSERT INTO Horario_Clase (descripcion, hora_inicio, hora_fin, dia_semana)
VALUES 
    ('08:00-12:00', '08:00:00', '12:00:00', 'Lunes'),
    ('14:00-18:00', '14:00:00', '18:00:00', 'Martes'),
    ('08:00-12:00', '08:00:00', '12:00:00', 'Miércoles'),
    ('14:00-18:00', '14:00:00', '18:00:00', 'Jueves'),
    ('08:00-12:00', '08:00:00', '12:00:00', 'Viernes'),
    ('14:00-18:00', '14:00:00', '18:00:00', 'Sábado'),
    ('08:00-12:00', '08:00:00', '12:00:00', 'Domingo'),
    ('10:00-14:00', '10:00:00', '14:00:00', 'Lunes'),
    ('15:00-19:00', '15:00:00', '19:00:00', 'Martes'),
    ('09:00-13:00', '09:00:00', '13:00:00', 'Miércoles');

-- Insert into Estado_camper
INSERT INTO Estado_camper (nombre_estado)
VALUES 
    ('Activo'), 
    ('Inactivo'), 
    ('Egresado'), 
    ('Retirado'),
    ('Graduado'),
    ('Activo'), 
    ('Inactivo'), 
    ('Egresado'), 
    ('Retirado'),
    ('Graduado');

-- Insert into Ruta_BD
INSERT INTO Ruta_BD (BD)
VALUES 
    ('MongoDB'), 
    ('MySQL'), 
    ('PostgreSQL'), 
    ('SQLite'),
    ('OracleDB'), 
    ('SQLServer'), 
    ('Redis'), 
    ('Cassandra'),
    ('MariaDB'), 
    ('Firebase');

-- Insert into Ruta_Entrenamiento
INSERT INTO Ruta_Entrenamiento (nombre_ruta, sgdb_principal)
VALUES 
    ('Python Beginner', 1),
    ('Java Advanced', 2),
    ('C++ Fundamentals', 3),
    ('React Basics', 4),
    ('Angular Essentials', 5),
    ('Ruby Basics', 6),
    ('JavaScript Beginner', 7),
    ('SQL Advanced', 8),
    ('CSS Mastery', 9),
    ('HTML Fundamentals', 10);

-- Insert into Skill
INSERT INTO Skill (nombre_skill, descripcion, id_ruta)
VALUES 
    ('Python', 'Fundamentals of Python', 1),
    ('Java', 'Advanced Java programming', 2),
    ('C++', 'Basic C++ programming', 3),
    ('React', 'Beginner level React development', 4),
    ('Angular', 'Introduction to Angular framework', 5),
    ('Ruby', 'Ruby basics and object-oriented programming', 6),
    ('JavaScript', 'JavaScript fundamentals for web development', 7),
    ('SQL', 'Advanced SQL for data manipulation', 8),
    ('CSS', 'Mastering CSS for web design', 9),
    ('HTML', 'Introduction to HTML and web structure', 10);

-- Insert into Modulo_Aprendizaje
INSERT INTO Modulo_Aprendizaje (id_skill, nombre_modulo, descripcion)
VALUES 
    (1, 'Introducción a Python', 'Conceptos básicos de Python'),
    (2, 'Introducción a Java', 'Conceptos fundamentales de Java'),
    (3, 'Conceptos básicos de C++', 'Aprende C++ desde cero'),
    (4, 'React para Principiantes', 'Construye tu primera app con React'),
    (5, 'Fundamentos de Angular', 'Aprende Angular paso a paso'),
    (6, 'Ruby para Principiantes', 'Comienza a programar con Ruby'),
    (7, 'JavaScript Básico', 'Aprende lo esencial de JavaScript'),
    (8, 'SQL Avanzado', 'Optimización y consultas complejas en SQL'),
    (9, 'CSS para Diseño Web', 'Aprende CSS para diseñar páginas web'),
    (10, 'HTML para Principiantes', 'Crea tu primera página web con HTML');

-- Insert into Trainner
INSERT INTO Trainner (nombre, apellido, especialidad, id_telefono)
VALUES 
    ('Carlos', 'Sanchez', 'Desarrollo de Software', 1),
    ('Maria', 'Lopez', 'Matemáticas Avanzadas', 2),
    ('Ricardo', 'Martinez', 'Redes y Seguridad', 3),
    ('Ana', 'Fernandez', 'Diseño Gráfico', 4),
    ('Luis', 'Ramirez', 'Físico Deportivo', 5),
    ('Patricia', 'Gonzalez', 'Gestión de Proyectos', 6),
    ('Fernando', 'Perez', 'Desarrollo Web', 7),
    ('Isabel', 'Mendoza', 'Python Avanzado', 8),
    ('Jaime', 'Rodriguez', 'Gestión de Bases de Datos', 9),
    ('Pedro', 'Gomez', 'Front-end Development', 10);

INSERT INTO Asignacion_Salon_Horario (id_salon, id_horario, id_area)
VALUES 
    (1, 1, 1), 
    (2, 2, 2),
    (3, 3, 3), 
    (4, 4, 4), 
    (5, 5, 5),
    (6, 6, 6), 
    (7, 7, 7), 
    (8, 8, 8),
    (9, 9, 9), 
    (10, 10, 10);


-- 20.Insert into Asignacion_Trainner
INSERT INTO Asignacion_Trainner (id_trainner, id_ruta, id_area)
VALUES 
    (1, 1, 1), 
    (2, 2, 2),
    (3, 3, 3), 
    (4, 4, 4), 
    (5, 5, 5),
    (6, 6, 6), 
    (7, 7, 7), 
    (8, 8, 8),
    (9, 9, 9), 
    (10, 10, 10);


-- Insert into DATOS_CAMPER
INSERT INTO DATOS_CAMPER (id_camper, id_acudiente, id_estado, id_direccion, id_telefono, id_usuario)
VALUES 
    (1, 1, 1, 1, 1, 1), 
    (2, 2, 2, 2, 2, 2),
    (3, 3, 3, 3, 3, 3), 
    (4, 4, 4, 4, 4, 4), 
    (5, 5, 5, 5, 5, 5),
    (6, 6, 6, 6, 6, 6), 
    (7, 7, 7, 7, 7, 7), 
    (8, 8, 8, 8, 8, 8),
    (9, 9, 9, 9, 9, 9), 
    (10, 10, 10, 10, 10, 10);

-- Insert into Inscripcion
INSERT INTO Inscripcion (id_datoscamper, id_ruta, fecha_inscripcion, id_estado_inscripcion)
VALUES 
    (1, 1, '2025-04-01', 1),
    (2, 2, '2025-04-02', 2),
    (3, 3, '2025-04-03', 3),
    (4, 4, '2025-04-04', 1),
    (5, 5, '2025-04-05', 2),
    (6, 6, '2025-04-06', 3),
    (7, 7, '2025-04-07', 1),
    (8, 8, '2025-04-08', 2),
    (9, 9, '2025-04-09', 3),
    (10, 10, '2025-04-10', 1);



    -- Insert into DATOS_TRAINNER
INSERT INTO DATOS_TRAINNER (id_trainner, id_telefono, id_usuario)
VALUES 
    (1, 1, 1), 
    (2, 2, 2),
    (3, 3, 3), 
    (4, 4, 4), 
    (5, 5, 5),
    (6, 6, 6), 
    (7, 7, 7), 
    (8, 8, 8),
    (9, 9, 9), 
    (10, 10, 10);

-- Insert into Historial_estado_camper
INSERT INTO Historial_estado_camper (id_camper, id_estado, fecha_modificacion)
VALUES 
    (1, 1, '2025-04-01'),
    (2, 2, '2025-04-02'),
    (3, 3, '2025-04-03'),
    (4, 4, '2025-04-04'),
    (5, 5, '2025-04-05'),
    (6, 6, '2025-04-06'),
    (7, 7, '2025-04-07'),
    (8, 8, '2025-04-08'),
    (9, 9, '2025-04-09'),
    (10, 10, '2025-04-10');

-- Insert into Material_Ruta
INSERT INTO Material_Ruta (id_modulo, titulo, descripcion, url_material)
VALUES 
    (1, 'MongoDB Intro', 'Introducción a MongoDB', 'http://example.com/mongodb_intro'),
    (2, 'MySQL Advanced Queries', 'Consultas avanzadas en MySQL', 'http://example.com/mysql_advanced'),
    (3, 'PostgreSQL for Professionals', 'PostgreSQL avanzado para profesionales', 'http://example.com/postgresql_pro'),
    (4, 'SQLite Basics', 'Fundamentos de SQLite', 'http://example.com/sqlite_basics'),
    (5, 'OracleDB Deep Dive', 'Profundización en OracleDB', 'http://example.com/oracledb_deep'),
    (6, 'SQLServer Optimization', 'Optimización en SQLServer', 'http://example.com/sqlserver_optimization'),
    (7, 'Redis Basics', 'Conceptos básicos de Redis', 'http://example.com/redis_basics'),
    (8, 'Cassandra Architecture', 'Arquitectura escalable con Cassandra', 'http://example.com/cassandra_architecture'),
    (9, 'MariaDB Performance Tuning', 'Optimización de consultas en MariaDB', 'http://example.com/mariadb_performance'),
    (10, 'Firebase Realtime Database', 'Base de datos en tiempo real con Firebase', 'http://example.com/firebase_realtime');



-- Insert into Ubicacion_Sede
INSERT INTO Ubicacion_Sede (id_empresa, id_tipo_sede, ciudad, direccion, region)
VALUES (1, 1, 'Bogotá', 'Calle 123, #45-67', 'Cundinamarca'),
VALUES (1, 1, 'TIBU', 'Calle 123, #45-67', 'Norte santander'),
VALUES (1, 1, 'Bucaramanga', 'Calle 123, #45-67', 'Santander');



-- Insert into Notificacion
INSERT INTO Notificacion (id_usuario, mensaje, fecha_notificacion, leido)
VALUES 
    (1, 'Tu inscripción ha sido confirmada para el curso de Desarrollo Web.', '2025-04-01 08:30:00', FALSE),
    (2, 'Recuerda entregar el proyecto final de la semana antes del viernes.', '2025-04-01 09:00:00', FALSE),
    (3, 'Nuevo material disponible en la ruta de Inteligencia Artificial.', '2025-04-01 10:00:00', FALSE),
    (4, 'No olvides la sesión de revisión de código a las 3:00 PM.', '2025-04-01 11:30:00', TRUE),
    (5, 'Tu solicitud de cambio de grupo ha sido procesada.', '2025-04-01 12:00:00', TRUE),
    (6, 'Nuevo grupo asignado para la ruta de Desarrollo Móvil.', '2025-04-01 14:00:00', FALSE),
    (7, 'Estás inscrito en la próxima clase de Ciberseguridad.', '2025-04-01 15:00:00', TRUE),
    (8, 'Tu evaluación teórica se ha publicado.', '2025-04-01 16:00:00', FALSE),
    (9, 'Recuerda que la evaluación práctica es el próximo viernes.', '2025-04-01 17:00:00', TRUE),
    (10, 'Se ha actualizado tu calificación final del curso de Backend.', '2025-04-01 18:00:00', FALSE);


    -- Insert into Notificacion_Trainer
INSERT INTO Notificacion_Trainer (id_datosentrenador, id_ruta, mensaje, fecha_notificacion, leido)
VALUES 
    (1, 1, 'Nuevo grupo asignado para el curso de Desarrollo Web.', '2025-04-01 08:30:00', FALSE),
    (2, 2, 'Revisión de proyectos a realizar en la clase de Inteligencia Artificial.', '2025-04-01 09:00:00', FALSE),
    (3, 3, 'Material extra disponible para la ruta de Ciberseguridad.', '2025-04-01 10:00:00', FALSE),
    (4, 4, 'Estudiantes necesitan asistencia adicional en la asignatura de Backend.', '2025-04-01 11:00:00', TRUE),
    (5, 5, 'Próximo examen de habilidades programáticas, prepara a tu grupo.', '2025-04-01 12:00:00', FALSE),
    (6, 6, 'Cambio de horario en la clase de Desarrollo Móvil.', '2025-04-01 13:00:00', TRUE),
    (7, 7, 'Nuevo curso disponible sobre DevOps, por favor comunícalo a tu grupo.', '2025-04-01 14:00:00', FALSE),
    (8, 8, 'Revisión de evaluaciones prácticas de la última sesión de desarrollo web.', '2025-04-01 15:00:00', TRUE),
    (9, 9, 'Clase especial de revisión sobre bases de datos, asistan todos.', '2025-04-01 16:00:00', FALSE),
    (10, 10, 'Cambio de grupo asignado en la ruta de Desarrollo de Videojuegos.', '2025-04-01 17:00:00', TRUE);


-- 30.Insert into Grupo_Campers
INSERT INTO Grupo_Campers (nombre_grupo, id_ruta, fecha_creacion)
VALUES 
    ('Grupo A - Web Dev', 1, '2025-04-01'),
    ('Grupo B - IA', 2, '2025-04-01'),
    ('Grupo C - Backend', 3, '2025-04-01'),
    ('Grupo D - Ciberseguridad', 4, '2025-04-01'),
    ('Grupo E - Videojuegos', 5, '2025-04-01'),
    ('Grupo F - Móvil', 6, '2025-04-01'),
    ('Grupo G - DevOps', 7, '2025-04-01'),
    ('Grupo H - Cloud', 8, '2025-04-01'),
    ('Grupo I - Full Stack', 9, '2025-04-01'),
    ('Grupo J - QA', 10, '2025-04-01');

-- Insert into Grupo_Camper_Asignacion
INSERT INTO Grupo_Camper_Asignacion (id_grupo, id_camper, fecha_asignacion)
VALUES 
    (1, 1, '2025-04-01'),
    (2, 2, '2025-04-01'),
    (3, 3, '2025-04-01'),
    (4, 4, '2025-04-01'),
    (5, 5, '2025-04-01'),
    (6, 6, '2025-04-01'),
    (7, 7, '2025-04-01'),
    (8, 8, '2025-04-01'),
    (9, 9, '2025-04-01'),
    (10, 10, '2025-04-01');

    -- Insert into Evaluacion
INSERT INTO Evaluacion (id_inscripcion, id_skill, fecha_evaluacion, nota_teorica, nota_practica, nota_trabajos_quizzes, calificacion_final)
VALUES 
    (1, 1, '2025-04-01', 85.00, 90.00, 88.00, 87.67),
    (2, 2, '2025-04-01', 78.00, 82.00, 80.00, 80.00),
    (3, 3, '2025-04-01', 92.00, 95.00, 94.00, 93.67),
    (4, 4, '2025-04-01', 88.00, 85.00, 87.00, 86.67),
    (5, 5, '2025-04-01', 90.00, 91.00, 92.00, 91.00),
    (6, 6, '2025-04-01', 75.00, 78.00, 80.00, 77.67),
    (7, 7, '2025-04-01', 95.00, 96.00, 98.00, 96.33),
    (8, 8, '2025-04-01', 80.00, 85.00, 83.00, 82.67),
    (9, 9, '2025-04-01', 72.00, 70.00, 75.00, 72.33),
    (10, 10, '2025-04-01', 89.00, 88.00, 87.00, 88.00);



-- Insert into Asignacion_Entrenador_Grupo
INSERT INTO Asignacion_Entrenador_Grupo (id_entrenador, id_grupo, id_area, fecha_inicio, fecha_fin)
VALUES 
    (1, 1, 1, '2025-04-01', NULL),
    (2, 2, 2, '2025-04-01', NULL),
    (3, 3, 3, '2025-04-01', NULL),
    (4, 4, 4, '2025-04-01', NULL),
    (5, 5, 5, '2025-04-01', NULL),
    (6, 6, 6, '2025-04-01', NULL),
    (7, 7, 7, '2025-04-01', NULL),
    (8, 8, 8, '2025-04-01', NULL),
    (9, 9, 9, '2025-04-01', NULL),
    (10, 10, 10, '2025-04-01', NULL);

