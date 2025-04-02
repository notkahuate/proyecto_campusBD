# Proyecto de Base de Datos - Consultas con JOINs y Funciones de Agregación

Este proyecto contiene ejemplos de consultas SQL utilizando JOINs y funciones de agregación (como `AVG()`, `COUNT()`, etc.) para obtener estadísticas relacionadas con los campers, módulos, rutas, trainers, y áreas de entrenamiento.

## Consultas SQL con JOINs y Funciones de Agregación

1. **Obtener el promedio de nota final por módulo.**
    ```sql
    SELECT 
    ma.nombre_modulo,
    COUNT(DISTINCT e.id_inscripcion) as total_evaluaciones,
    ROUND(AVG(e.calificacion_final), 2) as promedio_final,
    MIN(e.calificacion_final) as nota_minima,
    MAX(e.calificacion_final) as nota_maxima
    FROM Modulo_Aprendizaje ma
    INNER JOIN Evaluacion e ON ma.id_modulo = e.id_modulo
    GROUP BY ma.id_modulo, ma.nombre_modulo
    ORDER BY promedio_final DESC;
    ```

2. **Calcular la cantidad total de campers por ruta.**
    ```sql
    SELECT 
    re.nombre_ruta,
    COUNT(DISTINCT i.id_datoscamper) as total_campers,
    COUNT(DISTINCT gc.id_grupo) as total_grupos,
    COUNT(DISTINCT aeg.id_entrenador) as total_trainers
    FROM Ruta_Entrenamiento re
    LEFT JOIN Inscripcion i ON re.id_ruta = i.id_ruta
    LEFT JOIN Grupo_Campers gc ON re.id_ruta = gc.id_ruta
    LEFT JOIN Asignacion_Entrenador_Grupo aeg ON gc.id_grupo = aeg.id_grupo
    GROUP BY re.id_ruta, re.nombre_ruta
    ORDER BY total_campers DESC;
    ```

3. **Mostrar la cantidad de evaluaciones realizadas por cada trainer (según las rutas que imparte).**
    ```sql
    SELECT 
    t.nombre,
    t.apellido,
    COUNT(DISTINCT e.id_evaluacion) as total_evaluaciones,
    COUNT(DISTINCT c.id_camper) as total_campers_evaluados,
    ROUND(AVG(e.calificacion_final), 2) as promedio_general
    FROM Trainner t
    INNER JOIN Asignacion_Trainner at ON t.id_trainner = at.id_trainner
    INNER JOIN Inscripcion i ON at.id_ruta = i.id_ruta
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    GROUP BY t.id_trainner, t.nombre, t.apellido
    ORDER BY total_evaluaciones DESC;
    ```

4. **Consultar el promedio general de rendimiento por cada área de entrenamiento.**
    ```sql
    SELECT 
    ae.nombre_area,
    COUNT(DISTINCT e.id_evaluacion) as total_evaluaciones,
    ROUND(AVG(e.calificacion_final), 2) as promedio_rendimiento
    FROM Area_Entrenamiento ae
    INNER JOIN Asignacion_Entrenador_Grupo aeg ON ae.id_area = aeg.id_area
    INNER JOIN Grupo_Campers gc ON aeg.id_grupo = gc.id_grupo
    INNER JOIN Grupo_Camper_Asignacion gca ON gc.id_grupo = gca.id_grupo
    INNER JOIN DATOS_CAMPER dc ON gca.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    GROUP BY ae.id_area, ae.nombre_area
    ORDER BY promedio_rendimiento DESC;
    ```

5. **Obtener la cantidad de módulos asociados a cada ruta de entrenamiento.**
    ```sql
    SELECT 
    re.nombre_ruta,
    COUNT(DISTINCT s.id_skill) as total_skills,
    COUNT(DISTINCT ma.id_modulo) as total_modulos,
    GROUP_CONCAT(DISTINCT ma.nombre_modulo) as modulos
    FROM Ruta_Entrenamiento re
    LEFT JOIN Skill s ON re.id_ruta = s.id_ruta
    LEFT JOIN Modulo_Aprendizaje ma ON s.id_skill = ma.id_skill
    GROUP BY re.id_ruta, re.nombre_ruta
    ORDER BY total_modulos DESC;
    ```

