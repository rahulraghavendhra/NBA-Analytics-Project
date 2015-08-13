select
	distinct playerid
from 
(
select
playerdetails_2.playerid, playerdetails_2.season, min(playerdetails_2.Age), sum(playersalary.salary) salary, sum(playerdetails_2.G), sum(playerdetails_2.GS), sum(playerdetails_2.MP), sum(playerdetails_2.FG), sum(playerdetails_2.FGA), avg(playerdetails_2.FGPERCENT), sum(playerdetails_2.THREEP), sum(playerdetails_2.THREEPA), avg(playerdetails_2.THREEPPERCENT), sum(playerdetails_2.TWOP), sum(playerdetails_2.TWOPA), avg(playerdetails_2.TWOPPERCENT), avg(playerdetails_2.EFGPERCENT), sum(playerdetails_2.FT), sum(playerdetails_2.FTA), avg(playerdetails_2.FTPERCENT), sum(playerdetails_2.ORB), sum(playerdetails_2.DRB), sum(playerdetails_2.TRB), sum(playerdetails_2.AST),  sum(playerdetails_2.STL),sum(playerdetails_2.BLK),sum(playerdetails_2.TOV), sum(playerdetails_2.PF), sum(playerdetails_2.PTS), avg(exp.experience)
FROM 
	playerdetails_2 
		left join playersalary on playerdetails_2.playerid = playersalary.playerid and playerdetails_2.season = playersalary.season and playerdetails_2.teamid = playersalary.teamid
		join (select
		distinct
		pd.playerid,
		season,
		age-minage experience
	from
		(select
			playerid,
			min(age) minage
		from
			playerdetails_2
                where
			teamid <> 105 
		group by
			playerid
		) a,
		playerdetails_2 pd
	where
		pd.playerid = a.playerid and		
                pd.teamid <> 105
	)exp on exp.playerid = playerdetails_2.playerid and exp.season=playerdetails_2.season
		
where
	playerdetails_2.teamid <> 105
 group by
playerdetails_2.playerid, playerdetails_2.season
)
where
	season in ('2003-04','2004-05','2005-06','2006-07','2007-08','2008-09','2009-10','2010-11','2011-12', '2012-13') and salary is not null
group by
	playerid
having
	count(season) = 10
