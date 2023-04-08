-- Create database with file group
CREATE DATABASE [LibraryManagement]
CONTAINMENT = NONE
ON  PRIMARY 
(NAME = N'LibraryManagement', 
	FILENAME = N'E:\ITI\2 important Certificates\LibraryManagement.mdf', 
	SIZE = 8192KB , 
	FILEGROWTH = 65536KB )
LOG ON 
(NAME = N'LibraryManagement_log',
	FILENAME = N'E:\ITI\2 important Certificates\LibraryManagement_log.ldf',
	SIZE = 8192KB ,
	FILEGROWTH = 65536KB )
GO

use LibraryManagement

--full backup for database
BACKUP DATABASE [LibraryManagement] 
TO  DISK = N'E:\ITI\2 important Certificates\libraryfull.bak' 
WITH NOFORMAT, 
NOINIT,  
NAME = N'LibraryManagement-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO

--job for full backup database every month 
USE [msdb]
GO
DECLARE @jobId BINARY(16)
EXEC  msdb.dbo.sp_add_job @job_name=N'LibraryBackup', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'DESKTOP-IO1OCJM\comk', @job_id = @jobId OUTPUT
select @jobId
GO
EXEC msdb.dbo.sp_add_jobserver @job_name=N'LibraryBackup', @server_name = N'DESKTOP-IO1OCJM'
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_add_jobstep @job_name=N'LibraryBackup', @step_name=N'LibraryFullBackup', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_fail_action=2, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'BACKUP DATABASE [LibraryManagement] 
TO  DISK = N''E:\ITI\2 important Certificates\libraryfull.bak'' 
WITH NOFORMAT, 
NOINIT,  
NAME = N''LibraryManagement-Full Database Backup'', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
', 
		@database_name=N'LibraryManagement', 
		@flags=0
GO
USE [msdb]
GO
EXEC msdb.dbo.sp_update_job @job_name=N'LibraryBackup', 
		@enabled=1, 
		@start_step_id=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_page=2, 
		@delete_level=0, 
		@description=N'', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'DESKTOP-IO1OCJM\comk', 
		@notify_email_operator_name=N'', 
		@notify_page_operator_name=N''
GO
USE [msdb]
GO
DECLARE @schedule_id int
EXEC msdb.dbo.sp_add_jobschedule @job_name=N'LibraryBackup', @name=N'everymonth', 
		@enabled=1, 
		@freq_type=16, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20221028, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, @schedule_id = @schedule_id OUTPUT
select @schedule_id
GO

--Create tables 
create table publisher (
	PublisherName varchar(100) primary key not null ,
	PublisherAddress varchar(200) not null ,
	PublisherPhone varchar(50) not null
	)

create table Book(
	BookId int not null identity(1,1) primary key,
	Book_Title varchar(100) not null,
	PublisherName varchar(100) not null constraint FK_Publisher_Name1 
	foreign key references publisher(PublisherName) on update cascade on delete cascade
	)

Create table Branch(
	BranchId int primary key not null identity(1,1) ,
	BranchName varchar(100) not null ,
	library_branch_BranchAddress VARCHAR(200) NOT NULL
	)

create table Borrower(
	CardNo INT PRIMARY KEY NOT NULL IDENTITY (100,1),
	BorrowerName VARCHAR(100) NOT NULL,
	BorrowerAddress VARCHAR(200) NOT NULL,
	BorrowerPhone VARCHAR(50) NOT NULL
	)

create table Loans(
	LoansID int primary key not null identity(1,1),
	BookId int not null constraint FK_BookId_Book foreign key references Book(BookId) 
		on update cascade on delete cascade,
	BranchId int not null constraint FK_BranchId_Branch foreign key references Branch(BranchId) 
		on update cascade on delete cascade ,
	CardNo int not null constraint FK_CardNo_Borrower foreign key references Borrower(CardNo),
	DateOut varchar(50) not null,
	DueDate varchar(50) not null
	)

Create table Copies(
	CopiesId int primary key not null identity(1,1),
	BookId int not null constraint FK_BookId_Copies foreign key references Book(BookId)
		on update cascade on delete cascade ,
	BranchId int not null constraint FK_BranchId_Copies foreign key references Branch(BranchId) 
		on update cascade on delete cascade,
	No_Of_Copies int not null
		)

create table Authors(
	AuthorId int primary key not null identity(1,1),
	BookId int not null constraint FK_BookId_Authors foreign key references Book(BookId)
		on update cascade on delete cascade ,
	AuthorName varchar(50) not null
		)

--1.how many copies of the book titled 'the lost tribe' are owned by the library branch whose name is 'Sharpstown'?
select BranchName,Book_Title,No_Of_Copies
from Book B , Copies C , Branch Br
where B.BookId = C.BookId 
	and Br.BranchId = c.BranchId
	and Book_Title = 'the lost tribe'
	and BranchName = 'Sharpstown'

--2.How many copies of the book titled "The Lost Tribe" are owned by each library branch?
select BranchName,Book_Title,No_Of_Copies
from Book B , Copies C , Branch Br
where B.BookId = C.BookId 
	and Br.BranchId = c.BranchId
	and Book_Title = 'the lost tribe'

--3.Retrieve the names of all borrowers who do not have any books checked out?
select BorrowerName 
from Borrower B 
where not exists (select * from Loans L where B.CardNo = L.CardNo )

--4.For each book that is loaned out from the "Sharpstown" branch and whose DueDate is today, 
--retrieve the book title, the borrower's name, and the borrower's address
select Book_Title,BorrowerName,BorrowerAddress
from Branch Br , Loans l , Book B , Borrower r 
where Br.BranchId = l.BranchId
	and l.BookId = b.BookId
	and l.CardNo = r.CardNo
	and BranchName = 'Sharpstown'
	and DueDate = GETDATE()


--5.For each library branch, retrieve the branch name and the total number of books loaned out from that branch
select BranchName, COUNT(loansID) as [Total Loans]
from Branch Br , Book B , Loans L
where br.BranchId = l.BranchId
	and b.BookId = l.BookId
group by BranchName

--6.Retrieve the names, addresses, and number of books checked out for all borrowers 
--who have more than five books checked out
select BorrowerName,BorrowerAddress,COUNT(BorrowerName) as [Books Checked Out]
from Borrower B , Loans l 
where B.CardNo = l.CardNo
group by BorrowerName,BorrowerAddress
having COUNT(BorrowerName) > 5

--7.For each book authored by "Stephen King", retrieve the title and the number of copies 
--owned by the library branch whose name is "Central"
select BranchName,Book_Title,No_Of_Copies
from Book B,Copies C,Branch Br , Authors A 
where B.BookId = C.BookId 
	  and C.BranchId = Br.BranchId
	  and A.BookId = B.BookId
	  and BranchName = 'Central'
      and AuthorName = 'Stephen King'



















