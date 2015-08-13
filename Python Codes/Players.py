import urllib
from bs4 import BeautifulSoup
import re
import csv

player_links = []
def get_link_of_players():
	urlhandle = urllib.urlopen("http://basketball-reference.com/players/")
	content = urlhandle.read()
	soup = BeautifulSoup(content)
	links = soup.find_all('p')
	return links

def get_player_tables_info(link_of_player, player_name, divid, player_filehandle):
	print (divid + "\t" + player_name + "\t" + link_of_player)
	urlhandle = urllib.urlopen(link_of_player)
	content = urlhandle.read()
	soup = BeautifulSoup(content)
	players_total = soup.find("div", id=divid)
#	print players_total
	if not players_total:
		print (divid + " for player " + player_name + divid + "not found")
		return
	table_rows = players_total.find_all("tr")
#	print table_rows
	if not table_rows:
		print (divid + " for player " + player_name + divid + "not found for tr")
		return
	for table_row in table_rows:
		class_array = table_row['class']
		indices = [i for i, item in enumerate(table_row['class']) if re.search('stat', item)]
		if (divid == 'all_totals'):
			if class_array == [''] or indices:
				continue
		table_tds_ths = table_row.find_all("td");
		temp_array = []
		other_details = ""
		string = ""
		temp_array.append('"' + player_name + '"')
		for table_td_th in table_tds_ths:
			temp_array.append(' ') if table_td_th.text == "" else temp_array.append('"' + table_td_th.text.encode('ASCII', 'ignore') + '"')
		string = ','.join(temp_array)
		player_filehandle.write(string)
       		player_filehandle.write("\n");

def get_player_tables(links, divid, player_filehandle):
	for link in links:
                link_of_player = "http://basketball-reference.com" + link['href']
                print (divid + "\t" + link.text + "\t" + link_of_player)
                urlhandle = urllib.urlopen(link_of_player)
                content = urlhandle.read()
                soup = BeautifulSoup(content)
		players_total = soup.find("div", id=divid)
#		print players_total
		if not players_total:
			continue
		table_rows = players_total.find_all("tr")
#		print table_rows
		if not table_rows:
			continue
		for table_row in table_rows:
			class_array = table_row['class']
			table_tds_ths = table_row.find_all("td");
			temp_array = []
			other_details = ""
			string = ""
			for table_td_th in table_tds_ths:
				temp_array.append(' ') if table_td_th.text == "" else temp_array.append('"' + table_td_th.text.encode('ASCII', 'ignore') + '"')
				if (table_td_th.find("a") and divid == "div_players" and table_tds_ths.index(table_td_th) == 0):
					other_details=get_player_details(table_td_th.find("a")['href'], table_td_th.text)					
			string = ','.join(temp_array)
			string = string + ',' + other_details
			player_filehandle.write(string)
       			player_filehandle.write("\n");
	
def get_player_details(links, player_name):
		basic_info = ['Position:', 'Shoots:', 'Height:', 'Weight:', 'Born:', 'High School:', 'College:', 'NBA Debut:', 'Hall of Fame:', 'Died']
		link_of_player = "http://basketball-reference.com" + links	
		print link_of_player
		urlhandle = urllib.urlopen(link_of_player)
		content = urlhandle.read()	
		soup = BeautifulSoup(content)
		players = soup.find_all("p", class_="padding_bottom_half")
	#	players = soup.find_all("span")
		temp_array = []
		basic_data_string = ""
		for player in players:
			spans =  player.find_all('span')
			for span in spans:
				if span.get("data-birth"): 
					temp_array.append('"' + span.get("data-birth") + '"') 
				elif span.string == basic_info[1]:
					temp_array.append('"' + span.next_sibling + '"')
				elif span.get("data-death"):
					temp_array.append('"' + span.get("data-death") + '"')
			basic_data_string = ','.join(temp_array)
			basic_data_string = link_of_player + ',' + basic_data_string
		get_player_tables_info(link_of_player, player_name, "all_totals", player_totals)
		get_player_tables_info(link_of_player, player_name, "all_salaries", player_salaries)
		return basic_data_string
		
divid = ""			
player_info = open('player_info.csv', 'w')
player_info.write("Name, From, To, Position, Height, Weight, Born, College, URL, Shoots, DOB, Deceased")
player_info.write("\n");
player_totals = open('player_total.csv', 'w')
player_totals.write("Name,Season,Age,Tm,Lg,Pos,G,GS,MP,FG,FGA,FG%,3P,3PA,3P%,2P,2PA,2P%,eFG%,FT,FTA,FT%,ORB,DRB,TRB,AST,STL,BLK,TOV,PF,PTS")
player_totals.write("\n")
player_salaries = open('player_salaries.csv', 'w')
player_salaries.write("Name, Season, Team, Lg, Salary");
player_salaries.write("\n");
all_links = []
links = get_link_of_players()
hrefs = links[2].find_all("a");
all_links.append(hrefs[0])
#get_player_details(all_links)
#divid = "all_totals"
divid = "div_players"
get_player_tables(hrefs, divid, player_info)
player_info.close()
player_totals.close()
player_salaries.close()

