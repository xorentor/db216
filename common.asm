segment		.data
CMD_CREATE		db "create", 0
CMD_INSERT              db "insert", 0
CMD_DELETE              db "delete", 0
CMD_DATABASE		db "database", 0
CMD_TABLE		db "table", 0
CMD_EXPLAIN		db "explain", 0

segment 	.text

struc db_s
        .name           resb 128
        .ptr       	resd 1
endstruc

struc table_s
	.name		resb 128
	.ptr		resd 1
	.colnum		resd 1
endstruc

MAX_TABLES_PER_DB       equ 128

ERRNO_UNKNOWN_CMD       equ 100
ERRNO_UNKNOWN_DB	equ 101
ERRNO_UNKONWN_TABLE	equ 102
