# Proyecto de Base de Datos - Consultas Avanzadas y Subconsultas

Este proyecto proporciona ejemplos de consultas SQL avanzadas que utilizan subconsultas, cálculos y funciones agregadas para obtener información detallada sobre el rendimiento y las estadísticas de los campers, trainers, módulos y rutas.

## Consultas SQL Avanzadas

1. **Obtener los campers con la nota más alta en cada módulo.**
    ```sql
    WITH NotasMaximas AS (
    SELECT 
        id_modulo,
        MAX(calificacion_final) as nota_maxima
    FROM Evaluacion
    GROUP BY id_modulo
    )
    SELECT 
        ma.nombre_modulo,
        c.nombres,
        c.apellidos,
        e.calificacion_final
    FROM NotasMaximas nm
    INNER JOIN Evaluacion e ON nm.id_modulo = e.id_modulo 
        AND nm.nota_maxima = e.calificacion_final
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    INNER JOIN Modulo_Aprendizaje ma ON e.id_modulo = ma.id_modulo
    ORDER BY ma.nombre_modulo;
    ```

2. **Mostrar el promedio general de notas por ruta y comparar con el promedio global.**
    ```sql
    WITH PromedioGlobal AS (
    SELECT AVG(calificacion_final) as promedio_global
    FROM Evaluacion
    )
    SELECT 
        re.nombre_ruta,
        ROUND(AVG(e.calificacion_final), 2) as promedio_ruta,
        pg.promedio_global,
        ROUND(AVG(e.calificacion_final) - pg.promedio_global, 2) as diferencia
    FROM Ruta_Entrenamiento re
    INNER JOIN Inscripcion i ON re.id_ruta = i.id_ruta
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    CROSS JOIN PromedioGlobal pg
    GROUP BY re.id_ruta, re.nombre_ruta, pg.promedio_global
    ORDER BY diferencia DESC;
    ```

3. **Listar las áreas con más del 80% de ocupación.**
    ```sql
    SELECT 
    nombre_area,
    capacidad_maxima,
    ocupacion_actual,
    ROUND((ocupacion_actual * 100.0 / capacidad_maxima), 2) as porcentaje_ocupacion
    FROM Area_Entrenamiento
    WHERE (ocupacion_actual * 100.0 / capacidad_maxima) > 80
    ORDER BY porcentaje_ocupacion DESC;
    ```

4. **Mostrar los trainers con menos del 70% de rendimiento promedio.**
    ```sql
    WITH RendimientoTrainer AS (
    SELECT 
        t.id_trainner,
        t.nombre,
        t.apellido,
        AVG(e.calificacion_final) as promedio_rendimiento
    FROM Trainner t
    INNER JOIN Asignacion_Entrenador_Grupo aeg ON t.id_trainner = aeg.id_entrenador
    INNER JOIN Grupo_Campers gc ON aeg.id_grupo = gc.id_grupo
    INNER JOIN Grupo_Camper_Asignacion gca ON gc.id_grupo = gca.id_grupo
    INNER JOIN DATOS_CAMPER dc ON gca.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    GROUP BY t.id_trainner, t.nombre, t.apellido
    )
    SELECT *
    FROM RendimientoTrainer
    WHERE promedio_rendimiento < 70
    ORDER BY promedio_rendimiento;
    ```

5. **Consultar los campers cuyo promedio está por debajo del promedio general.**
    ```sql
    WITH PromedioGeneral AS (
    SELECT AVG(calificacion_final) as promedio
    FROM Evaluacion
    )
    SELECT 
        c.nombres,
        c.apellidos,
        ROUND(AVG(e.calificacion_final), 2) as promedio_camper,
        ROUND(pg.promedio, 2) as promedio_general
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    CROSS JOIN PromedioGeneral pg
    GROUP BY c.id_camper, c.nombres, c.apellidos, pg.promedio
    HAVING AVG(e.calificacion_final) < pg.promedio
    ORDER BY promedio_camper;
    ```

6. **Obtener los módulos con la menor tasa de aprobación.**
    ```sql
    SELECT 
    ma.nombre_modulo,
    COUNT(*) as total_evaluaciones,
    SUM(CASE WHEN e.Estado = 'Aprobado' THEN 1 ELSE 0 END) as aprobados,
    ROUND((SUM(CASE WHEN e.Estado = 'Aprobado' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) as tasa_aprobacion
    FROM Modulo_Aprendizaje ma
    INNER JOIN Evaluacion e ON ma.id_modulo = e.id_modulo
    GROUP BY ma.id_modulo, ma.nombre_modulo
    HAVING tasa_aprobacion < 50
    ORDER BY tasa_aprobacion;
    ```

