# Funciones SQL para la Gestión de Campers


## 📋 Categorías de Consultas

🔹 [Consultas de Campers](Consultas\Consultas.MD)
🔹 [Consultas de Evaluaciones](Consultas\consultas2.MD) 
🔹 [Consultas de Rutas](Consultas\consultas3.MD) 
🔹 [Consultas de Trainers](Consultas\consultas4.MD)   
🔹 [SubConsultas](Consultas\subconsultas.md)
🔹 [Procedimientos](Consultas\Procedimientos.MD)      
🔹 [Consultas con JOINs Básicos ](Consultas\Joins.MD) 
🔹 [Consultas con JOINs JOINs con condiciones específica ](Consultas\Joins2.MD)
🔹 [Consultas con JOINs  JOINs con funciones de agregación ](Consultas\Joins3.MD) 
🔹 [TRIGGERS](bd\triggers.sql)  

---

Este documento contiene una lista de 20 funciones SQL diseñadas para gestionar el rendimiento y la administración de campers en un programa de formación. Las funciones cubren cálculos de promedios, validaciones de disponibilidad, estados de aprobación y carga horaria.

## Lista de Funciones SQL

1.  **Calcular el promedio ponderado de evaluaciones de un camper.**

```sql
DELIMITER $$
CREATE FUNCTION calcular_promedio_ponderado(id_camper_param INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    
    SELECT AVG(e.calificacion_final) INTO promedio
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    WHERE dc.id_camper = id_camper_param;
    
    RETURN COALESCE(promedio, 0);
END$$
DELIMITER ;
```

2.  **Determinar si un camper aprueba o no un módulo específico.**

```sql
DELIMITER $$
CREATE FUNCTION aprobo_modulo(id_camper_param INT, id_modulo_param INT) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE estado VARCHAR(20);
    
    SELECT e.Estado INTO estado
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    WHERE dc.id_camper = id_camper_param 
    AND e.id_modulo = id_modulo_param
    LIMIT 1;
    
    RETURN COALESCE(estado, 'No evaluado');
END$$
DELIMITER ;
```
3.  **Evaluar el nivel de riesgo de un camper según su rendimiento promedio.**

```sql
DELIMITER $$
CREATE FUNCTION evaluar_nivel_riesgo(id_camper_param INT) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    
    SELECT AVG(e.calificacion_final) INTO promedio
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    WHERE dc.id_camper = id_camper_param;
    
    RETURN CASE
        WHEN promedio >= 90 THEN 'Bajo'
        WHEN promedio >= 60 THEN 'Medio'
        ELSE 'Alto'
    END;
END$$
DELIMITER ;
```

4.  **Obtener el total de campers asignados a una ruta específica.**

```sql
DELIMITER $$
CREATE FUNCTION total_campers_ruta(id_ruta_param INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    
    SELECT COUNT(DISTINCT i.id_datoscamper) INTO total
    FROM Inscripcion i
    WHERE i.id_ruta = id_ruta_param;
    
    RETURN COALESCE(total, 0);
END$$
DELIMITER ;
```
5.  **Consultar la cantidad de módulos que ha aprobado un camper.**
```sql
DELIMITER $$
CREATE FUNCTION modulos_aprobados_camper(id_camper_param INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total INT;
    
    SELECT COUNT(DISTINCT e.id_modulo) INTO total
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    WHERE dc.id_camper = id_camper_param 
    AND e.Estado = 'Aprobado';
    
    RETURN COALESCE(total, 0);
END$$
DELIMITER ;
```

6.  **Validar si hay cupos disponibles en una determinada área.**
```sql
DELIMITER $$
CREATE FUNCTION hay_cupos_area(id_area_param INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE capacidad_max INT;
    DECLARE ocupacion_actual INT;
    
    SELECT capacidad_maxima, ocupacion_actual 
    INTO capacidad_max, ocupacion_actual
    FROM Area_Entrenamiento 
    WHERE id_area = id_area_param;
    
    RETURN ocupacion_actual < capacidad_max;
END$$
DELIMITER ;
```

7.  **Calcular el porcentaje de ocupación de un área de entrenamiento.**
```sql
DELIMITER $$
CREATE FUNCTION calcular_porcentaje_ocupacion(id_area_param INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE capacidad_max INT;
    DECLARE ocupacion_actual INT;
    
    SELECT capacidad_maxima, ocupacion_actual 
    INTO capacidad_max, ocupacion_actual
    FROM Area_Entrenamiento 
    WHERE id_area = id_area_param;
    
    RETURN COALESCE((ocupacion_actual * 100.0 / capacidad_max), 0);
END$$
DELIMITER ;
```

