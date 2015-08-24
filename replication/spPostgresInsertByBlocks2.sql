USE [wiztel]
GO
/****** Object:  StoredProcedure [dbo].[spPostgresInsertByBlocks2]    Script Date: 08/24/2015 19:22:37 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spPostgresInsertByBlocks2]
    @tablename as varchar(max)= null,
    @pkey as varchar(max)= null,
    @field1 as varchar(max)= null,
	@field2 as varchar(max)= null,
	@field3 as varchar(max)= null,
	@field4 as varchar(max)= null,
    @field5 as varchar(max)= null,
	@field6 as varchar(max)= null,
	@field7 as varchar(max)= null,
	@field8 as varchar(max)= null,
	@field9 as varchar(max)= null,
	@field10 as varchar(max)= null,
@field11 as varchar(max)= null,
  @field12 as varchar(max)= null,
  @field13 as varchar(max)= null,
  @field14 as varchar(max)= null,
  @field15 as varchar(max)= null,
  
    @count as int,
    @mcount as int
AS
BEGIN

declare @q as  varchar(max)

declare @top1 as  bigint
declare @top2 as  bigint
declare  @TempTable table( 
	id  bigint 
)

declare @k as intSET NOCOUNT ON
set @k=0

set @top1 = 0

set @top2= @top1 -1

while not ( (@top1 = @top2) or (@k >= @mcount) )
begin
set @k=@k+1
set @q=' select top 1 "'+@pkey+'" as id from "'+@tablename+'" order by "'+@pkey+'" desc '  
set @q=' select * from openquery (pgslave , ''' +  @q + ''' )  'delete @TempTable
insert into @TempTable exec (@q)

set @top1 = (select id from @TempTable)

Set @top1=isnull(@top1,0)

exec spPostgresInsertbyrow2 @tablename=@tablename,
@pkey=@pkey,
  @field1=@field1,
 @field2=@field2, @field3=@field3, @field4=@field4, @field5=@field5, @field6=@field6, 
@field7=@field7, @field8=@field8, @field9=@field9, @field10=@field10,
@field11=@field11, @field12=@field12, @field13=@field13, @field14=@field14,@field15=@field15

,@count=@count

delete @TempTable
insert into @TempTable exec (@q)

set @top2 = (select id from @TempTable)

Set @top2=isnull(@top2,0)


/*
print(':')

print(cast(@top1 as varchar))
print(',')

print(cast(@top2 as varchar))
*/
end

exec('SELECT * from OPENQUERY(pgslave,''select count(*) as mc from "'+@tablename+'"'' ) ' ) 

END