7. **Listar los campers que han aprobado todos los módulos de su ruta.**
    ```sql
    WITH ModulosPorRuta AS (
    SELECT i.id_datoscamper, COUNT(DISTINCT e.id_modulo) as total_modulos
    FROM Inscripcion i
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    GROUP BY i.id_datoscamper
    ),
    ModulosAprobados AS (
    SELECT i.id_datoscamper, COUNT(DISTINCT e.id_modulo) as modulos_aprobados
    FROM Inscripcion i
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    WHERE e.Estado = 'Aprobado'
    GROUP BY i.id_datoscamper
    )
    SELECT 
        c.nombres,
        c.apellidos,
        mpr.total_modulos,
        ma.modulos_aprobados
    FROM ModulosPorRuta mpr
    INNER JOIN ModulosAprobados ma ON mpr.id_datoscamper = ma.id_datoscamper
    INNER JOIN DATOS_CAMPER dc ON mpr.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    WHERE mpr.total_modulos = ma.modulos_aprobados;
    ```

8. **Mostrar rutas con más de 10 campers en bajo rendimiento.**
    ```sql
    SELECT 
    re.nombre_ruta,
    COUNT(DISTINCT c.id_camper) as total_campers,
    SUM(CASE WHEN e.Estado = 'Bajo_Rendimiento' THEN 1 ELSE 0 END) as bajo_rendimiento
    FROM Ruta_Entrenamiento re
    INNER JOIN Inscripcion i ON re.id_ruta = i.id_ruta
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    GROUP BY re.id_ruta, re.nombre_ruta
    HAVING SUM(CASE WHEN e.Estado = 'Bajo_Rendimiento' THEN 1 ELSE 0 END) > 10
    ORDER BY bajo_rendimiento DESC;
    ```

9. **Calcular el promedio de rendimiento por SGDB principal.**
    ```sql
    SELECT 
    rb.BD as sgdb_principal,
    COUNT(DISTINCT i.id_datoscamper) as total_campers,
    ROUND(AVG(e.calificacion_final), 2) as promedio_rendimiento
    FROM Ruta_BD rb
    INNER JOIN Ruta_Entrenamiento re ON rb.id_rutaBD = re.sgdb_principal
    INNER JOIN Inscripcion i ON re.id_ruta = i.id_ruta
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    GROUP BY rb.id_rutaBD, rb.BD
    ORDER BY promedio_rendimiento DESC;
    ```

10. **Listar los módulos con al menos un 30% de campers reprobados.**
    ```sql
    SELECT 
    ma.nombre_modulo,
    COUNT(DISTINCT e.id_inscripcion) as total_estudiantes,
    SUM(CASE WHEN e.Estado = 'Reprobado' THEN 1 ELSE 0 END) as reprobados,
    ROUND((SUM(CASE WHEN e.Estado = 'Reprobado' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) as porcentaje_reprobados
    FROM Modulo_Aprendizaje ma
    INNER JOIN Evaluacion e ON ma.id_modulo = e.id_modulo
    GROUP BY ma.id_modulo, ma.nombre_modulo
    HAVING porcentaje_reprobados >= 30
    ORDER BY porcentaje_reprobados DESC;
    ```

11. **Mostrar el módulo más cursado por campers con riesgo alto.**
    ```sql
    SELECT 
    ma.nombre_modulo,
    COUNT(DISTINCT c.id_camper) as total_campers_riesgo_alto
    FROM Modulo_Aprendizaje ma
    INNER JOIN Evaluacion e ON ma.id_modulo = e.id_modulo
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    WHERE c.nivel_riesgo = 'Alto'
    GROUP BY ma.id_modulo, ma.nombre_modulo
    ORDER BY total_campers_riesgo_alto DESC
    LIMIT 1;
    ```

12. **Consultar los trainers con más de 3 rutas asignadas.**
    ```sql
    SELECT 
    t.nombre,
    t.apellido,
    COUNT(DISTINCT at.id_ruta) as total_rutas,
    GROUP_CONCAT(re.nombre_ruta) as rutas_asignadas
    FROM Trainner t
    INNER JOIN Asignacion_Trainner at ON t.id_trainner = at.id_trainner
    INNER JOIN Ruta_Entrenamiento re ON at.id_ruta = re.id_ruta
    GROUP BY t.id_trainner, t.nombre, t.apellido
    HAVING COUNT(DISTINCT at.id_ruta) > 3;
    ```

13. **Listar los horarios más ocupados por áreas.**
    ```sql
    SELECT 
    ae.nombre_area,
    hc.dia_semana,
    hc.hora_inicio,
    COUNT(*) as total_ocupaciones
    FROM Area_Entrenamiento ae
    INNER JOIN Asignacion_Entrenador_Grupo aeg ON ae.id_area = aeg.id_area
    INNER JOIN Horario_Clase hc ON aeg.id_asignacion = hc.id_horario
    GROUP BY ae.id_area, ae.nombre_area, hc.dia_semana, hc.hora_inicio
    ORDER BY total_ocupaciones DESC;
    ```

