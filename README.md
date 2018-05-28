# Data Dictionary manager

## Oracle SQL and PL/SQL solution to manage General Data Dictionaries


## Why?

During data migration and data exchange between systems requires a so-called translation tables, which assigns the different kind of external and internal identifiers to each other.
This is a tipical task, so I created a general solution for that.

## How?

In the DDM we can define data value pairs and we can use them to translate identifiers in both way. 
The structure to define a data value pair is the following:

**system => object => attribute => value <=> value <= attribute <= object <= system**

We can give any name to the levels.  The only thing we have to use clear names, because we have to use these keys later at translations.

### Limits

- The name of systems, objects and attributes could be at most 200 char.
- The values of the attributes could be at most 2000 char.
- If he identifier data type is not varchar2, then it will be converted (casted) to varchar2.

### Tables and its columns

**SYSTEMS** 

The name of the systems. Practically at least 2. 

**OBJECTS**

The objects, tables within the system.

**ATTRIBUTES**

The attributes, column names within the object, tables.

**ATTRIBUTE_PAIRS**

Two (a pair) system-object-attribute assingment. This connects to the „A” structure to „B”. The order should  be important when we would like to define the direction later. 

**ATTRIBUTE_VALUE_PAIRS**

To an attribute pair we can add value pairs. We have to define both „A” and „B” value too. When the get_value function look for a value it can search exact or like way too. That means we can use mask chars here % or _ too.
For search function we can define case sensitivity or insensivity too, so keep this mind when we entering value pairs.



## How to use?

The following test demonstraits the way of usage

In the first step we have to fill up the tables (the description of procedures and functions are below):

    declare
        v_attribute_pair_id    NUMBER;
    begin

        -- two systems
        PKG_DDM.add_system( 'FARAWAY'  );
        PKG_DDM.add_system( 'HERE'     );

        -- 1 object for each system
        PKG_DDM.add_object( 'FARAWAY', 'MASTERAGREEMENTS');
        PKG_DDM.add_object( 'HERE'   , 'AGREEMENTS'      );
    
        -- 1 attribute for each object
        PKG_DDM.add_attribute( 'FARAWAY', 'MASTERAGREEMENTS', 'ID' );
        PKG_DDM.add_attribute( 'HERE'   , 'AGREEMENTS'      , 'ID' );
        
        -- those are in pair
        PKG_DDM.add_attribute_pair( 'FARAWAY','MASTERAGREEMENTS','ID', 'HERE','AGREEMENTS','ID' );
        
        -- get this pair's ID
        v_attribute_pair_id := PKG_DDM.get_attribute_pair_id( 'FARAWAY','MASTERAGREEMENTS','ID', 'HERE','AGREEMENTS','ID' );
        dbms_output.put_line(  v_attribute_pair_id );

        -- adding some value pairs:
        PKG_DDM.add_attribute_value_pair( v_attribute_pair_id, 1,  2 );
        PKG_DDM.add_attribute_value_pair( v_attribute_pair_id, 3,  4 );
        PKG_DDM.add_attribute_value_pair( v_attribute_pair_id, 'Apple',  'Pear' );
        PKG_DDM.add_attribute_value_pair( v_attribute_pair_id, '%thing', 'Anything'  );
    
    end;
    

