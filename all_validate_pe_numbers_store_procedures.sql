DROP FUNCTION IF EXISTS func_is_characters;

DELIMITER $$

CREATE FUNCTION func_is_characters(val VARCHAR(25)) RETURNS tinyint(1)
BEGIN  
 DECLARE idx INT DEFAULT 0;  
 IF ISNULL(val) THEN RETURN 0; END IF;
 IF LENGTH(val) = 0 THEN RETURN 0; END IF;

  RETURN val REGEXP '^[A-Za-z]+$';

END $$

DELIMITER ;

DROP FUNCTION IF EXISTS func_is_numeric;

DELIMITER $$

CREATE FUNCTION func_is_numeric(val VARCHAR(25)) RETURNS tinyint(1)
BEGIN  
 DECLARE idx INT DEFAULT 0;  
 IF ISNULL(val) THEN RETURN 0; END IF;
 IF LENGTH(val) = 0 THEN RETURN 0; END IF;

  RETURN val REGEXP '^[0-9]+$';

END $$

DELIMITER ;

DROP procedure IF EXISTS sp_is_pe_valid_format;

DELIMITER $$

CREATE PROCEDURE sp_is_pe_valid_format (LV_CURRENT_PROGRAM_ELEMENT VARCHAR(10),LV_UPDATED_PROGRAM_ELEMENT VARCHAR(10),LV_ORG_SOURCE_COMPONENT_CODE VARCHAR(45),INOUT LV_UPDATED VARCHAR(1),LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE VARCHAR(1),LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE VARCHAR(1))
BEGIN
    -- --------------------------------------------------------------------------------
    -- helper function to help determine pe valid standard
    -- --------------------------------------------------------------------------------	
    DECLARE LV_DONE INT DEFAULT FALSE;
    DECLARE LV_PE_RETURNED VARCHAR(65);
    DECLARE LV_BA_RETURNED INT(1);
    DECLARE LV_BA INT(1);
    DECLARE LV_BA_STANDARD_FORMAT_VALUE INT(1);

    IF(LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE = 'Y') THEN
                SET LV_CURRENT_PROGRAM_ELEMENT = CONCAT('PE',LV_CURRENT_PROGRAM_ELEMENT);
    END IF;
                
    IF(LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE = 'Y') THEN
                SET LV_CURRENT_PROGRAM_ELEMENT = CONCAT('PE ',LV_CURRENT_PROGRAM_ELEMENT);
    END IF;

    IF(LV_UPDATED='N') THEN
        is_pe_valid: begin
	        
	        /*1.  Standard PE format (7 digits and (1 to 3 characters))
			2.  	-- DoD PROGRAM
						- First digit can be 0 or 1. 
						- If first digit is 1, second digit must be a 1.
					-- R&D CATEGORY
						- Third digit must be a 0.
						- Fourth digit is either 1 through 7.
					-- Equipment 
						- Fifth digit is either 1 through 8.
					- Service
						- Digits 8 through 10 is one of the below values	
					A Army 
	               	BB  U.S. Special Operations Command 
	               	BL  Defense Contract Management Agency 
	               	BP  Chemical & Biological Defense 
	               	BR  Defense Threat Reduction Agency 
	               	C    Missile Defense Agency 
	               	D8Z    Office of Secretary of Defense 
	               	DO Operational, Test & Evaluation Defense 
	               	E  DARPA 
	               	F Air Force 
 	               	J Joint Staff 
	              	K Defense Information Systems Agency 
	             	M  Marine Corps 
	             	N  Navy 
	             	S  Defense Logistics Agency 
	             	T  Defense Security Cooperation Agency 
	            	SE DoD Human Resources Activity 
	            	V Defense Security Center 
	            	KA Defense Technical Information Center 
	            	B8W Washington Headquarters Service*/
	                
            IF(LENGTH(LV_UPDATED_PROGRAM_ELEMENT) > 7 AND LENGTH(LV_UPDATED_PROGRAM_ELEMENT) < 11) THEN
                IF(func_is_numeric(LEFT(LV_UPDATED_PROGRAM_ELEMENT,7))=1) THEN
                    IF(func_is_characters(RIGHT(LV_UPDATED_PROGRAM_ELEMENT,LENGTH(LV_UPDATED_PROGRAM_ELEMENT)-7))=1) THEN
   						-- DoD PROGRAM
   							-- First digit can be 0 or 1. 
							-- If first digit is 1, second digit must be a 0 or 1.
                    	IF(SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,1,1)='0' 
                    		OR (SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,1,1)='1' AND SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,2,1)='1')
                    		OR (SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,1,1)='1' AND SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,2,1)='0')) THEN
                    		-- R&D CATEGORY
								-- Third digit must be a 0. AND SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,3,1)='0'
								-- Fourth digit is either 1 through 7.
                    		IF(SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,3,1)='0' /*AND (SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,4,1) > 0 AND SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,4,1) < 8) */) THEN
                    			-- Equipment 
									-- Fifth digit is either 1 through 8.
                    	-- 		IF((SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,5,1) > 0 AND SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,5,1) < 9) ) THEN
	                    			SET LV_UPDATED = 'Y';
		                        	SET LV_BA_STANDARD_FORMAT_VALUE = SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,4,1); 
		                        	insert into PE_UPDATED_LIST values (LV_CURRENT_PROGRAM_ELEMENT,LV_UPDATED_PROGRAM_ELEMENT,LV_ORG_SOURCE_COMPONENT_CODE,IF(LV_BA_RETURNED IS NOT NULL, LV_BA_RETURNED, IF(LV_BA_STANDARD_FORMAT_VALUE > 0 AND LV_BA_STANDARD_FORMAT_VALUE < 8,LV_BA_STANDARD_FORMAT_VALUE,NULL)))  /*ON DUPLICATE KEY UPDATE current_pe=LV_CURRENT_PROGRAM_ELEMENT,updated_pe=LV_UPDATED_PROGRAM_ELEMENT,org_source_component_code=LV_ORG_SOURCE_COMPONENT_CODE*/;
   						-- 		END IF;
		                        	
	                   		END IF;
	                        
	                        
	                   END IF;
                    	
                    	
                    	
                	END IF;
                END IF;
            END IF;
        
        end is_pe_valid;
    END IF;
 
