.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern fscanf: proc
extern fprintf: proc
extern fopen: proc
extern fclose: proc
extern printf: proc
extern scanf: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date

;date pentru partea de meniu
mesaj_meniu db "Introduceti cifra pentru operatiunea dorita:",10,13,"Comprimare: 1",10,13,"Decomprimare: 2",10,13,0
mesaj_eroare_op db "Operatiune invalida",10,13,10,13,0
format_nr db "%d",0
oper db 0


;date pentru partea de comprimare
fin_name db 100 dup(0)
fin dd 0
dict_name db "dictionar.txt",0
dict dd 0
fout_name db "fisier_out.txt",0
fout dd 0

mode_read db "r",0
mode_write db "w",0
mesaj_eroare db "fisier inaccesibil",0,0
mesaj_comprimare db "Introduceti numele fisierului pe care doriti sa il comprimati:",10,13,0
format_sir db "%s",0
format_cod db "%d ",0
format_dictionar db "%s-%d, ",0
index dd 0
poz dd 0
k dd 0	;prima litera a cuvantului cu indicele i
p dd 0	;prima litera a cuvantului cu indicele j
q dd 0	;parcurge literele cuvantului cu indicele i
r dd 0	;parcurge literele cuvantului cu indicele j
n dd 0
vizitat dw 1000 dup(0)
cod dw 1000 dup(0)
cuv db 20000 dup(0)


;date pentru partea de decomprimare
fcompr_name db 100 dup(0)
fcompr dd 0
fdecompr_name db "fisier_decomp.txt",0
fdecompr dd 0


mesaj_decomprimare db "Introduceti numele fisierului pe care doriti sa il decomprimati:",10,13,0
format_sir_scriere db "%s ",0

i dd 0	;pozitia primei litere din cuvantul decodificat, apoi parcurge vectorul dictionar pentru a scrie cuvantul decomprimat
;q dd 0	;parcurge vectorul dictionar, in final va arata pozitia ultimei litere din cuvantul decomprimat 
;p dd 0	;parcurge cuvantul de cod pentru comparatia cu vectorul dictionar
j dd 0	;parcurge pozitiile pe care se insereze literele in cuvantul decomprimat

;cuv db 20000 dup(0)
w db 100 dup(0)
decom db 100 dup(0)


.code



;aici incepe functia de comprimare
fct_compr proc

	mov fin,ecx
	
	push offset mode_write
	push offset dict_name
	call fopen
	add esp,8
	mov dict,eax
	
	push offset mode_write
	push offset fout_name
	call fopen
	add esp,8
	mov fout,eax
	
	
	
; aici incepe comprimarea efectiva	
	
	mov esi,0
bucla_citire:
	
	lea edi, cuv[esi]
	
	push edi
	push offset format_sir
	push fin
	call fscanf
	add esp,12
	
	cmp eax,1
	jne iesire
	
	mov al,cuv[esi]
	cmp al,'A'
	jl nu_majuscula
	
	cmp al,'Z'
	jg	nu_majuscula
	add al,32
	mov cuv[esi],al
	nu_majuscula:
	
	mov cl,0
	urmatoarea_adresa:
		inc esi
		cmp cuv[esi],cl
		jne urmatoarea_adresa
		
	inc esi
	inc n
	
	jmp bucla_citire
	
	mov al,0
	mov cuv[esi],al
	
iesire:

	mov ecx,0	;i=0	
	mov edi,0	
	dec edi		;index=-1
	
analiza_vector:
	cmp ecx,n
	je analiza_completa
	
		mov dx,1
		cmp vizitat[2*ecx],dx
		je incrementare_i
		
		inc edi
		mov cod[2*ecx],di
		
		mov ebx,ecx
		inc ebx					;j=i+1
		
		mov eax,k
		mov dl,0
				
		urm_adr:
			inc eax
			cmp cuv[eax],dl
			jne urm_adr
		inc eax
		mov p,eax
		
		bucla:
			cmp ebx,n
			je incrementare_i
			
			mov eax,k
			mov q,eax
			
			mov eax,p
			mov r,eax
			compar_caracter_cu_caracter:
				mov eax,q
				mov dh,cuv[eax];
				
				mov eax,r
				mov dl,cuv[eax];
				
				cmp dh,dl
				jne incrementare_j
				
				cmp dh,0
				je egale
				
				inc r
				inc q
				jmp compar_caracter_cu_caracter
				
			egale:
				inc vizitat[2*ebx]
				mov cod[2*ebx],di
				inc ebx
				mov eax,r
				mov p,eax
				inc p
				jmp bucla
			
			incrementare_j:
				inc ebx
				
				mov eax,p
				mov dl,0
				
				urm:
					inc eax
					cmp cuv[eax],dl
					jne urm
					
				inc eax
				mov p,eax
			
				jmp bucla
			
		incrementare_i:
			inc vizitat[2*ecx]
			inc ecx
			
			mov dl,0
			urm_adresa:
				inc k
				mov eax,k
				cmp cuv[eax],dl
				jne urm_adresa
			
			inc k

			jmp analiza_vector
			
analiza_completa:

	push fin
	call fclose
	add esp,4

	mov ecx,0
	mov index,ecx
	
scriere_fisier:
	
	mov ecx,index
	cmp ecx,n
	je fisier_complet
		
		mov edi,0
		mov di,cod[2*ecx]
		push edi
		push offset format_cod
		push fout
		call fprintf
		add esp,12
		
	inc index
	jmp scriere_fisier
		
