 PROCEDURE CREATE_TABLE(p_tname VARCHAR2 ,p_fields_and_types VARCHAR2 ,p_pkey VARCHAR2 ,p_create_sqn VARCHAR2) 
      AS
    --##########################################################################################################################--

    -- Description:          This procedure caretes a table if not exist
    -- Parameters:         p_tname  = Table name varchar
    --                                ,p_fileds_and_types= ecsepts fields name and data type with comma delimiter .
    --                                ,p_pkey = primary key constraint field name with comma delimiter .
    --                                ,p_create_sqn = ecsepts only Y or N . if Y then  procedure will create a new sequence
    -- Createtion Date:   05/11/2017
    -- Developer:             Dima Baturin
    --##########################################################################################################################--


    -- DDL statment  variables
      ddl_statment CLOB:='CREATE TABLE ';
      trigger_statment VARCHAR2 (4000):='CREATE OR REPLACE TRIGGER  ';
      sequence_statment VARCHAR2 (4000):='CREATE SEQUENCE  '; 

   --Object name suffix  variables
      table_suffix VARCHAR2 (40):='';
      const_suffix VARCHAR2 (40):='_PK';
      trigger_suffix VARCHAR2 (40):='_TRG';
      sequence_suffix VARCHAR2 (40):='_SQN';

    --Help variables 
      tmp VARCHAR2 (400) ;
      v_create_sqn VARCHAR2 (1) :=p_create_sqn;
      id_key VARCHAR2 (40):=REGEXP_SUBSTR(p_pkey,'[^ ,]+');

      BEGIN 

        IF p_tname IS NOT NULL THEN 

                    --Sub procedure for checking if TABLE exists
                   BEGIN 
                        SELECT t.TABLE_NAME
                             INTO tmp
                           FROM ALL_TABLES t
                        WHERE t.TABLE_NAME =p_tname||table_suffix;
                EXCEPTION
                              WHEN NO_DATA_FOUND THEN
                                tmp :=NULL;
                     END;
--******************************************
 --- PREPARE TABLE  DDL CODE 
--******************************************
             IF NVL(tmp,'1')='1'   AND NVL(p_fields_and_types,'1') <>'1' THEN 
             --Prepare ddl statement for table 
               ddl_statment:=CONCAT(ddl_statment,p_tname);                       
               ddl_statment:=CONCAT(ddl_statment,table_suffix);                    
               ddl_statment:=CONCAT(ddl_statment,' (');                                     
               ddl_statment:=CONCAT(ddl_statment,p_fields_and_types);     


                   IF p_pkey IS NOT NULL THEN

                     --Sub procedure  for checking if CONSTRAINT exists             
                      BEGIN 

                           SELECT t.CONSTRAINT_NAME
                                 INTO tmp
                              FROM ALL_CONSTRAINTS t
                            WHERE t.CONSTRAINT_NAME =p_tname || table_suffix ||const_suffix;
                    EXCEPTION
                      WHEN NO_DATA_FOUND THEN
                                tmp :=NULL;
                      END;

                    --  CHECK IF CONSTRAN IS EXISTE 
                        IF NVL(tmp,'1')='1'  AND p_pkey IS NOT NULL THEN

                         --Prepare constraint statement for table                                                                                                                                    
                            ddl_statment:=CONCAT(ddl_statment,' , CONSTRAINT ');                
                            ddl_statment:=CONCAT(ddl_statment,p_tname);                              
                            ddl_statment:=CONCAT(ddl_statment,table_suffix);                         
                            ddl_statment:=CONCAT(ddl_statment,const_suffix);                         
                            ddl_statment:=CONCAT(ddl_statment,' PRIMARY KEY ( ');             
                            ddl_statment:=CONCAT(ddl_statment,p_pkey);                                  
                            ddl_statment:=CONCAT(ddl_statment,'  )  ENABLE ');                       

                        END IF;                            
                   END IF;
                            ddl_statment:=CONCAT(ddl_statment,' )');                        -- CLOSE FIELDS DDL AREA

--********************************************
 --- PREPARE SEQUENCE DDL CODE  
--********************************************             
                                 IF UPPER(p_create_sqn)='Y' THEN

                                   --Sub procedure  for checking if SEQUENCE exists            
                                   BEGIN
                                       SELECT t.SEQUENCE_NAME
                                            INTO  tmp
                                          FROM ALL_SEQUENCES T
                                       WHERE t.SEQUENCE_NAME =p_tname || table_suffix ||sequence_suffix;
                               EXCEPTION
                                WHEN NO_DATA_FOUND THEN
                                        tmp :=NULL;
                                    END;


                                   --   IF CONSTRAN EXISTE ,Create DDL statment else use available 
                                    IF NVL(tmp,'1')='1'     THEN 
                                        --Prepare sequence statement based on table ID                    
                                       sequence_statment:=CONCAT(sequence_statment,p_tname);                 
                                       sequence_statment:=CONCAT(sequence_statment,table_suffix);             
                                       sequence_statment:=CONCAT(sequence_statment,sequence_suffix);     
 --**********************************************
 --- CREATE TRIGGER GROUP 
 --**********************************************                                                            

                                     --Prepare s trigger  statement for table ID  
                                       trigger_statment:=CONCAT(trigger_statment,p_tname);                              
                                       trigger_statment:=CONCAT(trigger_statment,table_suffix);                         
                                       trigger_statment:=CONCAT(trigger_statment,trigger_suffix);                      
                                       trigger_statment:=CONCAT(trigger_statment,' BEFORE INSERT ON ');    
                                       trigger_statment:=CONCAT(trigger_statment,p_tname);                             
                                       trigger_statment:=CONCAT(trigger_statment,table_suffix);                          
                                       trigger_statment:=CONCAT(trigger_statment,' FOR EACH ROW '); 
                                       trigger_statment:=CONCAT(trigger_statment,'  BEGIN'  
                                                                      ||' IF inserting THEN '
                                                                      ||' IF :NEW.'|| id_key  ||' IS NULL THEN '
                                                                      ||'     SELECT '
                                                                      ||p_tname || table_suffix ||sequence_suffix
                                                                      ||'.NEXTVAL INTO :NEW.'|| id_key ||' FROM dual; '
                                                                      ||'         END IF; '
                                                                      ||'   END IF; '
                                                                      ||' END;');
                                   ELSE
                                      v_create_sqn:='N';

                                   END IF;
                           END IF;


 --************************************************
 --- DDL CODE EXECUTION  
 --*************************************************

                   EXECUTE IMMEDIATE ddl_statment;                 --CREATE TABLE 

                    IF UPPER(v_create_sqn)='Y' THEN
                       EXECUTE IMMEDIATE sequence_statment;        --CREATE SEQUENCE
                       EXECUTE IMMEDIATE trigger_statment;         --CREATE TRIGGER

                    END IF; 


              END IF;
         END IF;
  EXCEPTION
      WHEN OTHERS THEN
     
      DBMS_OUTPUT.PUT_LINE(SQLERRM);
          
                      
 END CREATE_TABLE;
