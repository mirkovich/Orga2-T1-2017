; funciones de CASO

extern malloc
extern free
extern fprintf

;#####################################################################################################################################
;																 LISTA 
;#####################################################################################################################################

%define NULL 0 

;####################################################
;############## offset para lista ###################
;####################################################

%define offset_tamanio_struct_lista 20

;################ para el struct ####################

%define offset_longitud_lista 0
%define offset_primero_lista 4
%define offset_ultimo_lista 12


;####################################################
;############## offset para nodo ####################
;####################################################

%define offset_tamanio_struct_nodo 32

;################ para el struct ####################

%define offset_funcion_borrar_nodo 0
%define offset_dato_nodo 8
%define offset_siguiente_nodo 16
%define offset_anterior_nodo  24	

;####################################################
;############## offset para ciudad ##################
;####################################################

%define offset_tamanio_struct_ciudad 16

;####################################################

%define offset_nombre_ciudad 0
%define offset_poblacion_ciudad 8

;####################################################
;############## offset para ruta ####################
;####################################################

%define offset_tamanio_struct_ruta 24

;####################################################

%define offset_ciudadA_ruta 0
%define offset_distancia_ruta 8 
%define offset_ciudadB_ruta 16


;####################################################
;############## offset para redCaminera #############
;####################################################

%define offset_tamanio_struct_redCaminera 24

;####################################################

%define offset_ciudades_redCaminera 0
%define offset_rutas_redCaminera 8
%define offset_nombre_redCaminera 16

;####################################################
;############## offset para aux #############
;####################################################
%define offset_tamanio_puntero 0
;####################################################

section .text

;####################################################
;###### crea una lista vacia  lista* l crear();######       (PERFECTO)                       
;####################################################
global l_crear
l_crear:

	push rbp									; prepraro el stack frame 	
	mov rbp, rsp

	mov rdi , offset_tamanio_struct_lista
	call malloc										; rax <-- *nueva_list
													; la estructura lista tiene dos punteros a listas que unicialmente 
													; van a ser null y un char* que tambien va a ser null
	mov dword[rax + offset_longitud_lista], 0
	mov qword[rax + offset_primero_lista], NULL  	; ## R#CORDAR ## siempre que muevo a memoria digo el tamaño del espacio de memoria.
	mov qword[rax + offset_ultimo_lista], NULL	

	pop rbp
	ret


;#############################################################################################
;################ agrega un nuevo nodo a la lista, como primer elemento ######################
;###### void l agregarAdelante(lista** l, void* dato, void (*func borrar)(void*)); ########### 
;######							RDI 			RSI 		RDX					   ###########
;#############################################################################################
; 									(PERFECTO)			

global l_agregarAdelante
l_agregarAdelante:

	push rbp									; IDEA: primero creo el nodo con los parametros que me pasan 
	mov rbp, rsp								
	push rbx
	push r12
	push r13
	sub rsp, 8
	; preservo informacion para la creacion del NODO
	mov rbx, [rdi] 								; rbx <-- lista*
	mov r12, rsi   								; r12 <-- dato*
	mov r13, rdx 								; r13 <-- func_borrar* 

	mov rdi, offset_tamanio_struct_nodo
	call malloc
	; completo el nodo(RAX) 
	
	mov qword[rax + offset_funcion_borrar_nodo], r13
	mov qword[rax + offset_dato_nodo], r12	
	mov qword[rax + offset_anterior_nodo], NULL
		
	; falta la info de quien ahora pasaria a ser el segundo y que antes era el primero
	
	mov r12, [rbx + offset_primero_lista]			; r12 tiene el primero si la lista no es vacia o NULL si es vacia										
	mov qword[rax + offset_siguiente_nodo], r12		; el siguiente del nodo que agrego siempre va a ser el que apuntala la lista primero
	mov qword[rbx + offset_primero_lista], rax 		; actualizo el primero de la lista con el nodo que cree 
	
	cmp r12, NULL									; si es null es porque agregue el primero
	je .agregueElprimero
	; sino el ultimo no cambia 
	mov [r12+ offset_anterior_nodo], rax
	jmp .fin										; sino terminé

.agregueElprimero:
	mov qword[rbx + offset_ultimo_lista], rax		; si es el primero que agrego actualizo el ultimo de la lista tambien

.fin:
	inc dword[rbx + offset_longitud_lista]
	
	add rsp, 8
	pop r13
	pop r12
	pop rbx 
	pop rbp
	ret

;#############################################################################################
;################ agrega un nuevo nodo a la lista, como ultimo elemento ######################
;###### void l agregarAtras(lista** l, void* dato, void (*func borrar)(void*)); ##############
;######							RDI 			RSI 		RDX					   ###########
;#############################################################################################
; 											(PERFECTO)
global l_agregarAtras
l_agregarAtras:

	push rbp									; IDEA: primero creo el nodo con los parametros que me pasan 
	mov rbp, rsp								
	push rbx
	push r12
	push r13
	sub rsp, 8
	; preservo informacion para la creacion del NODO
	mov rbx, [rdi] 								; rbx <-- lista*
	mov r12, rsi   								; r12 <-- dato*
	mov r13, rdx 								; r13 <-- func_borrar* 

	mov rdi, offset_tamanio_struct_nodo
	call malloc
	; completo el nodo(RAX) 
	
	mov qword[rax + offset_funcion_borrar_nodo], r13
	mov qword[rax + offset_dato_nodo], r12	
	mov qword[rax + offset_siguiente_nodo], NULL
		
	; falta la info de quien ahora pasaria a ser el segundo y que antes era el primero
	
	mov r12, [rbx + offset_ultimo_lista]			; r12 tengo el ultimo (puede ser null)										
	mov qword[rax + offset_anterior_nodo], r12		; ahora pasa a ser el anterior del que agrego
	mov qword[rbx + offset_ultimo_lista], rax 		; y el que agrego pasa a ser el ultimo 
	
	cmp r12, NULL									; si el ultimo era null entonces estoy agregando el primer elemento
	je .agregueElprimero
	; sino el ultimo no cambia 
	mov [r12+ offset_siguiente_nodo], rax
	jmp .fin										; sino terminé

