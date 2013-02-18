#ifndef __COMMON
#define __COMMON

#define			MAX_ERRNO		8
#define			IS_DEBUG		1
#define			DISPLAY_ERRNO		1
#define			MAX_QUERY_RESULT	(1<<5)

#define         	db216_ui8       uint8_t
#define			db216_ui16	uint16_t
#define			db216_ui32	uint32_t
#define        		db216_ui64      uint64_t

#define			TYPE_UINT_16	"uint16"
#define         	TYPE_UINT_32    "uint32"
#define         	TYPE_UINT_64    "uint64"
#define			TYPE_CHAR	"char"
#define			TYPE_BOOL	"bool"

#define			CMD_INSERT		"insert"
#define			CMD_SELECT		"select"
#define			CMD_DELETE_EQUAL 	"equal"
#define			CMD_DELETE_NOTEQUAL	"notequal"
#define			CMD_DELETE		"delete"

#define 		ROUND8(x)    	(((x)+7)&~7)
#define 		ROUNDDOWN8(x) 	((x)&~7)

#define			MAX_DB		0x8

extern "C" inline char 		***asm_parsestr( char *, const int );

extern "C" inline int		create_db( const char* );
//extern "C" inline int		asm_strcmp( const char *, const char * );
//extern "C" inline int		asm_strlen( const char * );

inline static int	asm_strcmp( const char *s, const char *d, const int c )
{
        int r;
        __asm__ __volatile__
        (
                "testl  %%eax, %%eax;"
                "jz     .cmpf;"
                "testl  %%ebx, %%ebx;"
                "jz     .cmpf;"
                "mov    %%eax, %%esi;"
                "mov    %%ebx, %%edi;"
                "cld;"
                "repe   cmpsb;"
                "je     .cmpt;"
                ".cmpf:;"
                "movl   $1, %%eax;"
                "jmp    .cmpend;"
                ".cmpt:;"
                "xorl   %%eax, %%eax;"
                ".cmpend:;"
                : "=a"(r)
                : "a"(s), "b"(d), "c"(c)
        );
        return r;
}

inline static int 	asm_strlen( const char *s )
{
        int r;
        __asm__ __volatile__
        (       "xorl   %%ecx, %%ecx;"
		"testl	%%ebx, %%ebx;"
		"jz	.lenend;"
                ".len:;"
                "cmpb   $0, (%%ebx);"
                "je     .lenend;"
                "incl   %%ebx;"
                "incl   %%ecx;"
                "jmp    .len;"
                ".lenend:;"
                : "=c"(r)
                : "b"(s)
        );
        return r;
}

#endif
