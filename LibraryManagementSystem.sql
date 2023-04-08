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

insert into publisher (PublisherName,PublisherAddress,PublisherPhone)
values
('DAW Books','375 Hudson Street, New York, NY 10014','212-366-2000'),
		('Viking','375 Hudson Street, New York, NY 10014','212-366-2000'),
		('Signet Books','375 Hudson Street, New York, NY 10014','212-366-2000'),
		('Chilton Books','Not Available','Not Available'),
		('George Allen & Unwin','83 Alexander Ln, Crows Nest NSW 2065, Australia','+61-2-8425-0100'),
		('Alfred A. Knopf','The Knopf Doubleday Group Domestic Rights, 1745 Broadway, New York, NY 10019','212-940-7390'),		
		('Bloomsbury','Bloomsbury Publishing Inc., 1385 Broadway, 5th Floor, New York, NY 10018','212-419-5300'),
		('Shinchosa','Oga Bldg. 8, 2-5-4 Sarugaku-cho, Chiyoda-ku, Tokyo 101-0064 Japan','+81-3-5577-6507'),
		('Harper and Row','HarperCollins Publishers, 195 Broadway, New York, NY 10007','212-207-7000'),
		('Pan Books','175 Fifth Avenue, New York, NY 10010','646-307-5745'),
		('Chalto & Windus','375 Hudson Street, New York, NY 10014','212-366-2000'),
		('Harcourt Brace Jovanovich','3 Park Ave, New York, NY 10016','212-420-5800'),
		('W.W. Norton',' W. W. Norton & Company, Inc., 500 Fifth Avenue, New York, New York 10110','212-354-5500'),
		('Scholastic','557 Broadway, New York, NY 10012','800-724-6527'),
		('Bantam','375 Hudson Street, New York, NY 10014','212-366-2000'),
		('Picador USA','175 Fifth Avenue, New York, NY 10010','646-307-5745')
		
insert into Book (Book_Title,PublisherName)
values
('The Name of the Wind', 'DAW Books'),
		('It', 'Viking'),
		('The Green Mile', 'Signet Books'),
		('Dune', 'Chilton Books'),
		('The Hobbit', 'George Allen & Unwin'),
		('Eragon', 'Alfred A. Knopf'),
		('A Wise Mans Fear', 'DAW Books'),
		('Harry Potter and the Philosophers Stone', 'Bloomsbury'),
		('Hard Boiled Wonderland and The End of the World', 'Shinchosa'),
		('The Giving Tree', 'Harper and Row'),
		('The Hitchhikers Guide to the Galaxy', 'Pan Books'),
		('Brave New World', 'Chalto & Windus'),
		('The Princess Bride', 'Harcourt Brace Jovanovich'),
		('Fight Club', 'W.W. Norton'),
		('Holes', 'Scholastic'),
		('Harry Potter and the Chamber of Secrets', 'Bloomsbury'),
		('Harry Potter and the Prisoner of Azkaban', 'Bloomsbury'),
		('The Fellowship of the Ring', 'George Allen & Unwin'),
		('A Game of Thrones', 'Bantam'),
		('The Lost Tribe', 'Picador USA');

insert into Branch(BranchName,library_branch_BranchAddress)
values ('Sharpstown','32 Corner Road, New York, NY 10012'),
		('Central','491 3rd Street, New York, NY 10014'),
		('Saline','40 State Street, Saline, MI 48176'),
		('Ann Arbor','101 South University, Ann Arbor, MI 48104')


insert into Borrower(BorrowerName,BorrowerAddress,BorrowerPhone)
values ('Joe Smith','1321 4th Street, New York, NY 10014','212-312-1234'),
		('Jane Smith','1321 4th Street, New York, NY 10014','212-931-4124'),
		('Tom Li','981 Main Street, Ann Arbor, MI 48104','734-902-7455'),
		('Angela Thompson','2212 Green Avenue, Ann Arbor, MI 48104','313-591-2122'),
		('Harry Emnace','121 Park Drive, Ann Arbor, MI 48104','412-512-5522'),
		('Tom Haverford','23 75th Street, New York, NY 10014','212-631-3418'),
		('Haley Jackson','231 52nd Avenue New York, NY 10014','212-419-9935'),
		('Michael Horford','653 Glen Avenue, Ann Arbor, MI 48104','734-998-1513');
	