.agregueElprimero:
	mov qword[rbx + offset_primero_lista], rax		; si es el primero que agrego actualizo el primero de la lista con el 

.fin:

	inc dword[rbx + offset_longitud_lista]
	
	add rsp, 8
	pop r13
	pop r12
	pop rbx 
	pop rbp
	ret

;#########################################################################################################################
;########################## agrega un nuevo nodo a la lista ordenado sgn la funcion pasada ###############################
;## void l agregarOrdenado(lista** l, void* dato, void (*func borrar)(void*), int (*func cmp)(void*,void*));##############
;######							RDI 			RSI 		RDX					       RCX                  ##############
;#########################################################################################################################
; 											(PERFECTO)

global l_agregarOrdenado
l_agregarOrdenado:
	
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8
	
	mov r12, rdi 										; r12 <-- lista**
	mov r13, rsi 										; r13 <-- dato* 	
	mov r14, rdx 										; r14 <-- funcion_borrar* 
	mov r15, rcx 										; r15 <-- func_comparar* 

	;tenemos que agregar un nuevo nodo si o si vamos a crearlo, con la info necesaria

	mov rdi, offset_tamanio_struct_nodo
	call malloc											;rax <-- newNodo*

	mov [rax + offset_funcion_borrar_nodo] , r14
	mov [rax + offset_dato_nodo] , r13 					; funcion borrar y dato ya complete faltan siguiente y anterior
	
	mov r12,[r12]										; r12 <-- lista*

	mov r14, [r12 + offset_primero_lista]				; r14 (GUARDO) primero*
	
	mov rbx, rax 										; rbx <-- newNodo*
	cmp r14, NULL										; veo si la lista esta vacia 
	je .agregar_vacia_ordenado

	; HAY AL MENOS UN ELEMENTO 
.recorriendo_la_lista:

	mov rdi, [rbx + offset_dato_nodo]					; rdi <-- dato*  del newNodo 
	mov rsi, [r14 + offset_dato_nodo]					; rsi <-- dato* del primer nodo
	call r15											; llamo a la funcion comparar cmp(rdi,rsi)

	cmp eax, 0 											; caso en que sean iguales agregar. 
	je .agregar_nodo_ordenado

	cmp eax, 1
	je .agregar_nodo_ordenado							; caso en que ya tengo que agregar por ser menor

	; Si estoy aca es porque aun debo seguir recorriendo en la lista

	mov r14, [r14 + offset_siguiente_nodo]	;  avanzo al siguiente NODO

	cmp r14,NULL  							; si el null llegué al ultimo
	je .agregar_ultimo_ordenado

	; si no era el ultimo elemento entonces recorro la lista

	jmp .recorriendo_la_lista

.agregar_nodo_ordenado:

; veamos si es el primero de la lista. 

	mov rcx, [r14 + offset_anterior_nodo]
	cmp rcx, NULL 
	je .agregar_primero_ordenado

	
	mov qword[rbx + offset_siguiente_nodo],r14			; pongo bien el siguiente
	mov r13, [r14 + offset_anterior_nodo]					; me guardo el anterior
	
	mov [r14 + offset_anterior_nodo], rbx 	
	mov [r13 + offset_siguiente_nodo], rbx					; soy el siguiente del anterior 
	mov [rbx + offset_anterior_nodo], r13 				; el anterior ahora es mi anterior
	
	jmp	.incrementar_longitud 


;############### CASO 1: Es el primero de la lista
.agregar_primero_ordenado:

	mov qword[r12 + offset_primero_lista], rbx				; ahora es el primero 	
	mov qword[rbx + offset_anterior_nodo], NULL 			; el anterior ahora es NULL 
	mov qword[rbx + offset_siguiente_nodo], r14				; y el siguiente es  el que comparé
	mov [r14 + offset_anterior_nodo], rbx
	jmp .incrementar_longitud


;############### CASO 2: Es el ultimo de la lista  
.agregar_ultimo_ordenado:

	mov r14, [r12 + offset_ultimo_lista] 					;  r14 <-- obtengo el ultimo 	
	mov qword[r12 + offset_ultimo_lista], rbx				; ahora el nuevo es el ultimo
	mov qword[rbx + offset_siguiente_nodo], NULL 			; el siguiente es NULL
	mov qword[rbx + offset_anterior_nodo], r14 				; el anterior es r14 
	mov [r14 + offset_siguiente_nodo], rbx

	jmp .incrementar_longitud

;############### CASO 0: Es el unico de la lista  
.agregar_vacia_ordenado:

	mov qword[r12 + offset_primero_lista], rbx				; el primero y el ultimo son el nuevo nodo
	mov qword[r12 + offset_ultimo_lista], rbx

	mov qword[rbx + offset_siguiente_nodo], NULL 			; y ahora completar los datos del nodo siguiente y anterior
	mov qword[ rbx + offset_anterior_nodo], NULL	


.incrementar_longitud: 										; mantener el invariante de la lista (longitud) 

	xor rbx, rbx 
	mov ebx, [r12 + offset_longitud_lista]
	inc ebx
	mov dword[r12 + offset_longitud_lista], ebx

	add rsp, 8 
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp 
	ret

;#########################################################################################################################
;########## Borra la lista, todos sus nodos y datos. Para borrar estos ultimos, en el caso de existir, utiliza ###########
;########### la función definida en el nodo. De no tener una función borrar definida en el nodo no se borrará ############
;##########################################  void l borrarTodo(lista* l)  ################################################
;########################################                        RDI        ##############################################   
;#########################################################################################################################
; 											(PERFECTO)
global l_borrarTodo
l_borrarTodo:
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	push r13
	push r14
	
	mov r12, rdi 													;r12 <-- *lista (guardo)
	
	mov rbx, [r12 + offset_primero_lista]							; rbx primer nodo
	
	cmp rbx, NULL 											
	je .termine
	
	;sino borro el primer nodo
