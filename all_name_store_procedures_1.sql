DROP procedure IF EXISTS sp_create_transfer_phrases_to_last_name_table;

DELIMITER $$

CREATE PROCEDURE sp_create_transfer_phrases_to_last_name_table ()
BEGIN
-- --------------------------------------------------------------------------------
-- create transfer phrases to last name table
-- --------------------------------------------------------------------------------	

#Begin Time
select CURTIME() as 'Start sp_create_transfer_phrases_to_last_name_table';

DROP TABLE IF EXISTS TRANSFER_PHRASES_TO_LAST_NAME;

CREATE TABLE TRANSFER_PHRASES_TO_LAST_NAME (phrase VARCHAR(64) NOT NULL, PRIMARY KEY (phrase));

INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT REPORTED');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('TO BE DETERMINED');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NONE SUBMITTED');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('RESEARCH INC.');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT APPLICABLE');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT ABAILABLE');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT AV');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT GIVEN');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT AVAILABE');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT AVAILABLE');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT AVAILABLE  *');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('DO NOT KNOW.');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT KNOWN');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT LISTED');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT PROVIDED');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT REPO TED');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT REQ');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT SUBMITTED');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NOT SUPPLIED');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NONE GIVEN');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NONE PROVIDED');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NONE REPORTED');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NONE REPORTED.');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NONE TO REPORT');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('(804) 727-2171');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('* TO BE ADDED*');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('. DAJ. DANDO');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('EMPLOYMENT TERM.');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('SEE TEXT');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('SAFETY SCIENCES');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('NO NAME');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('BELL TECH OPERATIONS');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('CURRENTLY UNAVAILABLE');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('US ARMY');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('US ARMY TRADOC');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('BDM (CONTRACTOR)');
INSERT INTO TRANSFER_PHRASES_TO_LAST_NAME VALUES ('KNOWN NOT');

#End Time
select CURTIME() as 'End sp_create_transfer_phrases_to_last_name_table'; 

END $$

DELIMITER ;

DROP procedure IF EXISTS sp_create_suffix_table;

DELIMITER $$

CREATE PROCEDURE sp_create_suffix_table ()
BEGIN
-- --------------------------------------------------------------------------------
-- create suffix table
-- --------------------------------------------------------------------------------	

#Begin Time
select CURTIME() as 'Start sp_create_suffix_table';

DROP TABLE IF EXISTS SUFFIX;

CREATE TABLE SUFFIX (suffix VARCHAR(64) NOT NULL, PRIMARY KEY (suffix));

INSERT INTO SUFFIX VALUES ('Jr');
INSERT INTO SUFFIX VALUES ('Jr.');
INSERT INTO SUFFIX VALUES ('Sr');
INSERT INTO SUFFIX VALUES ('Sr.');
INSERT INTO SUFFIX VALUES ('Junior');
INSERT INTO SUFFIX VALUES ('Senior');
INSERT INTO SUFFIX VALUES ('II');
INSERT INTO SUFFIX VALUES ('III');
INSERT INTO SUFFIX VALUES ('IV');
INSERT INTO SUFFIX VALUES ('PhD');
INSERT INTO SUFFIX VALUES ('Ph.D');
INSERT INTO SUFFIX VALUES ('Ph.D.');
INSERT INTO SUFFIX VALUES ('M.D');
INSERT INTO SUFFIX VALUES ('M.D.');
INSERT INTO SUFFIX VALUES ('MD');
INSERT INTO SUFFIX VALUES ('MD.');
INSERT INTO SUFFIX VALUES ('Esq');
INSERT INTO SUFFIX VALUES ('CIV');
INSERT INTO SUFFIX VALUES ('USAF');
INSERT INTO SUFFIX VALUES ('Air Force');
INSERT INTO SUFFIX VALUES ('USN');
INSERT INTO SUFFIX VALUES ('Navy');
INSERT INTO SUFFIX VALUES ('USMC');
INSERT INTO SUFFIX VALUES ('MSC');
INSERT INTO SUFFIX VALUES ('Marine');
INSERT INTO SUFFIX VALUES ('USA');
INSERT INTO SUFFIX VALUES ('U.S.A');
INSERT INTO SUFFIX VALUES ('U.S.A.');
INSERT INTO SUFFIX VALUES ('Army');
INSERT INTO SUFFIX VALUES ('PE');
INSERT INTO SUFFIX VALUES ('SES');
INSERT INTO SUFFIX VALUES ('ATC');
INSERT INTO SUFFIX VALUES ('AIR-5162G');
INSERT INTO SUFFIX VALUES ('6022');
INSERT INTO SUFFIX VALUES ('LCDR/USN');
INSERT INTO SUFFIX VALUES ('AIR360B');
INSERT INTO SUFFIX VALUES ('5021');
INSERT INTO SUFFIX VALUES ('1SA');
INSERT INTO SUFFIX VALUES ('6054');
INSERT INTO SUFFIX VALUES ('AIR-54121');
INSERT INTO SUFFIX VALUES ('AIR-5412');
INSERT INTO SUFFIX VALUES ('(AIR-530313)');
INSERT INTO SUFFIX VALUES ('(AIR-54122A)');
INSERT INTO SUFFIX VALUES ('601');
INSERT INTO SUFFIX VALUES ('(N-82)');
INSERT INTO SUFFIX VALUES ('(JCM-S-101)');
INSERT INTO SUFFIX VALUES ('3010');
INSERT INTO SUFFIX VALUES ('LCDR');
INSERT INTO SUFFIX VALUES ('5251');
INSERT INTO SUFFIX VALUES ('ONR-521');
 
#End Time
select CURTIME() as 'End sp_create_suffix_table'; 

END $$

DELIMITER ;

DROP procedure IF EXISTS sp_create_prefix_table;

DELIMITER $$

CREATE PROCEDURE sp_create_prefix_table ()
BEGIN
-- --------------------------------------------------------------------------------
-- create prefix table
-- --------------------------------------------------------------------------------	

