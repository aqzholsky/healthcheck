create table jobs as select * from hr.JOBS;
ALTER TABLE jobs ADD CONSTRAINT job_id_pk PRIMARY KEY (job_id);

-- 1
create or replace function GET_JOB(
    p_job_id hr.jobs.job_id%type
) return varchar is p_job_title hr.jobs.job_title%type;
begin
    select job_title into p_job_title from jobs where job_id=p_job_id;
	return p_job_title;
exception
    when NO_DATA_FOUND then
    return null;
end GET_JOB;

declare
    job_title varchar(100);
begin
    job_title := GET_JOB('SA_REP');
	if job_title is not null then
        dbms_output.put_line('Job title: ' || job_title);
	end if;
end;

-- 2
create or replace function GET_ANNUAL_COMP(
    p_salary in number default 0, 
    p_commission_pct in number default 0)
return number is
 annual number;
begin
end GET_ANNUAL_COMP;create table jobs as select * from hr.JOBS;
ALTER TABLE jobs ADD CONSTRAINT job_id_pk PRIMARY KEY (job_id);

-- 1
create or replace function GET_JOB(
    p_job_id hr.jobs.job_id%type
) return varchar is p_job_title hr.jobs.job_title%type;
begin
    select job_title into p_job_title from jobs where job_id=p_job_id;
	return p_job_title;
exception
    when NO_DATA_FOUND then
    return null;
end GET_JOB;

declare
    v_job_title VARCHAR2(100);
begin
    v_job_title := GET_JOB('SA_REP');
    DBMS_OUTPUT.PUT_LINE('Job title: ' || v_job_title);
end;

-- 2
create or replace function GET_ANNUAL_COMP(
    p_salary in number default 0, 
    p_commission_pct in number default 0)
return number is
begin
	return (nvl(p_salary, 0)*12) + (nvl(p_commission_pct, 9)*nvl(p_salary, 0)*12);
end GET_ANNUAL_COMP;

select FIRST_NAME, LAST_NAME, SALARY, COMMISSION_PCT, GET_ANNUAL_COMP(SALARY, COMMISSION_PCT) as ANNUAL from hr.employees;

-- 3
create or replace function VALID_DEPTID(
    p_dep_id hr.departments.department_id%type
) return boolean is
    data_count number;
begin
    select count(*) into data_count from hr.departments where department_id=p_dep_id;
    return data_count > 0;
exception
    when NO_DATA_FOUND then
    return FALSE;
end VALID_DEPTID;

CREATE SEQUENCE employee_id_seq
  START WITH 227
  INCREMENT BY 1
  NOCYCLE
  CACHE 10;

create table employees as select * from hr.employees;
ALTER TABLE employees ADD CONSTRAINT employee_pk PRIMARY KEY (employee_id);

create or replace procedure add_job(
    job_id in hr.JOBS.JOB_ID%type,
    job_title in hr.JOBS.JOB_TITLE%type) is
begin
    insert into jobs(JOB_ID, JOB_TITLE) values(job_id, job_title);
end add_job;

create or replace procedure ADD_EMPLOYEE(
    p_first_name hr.employees.first_name%type,
    p_last_name hr.employees.first_name%type,
    p_email hr.employees.email%type,
    p_job_id in hr.employees.job_id%type default 'SA_REP',
    p_manager_id in hr.employees.manager_id%type default 145,
    p_salary in hr.employees.salary%type default 1000,
    p_commission_pct in hr.employees.commission_pct%type default 0,
    p_department_id in hr.employees.department_id%type default 30
) is
begin
    INSERT INTO
      employees (
        employee_id,
        first_name,
        last_name,
        email,
        hire_date,
        job_id,
        salary,
        commission_pct,
        manager_id,
        department_id
      )
    VALUES
      (
        employee_id_seq.NEXTVAL,
        p_first_name,
        p_last_name,
        p_email,
        TRUNC(SYSDATE),
        p_job_id,
        p_salary,
        p_commission_pct,
        p_manager_id,
        p_department_id
      );
end ADD_EMPLOYEE;

declare
    p_dep_id number := 15;
begin
    if VALID_DEPTID(p_dep_id) then
		dbms_output.put_line(TRUNC(SYSDATE));    
		ADD_EMPLOYEE('Jane', 'Harris', 'aqz@bak.com', p_department_id=>p_dep_id);
    end if;
end;