.borrando:
	mov r13, [rbx + offset_funcion_borrar_nodo]
	mov r14, [rbx + offset_siguiente_nodo]
	
	mov rdi, [rbx + offset_dato_nodo]
	call r13
	
	mov rdi, rbx
	call free
	
	cmp r14, NULL
	je .termine
	
	mov rbx,r14	
	jmp .borrando	

.termine:
	mov qword[r12 + offset_primero_lista],NULL
	mov qword[r12 + offset_ultimo_lista],NULL
	mov rdi, r12
	call free
	
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

;#########################################################################################################################
;																 CIUDAD 
;#########################################################################################################################

;#########################################################################################################################
;################################ ciudad* c crear(char* nombre, uint64 t poblacion); #####################################
;														rdi 			rsi 
;######################  Crea una ciudad y completa sus campos. Realiza una copia del nombre. ############################
;#########################################################################################################################
; 														(PERFECTO***********)
global c_crear
c_crear:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	
	mov rbx, rdi									; rbx  <-- *nombre
	mov r12, rsi									; r12  <-- poblacion.	
	
	mov rdi, offset_tamanio_struct_ciudad
	call malloc 									; rax  <-- *nuevaCiudad.
	
	mov [rax + offset_poblacion_ciudad], r12		;completo la poblacion
	mov r12, rax									;r12  (guardo) *nuevaCiudad.
	
	;ahora solo hay que copiar el nombre.
	
	mov rdi,rbx
	call str_copy 									; rax  <-- *copiaNombre
	mov [r12 + offset_nombre_ciudad], rax
	
	; devuelve el puntero de la nueva ciudad
	mov rax, r12	
	
	pop r12
	pop rbx
	pop rbp
	ret
	
;#########################################################################################################################
;##################################### int32 t c cmp(ciudad* c1, ciudad* c2); ############################################
;#####################################				   rdi 		   rsi 		  ############################################	
;##############################  Compara dos ciudades por su nombre (ver str cmp)  #######################################
;#########################################################################################################################
; 													(PERFECTO**************)
global c_cmp
c_cmp:
	push rbp
	mov rbp,rsp
	
	mov rdi, [rdi + offset_nombre_ciudad]
	mov rsi, [rsi + offset_nombre_ciudad]
	call str_cmp
	
	pop rbp
	ret
;#########################################################################################################################
;########################################void c borrar(ciudad* c)######################################################### 
; 															rdi	
;##################################  Borra una ciudad. Incluyendo el nombre ##############################################
;#########################################################################################################################
; 													(PERFECTO*************)
global c_borrar
c_borrar:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8	
	
	mov rbx,rdi
	mov rdi,[rdi + offset_nombre_ciudad]
	call free
	
	mov rdi, rbx 	
	call free 
	
	add rsp, 8
	pop rbx
	pop rbp
	ret

	ret


;######################################################################################################################################
;																 RUTA 
;######################################################################################################################################

;######################################################################################################################################
;##################################	   ruta* r crear(ciudad* c1, ciudad* c2, double distancia)   ######################################
;##################################						rdi        rsi          xmm0			 ######################################	
;# Crea una ruta y completa sus campos respetando orden lexicográfico entre ciudades, no puede exister una ruta entre la misma ciudad #
;######################################################################################################################################
;																(PERFECTO*************)
global r_crear
r_crear:

	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	
	; guardo la info
	mov rbx,rdi								; rbx tiene *c1
	mov r12,rsi								; r12 tiene *c2
	movq r13, xmm0							; r13 tiene distancia
	
	mov rdi,[rdi+ offset_nombre_ciudad]
	mov rsi,[rsi+ offset_nombre_ciudad]
	call str_cmp
	cmp eax, 0 
	mov r14d, eax
	je .imposible_crear_ruta
	
	; si no saltamos creamos la ruta
	
	mov rdi, offset_tamanio_struct_ruta
	call malloc
	; rax tengo la nueva ruta
	
	mov [rax + offset_distancia_ruta], r13
	
	; si estamos aca es posible crear la ruta
	cmp r14d, 1
	
	je .agregar_c1_primero
		
	; si estoy aca tengo que agregar c2 primero
	mov [rax+ offset_ciudadA_ruta], r12
	mov [rax+ offset_ciudadB_ruta], rbx
	jmp .fin_crear_ruta
	
	
.agregar_c1_primero:
	mov [rax+ offset_ciudadA_ruta], rbx
	mov [rax+ offset_ciudadB_ruta], r12	
	jmp .fin_crear_ruta

.imposible_crear_ruta:
	mov rax, NULL

.fin_crear_ruta:	
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret



;#########################################################################################################################
;####################################   int32 t r cmp(ruta* r1, ruta* r2);   #############################################
;#######################################    			rdi       rsi    	##############################################
;#############  Compara dos rutas por el nombre de las ciudades. Primero compara por la primer ciudad y en ###############
;############################### caso de ser iguales compara por la segunda ciudad. ######################################
;#########################################################################################################################
; 													(PERFECTO)

global r_cmp
r_cmp:

	push rbp
	mov rbp, rsp
	push rbx
	push r12
	
	mov rbx,rdi						; rbx <-- rdi
	mov r12,rsi						; r12 <-- rsi
	
	; comparo la primer componente
	mov rdi, [rbx + offset_ciudadA_ruta]
	mov rdi, [rdi + offset_nombre_ciudad]
	mov rsi, [r12 + offset_ciudadA_ruta]
	mov rsi, [rsi + offset_nombre_ciudad]
	
	call str_cmp					; eax <-- 0 si son igual 1 o -1 sino  
	
	cmp eax, 0
	je .comparar_segunda_ciudad 
	jmp .fin_cmp

