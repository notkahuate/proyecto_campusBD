# 🗄️ Procedimientos Almacenados en SQL

Este documento contiene una lista de 20 procedimientos almacenados diseñados para gestionar la administración de campers, trainers, rutas y evaluaciones dentro del sistema.
## 📋 Categorías de Consultas

| Categoría | Enlace |
|-----------|--------|
| 📌 Consultas de Campers | [🔍 Ver](Consultas.MD) |
| 📌 Consultas de Evaluaciones | [🔍 Ver](consultas2.MD) |
| 📌 Consultas de Rutas | [🔍 Ver](consultas3.MD) |
| 📌 Consultas de Trainers | [🔍 Ver](consultas4.MD) |
| 📌 SubConsultas | [🔍 Ver](subconsultas.md) |
| 📌 Procedimientos | [🔍 Ver](Procedimientos.MD) |
| 📌 JOINs Básicos | [🔍 Ver](Joins.MD) |
| 📌 JOINs con condiciones específicas | [🔍 Ver](Joins2.MD) |
| 📌 JOINs con funciones de agregación | [🔍 Ver](Joins3.MD) |
| 📌 TRIGGERS | [🔍 Ver](bd/triggers.sql) |


## 📌 Lista de Procedimientos Almacenados

1. **Registrar un nuevo camper con toda su información personal y estado inicial.**
```sql
DELIMITER $$
CREATE PROCEDURE registrar_camper(
    IN p_nombres VARCHAR(50),
    IN p_apellidos VARCHAR(50),
    IN p_identificacion VARCHAR(20),
    IN p_direccion VARCHAR(100),
    IN p_telefono VARCHAR(15),
    IN p_acudiente_nombre VARCHAR(100),
    IN p_acudiente_telefono VARCHAR(15)
)
BEGIN
    DECLARE v_id_camper INT;
    DECLARE v_id_direccion INT;
    DECLARE v_id_telefono INT;
    DECLARE v_id_acudiente INT;
    DECLARE v_id_usuario INT;
    
    START TRANSACTION;
    
    -- Insertar dirección
    INSERT INTO Direccion(direccion) VALUES(p_direccion);
    SET v_id_direccion = LAST_INSERT_ID();
    
    -- Insertar teléfono camper
    INSERT INTO Telefono_Camper(telefono) VALUES(p_telefono);
    SET v_id_telefono = LAST_INSERT_ID();
    
    -- Insertar acudiente
    INSERT INTO Acudiente(nombre, telefono) 
    VALUES(p_acudiente_nombre, p_acudiente_telefono);
    SET v_id_acudiente = LAST_INSERT_ID();
    
    -- Insertar camper
    INSERT INTO Camper(nombres, apellidos, identificacion) 
    VALUES(p_nombres, p_apellidos, p_identificacion);
    SET v_id_camper = LAST_INSERT_ID();
    
    -- Crear usuario
    INSERT INTO Usuario(username, password, rol)
    VALUES(p_identificacion, p_identificacion, 'camper');
    SET v_id_usuario = LAST_INSERT_ID();
    
    -- Insertar datos completos del camper
    INSERT INTO DATOS_CAMPER(
        id_camper, id_acudiente, id_estado, id_direccion, 
        id_telefono, id_usuario
    ) VALUES(
        v_id_camper, v_id_acudiente, 
        (SELECT id_estado FROM Estado_camper WHERE nombre_estado = 'Inscrito'),
        v_id_direccion, v_id_telefono, v_id_usuario
    );
    
    COMMIT;
    
    SELECT 'Camper registrado exitosamente' as mensaje;
    
    EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error al registrar el camper';
END$$
DELIMITER ;

```

2.  **Actualizar el estado de un camper luego de completar el proceso de ingreso.**
```sql

DELIMITER $$
CREATE PROCEDURE actualizar_estado_camper(
    IN p_id_camper INT,
    IN p_nuevo_estado VARCHAR(20)
)
BEGIN
    DECLARE v_id_estado INT;
    
    -- Obtener ID del nuevo estado
    SELECT id_estado INTO v_id_estado 
    FROM Estado_camper 
    WHERE nombre_estado = p_nuevo_estado;
    
    IF v_id_estado IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Estado no válido';
    END IF;
    
    -- Actualizar estado
    UPDATE DATOS_CAMPER 
    SET id_estado = v_id_estado
    WHERE id_camper = p_id_camper;
    
    -- Registrar en historial
    INSERT INTO Historial_estado_camper(
        id_camper, id_estado, fecha_modificacion
    ) VALUES (
        p_id_camper, v_id_estado, CURRENT_DATE
    );
    
    SELECT 'Estado actualizado correctamente' as mensaje;
END$$
DELIMITER ;
```

