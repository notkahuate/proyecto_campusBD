# Proyecto de Base de Datos - Gestión de Campers

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


Este proyecto está diseñado para gestionar la información de los campers, sus inscripciones, estado, rutas, nivel de riesgo, entre otros. A continuación, se presentan algunas consultas SQL que puedes utilizar para gestionar los datos de los campers.

## Consultas SQL Campers

1. **Obtener todos los campers inscritos actualmente.**
    ```sql
    SELECT c.nombres, c.apellidos, ec.nombre_estado
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Estado_camper ec ON dc.id_estado = ec.id_estado
    WHERE ec.nombre_estado = 'Inscrito';
    ```
   
2. **Listar los campers con estado "Aprobado".**
    ```sql
    SELECT DISTINCT c.nombres, c.apellidos, e.Estado
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Evaluacion e ON i.id_inscripcion = e.id_inscripcion
    WHERE e.Estado = 'Aprobado';
    ```

3. **Mostrar los campers que ya están cursando alguna ruta.**
    ```sql
   SELECT c.nombres, c.apellidos, re.nombre_ruta
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    INNER JOIN Ruta_Entrenamiento re ON i.id_ruta = re.id_ruta
    WHERE i.id_estado_inscripcion = 1;
    ```

4. **Consultar los campers graduados por cada ruta.**
    ```sql
    SELECT re.nombre_ruta, COUNT(e.id_egresado) as total_graduados
    FROM Ruta_Entrenamiento re
    INNER JOIN Inscripcion i ON re.id_ruta = i.id_ruta
    INNER JOIN DATOS_CAMPER dc ON i.id_datoscamper = dc.id_datoscamper
    INNER JOIN EGRESADO e ON dc.id_datoscamper = e.id_datoscamper
    GROUP BY re.nombre_ruta;
    ```

5. **Obtener los campers que se encuentran en estado "Expulsado" o "Retirado".**
    ```sql
   SELECT c.nombres, c.apellidos, ec.nombre_estado
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Estado_camper ec ON dc.id_estado = ec.id_estado
    WHERE ec.nombre_estado IN ('Retirado');
    ```

6. **Listar campers con nivel de riesgo “Alto”.**
    ```sql
    SELECT nombres, apellidos, nivel_riesgo
    FROM Camper
    WHERE nivel_riesgo = 'Alto';
    ```

7. **Mostrar el total de campers por cada nivel de riesgo.**
    ```sql
    SELECT nivel_riesgo, COUNT(*) as total_campers
    FROM Camper
    GROUP BY nivel_riesgo;
    ```

8. **Obtener campers con más de un número telefónico registrado.**
    ```sql
    SELECT c.nombres, c.apellidos, COUNT(tc.id_telefono) as total_telefonos
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Telefono_Camper tc ON dc.id_telefono = tc.id_telefono
    GROUP BY c.id_camper
    HAVING COUNT(tc.id_telefono) > 0;
    ```

9. **Listar los campers y sus respectivos acudientes y teléfonos.**
    ```sql
    SELECT 
    c.nombres as nombre_camper, 
    c.apellidos as apellido_camper,
    a.nombres as nombre_acudiente,
    a.apellidos as apellido_acudiente,
    tc.numero as telefono_camper
    FROM Camper c
    INNER JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    INNER JOIN Acudiente a ON dc.id_acudiente = a.id_acudiente
    INNER JOIN Telefono_Camper tc ON dc.id_telefono = tc.id_telefono;
    ```

10. **Mostrar campers que aún no han sido asignados a una ruta.**
    ```sql
    SELECT c.nombres, c.apellidos
    FROM Camper c
    LEFT JOIN DATOS_CAMPER dc ON c.id_camper = dc.id_camper
    LEFT JOIN Inscripcion i ON dc.id_datoscamper = i.id_datoscamper
    WHERE i.id_ruta IS NULL;
    ```

## Instalación

1. Clona este repositorio en tu máquina local.
2. Crea la base de datos correspondiente en tu sistema de gestión de bases de datos.
3. Ejecuta las consultas SQL en tu entorno de base de datos.

## Notas

- Asegúrate de tener configurada correctamente la base de datos antes de ejecutar las consultas.
- Las consultas deben adaptarse al modelo de datos específico que estés utilizando.