.comparar_segunda_ciudad:
	mov rdi, [rbx + offset_ciudadB_ruta]
	mov rdi, [rdi + offset_nombre_ciudad]
	mov rsi, [r12 + offset_ciudadB_ruta]
	mov rsi, [rsi + offset_nombre_ciudad]
		
	call str_cmp
		
.fin_cmp:
	pop r12
	pop rbx
	pop rbp
	ret

;#########################################################################################################################
;############################################  	void r borrar(ruta* r);	  ################################################
;#############################################					rdi 	 #################################################
;############################### 	Borra una ruta. No borra las ciudades asociadas. 	##################################
;#########################################################################################################################
; 													(PERFECTO*******)

global r_borrar
r_borrar:
	push rbp
	mov rbp, rsp
	
	call free

	pop rbp
	ret

; RED CAMINERA
;#########################################################################################################################
;#######################################	redCaminera* rc crear(char* nombre);	######################################
;##########################################								rdi 	##########################################
;#################################	Crea una red caminera vacia. Copia el nombre de la red.	##############################
;#########################################################################################################################
; 														(PERFECTO *********)
global rc_crear
rc_crear:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	
	mov rbx, rdi
	
	mov rdi, offset_tamanio_struct_redCaminera
	call malloc 								; rax <-- nueva redCaminera
	
	mov r12, rax
	
	call l_crear
	mov [r12 + offset_ciudades_redCaminera], rax
	
	call l_crear
	mov [r12 + offset_rutas_redCaminera], rax
	
	
	
	mov rdi, rbx
	call str_copy								; rax <-- copia nombre
	
	mov [r12 + offset_nombre_redCaminera], rax	

	mov rax, r12
	
	pop r12
	pop rbx
	pop rbp	
	ret

;#########################################################################################################################
;################## void rc agregarCiudad(redCaminera* rc, char* nombre, uint64 t poblacion);  ###########################
;####################						 rdi				rsi 			rdx				##########################
;############## 	Agrega una nueva ciudad a la red de forma ordenada. En el caso de existir, no agrega nada. ###########
;#########################################################################################################################
; 														(PERFECTO**************)			


global rc_agregarCiudad
rc_agregarCiudad:
	push rbp
	mov rbp, rsp
	push rbx
	push r12 
	push r13
	push r14									

	mov rbx, rdi										; rbx tengo redCaminera*							
	mov r14, rdx 										; r14 tengo la poblacion
    mov r12, [rbx + offset_ciudades_redCaminera]		; 
	mov r12, [r12 + offset_primero_lista]				; r12 *primero	
	mov r13, rsi										; r13 tengo *nombre

.buscamos_si_el_nombre_esta:

	cmp r12, NULL
	je .agregar_ciudad 

	mov rdi, r13						
	mov rsi, [r12 + offset_dato_nodo]				
	mov rsi, [rsi + offset_nombre_ciudad]			 
	call str_cmp							
	cmp eax, 0									
	je .fin										
	mov r12, [r12 + offset_siguiente_nodo]		
	jmp .buscamos_si_el_nombre_esta

.agregar_ciudad:
	mov rdi, r13 								
	mov rsi, r14
	call c_crear

	mov rsi, rax 								
	lea rdi, [rbx+offset_ciudades_redCaminera]	
	mov rdx, c_borrar 							
	mov rcx, c_cmp 								

	call l_agregarOrdenado						

.fin:
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

;##################################################################################################################
;############ 	void rc agregarRuta(redCaminera* rc, char* ciudad1, char* ciudad2, double distancia);	###########
;#################						rdi 			rsi 			rdx				xmm0		###############	
;#########	Agrega una ruta nueva a la red de forma ordenada. En el caso de existir, no agrega nada.	###########
;##################################################################################################################
;													(PERFECTO ************)
 
global rc_agregarRuta
rc_agregarRuta:
	push rbp
	mov rbp, rsp
	push rbx
	push r12 
	push r13
	push r14									
	push r15			
	sub rsp, 8									

	; GUARDO INFO 
	mov rbx, rdi												; rbx <-- *rc										
	mov r12, rsi 												; r12 <-- *nombreCiudad1
	mov r13, rdx												; r13 <-- *nombreCiudad2
	movq r14, xmm0												; r14 <-- distancia

	; si los nombres son iguales no agrego nada
	mov rdi, r12
	mov rsi, r13
	call str_cmp
	cmp rax, 0
	je .fin

	mov r15, [rbx+offset_ciudades_redCaminera]
	mov r15, [r15+offset_primero_lista]							; r15 <-- primerCiudad  

.buscamos_si_nombreCiudad1_esta_en_ciudades:
	cmp r15, NULL
	je .fin
	mov rdi, [r15 + offset_dato_nodo]
	mov rdi, [rdi + offset_nombre_ciudad]						; paso el nombre de la ciudad de la lista
	mov rsi, r12												; paso nombreCiudad1
	call str_cmp						
	cmp eax, 0													; si son iguales busco la ciudad 2
	je .buscamos_si_nombreCiudad2_esta_en_ciudades
	mov r15, [r15 + offset_siguiente_nodo]
	jmp .buscamos_si_nombreCiudad1_esta_en_ciudades

.buscamos_si_nombreCiudad2_esta_en_ciudades:					; lo mismo que antes pero con el nombreCiudad2
	mov r12, [r15 + offset_dato_nodo]							; r12 me guardo el * ciudad que coincide el primer nombre
	mov r15, [rbx+offset_ciudades_redCaminera]
	mov r15, [r15+offset_primero_lista]

.busqueda_Ciudad2:
	mov rdi, [r15+offset_dato_nodo]
	mov rdi, [rdi+offset_nombre_ciudad]
	mov rsi, r13
	call str_cmp
	cmp eax, 0
	je .creamos_ruta
	mov r15, [r15+offset_siguiente_nodo]
	cmp r15, NULL
	je .fin
	jmp .busqueda_Ciudad2