END $$ 

DELIMITER ;

DROP procedure IF EXISTS sp_rollback_dod_funding_source_data;

DELIMITER $$

CREATE PROCEDURE sp_rollback_dod_funding_source_data ()
BEGIN
-- --------------------------------------------------------------------------------
-- New requirements require rollback of the dod_funding_source data to the 08/07/2013 backup file. 
-- --------------------------------------------------------------------------------	

#Begin Time
select CURTIME() as 'Start sp_rollback_dod_funding_source_data';

/*DROP TABLE IF EXISTS dod_funding_source__ured_080713_after;

SELECT 'Create dod_funding_source__ured_080713_after table';
#create the dod funcing source table from the 080713 backup.
CREATE TABLE `dod_funding_source__ured_080713_after` (
  `DOD_FUND_SOURCE_ID` int(10) unsigned NOT NULL,
  `PROGRAM_ELEMENT` varchar(10) NOT NULL,
  `PROJECT_NUMBER` varchar(14) DEFAULT NULL,
  `PROJECT_NUMBER_PACKED` varchar(14) DEFAULT NULL,
  `TASK_NUMBER` varchar(10) DEFAULT NULL,
  `TASK_NUMBER_PACKED` varchar(10) DEFAULT NULL,
  `CONGRESSIONAL_ADD` varchar(1) NOT NULL,
  `CONTRACT_NUMBER` varchar(27) NOT NULL,
  `CONTRACT_NUMBER_PACKED` varchar(50) DEFAULT NULL,
  `RESEARCH_PROJECT_ID` int(10) unsigned NOT NULL,
  `BUDGET_ACTIVITY_CODE` int(10) DEFAULT NULL,
  `DISTRIBUTION_CODE` varchar(1) DEFAULT NULL,
  `DISTRIBUTION_REASON_CODE` varchar(2) DEFAULT NULL,
  `CREATED_BY` varchar(100) NOT NULL,
  `CREATE_DATE` datetime NOT NULL,
  `UPDATED_BY` varchar(100) DEFAULT NULL,
  `LAST_UPDATE_DATE` datetime DEFAULT NULL,
  PRIMARY KEY (`DOD_FUND_SOURCE_ID`),
  KEY `fk_DOD_FUNDING_SOURCE_distribution_code1_cpy` (`DISTRIBUTION_CODE`),
  KEY `fk_DOD_FUNDING_SOURCE_distribution_reason1_cpy` (`DISTRIBUTION_REASON_CODE`),
  KEY `fk_dod_funding_source_research_project1_cpy` (`RESEARCH_PROJECT_ID`),
  KEY `fk_dod_funding_source_budget_activity_code1_cpy` (`BUDGET_ACTIVITY_CODE`),
  CONSTRAINT `fk_dod_funding_source_budget_activity_code1_cpy` FOREIGN KEY (`BUDGET_ACTIVITY_CODE`) REFERENCES `budget_activity_code` (`CODE`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_DOD_FUNDING_SOURCE_distribution_code1_cpy` FOREIGN KEY (`DISTRIBUTION_CODE`) REFERENCES `distribution_code` (`CODE`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_DOD_FUNDING_SOURCE_distribution_reason1_cpy` FOREIGN KEY (`DISTRIBUTION_REASON_CODE`) REFERENCES `distribution_reason` (`CODE`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_dod_funding_source_research_project1_cpy` FOREIGN KEY (`RESEARCH_PROJECT_ID`) REFERENCES `research_project` (`RESEARCH_PROJECT_ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=631401 DEFAULT CHARSET=utf8;

SELECT 'Populate dod_funding_source__ured_080713_after table';
#insert data into ured_prod_view dod_funding_source__ured_080713_after from backup table (dev database) that is only RS
insert into ured_prod_view.dod_funding_source__ured_080713_after
SELECT ured.dod_funding_source__ured_080713_after.* FROM ured.dod_funding_source__ured_080713_after, ured.research_project
where ured.dod_funding_source__ured_080713_after.research_project_id = ured.research_project.research_project_id
and ured.research_project.source_db = 'Research Summaries';*/

#Same as step 1 and step 2 (which I am using)
#create_table___dod_funding_source__ured_080713_after.sql

SELECT 'Rollback the RS data in the dod_funding_source from the dod_funding_source__ured_080713_after table';
#replace dod_funding_source program_element, last_update_date, BUDGET_ACTIVITY_CODE from the backup file
update dod_funding_source,
dod_funding_source__ured_080713_after,
research_project 
set dod_funding_source.program_element = dod_funding_source__ured_080713_after.program_element,
dod_funding_source.last_update_date = dod_funding_source__ured_080713_after.last_update_date,
dod_funding_source.BUDGET_ACTIVITY_CODE = dod_funding_source__ured_080713_after.BUDGET_ACTIVITY_CODE
where research_project.research_project_id = dod_funding_source.research_project_id and
dod_funding_source.dod_fund_source_id = dod_funding_source__ured_080713_after.dod_fund_source_id and
research_project.source_db = 'Research Summaries';

#End Time
select CURTIME() as 'End sp_rollback_dod_funding_source_data'; 

END $$

DELIMITER ;