#Begin Time
select CURTIME() as 'Start sp_create_prefix_table';

DROP TABLE IF EXISTS PREFIX;

CREATE TABLE PREFIX (prefix VARCHAR(64) NOT NULL, PRIMARY KEY (prefix));

INSERT INTO PREFIX VALUES ('Ms');
INSERT INTO PREFIX VALUES ('Miss');
INSERT INTO PREFIX VALUES ('Mrs');
INSERT INTO PREFIX VALUES ('Mr');
INSERT INTO PREFIX VALUES ('Master');
INSERT INTO PREFIX VALUES ('Rev');
INSERT INTO PREFIX VALUES ('Fr');
INSERT INTO PREFIX VALUES ('Dr');
INSERT INTO PREFIX VALUES ('Atty');
INSERT INTO PREFIX VALUES ('Prof');
INSERT INTO PREFIX VALUES ('Professor');
INSERT INTO PREFIX VALUES ('Hon');
INSERT INTO PREFIX VALUES ('Pres');
INSERT INTO PREFIX VALUES ('Gov');
INSERT INTO PREFIX VALUES ('Coach');
INSERT INTO PREFIX VALUES ('Ofc');
INSERT INTO PREFIX VALUES ('Msgr');
INSERT INTO PREFIX VALUES ('Sr');
INSERT INTO PREFIX VALUES ('Br');
INSERT INTO PREFIX VALUES ('Supt');
INSERT INTO PREFIX VALUES ('Rep');
INSERT INTO PREFIX VALUES ('Sen');
INSERT INTO PREFIX VALUES ('Amb');
INSERT INTO PREFIX VALUES ('Treas');
INSERT INTO PREFIX VALUES ('Sec');
INSERT INTO PREFIX VALUES ('Pvt');
INSERT INTO PREFIX VALUES ('Cpl');
INSERT INTO PREFIX VALUES ('Sgt');
INSERT INTO PREFIX VALUES ('Adm');
INSERT INTO PREFIX VALUES ('Maj');
INSERT INTO PREFIX VALUES ('Major');
INSERT INTO PREFIX VALUES ('Capt');
INSERT INTO PREFIX VALUES ('Cmdr');
INSERT INTO PREFIX VALUES ('Lt');
INSERT INTO PREFIX VALUES ('Lt Col');
INSERT INTO PREFIX VALUES ('LTC');
INSERT INTO PREFIX VALUES ('LTC  .');
INSERT INTO PREFIX VALUES ('Col');
INSERT INTO PREFIX VALUES ('Gen');
INSERT INTO PREFIX VALUES ('Ms.');
INSERT INTO PREFIX VALUES ('Miss.');
INSERT INTO PREFIX VALUES ('Mrs.');
INSERT INTO PREFIX VALUES ('Mr.');
INSERT INTO PREFIX VALUES ('Master.');
INSERT INTO PREFIX VALUES ('Rev.');
INSERT INTO PREFIX VALUES ('Fr.');
INSERT INTO PREFIX VALUES ('Dr.');
INSERT INTO PREFIX VALUES ('Atty.');
INSERT INTO PREFIX VALUES ('Prof.');
INSERT INTO PREFIX VALUES ('Hon.');
INSERT INTO PREFIX VALUES ('Pres.');
INSERT INTO PREFIX VALUES ('Gov.');
INSERT INTO PREFIX VALUES ('Coach.');
INSERT INTO PREFIX VALUES ('Ofc.');
INSERT INTO PREFIX VALUES ('Msgr.');
INSERT INTO PREFIX VALUES ('Sr.');
INSERT INTO PREFIX VALUES ('Br.');
INSERT INTO PREFIX VALUES ('Supt.');
INSERT INTO PREFIX VALUES ('Rep.');
INSERT INTO PREFIX VALUES ('Sen.');
INSERT INTO PREFIX VALUES ('Amb.');
INSERT INTO PREFIX VALUES ('Treas.');
INSERT INTO PREFIX VALUES ('Sec.');
INSERT INTO PREFIX VALUES ('Pvt.');
INSERT INTO PREFIX VALUES ('Cpl.');
INSERT INTO PREFIX VALUES ('Sgt.');
INSERT INTO PREFIX VALUES ('Adm.');
INSERT INTO PREFIX VALUES ('Maj.');
INSERT INTO PREFIX VALUES ('Capt.');
INSERT INTO PREFIX VALUES ('Cmdr.');
INSERT INTO PREFIX VALUES ('Lt.');
INSERT INTO PREFIX VALUES ('Lt Col.');
INSERT INTO PREFIX VALUES ('LTC.');
INSERT INTO PREFIX VALUES ('LTCOL');
INSERT INTO PREFIX VALUES ('2/LT.');
INSERT INTO PREFIX VALUES ('Col.');
INSERT INTO PREFIX VALUES ('Gen.');
INSERT INTO PREFIX VALUES ('Captain');
INSERT INTO PREFIX VALUES ('RADM');
INSERT INTO PREFIX VALUES ('RDML');
INSERT INTO PREFIX VALUES ('VADM');
INSERT INTO PREFIX VALUES ('1LT');
INSERT INTO PREFIX VALUES ('CDR');
INSERT INTO PREFIX VALUES ('CPT');
INSERT INTO PREFIX VALUES ('CAPT MC');

#End Time
select CURTIME() as 'End sp_create_prefix_table'; 

END $$

DELIMITER ;

DROP procedure IF EXISTS sp_update_prefix_performing_ind;

DELIMITER $$

