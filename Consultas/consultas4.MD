# Proyecto de Base de Datos - Gestión de Trainers

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

Este proyecto tiene como objetivo gestionar la información sobre los entrenadores, su asignación a rutas, módulos, áreas de trabajo y disponibilidad. A continuación, se presentan las consultas SQL para obtener información detallada sobre los entrenadores.

## Consultas SQL

1. **Listar todos los entrenadores registrados.**
    ```sql
    SELECT 
    t.id_trainner,
    t.nombre,
    t.apellido,
    t.especialidad,
    dt.id_datos_trainner,
    tc.numero as telefono
    FROM Trainner t
    LEFT JOIN DATOS_TRAINNER dt ON t.id_trainner = dt.id_trainner
    LEFT JOIN Telefono_Trainner tc ON dt.id_telefono = tc.id_telefono
    ORDER BY t.apellido, t.nombre;
    ```

2. **Mostrar los trainers con sus horarios asignados.**
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
    ORDER BY t.nombre, hc.dia_semana, hc.hora_inicio;
    ```

3. **Consultar los trainers asignados a más de una ruta.**
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

4. **Obtener el número de campers por trainer.**
    ```sql
    SELECT 
    t.nombre,
    t.apellido,
    COUNT(DISTINCT gca.id_camper) as total_campers,
    GROUP_CONCAT(DISTINCT gc.nombre_grupo) as grupos
    FROM Trainner t
    LEFT JOIN Asignacion_Entrenador_Grupo aeg ON t.id_trainner = aeg.id_entrenador
    LEFT JOIN Grupo_Campers gc ON aeg.id_grupo = gc.id_grupo
    LEFT JOIN Grupo_Camper_Asignacion gca ON gc.id_grupo = gca.id_grupo
    GROUP BY t.id_trainner, t.nombre, t.apellido
    ORDER BY total_campers DESC;
    ```

5. **Mostrar las áreas en las que trabaja cada trainer.**
    ```sql
    SELECT 
    t.nombre,
    t.apellido,
    COUNT(DISTINCT aeg.id_area) as total_areas,
    GROUP_CONCAT(DISTINCT ae.nombre_area) as areas_asignadas
    FROM Trainner t
    LEFT JOIN Asignacion_Entrenador_Grupo aeg ON t.id_trainner = aeg.id_entrenador
    LEFT JOIN Area_Entrenamiento ae ON aeg.id_area = ae.id_area
    GROUP BY t.id_trainner, t.nombre, t.apellido
    ORDER BY total_areas DESC;
    ```

6. **Listar los trainers sin asignación de área o ruta.**
    ```sql
    SELECT 
    t.nombre,
    t.apellido,
    t.especialidad
    FROM Trainner t
    LEFT JOIN Asignacion_Trainner at ON t.id_trainner = at.id_trainner
    LEFT JOIN Asignacion_Entrenador_Grupo aeg ON t.id_trainner = aeg.id_entrenador
    WHERE at.id_asignacion IS NULL AND aeg.id_asignacion IS NULL;
    ```

7. **Mostrar cuántos módulos están a cargo de cada trainer.**
    ```sql
    SELECT 
    t.nombre,
    t.apellido,
    COUNT(DISTINCT ma.id_modulo) as total_modulos,
    GROUP_CONCAT(DISTINCT ma.nombre_modulo) as modulos_asignados
    FROM Trainner t
    INNER JOIN Asignacion_Trainner at ON t.id_trainner = at.id_trainner
    INNER JOIN Ruta_Entrenamiento re ON at.id_ruta = re.id_ruta
    INNER JOIN Skill s ON re.id_ruta = s.id_ruta
    INNER JOIN Modulo_Aprendizaje ma ON s.id_skill = ma.id_skill
    GROUP BY t.id_trainner, t.nombre, t.apellido
    ORDER BY total_modulos DESC;
    ```

8. **Obtener el trainer con mejor rendimiento promedio de campers.**
    ```sql
    SELECT 
    t.nombre,
    t.apellido,
    ROUND(AVG(e.calificacion_final), 2) as promedio_campers,
    COUNT(DISTINCT c.id_camper) as total_campers
    FROM Trainner t
    INNER JOIN Asignacion_Entrenador_Grupo aeg ON t.id_trainner = aeg.id_entrenador
    INNER JOIN Grupo_Campers gc ON aeg.id_grupo = gc.id_grupo
    INNER JOIN Grupo_Camper_Asignacion gca ON gc.id_grupo = gca.id_grupo
    INNER JOIN Camper c ON gca.id_camper = c.id_camper
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    GROUP BY t.id_trainner, t.nombre, t.apellido
    ORDER BY promedio_campers DESC
    LIMIT 1;
    ```

9. **Consultar los horarios ocupados por cada trainer.**
    ```sql
    SELECT 
    t.nombre,
    t.apellido,
    hc.dia_semana,
    hc.hora_inicio,
    hc.hora_fin,
    ae.nombre_area,
    gc.nombre_grupo
    FROM Trainner t
    INNER JOIN Asignacion_Entrenador_Grupo aeg ON t.id_trainner = aeg.id_entrenador
    INNER JOIN Horario_Clase hc ON aeg.id_asignacion = hc.id_horario
    INNER JOIN Area_Entrenamiento ae ON aeg.id_area = ae.id_area
    INNER JOIN Grupo_Campers gc ON aeg.id_grupo = gc.id_grupo
    ORDER BY t.nombre, hc.dia_semana, hc.hora_inicio;
    ```

10. **Mostrar la disponibilidad semanal de cada trainer.**
    ```sql
    WITH HorarioCompleto AS (
    SELECT DISTINCT 
        dia_semana,
        hora_inicio,
        hora_fin
    FROM Horario_Clase
    )
    SELECT 
        t.nombre,
        t.apellido,
        hc.dia_semana,
        hc.hora_inicio,
        hc.hora_fin,
        CASE 
            WHEN aeg.id_asignacion IS NULL THEN 'Disponible'
            ELSE 'Ocupado'
        END as estado
    FROM Trainner t
    CROSS JOIN HorarioCompleto hc
    LEFT JOIN Asignacion_Entrenador_Grupo aeg ON t.id_trainner = aeg.id_entrenador
    ORDER BY t.nombre, hc.dia_semana, hc.hora_inicio;
    ```

## Instalación

1. Clona este repositorio en tu máquina local.
2. Crea la base de datos correspondiente en tu sistema de gestión de bases de datos.
3. Ejecuta las consultas SQL en tu entorno de base de datos.

## Notas

- Asegúrate de tener configurada correctamente la base de datos antes de ejecutar las consultas.
- Las consultas deben adaptarse al modelo de datos específico que estés utilizando.