DROP procedure IF EXISTS sp_create_rdds_pe_list_table;

DELIMITER $$

CREATE PROCEDURE sp_create_rdds_pe_list_table ()
BEGIN
-- --------------------------------------------------------------------------------
-- create rdds_pe_list table
-- --------------------------------------------------------------------------------	

#Begin Time
select CURTIME() as 'Start sp_create_rdds_pe_list_table';

DROP TABLE IF EXISTS RDDS_PE_LIST;

CREATE TABLE RDDS_PE_LIST (pe varchar(10) NOT NULL, ba INT(10) NULL, PRIMARY KEY (pe));

INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0101113f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0101122f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0101126F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0101127F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0101221N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0101224N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0101226N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0101313F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0101314F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0101402N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0102325f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0102326f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0102419a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0102823F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203347A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203726a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203735a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203740a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203744a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203752a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203758a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203759a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203761F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203761N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203801a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203802a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203808A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204136N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204152N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204163N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204228N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204229N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204311N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204413N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204460M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204571N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204574N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204575N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0205219F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0205601N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0205604N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0205620N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0205632N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0205633N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0205658N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0205675N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0206313M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0206623M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0206624M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0206625M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207040F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207131f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207133f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207134f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207136f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207138F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207142F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207161f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207161N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207163f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207163N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207170F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207224F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207227F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207247f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207249F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207253f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207268f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207277F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207325f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207410F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207412f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207417f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207418F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207423f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207431F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207438f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207444F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207445F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207446F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207448F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207449F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207452F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207581f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207590f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207601f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207605f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207697F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208006f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208021f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208043J',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208045K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208053a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208058A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208058N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208059F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208087F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208088F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0301144K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0301359A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0301400F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0302015f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0302016K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0302019K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303028A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303109N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303126K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303131f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303131K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303138N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303140a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303140D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303140f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303140K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303140N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303141A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303141f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303142a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303148K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303149J',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303150a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303150f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303150K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303150M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303153K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303158F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303158M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303158N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303170K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303238N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303260D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303601f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303610K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303901N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303906N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303908N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303910N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303911N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0304210BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0304260F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305099f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305103D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305103F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305103K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305105F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305110f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305111f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305114f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305116F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305125D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305128f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305145F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305146F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305149N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305160N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305164f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305165f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305173F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305174F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305179F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305182f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305186D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305192N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305193F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305199D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305202F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305204a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305204N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305205f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305205N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305206f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305206N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305207f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305207N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305208a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305208BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305208f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305208K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305208M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305208N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305219A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305219BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305219F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305220F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305220N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305221F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305231BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305231N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305232A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305232M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305233A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305233N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305234M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305234N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305235A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305236F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305237N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305238F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305239M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305240F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305241N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305265F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305387D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305600D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305614F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305881F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305887F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305913f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305924F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305940F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0307141F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0307207A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0307207N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0307217N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0307665A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0307802N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0308601N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0308699f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401115F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401119f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401130f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401132F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401134F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401139F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401218f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401219F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401314F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401315F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401839F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0408011F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603423F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603778a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603820A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604130V',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604227N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604263F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604402N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604445F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604717M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604766M',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605018F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605024F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605127T',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605147T',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605502T',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605525N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605555N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0607141A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0607210D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0607310D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0607327T',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0607384BP',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0607665A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0607713S',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0607828D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0607828J',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0607865A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0702207f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0702207N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0702239N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0702976F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708011N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708011S',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708012F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708012s',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708045a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708610F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708611f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708730N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0801711F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0804743F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0804757F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0804772F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0808716F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0901202F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0901212F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0901218f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0901220F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0901226F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0901279F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0901538F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0902298J',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0902998F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1001018D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1105219BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1105232BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1105233BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1150219BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160279BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160403BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160404BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160405BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160408BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160421BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160423BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160426BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160427BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160428BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160429BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160431BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160432BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160474BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160476BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160477BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160478BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160479BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160480BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160481BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160482BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160483BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160484BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160488BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160489BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160490BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203345D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204571J',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303166D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303166J',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303169D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305103E',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305193D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305400D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305885N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603757D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604256a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604256f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604256N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604258a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604258N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604759a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604759f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604759N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604774D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604875D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604940D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604942D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604943D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605100D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605101f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605103a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605104D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605110D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605117D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605118OTE',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605126J',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605126N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605128D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605130D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605131OTE',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605142D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605151D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605152N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605154N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605161D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605170D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605200D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605301a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605326a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605384BP',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605502A',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605502BP',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605502BR',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605502C',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605502D8W',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605502D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605502E',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605502F',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605502N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605502S',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605601a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605602a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605604a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605605a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605606a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605702a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605706a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605709a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605712a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605712f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605716a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605718A',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605790D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605798D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605799D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605801a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605801KA',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605803a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605803SE',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605804D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605804N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605805a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605807f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605814OTE',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605853N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605856N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605857A',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605860f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605861N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605863N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605864f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605864N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605865N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605866N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605867N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605873M',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605897E',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605898a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605898E',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605976F',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605978F',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0606100D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0606301D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0606323F',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0606392F',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0702806F',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0804731F',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0804758N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0804767D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0901585C',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0901598C',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0901598D8W',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0909980F',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0909980N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0909990F',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0909999A',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0909999D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0909999F',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0909999N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1001004f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0101125F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204201N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0204202N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207100F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207434F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207451F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207604F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207701F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303032A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303141K',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303158K',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0304231N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0304270A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0304503N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0304785N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305124N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305176f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305230F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305304D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401138F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401318F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401845F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603260f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603840F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604051D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604161D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604165D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604201a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604212N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604214N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604215N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604216N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604218N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604220A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604221N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604222f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604226f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604230N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604231N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604233f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604234N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604240f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604245N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604261N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604262N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604264N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604269N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604270a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604270f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604270N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604273N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604274N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604280a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604280F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604280N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604281F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604287F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604290A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604300N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604307N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604311N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604321a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604328A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604329F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604329N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604366N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604373N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604376M',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604378N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604384BP',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604404N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604421F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604425F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604429F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604441f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604443F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604501N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604503N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604504N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604512N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604518N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604558N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604562N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604567N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604574N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604601a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604601N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604602f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604604a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604604f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604609a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604610N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604611a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604617f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604622a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604633a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604641a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604642a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604646A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604654N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604660A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604661A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604662A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604663A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604664A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604665A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604703N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604706f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604709D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604710a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604713a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604715a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604716a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604727N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604735f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604740f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604741a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604742A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604746a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604750f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604755N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604756N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604757N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604760a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604761N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604764K',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604771D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604771N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604777N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604778a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604780a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604798A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604800F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604800M',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604800N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604802a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604804a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604805a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604807a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604808a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604814a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604817a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604818a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604820a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604822A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604823a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604827A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604851f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604853f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604854a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604869A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604870A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604932F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604933F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605000BR',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605011f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605013A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605013BL',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605013M',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605013N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605018A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605018BTA',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605018N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605020BTA',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605021SE',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605022D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605027D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605028A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605030A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605070S',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605075D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605080S',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605140D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605210D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605212N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605213F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605221F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605229F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605277F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605278F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605380A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605430N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605431F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605432F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605433F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605450A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605450N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605452F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605455A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605456A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605457A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605500N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605625A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605626A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605648D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605766A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605812A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605931F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0807708D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0105921F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207455F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303191D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303354N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303562N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0304270N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305103C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305178F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305205A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603024A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603128N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603161D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603207N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603216N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603237N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603251N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603254N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603261N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603287F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603305A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603308a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603327A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603382N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603430f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603432f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603438f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603502N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603506N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603512N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603513N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603525N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603527D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603527N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603536N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603542N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603553N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603561N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603562N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603563N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603564N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603570N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603573N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603576N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603581N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603582N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603600D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603609N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603611M',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603619a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603627A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603635M',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603639a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603653a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603654N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603658N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603709D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603713N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603714D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603721N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603724N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603725N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603734N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603739N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603742f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603746N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603747a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603748N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603751N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603755N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603764N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603766a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603774a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603779A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603782A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603787N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603790a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603790f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603790N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603791F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603795N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603801a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603804a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603805a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603807a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603827A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603830F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603845F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603850A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603850f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603851D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603851f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603851M',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603854f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603859F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603860f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603860N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603879N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603881C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603882C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603883C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603884BP',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603884C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603886C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603888C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603889N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603890C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603891C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603892C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603893C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603894C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603895C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603896C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603897C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603898C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603904C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603906C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603907C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603908C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603909C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603911C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603912C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603913C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603914C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603915C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603920D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603923D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603925N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604015F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604016D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604115A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604131A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604250D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604272N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604279N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604283F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604284A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604317F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604319A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604327f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604330F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604337F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604400D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604422F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604436F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604445J',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604458F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604618f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604635F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604648D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604653N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604659N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604670D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604707N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604775A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604775D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604775F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604775N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604785A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604786N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604787D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604787J',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604796F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604828D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604828J',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604830F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604857F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604858F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604880C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604881C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604883C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604884C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604886C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605017D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605812M',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303310D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603000D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603001a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603002a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603003a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603004a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603005a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603006a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603007a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603008A',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603009A',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603015A',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603020A',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603105a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603112f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603114N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603121D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603122D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603123N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603125A',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603130A',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603131A',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603160BR',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603175C',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603199F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603200D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603203f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603211f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603216f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603225D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603231f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603235N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603236N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603250D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603264S',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603270a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603270f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603271N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603274C',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603286E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603287E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603313a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603322A',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603384BP',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603401f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603444F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603456F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603461A',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603601f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603605f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603606a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603607a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603618D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603640M',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603648D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603651M',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603662D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603663D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603665D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603668D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603670D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603673N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603680D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603680F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603699D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603710a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603711D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603712S',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603713S',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603716D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603720S',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603727D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603728a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603729N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603734a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603739E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603745D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603747N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603750D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603755D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603758N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603760E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603765E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603766E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603767E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603768E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603769SE',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603772a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603781D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603782N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603788F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603789f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603805S',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603826D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603828D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603828J',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603832D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603901C',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603902C',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603924F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603941D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603942D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604055D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160402BB',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160422BB',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160472BB',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0302168E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601101HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601117HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602000D8Z',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602102f',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602105a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602114N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602115E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602115HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602120a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602122A',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602123N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602131M',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602201f',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602202f',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602203f',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602204f',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602211a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602228D8Z',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602234D8Z',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602234N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602235N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602236N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602250D8Z',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602251D8Z',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602270a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602271N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602303a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602303E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602304E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602305E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602307A',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602308a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602383E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602384BP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602435N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602601a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602601f',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602602f',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602605F',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602618a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602622a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602623a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602624a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602651M',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602663D8Z',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602668D8Z',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602670D8Z',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602702E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602702f',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602705a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602709a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602712a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602715E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602716a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602716E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602718BR',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602720a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602747N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602750N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602751D8Z',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602782a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602782N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602783a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602784a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602785a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602786a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602787a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602787HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602788F',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602890F',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603002HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603115HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604110HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605013HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605023HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605025HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605145HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605502HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0606105HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0607100HP',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160401BB',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160407BB',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601000BR',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601101a',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601101E',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601102a',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601102f',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601103A',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601103F',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601103N',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601104a',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601108F',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601110D8Z',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601111D8Z',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601114D8Z',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601117E',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601120D8Z',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601152N',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601153N',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601228D8Z',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601384BP',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0101120f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0102411f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0104136N',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203610a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203761a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203762a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0203763a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0205667N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207027f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207028F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207131Fa',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207141f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207256F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207320f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207414f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207443F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207446',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0207450F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208010a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208031f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208052J',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208060f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208161F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0208889F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0300205R',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0301310F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303110f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303112F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303127K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303129K',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303149K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303150N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303158A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303165K',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0303401F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305108K',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305114a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305119f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305127D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305127V',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305128a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305137f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305138f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305144f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305146D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305148F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305158f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305160f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305188N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305190D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305191D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305206a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305840K',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305840S',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305906f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305910f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305911f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305917D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305917f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305927N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305953f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305972N',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0308601f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401133F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401214f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401221F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0401840F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0404011F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0508713N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0600412N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0600515N',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601101D8Z',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601103D8Z',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601105A',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601105D8Z',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601108D8Z',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601114A',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0601228A',1);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602015F',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602110E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602111N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602121N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602122D8Z',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602122N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602131N',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602173C',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602227D8Z',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602232N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602233N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602269f',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602270N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602301E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602302E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602314N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602315N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602500F',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602616BR',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602633N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602708E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602712E',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602715BR',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602716BR',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602717BR',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602787D8Z',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602789a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602805a',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602805f',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602805N',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0602890D8Z',2);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603002D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603023A',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603103A',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603104D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603106f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603108f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603173C',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603174C',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603202f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603205f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603208N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603217N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603227f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603228D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603232D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603238a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603238N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603245f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603253f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603270N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603280A',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603285E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603302f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603311f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603319f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603333F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603400D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603400F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603402f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603410f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603421F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603422F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603427F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603434f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603436F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603441f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603460A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603500F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603508N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603514N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603554N',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603559N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603612M',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603617f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603640a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603645a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603654a',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603690f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603704D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603706N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603707f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603707N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603711BR',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603712N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603713a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603723f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603726f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603727N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603728D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603728f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603736D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603738D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603755F',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603757N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603762E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603763E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603764E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603769D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603773A',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603790T',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603792N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603794N',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603800f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603800N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603802a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603835D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603850Fa',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603851N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603854a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603856a',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603856f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603857J',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603857N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603858D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603858F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603861C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603868C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603869A',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603869C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603870C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603871C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603872C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603873C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603874C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603875C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603876C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603876f',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603880C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603889C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603892D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603905C',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603910D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603924D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603943D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604012f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604140D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604201f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604217N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604223a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604227f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604235N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604237f',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604239f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604251F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604258f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604259N',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604261F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604310N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604312N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604327N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604328F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604329A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604355N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604400F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604435F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604442f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604450N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604479f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604480f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604507N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604524N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604528N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604561N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604600f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604603N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604612M',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604618D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604618N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604619a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604640a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604645a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604647A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604649a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604666A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604703f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604708f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604710N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604721N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604722D8Z',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604726a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604727f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604731F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604731Fa',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604738A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604739a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604745F',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604746K',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604754f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604754N',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604762f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604766a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604768a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604770a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604779f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604783A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604784N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604787N',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604801a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604805D8Z',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604805f',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604805N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604819A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604824a',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604855F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604856F',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604861C',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604865A',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604865C',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604867C',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604910N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605013',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605013D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605013S',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605014N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605014S',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605014SE',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605015',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605015BL',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605015N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605015S',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605016D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605018SE',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605019D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605027D9Z',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605104T',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605110BR',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605110T',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605114D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605116D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605118D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605123D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605124D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605131D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605155N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605160BR',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605160D8Z',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605172N',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605306f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605710D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605798S',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605799DHZ',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605801K',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605803S',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605804',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605806D8Z',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605807Fa',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605808f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605853a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605854a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605854f',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605856a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605862N',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605873N',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605876a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605878a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605879a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605885N',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605896a',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0607441A',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('060S127T',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0702239A',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0702239F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708011f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708026f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708071f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708612F',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0708730',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0804757Fa',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('084731F',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0901200D8Z',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0901539F',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0902740J',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0904903D',4);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('10001018A',NULL);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1001018a',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1001018f',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160425BB',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('1160444BB',7);