3.  **Procesar la inscripción de un camper a una ruta específica.**
```sql

DELIMITER $$
CREATE PROCEDURE inscribir_camper_ruta(
    IN p_id_camper INT,
    IN p_id_ruta INT
)
BEGIN
    DECLARE v_id_datoscamper INT;
    DECLARE v_cupo_disponible BOOLEAN;
    
    -- Verificar disponibilidad en la ruta
    SELECT hay_cupos_area(ae.id_area) INTO v_cupo_disponible
    FROM Ruta_Entrenamiento re
    INNER JOIN Area_Entrenamiento ae ON re.id_area = ae.id_area
    WHERE re.id_ruta = p_id_ruta;
    
    IF NOT v_cupo_disponible THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay cupos disponibles en esta ruta';
    END IF;
    
    -- Obtener id_datoscamper
    SELECT id_datoscamper INTO v_id_datoscamper
    FROM DATOS_CAMPER WHERE id_camper = p_id_camper;
    
    -- Crear inscripción
    INSERT INTO Inscripcion(
        id_datoscamper, id_ruta, fecha_inscripcion, id_estado_inscripcion
    ) VALUES (
        v_id_datoscamper, p_id_ruta, CURRENT_DATE, 1
    );
    
    -- Crear evaluaciones iniciales para cada módulo
    INSERT INTO Evaluacion (id_inscripcion, id_modulo, fecha_evaluacion)
    SELECT LAST_INSERT_ID(), ma.id_modulo, CURRENT_DATE
    FROM Modulo_Aprendizaje ma
    INNER JOIN Skill s ON ma.id_skill = s.id_skill
    WHERE s.id_ruta = p_id_ruta;
    
    SELECT 'Inscripción procesada exitosamente' as mensaje;
END$$
DELIMITER ;
```

4.  **Registrar una evaluación completa (teórica, práctica y quizzes) para un camper.**
```sql
DELIMITER $$
CREATE PROCEDURE registrar_evaluacion(
    IN p_id_inscripcion INT,
    IN p_id_modulo INT,
    IN p_nota_teorica DECIMAL(5,2),
    IN p_nota_practica DECIMAL(5,2),
    IN p_nota_quizzes DECIMAL(5,2)
)
BEGIN
    DECLARE v_calificacion_final DECIMAL(5,2);
    DECLARE v_estado VARCHAR(20);
    
    -- Calcular nota final
    SET v_calificacion_final = (p_nota_teorica * 0.3) + 
                              (p_nota_practica * 0.6) + 
                              (p_nota_quizzes * 0.1);
    
    -- Determinar estado
    SET v_estado = CASE
        WHEN v_calificacion_final >= 60 THEN 'Aprobado'
        ELSE 'Bajo_Rendimiento'
    END;
    
    -- Registrar evaluación
    UPDATE Evaluacion SET
        nota_teorica = p_nota_teorica,
        nota_practica = p_nota_practica,
        nota_trabajos_quizzes = p_nota_quizzes,
        calificacion_final = v_calificacion_final,
        Estado = v_estado,
        fecha_evaluacion = CURRENT_DATE
    WHERE id_inscripcion = p_id_inscripcion 
    AND id_modulo = p_id_modulo;
    
    SELECT 'Evaluación registrada exitosamente' as mensaje;
END$$
DELIMITER ;

```

