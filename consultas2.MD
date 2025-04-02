# Proyecto de Base de Datos - Gestión de Rendimiento de Campers

Este proyecto tiene como objetivo gestionar y consultar las notas, rendimiento y resultados de los campers por módulo y ruta de entrenamiento. A continuación, se presentan las consultas SQL necesarias para obtener información detallada sobre el rendimiento de los campers.

## Consultas SQL Evaluacion

1. **Obtener las notas teóricas, prácticas y quizzes de cada camper por módulo.**
    ```sql
    SELECT 
    c.nombres, 
    c.apellidos,
    ma.nombre_modulo,
    e.nota_teorica,
    e.nota_practica,
    e.nota_trabajos_quizzes
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    INNER JOIN Modulo_Aprendizaje ma ON e.id_modulo = ma.id_modulo
    ORDER BY c.nombres, ma.nombre_modulo;
    ```

2. **Calcular la nota final de cada camper por módulo.**
    ```sql
    SELECT 
    c.nombres,
    c.apellidos,
    ma.nombre_modulo,
    e.calificacion_final,
    CASE 
        WHEN e.calificacion_final >= 60 THEN 'Aprobado'
        ELSE 'Reprobado'
    END AS estado
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    INNER JOIN Modulo_Aprendizaje ma ON e.id_modulo = ma.id_modulo
    ORDER BY e.calificacion_final DESC;
    ```

3. **Mostrar los campers que reprobaron algún módulo (nota < 60).**
    ```sql
    SELECT 
    c.nombres,
    c.apellidos,
    ma.nombre_modulo,
    e.calificacion_final
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    INNER JOIN Modulo_Aprendizaje ma ON e.id_modulo = ma.id_modulo
    WHERE e.calificacion_final < 60
    ORDER BY e.calificacion_final;
    ```

4. **Listar los módulos con más campers en bajo rendimiento.**
    ```sql
    SELECT 
    ma.nombre_modulo,
    COUNT(*) as total_bajo_rendimiento
    FROM Modulo_Aprendizaje ma
    INNER JOIN Evaluacion e ON ma.id_modulo = e.id_modulo
    WHERE e.Estado = 'Bajo_Rendimiento'
    GROUP BY ma.id_modulo, ma.nombre_modulo
    ORDER BY total_bajo_rendimiento DESC;
    ```

5. **Obtener el promedio de notas finales por cada módulo.**
    ```sql
    SELECT 
    ma.nombre_modulo,
    ROUND(AVG(e.calificacion_final), 2) as promedio_notas,
    COUNT(*) as total_evaluaciones
    FROM Modulo_Aprendizaje ma
    INNER JOIN Evaluacion e ON ma.id_modulo = e.id_modulo
    GROUP BY ma.id_modulo, ma.nombre_modulo
    ORDER BY promedio_notas DESC;
    ```

6. **Consultar el rendimiento general por ruta de entrenamiento.**
    ```sql
    SELECT 
    re.nombre_ruta,
    ROUND(AVG(e.calificacion_final), 2) as promedio_ruta,
    COUNT(DISTINCT c.id_camper) as total_campers,
    SUM(CASE WHEN e.Estado = 'Aprobado' THEN 1 ELSE 0 END) as aprobados,
    SUM(CASE WHEN e.Estado = 'Bajo_Rendimiento' THEN 1 ELSE 0 END) as bajo_rendimiento
    FROM Ruta_Entrenamiento re
    INNER JOIN Inscripcion i ON re.id_ruta = i.id_ruta
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    GROUP BY re.id_ruta, re.nombre_ruta
    ORDER BY promedio_ruta DESC;
    ```

7. **Mostrar los trainers responsables de campers con bajo rendimiento.**
    ```sql
    SELECT 
    t.nombre,
    t.apellido,
    COUNT(DISTINCT c.id_camper) as campers_bajo_rendimiento
    FROM Trainner t
    INNER JOIN Asignacion_Trainner at ON t.id_trainner = at.id_trainner
    INNER JOIN Inscripcion i ON at.id_ruta = i.id_ruta
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    WHERE e.Estado = 'Bajo_Rendimiento'
    GROUP BY t.id_trainner, t.nombre, t.apellido
    ORDER BY campers_bajo_rendimiento DESC;
    ```

8. **Comparar el promedio de rendimiento por trainer.**
    ```sql
    SELECT 
    t.nombre,
    t.apellido,
    ROUND(AVG(e.calificacion_final), 2) as promedio_notas,
    COUNT(DISTINCT c.id_camper) as total_campers
    FROM Trainner t
    INNER JOIN Asignacion_Trainner at ON t.id_trainner = at.id_trainner
    INNER JOIN Inscripcion i ON at.id_ruta = i.id_ruta
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    GROUP BY t.id_trainner, t.nombre, t.apellido
    ORDER BY promedio_notas DESC;
    ```


10. **Mostrar cuántos campers pasaron cada módulo por ruta.**
    ```sql
    SELECT 
    re.nombre_ruta,
    ma.nombre_modulo,
    COUNT(DISTINCT c.id_camper) as total_aprobados
    FROM Ruta_Entrenamiento re
    INNER JOIN Skill s ON re.id_ruta = s.id_ruta
    INNER JOIN Modulo_Aprendizaje ma ON s.id_skill = ma.id_skill
    INNER JOIN Evaluacion e ON ma.id_modulo = e.id_modulo
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    WHERE e.Estado = 'Aprobado'
    GROUP BY re.id_ruta, re.nombre_ruta, ma.id_modulo, ma.nombre_modulo
    ORDER BY re.nombre_ruta, ma.nombre_modulo;
    ```

## Instalación

1. Clona este repositorio en tu máquina local.
2. Crea la base de datos correspondiente en tu sistema de gestión de bases de datos.
3. Ejecuta las consultas SQL en tu entorno de base de datos.

## Notas

- Asegúrate de tener configurada correctamente la base de datos antes de ejecutar las consultas.
- Las consultas deben adaptarse al modelo de datos específico que estés utilizando.
