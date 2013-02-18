#include "App.h"

void App::clean_errno()
{
        for( int i = 0; i < MAX_ERRNO; i++ )
        {
                errno[i] ^= errno[i];
        }
}

void App::clean_result()
{
        for( int i = 0; i < MAX_QUERY_RESULT; i++ )
        {
                result[i] ^= result[i];
        }
}

void App::dealloc_result()
{
        for( int i = 0; i < MAX_QUERY_RESULT; i++ )
        {
		if( result[i] != 0 )
		{
			free( (void*)result[i] );
			result[i] ^= result[i];
		}
        }
}

void App::query( const char *q )
{
	clean_errno();
	dealloc_result();
	
        _dbmain( q, databases, errno, result );

        for( int i = 0; i < MAX_ERRNO; i++ )
                if( errno[i] > 0 )
                        std::cout << errno[i] << std::endl;


	if( result[0] == 0 )
		return;

	std::cout << "Table name: " << (char*)result[0] << std::endl;

	if( result[1] != 0 && result[2] != 0 && result[3] != 0 && result[4] != 0 ) 
	{
		std::cout << "Columns number: " << *(int*)(result[1]) << std::endl;
		std::cout << "Row size(Bytes): " << *(int*)(result[2]) << std::endl;
		std::cout << "Table size(Bytes): " << *(int*)(result[3]) << std::endl;
		std::cout << "Table data start addr: " << *(int*)(result[4]) << std::endl;
	}

        for( int i = 5; i < MAX_QUERY_RESULT; i+=2 )
	{
                if( result[i] != 0 ) 
		{
                        std::cout << "Column size: " << *(int*)(result[i]) << std::endl;
			std::cout << "Column name: " << (char*)(result[i+1]) << std::endl;
		}
	}
}
