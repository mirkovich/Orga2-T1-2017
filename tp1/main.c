#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include "redcaminera.h"



int main (void){
	// item 1
	redCaminera* red = rc_crear("kukamonga");
	// item 2
	char* montebello = "montebello";
	char* haverbrook = "north haverbrook";
	char* cocula = "cocula";

	rc_agregarCiudad(red,montebello, 12041);
	rc_agregarCiudad(red,haverbrook, 1244);
	rc_agregarCiudad(red,cocula, 342);
	// item 3
	rc_agregarRuta(red,montebello, haverbrook, 232);
	rc_agregarRuta(red,montebello, cocula, 233);
	rc_agregarRuta(red,haverbrook, cocula, 236);
	// item 4
	ciudad* ciudadConMasPoblacion = ciudadMasPoblada(red);
	ruta* rivadavia = rutaMasLarga(red);
	// item 5
	char *archivo  =  "PepeGuapo.txt";
	FILE *pFile;
    pFile = fopen(archivo, "w+");
    
	rc_imprimirTodo(red, pFile);

	//~ char* primero = "alarma";
	//~ char* segundo = "ala";
	//~ int menor = str_cmp(primero,segundo);
	
}



	//~ char* nombredelared = "nombrecopadodelared";
	
	//~ redCaminera* lared = rc_crear(nombredelared);
	
	//~ char* c1 = "a";
	//~ char* c2 = "b";	
	//~ char* c3 = "c";	
	//~ char* c4 = "d";	
	//~ char* c5 = "e";	
	//~ char* c6 = "f";	

	//~ rc_agregarCiudad(lared, c5, 14000);
	//~ rc_agregarCiudad(lared, c2, 12000);
	//~ rc_agregarCiudad(lared, c3, 11000);
	//~ rc_agregarCiudad(lared, c6, 15000);
	//~ rc_agregarCiudad(lared, c4, 13000);
	//~ rc_agregarCiudad(lared, c1, 10000);


	//~ ciudad* primera = lared->ciudades->primero->dato;
	//~ ciudad* segunda = lared->ciudades->primero->siguiente->dato;
	//~ ciudad* tercera = lared->ciudades->primero->siguiente->siguiente->dato;
	//~ ciudad* cuarta 	= lared->ciudades->primero->siguiente->siguiente->siguiente->dato;
	//~ ciudad* quinta 	= lared->ciudades->primero->siguiente->siguiente->siguiente->siguiente->dato;
	//~ ciudad* sexta 	= lared->ciudades->primero->siguiente->siguiente->siguiente->siguiente->siguiente->dato;

	//~ ciudad* ciu1 = c_crear(c1,10000);
	//~ ciudad* ciu2 = c_crear(c2,10000);
	//~ ciudad* ciu3 = c_crear(c3,10000);
	//~ ciudad* ciu4 = c_crear(c4,10000);
	
	
	//~ rc_agregarRuta(lared, c2, c3, 20.123);
	//~ ruta* primera_rutaIni = lared->rutas->primero->dato;
	//~ rc_agregarRuta(lared, c3, c4, 30.123);
	//~ rc_agregarRuta(lared, c4, c3, 40.123);
	//~ rc_agregarRuta(lared, c1, c2, 10.123);
	//~ rc_agregarRuta(lared, c5, c5, 50.123);
	//~ rc_agregarRuta(lared, c1, c2, 10.123);
	//~ rc_agregarRuta(lared, c1, c2, 10.123);

	//~ ruta* primera_ruta = lared->rutas->primero->dato;
	//~ ruta* segunda_ruta = lared->rutas->primero->siguiente->dato;
	//~ ruta* tercera_ruta = lared->rutas->primero->siguiente->siguiente->dato;
	//~ ruta* cuarta_ruta  = lared->rutas->primero->siguiente->siguiente->siguiente->dato;
	//~ ruta* quinta_ruta  = lared->rutas->primero->siguiente->siguiente->siguiente->siguiente->dato;
	//~ ruta* sexta_ruta   = lared->ciudades->primero->siguiente->siguiente->siguiente->siguiente->siguiente->dato;



	//~ int poblacion = 1234;
	//~ char* city = "a";
	 
	//~ int poblacion2 = 3333;
	//~ char* city2 = "d";
	 
	//~ int poblacion3 = 2233;
	//~ char* city3 = "c";
	
	//~ int poblacion4 = 1133;
	//~ char* city4 = "cuartaCiudad";

	//~ ciudad* nuevaCiudad = c_crear(city,poblacion);
	//~ ciudad* nuevaCiudad2 = c_crear(city2,poblacion2);
	//~ ciudad* nuevaCiudad3 = c_crear(city3,poblacion3);
	//~ ciudad* nuevaCiudad4 = c_crear(city4,poblacion4);

	//~ ruta* ruta_a_d = r_crear(nuevaCiudad, nuevaCiudad2, 12.012);
	//~ ruta* ruta_a_c = r_crear(nuevaCiudad, nuevaCiudad3, 10.012);

	//~ int num = r_cmp(ruta_a_c, ruta_a_d);



	//~ lista* nuevaLista = l_crear();
		
	 
	
	//~ //c_borrar(nuevaCiudad);
	
	//~ l_agregarOrdenado(&nuevaLista, nuevaCiudad, (void (*)(void*))c_borrar, (int32_t (*)(void*,void*))c_cmp);
	//~ l_agregarOrdenado(&nuevaLista, nuevaCiudad2, (void (*)(void*))c_borrar, (int32_t (*)(void*,void*))c_cmp);
	//~ l_agregarOrdenado(&nuevaLista, nuevaCiudad4, (void (*)(void*))c_borrar, (int32_t (*)(void*,void*))c_cmp);
	
	//~ l_borrarTodo(nuevaLista);






	//~ ruta* nuevaRuta = r_crear(nuevaCiudad, nuevaCiudad2, 30.124);
	//~ ruta* nuevaRuta2 = r_crear(nuevaCiudad, nuevaCiudad3, 20.124);

	//~ int diferencia =  r_cmp(nuevaRuta2, nuevaRuta);





	//~ char* red = "mi primer RED";
	//~ redCaminera* nuevaRed = rc_crear(red);

	//~ int poblacion = 1234;
	//~ char* city = "a";
	//~ char* city2 = "b";
	//~ char* city3 = "c";
	//~ char* city4 = "d";
	 
	//~ rc_agregarCiudad(nuevaRed, city, poblacion);
	//~ rc_agregarCiudad(nuevaRed, city2,poblacion);
	//~ rc_agregarCiudad(nuevaRed, city3,poblacion);
	//~ rc_agregarCiudad(nuevaRed, city4,poblacion);
	
	
	//~ rc_agregarRuta(nuevaRed, city, city2, 12.323);
	//~ rc_agregarRuta(nuevaRed, city3, city4, 90.323);
	//~ ciudad* ciudadObtenida = obtenerCiudad(nuevaRed, city2);
	
	//~ ruta* rutaObtenida = obtenerRuta(nuevaRed, city3, city4);		

	//~ ciudad* ciudadConMasGente = ciudadMasPoblada(nuevaRed);
	//~ ruta* laRutaMasLarga = rutaMasLarga(nuevaRed);








	