5.  **Calcular y registrar automáticamente la nota final de un módulo.**
```sql

DELIMITER $$
CREATE PROCEDURE calcular_nota_final_modulo(
    IN p_id_inscripcion INT,
    IN p_id_modulo INT
)
BEGIN
    DECLARE v_nota_final DECIMAL(5,2);
    DECLARE v_estado VARCHAR(20);
    
    -- Calcular nota final
    SELECT 
        (nota_teorica * 0.3) + 
        (nota_practica * 0.6) + 
        (nota_trabajos_quizzes * 0.1)
    INTO v_nota_final
    FROM Evaluacion
    WHERE id_inscripcion = p_id_inscripcion 
    AND id_modulo = p_id_modulo;
    
    -- Determinar estado
    SET v_estado = CASE
        WHEN v_nota_final >= 60 THEN 'Aprobado'
        ELSE 'Bajo_Rendimiento'
    END;
    
    -- Actualizar evaluación
    UPDATE Evaluacion SET
        calificacion_final = v_nota_final,
        Estado = v_estado
    WHERE id_inscripcion = p_id_inscripcion 
    AND id_modulo = p_id_modulo;
    
    SELECT 'Nota final calculada y registrada' as mensaje;
END$$
DELIMITER ;
```

6.  **Asignar campers aprobados a una ruta de acuerdo con la disponibilidad del área.**
```sql

DELIMITER $$
CREATE PROCEDURE asignar_campers_ruta(
    IN p_id_ruta_origen INT,
    IN p_id_ruta_destino INT
)
BEGIN
    DECLARE v_cupos_disponibles INT;
    
    -- Verificar cupos disponibles
    SELECT (capacidad_maxima - ocupacion_actual) INTO v_cupos_disponibles
    FROM Area_Entrenamiento ae
    INNER JOIN Ruta_Entrenamiento re ON ae.id_area = re.id_area
    WHERE re.id_ruta = p_id_ruta_destino;
    
    IF v_cupos_disponibles <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay cupos disponibles';
    END IF;
    
    -- Asignar campers aprobados
    INSERT INTO Inscripcion(id_datoscamper, id_ruta, fecha_inscripcion, id_estado_inscripcion)
    SELECT DISTINCT dc.id_datoscamper, p_id_ruta_destino, CURRENT_DATE, 1
    FROM DATOS_CAMPER dc
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    WHERE i.id_ruta = p_id_ruta_origen
    AND e.Estado = 'Aprobado'
    LIMIT v_cupos_disponibles;
    
    SELECT 'Campers asignados exitosamente' as mensaje;
END$$
DELIMITER ;
```

7.  **Asignar un trainer a una ruta y área específica, validando el horario.**
```sql
DELIMITER $$
CREATE PROCEDURE asignar_trainer(
    IN p_id_trainer INT,
    IN p_id_ruta INT,
    IN p_id_area INT,
    IN p_id_horario INT
)
BEGIN
    -- Verificar disponibilidad del trainer
    IF NOT trainer_disponible(p_id_trainer, 
        (SELECT hora_inicio FROM Horario_Clase WHERE id_horario = p_id_horario),
        (SELECT hora_fin FROM Horario_Clase WHERE id_horario = p_id_horario),
        (SELECT dia_semana FROM Horario_Clase WHERE id_horario = p_id_horario)
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Trainer no disponible en este horario';
    END IF;
    
    -- Asignar trainer a ruta
    INSERT INTO Asignacion_Trainner(id_trainner, id_ruta, id_area)
    VALUES(p_id_trainer, p_id_ruta, p_id_area);
    
    -- Asignar trainer al área con horario
    INSERT INTO Asignacion_Entrenador_Grupo(
        id_entrenador, id_area, id_horario
    ) VALUES(
        p_id_trainer, p_id_area, p_id_horario
    );
    
    SELECT 'Trainer asignado exitosamente' as mensaje;
END$$
DELIMITER ;

```

8.  **Registrar una nueva ruta con sus módulos y SGDB asociados.**

```sql
DELIMITER $$
CREATE PROCEDURE registrar_ruta(
    IN p_nombre_ruta VARCHAR(100),
    IN p_descripcion TEXT,
    IN p_id_sgdb INT
)
BEGIN
    DECLARE v_id_ruta INT;
    
    -- Crear ruta
    INSERT INTO Ruta_Entrenamiento(
        nombre_ruta, descripcion, sgdb_principal
    ) VALUES(
        p_nombre_ruta, p_descripcion, p_id_sgdb
    );
    
    SET v_id_ruta = LAST_INSERT_ID();
    
    -- Crear skills básicos para la ruta
    INSERT INTO Skill(id_ruta, nombre_skill)
    VALUES
        (v_id_ruta, 'Fundamentos'),
        (v_id_ruta, 'Desarrollo'),
        (v_id_ruta, 'Avanzado');
    
    SELECT 'Ruta registrada exitosamente' as mensaje;
END$$
DELIMITER ;

```

