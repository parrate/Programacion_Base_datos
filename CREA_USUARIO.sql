CREATE USER ea1 IDENTIFIED BY ea1
default tablespace "SYSTEM"
temporary tablespace "TEMP"
account unlock;
grant resource,connect to ea1;
