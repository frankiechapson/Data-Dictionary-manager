/************************************************************
    Author  :   Ferenc Toth
    Remark  :   Data Dictionary Manager
    Date    :   2015.07.01
************************************************************/



Prompt *****************************************************************
Prompt **          I N S T A L L I N G   D D M G R                    **
Prompt *****************************************************************


/*============================================================================================*/
CREATE SEQUENCE DD_SEQ_ID
/*============================================================================================*/
    INCREMENT BY        1
    MINVALUE            1
    MAXVALUE   9999999999
    START WITH       1000
    CYCLE
    NOCACHE;



Prompt *****************************************************************
Prompt **                        T A B L E S                          **
Prompt *****************************************************************


/*============================================================================================*/
CREATE TABLE DD_SYSTEMS (
/*============================================================================================*/
    ID                              NUMBER   (   10 )   CONSTRAINT DD_SYSTEMS_NN1 NOT NULL,
    NAME                            VARCHAR2 (  500 )   CONSTRAINT DD_SYSTEMS_NN2 NOT NULL
  );

ALTER TABLE DD_SYSTEMS ADD CONSTRAINT DD_SYSTEMS_PK  PRIMARY KEY ( ID );


/*============================================================================================*/
CREATE OR REPLACE TRIGGER TR_DD_SYSTEMS_BIR
/*============================================================================================*/
  BEFORE INSERT ON DD_SYSTEMS FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN 
        :NEW.ID := DD_SEQ_ID.NEXTVAL; 
    END IF;
END;
/



/*============================================================================================*/
CREATE TABLE DD_OBJECTS (
/*============================================================================================*/
    ID                              NUMBER   (  10 )   CONSTRAINT DD_OBJECTS_NN1 NOT NULL,
    SYSTEM_ID                       NUMBER   (  10 )   CONSTRAINT DD_OBJECTS_NN2 NOT NULL,
    NAME                            VARCHAR2 ( 500 )   CONSTRAINT DD_OBJECTS_NN3 NOT NULL
  );

ALTER TABLE DD_OBJECTS ADD CONSTRAINT DD_OBJECTS_PK  PRIMARY KEY ( ID );
ALTER TABLE DD_OBJECTS ADD CONSTRAINT DD_OBJECTS_FK1 FOREIGN KEY ( SYSTEM_ID ) REFERENCES DD_SYSTEMS ( ID );

CREATE INDEX DD_OBJECTS_IX1 ON DD_OBJECTS ( SYSTEM_ID ) ;

/*============================================================================================*/
CREATE OR REPLACE TRIGGER TR_DD_OBJECTS_BIR
/*============================================================================================*/
  BEFORE INSERT ON DD_OBJECTS FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN 
        :NEW.ID := DD_SEQ_ID.NEXTVAL; 
    END IF;
END;
/



/*============================================================================================*/
CREATE TABLE DD_ATTRIBUTES (
/*============================================================================================*/
    ID                              NUMBER   (  10 )   CONSTRAINT DD_ATTRIBUTES_NN1 NOT NULL,
    OBJECT_ID                       NUMBER   (  10 )   CONSTRAINT DD_ATTRIBUTES_NN2 NOT NULL,
    NAME                            VARCHAR2 ( 500 )   CONSTRAINT DD_ATTRIBUTES_NN3 NOT NULL
  );

ALTER TABLE DD_ATTRIBUTES ADD CONSTRAINT DD_ATTRIBUTES_PK  PRIMARY KEY ( ID );
ALTER TABLE DD_ATTRIBUTES ADD CONSTRAINT DD_ATTRIBUTES_FK1 FOREIGN KEY ( OBJECT_ID ) REFERENCES DD_OBJECTS ( ID );

CREATE INDEX DD_ATTRIBUTES_IX1 ON DD_ATTRIBUTES ( OBJECT_ID ) ;


/*============================================================================================*/
CREATE OR REPLACE TRIGGER TR_DD_ATTRIBUTES_BIR
/*============================================================================================*/
  BEFORE INSERT ON DD_ATTRIBUTES FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN 
        :NEW.ID := DD_SEQ_ID.NEXTVAL; 
    END IF;
END;
/

