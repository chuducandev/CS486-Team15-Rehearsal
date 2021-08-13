create database SuperVocal
go
use SuperVocal

create table Candidates (
    ID int not null primary key,
    Name nvarchar(50) not null,
    State char(1) not null check (State = 'o' or State = 'r'),
)

create table Monitors (
    ID int not null primary key,
    Name nvarchar(50) not null,
)

create table Results (
    MonitorID int not null references Monitors(ID),
    ReserveID int not null unique references Candidates(ID),
    Result int not null check (Result = 0 or Result = 1),
    primary key (MonitorID, ReserveID),
)

create table Competitions (
    OfficialID int not null references Candidates(ID),
    ReserveID int not null references Candidates(ID),
    Result int not null check (Result = 0 or Result = 1),
    primary key (OfficialID, ReserveID),
)

go

insert into candidates values(1,'Nguyen Van Q','O')
insert into candidates values(2,'Nguyen Van W','O')
insert into candidates values(3,'Nguyen Van E','O')
insert into candidates values(4,'Nguyen Van R','O')
insert into candidates values(5,'Nguyen Van T','O')
insert into candidates values(6,'Nguyen Van Y','O')
insert into candidates values(7,'Nguyen Van U','R')
insert into candidates values(8,'Nguyen Van I','R')
insert into candidates values(9,'Nguyen Van O','R')
insert into candidates values(10,'Nguyen Van P','R')
insert into candidates values(11,'Nguyen Van A','R')
insert into candidates values(12,'Nguyen Van S','R')
insert into candidates values(13,'Nguyen Van D','R')
insert into candidates values(14,'Nguyen Van F','R')
insert into candidates values(15,'Nguyen Van G','R')
insert into candidates values(16,'Nguyen Van H','R')
insert into candidates values(17,'Nguyen Van j','R')
insert into candidates values(18,'Nguyen Van K','R')
insert into candidates values(19,'Nguyen Van K','R')
insert into candidates values(20,'Nguyen Van L','R')
insert into candidates values(21,'Nguyen Van Z','R')
insert into candidates values(22,'Nguyen Van X','R')
insert into candidates values(23,'Nguyen Van C','R')
insert into candidates values(24,'Nguyen Van V','R')
insert into candidates values(25,'Nguyen Van B','R')
insert into candidates values(26,'Nguyen Van N','R')
insert into candidates values(27,'Nguyen Van M','R')
insert into candidates values(28,'Nguyen Van qq','R')
insert into candidates values(29,'Nguyen Van ww','R')
insert into candidates values(30,'Nguyen Van ee','R')
insert into candidates values(31,'Nguyen Van rr','R')
insert into candidates values(32,'Nguyen Van tt','R')
insert into candidates values(33,'Nguyen Van kk','R')
insert into candidates values(34,'Nguyen Van WW','R')

insert into Monitors values (1,'Quan')
insert into Monitors values (2,'Quan2')
insert into Monitors values (3,'Quan3')

go

create procedure sp_addNewResult(@ReserveID int, @MonitorID int, @Result int)
as
Begin transaction
begin try
    if exists (
        select * 
        from Results
        where ReserveID = @ReserveID
        and MonitorID = @MonitorID
    ) 
        throw 10001, 'This result has already existed.', 1;

    insert into Results(MonitorID, ReserveID, Result) 
    values
        (@MonitorID, @ReserveID, @Result)

    commit transaction;
end try
begin catch
    rollback transaction;
    throw;
end catch

go

create procedure sp_judgeReserveCandidate(@ReserveID int, @Result1 int, @Result2 int, @Result3 int)
as
Begin transaction
begin try
    declare @MonitorID1 int;
    declare @MonitorID2 int;
    declare @MonitorID3 int;

    set @MonitorID1 = 1;
    set @MonitorID2 = 2;
    set @MonitorID3 = 3;

    if exists (
        select * 
        from Results
        where ReserveID = @ReserveID
    ) 
        throw 30001, 'This reserve candidate has already been examined.', 1;

    exec sp_addNewResult @ReserveID, @MonitorID1, @Result1;
    exec sp_addNewResult @ReserveID, @MonitorID2, @Result2;
    exec sp_addNewResult @ReserveID, @MonitorID3, @Result3;

    commit transaction;
end try
begin catch
    rollback transaction;
    throw;
end catch

go

create procedure sp_addNewCompetition(@OfficialID int, @ReserveID int, @Result int)
as 
begin transaction
begin try
    if not exists (
        select * 
        from Candidates
        where ID = @OfficialID
        and State = 'o'
    ) 
        throw 20001, 'The ID of the official candidate is invalid.', 1;
        
    if not exists (
        select * 
        from Candidates 
        where ID = @ReserveID
        and State = 'r'
    )
        throw 20002, 'The ID of the reserve candidate is invalid.', 1;

    if not exists (
        select * 
        from Results 
        where ReserveID = @ReserveID
        and Result = 1
        group by ReserveID
        having count(*) >= 3
    )
        throw 20003, 'This reserve candidate has not passed the examination.', 1;
    
    if exists (
        select * 
        from Competitions
        where OfficialID = @OfficialID
        and ReserveID = @ReserveID
    ) 
        throw 20003, 'This competition has already existed', 1;

    if @Result <> 0 and @Result <> 1
        throw 20004, 'Invalid result.', 1;

    insert into Competitions(OfficialID, ReserveID, Result)
    values 
        (@OfficialID, @ReserveID, @Result)

    if (@Result = 1) 
    begin
        update Candidates 
        set State = 'r'
        where ID = @OfficialID

        update Candidates 
        set State = 'o'
        where ID = @ReserveID
    end
    
    commit transaction;
end try
begin catch
    rollback transaction;
    throw;
end catch

go

create function fn_getAllReserveCandidates()
returns table 
as
    return (
        select * 
        from Candidates 
        where State = 'r'
    )

go

create function fn_getAllOfficialCandidates()
returns table 
as
    return (
        select * 
        from Candidates 
        where State='o'
    )

go

create function fn_getAllMonitors()
returns table 
as
    return (
        select * 
        from Monitors
    )

go

create function fn_getAllResults()
returns table
as 
    return (
        select * 
        from Results
    )

go

create function fn_getAllCompetitions()
returns table
as 
    return (
        select * 
        from Competitions
    )

go




use master
drop database SuperVocal