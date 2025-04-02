-- Triggers for the database

-- 1. Al insertar una evaluación, calcular automáticamente la nota final
DELIMITER $$

CREATE TRIGGER calcular_nota_final
AFTER INSERT ON EVALUACION
FOR EACH ROW
BEGIN 
    SET NEW.califiacion_final = (NEW.nota_teorica * 0.4) + (NEW.nota_practica * 0.4) + (NEW.nota_trabajos_quizzes * 0.2);
END$$

DELIMITER ;

-- 2. Recalcular la nota final al actualizar una evaluación
DELIMITER $$
CREATE TRIGGER actualizar_nota_final BEFORE UPDATE ON Evaluacion
FOR EACH ROW
BEGIN
    SET NEW.calificacion_final = (NEW.nota_teorica * 0.4) + (NEW.nota_practica * 0.4) + (NEW.nota_trabajos_quizzes * 0.2);
    SET NEW.Estado = IF(NEW.calificacion_final >= 60, 'Aprobado', 'Reprobado');
END$$
DELIMITER ;

--3. Al insertar una inscripción, cambiar el estado del camper a "Inscrito".
DELIMITER $$

CREATE TRIGGER cambiar_estado_camper
AFTER INSERT ON Inscripcion
FOR EACH ROW
BEGIN
    UPDATE DATOS_CAMPER
    SET id_estado = (SELECT id_estado FROM Estado_camper WHERE nombre_estado = 'Inscrito')
    WHERE id_datoscamper = NEW.id_datoscamper;
END $$
DELIMITER ;

-- 4. Al actualizar una evaluación, recalcular su promedio inmediatamente
DELIMITER $$

CREATE TRIGGER recalcular_promedio
AFTER UPDATE ON Evaluacion
FOR EACH ROW
BEGIN
    SET NEW.calificacion_final = (NEW.nota_teorica * 0.4) + (NEW.nota_practica * 0.4) + (NEW.nota_trabajos_quizzes * 0.2);
END$$

DELIMITER ;

-- 5. Al eliminar una inscripción, marcar al camper como “Retirado”

DELIMITER $$
CREATE TRIGGER marcar_retirado
AFTER DELETE ON Inscripcion
FOR EACH ROW
BEGIN
    UPDATE DATOS_CAMPER
    SET id_estado = (SELECT id_estado FROM Estado_camper WHERE nombre_estado = 'Retirado' LIMIT 1)
    WHERE id_datoscamper = OLD.id_datoscamper;
END$$
DELIMITER ;


-- 6. Al insertar un nuevo módulo, registrar automáticamente su SGDB asociado
DELIMITER $$
CREATE TRIGGER registrar_sgdb
AFTER INSERT ON Modulo_Aprendizaje
FOR EACH ROW
BEGIN
    INSERT INTO Ruta_BD (BD) VALUES (NEW.id_skill);
END$$
DELIMITER ;

-- 7. Al insertar un nuevo trainer, verificar duplicados por identificación
DELIMITER $$
CREATE TRIGGER verificar_duplicado_trainner
BEFORE INSERT ON Trainner
FOR EACH ROW
BEGIN
    DECLARE duplicado INT;
    SELECT COUNT(*) INTO duplicado FROM Trainner WHERE nombre = NEW.nombre;
    IF duplicado > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El trainer ya existe con esta identificación.';
    END IF;
END$$
DELIMITER ;

-- 8. Al asignar un área, validar que no exceda su capacidad

DELIMITER $$

CREATE TRIGGER validar_capacidad_area
BEFORE INSERT ON Asignacion_Salon_Horario
FOR EACH ROW
BEGIN
    DECLARE ocupacion_actual INT;
    SELECT ocupacion_actual INTO ocupacion_actual FROM Area_Entrenamiento WHERE id_area = NEW.id_area;
    IF ocupacion_actual >= (SELECT capacidad_maxima FROM Area_Entrenamiento WHERE id_area = NEW.id_area) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La capacidad del área ha sido excedida.';
    END IF;
END$$

DELIMITER ;

-- 9. Al insertar una evaluación con nota < 60, marcar al camper como “Bajo rendimiento”

DELIMITER $$

CREATE TRIGGER marcar_bajo_rendimiento
BEFORE UPDATE ON Evaluacion
FOR EACH ROW
BEGIN
    IF NEW.calificacion_final < 60 THEN 
        SET id_estado = (SELECT id_estado FROM Estado_camper WHERE nombre_estado = 'Bajo_Rendimiento') 
        WHERE id_datoscamper = (SELECT id_datoscamper FROM Inscripcion WHERE id_inscripcion = NEW.id_inscripcion);
    END IF;
END$$

DELIMITER ;


-- 10. Al cambiar de estado a “Graduado”, mover registro a la tabla de egresados

DELIMITER $$
CREATE TRIGGER mover_a_egresados
AFTER UPDATE ON DATOS_CAMPER
FOR EACH ROW
BEGIN
    IF NEW.id_estado = 5 THEN
        INSERT INTO EGRESADO (id_datoscamper, fecha_graduacion) VALUES (NEW.id_datoscamper, NOW());
    END IF;
END$$

DELIMITER ;


-- 12.Liberar horarios al eliminar trainer:

DELIMITER $$
CREATE TRIGGER liberar_horarios_trainer
BEFORE DELETE ON Trainner
FOR EACH ROW
BEGIN
    DELETE FROM Asignacion_Trainner WHERE id_trainner = OLD.id_trainner;
    DELETE FROM Asignacion_Entrenador_Grupo WHERE id_entrenador = OLD.id_trainner;