/*============================================================================================*/
CREATE TABLE DD_ATTRIBUTE_PAIRS (
/*============================================================================================*/
    ID                              NUMBER   (  10 )   CONSTRAINT DD_ATTRIBUTE_PAIRS_NN1 NOT NULL,
    A_ATTRIBUTE_ID                  NUMBER   (  10 )   CONSTRAINT DD_ATTRIBUTE_PAIRS_NN2 NOT NULL,
    B_ATTRIBUTE_ID                  NUMBER   (  10 )   CONSTRAINT DD_ATTRIBUTE_PAIRS_NN3 NOT NULL
  );


ALTER TABLE DD_ATTRIBUTE_PAIRS ADD CONSTRAINT DD_ATTRIBUTE_PAIRS_PK  PRIMARY KEY ( ID );
ALTER TABLE DD_ATTRIBUTE_PAIRS ADD CONSTRAINT DD_ATTRIBUTE_PAIRS_FK1 FOREIGN KEY ( A_ATTRIBUTE_ID ) REFERENCES DD_ATTRIBUTES ( ID );
ALTER TABLE DD_ATTRIBUTE_PAIRS ADD CONSTRAINT DD_ATTRIBUTE_PAIRS_FK2 FOREIGN KEY ( B_ATTRIBUTE_ID ) REFERENCES DD_ATTRIBUTES ( ID );

CREATE INDEX DD_ATTRIBUTE_PAIRS_IX1 ON DD_ATTRIBUTE_PAIRS ( A_ATTRIBUTE_ID ) ;
CREATE INDEX DD_ATTRIBUTE_PAIRS_IX2 ON DD_ATTRIBUTE_PAIRS ( B_ATTRIBUTE_ID ) ;


/*============================================================================================*/
CREATE OR REPLACE TRIGGER TR_DD_ATTRIBUTE_PAIRS_BIR
/*============================================================================================*/
  BEFORE INSERT ON DD_ATTRIBUTE_PAIRS FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN 
        :NEW.ID := DD_SEQ_ID.NEXTVAL; 
    END IF;
END;
/


/*============================================================================================*/
CREATE TABLE DD_ATTRIBUTE_VALUE_PAIRS (
/*============================================================================================*/
    ID                              NUMBER  (   10 )   CONSTRAINT DD_ATTRIBUTE_VALUE_PAIRS_NN1 NOT NULL,
    ATTRIBUTE_PAIR_ID               NUMBER  (   10 )   CONSTRAINT DD_ATTRIBUTE_VALUE_PAIRS_NN2 NOT NULL,
    A_ATTRIBUTE_VALUE               VARCHAR2( 2000 )   CONSTRAINT DD_ATTRIBUTE_VALUE_PAIRS_NN3 NOT NULL,
    B_ATTRIBUTE_VALUE               VARCHAR2( 2000 )   CONSTRAINT DD_ATTRIBUTE_VALUE_PAIRS_NN4 NOT NULL
  );


ALTER TABLE DD_ATTRIBUTE_VALUE_PAIRS ADD CONSTRAINT DD_ATTRIBUTE_VALUE_PAIRS_PK  PRIMARY KEY ( ID );
ALTER TABLE DD_ATTRIBUTE_VALUE_PAIRS ADD CONSTRAINT DD_ATTRIBUTE_VALUE_PAIRS_FK1 FOREIGN KEY ( ATTRIBUTE_PAIR_ID ) REFERENCES DD_ATTRIBUTE_PAIRS ( ID );

CREATE INDEX DD_ATTRIBUTE_VALUE_PAIRS_IX1 ON DD_ATTRIBUTE_VALUE_PAIRS ( ATTRIBUTE_PAIR_ID ) ;
CREATE INDEX DD_ATTRIBUTE_VALUE_PAIRS_IX2 ON DD_ATTRIBUTE_VALUE_PAIRS ( A_ATTRIBUTE_VALUE ) ;
CREATE INDEX DD_ATTRIBUTE_VALUE_PAIRS_IX3 ON DD_ATTRIBUTE_VALUE_PAIRS ( B_ATTRIBUTE_VALUE ) ;
CREATE UNIQUE INDEX DD_ATTRIBUTE_VALUE_PAIRS_IX4 ON DD_ATTRIBUTE_VALUE_PAIRS ( ATTRIBUTE_PAIR_ID, A_ATTRIBUTE_VALUE, B_ATTRIBUTE_VALUE ) ;
CREATE UNIQUE INDEX DD_ATTRIBUTE_VALUE_PAIRS_IX5 ON DD_ATTRIBUTE_VALUE_PAIRS ( ATTRIBUTE_PAIR_ID, B_ATTRIBUTE_VALUE, A_ATTRIBUTE_VALUE ) ;