9.  **Registrar una nueva área de entrenamiento con su capacidad y horarios.**
```sql

DELIMITER $$
CREATE PROCEDURE registrar_area(
    IN p_nombre_area VARCHAR(50),
    IN p_capacidad_maxima INT
)
BEGIN
    -- Crear área
    INSERT INTO Area_Entrenamiento(
        nombre_area, capacidad_maxima, ocupacion_actual, estado
    ) VALUES(
        p_nombre_area, p_capacidad_maxima, 0, 'Activo'
    );
    
    SELECT 'Área registrada exitosamente' as mensaje;
END$$
DELIMITER ;
```

10.  **Consultar disponibilidad de horario en un área determinada.**
```sql

DELIMITER $$
CREATE PROCEDURE consultar_disponibilidad_area(
    IN p_id_area INT,
    IN p_dia VARCHAR(20)
)
BEGIN
    SELECT 
        hc.hora_inicio,
        hc.hora_fin,
        CASE 
            WHEN aeg.id_asignacion IS NULL THEN 'Disponible'
            ELSE 'Ocupado'
        END as estado,
        COALESCE(t.nombre, 'N/A') as trainer_asignado
    FROM Horario_Clase hc
    LEFT JOIN Asignacion_Entrenador_Grupo aeg 
        ON hc.id_horario = aeg.id_horario AND aeg.id_area = p_id_area
    LEFT JOIN Trainner t ON aeg.id_entrenador = t.id_trainner
    WHERE hc.dia_semana = p_dia
    ORDER BY hc.hora_inicio;
END$$
DELIMITER ;

```
11.  **Reasignar a un camper a otra ruta en caso de bajo rendimiento.**
```sql
DELIMITER $$
CREATE PROCEDURE reasignar_camper_bajo_rendimiento(
    IN p_id_camper INT,
    IN p_id_nueva_ruta INT
)
BEGIN
    DECLARE v_id_datoscamper INT;
    DECLARE v_promedio DECIMAL(5,2);
    
    -- Verificar promedio actual
    SELECT AVG(e.calificacion_final), dc.id_datoscamper 
    INTO v_promedio, v_id_datoscamper
    FROM DATOS_CAMPER dc
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    WHERE dc.id_camper = p_id_camper
    GROUP BY dc.id_datoscamper;
    
    IF v_promedio >= 60 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El camper no requiere reasignación';
    END IF;
    
    -- Crear nueva inscripción
    INSERT INTO Inscripcion(
        id_datoscamper, id_ruta, fecha_inscripcion, id_estado_inscripcion
    ) VALUES (
        v_id_datoscamper, p_id_nueva_ruta, CURRENT_DATE, 1
    );
    
    -- Registrar notificación
    INSERT INTO Notificacion(id_usuario, mensaje, fecha_notificacion)
    SELECT dc.id_usuario, 
           CONCAT('Has sido reasignado a una nueva ruta debido a bajo rendimiento'), 
           CURRENT_TIMESTAMP
    FROM DATOS_CAMPER dc
    WHERE dc.id_camper = p_id_camper;
    
    SELECT 'Camper reasignado exitosamente' as mensaje;
END$$
DELIMITER ;

```
12.  **Cambiar el estado de un camper a “Graduado” al finalizar todos los módulos.**
```sql
DELIMITER $$
CREATE PROCEDURE graduar_camper(
    IN p_id_camper INT
)
BEGIN
    DECLARE v_modulos_totales INT;
    DECLARE v_modulos_aprobados INT;
    DECLARE v_promedio_final DECIMAL(5,2);
    
    -- Verificar requisitos de graduación
    SELECT 
        COUNT(DISTINCT ma.id_modulo),
        COUNT(DISTINCT CASE WHEN e.Estado = 'Aprobado' THEN e.id_modulo END),
        AVG(e.calificacion_final)
    INTO v_modulos_totales, v_modulos_aprobados, v_promedio_final
    FROM DATOS_CAMPER dc
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Ruta_Entrenamiento re ON i.id_ruta = re.id_ruta
    INNER JOIN Skill s ON re.id_ruta = s.id_ruta
    INNER JOIN Modulo_Aprendizaje ma ON s.id_skill = ma.id_skill
    LEFT JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    WHERE dc.id_camper = p_id_camper;
    
    IF v_modulos_aprobados < v_modulos_totales OR v_promedio_final < 60 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El camper no cumple los requisitos para graduarse';
    END IF;
    
    -- Actualizar estado a Graduado
    UPDATE DATOS_CAMPER 
    SET id_estado = (SELECT id_estado FROM Estado_camper WHERE nombre_estado = 'Graduado')
    WHERE id_camper = p_id_camper;
    
    SELECT 'Camper graduado exitosamente' as mensaje;
END$$
DELIMITER ;

```
13.  **Consultar y exportar todos los datos de rendimiento de un camper.**
```sql

DELIMITER $$
CREATE PROCEDURE consultar_rendimiento_camper(
    IN p_id_camper INT
)
BEGIN
    -- Información general
    SELECT 
        c.nombres,
        c.apellidos,
        re.nombre_ruta,
        ROUND(AVG(e.calificacion_final), 2) as promedio_general,
        COUNT(DISTINCT CASE WHEN e.Estado = 'Aprobado' THEN e.id_modulo END) as modulos_aprobados,
        COUNT(DISTINCT CASE WHEN e.Estado = 'Bajo_Rendimiento' THEN e.id_modulo END) as modulos_reprobados,
        ec.nombre_estado as estado_actual
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Estado_camper ec ON dc.id_estado = ec.id_estado
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Ruta_Entrenamiento re ON i.id_ruta = re.id_ruta
    LEFT JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    WHERE c.id_camper = p_id_camper
    GROUP BY c.id_camper, c.nombres, c.apellidos, re.nombre_ruta, ec.nombre_estado;
    
    -- Detalle de evaluaciones
    SELECT 
        ma.nombre_modulo,
        e.nota_teorica,
        e.nota_practica,
        e.nota_trabajos_quizzes,
        e.calificacion_final,
        e.Estado,
        e.fecha_evaluacion
    FROM DATOS_CAMPER dc
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    INNER JOIN Modulo_Aprendizaje ma ON e.id_modulo = ma.id_modulo
    WHERE dc.id_camper = p_id_camper
    ORDER BY e.fecha_evaluacion DESC;
END$$
DELIMITER ;
```
14.  **Registrar la asistencia a clases por área y horario.**
```sql
DELIMITER $$
CREATE PROCEDURE registrar_asistencia(
    IN p_id_camper INT,
    IN p_id_area INT,
    IN p_id_horario INT,
    IN p_asistio BOOLEAN
)
BEGIN
    INSERT INTO Asistencia(
        id_camper,
        id_area,
        id_horario,
        fecha_asistencia,
        asistio
    ) VALUES (
        p_id_camper,
        p_id_area,
        p_id_horario,
        CURRENT_DATE,
        p_asistio
    );
    
    -- Notificar si no asistió
    IF NOT p_asistio THEN
        INSERT INTO Notificacion(id_usuario, mensaje, fecha_notificacion)
        SELECT dc.id_usuario, 
               'Se ha registrado una inasistencia a clase', 
               CURRENT_TIMESTAMP
        FROM DATOS_CAMPER dc
        WHERE dc.id_camper = p_id_camper;
    END IF;
    
    SELECT 'Asistencia registrada exitosamente' as mensaje;
END$$
DELIMITER ;

```
15.  **Generar reporte mensual de notas por ruta.**
```sql
DELIMITER $$
CREATE PROCEDURE generar_reporte_mensual_notas(
    IN p_mes INT,
    IN p_año INT
)
BEGIN
    SELECT 
        re.nombre_ruta,
        COUNT(DISTINCT i.id_datoscamper) as total_campers,
        ROUND(AVG(e.calificacion_final), 2) as promedio_general,
        COUNT(DISTINCT CASE WHEN e.Estado = 'Aprobado' THEN e.id_evaluacion END) as evaluaciones_aprobadas,
        COUNT(DISTINCT CASE WHEN e.Estado = 'Bajo_Rendimiento' THEN e.id_evaluacion END) as evaluaciones_reprobadas,
        MIN(e.calificacion_final) as nota_minima,
        MAX(e.calificacion_final) as nota_maxima
    FROM Ruta_Entrenamiento re
    INNER JOIN Inscripcion i ON re.id_ruta = i.id_ruta
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    WHERE MONTH(e.fecha_evaluacion) = p_mes
    AND YEAR(e.fecha_evaluacion) = p_año
    GROUP BY re.id_ruta, re.nombre_ruta
    ORDER BY promedio_general DESC;
END$$
DELIMITER ;

```
16.  **Validar y registrar la asignación de un salón a una ruta sin exceder la capacidad.**
```sql
DELIMITER $$
CREATE PROCEDURE asignar_salon_ruta(
    IN p_id_ruta INT,
    IN p_id_area INT
)
BEGIN
    DECLARE v_capacidad_maxima INT;
    DECLARE v_campers_inscritos INT;
    
    -- Verificar capacidad del área
    SELECT capacidad_maxima INTO v_capacidad_maxima
    FROM Area_Entrenamiento
    WHERE id_area = p_id_area;
    
    -- Contar campers inscritos
    SELECT COUNT(*) INTO v_campers_inscritos
    FROM Inscripcion
    WHERE id_ruta = p_id_ruta;
    
    IF v_campers_inscritos > v_capacidad_maxima THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La capacidad del área es insuficiente para la cantidad de campers';
    END IF;
    
    -- Asignar área a ruta
    UPDATE Ruta_Entrenamiento
    SET id_area = p_id_area
    WHERE id_ruta = p_id_ruta;
    
    -- Actualizar ocupación del área
    UPDATE Area_Entrenamiento
    SET ocupacion_actual = v_campers_inscritos
    WHERE id_area = p_id_area;
    
    SELECT 'Salón asignado exitosamente' as mensaje;
END$$
DELIMITER ;

```
17.  **Registrar cambio de horario de un trainer.**
```sql
DELIMITER $$
CREATE PROCEDURE cambiar_horario_trainer(
    IN p_id_trainer INT,
    IN p_id_area INT,
    IN p_id_horario_antiguo INT,
    IN p_id_horario_nuevo INT
)
BEGIN
    -- Verificar disponibilidad del nuevo horario
    IF NOT trainer_disponible(p_id_trainer,
        (SELECT hora_inicio FROM Horario_Clase WHERE id_horario = p_id_horario_nuevo),
        (SELECT hora_fin FROM Horario_Clase WHERE id_horario = p_id_horario_nuevo),
        (SELECT dia_semana FROM Horario_Clase WHERE id_horario = p_id_horario_nuevo)
    ) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Horario no disponible';
    END IF;
    
    -- Actualizar asignación
    UPDATE Asignacion_Entrenador_Grupo
    SET id_horario = p_id_horario_nuevo
    WHERE id_entrenador = p_id_trainer
    AND id_area = p_id_area
    AND id_horario = p_id_horario_antiguo;
    
    -- Notificar cambio
    INSERT INTO Notificacion_Trainer(
        id_datosentrenador,
        mensaje,
        fecha_notificacion
    ) SELECT 
        dt.id_datos_trainner,
        'Se ha actualizado tu horario',
        CURRENT_TIMESTAMP
    FROM DATOS_TRAINNER dt
    WHERE dt.id_trainner = p_id_trainer;
    
    SELECT 'Horario actualizado exitosamente' as mensaje;
END$$
DELIMITER ;

```
18.  **Eliminar la inscripción de un camper a una ruta (en caso de retiro).**
```sql

DELIMITER $$
CREATE PROCEDURE eliminar_inscripcion_camper(
    IN p_id_inscripcion INT,
    IN p_motivo VARCHAR(200)
)
BEGIN
    DECLARE v_id_ruta INT;
    DECLARE v_id_area INT;
    
    -- Obtener información de la ruta
    SELECT id_ruta INTO v_id_ruta
    FROM Inscripcion
    WHERE id_inscripcion = p_id_inscripcion;
    
    -- Obtener área asociada
    SELECT id_area INTO v_id_area
    FROM Ruta_Entrenamiento
    WHERE id_ruta = v_id_ruta;
    
    START TRANSACTION;
    
    -- Eliminar evaluaciones
    DELETE FROM Evaluacion
    WHERE id_inscripcion = p_id_inscripcion;
    
    -- Eliminar inscripción
    DELETE FROM Inscripcion
    WHERE id_inscripcion = p_id_inscripcion;
    
    -- Actualizar ocupación del área
    UPDATE Area_Entrenamiento
    SET ocupacion_actual = ocupacion_actual - 1
    WHERE id_area = v_id_area;
    
    -- Registrar retiro
    INSERT INTO Historial_Retiros(
        id_inscripcion,
        fecha_retiro,
        motivo
    ) VALUES (
        p_id_inscripcion,
        CURRENT_DATE,
        p_motivo
    );
    
    COMMIT;
    
    SELECT 'Inscripción eliminada exitosamente' as mensaje;
END$$
DELIMITER ;
```
19.  **Recalcular el estado de todos los campers según su rendimiento acumulado.**
```sql

DELIMITER $$
CREATE PROCEDURE recalcular_estados_campers()
BEGIN
    -- Actualizar estados basados en rendimiento
    UPDATE DATOS_CAMPER dc
    INNER JOIN (
        SELECT 
            dc.id_camper,
            AVG(e.calificacion_final) as promedio,
            COUNT(DISTINCT CASE WHEN e.Estado = 'Bajo_Rendimiento' THEN e.id_evaluacion END) as reprobadas
        FROM DATOS_CAMPER dc
        INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
        INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
        GROUP BY dc.id_camper
    ) rendimiento ON dc.id_camper = rendimiento.id_camper
    SET dc.id_estado = (
        CASE
            WHEN rendimiento.promedio < 60 OR rendimiento.reprobadas > 2 
            THEN (SELECT id_estado FROM Estado_camper WHERE nombre_estado = 'Riesgo')
            ELSE (SELECT id_estado FROM Estado_camper WHERE nombre_estado = 'Activo')
        END
    );
    
    SELECT 'Estados actualizados exitosamente' as mensaje;
END$$
DELIMITER ;
```
20.  **Asignar horarios automáticamente a trainers disponibles según sus áreas.**
```sql

DELIMITER $$
CREATE PROCEDURE asignar_horarios_automaticos()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id_trainer, v_id_area, v_id_horario INT;
    
    DECLARE cur_trainers CURSOR FOR
        SELECT t.id_trainner, ae.id_area, hc.id_horario
        FROM Trainner t
        CROSS JOIN Area_Entrenamiento ae
        CROSS JOIN Horario_Clase hc
        WHERE NOT EXISTS (
            SELECT 1 FROM Asignacion_Entrenador_Grupo aeg
            WHERE aeg.id_entrenador = t.id_trainner
            AND aeg.id_horario = hc.id_horario
        )
        AND trainer_disponible(t.id_trainner, hc.hora_inicio, hc.hora_fin, hc.dia_semana);
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
    
    OPEN cur_trainers;
    
    read_loop: LOOP
        FETCH cur_trainers INTO v_id_trainer, v_id_area, v_id_horario;
        IF done THEN
            LEAVE read_loop;
        END IF;
        
        -- Asignar horario
        INSERT INTO Asignacion_Entrenador_Grupo(
            id_entrenador, id_area, id_horario
        ) VALUES (
            v_id_trainer, v_id_area, v_id_horario
        );
    END LOOP;
    
    CLOSE cur_trainers;
    
    SELECT 'Horarios asignados automáticamente' as mensaje;
END$$
DELIMITER ;
```

## 📝 Implementación de Procedimientos Almacenados


## Instalación

1. Clona este repositorio en tu máquina local.
2. Crea la base de datos correspondiente en tu sistema de gestión de bases de datos.
3. Ejecuta las consultas SQL en tu entorno de base de datos.

## Notas

- Asegúrate de tener configurada correctamente la base de datos antes de ejecutar las consultas.
- Las consultas deben adaptarse al modelo de datos específico que estés utilizando.