8.  **Determinar la nota más alta obtenida en un módulo.**
```sql
DELIMITER $$
CREATE FUNCTION nota_mas_alta_modulo(id_modulo_param INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE nota_maxima DECIMAL(5,2);
    
    SELECT MAX(calificacion_final) INTO nota_maxima
    FROM Evaluacion
    WHERE id_modulo = id_modulo_param;
    
    RETURN COALESCE(nota_maxima, 0);
END$$
DELIMITER ;
```

9.  **Calcular la tasa de aprobación de una ruta.**
```sql
DELIMITER $$
CREATE FUNCTION tasa_aprobacion_ruta(id_ruta_param INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE total_evaluaciones INT;
    DECLARE aprobados INT;
    
    SELECT 
        COUNT(*) as total,
        SUM(CASE WHEN e.Estado = 'Aprobado' THEN 1 ELSE 0 END) as aprobados_count
    INTO total_evaluaciones, aprobados
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    WHERE i.id_ruta = id_ruta_param;
    
    RETURN CASE 
        WHEN total_evaluaciones > 0 THEN (aprobados * 100.0 / total_evaluaciones)
        ELSE 0
    END;
END$$
DELIMITER ;
```

10.  **Verificar si un trainer tiene horario disponible.**
```sql
DELIMITER $$
CREATE FUNCTION trainer_disponible(id_trainer_param INT, hora_inicio TIME, hora_fin TIME, dia VARCHAR(20)) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE conflictos INT;
    
    SELECT COUNT(*) INTO conflictos
    FROM Asignacion_Entrenador_Grupo aeg
    INNER JOIN Horario_Clase hc ON aeg.id_horario = hc.id_horario
    WHERE aeg.id_entrenador = id_trainer_param
    AND hc.dia_semana = dia
    AND ((hora_inicio BETWEEN hc.hora_inicio AND hc.hora_fin)
    OR (hora_fin BETWEEN hc.hora_inicio AND hc.hora_fin));
    
    RETURN conflictos = 0;
END$$
DELIMITER ;
```

11.  **Obtener el promedio de notas por ruta.**
```sql
DELIMITER $$
CREATE FUNCTION promedio_notas_ruta(id_ruta_param INT) 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    
    SELECT AVG(e.calificacion_final) INTO promedio
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    WHERE i.id_ruta = id_ruta_param;
    
    RETURN COALESCE(promedio, 0);
END$$
DELIMITER ;
```

12.  **Calcular cuántas rutas tiene asignadas un trainer.**

```sql
DELIMITER $$
CREATE FUNCTION rutas_asignadas_trainer(id_trainer_param INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_rutas INT;
    
    SELECT COUNT(DISTINCT id_ruta) INTO total_rutas
    FROM Asignacion_Trainner
    WHERE id_trainner = id_trainer_param;
    
    RETURN COALESCE(total_rutas, 0);
END$$
DELIMITER ;
```

13.  **Verificar si un camper puede ser graduado.**

```sql
DELIMITER $$
CREATE FUNCTION puede_graduarse(id_camper_param INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE total_modulos INT;
    DECLARE modulos_aprobados INT;
    DECLARE promedio_final DECIMAL(5,2);
    
    -- Obtener total de módulos de la ruta
    SELECT COUNT(DISTINCT ma.id_modulo) INTO total_modulos
    FROM Inscripcion i
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Ruta_Entrenamiento re ON i.id_ruta = re.id_ruta
    INNER JOIN Skill s ON re.id_ruta = s.id_ruta
    INNER JOIN Modulo_Aprendizaje ma ON s.id_skill = ma.id_skill
    WHERE dc.id_camper = id_camper_param;
    
    -- Obtener módulos aprobados
    SELECT COUNT(DISTINCT e.id_modulo) INTO modulos_aprobados
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    WHERE dc.id_camper = id_camper_param AND e.Estado = 'Aprobado';
    
    -- Obtener promedio final
    SELECT AVG(e.calificacion_final) INTO promedio_final
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    WHERE dc.id_camper = id_camper_param;
    
    RETURN modulos_aprobados = total_modulos AND promedio_final >= 60;
END$$
DELIMITER ;
```

14.  **Obtener el estado actual de un camper en función de sus evaluaciones.**