CREATE PROCEDURE sp_update_prefix_performing_ind (INOUT LV_NAME varchar(65),LV_SPACE VARCHAR(1),LV_PERFORMING_IND_ID INT(10))
BEGIN
    -- --------------------------------------------------------------------------------
    -- update performing_ind.prefix
    -- --------------------------------------------------------------------------------	
    DECLARE LV_PREFIX VARCHAR(65);
    
    prefix_in_name: begin
        DECLARE LV_DONE_PREFIX INT DEFAULT FALSE;
        DECLARE prefix_in_name_cursor CURSOR FOR select prefix from PREFIX where prefix in (SUBSTRING_INDEX(LV_NAME,LV_SPACE,1));
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET LV_DONE_PREFIX = TRUE;
        
        OPEN prefix_in_name_cursor;
        
        prefix_in_name_cursor: LOOP
        FETCH prefix_in_name_cursor INTO LV_PREFIX;

            IF LV_DONE_PREFIX THEN
                LEAVE prefix_in_name_cursor;
            ELSE
                #Update Prefix field
                update performing_ind SET PREFIX = LV_PREFIX WHERE performing_ind_ID = LV_PERFORMING_IND_ID;
                #Remove Prefix value (plus space after prefix) from LV_NAME
                SET LV_NAME = SUBSTRING(LV_NAME FROM (LENGTH(SUBSTRING_INDEX(LV_NAME,LV_SPACE,1)) + 2) FOR (LENGTH(LV_NAME) - LENGTH(SUBSTRING_INDEX(LV_NAME,LV_SPACE,1))));
            END IF;

        END LOOP prefix_in_name_cursor;
        
        CLOSE prefix_in_name_cursor;
    end prefix_in_name;
END $$ 

DELIMITER ;

DROP procedure IF EXISTS sp_update_prefix_responsible_ind;

DELIMITER $$

CREATE PROCEDURE sp_update_prefix_responsible_ind (INOUT LV_NAME varchar(65),LV_SPACE VARCHAR(1),LV_RESPONSIBLE_IND_ID INT(10))
BEGIN
    -- --------------------------------------------------------------------------------
    -- update responsible_ind.prefix
    -- --------------------------------------------------------------------------------	
    DECLARE LV_PREFIX VARCHAR(65);
    
    prefix_in_name: begin
        DECLARE LV_DONE_PREFIX INT DEFAULT FALSE;
        DECLARE prefix_in_name_cursor CURSOR FOR select prefix from PREFIX where prefix in (SUBSTRING_INDEX(LV_NAME,LV_SPACE,1));
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET LV_DONE_PREFIX = TRUE;
        
        OPEN prefix_in_name_cursor;
        
        prefix_in_name_cursor: LOOP
        FETCH prefix_in_name_cursor INTO LV_PREFIX;

            IF LV_DONE_PREFIX THEN
                LEAVE prefix_in_name_cursor;
            ELSE
                #Update Prefix field
                update responsible_ind SET PREFIX = LV_PREFIX WHERE RESPONSIBLE_IND_ID = LV_RESPONSIBLE_IND_ID;
                #Remove Prefix value (plus space after prefix) from LV_NAME
                SET LV_NAME = SUBSTRING(LV_NAME FROM (LENGTH(SUBSTRING_INDEX(LV_NAME,LV_SPACE,1)) + 2) FOR (LENGTH(LV_NAME) - LENGTH(SUBSTRING_INDEX(LV_NAME,LV_SPACE,1))));
            END IF;

        END LOOP prefix_in_name_cursor;
        
        CLOSE prefix_in_name_cursor;
    end prefix_in_name;
END $$

DELIMITER ;

DROP procedure IF EXISTS sp_update_suffix_performing_ind;

DELIMITER $$

CREATE PROCEDURE sp_update_suffix_performing_ind (INOUT LV_NAME varchar(65),LV_SPACE VARCHAR(1),LV_PERFORMING_IND_ID INT(10))
BEGIN
    -- --------------------------------------------------------------------------------
    -- update performing_ind.SUFFIX
    -- --------------------------------------------------------------------------------	
    DECLARE LV_SUFFIX VARCHAR(65);
    
    SUFFIX_in_name: begin
        DECLARE LV_DONE_SUFFIX INT DEFAULT FALSE;
        DECLARE SUFFIX_in_name_cursor CURSOR FOR select SUFFIX from SUFFIX where SUFFIX in (SUBSTRING_INDEX(LV_NAME,LV_SPACE,-1));
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET LV_DONE_SUFFIX = TRUE;
        
        OPEN SUFFIX_in_name_cursor;
        
        SUFFIX_in_name_cursor: LOOP
        FETCH SUFFIX_in_name_cursor INTO LV_SUFFIX;

            IF LV_DONE_SUFFIX THEN
                LEAVE SUFFIX_in_name_cursor;
            ELSE
                #Update SUFFIX field
                update performing_ind SET SUFFIX = LV_SUFFIX WHERE performing_ind_ID = LV_PERFORMING_IND_ID;
                #Remove SUFFIX value (plus space after SUFFIX) from LV_NAME
                #SET LV_NAME = SUBSTRING(LV_NAME FROM (LENGTH(SUBSTRING_INDEX(LV_NAME,LV_SPACE,1)) + 2) FOR (LENGTH(LV_NAME) - LENGTH(SUBSTRING_INDEX(LV_NAME,LV_SPACE,1))));
                SET LV_NAME = LEFT(LV_NAME,(LENGTH(LV_NAME) - LENGTH(SUBSTRING_INDEX(LV_NAME,LV_SPACE,-1)) - 1));
            END IF;

        END LOOP SUFFIX_in_name_cursor;
        
        CLOSE SUFFIX_in_name_cursor;
    end SUFFIX_in_name;
END $$ 

DELIMITER ;

DROP procedure IF EXISTS sp_update_suffix_responsible_ind;

DELIMITER $$

