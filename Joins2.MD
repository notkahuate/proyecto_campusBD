# Proyecto de Base de Datos - Consultas con JOINs y Condiciones Específicas

Este proyecto proporciona ejemplos de consultas SQL que utilizan JOINs con condiciones específicas para obtener información detallada sobre los campers, trainers, rutas, módulos y áreas de entrenamiento.

## Consultas SQL con JOINs y Condiciones Específicas

1. **Listar los campers que han aprobado todos los módulos de su ruta (nota_final >= 60).**
    ```sql
   WITH ModulosPorRuta AS (
    SELECT re.id_ruta, COUNT(DISTINCT ma.id_modulo) as total_modulos
    FROM Ruta_Entrenamiento re
    INNER JOIN Skill s ON re.id_ruta = s.id_ruta
    INNER JOIN Modulo_Aprendizaje ma ON s.id_skill = ma.id_skill
    GROUP BY re.id_ruta
    ),
    ModulosAprobados AS (
        SELECT 
            c.id_camper,
            i.id_ruta,
            COUNT(DISTINCT CASE WHEN e.calificacion_final >= 60 THEN e.id_modulo END) as modulos_aprobados
        FROM Camper c
        INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
        INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
        INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
        GROUP BY c.id_camper, i.id_ruta
    )
    SELECT 
        c.nombres,
        c.apellidos,
        re.nombre_ruta
    FROM ModulosAprobados ma
    INNER JOIN ModulosPorRuta mpr ON ma.id_ruta = mpr.id_ruta
    INNER JOIN Camper c ON ma.id_camper = c.id_camper
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Ruta_Entrenamiento re ON i.id_ruta = re.id_ruta
    WHERE ma.modulos_aprobados = mpr.total_modulos;
    ```

2. **Mostrar las rutas que tienen más de 10 campers inscritos actualmente.**
    ```sql
    SELECT 
    re.nombre_ruta,
    COUNT(DISTINCT i.id_datoscamper) as total_campers,
    GROUP_CONCAT(DISTINCT c.nombres) as nombres_campers
    FROM Ruta_Entrenamiento re
    INNER JOIN Inscripcion i ON re.id_ruta = i.id_ruta
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    GROUP BY re.id_ruta, re.nombre_ruta
    HAVING COUNT(DISTINCT i.id_datoscamper) > 10
    ORDER BY total_campers DESC;
    ```

3. **Consultar las áreas que superan el 80% de su capacidad con el número actual de campers asignados.**
    ```sql
    SELECT 
    ae.nombre_area,
    ae.capacidad_maxima,
    COUNT(DISTINCT gca.id_camper) as campers_actuales,
    ROUND((COUNT(DISTINCT gca.id_camper) * 100.0 / ae.capacidad_maxima), 2) as porcentaje_ocupacion
    FROM Area_Entrenamiento ae
    INNER JOIN Asignacion_Entrenador_Grupo aeg ON ae.id_area = aeg.id_area
    INNER JOIN Grupo_Campers gc ON aeg.id_grupo = gc.id_grupo
    INNER JOIN Grupo_Camper_Asignacion gca ON gc.id_grupo = gca.id_grupo
    GROUP BY ae.id_area, ae.nombre_area, ae.capacidad_maxima
    HAVING (COUNT(DISTINCT gca.id_camper) * 100.0 / ae.capacidad_maxima) > 80
    ORDER BY porcentaje_ocupacion DESC;
    ```

4. **Obtener los trainers que imparten más de una ruta diferente.**
    ```sql
    SELECT 
    t.nombre,
    t.apellido,
    COUNT(DISTINCT at.id_ruta) as total_rutas,
    GROUP_CONCAT(DISTINCT re.nombre_ruta) as rutas_asignadas
    FROM Trainner t
    INNER JOIN Asignacion_Trainner at ON t.id_trainner = at.id_trainner
    INNER JOIN Ruta_Entrenamiento re ON at.id_ruta = re.id_ruta
    GROUP BY t.id_trainner, t.nombre, t.apellido
    HAVING COUNT(DISTINCT at.id_ruta) > 1
    ORDER BY total_rutas DESC;
    ```