#Extract from PE_ values
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0908612C',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0604218C',5);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603761E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603753S',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603228D',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0605801S',6);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305188J',7);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603747E',3);
INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0305207D',7);

#Just a test value.  will be removed.
#INSERT INTO `RDDS_PE_LIST` (`pe`,`ba`) VALUES ('0603238D',7);

#End Time
select CURTIME() as 'End sp_create_rdds_pe_list_table'; 

END $$

DELIMITER ;

DROP procedure IF EXISTS sp_create_pe_updated_list_table;

DELIMITER $$

CREATE PROCEDURE sp_create_pe_updated_list_table ()
BEGIN
-- --------------------------------------------------------------------------------
-- create sp_create_pe_updated_list_table table
-- --------------------------------------------------------------------------------	

#Begin Time
select CURTIME() as 'Start sp_create_pe_updated_list_table';

DROP TABLE IF EXISTS PE_UPDATED_LIST;

CREATE TABLE PE_UPDATED_LIST (current_pe varchar(10) NOT NULL,updated_pe varchar(10) NOT NULL, org_source_component_code varchar(45) NOT NULL, budget_activity_code int(10), PRIMARY KEY (current_pe,updated_pe,org_source_component_code));

#End Time
select CURTIME() as 'End sp_create_pe_updated_list_table'; 

