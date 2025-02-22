	.model tiny
	.code

	locals @@

	org 100h

				COLOR_ATR   			    = 00110100b
				SIZE_OF_SCREEN              = 160
				HEIGHT_OF_SCREEN            = 25
				ADDR_OF_VIDEO_MEMORY        = 0b800h
				ADDR_OF_COMMAND_STR         = 082h
				SYSTEM_CALL                 = 21h
				RETURN_0                    = 4c00h
				
	Start:
				jmp main
				WordsInFrame db 'MEOW!$' 
				String       db "HELLO$"
				ArraySymbols db 201, 205, 187, 186, ' ', 186, 200, 205, 188  
				FRAME_WIDTH  dw 0
				FRAME_HEIGHT dw 0

;--------------------------------------------------------------------------------------------------
	main:	
				mov ah, 09h                      ; 
				mov dx, offset String		     ; printf ("Hello")
				int SYSTEM_CALL                  ;
												
				call getXY                       ; return ax - width, bx - height
				;FRAME_WIDTH			    = ax
				mov FRAME_WIDTH, ax
				mov FRAME_HEIGHT, bx
				;FRAME_WIDTH				    = 20 ; длина
				;FRAME_HEIGHT  				= 8  ; высота


				mov di, ADDR_OF_VIDEO_MEMORY	 ; write to di addr video mem
				mov es, di			             ;

				call getBias                     ;mov di, START_POSITION_IN_VIDEO_MEMORY

				mov ah, COLOR_ATR			     ; put to ah the color atribute 
				;call getColor

				call drawFrame					 ; draw frame

				call myStrlen
				call printMessage
				
				mov ax, RETURN_0			     ; return 0
				int SYSTEM_CALL  		         ;
;--------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------
 	; Draw frame in video mem
 	; Entry: None
 	; Exit : None
 	; Destr: si, di
 	drawFrame	proc
 				mov si, offset ArraySymbols		     ; put string to si
 				call drawLine					     ; draw the top of border
 				add si, 3							 ; array pointer += 3
				call drawSpace						 ; draw the space over the text

																;call drawWords						 ; draw words in the middle of the frame 
												
																;mov si, offset ArraySymbols + 3
																;
																;call drawSpace						 ; draw the space over the text
																;

				add si, 3							 ; array pointer += 3
				call drawLine						 ; draw the botton of border
				;and al, 0feh
 				ret
 	endp
;--------------------------------------------------------------------------------------------------

;--------------------------------------------------------------------------------------------------
 	; Draw background of frame in video mem
 	; Entry: None
 	; Exit : None
	; Destr: bx
 	drawSpace 	proc

 				;mov bx, FRAME_HEIGHT - 2
				mov bx, [word ptr FRAME_HEIGHT]
				sub bx, 2

 				@@cycleForDrawingLine:				 ; draw space 
 					call drawLine 
 					sub bx, 1					     ;
 					jnz @@cycleForDrawingLine 		 ;
 				ret
 	endp
;--------------------------------------------------------------------------------------------------

;//TODO debug comments
;--------------------------------------------------------------------------------------------------
 	; Draw line of the frame (subfunction of drawFrame) 
 	; Entry: si - offset
 	; Exit : None
 	; Destr: al, di
 	drawLine    proc

 				mov al, [si]						 ; al = ArraySymbols[si]
 				stosw						         ;  

 				mov al, [si+1]						 ; al = ArraySymbols[si + 1]

 				mov cx, [word ptr FRAME_WIDTH]
				sub cx, 2

 				rep stosw 			     		     ; CycleForString:
 												     ;    stosw
 											         ;    loop CycleForString
				
 				mov al, [si+2]					     ; al = ArraySymbols[si + 2]
				
 				stosw

				push si

 				mov si, FRAME_WIDTH              ;
 				shl si, 1						 ;
 				neg si							 ; add di, SIZE_OF_SCREEN - (2 * FRAME_WIDTH)
 				add si, SIZE_OF_SCREEN			 ;
				add di, si						 ;
				
				pop si
 				
			

 				ret 
 	endp
;--------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------
 	; counts the number of characters in the string until it reaches the '$' character
 	; ENTRY: None
 	; EXIT:  CX - result
 	; DESTR: al, di, cx
 	myStrlen proc

 				mov al, '$'
 				mov di, ds
 				mov es, di
 				lea di, WordsInFrame
 				xor cx, cx
 				dec cx
 				repne scasb
 				neg cx
 				sub cx, 2
 				ret
 	endp
;--------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------
	PRINT proc
	; Function for printing text at a calculated address
	; ENTRY:   DI - bias message
	;          AH - color of text
	;          CX - number of symbols
	;          SI - current place in command line
	; DESTROY: 

			mov bx, 0b800h
			mov es, bx

			mov bx, di
			mov di, si
			mov si, bx

			PRINT_MESSAGE_CYCLE:
			lodsb            ;| <=>  mov es[di], ax   add di, 2
			stosw
			loop PRINT_MESSAGE_CYCLE
			ret
    endp
;--------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------
	getEven proc

			and si, 0fffeh
			ret
	endp
