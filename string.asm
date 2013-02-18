segment .data
strtmp: 	dd 0
mulp:		dd 0

segment .text

; _strtoint:
; IN: esi
; OUT: edi
_strtoint:
        pushad

        mov 	ebx, esi
        call 	_strlen

        add 	esi, ecx
        dec 	esi

        xor 	ebx, ebx                       
        xor 	eax, eax

        mov 	dword [mulp], 1     

.loop:
        xor	eax, eax
        mov 	byte al, [esi]               
        sub 	al, 48

        mul 	dword [mulp]

        add 	ebx, eax

        push 	eax                        
        mov 	dword eax, [mulp]
        mov 	edx, 10
        mul 	edx
        mov 	dword [mulp], eax
        pop 	eax

        dec 	ecx
        test 	ecx, ecx
        jz 	.end
        dec 	esi
        jmp 	.loop

.end:
        mov 	[strtmp], ebx

        popad

        mov 	edi, [strtmp]

        ret

; _strcpy:
; IN: esi, edi
; OUT: void
_strcpy:
        pushad

        test    esi, esi
        jz      .end
.loop:
        mov     al, [esi]
        mov     [edi], al
        inc     esi
        inc     edi
        mov     eax, [esi]
        cmp     byte al, 0
        jnz     .loop

.end:
        popad

        ret

; _strlen:
; IN: ebx - str location
; OUT: ecx
_strlen:
	pushad

	xor	ecx, ecx
	test	ebx, ebx
	jz	.end

.loop:
	cmp	byte [ebx], 0
	jz	.end
	inc	ebx
	inc	ecx
	jmp	.loop

.end:
	mov	[strtmp], ecx

	popad

	mov	ecx, [strtmp]

	ret

; _strcmp:
; IN: esi, edi, ecx
; OUT: carry set if true (same)
_strcmp:
	pushad

	test	esi, esi
	jz	.false
	test	edi, edi
	jz	.false
	cld
	repe	cmpsb
	je	.true

.false:
	clc
	jmp	.end

.true:
	stc

.end:
	popad

	ret
