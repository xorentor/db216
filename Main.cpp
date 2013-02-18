#include "App.h"

int main()
{
        App app;

        app.clean_errno();
	app.clean_result();
	
        app.query( ".create.database.dbname" );

        app.query( ".create.table.dbname.table1.2.int16.128.address1.256.description" );

        app.query( ".explain.table.dbname.table1" );

	app.query( ".insert.dbname.table1.description.873.address1.hi this is nice" );

        app.query( ".test.one.two" );

	return 0;
}
