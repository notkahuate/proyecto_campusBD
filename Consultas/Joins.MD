# Proyecto de Base de Datos - Consultas con JOINs


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

Este proyecto incluye ejemplos de consultas SQL utilizando JOINs básicos (INNER JOIN, LEFT JOIN, etc.) para obtener información relacionada entre diferentes tablas. Estas consultas están orientadas a obtener detalles sobre los campers, rutas, módulos, trainers y áreas de entrenamiento.

## Consultas SQL con JOINs

1. **Obtener los nombres completos de los campers junto con el nombre de la ruta a la que están inscritos.**
    ```sql
    SELECT 
    c.nombres,
    c.apellidos,
    re.nombre_ruta,
    i.fecha_inscripcion
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Ruta_Entrenamiento re ON i.id_ruta = re.id_ruta
    ORDER BY re.nombre_ruta, c.apellidos;
    ```

2. **Mostrar los campers con sus evaluaciones (nota teórica, práctica, quizzes y nota final) por cada módulo.**
    ```sql
    SELECT 
    c.nombres,
    c.apellidos,
    ma.nombre_modulo,
    e.nota_teorica,
    e.nota_practica,
    e.nota_trabajos_quizzes,
    e.calificacion_final,
    e.Estado
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    INNER JOIN Modulo_Aprendizaje ma ON e.id_modulo = ma.id_modulo
    ORDER BY c.apellidos, ma.nombre_modulo;
    ```

3. **Listar todos los módulos que componen cada ruta de entrenamiento.**
    ```sql
    SELECT 
    re.nombre_ruta,
    s.nombre_skill,
    ma.nombre_modulo,
    ma.descripcion
    FROM Ruta_Entrenamiento re
    INNER JOIN Skill s ON re.id_ruta = s.id_ruta
    INNER JOIN Modulo_Aprendizaje ma ON s.id_skill = ma.id_skill
    ORDER BY re.nombre_ruta, s.nombre_skill;
    ```

4. **Consultar las rutas con sus trainers asignados y las áreas en las que imparten clases.**
    ```sql
    SELECT 
    re.nombre_ruta,
    t.nombre as nombre_trainer,
    t.apellido as apellido_trainer,
    ae.nombre_area
    FROM Ruta_Entrenamiento re
    INNER JOIN Asignacion_Trainner at ON re.id_ruta = at.id_ruta
    INNER JOIN Trainner t ON at.id_trainner = t.id_trainner
    LEFT JOIN Asignacion_Entrenador_Grupo aeg ON t.id_trainner = aeg.id_entrenador
    LEFT JOIN Area_Entrenamiento ae ON aeg.id_area = ae.id_area
    ORDER BY re.nombre_ruta, t.apellido;
    ```

5. **Mostrar los campers junto con el trainer responsable de su ruta actual.**
    ```sql
    SELECT 
    c.nombres as nombre_camper,
    c.apellidos as apellido_camper,
    re.nombre_ruta,
    t.nombre as nombre_trainer,
    t.apellido as apellido_trainer
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Ruta_Entrenamiento re ON i.id_ruta = re.id_ruta
    INNER JOIN Asignacion_Trainner at ON re.id_ruta = at.id_ruta
    INNER JOIN Trainner t ON at.id_trainner = t.id_trainner
    ORDER BY c.apellidos;
    ```

6. **Obtener el listado de evaluaciones realizadas con nombre de camper, módulo y ruta.**
    ```sql
    SELECT 
    c.nombres,
    c.apellidos,
    ma.nombre_modulo,
    re.nombre_ruta,
    e.calificacion_final,
    e.fecha_evaluacion
    FROM Evaluacion e
    INNER JOIN Inscripcion i ON e.id_inscripcion = i.id_inscripcion
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN Camper c ON dc.id_camper = c.id_camper
    INNER JOIN Modulo_Aprendizaje ma ON e.id_modulo = ma.id_modulo
    INNER JOIN Skill s ON ma.id_skill = s.id_skill
    INNER JOIN Ruta_Entrenamiento re ON s.id_ruta = re.id_ruta
    ORDER BY e.fecha_evaluacion DESC;
    ```

7. **Listar los trainers y los horarios en que están asignados a las áreas de entrenamiento.**
    ```sql
    SELECT 
    t.nombre,
    t.apellido,
    ae.nombre_area,
    hc.dia_semana,
    hc.hora_inicio,
    hc.hora_fin
    FROM Trainner t
    INNER JOIN Asignacion_Entrenador_Grupo aeg ON t.id_trainner = aeg.id_entrenador
    INNER JOIN Area_Entrenamiento ae ON aeg.id_area = ae.id_area
    INNER JOIN Horario_Clase hc ON aeg.id_asignacion = hc.id_horario
    ORDER BY t.apellido, hc.dia_semana, hc.hora_inicio;
    ```

8. **Consultar todos los campers junto con su estado actual y el nivel de riesgo.**
    ```sql
    SELECT 
    c.nombres,
    c.apellidos,
    ec.nombre_estado,
    c.nivel_riesgo
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Estado_camper ec ON dc.id_estado = ec.id_estado
    ORDER BY c.nivel_riesgo DESC, c.apellidos;
    ```

9. **Obtener todos los módulos de cada ruta junto con su porcentaje teórico, práctico y de quizzes.**
    ```sql
    SELECT 
    re.nombre_ruta,
    ma.nombre_modulo,
    'Teórico: 30%, Práctico: 60%, Quizzes: 10%' as distribucion_notas
    FROM Ruta_Entrenamiento re
    INNER JOIN Skill s ON re.id_ruta = s.id_ruta
    INNER JOIN Modulo_Aprendizaje ma ON s.id_skill = ma.id_skill
    ORDER BY re.nombre_ruta, ma.nombre_modulo;
    ```

10. **Mostrar los nombres de las áreas junto con los nombres de los campers que están asistiendo en esos espacios.**
    ```sql
    SELECT 
    ae.nombre_area,
    c.nombres,
    c.apellidos,
    gc.nombre_grupo
    FROM Area_Entrenamiento ae
    INNER JOIN Asignacion_Entrenador_Grupo aeg ON ae.id_area = aeg.id_area
    INNER JOIN Grupo_Campers gc ON aeg.id_grupo = gc.id_grupo
    INNER JOIN Grupo_Camper_Asignacion gca ON gc.id_grupo = gca.id_grupo
    INNER JOIN Camper c ON gca.id_camper = c.id_camper
    ORDER BY ae.nombre_area, c.apellidos;
    ```

## Instalación

1. Clona este repositorio en tu máquina local.
2. Crea la base de datos correspondiente en tu sistema de gestión de bases de datos.
3. Ejecuta las consultas SQL en tu entorno de base de datos.

## Notas

- Asegúrate de tener configurada correctamente la base de datos antes de ejecutar las consultas.
- Las consultas deben adaptarse al modelo de datos específico que estés utilizando.