/*============================================================================================*/
CREATE OR REPLACE TRIGGER TR_DD_ATTRIBUTE_VALUE_PAIR_BIR
/*============================================================================================*/
  BEFORE INSERT ON DD_ATTRIBUTE_VALUE_PAIRS FOR EACH ROW
BEGIN
    IF :NEW.ID IS NULL THEN 
        :NEW.ID := DD_SEQ_ID.NEXTVAL; 
    END IF;
END;
/



Prompt *****************************************************************
Prompt **                         V I E W S                           **
Prompt *****************************************************************

CREATE OR REPLACE VIEW DD_SYSTEMS_VW AS
SELECT *
  FROM DD_SYSTEMS
;

CREATE OR REPLACE VIEW DD_OBJECTS_VW AS
SELECT DD_OBJECTS.ID           AS ID
     , DD_SYSTEMS.ID           AS SYSTEM_ID
     , DD_SYSTEMS.NAME         AS SYSTEM_NAME
     , DD_OBJECTS.NAME         AS NAME
  FROM DD_SYSTEMS             
     , DD_OBJECTS             
 WHERE DD_OBJECTS.SYSTEM_ID   = DD_SYSTEMS.ID
;

CREATE OR REPLACE VIEW DD_ATTRIBUTES_VW AS
SELECT DD_ATTRIBUTES.ID        AS ID
     , DD_SYSTEMS.ID           AS SYSTEM_ID
     , DD_SYSTEMS.NAME         AS SYSTEM_NAME
     , DD_OBJECTS.ID           AS OBJECT_ID
     , DD_OBJECTS.NAME         AS OBJECT_NAME
     , DD_ATTRIBUTES.NAME      AS NAME
  FROM DD_SYSTEMS             
     , DD_OBJECTS             
     , DD_ATTRIBUTES
 WHERE DD_OBJECTS.SYSTEM_ID     = DD_SYSTEMS.ID
   AND DD_ATTRIBUTES.OBJECT_ID  = DD_OBJECTS.ID
;


CREATE OR REPLACE VIEW DD_ATTRIBUTE_PAIRS_VW AS
SELECT 'A2B'                AS WAY
     , DD_ATTRIBUTE_PAIRS.ID   AS ID
     , A_DD_SYSTEMS.ID         AS A_SYSTEM_ID
     , A_DD_SYSTEMS.NAME       AS A_SYSTEM_NAME
     , A_DD_OBJECTS.ID         AS A_OBJECT_ID
     , A_DD_OBJECTS.NAME       AS A_OBJECT_NAME
     , A_DD_ATTRIBUTES.ID      AS A_ATTRIBUTE_ID
     , A_DD_ATTRIBUTES.NAME    AS A_ATTRIBUTE_NAME
     , B_DD_SYSTEMS.ID         AS B_SYSTEM_ID
     , B_DD_SYSTEMS.NAME       AS B_SYSTEM_NAME
     , B_DD_OBJECTS.ID         AS B_OBJECT_ID
     , B_DD_OBJECTS.NAME       AS B_OBJECT_NAME
     , B_DD_ATTRIBUTES.ID      AS B_ATTRIBUTE_ID
     , B_DD_ATTRIBUTES.NAME    AS B_ATTRIBUTE_NAME
  FROM DD_SYSTEMS              A_DD_SYSTEMS
     , DD_OBJECTS              A_DD_OBJECTS
     , DD_ATTRIBUTES           A_DD_ATTRIBUTES
     , DD_SYSTEMS              B_DD_SYSTEMS
     , DD_OBJECTS              B_DD_OBJECTS
     , DD_ATTRIBUTES           B_DD_ATTRIBUTES
     , DD_ATTRIBUTE_PAIRS
 WHERE DD_ATTRIBUTE_PAIRS.A_ATTRIBUTE_ID  = A_DD_ATTRIBUTES.ID
   AND A_DD_ATTRIBUTES.OBJECT_ID          = A_DD_OBJECTS.ID
   AND A_DD_OBJECTS.SYSTEM_ID             = A_DD_SYSTEMS.ID
   AND DD_ATTRIBUTE_PAIRS.B_ATTRIBUTE_ID  = B_DD_ATTRIBUTES.ID
   AND B_DD_ATTRIBUTES.OBJECT_ID          = B_DD_OBJECTS.ID
   AND B_DD_OBJECTS.SYSTEM_ID             = B_DD_SYSTEMS.ID