.creamos_ruta:
	mov r13, [r15+offset_dato_nodo]				; creamos la ruta 
	mov rdi, r12 				 						
	mov rsi, r13
	movq xmm0, r14
	call r_crear 									; rax <-- rutaNueva		

	mov r13, rax 									; (guardo) r13 la rutaNueva 		
    mov r12, [rbx+offset_rutas_redCaminera]				
	mov r12, [r12+offset_primero_lista]			
	cmp r12, NULL								 							
	je .agregar 									; si la lista esta vacia agregamos ruta

.vemos_si_la_ruta_yasta:
	mov rdi, r13								 
	mov rsi, [r12+offset_dato_nodo]				
	call r_cmp										; cmp las rutas
	cmp eax, 0									
	je .la_ruta_yasta_eliminar_nuevaRuta			; si esta tengo que eliminarla					

	mov r12, [r12+offset_siguiente_nodo]			; sino continuo hasta recorrer todas las rutas				
	cmp r12, NULL 												
	je .agregar									
	jmp .vemos_si_la_ruta_yasta								

.la_ruta_yasta_eliminar_nuevaRuta:
	mov rdi, r13
	call free
	jmp .fin

.agregar:											; paso los parametros para l_agregarOrdenado (*listaRutas, *ruta , r_borrar, r_cmp)
	lea rdi, [rbx+offset_rutas_redCaminera]
	mov rsi, r13 			
	mov rdx, r_borrar 							
	mov rcx, r_cmp 								
	call l_agregarOrdenado 					
		
.fin:
	add rsp, 8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
	
; ####################################################################################################			
;#################################	void rc borrarTodo(redCaminera* rc);	##########################
;#########################################					rdi 		##############################
;#######################	Borra toda la red caminera. Tanto ciudades como rutas.	##################
;#####################################################################################################
; 											(PERFECTO)
global rc_borrarTodo

rc_borrarTodo:
	push rbp
	mov rbp, rsp
	push rbx
	sub rsp, 8
		
	mov rbx, rdi												; (GUARDO) rbx <-- *redCaminera 
	
	mov rdi, [rbx + offset_nombre_redCaminera]
	call free													; ELIMINO NOMBRE

	mov rdi, [rbx + offset_rutas_redCaminera]
	call l_borrarTodo											; ELIMINO RUTAS

	mov rdi, [rbx + offset_ciudades_redCaminera]
	call l_borrarTodo											; ELIMINO CIUDADES

	mov rdi, rbx
	call free													; ELIMINO REDCAMINERA
	
	add rsp, 8
	pop rbx
	pop rbp
	ret

; OTRAS DE RED CAMINERA

;###############################################################################################################
;#######################	ciudad* obtenerCiudad(redCaminera* rc, char* c);	################################
;#############################							rdi 		rsi 		################################
;########	Dada una red caminera y un nombre, busca el nombre de ciudad pasado por parámetro y retorna	  ######	
;########### 	un puntero a la ciudad correspondiente. De no existir la ciudad, retorna null. 		############
;###############################################################################################################
; 											(PERFECTO)

global obtenerCiudad
obtenerCiudad:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	sub rsp, 8
	
		
	mov rbx, [rdi + offset_ciudades_redCaminera]					; rbx <-- *list_de_ciudades
	
	; vemos si la lista esta vacia
	mov rbx, [rbx + offset_primero_lista]							; rbx <-- primerNodo
	cmp rbx, NULL
	je .la_ciudad_NO_esta
	
	; si estoy aca la lista no es vacia.. tengo que ponerme a buscar
	
.buscar_ciudad_de_mismo_nombre:	
	mov r13, rbx													; r13 (GUARDO) el nodo actual
	
	mov rbx, [rbx + offset_dato_nodo]								; rbx *dato (que es una ciudad)

	mov r12, rbx													; r12 (GUARDO) el *ciudad del nodo actual
	
	mov rbx, [rbx + offset_nombre_ciudad]							; rbx *nombre de la ciudad
	mov rdi, rbx
	;rsi tiene lo que quiero
	call str_cmp
	
	cmp eax, 0
	je .devolver_ciudad
	;si no tengo que seguir buscando
	mov rbx, [r13 + offset_siguiente_nodo]
	cmp rbx,NULL
	je .la_ciudad_NO_esta
			
	jmp .buscar_ciudad_de_mismo_nombre

.devolver_ciudad:
	
	mov rax, r12
	jmp .fin_de_obtener_ciudad
	
.la_ciudad_NO_esta:
	mov rax, NULL
	
.fin_de_obtener_ciudad:
	
	add rsp,8
	pop r13
	pop r12
	pop rbx 
	pop rbp
	ret

;#######################################################################################################
;################### 	ruta* obtenerRuta(redCaminera* rc, char* c1, char* c2);		####################
;#########################					rdi 			rsi 		rdx		########################
;#####	Dada una red caminera y un par de nombres de ciudades, obtiene el puntero a la ruta que   ######
;##################		conecta ambas ciudades. De no existir la ruta, retorna null.	################
;#######################################################################################################
; 												(PERFECTO)
global obtenerRuta
obtenerRuta:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp,8
	
	; me guardo INFO
	mov rbx, rdi								;rbx <-- *redCaminera
	mov r12, rsi								;r12 <-- *nombre1
	mov r13, rdx								;r13 <-- *nombre2 	

	; caso en qeu me pases mismos nombres
	
	mov rdi, r12
	mov rsi, r13
	call str_cmp
	cmp eax, 0
	je .ciudadNoexiste
	
	;si toy aca me pasaron nombres distintos (puede haber ruta)
	
	mov rdi, rbx
	mov rsi, r12
	call obtenerCiudad							; miro si el primer nombre esta en ciudades
	cmp rax, NULL 
	je .ciudadNoexiste
	
	;si estamos aca es porq el nombre1 es una ciudad de la red
	
	mov rdi, rbx
	mov rsi, r13
	call obtenerCiudad
	cmp rax, NULL 
	je .ciudadNoexiste
	
	; ahora es MAS posible que la ruta exista
	; vamos a crear una ruta (provisoria)
	
	mov rbx, [rbx + offset_rutas_redCaminera]
	mov rbx,[rbx + offset_primero_lista]