insert into Loans (BookId,BranchId,CardNo,DateOut,DueDate)
values
('1','1','100','1/1/18','2/2/18'),
		('2','1','100','1/1/18','2/2/18'),
		('3','1','100','1/1/18','2/2/18'),
		('4','1','100','1/1/18','2/2/18'),
		('5','1','102','1/3/18','2/3/18'),
		('6','1','102','1/3/18','2/3/18'),
		('7','1','102','1/3/18','2/3/18'),
		('8','1','102','1/3/18','2/3/18'),
		('9','1','102','1/3/18','2/3/18'),
		('11','1','102','1/3/18','2/3/18'),
		('12','2','105','12/12/17','1/12/18'),
		('10','2','105','12/12/17','1/12/17'),
		('20','2','105','2/3/18','3/3/18'),
		('18','2','105','1/5/18','2/5/18'),
		('19','2','105','1/5/18','2/5/18'),
		('19','2','100','1/3/18','2/3/18'),
		('11','2','106','1/7/18','2/7/18'),
		('1','2','106','1/7/18','2/7/18'),
		('2','2','100','1/7/18','2/7/18'),
		('3','2','100','1/7/18','2/7/18'),
		('5','2','105','12/12/17','1/12/18'),
		('4','3','103','1/9/18','2/9/18'),
		('7','3','102','1/3/18','2/3/18'),
		('17','3','102','1/3/18','2/3/18'),
		('16','3','104','1/3/18','2/3/18'),
		('15','3','104','1/3/18','2/3/18'),
		('15','3','107','1/3/18','2/3/18'),
		('14','3','104','1/3/18','2/3/18'),
		('13','3','107','1/3/18','2/3/18'),
		('13','3','102','1/3/18','2/3/18'),
		('19','3','102','12/12/17','1/12/18'),
		('20','4','103','1/3/18','2/3/18'),
		('1','4','102','1/12/18','2/12/18'),
		('3','4','107','1/3/18','2/3/18'),
		('18','4','107','1/3/18','2/3/18'),
		('12','4','102','1/4/18','2/4/18'),
		('11','4','103','1/15/18','2/15/18'),
		('9','4','103','1/15/18','2/15/18'),
		('7','4','107','1/1/18','2/2/18'),
		('4','4','103','1/1/18','2/2/18'),
		('1','4','103','2/2/17','3/2/18'),
		('20','4','103','1/3/18','2/3/18'),
		('1','4','102','1/12/18','2/12/18'),
		('3','4','107','1/13/18','2/13/18'),
		('18','4','107','1/13/18','2/13/18'),
		('12','4','102','1/14/18','2/14/18'),
		('11','4','103','1/15/18','2/15/18'),
		('9','4','103','1/15/18','2/15/18'),
		('7','4','107','1/19/18','2/19/18'),
		('4','4','103','1/19/18','2/19/18'),
		('1','4','103','1/22/18','2/22/18');

insert into Copies (BookId,BranchId,No_Of_Copies)
values ('1','1','5'),
		('2','1','5'),
		('3','1','5'),
		('4','1','5'),
		('5','1','5'),
		('6','1','5'),
		('7','1','5'),
		('8','1','5'),
		('9','1','5'),
		('10','1','5'),
		('11','1','5'),
		('12','1','5'),
		('13','1','5'),
		('14','1','5'),
		('15','1','5'),
		('16','1','5'),
		('17','1','5'),
		('18','1','5'),
		('19','1','5'),
		('20','1','5'),
		('1','2','5'),
		('2','2','5'),
		('3','2','5'),
		('4','2','5'),
		('5','2','5'),
		('6','2','5'),
		('7','2','5'),
		('8','2','5'),
		('9','2','5'),
		('10','2','5'),
		('11','2','5'),
		('12','2','5'),
		('13','2','5'),
		('14','2','5'),
		('15','2','5'),
		('16','2','5'),
		('17','2','5'),
		('18','2','5'),
		('19','2','5'),
		('20','2','5'),
		('1','3','5'),
		('2','3','5'),
		('3','3','5'),
		('4','3','5'),
		('5','3','5'),
		('6','3','5'),
		('7','3','5'),
		('8','3','5'),
		('9','3','5'),
		('10','3','5'),
		('11','3','5'),
		('12','3','5'),
		('13','3','5'),
		('14','3','5'),
		('15','3','5'),
		('16','3','5'),
		('17','3','5'),
		('18','3','5'),
		('19','3','5'),
		('20','3','5'),
		('1','4','5'),
		('2','4','5'),
		('3','4','5'),
		('4','4','5'),
		('5','4','5'),
		('6','4','5'),
		('7','4','5'),
		('8','4','5'),
		('9','4','5'),
		('10','4','5'),
		('11','4','5'),
		('12','4','5'),
		('13','4','5'),
		('14','4','5'),
		('15','4','5'),
		('16','4','5'),
		('17','4','5'),
		('18','4','5'),
		('19','4','5'),
		('20','4','5');

insert into Authors(BookId,AuthorName)
values ('1','Patrick Rothfuss'),
		('2','Stephen King'),
		('3','Stephen King'),
		('4','Frank Herbert'),
		('5','J.R.R. Tolkien'),
		('6','Christopher Paolini'),
		('6','Patrick Rothfuss'),
		('8','J.K. Rowling'),
		('9','Haruki Murakami'),
		('10','Shel Silverstein'),
		('11','Douglas Adams'),
		('12','Aldous Huxley'),
		('13','William Goldman'),
		('14','Chuck Palahniuk'),
		('15','Louis Sachar'),
		('16','J.K. Rowling'),
		('17','J.K. Rowling'),
		('18','J.R.R. Tolkien'),
		('19','George R.R. Martin'),
		('20','Mark Lee');

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



