UNION ALL
SELECT 'B2A'                AS WAY
     , DD_ATTRIBUTE_PAIRS.ID   AS ID
     , B_DD_SYSTEMS.ID         AS A_SYSTEM_ID
     , B_DD_SYSTEMS.NAME       AS A_SYSTEM_NAME
     , B_DD_OBJECTS.ID         AS A_OBJECT_ID
     , B_DD_OBJECTS.NAME       AS A_OBJECT_NAME
     , B_DD_ATTRIBUTES.ID      AS A_ATTRIBUTE_ID
     , B_DD_ATTRIBUTES.NAME    AS A_ATTRIBUTE_NAME
     , A_DD_SYSTEMS.ID         AS B_SYSTEM_ID
     , A_DD_SYSTEMS.NAME       AS B_SYSTEM_NAME
     , A_DD_OBJECTS.ID         AS B_OBJECT_ID
     , A_DD_OBJECTS.NAME       AS B_OBJECT_NAME
     , A_DD_ATTRIBUTES.ID      AS B_ATTRIBUTE_ID
     , A_DD_ATTRIBUTES.NAME    AS B_ATTRIBUTE_NAME
  FROM DD_SYSTEMS              A_DD_SYSTEMS
     , DD_OBJECTS              A_DD_OBJECTS
     , DD_ATTRIBUTES           A_DD_ATTRIBUTES
     , DD_SYSTEMS              B_DD_SYSTEMS
     , DD_OBJECTS              B_DD_OBJECTS
     , DD_ATTRIBUTES           B_DD_ATTRIBUTES
     , DD_ATTRIBUTE_PAIRS
 WHERE DD_ATTRIBUTE_PAIRS.A_ATTRIBUTE_ID  = A_DD_ATTRIBUTES.ID
   AND A_DD_ATTRIBUTES.OBJECT_ID          = A_DD_OBJECTS.ID
   AND A_DD_OBJECTS.SYSTEM_ID             = A_DD_SYSTEMS.ID
   AND DD_ATTRIBUTE_PAIRS.B_ATTRIBUTE_ID  = B_DD_ATTRIBUTES.ID
   AND B_DD_ATTRIBUTES.OBJECT_ID          = B_DD_OBJECTS.ID
   AND B_DD_OBJECTS.SYSTEM_ID             = B_DD_SYSTEMS.ID
;


CREATE OR REPLACE VIEW DD_ATTRIBUTE_VALUE_PAIRS_VW AS
SELECT DD_ATTRIBUTE_PAIRS_VW.*
     , DD_ATTRIBUTE_VALUE_PAIRS.A_ATTRIBUTE_VALUE
     , DD_ATTRIBUTE_VALUE_PAIRS.B_ATTRIBUTE_VALUE
  FROM DD_ATTRIBUTE_PAIRS_VW
     , DD_ATTRIBUTE_VALUE_PAIRS
 WHERE WAY = 'A2B'
   AND DD_ATTRIBUTE_PAIRS_VW.ID = DD_ATTRIBUTE_VALUE_PAIRS.ATTRIBUTE_PAIR_ID
UNION ALL
SELECT DD_ATTRIBUTE_PAIRS_VW.*
     , DD_ATTRIBUTE_VALUE_PAIRS.B_ATTRIBUTE_VALUE
     , DD_ATTRIBUTE_VALUE_PAIRS.A_ATTRIBUTE_VALUE
  FROM DD_ATTRIBUTE_PAIRS_VW
     , DD_ATTRIBUTE_VALUE_PAIRS
 WHERE WAY = 'B2A'
   AND DD_ATTRIBUTE_PAIRS_VW.ID = DD_ATTRIBUTE_VALUE_PAIRS.ATTRIBUTE_PAIR_ID
;




Prompt *****************************************************************
Prompt **                       P A C K A G E                         **
Prompt *****************************************************************

