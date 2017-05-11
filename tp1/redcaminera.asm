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

	;tenemos que agregar un nuevo nodo si o si vamos a crearlo con la info necesaria

	mov rdi, offset_tamanio_struct_nodo
	call malloc											;rax <-- newNodo*

	mov [rax + offset_funcion_borrar_nodo] , r14
	mov [rax + offset_dato_nodo] , r13 
	
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

	; si estoy aca es porq tengo q agregar en el medio

	; la estructura de la lista no cambia (solo la longitud)

	; solo tengo que actualizar el siguiente y anterior del nodo que voy a insertar

	; siempre agrego por delante asi que en r14 voy a tener el nodo siguiente 

	
	mov qword[rbx + offset_siguiente_nodo] , r14			; pongo bien el siguiente
	mov [r14 + offset_anterior_nodo], rbx 
	
	mov r14, [r14 + offset_anterior_nodo]					; obtengo el anterior
	
	mov [r14 + offset_siguiente_nodo], rbx					; soy el siguiente del anterior 
	mov [rbx + offset_anterior_nodo], r14 				; el anterior ahora es mi anterior
	
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

global l_borrarTodo
l_borrarTodo:
	push rbp
	mov rbp,rsp
	push rbx
	push r12
	push r13
	push r14

	
	; CASO 0: lista vacia 

	mov rbx, [rdi + offset_primero_lista]							;rbx <-- *primer_nodo
	cmp rbx, NULL
	je .borrarListaVacia	
	;SI TOY ACA LA LISTA NO ES VACIA.
	mov r12, rdi 													;r12 <-- *lista (guardo)
	; CASO 1: unico elemento

	mov rcx, [rdi + offset_ultimo_lista]							;rcx <-- *ultimo_nodo
	cmp rbx,rcx
	je .borrarLista_unico_elemento


	; ESTAMOS EN EL CASO EN EL QUE LA LISTA TIENE MAS DE UN ELEMENTO
	; OPCION: BORRAR EL PRIMER ELEMENTO Y LLAMAR RECURSIVAMENTE 

	; borramos el dato del nodo 
		
	mov r14, [rbx + offset_funcion_borrar_nodo]
	
	mov rdi, [rbx+ offset_dato_nodo]
	call r14

	; ahora tenemos que borrar el nodo pero antes tenemos que mantener el invariante de la lista

	mov r13, [rbx + offset_siguiente_nodo]							; r13 <-- nodo_siguiente* (del que voy a borrar)
	mov [r12 +  offset_primero_lista], r13						; ahora la el primero de la lista apunta bien 
	mov qword[r13+ offset_anterior_nodo], NULL    					; ahora el anterior del nuevo primero es NULL

	; borramos el nodo
	mov rdi, rbx
	call free

	mov rdi, r12 
	call l_borrarTodo

	jmp .fin_borrar_todo

.borrarLista_unico_elemento:
	 
	mov qword[r12 + offset_primero_lista], NULL
	mov qword[r12 + offset_ultimo_lista], NULL

	; borro dato
	mov r14, [rbx + offset_funcion_borrar_nodo]
	
	mov rdi, [rbx + offset_dato_nodo]
	call r14

	; borro nodo
	mov rdi, rbx 
	call free 

	; llamada recursiva
	mov rdi, r12 
	call l_borrarTodo

.borrarListaVacia:
	
	call free

.fin_borrar_todo:

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
; 														(PERFECTO)
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
; 													(PERFECTO)
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
; 													(PERFECTO)
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
global r_cmp
r_cmp:

	push rbp
	mov rbp, rsp
	push rbx
	push r12
	
	mov rbx,rdi						; rbx <-- r1
	mov r12,rsi						; r12 <-- r2
	
	mov rdi, [rdi + offset_ciudadA_ruta]
	mov rsi, [rsi + offset_ciudadA_ruta]
	
	call str_cmp					; eax <-- 0 si son igual 1 o -1 sino  
	
	
	cmp eax, 0
	je .comparar_segunda_ciudad 
	jmp .fin_cmp

.comparar_segunda_ciudad:
	mov rdi,[rbx + offset_ciudadB_ruta]
	mov rsi,[r12 + offset_ciudadB_ruta]
	
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