.busqueda_ruta:	
	cmp rbx, NULL 								;comparo el primero de la lista con null
	je .ciudadNoexiste
	
	; si no es null comparo los valores datos-ciudadX con los que me pasaron
	
	mov r15, [rbx + offset_dato_nodo]
	mov r8, [r15 + offset_ciudadA_ruta]
	mov r8, [r8 + offset_nombre_ciudad]
	
	mov rdi, r12
	mov rsi, r8
	call str_cmp
	cmp eax,0
	je .chequeo_ciudadB
.avanzar:	
	mov rbx, [rbx + offset_siguiente_nodo]
	jmp .busqueda_ruta
	
.chequeo_ciudadB:
	mov r8,[r15 + offset_ciudadB_ruta]
	mov r8, [r8 + offset_nombre_ciudad]
	mov rdi, r13
	mov rsi, r8
	call str_cmp
	cmp eax,0
	je .encontre_ruta
	jmp .avanzar

.encontre_ruta:
	mov rax, r15
	jmp .termino_la_busqueda

.ciudadNoexiste:
	mov rax, NULL

.termino_la_busqueda:	
	
	add rsp,8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
	
;#######################################################################################################
;############################	ciudad* ciudadMasPoblada(redCaminera* rc);	############################
;#####################################						RDI				############################
;###### 	Retorna el puntero a la ciudad mas poblada de la red caminera pasada por parámetro.  #######
;#######################################################################################################
;												(PERFECTO)

global ciudadMasPoblada

ciudadMasPoblada:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp,8
	

;	sub rax,rbx  rax - rbx igual que el cmp 
	
	mov rbx,[rdi + offset_ciudades_redCaminera] 		; rbx <-- *lista_de_ciudades
	mov rbx,[rbx +  offset_primero_lista]				; rbx <-- *nodo(ciudad)
	cmp rbx,NULL
	je .no_hay_ciudades
	
	mov rax,[rbx + offset_dato_nodo]				; la primer es la mas  poblada si no se recorre mas
	mov r12,[rax + offset_poblacion_ciudad]			; r12 tiene la poblacion maxima hasta ahora

.continuar:		
	mov rbx,[rbx +  offset_siguiente_nodo]			; miro el siguiente si es null termino
	cmp rbx, NULL
	je .devolverMaximo
	mov r13,[rbx + offset_dato_nodo]
	mov r14,[r13 + offset_poblacion_ciudad]
	cmp r14,r12
	jg .actualizarMaximo
	jmp .continuar
	
.actualizarMaximo:	
	mov rax, r13
	mov r12, r14
	jmp .continuar

.devolverMaximo:	
	jmp .terminarMaximo
	
.no_hay_ciudades:	
	mov rax, NULL

.terminarMaximo:
	add rsp,8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
	
;#####################################################################################################
;#########################	ruta* rutaMasLarga(redCaminera* rc); #####################################
;##############################  					rdi				##################################
;##	Retorna el puntero a la ruta mas larga de la red caminera pasada por parámetro. De existir mas ###
;########################## 	de una, se toma la de nombre mas chico.		##########################
;#####################################################################################################
; 											(PERFECTO)
global rutaMasLarga

rutaMasLarga:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp,8
	

;	sub rax,rbx  rax - rbx igual que el cmp 
	
	mov rbx,[rdi + offset_rutas_redCaminera] 		; rbx <-- *lista_de_rutas
	mov rbx,[rbx +  offset_primero_lista]			; rbx <-- *nodo(ciudad)
	cmp rbx,NULL
	je .no_hay_rutas								; si es ta vacias termino
	
	mov rax,[rbx + offset_dato_nodo]				; la primer es la mas  poblada si no se recorre mas
	mov r12,[rax + offset_distancia_ruta]			; r12 tiene la poblacion maxima hasta ahora

.continuar:		
	mov rbx,[rbx +  offset_siguiente_nodo]			; miro el siguiente si es null termino
	cmp rbx, NULL
	je .devolverMaximo
	mov r13,[rbx + offset_dato_nodo]
	mov r14,[r13 + offset_distancia_ruta]
	cmp r14,r12
	jg .actualizarMaximo
	jmp .continuar
	
.actualizarMaximo:	
	mov rax, r13
	mov r12, r14
	jmp .continuar

.devolverMaximo:	
	jmp .terminarMaximo
	
.no_hay_rutas:	
	mov rax, NULL

.terminarMaximo:
	add rsp,8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret




;#####################################################################################################
;#############		void ciudadesMasLejanas(redCaminera* rc, ciudad** c1, ciudad** c2);	##############
;########################### 					rdi 			rsi 		rdx		##################
;#### Modifica los valores de los dobles punteros a ciudad, de forma de cargar en los mismos las #####
;##ciudades a mas distancia entre si. De existir mas de una, se toma la primer nombre mas chico. #####
;#####################################################################################################
; 										(CREO QUE PERFECTO)	
global ciudadesMasLejanas
ciudadesMasLejanas:
	push rbp
	mov rbp, rsp
	push rbx 
	push r12
	push r13
	sub rsp,8
	
	mov rbx, rdi
	mov r12, rsi
	mov r13, rdx
	
	mov rdi, rbx 
	call rutaMasLarga			; en rax obtengo la ruta mas larga 
	
	mov r8, [rax + offset_ciudadA_ruta]
	mov r9, [rax + offset_ciudadB_ruta]
	
	mov [r12],r8
	mov [r13],r9

	add rsp, 8
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

