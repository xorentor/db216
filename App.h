#ifndef APP_H
#define APP_H

#include <iostream>
#include <malloc.h>

#include "Common.h"

extern "C" void _dbmain( const char*, int*, int[MAX_ERRNO], int[MAX_QUERY_RESULT] );

class App {
public:
	App() {};
	virtual ~App() {};

public:
	void clean_errno();
	void clean_result();
	void dealloc_result();
	void query( const char *q );
	
	int result[MAX_QUERY_RESULT];

private:
	int databases[8];
	int errno[MAX_ERRNO];
};

#endif