6. **Mostrar el promedio de nota final de los campers en estado “Cursando”.**
    ```sql
    SELECT 
    ROUND(AVG(e.calificacion_final), 2) as promedio_general,
    COUNT(DISTINCT c.id_camper) as total_campers,
    COUNT(DISTINCT e.id_evaluacion) as total_evaluaciones
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Estado_camper ec ON dc.id_estado = ec.id_estado
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    WHERE ec.nombre_estado = 'Activo';
    ```

7. **Listar el número de campers evaluados en cada módulo.**
    ```sql
    SELECT 
    ma.nombre_modulo,
    COUNT(DISTINCT e.id_inscripcion) as total_evaluados,
    COUNT(DISTINCT CASE WHEN e.Estado = 'Aprobado' THEN e.id_inscripcion END) as aprobados
    FROM Modulo_Aprendizaje ma
    LEFT JOIN Evaluacion e ON ma.id_modulo = e.id_modulo
    GROUP BY ma.id_modulo, ma.nombre_modulo
    ORDER BY total_evaluados DESC;
    ```

8. **Consultar el porcentaje de ocupación actual por cada área de entrenamiento.**
    ```sql
    SELECT 
    ae.nombre_area,
    ae.capacidad_maxima,
    COUNT(DISTINCT gca.id_camper) as ocupacion_actual,
    ROUND((COUNT(DISTINCT gca.id_camper) * 100.0 / ae.capacidad_maxima), 2) as porcentaje_ocupacion
    FROM Area_Entrenamiento ae
    LEFT JOIN Asignacion_Entrenador_Grupo aeg ON ae.id_area = aeg.id_area
    LEFT JOIN Grupo_Campers gc ON aeg.id_grupo = gc.id_grupo
    LEFT JOIN Grupo_Camper_Asignacion gca ON gc.id_grupo = gca.id_grupo
    GROUP BY ae.id_area, ae.nombre_area, ae.capacidad_maxima
    ORDER BY porcentaje_ocupacion DESC;
    ```

9. **Mostrar cuántos trainers tiene asignados cada área.**
    ```sql
    SELECT 
    ae.nombre_area,
    COUNT(DISTINCT aeg.id_entrenador) as total_trainers,
    GROUP_CONCAT(DISTINCT CONCAT(t.nombre, ' ', t.apellido)) as trainers
    FROM Area_Entrenamiento ae
    LEFT JOIN Asignacion_Entrenador_Grupo aeg ON ae.id_area = aeg.id_area
    LEFT JOIN Trainner t ON aeg.id_entrenador = t.id_trainner
    GROUP BY ae.id_area, ae.nombre_area
    ORDER BY total_trainers DESC;
    ```

10. **Listar las rutas que tienen más campers en riesgo alto.**
    ```sql
    SELECT 
    re.nombre_ruta,
    COUNT(DISTINCT CASE WHEN c.nivel_riesgo = 'Alto' THEN c.id_camper END) as campers_riesgo_alto,
    COUNT(DISTINCT c.id_camper) as total_campers,
    ROUND((COUNT(DISTINCT CASE WHEN c.nivel_riesgo = 'Alto' THEN c.id_camper END) * 100.0 / 
           COUNT(DISTINCT c.id_camper)), 2) as porcentaje_riesgo
    FROM Ruta_Entrenamiento re
    INNER JOIN Inscripcion i ON re.id_ruta = i.id_ruta
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    GROUP BY re.id_ruta, re.nombre_ruta
    HAVING campers_riesgo_alto > 0
    ORDER BY campers_riesgo_alto DESC;
    ```

## Instalación

1. Clona este repositorio en tu máquina local.
2. Crea la base de datos correspondiente en tu sistema de gestión de bases de datos.
3. Ejecuta las consultas SQL en tu entorno de base de datos.

## Notas

- Asegúrate de tener configurada correctamente la base de datos antes de ejecutar las consultas.
- Las consultas deben adaptarse al modelo de datos específico que estés utilizando.

