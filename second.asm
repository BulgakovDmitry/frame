.model tiny
.code
org 100h
; глава 10 177

Start:
	mov ah, 09h                           	     ; printf ("Hello world")
	mov dx, offset String		                 ;
	int 21h                                		 ;
	                                  
	mov bx, 0b800h		                   		 ; write to bx addr video mem
	
	mov es, bx							         ;
	mov bx, 700			                         ; start to position 500 in vid mem
	mov ah, 00110100b							 ; put to ah the color atribute 

	mov dx, 7									 ; frame width
	;mov sp, 48
	call drawFrame								 ; draw frame
	
	mov ax, 4c00h							     ; return 0
	int 21h									     ;

String: db "Hello World$"

;------------------------------------------------
; Draw frame in video mem
; Entry: None
; Exit : None
; Destr: si, di

drawFrame	proc

			sub di, 1

			mov si, offset ArraySymbols		     ; put string to si

			call drawLine					     ; draw the top of border
			add si, 3							 ; array pointer += 3

			call drawSpace

			call drawWords						 ; draw words in the middle of the frame 

			mov si, offset ArraySymbols + 3

			call drawSpace

			add si, 3							 ; array pointer += 3
			call drawLine						 ; draw the botton of border

			ret
endp
;------------------------------------------------

drawSpace 	proc

			mov di, dx							 ; 
			cycleForDrawingLine:				 ; draw space 
				call drawLine				     ; 
				sub di, 1					     ;
				jnz cycleForDrawingLine 		 ;
			ret
endp

;------------------------------------------------
; Draw line of the frame (subfunction of drawFrame) 
; Entry: None
; Exit : None
; Destr: cx, al

drawLine    proc

			mov al, [si]						 ; al = ArraySymbols[si]
			call DrawChar						 ; 
				
		    mov cx, 40                           ; number of repetitions
			mov al, [si+1]						 ; al = ArraySymbols[si + 1]
			CycleForString:
				call DrawChar
				loop CycleForString
			
			mov al, [si+2]					     ; al = ArraySymbols[si + 2]
			call DrawChar						 ; 

			add bx, 76

			ret 
endp

drawWords       proc

				mov al, 186
				call DrawChar

				mov di, 17
				cycleForDrawingString1:				 ; draw space 
					mov al, ' '
					call DrawChar
					sub di, 1
					jnz cycleForDrawingString1 		 ;

				mov si, offset WordsInFrame

				mov di, 5
				cycleForDrawingString3:
					mov al, [si]
					call DrawChar
					add si, 1
					sub di, 1
					jnz cycleForDrawingString3

				mov di, 18
				cycleForDrawingString2:				 ; draw space 
					mov al, ' '
					call DrawChar
					sub di, 1
					jnz cycleForDrawingString2 		 ;

				mov al, 186
				call DrawChar

				add bx, 76

				ret 
				endp

DrawChar 		proc

				mov byte ptr es:[bx], al
				add bx, 1                                     
				mov byte ptr es:[bx], ah
				add bx, 1

				ret 
endp
;------------------------------------------------ 

ArraySymbols : db 201, 205, 187, 186, ' ', 186, 200, 205, 188 
;ArraySymbols : db c9h, cdh, bbh, bah, ' ', bah, c8h, cdh, bch 
WordsInFrame : db 'MEOW!' 

end Start