END $$

DELIMITER ;

DROP procedure IF EXISTS sp_update_dod_funding_source_with_valid_pe;

DELIMITER $$

CREATE PROCEDURE sp_update_dod_funding_source_with_valid_pe ()
BEGIN
-- --------------------------------------------------------------------------------
-- update dod_funding_source with valid program elements
-- --------------------------------------------------------------------------------	

#Begin Time
select CURTIME() as 'Start sp_update_dod_funding_source_with_valid_pe';

UPDATE dod_funding_source,PE_UPDATED_LIST,research_project 
SET dod_funding_source.PROGRAM_ELEMENT = PE_UPDATED_LIST.updated_pe, dod_funding_source.last_update_date = now(), dod_funding_source.BUDGET_ACTIVITY_CODE = PE_UPDATED_LIST.budget_activity_code
WHERE dod_funding_source.PROGRAM_ELEMENT = PE_UPDATED_LIST.current_pe 
AND dod_funding_source.research_project_id = research_project.research_project_id 
AND research_project.org_source_component_code = PE_UPDATED_LIST.org_source_component_code;

#End Time
select CURTIME() as 'End sp_update_dod_funding_source_with_valid_pe'; 

END $$

DELIMITER ;

DROP procedure IF EXISTS sp_is_pe_valid;

