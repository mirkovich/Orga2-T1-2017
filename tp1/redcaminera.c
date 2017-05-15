#include "redcaminera.h"

void rc_imprimirTodo(redCaminera* rc, FILE *pFile) {
	lista* ciudades;
	lista* rutas;
	ciudades = rc->ciudades;
	rutas = rc->rutas;
	fprintf(pFile,"Nombre:\n"); // según el formato
	fprintf(pFile, "%s\n", rc->nombre);
	nodo* nodo_actual_c = ciudades->primero;
	nodo* nodo_actual_r = rutas->primero;
	ciudad* ciudad_actual;
	ruta* ruta_actual;
	fprintf(pFile,"Ciudades:\n");
	while (nodo_actual_c != NULL)
		{
			ciudad_actual = nodo_actual_c->dato;
			fprintf(pFile,"[%s,%li]\n", ciudad_actual->nombre, ciudad_actual->poblacion);
			nodo_actual_c = nodo_actual_c->siguiente;
		}
	fprintf(pFile,"Rutas:\n");
	while (nodo_actual_r != NULL)
		{
			ruta_actual = nodo_actual_r->dato;
			fprintf(pFile,"[%s,%s,%.1f]\n", ruta_actual->ciudadA->nombre , ruta_actual->ciudadB->nombre, ruta_actual->distancia);
			nodo_actual_r = nodo_actual_r->siguiente;
		}	
	
}

redCaminera* rc_combinarRedes(char* nombre, redCaminera* rc1, redCaminera* rc2) {
    redCaminera* redCombinada= rc_crear(nombre);
    lista* list_ciudades_rc1 = rc1->ciudades;
    lista* list_ciudades_rc2 = rc2->ciudades;

    lista* list_rutas_rc1 = rc1->rutas;
    lista* list_rutas_rc2 = rc2->rutas;

    nodo* nodo_actual_ciudades_rc1 = list_ciudades_rc1->primero;
    nodo* nodo_actual_rutas_rc1 = list_rutas_rc1->primero;
    
    nodo* nodo_actual_ciudades_rc2 = list_ciudades_rc2->primero;
    nodo* nodo_actual_rutas_rc2 = list_rutas_rc2->primero;
    
    ciudad* ciudad_a_agregar;
    ruta* ruta_a_agregar;
    
    // agregamos las ciudades de la primer red
    while (nodo_actual_ciudades_rc1 != NULL)
		{
			ciudad_a_agregar = nodo_actual_ciudades_rc1->dato;
			rc_agregarCiudad(redCombinada, ciudad_a_agregar->nombre ,ciudad_a_agregar->poblacion);
			nodo_actual_ciudades_rc1 = nodo_actual_ciudades_rc1->siguiente;	
		}
	// una vez agregadas estas. agregamos la de la otra ruta
	while (nodo_actual_ciudades_rc2 != NULL)
		{
			ciudad_a_agregar = nodo_actual_ciudades_rc2->dato;
			rc_agregarCiudad(redCombinada, ciudad_a_agregar->nombre ,ciudad_a_agregar->poblacion);
			nodo_actual_ciudades_rc2 = nodo_actual_ciudades_rc2->siguiente;	
		}
	//AHORA NOS OCUPAMOS DE LAS RUTAS

    // agregamos las ciudades de la primer red
    while (nodo_actual_rutas_rc1 != NULL)
		{
			ruta_a_agregar = nodo_actual_rutas_rc1->dato;
			rc_agregarRuta(redCombinada, ruta_a_agregar->ciudadA->nombre, ruta_a_agregar->ciudadB->nombre ,ruta_a_agregar->distancia);
			nodo_actual_rutas_rc1 = nodo_actual_rutas_rc1->siguiente;	
		}
	// una vez agregadas estas. agregamos la de la otra ruta
	while (nodo_actual_rutas_rc2 != NULL)
		{
			ruta_a_agregar = nodo_actual_rutas_rc2->dato;
			rc_agregarRuta(redCombinada, ruta_a_agregar->ciudadA->nombre, ruta_a_agregar->ciudadB->nombre ,ruta_a_agregar->distancia);
			nodo_actual_rutas_rc2 = nodo_actual_rutas_rc2->siguiente;	
		}
    return redCombinada;
}

redCaminera* rc_obtenerSubRed(char* nombre, redCaminera* rc, lista* ciudades) {
	redCaminera* subRed = rc_crear(nombre);
	
	nodo* nodo_actual_lista_ciudades = ciudades->primero;
	ciudad* ciudad_de_la_sub_red;
	// agregamos las ciudades que estan tanto en la lista pasada como en la red pasada
	while(nodo_actual_lista_ciudades != NULL)
		{
			ciudad_de_la_sub_red = nodo_actual_lista_ciudades->dato;
			ciudad_de_la_sub_red = obtenerCiudad(rc, ciudad_de_la_sub_red->nombre);
			if (ciudad_de_la_sub_red != NULL){
					ciudad_de_la_sub_red = nodo_actual_lista_ciudades->dato;				
					rc_agregarCiudad(subRed,ciudad_de_la_sub_red->nombre ,ciudad_de_la_sub_red->poblacion);
				}
		nodo_actual_lista_ciudades = nodo_actual_lista_ciudades->siguiente;
		}
		
	lista* ciudades_sub_red = subRed->ciudades;
	int n = ciudades_sub_red->longitud;
	ciudad* ciudad_1;
	ciudad* ciudad_2;
	ruta* ruta_sub_red;
	nodo* nodo1 = ciudades_sub_red->primero;
	for(int i =0; i < n ; i++)
		{
			nodo* nodo2 = ciudades_sub_red->primero;
			ciudad_1 = nodo1->dato;			
			for(int j = 0; j< n ; j++)
				{
					ciudad_2 = nodo2->dato;	
					ruta_sub_red = obtenerRuta(rc, ciudad_1->nombre,ciudad_2->nombre);
					
					if (ruta_sub_red != NULL){
							rc_agregarRuta(subRed, ruta_sub_red->ciudadA->nombre, ruta_sub_red->ciudadB->nombre ,ruta_sub_red->distancia);

						}	
					nodo2 = nodo2->siguiente;
				}		
			nodo1 = nodo1->siguiente;
		}
	
    return subRed;
}