CREATE OR REPLACE PACKAGE PKG_DDM IS

    --------------------------------------------------------------------------------------------------------------------

    PROCEDURE   add_system          ( i_system_name IN VARCHAR2                                 );
    PROCEDURE   rename_system       ( i_system_name IN VARCHAR2, i_new_name IN VARCHAR2         );
    PROCEDURE   remove_system       ( i_system_name IN VARCHAR2, i_cascade  IN BOOLEAN := FALSE );
    FUNCTION    get_system_id       ( i_system_name IN VARCHAR2                                 ) RETURN NUMBER;

    --------------------------------------------------------------------------------------------------------------------

    PROCEDURE   add_object          ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2                                 );
    PROCEDURE   rename_object       ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2, i_new_name IN VARCHAR2         );
    PROCEDURE   remove_object       ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2, i_cascade  IN BOOLEAN := FALSE );
    FUNCTION    get_object_id       ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2                                 ) RETURN NUMBER;

    --------------------------------------------------------------------------------------------------------------------

    PROCEDURE   add_attribute       ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2, i_attribute_name IN VARCHAR2                                 );
    PROCEDURE   rename_attribute    ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2, i_attribute_name IN VARCHAR2, i_new_name IN VARCHAR2         );
    PROCEDURE   remove_attribute    ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2, i_attribute_name IN VARCHAR2, i_cascade  IN BOOLEAN := FALSE );
    FUNCTION    get_attribute_id    ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2, i_attribute_name IN VARCHAR2                                 ) RETURN NUMBER;

    --------------------------------------------------------------------------------------------------------------------

    PROCEDURE   add_attribute_pair  ( i_a_system_name       IN VARCHAR2, 
                                      i_a_object_name       IN VARCHAR2, 
                                      i_a_attribute_name    IN VARCHAR2, 
                                      i_b_system_name       IN VARCHAR2, 
                                      i_b_object_name       IN VARCHAR2, 
                                      i_b_attribute_name    IN VARCHAR2 
                                    );

    PROCEDURE   remove_attribute_pair  ( i_a_system_name       IN VARCHAR2, 
                                         i_a_object_name       IN VARCHAR2, 
                                         i_a_attribute_name    IN VARCHAR2, 
                                         i_b_system_name       IN VARCHAR2, 
                                         i_b_object_name       IN VARCHAR2, 
                                         i_b_attribute_name    IN VARCHAR2, 
                                         i_way                 IN VARCHAR2 := NULL,    -- null = both, or 'A2B' or 'B2A'
                                         i_cascade             IN BOOLEAN  := FALSE
                                       );

    FUNCTION    get_attribute_pair_id ( i_a_system_name       IN VARCHAR2, 
                                        i_a_object_name       IN VARCHAR2, 
                                        i_a_attribute_name    IN VARCHAR2, 
                                        i_b_system_name       IN VARCHAR2, 
                                        i_b_object_name       IN VARCHAR2, 
                                        i_b_attribute_name    IN VARCHAR2,
                                        i_way                 IN VARCHAR2 := NULL    -- null = both, or 'A2B' or 'B2A'
                                      ) RETURN NUMBER;

    --------------------------------------------------------------------------------------------------------------------

    PROCEDURE   add_attribute_value_pair  ( i_attribute_pair_id  IN NUMBER,
                                            i_a_value            IN VARCHAR2, 
                                            i_b_value            IN VARCHAR2
                                          );

    PROCEDURE   remove_attribute_value_pair( i_attribute_pair_id  IN NUMBER,
                                             i_a_value            IN VARCHAR2, 
                                             i_b_value            IN VARCHAR2
                                           );

    FUNCTION    get_attribute_value ( i_attribute_pair_id  IN NUMBER,
                                      i_value              IN VARCHAR2,
                                      i_way                IN VARCHAR2 := NULL,    -- null = both, or 'A2B' or 'B2A'
                                      i_exact              IN BOOLEAN  := TRUE,    -- true = use exact match eg "=", false = use "like"
                                      i_case_sensitive     IN BOOLEAN  := TRUE     -- false = use UPPER before comparison
                                    )  RETURN VARCHAR2;

    --------------------------------------------------------------------------------------------------------------------

END PKG_DDM;
/