fisier_complet:
	push fout
	call fclose
	add esp,4
	

	mov ecx,0
	mov index,ecx
	mov eax,0
	mov poz,eax
	
scriere_dictionar:

	mov ecx,index
	cmp ecx,n
	je dictionar_complet
	
	mov dx,1
	cmp vizitat[2*ecx],dx
	jg next_cuv
		
		mov edi,0
		mov di,cod[2*ecx]		
		push edi
		
		mov eax,poz
		lea edi,cuv[eax]
		push edi
		
		push offset format_dictionar
		push dict
		call fprintf
		add esp,16
		
	next_cuv:
		inc index
		
		mov dl,0
		urm_caracter:
			inc poz
			mov eax,poz
			cmp cuv[eax],dl
			jne urm_caracter
			
		inc poz
		jmp scriere_dictionar
	
dictionar_complet:
	push dict
	call fclose
	add esp,4	
	
;aici se incheie comprimarea efectiva

	ret
	
fct_compr endp
;aici se incheie functia de comprimare



;aici incepe functia de decomprimare
fct_decompr proc
	
	mov fcompr,ecx
	
	push offset mode_read
	push offset dict_name
	call fopen
	add esp,8
	mov dict,eax
	
	push offset mode_write
	push offset fdecompr_name
	call fopen
	add esp,8
	mov fdecompr,eax
	
		
	
	mov esi,0
bucla_citire_decompr:

	lea edi, cuv[esi]
	
	push edi
	push offset format_sir
	push dict
	call fscanf
	add esp,12
	
	cmp eax,1
	jne iesire_decompr
	
	mov cl,0
	urmatoarea_adresa_decompr:
		inc esi
		cmp cuv[esi],cl
		jne urmatoarea_adresa_decompr
		
	inc esi
	
	jmp bucla_citire_decompr
	
	mov al,0
	mov cuv[esi],al
	
iesire_decompr:

	mov esi,0
	
analiza_fisier:
	
	push offset w
	push offset format_sir
	push fcompr
	call fscanf
	add esp,12
	
	cmp eax,1
	jne analiza_completa_decompr
	
	mov eax,0
	mov p,eax
	
	mov eax,0
	mov q,eax
	
	bucla_decompr:
		mov eax,p
		mov dl,w[eax]
		
		cmp dl,0
		je gasire_ultimul_carcarter
		
		mov eax,q
		mov dh,cuv[eax]
		
		cmp dh,dl
		je continuare
		
		mov eax,0
		mov p,eax
		inc q
		jmp bucla_decompr
		
		continuare:
			inc p
			inc q
		
		jmp bucla_decompr
		
	gasire_ultimul_carcarter:
		dec q
		mov eax,q
		mov dl,cuv[eax]
		cmp dl,'-'
		jne gasire_ultimul_carcarter
		
		mov eax,q
		mov i,eax
		
		gasire_primul_caracter:
			dec i
			mov eax,i
			mov dl,cuv[eax]
			mov dh,0
			cmp dh,dl
			jne	gasire_primul_caracter
		inc i
		
		jmp cuvant_gasit
		
	cuvant_gasit:
		
		mov eax,0
		mov j,eax
		
		
		bucla_cuvant:
			mov eax,q
		
			cmp i,eax
			je cuvant_complet
		
			mov eax,i
			mov dl,cuv[eax]
			mov eax,j
			mov decom[eax],dl
		
			inc j
			inc i
		
		jmp bucla_cuvant
		
		
	cuvant_complet:
		mov eax,j
		mov dl,0
		mov decom[eax],dl
		
		
	push offset decom
	push offset format_sir_scriere
	push fdecompr
	call fprintf
	add esp,12
	
	jmp analiza_fisier
		
analiza_completa_decompr:
	push dict
	call fclose
	add esp,4
	
	push fdecompr
	call fclose
	add esp,4

	ret
	
fct_decompr endp
;aici se incheie functia de decomprimare




start:
	;aici se scrie codul
	push offset mesaj_meniu
	push offset format_sir
	call printf
	add esp,8
	
	push offset oper
	push offset format_nr
	call scanf
	add esp,8
	
	mov al,1
	cmp al,oper
	je comprimare
	inc al
	cmp al,oper
	je decomprimare
	jmp eroare
	
	
; aici incepe partea de comprimare
comprimare:
	push offset mesaj_comprimare
	push offset format_sir
	call printf
	add esp,8
	
	push offset fin_name
	push offset format_sir
	call scanf
	add esp,8	
	
	push offset mode_read
	push offset fin_name
	call fopen
	add esp,8
	cmp eax,0
	jz eroare_compr
	mov fin,eax
	
	
	mov ecx,fin
	call fct_compr
	
		jmp final
		
eroare_compr:
	push offset mesaj_eroare
	push offset format_sir
	call printf
	add esp,8
	
		jmp final
	
	
decomprimare:
	
	push offset mesaj_decomprimare
	push offset format_sir
	call printf
	add esp,8
	
	push offset fcompr_name
	push offset format_sir
	call scanf
	add esp,8	
	
	push offset mode_read
	push offset fcompr_name
	call fopen
	add esp,8
	cmp eax,0
	jz eroare_decompr
	mov fcompr,eax
	
	mov ecx,fcompr
	call fct_decompr
	
		jmp final
	
eroare_decompr:
	push offset mesaj_eroare
	push offset format_sir
	call printf
	add esp,8
	
		jmp final
		
eroare:
		push offset mesaj_eroare_op
		push offset format_sir
		call printf
		add esp,8
		jmp start
		
	final:
	
	
	;terminarea programului
	push 0
	call exit
end start
