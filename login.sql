set sqlformat ansiconsole
set statusbar on
set statusbar add editmode 
set statusbar add txn
set statusbar add timing
set highlighting on
set highlighting keyword foreground green
set highlighting identifier foreground magenta
set highlighting string foreground yellow
set highlighting number foreground cyan
set highlighting comment background white
set highlighting comment foreground black

alias usr=select username, account_status, default_tablespace, created, profile from dba_users where oracle_maintained='N' order by username;
alias sess=select count(*), username, machine from v$session group by username, machine order by username, machine;
alias dblinks=select * from dba_db_links order by db_link;
alias registry=select comp_name, version, status from dba_registry;
alias invalid=select count(*), owner, object_type from dba_objects where status = 'INVALID' group by owner, object_type order by owner, object_type;
alias connxe=conn scott/tiger@"host.docker.internal:1521/xepdb1";

PROMPT -- Note: SQLFORMAT is ANSICONSOLE
PROMPT --       STATUSBAR is ON
PROMPT --       HIGHLIGHTING is ON
PROMPT -- Sample connection string:
PROMPT --    SQL> conn scott/tiger@host.docker.internal:1521/xepdb1
PROMPT -- or using alias for local XE installation:
PROMPT --    SQL> connxe
PROMPT -- Cloud connection with client credential (wallet), file upload:
PROMPT --       $ docker cp /tmp/Wallet_MyDB.zip mochoa_sqlcl-docker-extension-desktop-extension-service:/home/sqlcl
PROMPT -- Cloud connection string:
PROMPT --    SQL> set cloudconfig /home/sqlcl/Wallet_MyDB.zip
PROMPT --    SQL> conn admin/MyStrongSecretPwd@mydb_high
