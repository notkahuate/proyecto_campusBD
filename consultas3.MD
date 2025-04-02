# Proyecto de Base de Datos - Gestión de Rutas y Áreas de Entrenamiento

Este proyecto está enfocado en gestionar las rutas de entrenamiento, módulos asociados, áreas de entrenamiento y su ocupación. A continuación, se presentan las consultas SQL para obtener información detallada sobre las rutas y áreas de entrenamiento.

## Consultas SQL

1. **Mostrar todas las rutas de entrenamiento disponibles.**
    ```sql
    SELECT 
    re.id_ruta,
    re.nombre_ruta,
    COUNT(DISTINCT s.id_skill) as total_skills
    FROM Ruta_Entrenamiento re
    LEFT JOIN Skill s ON re.id_ruta = s.id_ruta
    GROUP BY re.id_ruta, re.nombre_ruta
    ORDER BY re.nombre_ruta;
    ```

2. **Obtener las rutas con su SGDB principal y alternativo.**
    ```sql
    SELECT 
    re.nombre_ruta,
    rb.BD as sgdb_principal,
    GROUP_CONCAT(DISTINCT rb2.BD) as sgdbs_alternativos
    FROM Ruta_Entrenamiento re
    INNER JOIN Ruta_BD rb ON re.sgdb_principal = rb.id_rutaBD
    LEFT JOIN Ruta_BD rb2 ON rb2.id_rutaBD != re.sgdb_principal
    GROUP BY re.id_ruta, re.nombre_ruta, rb.BD
    ORDER BY re.nombre_ruta;
    ```

3. **Listar los módulos asociados a cada ruta.**
    ```sql
    SELECT 
    re.nombre_ruta,
    s.nombre_skill,
    ma.nombre_modulo,
    ma.descripcion
    FROM Ruta_Entrenamiento re
    INNER JOIN Skill s ON re.id_ruta = s.id_ruta
    INNER JOIN Modulo_Aprendizaje ma ON s.id_skill = ma.id_skill
    ORDER BY re.nombre_ruta, s.nombre_skill, ma.nombre_modulo;
    ```

4. **Consultar cuántos campers hay en cada ruta.**
    ```sql
    SELECT 
    re.nombre_ruta,
    COUNT(DISTINCT i.id_datoscamper) as total_campers,
    COUNT(DISTINCT gc.id_grupo) as total_grupos
    FROM Ruta_Entrenamiento re
    LEFT JOIN Inscripcion i ON re.id_ruta = i.id_ruta
    LEFT JOIN Grupo_Campers gc ON re.id_ruta = gc.id_ruta
    GROUP BY re.id_ruta, re.nombre_ruta
    ORDER BY total_campers DESC;
    ```

5. **Mostrar las áreas de entrenamiento y su capacidad máxima.**
    ```sql
    SELECT 
    nombre_area,
    capacidad_maxima,
    ocupacion_actual,
    estado,
    (capacidad_maxima - ocupacion_actual) as cupos_disponibles
    FROM Area_Entrenamiento
    ORDER BY ocupacion_actual DESC;
    ```

6. **Obtener las áreas que están ocupadas al 100%.**
    ```sql
    SELECT 
    nombre_area,
    capacidad_maxima,
    ocupacion_actual,
    ROUND((ocupacion_actual * 100.0 / capacidad_maxima), 2) as porcentaje_ocupacion
    FROM Area_Entrenamiento
    WHERE ocupacion_actual = capacidad_maxima;
    ```

7. **Verificar la ocupación actual de cada área.**
    ```sql
    SELECT 
    ae.nombre_area,
    ae.ocupacion_actual,
    COUNT(DISTINCT aeg.id_entrenador) as total_trainers,
    COUNT(DISTINCT gca.id_camper) as total_campers
    FROM Area_Entrenamiento ae
    LEFT JOIN Asignacion_Entrenador_Grupo aeg ON ae.id_area = aeg.id_area
    LEFT JOIN Grupo_Campers gc ON aeg.id_grupo = gc.id_grupo
    LEFT JOIN Grupo_Camper_Asignacion gca ON gc.id_grupo = gca.id_grupo
    GROUP BY ae.id_area, ae.nombre_area, ae.ocupacion_actual
    ORDER BY ae.ocupacion_actual DESC;
    ```

8. **Consultar los horarios disponibles por cada área.**
    ```sql
    SELECT 
    ae.nombre_area,
    hc.dia_semana,
    hc.hora_inicio,
    hc.hora_fin,
    CASE 
        WHEN aeg.id_asignacion IS NULL THEN 'Disponible'
        ELSE 'Ocupado'
    END as estado
    FROM Area_Entrenamiento ae
    CROSS JOIN Horario_Clase hc
    LEFT JOIN Asignacion_Entrenador_Grupo aeg ON ae.id_area = aeg.id_area
    WHERE ae.estado = 'Activo'
    ORDER BY ae.nombre_area, hc.dia_semana, hc.hora_inicio;
    ```

9. **Mostrar las áreas con más campers asignados.**
    ```sql
    SELECT 
    ae.nombre_area,
    COUNT(DISTINCT gca.id_camper) as total_campers,
    GROUP_CONCAT(DISTINCT gc.nombre_grupo) as grupos_asignados
    FROM Area_Entrenamiento ae
    INNER JOIN Asignacion_Entrenador_Grupo aeg ON ae.id_area = aeg.id_area
    INNER JOIN Grupo_Campers gc ON aeg.id_grupo = gc.id_grupo
    INNER JOIN Grupo_Camper_Asignacion gca ON gc.id_grupo = gca.id_grupo
    GROUP BY ae.id_area, ae.nombre_area
    ORDER BY total_campers DESC;
    ```

10. **Listar las rutas con sus respectivos trainers y áreas asignadas.**
    ```sql
    SELECT 
    re.nombre_ruta,
    GROUP_CONCAT(DISTINCT CONCAT(t.nombre, ' ', t.apellido)) as trainers,
    GROUP_CONCAT(DISTINCT ae.nombre_area) as areas_asignadas
    FROM Ruta_Entrenamiento re
    LEFT JOIN Asignacion_Trainner at ON re.id_ruta = at.id_ruta
    LEFT JOIN Trainner t ON at.id_trainner = t.id_trainner
    LEFT JOIN Asignacion_Entrenador_Grupo aeg ON t.id_trainner = aeg.id_entrenador
    LEFT JOIN Area_Entrenamiento ae ON aeg.id_area = ae.id_area
    GROUP BY re.id_ruta, re.nombre_ruta
    ORDER BY re.nombre_ruta;
    ```

## Instalación

1. Clona este repositorio en tu máquina local.
2. Crea la base de datos correspondiente en tu sistema de gestión de bases de datos.
3. Ejecuta las consultas SQL en tu entorno de base de datos.

## Notas

- Asegúrate de tener configurada correctamente la base de datos antes de ejecutar las consultas.
- Las consultas deben adaptarse al modelo de datos específico que estés utilizando.

