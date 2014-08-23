START TRANSACTION;

-- Rollback dod_funding_source rs data from 08/07/2013 backup file.
call sp_rollback_dod_funding_source_data();

-- Create rdds_pe_list table.
call sp_create_rdds_pe_list_table();

-- Create pe_updated_list table.
call sp_create_pe_updated_list_table();

-- Check all rs pe.
call sp_checked_all_rs_pe();

-- Update dod_funding_source with valid program elements.
call sp_update_dod_funding_source_with_valid_pe();

-- Clean Up Function and Store Procedures.
-- drop function IsNumeric;
drop procedure sp_rollback_dod_funding_source_data;
drop procedure sp_create_rdds_pe_list_table;
drop procedure sp_create_pe_updated_list_table;
drop procedure sp_checked_all_rs_pe;
drop procedure sp_update_dod_funding_source_with_valid_pe;
drop procedure sp_is_pe_valid;
drop function func_is_numeric;
drop function func_is_characters;
drop procedure sp_is_pe_valid_format;

-- Decided to not drop the RDDS_PE_LIST table.  URED will use it in the future.
#drop table dod_funding_source__ured_080713_after;
#drop table RDDS_PE_LIST;
#drop table PE_UPDATED_LIST;

COMMIT;