5. **Listar las evaluaciones donde la nota práctica es mayor que la nota teórica.**
    ```sql
    SELECT 
    c.nombres,
    c.apellidos,
    ma.nombre_modulo,
    e.nota_teorica,
    e.nota_practica,
    (e.nota_practica - e.nota_teorica) as diferencia
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    INNER JOIN Modulo_Aprendizaje ma ON e.id_modulo = ma.id_modulo
    WHERE e.nota_practica > e.nota_teorica
    ORDER BY diferencia DESC;
    ```

6. **Mostrar campers que están en rutas cuyo SGDB principal es MySQL.**
    ```sql
    SELECT 
    c.nombres,
    c.apellidos,
    re.nombre_ruta,
    rb.BD as sgdb_principal
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Ruta_Entrenamiento re ON i.id_ruta = re.id_ruta
    INNER JOIN Ruta_BD rb ON re.sgdb_principal = rb.id_rutaBD
    WHERE rb.BD = 'MySQL'
    ORDER BY c.apellidos;
    ```

7. **Obtener los nombres de los módulos donde los campers han tenido bajo rendimiento.**
    ```sql
    SELECT 
    ma.nombre_modulo,
    COUNT(DISTINCT e.id_evaluacion) as total_evaluaciones,
    COUNT(DISTINCT CASE WHEN e.Estado = 'Bajo_Rendimiento' THEN e.id_evaluacion END) as bajo_rendimiento,
    ROUND((COUNT(DISTINCT CASE WHEN e.Estado = 'Bajo_Rendimiento' THEN e.id_evaluacion END) * 100.0 / 
           COUNT(DISTINCT e.id_evaluacion)), 2) as porcentaje_bajo
    FROM Modulo_Aprendizaje ma
    INNER JOIN Evaluacion e ON ma.id_modulo = e.id_modulo
    GROUP BY ma.id_modulo, ma.nombre_modulo
    HAVING COUNT(DISTINCT CASE WHEN e.Estado = 'Bajo_Rendimiento' THEN e.id_evaluacion END) > 0
    ORDER BY porcentaje_bajo DESC;
    ```

8. **Consultar las rutas con más de 3 módulos asociados.**
    ```sql
    SELECT 
    re.nombre_ruta,
    COUNT(DISTINCT ma.id_modulo) as total_modulos,
    GROUP_CONCAT(DISTINCT ma.nombre_modulo) as modulos
    FROM Ruta_Entrenamiento re
    INNER JOIN Skill s ON re.id_ruta = s.id_ruta
    INNER JOIN Modulo_Aprendizaje ma ON s.id_skill = ma.id_skill
    GROUP BY re.id_ruta, re.nombre_ruta
    HAVING COUNT(DISTINCT ma.id_modulo) > 3
    ORDER BY total_modulos DESC;
    ```

9. **Listar las inscripciones realizadas en los últimos 30 días con sus respectivos campers y rutas.**
    ```sql
   SELECT 
    c.nombres,
    c.apellidos,
    re.nombre_ruta,
    i.fecha_inscripcion,
    DATEDIFF(CURRENT_DATE, i.fecha_inscripcion) as dias_desde_inscripcion
    FROM Inscripcion i
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    INNER JOIN Ruta_Entrenamiento re ON i.id_ruta = re.id_ruta
    WHERE i.fecha_inscripcion >= DATE_SUB(CURRENT_DATE, INTERVAL 30 DAY)
    ORDER BY i.fecha_inscripcion DESC;
    ```

10. **Obtener los trainers que están asignados a rutas con campers en estado de “Alto Riesgo”.**
    ```sql
    SELECT DISTINCT
    t.nombre,
    t.apellido,
    COUNT(DISTINCT c.id_camper) as campers_alto_riesgo
    FROM Trainner t
    INNER JOIN Asignacion_Trainner at ON t.id_trainner = at.id_trainner
    INNER JOIN Ruta_Entrenamiento re ON at.id_ruta = re.id_ruta
    INNER JOIN Inscripcion i ON re.id_ruta = i.id_ruta
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    WHERE c.nivel_riesgo = 'Alto'
    GROUP BY t.id_trainner, t.nombre, t.apellido
    ORDER BY campers_alto_riesgo DESC;
    ```

## Instalación

1. Clona este repositorio en tu máquina local.
2. Crea la base de datos correspondiente en tu sistema de gestión de bases de datos.
3. Ejecuta las consultas SQL en tu entorno de base de datos.

## Notas

- Asegúrate de tener configurada correctamente la base de datos antes de ejecutar las consultas.
- Las consultas deben adaptarse al modelo de datos específico que estés utilizando.