END$$
DELIMITER ;

-- 13.Liberar horarios al eliminar trainer:
DELIMITER $$
CREATE TRIGGER actualizar_modulos_camper
AFTER UPDATE ON Inscripcion
FOR EACH ROW
BEGIN
    IF NEW.id_ruta != OLD.id_ruta THEN
        -- Eliminar evaluaciones anteriores
        DELETE FROM Evaluacion WHERE id_inscripcion = NEW.id_inscripcion;
        
        -- Insertar nuevas evaluaciones para los módulos de la nueva ruta
        INSERT INTO Evaluacion (id_inscripcion, id_modulo, fecha_evaluacion)
        SELECT NEW.id_inscripcion, m.id_modulo, CURRENT_DATE
        FROM Modulo_Aprendizaje m
        INNER JOIN Skill s ON m.id_skill = s.id_skill
        WHERE s.id_ruta = NEW.id_ruta;
    END IF;
END$$
DELIMITER ;

--14 Verificar duplicado de camper:
DELIMITER $$
CREATE TRIGGER verificar_duplicado_camper
BEFORE INSERT ON Camper
FOR EACH ROW
BEGIN
    DECLARE duplicado INT;
    SELECT COUNT(*) INTO duplicado FROM Camper WHERE identificacion = NEW.identificacion;
    
    IF duplicado > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un camper con esta identificación';
    END IF;
END$$
DELIMITER ;

--15. Recalcular estado del módulo:

DELIMITER $$
CREATE TRIGGER actualizar_estado_evaluacion
BEFORE UPDATE ON Evaluacion
FOR EACH ROW
BEGIN
    SET NEW.calificacion_final = (NEW.nota_teorica * 0.3) + (NEW.nota_practica * 0.6) + (NEW.nota_trabajos_quizzes * 0.1);
    
    IF NEW.calificacion_final < 60 THEN
        SET NEW.Estado = 'Bajo_Rendimiento';
    ELSE
        SET NEW.Estado = 'Aprobado';
    END IF;
END$$
DELIMITER ;

--16.Conocimineto del trainner
DELIMITER $$
CREATE TRIGGER verificar_conocimiento_trainer
BEFORE INSERT ON Asignacion_Trainner
FOR EACH ROW
BEGIN
    DECLARE tiene_skill BOOLEAN;
    SELECT EXISTS(
        SELECT 1 FROM Trainers_skills ts
        INNER JOIN DATOS_TRAINNER dt ON ts.id_trainer_skill = dt.id_trainer_skill
        WHERE dt.id_trainner = NEW.id_trainner
    ) INTO tiene_skill;
    
    IF NOT tiene_skill THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El trainer no tiene las habilidades requeridas para esta ruta';
    END IF;
END$$
DELIMITER ;

--17 liberar campers al inactivar area:
DELIMITER $$
CREATE TRIGGER liberar_area_inactiva
BEFORE UPDATE ON Area_Entrenamiento
FOR EACH ROW
BEGIN
    IF NEW.estado = 'Inactivo' AND OLD.estado != 'Inactivo' THEN
        UPDATE Asignacion_Entrenador_Grupo
        SET fecha_fin = CURRENT_DATE
        WHERE id_area = OLD.id_area AND fecha_fin IS NULL;
        
        SET NEW.ocupacion_actual = 0;
    END IF;
END$$
DELIMITER ;


--18 clonar plantilla de modulos 
DELIMITER $$
CREATE TRIGGER clonar_plantilla_ruta
AFTER INSERT ON Ruta_Entrenamiento
FOR EACH ROW
BEGIN
    -- Crear skill base para la nueva ruta
    INSERT INTO Skill (nombre_skill, descripcion, id_ruta)
    VALUES (CONCAT('Skill base - ', NEW.nombre_ruta), 'Skill inicial', NEW.id_ruta);
    
    -- Clonar módulos base
    INSERT INTO Modulo_Aprendizaje (nombre_modulo, descripcion, id_skill)
    SELECT ma.nombre_modulo, ma.descripcion, LAST_INSERT_ID()
    FROM Modulo_Aprendizaje ma
    WHERE ma.id_skill = 1; -- Asumiendo que el ID 1 es la plantilla base
END$$
DELIMITER ;

--19 .verificar nota practica 
DELIMITER $$
CREATE TRIGGER validar_nota_practica
BEFORE UPDATE ON Evaluacion
FOR EACH ROW
BEGIN
    IF NEW.nota_practica > 60 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La nota práctica no puede superar el 60% del total';
    END IF;
END$$
DELIMITER ;


--20. Notificar cambios de ruta:
DELIMITER $$
CREATE TRIGGER notificar_cambios_ruta
AFTER UPDATE ON Ruta_Entrenamiento
FOR EACH ROW
BEGIN
    INSERT INTO Notificacion_Trainer (id_datosentrenador, id_ruta, mensaje, fecha_notificacion)
    SELECT dt.id_datos_trainner, NEW.id_ruta, 
           CONCAT('Se han actualizado los contenidos de la ruta: ', NEW.nombre_ruta),
           NOW()
    FROM DATOS_TRAINNER dt
    INNER JOIN Asignacion_Trainner at ON dt.id_trainner = at.id_trainner
    WHERE at.id_ruta = NEW.id_ruta;
END$$
DELIMITER ;