Then check some translations:

    declare
        v_attribute_pair_id    NUMBER;
    begin
        v_attribute_pair_id := PKG_DDM.get_attribute_pair_id( 'FARAWAY','MASTERAGREEMENTS','ID' , 'HERE','AGREEMENTS','ID' );
        dbms_output.put_line(  v_attribute_pair_id );
        dbms_output.put_line( '-------------------------------------------------------------');
        dbms_output.put_line( 'test case  1: '|| PKG_DDM.get_attribute_value( v_attribute_pair_id, 1 ) );
        dbms_output.put_line( 'test case  2: '|| PKG_DDM.get_attribute_value( v_attribute_pair_id, 2 ) );
        dbms_output.put_line( 'test case  3: '|| PKG_DDM.get_attribute_value( v_attribute_pair_id, 3 ) );
        dbms_output.put_line( 'test case  4: '|| PKG_DDM.get_attribute_value( v_attribute_pair_id, 'Apple' ) );
        dbms_output.put_line( 'test case  5: '|| PKG_DDM.get_attribute_value( v_attribute_pair_id, 'Pear'  ) );
        dbms_output.put_line( 'test case  6: '|| PKG_DDM.get_attribute_value( v_attribute_pair_id, 'APPLE' ) );
        dbms_output.put_line( 'test case  7: '|| PKG_DDM.get_attribute_value( v_attribute_pair_id, 'APPLE' , i_case_sensitive => FALSE  ) );
        dbms_output.put_line( 'test case  8: '|| PKG_DDM.get_attribute_value( v_attribute_pair_id, 'PEAR'  , i_case_sensitive => FALSE  ) );
        dbms_output.put_line( 'test case  9: '|| PKG_DDM.get_attribute_value( v_attribute_pair_id, 'thing' , i_case_sensitive => FALSE, i_exact => FALSE  ) );
        dbms_output.put_line( 'test case 10: '|| PKG_DDM.get_attribute_value( v_attribute_pair_id, 'thing' , i_case_sensitive => FALSE, i_exact => FALSE, i_way =>'A2B'  ) );
        dbms_output.put_line( 'test case 11: '|| PKG_DDM.get_attribute_value( v_attribute_pair_id, ’thing' , i_case_sensitive => FALSE, i_exact => FALSE, i_way =>'B2A'  ) );
    end;

The result:

    7
    -------------------------------------------------------------
    test case  1: 2
    test case  2: 1
    test case  3: 4
    test case  4: Pear
    test case  5: Apple
    test case  6: 
    test case  7: Pear
    test case  8: Apple
    test case  9: Anything
    test case 10: Anything
    test case 11:


A typical usage:

    V_ITEM.TEAM_CODE := PKG_DDM.GET_ATTRIBUTE_VALUE( 
                            PKG_DDM.GET_ATTRIBUTE_PAIR_ID( 'SAP'      , 'TEAM' , 'ID'
                                                         , 'OURSYSTEM', 'TEAMS', 'CODE' 
                                                         )
                            , V_INPUT.ID
                            , 'A2B' );

--------------------------------------------------------------

## Procedures and Functions

Every procedure and function are in the **PKG_DDM** package.

There is not any explicite *COMMIT* or *ROLLBACK* in them! 

The levels can be defined by their names and not by IDs. The names will be used case insentive!

### Systems

    PROCEDURE add_system    ( i_system_name IN VARCHAR2 );
    PROCEDURE rename_system ( i_system_name IN VARCHAR2
                            , i_new_name    IN VARCHAR2 );
    PROCEDURE remove_system ( i_system_name IN VARCHAR2
                            , i_cascade     IN BOOLEAN := FALSE );
    FUNCTION  get_system_id ( i_system_name IN VARCHAR2 ) RETURN NUMBER;


### Objects

    PROCEDURE add_object    ( i_system_name IN VARCHAR2
                            , i_object_name IN VARCHAR2 );
    PROCEDURE rename_object ( i_system_name IN VARCHAR2
                            , i_object_name IN VARCHAR2
                            , i_new_name    IN VARCHAR2 );
    PROCEDURE remove_object ( i_system_name IN VARCHAR2
                            , i_object_name IN VARCHAR2
                            , i_cascade     IN BOOLEAN := FALSE );
    FUNCTION  get_object_id ( i_system_name IN VARCHAR2
                            , i_object_name IN VARCHAR2 ) RETURN NUMBER;

### Attributes

    PROCEDURE add_attribute   ( i_system_name    IN VARCHAR2
                              , i_object_name    IN VARCHAR2
                              , i_attribute_name IN VARCHAR2 );
    PROCEDURE rename_attribute( i_system_name    IN VARCHAR2
                              , i_object_name    IN VARCHAR2
                              , i_attribute_name IN VARCHAR2
                              , i_new_name       IN VARCHAR2 );
    PROCEDURE remove_attribute( i_system_name    IN VARCHAR2
                              , i_object_name    IN VARCHAR2
                              , i_attribute_name IN VARCHAR2
                              , i_cascade        IN BOOLEAN := FALSE );
    FUNCTION  get_attribute_id( i_system_name    IN VARCHAR2
                              , i_object_name    IN VARCHAR2
                              , i_attribute_name IN VARCHAR2 ) RETURN NUMBER;


### Attribute pair

The **i_way** may be important at lookup. Possible values: 'A2B', 'B2A' or null = both.


    PROCEDURE   add_attribute_pair     ( i_a_system_name       IN VARCHAR2
                                       , i_a_object_name       IN VARCHAR2
                                       , i_a_attribute_name    IN VARCHAR2 
                                       , i_b_system_name       IN VARCHAR2 
                                       , i_b_object_name       IN VARCHAR2 
                                       , i_b_attribute_name    IN VARCHAR2 
                                       );
    PROCEDURE   remove_attribute_pair  ( i_a_system_name       IN VARCHAR2
                                       , i_a_object_name       IN VARCHAR2 
                                       , i_a_attribute_name    IN VARCHAR2 
                                       , i_b_system_name       IN VARCHAR2 
                                       , i_b_object_name       IN VARCHAR2 
                                       , i_b_attribute_name    IN VARCHAR2 
                                       , i_way                 IN VARCHAR2 := NULL   
                                       , i_cascade             IN BOOLEAN  := FALSE
                                       );
    FUNCTION    get_attribute_pair_id ( i_a_system_name       IN VARCHAR2
                                      , i_a_object_name       IN VARCHAR2 
                                      , i_a_attribute_name    IN VARCHAR2 
                                      , i_b_system_name       IN VARCHAR2 
                                      , i_b_object_name       IN VARCHAR2 
                                      , i_b_attribute_name    IN VARCHAR2
                                      , i_way                 IN VARCHAR2 := NULL    
                                      ) RETURN NUMBER;



### Attribute value pairs
The following procedures can manage the value pairs for a certain attribute pair.
The **get_attribute_value** function is the essence of the DDM! It returns a value pair of the given value.
Additional parameters for translation:

- *i_way*: 'A2B', 'B2A' or null = both/any direction
- *i_exact*: 'true' only exact match, 'false' means "like" 
- *i_case_sensitive*: implicitly

Procedures and Function:

    PROCEDURE   add_attribute_value_pair   ( i_attribute_pair_id  IN NUMBER
                                           , i_a_value            IN VARCHAR2
                                           , i_b_value            IN VARCHAR2
                                           );
    PROCEDURE   remove_attribute_value_pair( i_attribute_pair_id  IN NUMBER
                                           , i_a_value            IN VARCHAR2
                                           , i_b_value            IN VARCHAR2
                                           );
    FUNCTION    get_attribute_value        ( i_attribute_pair_id  IN NUMBER
                                           , i_value              IN VARCHAR2
                                           , i_way                IN VARCHAR2 := NULL
                                           , i_exact              IN BOOLEAN  := TRUE
                                           , i_case_sensitive     IN BOOLEAN  := TRUE 
                                           ) RETURN VARCHAR2;


## Views

For the readability and security reasons we use views instead of tables to select the data. To edit tables we use the package procedures.

**V_SYSTEMS** The system names and IDs.

**V_OBJECTS** The object names and IDs with their system names and IDs.

**V_ATTRIBUTES** The attribute names and Ids with their object and system names and IDs.

**V_ATTRIBUTE_PAIRS** The attributes pairs with their full path and the view shows both direction ’A2B’ and  ’B2A’ too.

**V_ATTRIBUTE_VALUE_PAIRS** The **V_ATTRIBUTE_PAIRS** extended with the Value pairs. The both way.

