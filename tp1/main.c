#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "redcaminera.h"



int main (void){
	
	lista* nuevaLista = l_crear();
		
	int poblacion = 1234;
	char* city = "primerCiudad";
	 
	int poblacion2 = 3333;
	char* city2 = "segundaCiudad";
	 
	int poblacion3 = 2233;
	char* city3 = "tercerCiudad";
	
	int poblacion4 = 1133;
	char* city4 = "cuartaCiudad";
	 
	ciudad* nuevaCiudad = c_crear(city,poblacion);
	ciudad* nuevaCiudad2 = c_crear(city2,poblacion2);
	ciudad* nuevaCiudad3 = c_crear(city3,poblacion3);
	ciudad* nuevaCiudad4 = c_crear(city4,poblacion4);


	l_agregarOrdenado(&nuevaLista, nuevaCiudad, (void (*)(void*))c_borrar, (int32_t (*)(void*,void*))c_cmp);
	l_agregarOrdenado(&nuevaLista, nuevaCiudad2, (void (*)(void*))c_borrar, (int32_t (*)(void*,void*))c_cmp);
	l_agregarOrdenado(&nuevaLista, nuevaCiudad4, (void (*)(void*))c_borrar, (int32_t (*)(void*,void*))c_cmp);
	
	l_borrarTodo(nuevaLista);
	
}