global rc_agregarCiudad
rc_agregarCiudad:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
	
	mov rbx, rdi									; rbx <-- *redCaminera
	mov r13,rsi										; r13 <-- *nombre
	mov r14,rdx										; r14 <-- poblacion
	
	; tenemos que ver que ese nombre no este en la lista de ciudades
	
	mov rbx, [rbx + offset_ciudades_redCaminera]		; rbx <-- *listaCiudades
	mov r12, rbx										; r12 <-- *listaCiudades
	mov rbx, [rbx + offset_primero_lista]				; rbx <-- *primero_de_la_lista
	
	cmp rbx, NULL										; veo el primer elemento 
		
	je .dejamos_de_buscar_y_agregamos
	
	; si estamos aca es porq la lista tiene al menos un elemento
	; comparamos nombre con todos los elementos de la lista ciudad
	
	;  rbx --- tengo el primer elemento de la lista
	
.continua_la_busqueda:	
	
	mov r14, rbx										; r14 <-- me guardo el puntero al nodo donde estoy parado
	
	mov rbx, [rbx + offset_dato_nodo]					; rbx <-- *dato 	(del nodo donde toy parado)
	mov rdi, [rbx + offset_nombre_ciudad]				; rdi <-- *nombre	(del nodo donde toy parado)
	;mov rdi, rbx
	mov rsi, r13										; rsi <-- *nombre 	(de la ciudad que quiero agregar)
	
	call str_cmp										; comparo rdi y rsi 
	
	cmp eax, 0
	
	je .no_agrego_ciudad								; si la ciudad ya existe termino todo 
	
	;veo ahora si el siguiente no es null
	
	mov rbx, [r14 + offset_siguiente_nodo]
	cmp rbx, NULL
	je .dejamos_de_buscar_y_agregamos
	
	jmp .continua_la_busqueda
	 
.dejamos_de_buscar_y_agregamos:

	mov rdi, r13									; rdi (tiene que ir nombre)
	mov rsi, r14									; rsi (tiene que ir poblacion)
	call c_crear									; rax <-- *newCiudad
	

	lea rdi, [r12]									;  rdi <-- **lista de ciudades
	
	mov rsi, rax 									; el dato es el *newCiudad
	
	mov rdx, c_borrar								; paso funcion c_borrar
	
	mov rcx, str_cmp								; paso funcion str_cmp
	
	call l_agregarOrdenado
	
	
.no_agrego_ciudad:
	
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

global rc_agregarRuta

rc_agregarRuta:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	push r14
		
	
	; tenemos que ver si podemos agregar la ruta o no 
	
	;guardemos la info
	mov rbx, rdi											; rbx <-- *redCaminera
	;info guardada podemos hacer call de lo que queramos
	
	; vamos a crear la ruta si o si (si la puedo agregar la agrego sino le mando free)
	mov rdi, rsi
	mov rsi, rdx
	; xmm0 tengo lo que queria
	call r_crear											; rax <-- *newRuta
	mov r13,rax												; GUARDO rax
	
	; ahora tengo que ver si ya estaba o no en la lista de rutas (similar a agregar ciudad)
	;(puede que r_crear me de NULL)
	cmp rax, NULL

	je .ruta_no_valida_no_agrego_ruta
	
	; si toy aca es porque cree una ruta VALIDA.
	
	mov rbx, [rbx + offset_rutas_redCaminera]				; rbx <-- *lista_de_rutas
	mov r12, rbx 											; GUARDO rbx 
	mov rbx, [rbx + offset_primero_lista]					; rbx <-- *primer_de_la_lista_de_rutas
	cmp rbx, NULL 											; veo si la lista era vacia
	je .dejamos_de_buscar_y_agregamos_ruta
	
	; en este punto tenemos una lista que no es vacia y un posible nodo a agregar		
	; rbx tengo el primer elemento de la lista rutas	
	
.continua_la_busqueda_ruta:	
	mov r14, rbx 											; GUARDO "el nodo actual, en el que estoy parado"
	
	mov rdi,[rbx + offset_dato_nodo]						; rbx <-- *rutaActualdeLaLista 
	mov rsi,r13  	
	call r_cmp
	
	cmp eax, 0
	je .la_ruta_ya_esta_NO_agrego_y_borro_la_que_cree
	
	; si estoy aca es porque tengo que seguir buscando
	
	mov rbx, [r14 + offset_siguiente_nodo]
	cmp rbx, NULL
	je .revisamos_todas_las_rutas_agreguemos
	
	jmp .continua_la_busqueda_ruta
	
.dejamos_de_buscar_y_agregamos_ruta:
.revisamos_todas_las_rutas_agreguemos:
	
	lea rdi, [r12]											; rdi <-- **lista_de_rutas
	mov rsi, r13											; r13 <-- *dato(ruta)
	mov rdx, r_borrar
	mov rcx, r_cmp	
	
	call l_agregarOrdenado
	
	jmp .agregado_correctamente
	
