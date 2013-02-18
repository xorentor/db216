	extern	printf

segment         .data
debug_str 	db "DebStr: '%s'", 10, 0
debug_x 	db "DebHex: '%x'", 10, 0
debug_db         db "DebDec: '%d'", 10, 0

segment         .text

; _print:
; IN: EAX
; OUT: void
_print:
        pushad

        push    eax
        push    dword debug_str
        call    printf
        add     esp, 8

        popad
        ret

; _printx:
; IN: EAX
; OUT: void
_printx:
        pushad

        push    eax
        push    dword debug_x
        call    printf
        add     esp, 8

        popad
        ret

; _printdb:
; IN: EAX
; OUT: void
_printdb:
        pushad

        push    eax
        push    dword debug_db
        call    printf
        add     esp, 8

        popad
        ret

