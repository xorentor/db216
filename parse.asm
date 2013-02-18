segment .data

segment .bss
	pointers resd 128

segment .text

	extern malloc

	%define 	DELIMITER 	'.'

; _parsestr:
; IN: ebx - string, ecx - strlength
; OUT: ebx - string array
_parsestr:
	pushad

	mov 	esi, ebx		; string
	;lodsb	
	;movzx 	ebx, al
	mov	ebx, ecx		; string length
	add 	ebx, esi

	mov 	edx, pointers

.top:
	xor 	ecx, ecx

.getlen:
    	cmp 	byte [esi + ecx], DELIMITER
    	jz 	.gotlen
    	inc 	ecx
    	lea 	edi, [esi + ecx]
    	cmp 	edi, ebx
    	jnz 	.getlen

.gotlen:
    	inc 	ecx		
    	push 	edx	
    	push 	ecx	
    	call	malloc
    	pop 	ecx
    	pop 	edx

;	call	_printx

	; malloc failed ?
	test	eax, eax
	jnz	.mallocok
	popad
	jmp	.end

.mallocok:
    	mov 	[edx], eax	
    	add 	edx, 4		
    
    	mov 	edi, eax	
    	dec 	ecx		

    	mov 	al, cl
    	;stosb
    	rep 	movsb

    	inc 	esi	
    	cmp 	esi, ebx	
    	jb 	.top		

	popad

    	mov 	ebx, pointers

.end:
	ret 

	;%INCLUDE	"debug.asm"
