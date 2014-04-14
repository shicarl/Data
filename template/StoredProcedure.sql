drop procedure devdb.sp_template;

create procedure devdb.sp_template
(
    in  i_num   int,
    out o_rtcd  integer,
    out o_msg varchar(300)
)
begin
/*
description£º<description information>
tables(select):
          [1] XXXXXXXX <table description>
          [2] ......
tabels(modify):
          [1] XXXXXXXX <table description>
          [2] ......
example: call devdb.sp_template(1, @rtcd, @msg); [select @rtcd,@msg;]
author:  <full name>
create date:  <YYYY-MM-DD>
maintainer:   <full name>
maintain date:<YYYY-MM-DD>
note: <note infomation>
*/
    /*----------- local variables ---------------*/
    declare v_debug int default 0; /*0 debug ,1 no debug,which means not to print logs*/
    declare v_procname varchar(100) default 'devdb.sp_template';
    declare v_i int default 0;

    /*----------- condition & handler  ---------------*/
    declare continue handler for SQLWARNING
    begin
        call dbadb.sp_log(v_procname,'SQLWARNING');
        set o_rtcd = 1;
        set o_msg = 'SQLWARNING';
        if v_debug = 0 then select o_rtcd,o_msg; end if; 
    end;

    declare continue handler FOR NOT FOUND
    begin
        call dbadb.sp_log(v_procname,'NOT FOUND');
        set o_rtcd = 2;
        set o_msg = 'NOT FOUND';
        if v_debug = 0 then select o_rtcd,o_msg; end if; 
    end;

    declare exit handler for SQLEXCEPTION
    begin
        rollback work;
        call dbadb.sp_log(v_procname,'SQLEXCEPTION');
        set o_rtcd = -1;
        set o_msg = 'SQLEXCEPTION';
        if v_debug = 0 then select o_rtcd,o_msg; end if; 
    end;

    /*----------- main begin---------------*/
    set o_rtcd = 0;
    set o_msg = '';
    set v_i = 0;

    /*----------- 1.create temporary table ---------------*/
    drop temporary table if exists tmp_account;
    create temporary table IF NOT EXISTS tmp_account
    ( 
        num int
    );
    
    l:loop
        if v_i <= i_num
        then 
            insert into tmp_account(num) values(v_i);
            set v_i = v_i +1;
        else 
            leave l;
        end if;
    end loop l;

    insert into devdb.t2(id)
        select num from tmp_account;
        
    /*----------- main end ---------------*/
    if v_debug = 0 then select o_rtcd,o_msg; end if; 

end!

alter procedure devdb.sp_template comment 'MySQL stored procedure template';