.la_ruta_ya_esta_NO_agrego_y_borro_la_que_cree:

	mov rdi,r13
	call free
.ruta_no_valida_no_agrego_ruta:
.agregado_correctamente:

	pop  r14
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
	je .no_existe_ruta
	
	; si estoy aca es posible que exista la ruta (ya que los nombres son distintos)
	;	AHORA veamos que las ciudades sean parte de la red
	; si ninguna esta 
	
	mov rbx, [rbx + offset_rutas_redCaminera]	;rbx <-- *lista_de_rutas
	mov rbx, [rbx + offset_primero_lista]		;rbx <-- *primerNodo
	
.continuar_busqueda_ruta:	
	cmp rbx, NULL
	je .no_existe_ruta
	
	mov r14, rbx								; r14 (guardo el nodo actual)
	; si no es vacia veo el valor de dato
	mov rbx, [rbx + offset_dato_nodo ]			; rbx <-- *dato (ruta)
	mov r15, rbx								; r15 (guardo el dato)
	mov rbx, [rbx + offset_ciudadA_ruta]		; rbx <-- *ciudadA(ruta)
	mov rbx, [rbx + offset_nombre_ciudad]		; rbx <-- *nombre de la ciudadA
	
	mov rdi, rbx 								; veo si coincide con nombre1
	mov rsi, r12
	call str_cmp
	; su coincide tengo que chequear nombre2
	cmp eax,0
	je .comparar_ciudadB						
	
	;si estamos aca tenemos que seguir recorriendo la lista
	mov rbx, [r14 + offset_siguiente_nodo]
	jmp .continuar_busqueda_ruta		
	 
.comparar_ciudadB:
	mov rbx, [r15 + offset_ciudadB_ruta]
	
	mov rdi,rbx
	mov rsi, r13
	call str_cmp
	cmp eax, 0
	je .encontre_la_ruta
	;sino tenemos que seguir buscando
	mov rbx,[r14+offset_siguiente_nodo]
	jmp .continuar_busqueda_ruta
	
.encontre_la_ruta:
	
	mov rax,r15
	jmp .ruta_encontrada_devolver
	 
.no_existe_ruta:
		
	mov rax, NULL
.ruta_encontrada_devolver:	
	
	add rsp,8
	pop r15
	pop r14
	pop r13
	pop r12
	pop rbp
	ret
	
;#######################################################################################################
;############################	ciudad* ciudadMasPoblada(redCaminera* rc);	############################
;#####################################						RDI				############################
;###### 	Retorna el puntero a la ciudad mas poblada de la red caminera pasada por parámetro.  #######
;#######################################################################################################
global ciudadMasPoblada
ciudadMasPoblada:
	push rbp
	mov rbp, rsp
	push rbx
	push r12
	push r13
	sub rsp,8
	
	mov rbx,[rdi + offset_ciudades_redCaminera] 		; rbx <-- *lista_de_ciudades
	mov rbx,[rbx +  offset_primero_lista]				; rbx <-- *nodo(ciudad)
	mov rax, NULL
	cmp rbx,NULL
	je .no_hay_ciudades
	
	mov r12, rbx 										; r12 me (guardo) el nodo actual 
	xor r8,r8											; r8 va a tener el valor mas grande de poblacion
	
.continua_busqueda_maximo:	
	mov rbx,[rbx + offset_dato_nodo]					; rbx <-- *ciudad
	mov r13, rbx										; r13 me (guardo) la ciudad actual
	mov rbx,[rbx + offset_poblacion_ciudad]				; rbx <-- poblacion de la ciudad actual
	cmp rbx, r8
	jg .actualizar_maximo								;(si es mayor rbx que r8) 	
	
	; si toy aca aun sigo con el mismo maximo tengo que avanzar en la lista
.pasar_a_siguiente:	
	mov rbx, [r12 + offset_siguiente_nodo]
	cmp rbx, NULL
	je .devolver_maximo
	jmp .continua_busqueda_maximo
	
.actualizar_maximo:
	
	mov rax, r13
	mov r8, rbx
	jmp .pasar_a_siguiente 	

.devolver_maximo:
.no_hay_ciudades:	
	add rsp,8
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
global rutaMasLarga
rutaMasLarga:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	
	mov rbx,[rdi + offset_rutas_redCaminera]			; rbx  <-- *lista de rutas
	mov rbx,[rbx + offset_primero_lista]				; rbx  <-- *primero (nodo)
	
	; veo si el primero es null
	cmp rbx, NULL
	; si es null devuelvo en rax NULL
	je .retornar_null 
	
	xor r8,r8											; va a ser mi initialize
	
