segment		.data
tmp:		dd 0

segment		.text

; _cmd_get_empty_row:
; IN: edi
; OUT: eax
_cmd_get_empty_row:
	; FIXME: do this before loop
	mov	eax, [edi+8]
.loop:
	cmp	byte [eax], 0
	jz	.end

	call	_printdb

	add	eax, [edi+2]
	inc	eax			; reserved byte
 	jmp	.loop
		
.end:
	ret

; _cmd_insert_row:
; IN: ebx - data, ecx - column distance, edx - column size, edi - row size/table data start
; OUT: void
_cmd_insert_row:
	pushad

	call	_cmd_get_empty_row
	
	mov	byte [eax], 1		; reserved byte
	add	eax, ecx		; column start

	cmp	dword [edx-4], 4
	jg	.str

	lea	esi, [ebx+4]
	call	_strtoint
	mov	[eax], edi		; insert int

.str:
	lea	esi, [ebx+4]
	mov	edi, eax
	call	_strcpy

	popad
	ret

; _push_result_4B:
; IN: ebx - result address, esi - 4B int
; OUT: void
_push_result_4B:
	pushad

	push	4
	call	_malloc
	add	esp, 4
	mov	dword [eax], esi

.loop:
	cmp	dword [ebx], 0
	jz	.push	
	add	ebx, 4
	jmp	.loop

.push:
	mov	[ebx], eax

	popad
	ret

; _push_result_str:
; IN: ebx - result address, esi - string
; OUT: void
_push_result_str:
	pushad

	push	ebx

	mov	ebx, esi
	call	_strlen
	push	ecx
	call	_malloc
	add	esp, 4	
	mov	edi, eax
	call	_strcpy

	pop	ebx
.loop:
	cmp	dword [ebx], 0
	jz	.push
	add	ebx, 4
	jmp	.loop
	
.push:
	mov	[ebx], eax	

.end:
	popad
	ret

; _error:
; IN: ebx, esi
; OUT: void
_error: 
	pushad

.loop:				; FIXME: check for MAX_ERROR
	cmp	dword [ebx], 0
	jz	.add
	add	ebx, 4
	jmp	.loop

.add:
	mov	[ebx], esi

.end:
	popad
	ret

; _cmd_get_table_pointer:
; IN: esi - table name, edx - db pointer
; OUT: edx - pointer, carry if not empty
_cmd_get_table_ptr:
	pushad
	clc

	xor	ecx, ecx
	mov	ebx, esi
	call	_strlen	

	mov     eax, [edx + db_s.ptr]
	push	dword [eax + table_s.ptr]

        lea     eax, [eax + table_s.name]
	mov	ebx, esi
	call	_strlen
	xor	ebx, ebx
.cmp:
	cmp	ebx, MAX_TABLES_PER_DB
	jz	.notfound

	mov	edi, eax
	call	_strcmp	
	jc	.found
	add	eax, 88h		; 136d, 128 + 4 + 4
	inc	ebx
	
	jnc	.cmp

.found:
	pop	edx		
	mov	[tmp], edx
	stc
	jmp	.end

.notfound:
	add	esp, 4
	clc

.end:
	popad

	mov	edx, [tmp]
	
	ret

; _cmd_get_db_pointer:
; IN: esi - db name, edx - db pointers
; OUT: edx - pointer, carry if not empty
_cmd_get_db_ptr:
	pushad
	clc

.cmp:
	mov	eax, [edx]
	mov	edi, eax

	test	edi, edi
	jz	.notfound
	add	edx, 4

	mov	ebx, edi
	call	_strlen			; prepares ecx for strcmp
	test	ecx, ecx		; FIXME: out of loop
	jz	.notfound
	call	_strcmp
	jnc	.cmp

	mov	[tmp], eax

	stc
	jmp	.end

.notfound:
	clc

.end:	
	popad

	mov	edx, [tmp]
	
	ret

; _cmd_create_table:
; IN: eax - name, ebx - db ptr, ecx - columns number, edx - table column data, esi - row data size
; OUT: void
_cmd_create_table:
        pushad
        clc

	push	ecx				; store columns number
	mov	ebx, [ebx + db_s.ptr]
	xor	ecx, ecx
.cmp:
        cmp     ecx, MAX_TABLES_PER_DB
        jz      .full

        cmp     dword [ebx], 0
        jz      .allowed

        add     ebx, 88h                        ; 128d + 4 + 4
        inc     ecx
	jmp	.cmp

.full:
        stc
        pop     ecx	
	
	popad
	ret

.allowed:
        pop	ecx				; get columns number
        mov     [ebx + table_s.colnum], ecx

	push	esi
	push	esi

        ; set table name        
        mov     esi, eax
        lea     edi, [ebx + table_s.name]
        call    _strcpy

	pop	eax

	push	ecx
	; allocate space for column headers: 1byte + Col.Number * 128( 4+124 = col size + col name )
	shl	ecx, 7
	add	ecx, 8			; add 2 bytes ( col number ) + 2 bytes ( col size ) + 4 bytes ( table size ) 
	
        ; allocate space for ( columns size (esi) * max rows per table 1024 )
        shl     eax, 0Ah	
	add	eax, ecx
	
	push	eax			; store table size
	push	edx			; malloc flushes edx
        push    eax
        call    _malloc
        add     esp, 4
        mov     [ebx + table_s.ptr], eax

	; ready to create columns
	pop	edx			; column's size/name
	pop	ebx			; load table size
	pop	ecx			; columns number

	mov	word [eax], cx		; 2 bytes, columns count
	add	eax, 2			; eax+2: column position

	pop	esi

	push	ebx
	mov	ebx, esi
	mov	word [eax], bx		; 2 bytes, row data size
	pop	ebx
	add	eax, 2

	mov	dword [eax], ebx	; 4 bytes, table size
	add   	eax, 4
	push	eax
	add	eax, 4			; FIXME: add this to table malloc; table data start address


.newcolumn:
	test	ecx, ecx
	jz	.done	
	dec	ecx

	mov	esi, [edx]
	call	_strtoint
	mov	[eax], edi		; 32 bit int
	add	eax, 4
	add	edx, 4

	mov	esi, [edx]		; column name
	mov	edi, eax 
	call	_strcpy
	add	eax, 7Ch		; 124d
	add	edx, 4

	jmp	.newcolumn

.done:
	pop	ebx
	mov	[ebx], eax

        popad
        ret

; _cmd_create_db
; IN: esi - name, edx - databases pointer
; OUT: void
_cmd_create_db:
        pushad

	push	edx
        push    dword 84h                       ; sizeof(db_s): char 128 + int32 4 
        call    _malloc
        add     esp, 4
        mov     ebx, eax                        ; ebx = database ptr
	pop	edx

.store:
	mov	[edx], ebx			; store database pointer
		
        ; set db name
        lea     edi, [ebx + db_s.name]
        call    _strcpy

        ; allocate db tables array
        mov     ecx, 88h                        ; ( sizeof(tables_s) = (128 + 4 + 4) ) * 128 tables
        shl     ecx, 7                          ; ^^
        push    ecx
        call    _malloc
        add     esp, 4
        mov     dword [ebx + db_s.ptr], eax

.end:
        popad

        ret

	%INCLUDE	"memory.asm"
	%INCLUDE	"common.asm"	