CREATE PROCEDURE sp_update_suffix_responsible_ind (INOUT LV_NAME varchar(65),LV_SPACE VARCHAR(1),LV_RESPONSIBLE_IND_ID INT(10))
BEGIN
    -- --------------------------------------------------------------------------------
    -- update responsible_ind.SUFFIX
    -- --------------------------------------------------------------------------------	
    DECLARE LV_SUFFIX VARCHAR(65);
    
    SUFFIX_in_name: begin
        DECLARE LV_DONE_SUFFIX INT DEFAULT FALSE;
        DECLARE SUFFIX_in_name_cursor CURSOR FOR select SUFFIX from SUFFIX where SUFFIX in (SUBSTRING_INDEX(LV_NAME,LV_SPACE,-1));
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET LV_DONE_SUFFIX = TRUE;
        
        OPEN SUFFIX_in_name_cursor;
        
        SUFFIX_in_name_cursor: LOOP
        FETCH SUFFIX_in_name_cursor INTO LV_SUFFIX;

            IF LV_DONE_SUFFIX THEN
                LEAVE SUFFIX_in_name_cursor;
            ELSE
                #Update SUFFIX field
                update responsible_ind SET SUFFIX = LV_SUFFIX WHERE RESPONSIBLE_IND_ID = LV_RESPONSIBLE_IND_ID;
                #Remove SUFFIX value (plus space after SUFFIX) from LV_NAME
                #SET LV_NAME = SUBSTRING(LV_NAME FROM (LENGTH(SUBSTRING_INDEX(LV_NAME,LV_SPACE,1)) + 2) FOR (LENGTH(LV_NAME) - LENGTH(SUBSTRING_INDEX(LV_NAME,LV_SPACE,1))));
                SET LV_NAME = LEFT(LV_NAME,(LENGTH(LV_NAME) - LENGTH(SUBSTRING_INDEX(LV_NAME,LV_SPACE,-1)) - 1));
            END IF;

        END LOOP SUFFIX_in_name_cursor;
        
        CLOSE SUFFIX_in_name_cursor;
    end SUFFIX_in_name;
END $$

DELIMITER ;

DROP procedure IF EXISTS sp_update_transfer_phrases_to_last_name_for_performing_ind;

DELIMITER $$

CREATE PROCEDURE sp_update_transfer_phrases_to_last_name_for_performing_ind (INOUT LV_NAME varchar(65),LV_PERFORMING_IND_ID INT(10))
BEGIN
    -- --------------------------------------------------------------------------------
    -- update performing_ind.last_name
    -- --------------------------------------------------------------------------------	
    DECLARE LV_PHRASE VARCHAR(65);
    
    prefix_in_name: begin
        DECLARE LV_DONE_PHRASE INT DEFAULT FALSE;
        DECLARE phrase_in_name_cursor CURSOR FOR select phrase from TRANSFER_PHRASES_TO_LAST_NAME where phrase in (LV_NAME);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET LV_DONE_PHRASE = TRUE;
        
        OPEN phrase_in_name_cursor;
        
        phrase_in_name_cursor: LOOP
        FETCH phrase_in_name_cursor INTO LV_PHRASE;

            IF LV_DONE_PHRASE THEN
                LEAVE phrase_in_name_cursor;
            ELSE
                #Update Last Name field
                update performing_ind SET LAST_NAME = LV_PHRASE WHERE performing_ind_ID = LV_PERFORMING_IND_ID;
                #Set the LV_NAME to Null.  No more processing necessary to the name.
                SET LV_NAME = NULL;
            END IF;

        END LOOP phrase_in_name_cursor;
        
        CLOSE phrase_in_name_cursor;
    end prefix_in_name;
END $$ 

DELIMITER ;

DROP procedure IF EXISTS sp_update_transfer_phrases_to_last_name_for_responsible_ind;

DELIMITER $$

CREATE PROCEDURE sp_update_transfer_phrases_to_last_name_for_responsible_ind (INOUT LV_NAME varchar(65),LV_RESPONSIBLE_IND_ID INT(10))
BEGIN
    -- --------------------------------------------------------------------------------
    -- update responsible_ind.last_name
    -- --------------------------------------------------------------------------------	
    DECLARE LV_PHRASE VARCHAR(65);
    
    prefix_in_name: begin
        DECLARE LV_DONE_PHRASE INT DEFAULT FALSE;
        DECLARE phrase_in_name_cursor CURSOR FOR select phrase from TRANSFER_PHRASES_TO_LAST_NAME where phrase in (LV_NAME);
        DECLARE CONTINUE HANDLER FOR NOT FOUND SET LV_DONE_PHRASE = TRUE;
        
        OPEN phrase_in_name_cursor;
        
        phrase_in_name_cursor: LOOP
        FETCH phrase_in_name_cursor INTO LV_PHRASE;

            IF LV_DONE_PHRASE THEN
                LEAVE phrase_in_name_cursor;
            ELSE
                #Update Last Name field
                update responsible_ind SET LAST_NAME = LV_PHRASE WHERE RESPONSIBLE_IND_ID = LV_RESPONSIBLE_IND_ID;
                #Set the LV_NAME to Null.  No more processing necessary to the name.
                SET LV_NAME = NULL;
            END IF;

        END LOOP phrase_in_name_cursor;
        
        CLOSE phrase_in_name_cursor;
    end prefix_in_name;
END $$ 

DELIMITER ;

DROP procedure IF EXISTS sp_split_name_performing_ind;

DELIMITER $$