;#####################################################################################################
;#########################	double totalDeDistancia(redCaminera *rc);	##############################
;#######################################					rdi 		##############################
;################	Obtiene la cantidad total de distancias de todas las rutas de la red. ############
;#####################################################################################################
; 									(PERFECTO)
global totalDeDistancia
totalDeDistancia:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
		
	mov rbx, [rdi + offset_rutas_redCaminera]					; rbx  <-- *lista de rutas
	mov rbx, [rbx + offset_primero_lista]						; rbx  <-- *primer Nodo
	
	xor rax, rax
	movq xmm0,rax
	cmp rbx, NULL
	je .devolver_total_de_distancia
	
	; si la lista no es vacia la empiezo a recorrer y acumular el rax el valor
.calculando_total:	
	; me guardo el nodo actual
	mov r12, rbx 												; r12 (guardo nodo actual)
	mov rbx, [rbx + offset_dato_nodo]							; rbx <-- *ruta
	mov rbx, [rbx + offset_distancia_ruta]
 	movq xmm1, rbx 
	addsd xmm0, xmm1
	
	; ahora avanzo
	mov rbx , [r12 + offset_siguiente_nodo]
	cmp rbx, NULL
	je .devolver_total_de_distancia
	;si no salté tengo que seguir recorriendo
	jmp .calculando_total
	
.devolver_total_de_distancia:
	
	pop r12
	pop rbx
	pop rbp
	ret

;#####################################################################################################
;######################		uint64 t totalDePoblacion(redCaminera *rc);  #############################
;#################################						rdi 		##################################
;#########   Obtiene la cantidad de poblacion de todas las ciudades de la red. 	######################
;#####################################################################################################
; 									(PERFECTO)
global totalDePoblacion
totalDePoblacion:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
		
	mov rbx, [rdi + offset_ciudades_redCaminera]				; rbx  <-- *lista de ciudades
	mov rbx, [rbx + offset_primero_lista]						; rbx  <-- *primer Nodo
	
	xor rax, rax
	cmp rbx, NULL
	je .devolver_total_de_poblacion
	
	; si la lista no es vacia la empiezo a recorrer y acumular el rax el valor
.calculando_poblacion_total:	
	; me guardo el nodo actual
	mov r12, rbx 												; r12 (guardo nodo actual)
	mov rbx, [rbx + offset_dato_nodo]							; rbx <-- *ruta
	mov rbx, [rbx + offset_poblacion_ciudad]
 	add rax, rbx 
	
	; ahora avanzo
	mov rbx , [r12 + offset_siguiente_nodo]
	cmp rbx, NULL
	je .devolver_total_de_poblacion
	;si no salté tengo que seguir recorriendo
	jmp .calculando_poblacion_total
	
	
.devolver_total_de_poblacion:
	
	pop r12
	pop rbx
	pop rbp
	ret


;#####################################################################################################
;################3	uint32 t cantidadDeCaminos(redCaminera *rc, char* ci);  ##########################
;####################################				rdi 		rsi 	##############################
;###### Dado el nombre de una ciudad, obtiene la cantidad de rutas que conectan a dicha ciudad. ######
;#####################################################################################################
;												(PERFECTO)

global cantidadDeCaminos

cantidadDeCaminos:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8
	
	mov rbx, rdi								; rbx (guardo) * redCaminera	
	mov r12, rsi 								; rsi (guardo) *nombre de la ciudad
	
	mov rbx, [rbx + offset_rutas_redCaminera]	; rbx <-- * lista de rutas
	mov rbx, [rbx + offset_primero_lista]		; rbx <-- * primer nodo
	
	;limpiamos mi contador								
	xor r15, r15
	
	; veo si mi lista es vacia
	cmp rbx, NULL
	je .ya_recorrimos_todo_devolver_valor_calculado
	
	;si estamos aca la lista tiene al menos una ruta veamos si uno de sus extremos es la ciudad

.recorrer_rutas:	
	mov r13, rbx 								; r13 (guardo) el nodo actual	
	mov rbx, [rbx + offset_dato_nodo]			;rbx <-- * ruta del nodo actual
	
	mov r14, [rbx + offset_ciudadA_ruta]		; r15 <-- *ciudadA
;	mov r14, [rbx + offset_ciudadB_ruta]		; r14 <-- *ciudadB
	
	
	; vemos si la ciudadA es igual al nombre pasado
	mov rdi, r12
	mov rsi, [r14 + offset_nombre_ciudad]
	call str_cmp
	cmp eax, 0
	je .incrementar_contador
	
	; si estoy aca es porq ciudadA no es, hay que ver si es ciudadB
	mov r14, [rbx + offset_ciudadB_ruta]
	mov rdi,r12
	mov rsi,[r14 + offset_nombre_ciudad]
	call str_cmp
	cmp eax,0
	je .incrementar_contador
	
	; si estoy aca tengo que avanzar en la lista_rutas 
	mov rbx, [r13 + offset_siguiente_nodo]
	cmp rbx, NULL
	je .ya_recorrimos_todo_devolver_valor_calculado
	jmp .recorrer_rutas	
	
.incrementar_contador:
	inc r15d
	mov rbx, [r13 + offset_siguiente_nodo]
	cmp rbx, NULL
	je .ya_recorrimos_todo_devolver_valor_calculado
	jmp .recorrer_rutas

.ya_recorrimos_todo_devolver_valor_calculado:		
	mov eax, r15d
	
	add rsp,8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx 
	pop rbp
	ret

;#####################################################################################################
;###################### 	ciudad* ciudadMasComunicada(redCaminera *rc);  ###########################
;####################################						rdi 			##########################
;### Obtiene el puntero a la ciudad que mas caminos la conectan. De existir mas de una, se toma la ###
;############################   	de nombre mas chico.		######################################	
;#####################################################################################################
;

