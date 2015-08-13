Main Table Queries;

PLAYER
——————

CREATE TABLE Player (Id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, URL TEXT, Shoots TEXT, Height INTEGER, Weight INTEGER, DOB DATE, Deceased DATE, College TEXT);

insert into Player(Name,URL, Shoots, Height, Weight, DOB, Deceased, College) select Name, URL,  Shoots, (cast(substr(Height,1,pos-1) as Integer) * 12)+ cast(substr(Height,pos+1) as Integer), Weight, DOB, Deceased, College from (select *, instr(Height, '-') as pos from playerinfotemp); 


FRANCHISES
——————————

CREATE TABLE Franchise (id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, ShortName TEXT,URL Text, Championship TEXT);

insert into Franchise(Name, ShortName, URL, Championship) select Name, rtrim(replace(url, 'http://www.basketball-reference.com/teams/', ''), '/'),URL, Championship from franchise_info_temp;


LEAGUE
——————
CREATE TABLE League(id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT);

insert into league(Name) select distinct lg from player_total_temp_url;

TEAM
————

CREATE TABLE TEAM (id INTEGER PRIMARY KEY AUTOINCREMENT, Name TEXT, ShortName TEXT, FranchiseID INTEGER, FOREIGN KEY (FranchiseID) REFERENCES Franchise(id));

insert into team (Name,ShortName,FranchiseID) select distinct rtrim(rtrim(team, '*'), ' (1)'), team_short, franchise.id from team_stat,franchise where team_stat.franchise_url = franchise.url;

create table playerdetails (Id INTEGER PRIMARY KEY AUTOINCREMENT, PlayerID INTEGER, TeamID INTEGER, LeagueID INTEGER, Season TEXT, Position TEXT, Salary INTEGER, NoOfGames INTEGER, Age INTEGER, FOREIGN KEY (PlayerID) REFERENCES Player(ID), FOREIGN KEY (TeamID) REFERENCES Team(ID), FOREIGN KEY (LeagueID) REFERENCES League(ID));
insert into playerdetails (PlayerID, TeamID, LeagueID, Season, Position, NoOfGames, Age)
select 
	player.id,
 	team.id,
	league.id,
	pt.season,
	pt.pos,
	pt.g,
	pt.age	
from
	player_total_temp_url pt join player on (pt.url = player.url)
	join team on pt.tm = team.shortname
	join league on pt.lg = league.name


create table playersalary (Id INTEGER PRIMARY KEY AUTOINCREMENT, PlayerID INTEGER, TeamID INTEGER, LeagueID INTEGER, Season TEXT, Salary INTEGER, FOREIGN KEY (PlayerID) REFERENCES Player(ID), FOREIGN KEY (TeamID) REFERENCES Team(ID), FOREIGN KEY (LeagueID) REFERENCES League(ID));

insert into playersalary (playerid, teamid, leagueid, season, salary) select	
	player.id playerid,
	team.id teamid,
	league.id leagueid,
	ps.season season,	
	ps.salary salary
from
	player,
	player_salary_temp_url ps,
	team,
	league
where
	player.url = ps.url and player.name = ps.name and
	ps.team = team.name and substr(replace(ps.team_url, '/teams/', ''), 0,4) = team.shortname and
	ps.lg = league.name 

CREATE TABLE TeamDetails (id INTEGER PRIMARY KEY AUTOINCREMENT, TeamID INTEGER REFERENCES TEAM (id), LeagueID INTEGER REFERENCES League (id), Season TEXT, Win INTEGER, Loss INTEGER, Finish INTEGER, Playoffs TEXT, TWS TEXT);

Insert into TeamDetails (TeamID, LeagueID, Season, Win, Loss, Finish, Playoffs, TWS )
select Team.id TID, League.id LID, ts.Season, ts.w, ts.l, ts.finish, ts.playoffs, ts.top_ws from team_stat ts join TEAM on ( ts.team_short = TEAM.ShortName )left join league on ts.lg = league.name

