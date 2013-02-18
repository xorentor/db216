%define		dbp		[ebp+0Ch]	; database's pointer
%define		errno		[ebp+10h]	; errno
%define		result		[ebp+14h]	; result

segment 	.data
dbtmp:		dd 0

segment		.bss

segment		.text

; _get_column_pos:
; IN: edi, eax
; OUT: ecx
_get_column_pos:
	pushad

	add	edi, 0ch
	xor	ecx, ecx
		
.loop:
	test	eax, eax
	jz	.end

	add	ecx, [edi]

	add	edi, 80h
	dec	eax
	jmp	.loop

.end:
	mov	[dbtmp], ecx
	popad
	mov	ecx, [dbtmp]
	ret

_cmd_insert:
	pushad

        mov     esi, [ebx+4]            ; db name
        mov     edx, dbp

        call    _cmd_get_db_ptr
        jnc     .end                    ; db name not found

        mov     esi, [ebx+8]         	; table name
        call    _cmd_get_table_ptr
        jnc     .end

	add	ebx, 0ch		; query arguments
.loop:
	cmp	dword [ebx], 0
	jz	.end

	mov	esi, [ebx]

	push	ebx
	mov	ebx, esi
	call	_strlen
	pop	ebx

	push	edx
	add	edx, 10h		; col name - first element
	xor	eax, eax
.table:
	cmp	dword [edx], 0
	jz	.next

	lea	edi, [edx]
	call	_strcmp
	jnc	.try

	pop	edi
	call	_get_column_pos
	call	_cmd_insert_row
	push	edi 
	jmp	.next

.try:
	inc	eax
	add	edx, 80h		; 128d ( 4 + 124 )
	jmp	.table

.next:
	pop	edx
	add	ebx, 8
	jmp	.loop

.end:
	popad
	ret

; _cmd_create:
; IN: ebx
; OUT: void
_cmd_create:
	pushad

.checkcreate:				; .create.database||table.test
	add	ebx, 4			; move to table||database

	mov	esi, [ebx]
	mov	edi, CMD_DATABASE
	mov	ecx, 8
	call	_strcmp
	jnc	.tablecreate
	add	ebx, 4			; move to database name
	cmp	byte [ebx], 0		; test first byte
	jz	.enddb
	mov	esi, [ebx]
	mov	edx, dbp
	call	_cmd_create_db		; create new database

.enddb:
	popad
	ret

.tablecreate:
	mov	edi, CMD_TABLE
	mov	ecx, 5
	call	_strcmp
	jnc	.end
	
	mov	esi, [ebx+4]		; db name
	mov	edx, dbp

	call	_cmd_get_db_ptr
	jnc	.end			; db name not found

	push	edx			; save db pointer
	lea	edx, [ebx+0Ch]		; arguments

	mov	eax, [ebx+8h]		; table name
	
	push	edx			; save query table arguments
	xor	ecx, ecx		; column count
	xor	esi, esi		; column size count

.colcnt:				
	cmp	dword [edx], 0
	jz	.createtable

	; FIXME
        ;push    eax
	push	esi
        mov     esi, [edx]
	call	_strtoint	
	;mov	[edx], edi		; replace string with int
	pop	esi

	add	esi, edi

	inc	ecx
	add	edx, 8			; add 2 x 4bytes ( column type, column name )
	jmp	.colcnt

.createtable:
	inc	esi			; table row size + 1 reserved byte

	pop	edx			; load query table arguments
	pop	ebx			; load db pointer

	call	_cmd_create_table

.end:
	popad
	ret

; _cmd_explain:
; IN: EBX
; OUT: void
_cmd_explain:
	pushad
	
        mov     esi, [ebx+8]            ; db name
        mov     edx, dbp

        call    _cmd_get_db_ptr
        jnc     .end                    ; db name not found

	mov	esi, [ebx+0Ch]		; table name
	call	_cmd_get_table_ptr
	jnc	.end

	mov	ebx, result
	call	_push_result_str

	; column count
	xor	eax, eax
	mov	ax, word [edx]
	mov	esi, eax
	call	_push_result_4B

	add	edx, 2

	; row data size
        xor     eax, eax
        mov     ax, word [edx]
	mov	esi, eax
        call    _push_result_4B

	add	edx, 2

	; table size
        mov     esi, [edx]
        call    _push_result_4B
	
	add	edx, 4

	mov	esi, [edx]
	call	_push_result_4B

	add	edx, 4


.column:
	cmp	dword [edx], 0
	jz	.end

	mov	eax, [edx]
	mov	esi, eax
	call	_push_result_4B
	add	edx, 4

	lea     eax, [edx + table_s.name]
	mov	esi, eax
	call	_push_result_str
	add	edx, 7Ch

	jmp	.column

.end:
	popad
	ret

; _parse_cmd:
; IN: ebx
; OUT: void
_parse_cmd:
	pushad

	add     ebx, 4                  ; bug from parser

        mov     esi, [ebx]
        mov     edi, CMD_CREATE
        mov     ecx, 6
        call    _strcmp
	jnc	.explain
	call	_cmd_create	
	jmp	.end

.explain:
        mov     edi, CMD_EXPLAIN
        mov     ecx, 7
        call    _strcmp
        jnc     .insert
        call    _cmd_explain
	jmp	.end

.insert:
	mov	edi, CMD_INSERT
	mov	ecx, 6
	call	_strcmp
	jnc	.error
	call	_cmd_insert
	jmp	.end

.error:
	mov	ebx, errno
	mov	esi, ERRNO_UNKNOWN_CMD
	call	_error

.end:	
	popad
	ret

; _dbmain
; IN: void
; OUT: void
	global _dbmain
_dbmain:
    	push 	ebp
    	mov  	ebp, esp

	; check for input string
	mov	ebx, [ebp+8]
	call	_strlen			; length of input
	test	ecx, ecx
	jz	.done

	; parse string
	call	_parsestr

	; execute
	call	_parse_cmd

	call	_free_array4b

.done:
    	mov  	esp, ebp
    	pop  	ebp

	ret

	%INCLUDE "core.asm"
	%INCLUDE "parse.asm"
