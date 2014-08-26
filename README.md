Portfolio Description:

The MySQL code was written for the Unified Research & Engineering Database (URED) project at Defense Technical Information Center (DTIC).  The major purpose of the databases is to collect information about research and development that is funded by the Department of Defense.  URED consisted of a web-based system that allows for rapid data entry, mining, analysis, and report creation.  Data is collected through a user interface, xml upload module, and web services.

1.  Program Elements are an identifier used by the Department of Defense military services and agencies.  The Program Elements are available to the public from Research and Development Descriptive Summaries (RDDS).  The Program Elements repository goes back ten years while the URED data that uses Program Elements goes back almost hundred years.  The rules to build Program Elements are defined here.  The rules to build Program Elements have changed over time.  DTIC wanted to determine which Program Elements in URED closely resembled the Program Elements in RDDS.  Using rules defined by DTIC, if a massaged Program Element from URED matches a RDDS the URED data would be updated with that Program Element.  The URED data is hundred of thousand records.

o	Execute the Program Elements script:
https://github.com/gdombchik/mysql_code/blob/master/execute_all_validate_pe_numbers_store_procedures.sql
o	The Program Element script:
https://github.com/gdombchik/mysql_code/blob/master/all_validate_pe_numbers_store_procedures.sql

2.  A Name field exists in multiple of tables.  For each table, parse and update the data from a Name field into a Prefix, First Name, Middle Name, Last Name, and Suffix fields.

o	Execute the parser script: 
https://github.com/gdombchik/mysql_code/blob/master/execute_all_name_store_procedures_1.sql
o	The parser script:
https://github.com/gdombchik/mysql_code/blob/master/all_name_store_procedures_1.sql

Technical Environment:  MySQL


Portfolio Location:

https://github.com/gdombchik/mysql_code