14. **Consultar las rutas con el mayor número de módulos.**
    ```sql
    SELECT 
    re.nombre_ruta,
    COUNT(DISTINCT ma.id_modulo) as total_modulos,
    GROUP_CONCAT(DISTINCT ma.nombre_modulo) as modulos
    FROM Ruta_Entrenamiento re
    INNER JOIN Skill s ON re.id_ruta = s.id_ruta
    INNER JOIN Modulo_Aprendizaje ma ON s.id_skill = ma.id_skill
    GROUP BY re.id_ruta, re.nombre_ruta
    ORDER BY total_modulos DESC;
    ```

15. **Obtener los campers que han cambiado de estado más de una vez.**
    ```sql
    SELECT 
    c.nombres,
    c.apellidos,
    COUNT(DISTINCT dc.id_estado) as total_cambios_estado
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    GROUP BY c.id_camper, c.nombres, c.apellidos
    HAVING COUNT(DISTINCT dc.id_estado) > 1
    ORDER BY total_cambios_estado DESC;
    ```

16. **Mostrar las evaluaciones donde la nota teórica sea mayor a la práctica.**
    ```sql
   SELECT 
    c.nombres,
    c.apellidos,
    ma.nombre_modulo,
    e.nota_teorica,
    e.nota_practica,
    (e.nota_teorica - e.nota_practica) as diferencia
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    INNER JOIN Modulo_Aprendizaje ma ON e.id_modulo = ma.id_modulo
    WHERE e.nota_teorica > e.nota_practica
    ORDER BY diferencia DESC;
    ```

17. **Listar los módulos donde la media de quizzes supera el 9.**
    ```sql
    SELECT 
    ma.nombre_modulo,
    ROUND(AVG(e.nota_trabajos_quizzes), 2) as promedio_quizzes,
    COUNT(DISTINCT e.id_inscripcion) as total_evaluaciones
    FROM Modulo_Aprendizaje ma
    INNER JOIN Evaluacion e ON ma.id_modulo = e.id_modulo
    GROUP BY ma.id_modulo, ma.nombre_modulo
    HAVING AVG(e.nota_trabajos_quizzes) > 9
    ORDER BY promedio_quizzes DESC;
    ```

18. **Consultar la ruta con mayor tasa de graduación.**
    ```sql
    SELECT 
    re.nombre_ruta,
    COUNT(DISTINCT i.id_datoscamper) as total_inscritos,
    COUNT(DISTINCT e.id_egresado) as total_graduados,
    ROUND((COUNT(DISTINCT e.id_egresado) * 100.0 / COUNT(DISTINCT i.id_datoscamper)), 2) as tasa_graduacion
    FROM Ruta_Entrenamiento re
    INNER JOIN Inscripcion i ON re.id_ruta = i.id_ruta
    LEFT JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    LEFT JOIN EGRESADO e ON dc.id_datoscamper = e.id_datoscamper
    GROUP BY re.id_ruta, re.nombre_ruta
    ORDER BY tasa_graduacion DESC
    LIMIT 1;
    ```

19. **Mostrar los módulos cursados por campers de nivel de riesgo medio o alto.**
    ```sql
    SELECT 
    ma.nombre_modulo,
    c.nivel_riesgo,
    COUNT(DISTINCT c.id_camper) as total_campers,
    ROUND(AVG(e.calificacion_final), 2) as promedio_notas
    FROM Modulo_Aprendizaje ma
    INNER JOIN Evaluacion e ON ma.id_modulo = e.id_modulo
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    WHERE c.nivel_riesgo IN ('Medio', 'Alto')
    GROUP BY ma.id_modulo, ma.nombre_modulo, c.nivel_riesgo
    ORDER BY ma.nombre_modulo, c.nivel_riesgo;
    ```

20. **Obtener la diferencia entre capacidad y ocupación en cada área.**
    ```sql
    SELECT 
        nombre_area,
        capacidad_maxima,
        ocupacion_actual,
        (capacidad_maxima - ocupacion_actual) as espacios_disponibles,
        ROUND((ocupacion_actual * 100.0 / capacidad_maxima), 2) as porcentaje_ocupacion,
        CASE 
            WHEN ocupacion_actual >= capacidad_maxima THEN 'Lleno'
            WHEN ocupacion_actual >= (capacidad_maxima * 0.8) THEN 'Casi lleno'
            ELSE 'Disponible'
        END as estado_ocupacion
    FROM Area_Entrenamiento
    ORDER BY porcentaje_ocupacion DESC;
    ```

## Instalación

1. Clona este repositorio en tu máquina local.
2. Crea la base de datos correspondiente en tu sistema de gestión de bases de datos.
3. Ejecuta las consultas SQL en tu entorno de base de datos.

## Notas

- Asegúrate de tener configurada correctamente la base de datos antes de ejecutar las consultas.
- Las consultas deben adaptarse al modelo de datos específico que estés utilizando.