DELIMITER $$

CREATE PROCEDURE sp_is_pe_valid (LV_CURRENT_PROGRAM_ELEMENT VARCHAR(10),LV_UPDATED_PROGRAM_ELEMENT VARCHAR(10),LV_ORG_SOURCE_COMPONENT_CODE VARCHAR(45),INOUT LV_UPDATED VARCHAR(1),LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE VARCHAR(1),LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE VARCHAR(1))
BEGIN
    -- --------------------------------------------------------------------------------
    -- helper function to help determine pe valid
    -- --------------------------------------------------------------------------------	
    DECLARE LV_DONE INT DEFAULT FALSE;
	DECLARE LV_PE_RETURNED VARCHAR(65);
	DECLARE LV_BA_RETURNED INT(1);
	DECLARE LV_BA INT(1);
    
	IF(LV_UPDATED='N') THEN
	    is_pe_valid: begin
	        DECLARE LV_PE_RETURNED INT DEFAULT FALSE;
	        DECLARE is_pe_valid_cursor CURSOR FOR select pe,ba from RDDS_PE_LIST where pe in (LV_UPDATED_PROGRAM_ELEMENT);
	        DECLARE CONTINUE HANDLER FOR NOT FOUND SET LV_DONE = TRUE;
	        
	        OPEN is_pe_valid_cursor;
	        
	        is_pe_valid_cursor: LOOP
	        FETCH is_pe_valid_cursor INTO LV_PE_RETURNED,LV_BA_RETURNED;

        		IF(LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE = 'Y') THEN
					SET LV_CURRENT_PROGRAM_ELEMENT = CONCAT('PE',LV_CURRENT_PROGRAM_ELEMENT);
				END IF;
				
				IF(LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE = 'Y') THEN
					SET LV_CURRENT_PROGRAM_ELEMENT = CONCAT('PE ',LV_CURRENT_PROGRAM_ELEMENT);
				END IF;
	        
	            IF LV_DONE THEN
					#SELECT CONCAT('IN IF. LV_CURRENT_PROGRAM_ELEMENT=', LV_CURRENT_PROGRAM_ELEMENT,' LV_UPDATED_PROGRAM_ELEMENT=',LV_UPDATED_PROGRAM_ELEMENT);
	            	SET LV_UPDATED = 'N';
	            	#only update if the current program element or converted program element is not found in rdds 
	            	IF(LENGTH(TRIM(LV_UPDATED_PROGRAM_ELEMENT))=0) THEN	            	
	            		insert into PE_UPDATED_LIST values (LV_CURRENT_PROGRAM_ELEMENT,LV_UPDATED_PROGRAM_ELEMENT,LV_ORG_SOURCE_COMPONENT_CODE,NULL);
	            	END IF;
	                LEAVE is_pe_valid_cursor;
	            ELSE
					#SELECT CONCAT('IN ELSE. LV_CURRENT_PROGRAM_ELEMENT=', LV_CURRENT_PROGRAM_ELEMENT,' LV_UPDATED_PROGRAM_ELEMENT=',LV_UPDATED_PROGRAM_ELEMENT);
	            	SET LV_UPDATED = 'Y';	 
	                insert into PE_UPDATED_LIST values (LV_CURRENT_PROGRAM_ELEMENT,LV_UPDATED_PROGRAM_ELEMENT,LV_ORG_SOURCE_COMPONENT_CODE,IF(LV_BA_RETURNED IS NOT NULL, LV_BA_RETURNED, SUBSTRING(LV_UPDATED_PROGRAM_ELEMENT,4,1)));
	                LEAVE is_pe_valid_cursor;
	            END IF;
	
	        END LOOP is_pe_valid_cursor;
	        
	        CLOSE is_pe_valid_cursor;
	    end is_pe_valid;
	END IF;
END $$ 

DELIMITER ;

DROP procedure IF EXISTS sp_checked_all_rs_pe;

DELIMITER $$