CREATE OR REPLACE PACKAGE BODY PKG_DDM IS


    /****************************************/
    /**************   SYSTEM   **************/
    /****************************************/

    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   add_system    ( i_system_name IN VARCHAR2 ) IS
    --------------------------------------------------------------------------------------------------------------------
    BEGIN
        INSERT INTO DD_SYSTEMS ( id, name ) VALUES ( DD_SEQ_ID.NEXTVAL, UPPER( i_system_name ) );
    END;


    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   rename_system ( i_system_name IN VARCHAR2, i_new_name IN VARCHAR2 ) IS
    --------------------------------------------------------------------------------------------------------------------
    BEGIN
        UPDATE DD_SYSTEMS SET name = UPPER( i_new_name ) WHERE id = get_system_id( i_system_name );
    END;


    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   remove_system ( i_system_name IN VARCHAR2, i_cascade IN BOOLEAN := FALSE ) IS
    --------------------------------------------------------------------------------------------------------------------
        v_id      NUMBER;
    BEGIN
        v_id := get_system_id( i_system_name);
        IF i_cascade THEN
            FOR l_r IN ( SELECT * FROM DD_OBJECTS WHERE system_id = v_id ) LOOP
                remove_object( i_system_name, l_r.name, i_cascade => TRUE );
            END LOOP;
        END IF;
        DELETE DD_SYSTEMS WHERE id = v_id;
    END;


    --------------------------------------------------------------------------------------------------------------------
    FUNCTION   get_system_id  ( i_system_name IN VARCHAR2 ) RETURN NUMBER IS
    --------------------------------------------------------------------------------------------------------------------
        v_id    NUMBER;
    BEGIN
        SELECT MIN ( id ) INTO v_id FROM DD_SYSTEMS WHERE name = UPPER ( i_system_name );
        RETURN v_id;
    END;


    /****************************************/
    /**************   OBJECT   **************/
    /****************************************/

    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   add_object    ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2 ) IS
    --------------------------------------------------------------------------------------------------------------------
    BEGIN
        INSERT INTO DD_OBJECTS ( id, system_id, name ) VALUES ( DD_SEQ_ID.NEXTVAL, get_system_id( i_system_name ), UPPER( i_object_name ) );
    END;


    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   rename_object ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2, i_new_name IN VARCHAR2         ) IS
    --------------------------------------------------------------------------------------------------------------------
    BEGIN
        UPDATE DD_OBJECTS SET name = UPPER( i_new_name ) WHERE id = get_object_id( i_system_name, i_object_name );
    END;


    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   remove_object ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2, i_cascade  IN BOOLEAN := FALSE ) IS
    --------------------------------------------------------------------------------------------------------------------
        v_id      NUMBER;
    BEGIN
        v_id := get_object_id( i_system_name, i_object_name );
        IF i_cascade THEN
            FOR l_r IN ( SELECT * FROM DD_ATTRIBUTES WHERE object_id = v_id ) LOOP
                remove_attribute( i_system_name, i_object_name, l_r.name, i_cascade => TRUE );
            END LOOP;
        END IF;
        DELETE DD_OBJECTS WHERE id = v_id;
    END;


    --------------------------------------------------------------------------------------------------------------------
    FUNCTION    get_object_id ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2 ) RETURN NUMBER IS
    --------------------------------------------------------------------------------------------------------------------
        v_id    NUMBER;
    BEGIN
        SELECT MIN ( id ) INTO v_id FROM DD_OBJECTS_VW WHERE system_name = UPPER( i_system_name ) AND name = UPPER ( i_object_name );
        RETURN v_id;
    END;


    /*******************************************/
    /**************   ATTRIBUTE   **************/
    /*******************************************/

    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   add_attribute       ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2, i_attribute_name IN VARCHAR2 ) IS
    --------------------------------------------------------------------------------------------------------------------
    BEGIN
        INSERT INTO DD_ATTRIBUTES ( id, object_id, name ) VALUES ( DD_SEQ_ID.NEXTVAL, get_object_id( i_system_name, i_object_name ), UPPER( i_attribute_name ) ) ;
    END;


    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   rename_attribute    ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2, i_attribute_name IN VARCHAR2, i_new_name IN VARCHAR2         ) IS
    --------------------------------------------------------------------------------------------------------------------
    BEGIN
        UPDATE DD_ATTRIBUTES SET name = UPPER( i_new_name ) WHERE id = get_attribute_id( i_system_name, i_object_name, i_attribute_name );
    END;


    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   remove_attribute    ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2, i_attribute_name IN VARCHAR2, i_cascade  IN BOOLEAN := FALSE ) IS
    --------------------------------------------------------------------------------------------------------------------
        v_id      NUMBER;
    BEGIN
        v_id := get_attribute_id( i_system_name, i_object_name, i_attribute_name );
        IF i_cascade THEN
            remove_attribute_pair( i_system_name, i_object_name, i_attribute_name, NULL, NULL, NULL, i_cascade => TRUE );
            remove_attribute_pair( NULL, NULL, NULL, i_system_name, i_object_name, i_attribute_name, i_cascade => TRUE );
        END IF;
        DELETE DD_ATTRIBUTES WHERE id = v_id;
    END;


    --------------------------------------------------------------------------------------------------------------------
    FUNCTION    get_attribute_id    ( i_system_name IN VARCHAR2, i_object_name IN VARCHAR2, i_attribute_name IN VARCHAR2 ) RETURN NUMBER IS
    --------------------------------------------------------------------------------------------------------------------
        v_id    NUMBER;
    BEGIN
        SELECT MIN ( id ) INTO v_id FROM DD_ATTRIBUTES_VW WHERE system_name = UPPER( i_system_name ) AND object_name = UPPER( i_object_name ) AND name = UPPER ( i_attribute_name );
        RETURN v_id;
    END;


    /***********************************************/
    /**************   ATTRIBUTE PAIR  **************/
    /***********************************************/

    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   add_attribute_pair  ( i_a_system_name       IN VARCHAR2, 
                                      i_a_object_name       IN VARCHAR2, 
                                      i_a_attribute_name    IN VARCHAR2, 
                                      i_b_system_name       IN VARCHAR2, 
                                      i_b_object_name       IN VARCHAR2, 
                                      i_b_attribute_name    IN VARCHAR2 
                                    ) IS
    --------------------------------------------------------------------------------------------------------------------
    BEGIN
        INSERT INTO DD_ATTRIBUTE_PAIRS ( id, a_attribute_id, b_attribute_id ) VALUES 
            ( DD_SEQ_ID.NEXTVAL, get_attribute_id( i_a_system_name, i_a_object_name, i_a_attribute_name ),
                                 get_attribute_id( i_b_system_name, i_b_object_name, i_b_attribute_name ) );
    END;


    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   remove_attribute_pair  ( i_a_system_name       IN VARCHAR2, 
                                         i_a_object_name       IN VARCHAR2, 
                                         i_a_attribute_name    IN VARCHAR2, 
                                         i_b_system_name       IN VARCHAR2, 
                                         i_b_object_name       IN VARCHAR2, 
                                         i_b_attribute_name    IN VARCHAR2, 
                                         i_way                 IN VARCHAR2 := NULL,    -- null = both, or 'A2B' or 'B2A'
                                         i_cascade             IN BOOLEAN  := FALSE
                                       ) IS
    --------------------------------------------------------------------------------------------------------------------
        v_id      NUMBER;
    BEGIN
        v_id := get_attribute_pair_id( i_a_system_name, i_a_object_name, i_a_attribute_name, i_b_system_name, i_b_object_name, i_b_attribute_name, i_way );
        IF i_cascade THEN
            remove_attribute_value_pair( v_id, NULL, NULL );
        END IF;
        DELETE DD_ATTRIBUTE_PAIRS WHERE id = v_id;        
    END;


    --------------------------------------------------------------------------------------------------------------------
    FUNCTION    get_attribute_pair_id ( i_a_system_name       IN VARCHAR2, 
                                        i_a_object_name       IN VARCHAR2, 
                                        i_a_attribute_name    IN VARCHAR2, 
                                        i_b_system_name       IN VARCHAR2, 
                                        i_b_object_name       IN VARCHAR2, 
                                        i_b_attribute_name    IN VARCHAR2,
                                        i_way                 IN VARCHAR2 := NULL    -- null = both, or 'A2B' or 'B2A'
                                      ) RETURN NUMBER IS
    --------------------------------------------------------------------------------------------------------------------
        v_id    NUMBER;
    BEGIN
        SELECT MIN ( id ) 
          INTO v_id 
          FROM DD_ATTRIBUTE_PAIRS_VW 
         WHERE a_attribute_id = NVL( get_attribute_id( i_a_system_name, i_a_object_name, i_a_attribute_name ), a_attribute_id ) 
           AND b_attribute_id = NVL( get_attribute_id( i_b_system_name, i_b_object_name, i_b_attribute_name ), b_attribute_id )
           AND way = NVL( UPPER ( i_way ), way );
        RETURN v_id;
    END;


    /*****************************************************/
    /**************   ATTRIBUTE VALUE PAIR  **************/
    /*****************************************************/

    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   add_attribute_value_pair  ( i_attribute_pair_id  IN NUMBER,
                                            i_a_value            IN VARCHAR2, 
                                            i_b_value            IN VARCHAR2
                                          ) IS
    --------------------------------------------------------------------------------------------------------------------
    BEGIN
        INSERT INTO DD_ATTRIBUTE_VALUE_PAIRS ( id, attribute_pair_id, a_attribute_value, b_attribute_value ) VALUES 
            ( DD_SEQ_ID.NEXTVAL, i_attribute_pair_id, i_a_value, i_b_value );
    END;


    --------------------------------------------------------------------------------------------------------------------
    PROCEDURE   remove_attribute_value_pair( i_attribute_pair_id  IN NUMBER,
                                             i_a_value            IN VARCHAR2, 
                                             i_b_value            IN VARCHAR2
                                           ) IS
    --------------------------------------------------------------------------------------------------------------------
    BEGIN
        DELETE DD_ATTRIBUTE_VALUE_PAIRS 
         WHERE attribute_pair_id = i_attribute_pair_id 
           AND a_attribute_value = NVL( i_a_value, a_attribute_value)
           AND b_attribute_value = NVL( i_b_value, b_attribute_value);
    END;


    --------------------------------------------------------------------------------------------------------------------
    FUNCTION    get_attribute_value ( i_attribute_pair_id  IN NUMBER,
                                      i_value              IN VARCHAR2,
                                      i_way                IN VARCHAR2 := NULL,    -- null = both, or 'A2B' or 'B2A'
                                      i_exact              IN BOOLEAN  := TRUE,    -- true = use exact match eg "=", false = use "like"
                                      i_case_sensitive     IN BOOLEAN  := TRUE     -- false = use UPPER before comparison
                                    ) RETURN VARCHAR2 IS
    --------------------------------------------------------------------------------------------------------------------
        l_sql           VARCHAR2 ( 4000 );
        l_value         VARCHAR2 ( 2000 );

    PROCEDURE set_sql ( i_from IN VARCHAR2, i_to IN VARCHAR2 ) IS
    BEGIN
        l_sql := 'SELECT '||i_to||'_ATTRIBUTE_VALUE FROM DD_ATTRIBUTE_VALUE_PAIRS WHERE ATTRIBUTE_PAIR_ID = '||i_attribute_pair_id||' AND ';
        IF i_case_sensitive THEN 
            l_sql := l_sql || ' '||i_from||'_ATTRIBUTE_VALUE '; 
        ELSE
            l_sql := l_sql || ' UPPER( '||i_from||'_ATTRIBUTE_VALUE )'; 
        END IF;
        IF i_exact THEN 
            l_sql := l_sql || ' = '; 
        ELSE
            l_sql := l_sql || ' LIKE '; 
        END IF;
        IF i_case_sensitive THEN 
            l_sql := l_sql || '''' || i_value || ''' '; 
        ELSE
            l_sql := l_sql || ' UPPER( '|| '''' || i_value || ''') ';
        END IF;
-- dbms_output.put_line(l_sql);
    END;

    BEGIN

        IF i_way IS NULL OR UPPER( i_way ) = 'A2B' THEN 
            set_sql( 'A', 'B' );
            BEGIN
                EXECUTE IMMEDIATE l_sql INTO l_value;
                IF l_value IS NOT NULL THEN
                    RETURN l_value;
                END IF;
            EXCEPTION WHEN OTHERS THEN
                NULL;
            END;
        END IF;

        IF i_way IS NULL OR UPPER( i_way ) = 'B2A' THEN 
            set_sql( 'B', 'A' );
            BEGIN
                EXECUTE IMMEDIATE l_sql INTO l_value;
                IF l_value IS NOT NULL THEN
                    RETURN l_value;
                END IF;
            EXCEPTION WHEN OTHERS THEN
                NULL;
            END;
        END IF;

        RETURN NULL;

    END;

    --------------------------------------------------------------------------------------------------------------------

END PKG_DDM;
/