.continua_busqueda_ruta:	
	mov r12, rbx										; r12 (guardo)el nodo actual		
	mov rbx,[rbx + offset_dato_nodo]					; rbx  <-- *dato(ruta)
	mov r13, rbx 										; r13 (GUARDO) el *dato posible a devolver
	mov rbx,[rbx + offset_distancia_ruta]				; rbx  <-- distancia
	
	cmp rbx, r8
	jg .actualizar_maxima_distancia

.avanzamos_en_la_ruta:	
	mov rbx, [r12 + offset_siguiente_nodo]
	cmp rbx, NULL
	je .devolver_la_ruta_mas_larga
	jmp .continua_busqueda_ruta
		
.actualizar_maxima_distancia:
	mov rax, r12
	mov r8, rbx	
	jmp .avanzamos_en_la_ruta

.retornar_null:
	mov rax, NULL
	
.devolver_la_ruta_mas_larga:
	
	pop r13
	pop r12
	pop rbp
	ret


;#####################################################################################################
;#############		void ciudadesMasLejanas(redCaminera* rc, ciudad** c1, ciudad** c2);	##############
;########################### 					rdi 			rsi 		rdx		##################
;#### Modifica los valores de los dobles punteros a ciudad, de forma de cargar en los mismos las #####
;##ciudades a mas distancia entre si. De existir mas de una, se toma la primer nombre mas chico. #####
;#####################################################################################################
global ciudadesMasLejanas
ciudadesMasLejanas:
	push rbp
	mov rbp, rsp
	
	
	
	pop rbp
	ret

;#####################################################################################################
;#########################	double totalDeDistancia(redCaminera *rc);	##############################
;#######################################					rdi 		##############################
;################	Obtiene la cantidad total de distancias de todas las rutas de la red. ############
;#####################################################################################################

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
	
	
	mov r12, rsi 								; rsi (guardo) *nombre de la ciudad
	
	mov rbx, [rbx + offset_rutas_redCaminera]	; rbx <-- * lista de rutas
	
	mov rbx, [rbx + offset_primero_lista]		; rbx <-- * primer nodo
	
	;limpiamos mi contador
	xor rax, rax
	mov r15d, eax
	; veo si mi lista es vacia
	cmp rbx, NULL
	je .ya_recorrimos_todo_devolver_valor_calculado
	
	;si estamos aca la lista tiene al menos una ruta veamos si uno de sus extremos es la ciudad
.recorrer_rutas:	
	mov r13, rbx 								; r13 (guardo) el nodo actual	
	mov rbx, [rbx + offset_dato_nodo]			;rbx <-- * ruta del nodo actual
	
	mov rbx, [rbx + offset_ciudadA_ruta]		; rbx <-- *ciudadA
	mov r14, [rbx + offset_ciudadB_ruta]		; r14 <-- *ciudadB
	
	
	; vemos si la ciudadA es igual al nombre pasado
	mov rdi, r12
	mov rsi, [rbx + offset_nombre_ciudad]
	call str_cmp
	cmp eax, 0
	je .incrementar_contador
	
	; si estoy aca es porq ciudadA no es, hay que ver si es ciudadB
	
	mov rdi,r12
	mov rsi,[r14 + offset_nombre_ciudad]
	call str_cmp
	je .incrementar_contador
	
	; si estoy aca tengo que avanzar en la lista_rutas 
	mov rbx, [r13+ offset_siguiente_nodo]
	cmp rbx, NULL
	je .ya_recorrimos_todo_devolver_valor_calculado
	jmp .recorrer_rutas	
	
.incrementar_contador:
	inc r15d
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
	
	xor r13, r13												; r13 (guardo) mi contador 
	
.busqueda_de_la_mas_poblada:	
	mov r14, rbx												; r14 (guardo) nodo actual
	mov rsi, [rbx + offset_dato_nodo]							; rsi <-- *ciudad	

	
	mov rbx,rsi													; rbx (guardo) el *ciudad	
	
	mov rsi, [rsi + offset_nombre_ciudad]						; rsi <-- *nombre de la ciudad
	mov rdi, r12												; rdi <-- * redCaminera
	call cantidadDeCaminos
																; eax <-- tengo la cant de caminos de la ciudad actual
																
	cmp eax, r13d
	; si son iguales ver cual tiene el nombre mas chico
	je .ver_nombre_mas_chico
	; si es mas grande eax actualizo la ciudad mas comunicada

	jg .actualizar_ciudad_mas_comunicada																

	; si no salte la ciudad es menos comunicada de la que ya tenia antes	
	; continuo buscando
