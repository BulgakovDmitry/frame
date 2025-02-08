.model tiny
.code
org 100h
; di
Start:
	mov ah, 09h                             ; printf ('Hello world')
	mov dx, offset String		            ;
	int 21h                                 ;
	                                  
	mov bx, 0b800h		                    ; write to bx addr video mem
	
	mov es, bx							    ;
	mov bx, 700			                    ; start to position 500 in vid mem
	
	call DrawtopBorder
	call DrawString
	call DrawString
	call DrawString
	call DrawString
	call DrawString
	call DrawString

	call DrawWords

	call DrawString
	call DrawString
	call DrawString
	call DrawString
	call DrawString
	call DrawString
	call DrawbottonBorder

	mov ax, 4c00h							; return 0
	int 21h									;


String: db "Hello World$"

;------------------------------------------------
; Draw string in video mem
; Entry: None
; Exit : None
; Destr: bx es cx

DrawString  proc
		    mov cx, 40 

			mov si, offset ArraySymbols
			mov dx, [si]

			call DrawSideBorder
				
			mov dx, [si+1]
			CycleForString:
				mov byte ptr es:[bx], dl
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1
				loop CycleForString
			
			mov dx, [si+2]

			call DrawSideBorder

			add bx, 76

			ret 
			endp

DrawSideBorder  proc

				mov byte ptr es:[bx], dl
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1

				ret 
				endp

DrawtopBorder   proc

				mov cx, 40

				mov byte ptr es:[bx], 201
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1

				CycleForTopBorder:
					mov byte ptr es:[bx], 205
					add bx, 1                                     
					mov byte ptr es:[bx], 00110100b
					add bx, 1
					loop CycleForTopBorder
				
				mov byte ptr es:[bx], 187
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1

				add bx, 76

				ret 
				endp

DrawbottonBorder proc

				mov cx, 40

				mov byte ptr es:[bx], 200
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1

				CycleForBottonBorder:
					mov byte ptr es:[bx], 205
					add bx, 1                                     
					mov byte ptr es:[bx], 00110100b
					add bx, 1
					loop CycleForBottonBorder
				
				mov byte ptr es:[bx], 188
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1

				add bx, 76

				ret 
				endp

DrawWords       proc

				mov byte ptr es:[bx], 186
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1

				mov cx, 17
				CycleForWordsInFrame1:
					mov byte ptr es:[bx], ' '
					add bx, 1                                     
					mov byte ptr es:[bx], 00110100b
					add bx, 1
					loop CycleForWordsInFrame1

				mov si, offset WordsInFrame

				mov dx, [si]
				mov byte ptr es:[bx], dl
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1
				
				mov dx, [si+1]
				mov byte ptr es:[bx], dl
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1

				mov dx, [si+2]
				mov byte ptr es:[bx], dl
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1

				mov dx, [si+3]
				mov byte ptr es:[bx], dl
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1

				mov dx, [si+4]
				mov byte ptr es:[bx], dl
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1

				mov cx, 18
				CycleForWordsInFrame2:
					mov byte ptr es:[bx], ' '
					add bx, 1                                     
					mov byte ptr es:[bx], 00110100b
					add bx, 1
					loop CycleForWordsInFrame2

				mov byte ptr es:[bx], 186
				add bx, 1                                     
				mov byte ptr es:[bx], 00110100b
				add bx, 1

				add bx, 76

				ret 
				endp
;------------------------------------------------

ArraySymbols: db 186, ' ', 186 
WordsInFrame : db 'MEOW!' 

end Start