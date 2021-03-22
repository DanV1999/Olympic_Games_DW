--- 1900 - 2016
go
create database OlympicsDW;
go
use OlympicsDW;
go

create table DimSport(
	[SportKey]  int IDENTITY  NOT NULL,
	[SportID]  int NOT NULL,
	[SportName]  varchar(200)  NOT NULL,
	[EventName] varchar(200) NOT NULL,
	--metadata
   [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [pkOlympicsSportKey] PRIMARY KEY ( [SportKey] )
);


create table DimMedal(
	[MedalKey]  int IDENTITY  NOT NULL,
	[MedalID]  int NOT NULL,
	[MedalName]  varchar(50)  NOT NULL,
	--metadata
	[RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [pkOlympicsMedalKey] PRIMARY KEY ( [MedalKey] )
);

create table DimCompetitor(
	[CompetitorKey]  int IDENTITY  NOT NULL,
	[CompetitorID]  int NOT NULL,
	[CompetitorName]  varchar(500)  NOT NULL,
	[CompetitorGender]  varchar(10)  NOT NULL,
	[CompetitorHeight]  int  NOT NULL,
	[CompetitorWeight]  int NOT NULL,
	[CompetitorAge]  int  NOT NULL,
	[CompetitorRegion]  varchar(200)  NOT NULL,
	--metadata
	[RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [pkOlympicsCompetitorKey] PRIMARY KEY ( [CompetitorKey] )
);

create table DimGames(
	[GameKey]  int IDENTITY  NOT NULL,
	[GameID]  int NOT NULL,
	[GameName]  varchar(100)  NOT NULL,
	[GameCity]  varchar(200)  NOT NULL,
	--metadata
	[RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [pkOlympicsGameKey] PRIMARY KEY ( [GameKey] )
);

create table DimSeasonYear(
	[SYKey] int IDENTITY NOT NULL,
	[SYID] int NOT NULL,
	[Season]  varchar(100)  NOT NULL,
	[Year]  int  NOT NULL
	--metadata
,  [RowIsCurrent]  bit   DEFAULT 1 NOT NULL
,  [RowStartDate]  datetime  DEFAULT '12/31/1899' NOT NULL
,  [RowEndDate]  datetime  DEFAULT '12/31/9999' NOT NULL
,  [RowChangeReason]  nvarchar(200)   NULL
, CONSTRAINT [pkOlympicsSYKey] PRIMARY KEY ( [SYKey] )
);


create table FactCompetitorAVG (
	MedalKey	int	NOT NULL
,	GameKey	int NOT NULL
,	SYKey	int NOT NULL
,	SportKey int NOT NULL
	-- measures
,	AVGAge	int NOT NULL
,	AVGHeight	int  NOT NULL
,	AVGWeight	int  NOT NULL
	-- constraints
, 	CONSTRAINT PK_FactCompetitorAVG PRIMARY KEY (SportKey, MedalKey,GameKey,SYKey)
,	CONSTRAINT FK_CAMedalKey FOREIGN KEY (MedalKey) REFERENCES DimMedal(MedalKey)
,	CONSTRAINT FK_CAGameKey FOREIGN KEY (GameKey) REFERENCES DimGames(GameKey)
,	CONSTRAINT FK_CASportKey FOREIGN KEY (SportKey) REFERENCES DimSport(SportKey)
,	CONSTRAINT FK_CASYKey FOREIGN KEY (SYKey) REFERENCES DimSeasonYear(SYKey)
)

CREATE TABLE FactTotalMedal (
	MedalKey	int	NOT NULL
,	GameKey	int	NOT NULL
,	CompetitorKey	int NOT NULL
,	SportKey int NOT NULL
,	SYKey int NOT NULL
	-- measures
,	RegionID int NOT NULL
,	RegionName varchar(200) NOT NULL
,	GameName	varchar(100) 	NOT NULL
,	TotalMedals	int NOT NULL

	-- constraints
, 	CONSTRAINT PK_FactTotalMedal PRIMARY KEY (MedalKey, GameKey, CompetitorKey,SportKey,SYKey,RegionID)
,	CONSTRAINT FK_FTMMedalKey FOREIGN KEY (MedalKey) REFERENCES DimMedal(MedalKey)
,	CONSTRAINT FK_FTMGamesKey FOREIGN KEY (GameKey) REFERENCES DimGames(GameKey)
,	CONSTRAINT FK_FTMCompetitorKey FOREIGN KEY (CompetitorKey) REFERENCES DimCompetitor(CompetitorKey)
,	CONSTRAINT FK_FTMSportKey FOREIGN KEY (SportKey) REFERENCES DimSport(SportKey)
,	CONSTRAINT FK_FTMSYKey FOREIGN KEY (SYKey) REFERENCES DimSeasonYear(SYKey)
)



/*
CREATE TABLE FactSportRate (
	SportKey	int	NOT NULL
,	MedalKey	int NOT NULL
,	GameKey int NOT NULL
,	SYKey int NOT NULL
	-- measures
,	TotalEventsInGame	int 	NOT NULL
,	GoldRatioPerSport	decimal(25,4) NOT NULL
	-- constraints
, 	CONSTRAINT PK_FactSportRate  PRIMARY KEY (SportKey, MedalKey, GameKey, SYKey)
,	CONSTRAINT FK_SRSportKey FOREIGN KEY (SportKey) REFERENCES DimSport(SportKey)
,	CONSTRAINT FK_SRMedalKey FOREIGN KEY (MedalKey) REFERENCES DimMedal(MedalKey)
,	CONSTRAINT FK_SRGamesKey FOREIGN KEY (GameKey) REFERENCES DimGames(GameKey)
,	CONSTRAINT FK_SRSYKey FOREIGN KEY (SYKey) REFERENCES DimSeasonYear(SYKey)
)
*/
---------------------------------
/* 
use OlympicsStage
go
select games_year, season
into [dbo].[OlympicsStageSeasonYear]
from [Olympics].[dbo].[games]


insert into OlympicsDW.dbo.DimSeasonYear(Season,Year)
select season,games_year
from OlympicsStage.dbo.OlympicsStageSeasonYear
*/

/* Fact TotalMedal
select nr.region_name, count(ce.medal_id) as TotalMedalCountry
from medal m join competitor_event ce on m.id = ce.medal_id join games_competitor gc on ce.competitor_id = gc.id join person p on p.id = gc.person_id join person_region pr on pr.person_id = p.id join noc_region nr on nr.id = pr.region_id
where ce.medal_id = 1 or  ce.medal_id = 2 or ce.medal_id = 3
group by nr.region_name

select g.games_name, count(ce.medal_id) as TotalMedalGames
from medal m join competitor_event ce on m.id = ce.medal_id join games_competitor gc on ce.competitor_id = gc.id join games g on gc.games_id = g.id
where ce.medal_id = 1 or  ce.medal_id = 2 or ce.medal_id = 3
group by g.games_name
*/

/* Fact CompetitorAVG
select g.games_name,avg(p.height) as AVGHeight
from games_competitor gc join games g on gc.games_id = g.id join competitor_event ce on ce.competitor_id = gc.person_id join medal m on m.id = ce.medal_id join person p on p.id = gc.person_id
where m.id = 1 and p.height !=0
group by g.games_name

select g.games_name, avg(p.weight) as AVGWeight
from games_competitor gc join games g on gc.games_id = g.id join competitor_event ce on ce.competitor_id = gc.person_id join medal m on m.id = ce.medal_id join person p on p.id = gc.person_id
where m.id = 1 and p.weight !=0
group by g.games_name

select g.games_name,avg(gc.age) as AVGAge
from games_competitor gc join games g on gc.games_id = g.id join competitor_event ce on ce.competitor_id = gc.person_id join medal m on m.id = ce.medal_id
where m.id = 1 and gc.age !=0
group by g.games_name
*/

/*
select distinct g.games_name,/*e.event_name*/count(e.event_name)
from games g join games_competitor gc on gc.games_id= g.id join competitor_event ce on gc.person_id = ce.competitor_id join event e on e.id = ce.event_id join sport s on s.id = e.sport_id
group by g.games_name
order by g.games_name

select e.event_name, count(ce.medal_id) as V , nr.region_name
from games_competitor gc join competitor_event ce on gc.person_id = ce.competitor_id join event e on e.id = ce.event_id join sport s on s.id = e.sport_id join medal m on m.id = ce.medal_id join person p on p.id=gc.person_id join person_region pr on pr.person_id = p.id join noc_region nr on nr.id = pr.region_id
where ce.medal_id = 1
group by nr.region_name, e.event_name


select e.event_name, count(m.id) as V
from competitor_event ce  join event e on e.id = ce.event_id join sport s on s.id = e.sport_id join medal m on m.id = ce.medal_id 
where m.id = 1
group by e.event_name


select count(m.id) as V
from games_competitor gc join competitor_event ce on gc.person_id = ce.competitor_id join event e on e.id = ce.event_id join sport s on s.id = e.sport_id join medal m on m.id = ce.medal_id join person p on p.id=gc.person_id join person_region pr on pr.person_id = p.id join noc_region nr on nr.id = pr.region_id
where m.id =1
group by event_name
*/





