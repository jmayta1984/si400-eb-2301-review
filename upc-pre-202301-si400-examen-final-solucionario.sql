
-- Pregunta 1
-- Crear un procedimiento almacenado o función que retorne los nombres de los asesores con la mayor cantidad de alumnos asignados.

create view v_students_quantity_per_adviser
as
select a.first_name first_name, a.last_name last_name, count(s.id) quantity
from advisers a
	join students s on a.id = s.adviser_id
group by a.first_name, a.last_name
go

create function f_adviser_with_max_students_quantity() returns table
return
	select first_name, last_name
	from v_students_quantity_per_adviser
	where quantity = (select max(quantity) from v_students_quantity_per_adviser)

-- Pregunta 2
-- Crear un procedimiento almacenado o función que retorne los nombres de los asesores con la mayor cantidad de alumnos asignados.

create view v_students_quantity_per_master
as
select name, version, count(s.id) quantity
from masters m
	join students s on m.id = s.master_id
group by name, version
go

create function f_master_with_max_students_quantity() returns table
return
	select name, version
	from v_students_quantity_per_master
	where quantity = (select max(quantity) from v_students_quantity_per_master)

-- Pregunta 3
-- Crear un procedimiento almacenado o función que retorne los nombres completos de los estudiantes que no forman parte de ningún grupo de estudio.

select first_name, last_name
from students where id not in (select students_id from students_by_group)

-- Pregunta 4
-- Crear un procedimiento almacenado o función que retorne los nombres de los cursos con la mayor cantidad de conferencias.

create view v_conferences_quantity_per_course
as
select name, count(co.id) quantity
from courses c
	join conferences co on c.id = co.course_id
group by name
go

create function f_course_with_max_conferences_quantity() returns table
return
	select name
	from v_conferences_quantity_per_course
	where quantity = (select max(quantity) from v_conferences_quantity_per_course)

-- Pregunta 5
-- Crear un procedimiento almacenado o función que retorne la cantidad consolidada de actividades (exámenes, ensayos y presentaciones) para cada curso.


create view v_activities_quantity_per_course
as 
select course_id, count (*) quantity
from keynotes
group by course_id

union all

select course_id, count (*) quantity
from essays
group by course_id


union all

select course_id, count (*) quantity
from exams
group by course_id
go

create function f_activities_quantity_per_course() returns table
return
	select id, name, sum(quantity)
	from courses c
		join v_activities_quantity_per_course v on c.id = v.course_id
	group by id, name

-- Pregunta 6
-- Establecer una regla de validación utilizando JSON Schema para la colección de documentos que represente una lista de reproducción creada por un usuario.

db.createCollection("lista_reproduccion", {
   validator: {
      $jsonSchema: {
         bsonType: "object",
         required: [ "nombre", "usuario", "fecha_creacion", "canciones" ],
         properties: {
            nombre: {
               bsonType: "string",
            },
            usuario: {
               bsonType: "object",
               required: ["nombre", "fecha_registro", "plan"],
               properties: {
               	nombre: {
               		bsonType: "string"
               	},
               	fecha_registro: {
               		bsonType: "date"
               	},
               	plan: {
               		bsonType: "object"
               	}
               }
            
            },
            fecha_creacion: {
            	bsonType: "date"
            },
            canciones: {
            	bsonType: "array",
            	minItems: 1,
            	items: {
            		bsonType: "object",
            		required: ["nombre", "album", "artista"]
            	}
            }
           
         }
      }
   }
} )

-- Pregunta 7
-- Indicar los patrones de modelado de datos utilizados para el documento que representa una lista de reproducción creada por un usuario.

-- Relaciones de 1 a 1
-- Una lista de reproducción es creada por un usuario
-- Documento embebido: En el mismo documento que representa una lista de reproducción se tiene un campo [usuario] el cual es un objeto que representa un usuario.

-- Relaciones de 1 a muchos
-- Una lista de reproducción tiene varias canciones
-- Documento embebido: En el mismo documento que representa una lista de reproducción se tiene un campo [canciones] el cual es la relación de canciones incluídas en la lista.

-- Pregunta 8
-- Escribir una consulta que permita mostrar la cantidad de ventas realizadas en cada ciudad.
-- Considerar solo aquellas ventas en la cuales se haya utilizado un cupón de descuento. 

db.sales.aggregate([
	{
		$match : {couponUsed : true } 
	},
 	{
 		$group: {
 			_id: "$storeLocation",
	 		quantity: { $count: {}}
 		}
 	}
])

-- Pregunta 9
-- Escribir una consulta que permita mostrar la cantidad de ventas realizadas por cada método de compra.
-- Considerar solo aquellas ventas en las cuales la satisfacción del cliente haya sido mayor o igual a 4

db.sales.aggregate([
	{
		$match : {"$customer.satisfaccion" : { $gte: 4 } } 
	}, 
 	{
 		$group: {
 			_id: "$purchaseMethod",
 			count: { $count: {} }
 		}
 	}
])