CREATE PROCEDURE sp_split_name_performing_ind ()
BEGIN
    -- --------------------------------------------------------------------------------
    -- Parse performing_ind.name to first_name, middle_name, last_name, prefix, and suffix
    -- --------------------------------------------------------------------------------	
    DECLARE LV_DONE INT DEFAULT FALSE;

    DECLARE LV_NAME VARCHAR(65);
    DECLARE LV_PERFORMING_IND_ID INT(10);
    DECLARE LV_FIRST_AND_MIDDLE_NAME VARCHAR(65);
    DECLARE LV_INNER_COUNTER INT DEFAULT 0;
    DECLARE LV_OUTER_COUNTER INT DEFAULT 0;
    DECLARE LV_COMMA VARCHAR(1);
    DECLARE LV_SPACE VARCHAR(1);
    DECLARE LV_NUMBER_OF_COMMAS INT DEFAULT 0;
    DECLARE LV_ZERO_COMMA_FIRST_NAME VARCHAR(65);
    DECLARE LV_ZERO_COMMA_LAST_NAME VARCHAR(65);
    DECLARE LV_PREFIX VARCHAR(65);
    DECLARE LV_FIRST_NAME VARCHAR(65);
    DECLARE LV_LAST_NAME VARCHAR(65);
    DECLARE LV_IS_NAME_RULE1 VARCHAR(1) DEFAULT 'N';

	#Returns all the Research Summary Performing Individual records
    DECLARE performing_ind_one_comma_cursor CURSOR FOR 
    SELECT NAME,performing_ind_ID,LENGTH(NAME) - LENGTH(REPLACE(NAME, ",", "")),FIRST_NAME,LAST_NAME 
    from research_project, performing_org, performing_ind 
    where research_project.research_project_id = performing_org.research_project_id 	
    and performing_org.performing_org_id = performing_ind.performing_org_id
	and source_db = 'Research Summaries' 
	and NAME IS NOT NULL;
    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET LV_DONE = TRUE;
    
    #Begin Time
    select CURTIME() as 'Start sp_split_name_performing_ind';

    SET LV_COMMA = ',';
    SET LV_SPACE = ' ';

    OPEN performing_ind_one_comma_cursor;
    
    performing_ind_one_comma_loop: LOOP
    FETCH performing_ind_one_comma_cursor INTO LV_NAME,LV_PERFORMING_IND_ID,LV_NUMBER_OF_COMMAS,LV_FIRST_NAME,LV_LAST_NAME;
    
        IF LV_DONE THEN
          LEAVE performing_ind_one_comma_loop;
        END IF;
        
        SET LV_NAME = TRIM(LV_NAME);
        
        #clear out first and middle name
        update performing_ind SET FIRST_NAME = NULL, MIDDLE_NAME = NULL WHERE PERFORMING_IND_ID = LV_PERFORMING_IND_ID;
        
        #transfer phrases to last name
        call sp_update_transfer_phrases_to_last_name_for_performing_ind(LV_NAME,LV_PERFORMING_IND_ID);
        
        #Skip over empty data
        IF(LENGTH(LV_NAME)>0) THEN
	    	#Scenario:  LAST_NAME, FIRST_NAME MIDDLE_NAME
	        IF(LV_NUMBER_OF_COMMAS=1) THEN
	        	#suffix
	            call sp_update_suffix_performing_ind(LV_NAME,LV_SPACE,LV_PERFORMING_IND_ID);
	        
	            #Prefix
	            call sp_update_prefix_performing_ind(LV_NAME,LV_SPACE,LV_PERFORMING_IND_ID);
	            
	            #Last Name
	            update performing_ind SET LAST_NAME = TRIM(SUBSTRING_INDEX(LV_NAME, LV_COMMA, 1)) WHERE performing_ind_ID = LV_PERFORMING_IND_ID;
	            #First Name
	            update performing_ind SET FIRST_NAME = TRIM(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(LV_NAME, LV_COMMA, -1)), LV_SPACE, 1))
	            WHERE performing_ind_ID = LV_PERFORMING_IND_ID;
	            
	            SET LV_FIRST_AND_MIDDLE_NAME = TRIM(SUBSTRING(LV_NAME, INSTR(LV_NAME,LV_COMMA)+1));
	            
	            #Middle Name
	            IF INSTR(TRIM(SUBSTRING(LV_FIRST_AND_MIDDLE_NAME, INSTR(LV_FIRST_AND_MIDDLE_NAME,LV_COMMA)+1)),LV_SPACE) > 0 THEN
	               update performing_ind SET MIDDLE_NAME = 
	               TRIM(SUBSTRING(TRIM(SUBSTRING(LV_NAME, INSTR(LV_NAME,LV_COMMA)+1)), 
	               INSTR(TRIM(SUBSTRING(LV_NAME, INSTR(LV_NAME,LV_COMMA)+1)),LV_SPACE)+1))
	               WHERE performing_ind_ID = LV_PERFORMING_IND_ID;
	            END IF;
	        ELSE
	        	IF(LENGTH(LV_FIRST_NAME)>0 Or LENGTH(LV_LAST_NAME)=0) THEN
	        		SET LV_IS_NAME_RULE1 = 'Y';
	        	ELSE
	        		SET LV_IS_NAME_RULE1 = 'N';
	        	END IF;
           		call sp_update_rs_data(LV_NAME,LV_SPACE,LV_PERFORMING_IND_ID,'PERFORMING_IND',LV_IS_NAME_RULE1);
            END IF;
	    END IF;
        
        SET LV_INNER_COUNTER = LV_INNER_COUNTER + 1;
        SET LV_OUTER_COUNTER = LV_OUTER_COUNTER + 1;

        IF(LV_INNER_COUNTER = 5000)THEN
            SELECT LV_OUTER_COUNTER AS "Total Records Processed";
            SET LV_INNER_COUNTER = 0;
        END IF;
        
    END LOOP performing_ind_one_comma_loop;
  
    CLOSE performing_ind_one_comma_cursor;

    SELECT LV_OUTER_COUNTER AS "Total Records Processed";

    #End Time
    select CURTIME() as 'End sp_split_name_performing_ind';
END $$

DELIMITER ;

DROP procedure IF EXISTS sp_split_name_responsible_ind;

DELIMITER $$

