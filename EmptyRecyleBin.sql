declare @CleanupList table(ArchivalId uniqueidentifier)
declare @ArchivalId uniqueidentifier
insert into @CleanupList(ArchivalId) 
	select ArchivalId
	from dbo.Archive
	where ArchiveName = 'recyclebin'
while(1 = 1)
begin
    set @ArchivalId = NULL
    select top (1) @ArchivalId = ArchivalId
    from @CleanupList
    if @ArchivalId IS NULL
        break
	delete from dbo.ArchivedFields where ArchivalId = @ArchivalId
	delete from dbo.ArchivedItems where ArchivalId = @ArchivalId
	delete from dbo.ArchivedVersions where ArchivalId = @ArchivalId
	delete from dbo.Archive where ArchivalId = @ArchivalId
    delete top(1) from @CleanupList
end