.pasar_a_la_siguiente_ciudad:

	mov rbx, [r14+ offset_siguiente_nodo]
	cmp rbx, NULL
	je .ya_recorri_todas_las_ciudades
	; sino salte tengo mas que recorrer
	jmp .busqueda_de_la_mas_poblada
	
.ver_nombre_mas_chico:
	;rbx tengo *ciudad actual  r15 tengo el historico

	mov rdi,[r15 + offset_nombre_ciudad]
	mov rsi,[rbx + offset_nombre_ciudad]
	call str_cmp
	; en eax tengo 1 si r15 nombre es menor que rbx nombre --- avanzo en la lista de ciudades
	cmp eax, 1
	je .pasar_a_la_siguiente_ciudad
	; si no salto es que el nombre de rbx es menor entonces actualizo

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

;global str_copy
;str_copy:
	;push rbp
	;mov rbp, rsp
	
	
	
	;pop rbp
	;ret

;global str_cmp
;str_cmp:
	;push rbp
	;mov rbp, rsp
	
	
	
	;pop rbp
	;ret

global str_copy
str_copy:
	push rbp
	mov rbp, rsp
	push r12
	push r13 							;	# pila alineada #

	mov r12, rdi 						; 	# me guardo el puntero al string #			
	
	mov rdi, 8
	call malloc 						;	# pido memoria #

	mov r11, 0 							;	# r11 = indice #
	mov r13b, [r12+r11] 					;	# r13 = caracter[r11] #

.ciclo:
	cmp r13b, 0 						
	je .termine 						;	# ya copie el string porque termina en cero #
	mov byte [rax+r11], r13b 			; 	# copio el caracter en memoria #
	inc r11 							; 	# incremento el indice #
	mov r13b, [r12+r11] 					;	# r13 = caracter[r11] #
	jmp .ciclo 							;	# repito el ciclo #

.termine:
	pop r13
	pop r12
	pop rbp
ret

global str_cmp
str_cmp:
	push rbp
	mov rbp, rsp
	push r12
	push r13
	push r14
	push r15
	push rbx
	sub rsp, 8 								; 	# alineo la pila #

	xor rbx, rbx
	mov r8, 1 								;	# r8, r9 y r10 los uso como constantes #
	mov r9, -1
	mov r10, 0

	mov r14, 0 								;	# variable largo string1 #  
	mov r15, 0								;	# variable largo string2 #

	mov r12, [rdi]
	mov r13, [rsi]
	jmp .largo1

.largo2:									;	# recorro los caracteres del string2 hasta llegar a 0 #
	cmp r13b, 0
	je .fin_largo							; 	# llegue a 0 #
	inc r15 								;	# incremento el indice #
	mov r13b, [rsi + r15]
	jmp .largo2

.largo1: 									;	# recorro los caracteres del string1 hasta llegar a 0 #
	cmp r12b, 0 
	je .largo2 								; 	# llegue a 0 #
	inc r14									;	# incremento el indice #
	mov r12b, [rdi + r14]
	jmp .largo1
	
.fin_largo:
	mov rcx, r14
	cmp r14, r15
	cmovg rcx, r15 							;	# rcx = min(r14,r15) #

	cmovl rbx, r8							; 	# rbx = 1 si r14 < r15 #
	cmovg rbx, r9							; 	# rbx = -1 si r14 > r15 #
	cmove rbx, r10							; 	# rbx = 0 si r14 = r15 #
	mov r11, 0 								;	# indice #
	mov rax, 0

	mov r12, [rdi+r11]
	mov r13, [rsi+r11]
	
.ciclo_cmp:
	cmp r12b, r13b 							;	# comparo caracteres string1[r11]  con string2[r11] #
	cmovl rax, r8 							; 	# rax = 1 si string1[r11] < string2[r11] #
	cmovg rax, r9							; 	# rax = -1 si string1[r11] > string2[r11] #
	cmove rax, r10							; 	# rax = 0 si string1[r11] = string2[r11] #
	jl .fin 								;	# rax != 0 entonces salto #
	jg .fin 								;	# rax != 0 entonces salto #
	inc r11 								;	# incremento el indice #
	mov r12b, [rdi + r11] 					;	# r12 = siguiente caracter de string1 #
	mov r13b, [rsi + r11]					;	# r13 = siguiente caracter de string2 #
	loop .ciclo_cmp 

.largo_y_rax:
	cmp rax, 0 								
	jne .fin
	mov rax, rbx 							; 	# si un string es prefijo de otro, entonces me fijo por el largo #

.fin:
	add rsp, 8
	pop rbx
	pop	r15
	pop r14
	pop r13
	pop r12
	pop rbp
ret