```sql
DELIMITER $$
CREATE FUNCTION estado_actual_camper(id_camper_param INT) 
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    DECLARE modulos_reprobados INT;
    
    SELECT AVG(e.calificacion_final), 
           SUM(CASE WHEN e.Estado = 'Reprobado' THEN 1 ELSE 0 END)
    INTO promedio, modulos_reprobados
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    WHERE dc.id_camper = id_camper_param;
    
    RETURN CASE
        WHEN modulos_reprobados > 2 THEN 'En Riesgo'
        WHEN promedio >= 90 THEN 'Excelente'
        WHEN promedio >= 60 THEN 'Regular'
        ELSE 'Bajo Rendimiento'
    END;
END$$
DELIMITER ;
```

15.  **Calcular la carga horaria semanal de un trainer.**

```sql
DELIMITER $$
CREATE FUNCTION carga_horaria_trainer(id_trainer_param INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_horas INT;
    
    SELECT SUM(
        TIMESTAMPDIFF(HOUR, hc.hora_inicio, hc.hora_fin)
    ) INTO total_horas
    FROM Asignacion_Entrenador_Grupo aeg
    INNER JOIN Horario_Clase hc ON aeg.id_horario = hc.id_horario
    WHERE aeg.id_entrenador = id_trainer_param;
    
    RETURN COALESCE(total_horas, 0);
END$$
DELIMITER ;
```
16.  **Determinar si una ruta tiene módulos pendientes por evaluación.**
```sql
DELIMITER $$
CREATE FUNCTION tiene_modulos_pendientes(id_ruta_param INT) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE total_modulos INT;
    DECLARE modulos_evaluados INT;
    
    SELECT COUNT(DISTINCT ma.id_modulo) INTO total_modulos
    FROM Ruta_Entrenamiento re
    INNER JOIN Skill s ON re.id_ruta = s.id_ruta
    INNER JOIN Modulo_Aprendizaje ma ON s.id_skill = ma.id_skill
    WHERE re.id_ruta = id_ruta_param;
    
    SELECT COUNT(DISTINCT e.id_modulo) INTO modulos_evaluados
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    WHERE i.id_ruta = id_ruta_param;
    
    RETURN modulos_evaluados < total_modulos;
END$$
DELIMITER ;
```

17.  **Calcular el promedio general del programa.**

```sql
DELIMITER $$
CREATE FUNCTION promedio_general_programa() 
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE promedio DECIMAL(5,2);
    
    SELECT AVG(calificacion_final) INTO promedio
    FROM Evaluacion;
    
    RETURN COALESCE(promedio, 0);
END$$
DELIMITER ;
```

18.  **Verificar si un horario choca con otros entrenadores en el área.**

```sql
DELIMITER $$
CREATE FUNCTION horario_choca_area(id_area_param INT, hora_inicio TIME, hora_fin TIME, dia VARCHAR(20)) 
RETURNS BOOLEAN
DETERMINISTIC
BEGIN
    DECLARE conflictos INT;
    
    SELECT COUNT(*) INTO conflictos
    FROM Asignacion_Entrenador_Grupo aeg
    INNER JOIN Horario_Clase hc ON aeg.id_horario = hc.id_horario
    WHERE aeg.id_area = id_area_param
    AND hc.dia_semana = dia
    AND ((hora_inicio BETWEEN hc.hora_inicio AND hc.hora_fin)
    OR (hora_fin BETWEEN hc.hora_inicio AND hc.hora_fin));
    
    RETURN conflictos > 0;
END$$
DELIMITER ;
```

19.  **Calcular cuántos campers están en riesgo en una ruta específica.**

```sql
DELIMITER $$
CREATE FUNCTION campers_en_riesgo_ruta(id_ruta_param INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_riesgo INT;
    
    SELECT COUNT(DISTINCT dc.id_camper) INTO total_riesgo
    FROM Inscripcion i
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    WHERE i.id_ruta = id_ruta_param
    AND e.calificacion_final < 60;
    
    RETURN COALESCE(total_riesgo, 0);
END$$
DELIMITER ;
```

20.  **Consultar el número de módulos evaluados por un camper.**

```sql
DELIMITER $$
CREATE FUNCTION modulos_evaluados_camper(id_camper_param INT) 
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE total_evaluados INT;
    
    SELECT COUNT(DISTINCT e.id_modulo) INTO total_evaluados
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    WHERE dc.id_camper = id_camper_param;
    
    RETURN COALESCE(total_evaluados, 0);
END$$
DELIMITER ;
```

## Instalación

1. Clona este repositorio en tu máquina local.
2. Crea la base de datos correspondiente en tu sistema de gestión de bases de datos.
3. Ejecuta las consultas SQL en tu entorno de base de datos.

## Notas

- Asegúrate de tener configurada correctamente la base de datos antes de ejecutar las consultas.
- Las consultas deben adaptarse al modelo de datos específico que estés utilizando.