CREATE PROCEDURE sp_split_name_responsible_ind ()
BEGIN
    -- --------------------------------------------------------------------------------
    -- Parse responsible_ind.name to first_name, middle_name, last_name, prefix, and suffix
    -- --------------------------------------------------------------------------------	
    DECLARE LV_DONE INT DEFAULT FALSE;

    DECLARE LV_NAME VARCHAR(65);
    DECLARE LV_RESPONSIBLE_IND_ID INT(10);
    DECLARE LV_FIRST_AND_MIDDLE_NAME VARCHAR(65);
    DECLARE LV_INNER_COUNTER INT DEFAULT 0;
    DECLARE LV_OUTER_COUNTER INT DEFAULT 0;
    DECLARE LV_COMMA VARCHAR(1);
    DECLARE LV_SPACE VARCHAR(1);
    DECLARE LV_NUMBER_OF_COMMAS INT DEFAULT 0;
    DECLARE LV_ZERO_COMMA_FIRST_NAME VARCHAR(65);
    DECLARE LV_ZERO_COMMA_LAST_NAME VARCHAR(65);
    DECLARE LV_PREFIX VARCHAR(65);
    DECLARE LV_FIRST_NAME VARCHAR(65);
    DECLARE LV_LAST_NAME VARCHAR(65);
    DECLARE LV_IS_NAME_RULE1 VARCHAR(1) DEFAULT 'N';
    
	#Returns all the Research Summary Performing Individual records
    DECLARE responsible_ind_one_comma_cursor CURSOR FOR 
	SELECT NAME,RESPONSIBLE_IND_ID,LENGTH(NAME) - LENGTH(REPLACE(NAME, LV_COMMA, "")),FIRST_NAME,LAST_NAME
	from research_project, responsible_org, responsible_ind
	where research_project.research_project_id = responsible_org.research_project_id
	and responsible_org.responsible_org_id = responsible_ind.responsible_org_id
	and source_db = 'Research Summaries' 
	and NAME IS NOT NULL;
	    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET LV_DONE = TRUE;
    
    #Begin Time
    select CURTIME() as 'Start sp_split_name_responsible_ind';

    SET LV_COMMA = ',';
    SET LV_SPACE = ' ';

    OPEN responsible_ind_one_comma_cursor;

    responsible_ind_one_comma_loop: LOOP
    FETCH responsible_ind_one_comma_cursor INTO LV_NAME,LV_RESPONSIBLE_IND_ID,LV_NUMBER_OF_COMMAS,LV_FIRST_NAME,LV_LAST_NAME;
    
        IF LV_DONE THEN
          LEAVE responsible_ind_one_comma_loop;
        END IF;
        
        SET LV_NAME = TRIM(LV_NAME);
        
        #clear out first and middle name
        update responsible_ind SET FIRST_NAME = NULL, MIDDLE_NAME = NULL WHERE RESPONSIBLE_IND_ID = LV_RESPONSIBLE_IND_ID;
        
        #transfer phrases to last name
        call sp_update_transfer_phrases_to_last_name_for_responsible_ind(LV_NAME,LV_RESPONSIBLE_IND_ID);
        
        #Skip over empty data
        IF(LENGTH(LV_NAME)>0) THEN
	    	#Scenario:  LAST_NAME, FIRST_NAME MIDDLE_NAME
	        IF(LV_NUMBER_OF_COMMAS=1) THEN
	        	#suffix
	            call sp_update_suffix_responsible_ind(LV_NAME,LV_SPACE,LV_RESPONSIBLE_IND_ID);
	        
	            #Prefix
	            call sp_update_prefix_responsible_ind(LV_NAME,LV_SPACE,LV_RESPONSIBLE_IND_ID);
	            
	            #Last Name
	            update responsible_ind SET LAST_NAME = TRIM(SUBSTRING_INDEX(LV_NAME, LV_COMMA, 1)) WHERE responsible_ind_ID = LV_RESPONSIBLE_IND_ID;
	            #First Name
	            update responsible_ind SET FIRST_NAME = TRIM(SUBSTRING_INDEX(TRIM(SUBSTRING_INDEX(LV_NAME, LV_COMMA, -1)), LV_SPACE, 1))
	            WHERE responsible_ind_ID = LV_RESPONSIBLE_IND_ID;
	            
	            SET LV_FIRST_AND_MIDDLE_NAME = TRIM(SUBSTRING(LV_NAME, INSTR(LV_NAME,LV_COMMA)+1));
	            
	            #Middle Name
	            IF INSTR(TRIM(SUBSTRING(LV_FIRST_AND_MIDDLE_NAME, INSTR(LV_FIRST_AND_MIDDLE_NAME,LV_COMMA)+1)),LV_SPACE) > 0 THEN
	               update responsible_ind SET MIDDLE_NAME = 
	               TRIM(SUBSTRING(TRIM(SUBSTRING(LV_NAME, INSTR(LV_NAME,LV_COMMA)+1)), 
	               INSTR(TRIM(SUBSTRING(LV_NAME, INSTR(LV_NAME,LV_COMMA)+1)),LV_SPACE)+1))
	               WHERE responsible_ind_ID = LV_RESPONSIBLE_IND_ID;
	            END IF;
	        ELSE
	        	IF(LENGTH(LV_FIRST_NAME)>0 Or LENGTH(LV_LAST_NAME)=0) THEN
	        		SET LV_IS_NAME_RULE1 = 'Y';
	        	ELSE
	        		SET LV_IS_NAME_RULE1 = 'N';
	        	END IF;
           		call sp_update_rs_data(LV_NAME,LV_SPACE,LV_RESPONSIBLE_IND_ID,'RESPONSIBLE_IND',LV_IS_NAME_RULE1);
            END IF;
	    END IF;
        
        SET LV_INNER_COUNTER = LV_INNER_COUNTER + 1;
        SET LV_OUTER_COUNTER = LV_OUTER_COUNTER + 1;

        IF(LV_INNER_COUNTER = 5000)THEN
            SELECT LV_OUTER_COUNTER AS "Total Records Processed";
            SET LV_INNER_COUNTER = 0;
        END IF;
   
    END LOOP responsible_ind_one_comma_loop;

    CLOSE responsible_ind_one_comma_cursor;  

    SELECT LV_OUTER_COUNTER AS "Total Records Processed";

    #End Time
    select CURTIME() as 'End sp_split_name_responsible_ind';
END $$

DELIMITER ;

DROP procedure IF EXISTS sp_insert_special_cases;

DELIMITER $$

