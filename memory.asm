        extern  malloc
        extern  free

segment         .data

segment         .text

; _memset:
; IN: EDI - addr, EDX - value, ECX - length 
; OUT: void
_memset:
	pushad

.loop:
	test	ecx, ecx
	jz	.end

	mov	byte [edi], dl
	inc	edi
	dec 	ecx	
	jmp	.loop

.end:
	popad
	ret

; _free_array4b:
; IN: EBX
; OUT: void
_free_array4b:
	pushad

.loop:	
        cmp     dword [ebx], 0
        jz      .end

	push	ebx
	mov	ebx, [ebx]
	call	_strlen
	pop	ebx
	push	ecx

        push    dword [ebx]
        call    free
	add	esp, 4

	pop	ecx	
	mov	edi, [ebx]
	xor	edx, edx
	call	_memset
	mov	dword [ebx], 0		; zero

	add	ebx, 4
	jmp	.loop
	
.end:
	popad

	ret

; _malloc:
; IN: ST0
; OUT: EAX
_malloc:
        call    malloc
        ret

	%INCLUDE       "debug.asm"
	%INCLUDE	"string.asm"