global ciudadMasComunicada
ciudadMasComunicada:
	push rbp
	mov rbp, rsp
	push rbx 
	push r12
	push r13
	push r14
	push r15
	sub rsp,8
	
	mov r12, rdi												; r12 (guardo) el *redCiudad 
	mov rbx, [rdi + offset_ciudades_redCaminera]				; rbx <-- *lista de ciudades
	mov rbx, [rbx + offset_primero_lista]						; rbx <-- *primero (nodo)
	cmp rbx, NULL
	je .no_hay_ciudades
	; si estoy aca tengo por lo menos una ciudad	
	xor r13, r13												; r13 (guardo) mi contador (lo seteo en 0)
		
.busqueda_de_la_mas_poblada:	
	mov r14, rbx												; r14 (guardo) nodo actual
	mov rbx, [rbx + offset_dato_nodo]							; rbx <-- *ciudad		

	; calculo la cantidad de caminos de la CIUDAD
	mov rdi, r12												; rdi <-- * redCaminera
	mov rsi, [rbx + offset_nombre_ciudad]						; rsi <-- *nombre de la ciudad
	call cantidadDeCaminos										; eax <-- tengo la cant de caminos de la ciudad actual
	cmp eax, r13d
	; si son iguales no actualizo y avanzo
	je .pasar_a_la_siguiente_ciudad
	
	jg .actualizar_ciudad_mas_comunicada																

	; si no salte la ciudad es menos comunicada de la que ya tenia antes	
	; continuo buscando
.pasar_a_la_siguiente_ciudad:

	mov rbx, [r14+ offset_siguiente_nodo]
	cmp rbx, NULL
	je .ya_recorri_todas_las_ciudades
	; sino salte tengo mas que recorrer
	jmp .busqueda_de_la_mas_poblada
	
.actualizar_ciudad_mas_comunicada:

	mov r15,rbx 
	mov r13d, eax
	jmp .pasar_a_la_siguiente_ciudad

	
.no_hay_ciudades:
	mov rax, NULL
	jmp .fin_ciudad_mas_poblada


.ya_recorri_todas_las_ciudades:
	mov rax, r15
	
.fin_ciudad_mas_poblada:	
	
	add rsp,8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret

; AUXILIARES

;####################################################################################
;######################			char* str copy(char* a); 		#####################
;#########################						rdi 			#####################
;##############		 Copia una string de C terminada en 0.		#####################
;####################################################################################

global str_copy
str_copy:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	
	mov rbx, rdi 						; rbx (guardo) el *char

	mov rdi, offset_tamanio_puntero
	call malloc 						; rax puntero que apunta a la copia
	mov r14, rax
	
	xor r13, r13							; limpio r8 es mi indicador de indice
	mov r12b, [rbx + r13] 				; r12b tengo caracter[actual] 

.continua_copia:
	cmp r12b, 0 						; si es cero termino
	je .termine_copia 						
	mov byte[r14 + r13], r12b 			; sino copio el byte y avanzo
	inc r13 								 
	mov r12b, [rbx + r13] 					
	jmp .continua_copia 							

.termine_copia:
	pop r14
	pop r13
	pop r12
	pop rbx
	pop rbp
	ret
	
	
;#####################################################################################
;####################	int32 t str cmp(char* a, char* b);   	######################
;# Compara dos strings de C terminadas en 0, en orden lexicográfico. Debe retornar: ##
;##								• 0 si son iguales									##
;##								• 1 si a < b										##
;##								• −1 si b < a										##
;#####################################################################################

global str_cmp
str_cmp:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	push r15
	sub rsp, 8

	xor r14, r14 							; contador de la longitud del primer string  
	xor r15, r15							; contador de la longitud del second string

	
	mov r12, [rdi]
	mov r13, [rsi]

.calculo_long_primer_string: 				
	cmp r12b, 0 							
	je .calculo_long_second_string 		; si es cero termine de calcular longitud de string --> calculo la long del segundo
	inc r14									; sino incremento contador
	mov r12b, [rdi + r14]					; y avanzo lo que el contador/indice dice
	jmp .calculo_long_primer_string


.calculo_long_second_string:				; IDEA IGUAL A LA DE CALCULAR LA LONG DE LONG PRIMERO
	cmp r13b, 0
	je .fin_largo							; una vez calculada empiezo a comparar los string 	
	inc r15 								
	mov r13b, [rsi + r15]
	jmp .calculo_long_second_string
	
	
	; 	en este punto tengo:
	;	r14 <-- long del primer string 
	;	r15 <-- long del second string
	
.fin_largo:
	cmp r14, r15
	jl .el_primero_es_masChico
													
	mov rcx, r15
	jmp .rcx_tiene_el_min

.el_primero_es_masChico:
	mov rcx, r14

.rcx_tiene_el_min:	

	xor r11, r11 							; r11 va a ser mi indice para recorrer
	
	mov r12, [rdi + r11]
	mov r13, [rsi + r11]
	
.ciclo_cmp:
	cmp r12b, r13b 							;	# comparo caracteres string1[r11]  con string2[r11] #
	jl .devuelvo_uno						
	jg .devuelvo_menos_uno					
												
	; si no salte es porq devo decir comparando hasta quedarme sin chars a comparar 																;	# rax != 0 entonces salto #
	inc r11 								;	# incremento el indice #
	mov r12b, [rdi + r11] 					;	# r12 = siguiente caracter de string1 #
	mov r13b, [rsi + r11]					;	# r13 = siguiente caracter de string2 #
	loop .ciclo_cmp 
	; aca ya termine de recorrer las listas
	cmp r14,r15
	je .devuelvo_cero
	jg .devuelvo_menos_uno

.devuelvo_uno:
	xor rax,rax
	mov eax, 1
	jmp .fin
	
.devuelvo_menos_uno:
	xor rax,rax
	mov eax, -1
	jmp .fin
	
.devuelvo_cero:
	xor rax,rax
.fin:
	add rsp, 8
	pop	r15
	pop r14
	pop r13
	pop r12
	pop rbx	
	pop rbp
	ret