CREATE PROCEDURE sp_insert_special_cases ()
BEGIN
-- --------------------------------------------------------------------------------
-- Handle special cases where the name is not correctly being parsed by either 
-- sp_split_name_performing_ind, or
-- sp_split_name_responsible_ind.
-- --------------------------------------------------------------------------------	

#Begin Time
select CURTIME() as 'Start sp_insert_special_cases';

#

#End Time
select CURTIME() as 'End sp_insert_special_cases';

END $$

DELIMITER ;

DROP procedure IF EXISTS sp_update_rs_data;

DELIMITER $$

CREATE PROCEDURE sp_update_rs_data
(
  INOUT LV_NAME VARCHAR(65),
  LV_SPACE VARCHAR(5),
  LV_TABLE_ID INT(10),
  LV_TABLE VARCHAR(65),
  LV_IS_NAME_RULE1 VARCHAR(1)
)
BEGIN
 
DECLARE vDone tinyint(1) DEFAULT 1;
DECLARE vIndex INT DEFAULT 1;
DECLARE vSubString VARCHAR(15);
DECLARE LV_NEW_NAME VARCHAR(65) DEFAULT '';
DECLARE vCount tinyint(1) DEFAULT 1;
DECLARE vTotalWordCount tinyint(1) DEFAULT 0;
DECLARE vPrefixAtBeginning VARCHAR(1) DEFAULT 'N';
DECLARE LV_IS_COMMON_FIRST_NAME VARCHAR(1) DEFAULT 'N';

-- update prefix and suffix data and remove from name string
WHILE vDone > 0 DO
  SET vSubString = SUBSTRING(LV_NAME , vIndex,
                    IF(LOCATE(LV_SPACE, LV_NAME , vIndex) > 0,
                      LOCATE(LV_SPACE, LV_NAME , vIndex) - vIndex,
                      LENGTH(LV_NAME )
                    ));
  IF LENGTH(vSubString) > 0 THEN
      SET vIndex = vIndex + LENGTH(vSubString) + 1;
      
      IF(LV_TABLE='PERFORMING_IND') THEN
	      call sp_update_prefix_performing_ind (vSubString,LV_SPACE,LV_TABLE_ID);
	      
	      IF LENGTH(vSubString) = 0 AND vCount=1 THEN
	      	SET vPrefixAtBeginning = 'Y';
	      END IF;
	      
	      -- select vSubString as "prefix";
	      IF LENGTH(vSubString) > 0 THEN
	      	call sp_update_suffix_performing_ind (vSubString,LV_SPACE,LV_TABLE_ID);
	      END IF;
	  ELSEIF(LV_TABLE='RESPONSIBLE_IND') THEN
	      
	  	  call sp_update_prefix_responsible_ind (vSubString,LV_SPACE,LV_TABLE_ID);
	      
	      IF LENGTH(vSubString) = 0 AND vCount=1 THEN
	      	SET vPrefixAtBeginning = 'Y';
	      END IF;
	      
	      -- select vSubString as "prefix";
	      IF LENGTH(vSubString) > 0 THEN
	      	call sp_update_suffix_responsible_ind (vSubString,LV_SPACE,LV_TABLE_ID);
	      END IF;
	  
	  
	  END IF;

		IF LENGTH(vSubString) > 0 THEN 
      		SET LV_NEW_NAME = TRIM(CONCAT(LV_NEW_NAME, LV_SPACE, vSubString));
		END IF;
      
      SET vCount = vCount + 1;
  ELSE
      SET vDone = 0;
  END IF;
END WHILE;

#reset variables
SET vIndex = 1;
SET vSubString = '';
SET vDone = 1;
set vCount = 1;
SET vTotalWordCount = (LENGTH(LV_NEW_NAME) - LENGTH(REPLACE(LV_NEW_NAME, " ", ""))) + 1;
SET LV_IS_COMMON_FIRST_NAME = 'N';

