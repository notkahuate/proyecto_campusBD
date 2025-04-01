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
CREATE TRIGGER cambiar_estado AFTER INSERT ON Inscripcion
FOR EACH ROW
BEGIN
    UPDATE DATOS_CAMPER
    SET id_estado = (SELECT id_estado FROM Estado_camper WHERE nombre_estado = 'Retirado')
    WHERE id_datoscamper = NEW.id_datoscamper;
END$$
DELIMITER ;