;--------------------------------------------------------------------------------------------------



;--------------------------------------------------------------------------------------------------
 	; ENTRY: ax - x 
 	;        bx - y
 	; EXIT: di - result
 	; DESTROY: di, di, ax
 	getBias proc
 				mov di, ax
 				sub di, SIZE_OF_SCREEN / 2       ; bias_x = (160 - 2x)/2 = 80 - x
 				neg di                  

 				mov si, bx
 				sub si, HEIGHT_OF_SCREEN                       ; bias_y = (25 - y)/2
 				neg si
 				shr si, 1

 				mov ax, si                       ; al = bias_y
 				mov bx, di 
 				mov di, SIZE_OF_SCREEN    	     ; di = 160
 				mul di         				     ; ax = di * al
 				mov si, ax                       ; si = ax
 				mov di, bx
 				add si, di                       ; si = si + di
			
 				mov di, si                       ; di = si

				and di, 0fffeh
 				ret
    endp
;--------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------
 	; ENTRY:   None
 	; EXIT:    ax - frame width  (X)
 	;          bx - frame height (Y)
 	; DESTROY: ax, bx, cx, dx, si, di
 	getXY 		proc

 				mov si, ADDR_OF_COMMAND_STR
 				call myAtoi
 				mov cx, bx

 				mov di, si
				call skipSpace

 				mov si, di
 				call myAtoi

 				mov di, si
 				call skipSpace
				
 				mov ax, cx
 				ret
    endp
;--------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------
	getColor proc

			mov dh, ah       
			mov si, di
			call MY_ATOHEX

			mov di, si
			call skipSpace
			mov ah, dh     
			ret
		endp
;--------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------
	; Print message in center of frame
	; ENTRY  : 
	; DESTROY: AX, BX
    printMessage proc

            call getBiasMessage
            call getEven
            call PRINT
            ret
    endp
;--------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------
    getBiasMessage proc

            mov si, cx
            sub si, 2000   ; bias_common = bias_x + bias_y = (25 - 1)/2 * 160 + (160 - 2x)/2 = 2000 - x
            neg si
            ret
    endp
;--------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------
 	; Converts a number consisting of ascii codes into a hex number
 	; ENTRY:   None
 	; EXIT:    bx - result
 	; DESTROY: ax, bx, dx, si 
    myAtoi 		proc

 				mov ax, [si]         
 				cmp al, 0h            
 				je OUT__             

 				xor ax, ax
 				xor bx, bx
 				lodsb
				
 				CONDITION_ATOI:
 				cmp al, '9'
 				ja NOT_NUMBER

 				cmp al, '0'
 				jb NOT_NUMBER

 				sub al, '0'
 				mov dx, bx
 				shl bx, 3       
 				shl dx, 1    
 				add bx, dx   
 				add bx, ax
 				lodsb
 				jmp CONDITION_ATOI

 				NOT_NUMBER:
 				ret

 				OUT__: call myEnd
    endp
;--------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------
	; Converts a number consisting of ascii codes into a hex number
	; ENTRY:   None
	; EXIT:    CX - result
	; DESTROY: AX, CX, DX, SI 
    MY_ATOHEX proc

           mov ax, [si]         
           cmp al, 0h           
           je OUT__             

           xor ax, ax
           xor cx, cx
           lodsb
           
        CONDITION_ATOHEX:
           cmp al, '0'
           jb MY_NOT_NUMBER

           cmp al, '9'
           ja CompareBigLetters
           
           sub al, '0'
           jmp ConvertingToHex
        
        CompareBigLetters:
           cmp al, 'A'
           jb MY_NOT_NUMBER

           cmp al, 'F'
           ja CompareSmallLetters
           
           sub al, 'A'
           add al, 10
           jmp ConvertingToHex

        CompareSmallLetters:
           cmp al, 'a'
           jb MY_NOT_NUMBER

           cmp al, 'f'
           ja MY_NOT_NUMBER
           
           sub al, 'a'
           add al, 10

        ConvertingToHex:
           shl cx, 4
           add cx, ax
           lodsb
           jmp CONDITION_ATOHEX

        MY_NOT_NUMBER:
           ret

        MY_OUT__: call myEnd
   endp
;--------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------
 	; Skips whitespace characters until it reaches the first non-whitespace character. 
 	; ENTRY:   AL - current symbol in string
 	;          DI - address of current symbol
 	; EXIT:    DI - address of the first non-space character encountered
 	; DESTROY: AL, SI, DI
    skipSpace 	proc

 				mov si, ds
 				mov es, si
 				mov al, byte ptr es:[di] 
 				cmp al, ' '
 				jne OUT_SKIP_SPACE

 				repe scasb
 				dec di

 				OUT_SKIP_SPACE: 
 				ret
     endp
;--------------------------------------------------------------------------------------------------


;--------------------------------------------------------------------------------------------------
 	myEnd 		proc
 				MY_END_Label:
 				mov ah, 4ch
 				int 21h
 				ret
 	endp
;--------------------------------------------------------------------------------------------------

	end Start