CREATE PROCEDURE sp_checked_all_rs_pe ()
BEGIN
    -- --------------------------------------------------------------------------------
    -- Loop through all rs pe numbers
    -- --------------------------------------------------------------------------------	
    DECLARE LV_DONE INT DEFAULT FALSE;

    DECLARE LV_CURRENT_PROGRAM_ELEMENT VARCHAR(20);
    DECLARE LV_UPDATED_PROGRAM_ELEMENT VARCHAR(20);
    DECLARE LV_ORG_SOURCE_COMPONENT_CODE VARCHAR(45);
    DECLARE LV_INNER_COUNTER INT DEFAULT 0;
    DECLARE LV_OUTER_COUNTER INT DEFAULT 0;
    DECLARE LV_UPDATED VARCHAR(1) DEFAULT 'N';
    DECLARE LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE VARCHAR(1) DEFAULT 'N';
    DECLARE LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE VARCHAR(1) DEFAULT 'N';
    
	#Returns all the Research Summary Performing Individual records
    DECLARE checked_all_rs_pe_cursor CURSOR FOR 
	select distinct  b.program_element,a.org_source_component_code
	from research_project a, dod_funding_source b 
	WHERE a.research_project_id = b.research_project_id and source_db = 'Research Summaries'
	and b.program_element <> ' '
	#and b.program_element REGEXP '^6'
	order by b.program_element;
	    
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET LV_DONE = TRUE;
    
    #Begin Time
    select CURTIME() as 'Start sp_checked_all_rs_pe';

    OPEN checked_all_rs_pe_cursor;

    checked_all_rs_pe_loop: LOOP
    FETCH checked_all_rs_pe_cursor INTO LV_CURRENT_PROGRAM_ELEMENT,LV_ORG_SOURCE_COMPONENT_CODE;
    
        IF LV_DONE THEN
          LEAVE checked_all_rs_pe_loop;
        END IF;
                
        #If the PE starts with 'PE<space>', remove it
        IF(SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,1,3)='PE ') THEN
        	SET LV_CURRENT_PROGRAM_ELEMENT = SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT FROM 4);
        	SET LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE = 'Y';
        	SET LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE = 'N';
        #If the PE starts with 'PE', remove it
        ELSEIF(SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,1,2)='PE') THEN
        	SET LV_CURRENT_PROGRAM_ELEMENT = SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT FROM 3);
        	SET LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE = 'Y';
        	SET LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE = 'N';
        ELSE
        	SET LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE = 'N';
        	SET LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE = 'N';
        END IF;
        
        IF(LENGTH(LV_CURRENT_PROGRAM_ELEMENT)>0) THEN
 	       	#-------------------------------------------------------------------------
        	#Checks against the RDDS List
			#-------------------------------------------------------------------------
        	#check originial value
        	call sp_is_pe_valid(LV_CURRENT_PROGRAM_ELEMENT,LV_CURRENT_PROGRAM_ELEMENT,LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#check originial value and second character of org source component code at the end and check
        	call sp_is_pe_valid(LV_CURRENT_PROGRAM_ELEMENT,CONCAT(LV_CURRENT_PROGRAM_ELEMENT,RIGHT(LV_ORG_SOURCE_COMPONENT_CODE,1)),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#add 0 on index 0 and check
        	call sp_is_pe_valid(LV_CURRENT_PROGRAM_ELEMENT,CONCAT('0',LV_CURRENT_PROGRAM_ELEMENT),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#add 0 on index 2, second character of org source component code at the end and check
        	call sp_is_pe_valid(LV_CURRENT_PROGRAM_ELEMENT,CONCAT(LEFT(LV_CURRENT_PROGRAM_ELEMENT,1),'0',SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,2),RIGHT(LV_ORG_SOURCE_COMPONENT_CODE,1)),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#add 0 on index 0, second character of org source component code at the end and check
        	call sp_is_pe_valid(LV_CURRENT_PROGRAM_ELEMENT,CONCAT('0',LV_CURRENT_PROGRAM_ELEMENT,RIGHT(LV_ORG_SOURCE_COMPONENT_CODE,1)),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#add 0 on index 0 and 0 on index 2 and check
        	call sp_is_pe_valid(LV_CURRENT_PROGRAM_ELEMENT,CONCAT('0',LEFT(LV_CURRENT_PROGRAM_ELEMENT,1),'0',SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,2)),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#add 0 on index 0, 0 on index 2, second character of org source component code at the end and check
        	call sp_is_pe_valid(LV_CURRENT_PROGRAM_ELEMENT,CONCAT('0',LEFT(LV_CURRENT_PROGRAM_ELEMENT,1),'0',SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,2),RIGHT(LV_ORG_SOURCE_COMPONENT_CODE,1)),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#if pe ends with a D, add 0 on index 0, 0 on index 2, add 8Z at the end and check (Example:  61103D changed to 0601103D8Z)
        	IF(right(LV_CURRENT_PROGRAM_ELEMENT,1) = 'D') THEN
        		call sp_is_pe_valid(LV_CURRENT_PROGRAM_ELEMENT,CONCAT('0',LEFT(LV_CURRENT_PROGRAM_ELEMENT,1),'0',SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,2),'8Z'),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);	
        	END IF;
        	
        	#if pe ends with a H, add 0 on index 0, remove 0 3rd character from end, remove H with BR (Example:  6027105H changed to 0602715BR)
        	IF(right(LV_CURRENT_PROGRAM_ELEMENT,1) = 'H') THEN
        		call sp_is_pe_valid(LV_CURRENT_PROGRAM_ELEMENT,CONCAT(LEFT(CONCAT('0',LEFT(LV_CURRENT_PROGRAM_ELEMENT,5),RIGHT(LV_CURRENT_PROGRAM_ELEMENT,2)),7),'BR'),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);	
        	END IF;
        	
        	#if pe ends with a E, add 0 on index 0, 0 on index 2, remove E with F (Example: 63227E changed to 0603227F)
        	IF(right(LV_CURRENT_PROGRAM_ELEMENT,1) = 'E') THEN
        		call sp_is_pe_valid(LV_CURRENT_PROGRAM_ELEMENT,
									CONCAT(SUBSTRING(CONCAT('0',LEFT(LV_CURRENT_PROGRAM_ELEMENT,1),'0',SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,2)),1,LENGTH(CONCAT('0',LEFT(LV_CURRENT_PROGRAM_ELEMENT,1),'0',SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,2)))-1),'F'),
									LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);	
        	END IF;
        	
        	#if the program element is not found, make the program element blank
        	#call sp_is_pe_valid(LV_CURRENT_PROGRAM_ELEMENT,' ',LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	#-------------------------------------------------------------------------
        	#Checks if the PE is in a standard PE format (7 digits and (1 to 3 characters))
			#-------------------------------------------------------------------------
			#check originial value
        	call sp_is_pe_valid_format(LV_CURRENT_PROGRAM_ELEMENT,LV_CURRENT_PROGRAM_ELEMENT,LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#check originial value and second character of org source component code at the end and check
        	call sp_is_pe_valid_format(LV_CURRENT_PROGRAM_ELEMENT,CONCAT(LV_CURRENT_PROGRAM_ELEMENT,RIGHT(LV_ORG_SOURCE_COMPONENT_CODE,1)),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#add 0 on index 0 and check
        	call sp_is_pe_valid_format(LV_CURRENT_PROGRAM_ELEMENT,CONCAT('0',LV_CURRENT_PROGRAM_ELEMENT),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#add 0 on index 2, second character of org source component code at the end and check
        	call sp_is_pe_valid_format(LV_CURRENT_PROGRAM_ELEMENT,CONCAT(LEFT(LV_CURRENT_PROGRAM_ELEMENT,1),'0',SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,2),RIGHT(LV_ORG_SOURCE_COMPONENT_CODE,1)),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#add 0 on index 0, second character of org source component code at the end and check
        	call sp_is_pe_valid_format(LV_CURRENT_PROGRAM_ELEMENT,CONCAT('0',LV_CURRENT_PROGRAM_ELEMENT,RIGHT(LV_ORG_SOURCE_COMPONENT_CODE,1)),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#add 0 on index 0 and 0 on index 2 and check
        	call sp_is_pe_valid_format(LV_CURRENT_PROGRAM_ELEMENT,CONCAT('0',LEFT(LV_CURRENT_PROGRAM_ELEMENT,1),'0',SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,2)),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#add 0 on index 0, 0 on index 2, second character of org source component code at the end and check
        	call sp_is_pe_valid_format(LV_CURRENT_PROGRAM_ELEMENT,CONCAT('0',LEFT(LV_CURRENT_PROGRAM_ELEMENT,1),'0',SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,2),RIGHT(LV_ORG_SOURCE_COMPONENT_CODE,1)),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);
        	
        	#if pe ends with a D, add 0 on index 0, 0 on index 2, add 8Z at the end and check (Example:  61103D changed to 0601103D8Z)
        	IF(right(LV_CURRENT_PROGRAM_ELEMENT,1) = 'D') THEN
        		call sp_is_pe_valid_format(LV_CURRENT_PROGRAM_ELEMENT,CONCAT('0',LEFT(LV_CURRENT_PROGRAM_ELEMENT,1),'0',SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,2),'8Z'),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);	
        	END IF;
        	
        	#if pe ends with a H, add 0 on index 0, remove 0 3rd character from end, remove H with BR (Example:  6027105H changed to 0602715BR)
        	IF(right(LV_CURRENT_PROGRAM_ELEMENT,1) = 'H') THEN
        		call sp_is_pe_valid_format(LV_CURRENT_PROGRAM_ELEMENT,CONCAT(LEFT(CONCAT('0',LEFT(LV_CURRENT_PROGRAM_ELEMENT,5),RIGHT(LV_CURRENT_PROGRAM_ELEMENT,2)),7),'BR'),LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);	
        	END IF;
        	
        	#if pe ends with a E, add 0 on index 0, 0 on index 2, remove E with F (Example: 63227E changed to 0603227F)
        	IF(right(LV_CURRENT_PROGRAM_ELEMENT,1) = 'E') THEN
        		call sp_is_pe_valid_format(LV_CURRENT_PROGRAM_ELEMENT,
									CONCAT(SUBSTRING(CONCAT('0',LEFT(LV_CURRENT_PROGRAM_ELEMENT,1),'0',SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,2)),1,LENGTH(CONCAT('0',LEFT(LV_CURRENT_PROGRAM_ELEMENT,1),'0',SUBSTRING(LV_CURRENT_PROGRAM_ELEMENT,2)))-1),'F'),
									LV_ORG_SOURCE_COMPONENT_CODE,LV_UPDATED,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE,LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE);	
        	END IF;
       	#ELSE
       		#Handles PE that just have the value 'PE'
       		#IF(LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE = 'Y' OR LV_CURRENT_PROGRAM_ELEMENT_STARTS_WITH_PE_SPACE = 'Y') THEN
			#	insert into PE_UPDATED_LIST values ('PE',' ',LV_ORG_SOURCE_COMPONENT_CODE,NULL);
			#END IF;
        END IF;
        
        #Reset pe updated flag back to no
        SET LV_UPDATED = 'N'; 
        
        SET LV_INNER_COUNTER = LV_INNER_COUNTER + 1;
        SET LV_OUTER_COUNTER = LV_OUTER_COUNTER + 1;

        IF(LV_INNER_COUNTER = 5000)THEN
            SELECT LV_OUTER_COUNTER AS "Total Records Processed";
            SET LV_INNER_COUNTER = 0;
            #LEAVE checked_all_rs_pe_loop;
        END IF;
   
    END LOOP checked_all_rs_pe_loop;
    

    CLOSE checked_all_rs_pe_cursor;  

    SELECT LV_OUTER_COUNTER AS "Total Records Processed";
    
    #End Time
    select CURTIME() as 'End sp_checked_all_rs_pe';
END $$

DELIMITER ;

