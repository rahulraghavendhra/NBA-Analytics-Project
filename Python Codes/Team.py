'''
@author: jayakumara
'''
from urllib import urlopen
from bs4 import BeautifulSoup
import collections
import datetime
import time
import sys

def getTeamsURL(url) :
    """Returns the teams-URL"""
    urlHTML = urlopen(url).read()
    soup = BeautifulSoup(urlHTML)
    scrapeContent = soup.find_all('tr', {'class' : 'full_table'})
    
    team = collections.defaultdict(dict)
    
    for content in scrapeContent:
	print content.td.a.text
        team[content.td.a.text]['name'] = content.td.a.text 
        team[content.td.a.text]['url'] = url + content.find('a').get('href').replace("/teams", "")
    
    return team

def getTeamStats(team):
	"""Fetches the team stats"""
	for key in team.keys():
		teamHTML = urlopen(team[key]['url']).read()
		soup = BeautifulSoup(teamHTML)
		scrapeContent = soup.find_all('tr', {'class' : ''})
		#print scrapeContent    
		for content in scrapeContent:
			string  = ""
			statsData = content.find_all('td')
			rowData = list()
			if statsData:
				url = team[key]['url']
				rowData.append(team[key]['url'])
				url_array = url.split("/")
				rowData.append(url_array[4])
			for row in statsData:
				rowData.append('"' + row.text.replace(u'\xa0', u'') + '"')
				if (row.find("a") and statsData.index(row) == 2):
					team_url = row.find("a")['href']
					rowData.append('"' + row.find("a")['href'] + '"')
					team_url_array = team_url.split("/")
					rowData.append(team_url_array[2])
			string = ",".join(rowData)
			team_stat.write(string)
			team_stat.write(",\n")
	
                
def getTeamInfo(team):
    """Fetches team info"""
#     print ('am inside the routine\n')
    for key in team.keys():
        teamHTML = urlopen(team[key]['url']).read()
        soup = BeautifulSoup(teamHTML)
        scrapeContent = soup.find_all('div', {'class' : 'mobile_text'})
            
        for content in scrapeContent:
#             print (content.encode('utf-8'))
            statsData = content.find_all('span')
             
            for spantag in statsData:
#                 print ("%s - %s\n" % (spantag.text.replace(":", ""), spantag.next_sibling))
                team[key][spantag.text.replace(":", "")] = spantag.next_sibling.rstrip()
            
    teamInfo = list()
    
    for key in team:
        rowData = list()
  	string  = key + "," + team[key]['url'] + "," + team[key]['Championships']
#        for col in team[key]:
 #           rowData.append(team[key][col])
#        string = ",".join(rowData)
	team_info.write(string)
	team_info.write(",\n")
        teamInfo.append(rowData)
    
    print (teamInfo)
    
    return team

def getCurrentTime():
    timeStamp = time.time()
    return datetime.datetime.fromtimestamp(timeStamp).strftime('%Y-%m-%d %H:%M:%S')

team_stat = open("team_stat.csv", 'w')
#team_info = open("team_info.csv", "w")
print (getCurrentTime() + "\n")
# Fetch teams URL
team = getTeamsURL("http://www.basketball-reference.com/teams")
print (team)
print("\n")
print(getCurrentTime() + "\n")

# print (getCurrentTime() + "\n")
getTeamStats(team)
# print (getCurrentTime() + "\n")

print (getCurrentTime() + "\n")
team = getTeamInfo(team)
#print (team)
print (getCurrentTime() + "\n")
