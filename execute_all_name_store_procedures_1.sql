START TRANSACTION;

-- Create prefix table.
call sp_create_prefix_table();

-- Create suffix table.
call sp_create_suffix_table();

-- Create transfer phrases to last name table.
call sp_create_transfer_phrases_to_last_name_table();

-- Parse performing_ind.name to first_name, middle_name, last_name, prefix, and suffix.
call sp_split_name_performing_ind();

-- Parse responsible_ind.name to first_name, middle_name, last_name, prefix, and suffix.
call sp_split_name_responsible_ind();

-- Handle special cases where the name is not correctly being parsed 
call sp_insert_special_cases();
call sp_insert_special_cases_from_test_script();

-- Clean Up.  Drop PREFIX and SUFFIX tables and Name Store Procedures'.
drop procedure sp_create_prefix_table;
drop procedure sp_create_suffix_table;
drop procedure sp_create_transfer_phrases_to_last_name_table;
drop procedure sp_update_prefix_performing_ind;
drop procedure sp_update_prefix_responsible_ind;
drop procedure sp_update_suffix_performing_ind;
drop procedure sp_update_suffix_responsible_ind;
drop procedure sp_update_transfer_phrases_to_last_name_for_performing_ind;
drop procedure sp_update_transfer_phrases_to_last_name_for_responsible_ind;
drop procedure sp_split_name_performing_ind;
drop procedure sp_split_name_responsible_ind;
drop procedure sp_insert_special_cases;
drop procedure sp_update_rs_data;
drop procedure sp_insert_special_cases_from_test_script;

drop table PREFIX;
drop table SUFFIX;
drop table TRANSFER_PHRASES_TO_LAST_NAME;

COMMIT;