-- update first name, middle name, last name
WHILE vDone > 0 DO
  SET vSubString = SUBSTRING(LV_NEW_NAME , vIndex,
                    IF(LOCATE(LV_SPACE, LV_NEW_NAME , vIndex) > 0,
                      LOCATE(LV_SPACE, LV_NEW_NAME , vIndex) - vIndex,
                      LENGTH(LV_NEW_NAME )
                    ));
  IF LENGTH(vSubString) > 0 THEN
      SET vIndex = vIndex + LENGTH(vSubString) + 1;
      
      #select vCount as "vCount";
      #select LV_IS_COMMON_FIRST_NAME as "is first name";
      #select vSubString as "vSubString";
      
      IF(LV_TABLE='PERFORMING_IND') THEN
      	IF(vTotalWordCount > 1 AND (vPrefixAtBeginning='Y' OR LOCATE('.',LV_NEW_NAME)=2 OR LOCATE(LV_SPACE,LV_NEW_NAME)=2 OR LV_IS_COMMON_FIRST_NAME='Y' OR LV_IS_NAME_RULE1 = 'Y')) THEN
	    	IF(vCount=1) THEN #FIRST NAME
	    		#Data with two initials such as A.B. is actually A. first name and B. is middle name
	      		IF(LOCATE('.',vSubString)=2) THEN
	      			#FIRST NAME INITIAL
	      			UPDATE performing_ind SET FIRST_NAME = LEFT(vSubString,2) WHERE performing_ind_ID = LV_TABLE_ID;
					#MIDDLE NAME INITIAL
	      			UPDATE performing_ind SET MIDDLE_NAME = SUBSTRING(vSubString,3,2) WHERE performing_ind_ID = LV_TABLE_ID;
	      			
	      			#Skip to Last Name (vIndex=3)
	      			SET vCount = vCount + 1;
	      		ELSE
	      			UPDATE performing_ind SET FIRST_NAME = vSubString WHERE performing_ind_ID = LV_TABLE_ID;
	      		END IF;
	      	ELSEIF(vCount=2) THEN #MIDDLE NAME
	      		#Only Add Middle Name if there are three words 
	      		IF(vTotalWordCount = 3) THEN
	      			UPDATE performing_ind SET MIDDLE_NAME = vSubString WHERE performing_ind_ID = LV_TABLE_ID;
	      		ELSE
	      			UPDATE performing_ind SET LAST_NAME = vSubString WHERE performing_ind_ID = LV_TABLE_ID;
	      		END IF;
	      	ELSEIF(vCount=3) THEN #LAST NAME
	      		UPDATE performing_ind SET LAST_NAME = vSubString WHERE performing_ind_ID = LV_TABLE_ID;
			END IF;
	    ELSE
	    	IF(vCount=1) THEN #LAST NAME
	      		UPDATE performing_ind SET LAST_NAME = vSubString WHERE performing_ind_ID = LV_TABLE_ID;
	      	ELSEIF(vCount=2) THEN #FIRST NAME
	      		#Data with two initials such as A.B. is actually A. first name and B. is middle name
	      		IF(LOCATE('.',vSubString)=2) THEN
	      			#FIRST NAME INITIAL
	      			UPDATE performing_ind SET FIRST_NAME = LEFT(vSubString,2) WHERE performing_ind_ID = LV_TABLE_ID;
					#MIDDLE NAME INITIAL
					UPDATE performing_ind SET MIDDLE_NAME = SUBSTRING(vSubString,3,2) WHERE performing_ind_ID = LV_TABLE_ID;
	      		ELSE
	      			UPDATE performing_ind SET FIRST_NAME = vSubString WHERE performing_ind_ID = LV_TABLE_ID;
	      		END IF;	      		
	      	ELSEIF(vCount=3) THEN #MIDDLE NAME
	    		UPDATE performing_ind SET MIDDLE_NAME = vSubString WHERE performing_ind_ID = LV_TABLE_ID;      		
	    	END IF;
      	END IF;
      ELSEIF(LV_TABLE='RESPONSIBLE_IND') THEN
      	IF(vTotalWordCount > 1 AND (vPrefixAtBeginning='Y' OR LOCATE('.',LV_NEW_NAME)=2 OR LOCATE(LV_SPACE,LV_NEW_NAME)=2 OR LV_IS_COMMON_FIRST_NAME='Y' OR LV_IS_NAME_RULE1 = 'Y')) THEN
	    	IF(vCount=1) THEN #FIRST NAME
	    		#Data with two initials such as A.B. is actually A. first name and B. is middle name
	      		IF(LOCATE('.',vSubString)=2) THEN
	      			#FIRST NAME INITIAL
	      			UPDATE responsible_ind SET FIRST_NAME = LEFT(vSubString,2) WHERE responsible_ind_ID = LV_TABLE_ID;
					#MIDDLE NAME INITIAL
	      			UPDATE responsible_ind SET MIDDLE_NAME = SUBSTRING(vSubString,3,2) WHERE responsible_ind_ID = LV_TABLE_ID;
	      			
	      			#Skip to Last Name (vIndex=3)
	      			SET vCount = vCount + 1;
	      		ELSE
	      			UPDATE responsible_ind SET FIRST_NAME = vSubString WHERE responsible_ind_ID = LV_TABLE_ID;
	      		END IF;
	      	ELSEIF(vCount=2) THEN #MIDDLE NAME
	      		#Only Add Middle Name if there are three words 
	      		IF(vTotalWordCount = 3) THEN
	      			UPDATE responsible_ind SET MIDDLE_NAME = vSubString WHERE responsible_ind_ID = LV_TABLE_ID;
	      		ELSE
	      			UPDATE responsible_ind SET LAST_NAME = vSubString WHERE responsible_ind_ID = LV_TABLE_ID;
	      		END IF;
	      	ELSEIF(vCount=3) THEN #LAST NAME
	      		UPDATE responsible_ind SET LAST_NAME = vSubString WHERE responsible_ind_ID = LV_TABLE_ID;
			END IF;
	    ELSE
	    	IF(vCount=1) THEN #LAST NAME
	      		UPDATE responsible_ind SET LAST_NAME = vSubString WHERE responsible_ind_ID = LV_TABLE_ID;
	      	ELSEIF(vCount=2) THEN #FIRST NAME
	      		#Data with two initials such as A.B. is actually A. first name and B. is middle name
	      		IF(LOCATE('.',vSubString)=2) THEN
	      			#FIRST NAME INITIAL
	      			UPDATE responsible_ind SET FIRST_NAME = LEFT(vSubString,2) WHERE responsible_ind_ID = LV_TABLE_ID;
					#MIDDLE NAME INITIAL
	      			UPDATE responsible_ind SET MIDDLE_NAME = SUBSTRING(vSubString,3,2) WHERE responsible_ind_ID = LV_TABLE_ID;
	      		ELSE
	      			UPDATE responsible_ind SET FIRST_NAME = vSubString WHERE responsible_ind_ID = LV_TABLE_ID;
	      		END IF;	      		
	      	ELSEIF(vCount=3) THEN #MIDDLE NAME
	    		UPDATE responsible_ind SET MIDDLE_NAME = vSubString WHERE responsible_ind_ID = LV_TABLE_ID;      		
	    	END IF;
      	END IF;
	  END IF;
		
      SET vCount = vCount + 1;
  ELSE
      SET vDone = 0;
  END IF;
END WHILE;

END $$

DELIMITER ;

DROP procedure IF EXISTS sp_insert_special_cases_from_test_script;

DELIMITER $$

CREATE PROCEDURE sp_insert_special_cases_from_test_script ()
BEGIN
-- --------------------------------------------------------------------------------
-- Handle special cases where the name is not correctly being parsed.
-- The list below is created by a test script:  all_name_store_procedures_for_test.sql
-- and execute_all_name_store_procedures_for_test.sql.
-- --------------------------------------------------------------------------------	

#Begin Time
select CURTIME() as 'Start sp_insert_special_cases_from_test_script';

#The special case names have been redacted to protect confidentiality.

END $$

DELIMITER ;


