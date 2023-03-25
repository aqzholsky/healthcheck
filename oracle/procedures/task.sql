create table jobs as select * from hr.JOBS;
ALTER TABLE jobs ADD CONSTRAINT job_id_pk PRIMARY KEY (job_id);
drop table jobs;

-- 1.a
create or replace procedure add_job(
    job_id in hr.JOBS.JOB_ID%type,
    job_title in hr.JOBS.JOB_TITLE%type) is
begin
    insert into jobs(JOB_ID, JOB_TITLE) values(job_id, job_title);
end add_job;

-- 1.b
execute add_job('IT_DBA', 'Database Administrator');
select * from jobs;

-- 1.c
execute add_job('ST_MAN', 'Stock Manager');
select * from jobs where job_id='ST_MAN';

-- 2.a
create or replace procedure upd_job(
    p_job_id in hr.JOBS.JOB_ID%type,
    new_job_title in hr.JOBS.JOB_TITLE%type) is
    updated_rows NUMBER;
	no_row_updated_exception EXCEPTION;
begin
    update jobs set JOB_TITLE=new_job_title where JOB_ID=p_job_id;
	updated_rows := SQL%ROWCOUNT;
	if updated_rows = 0 then
        raise no_row_updated_exception;
    end if;
	dbms_output.put_line('Successfully updated: ' || updated_rows || ' records');
	COMMIT;
exception
    when no_row_updated_exception then
    	dbms_output.put_line('Record not found by ID : ' || p_job_id);
end upd_job;

-- 2.b
execute upd_job('IT_DBA', 'Data Administrator');
select * from jobs;

-- 2.c
execute upd_job('IT_WEB', 'Web Master');

-- 3.a
create or replace procedure del_job(p_job_id in hr.JOBS.JOB_ID%type) is
    updated_rows NUMBER;
	no_row_updated_exception EXCEPTION;
begin
    delete from jobs where JOB_ID=p_job_id;
	updated_rows := SQL%ROWCOUNT;
	if updated_rows = 0 then
        raise no_row_updated_exception;
    end if;
	dbms_output.put_line('Successfully deleted: ' || updated_rows || ' records');
	COMMIT;
exception
    when no_row_updated_exception then
    	dbms_output.put_line('Record not found by ID : ' || p_job_id);
end del_job;

-- 3.b
execute del_job('AA_PRES');
select * from jobs;

-- 4.a
create table employees as (select * from hr.employees);
select * from employees;
create or replace procedure get_employee(
    emp_id in hr.employees.EMPLOYEE_ID%type,
    emp_salary out hr.employees.SALARY%type,
    emp_job_id out hr.employees.JOB_ID%type
) is
begin
    select salary, job_id into emp_salary, emp_job_id
    from employees where employee_id=emp_id;

	if emp_salary is null then
        raise NO_DATA_FOUND;
	end if;
exception
    when NO_DATA_FOUND then
    	dbms_output.put_line('No data found by ID: ' || emp_id);
end get_employee;

declare
	v_salary hr.employees.SALARY%type;
	v_job_id hr.employees.JOB_ID%type;
begin
    get_employee(100, v_salary, v_job_id);
    DBMS_OUTPUT.PUT_LINE('Salary: ' || v_salary);
    DBMS_OUTPUT.PUT_LINE('Job ID: ' || v_job_id);
end;
