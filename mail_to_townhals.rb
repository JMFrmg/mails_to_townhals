require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'
require 'pry'
require "google_drive"
require "pp"
require "gmail"



page_of_all_departements = "http://annuaire-des-mairies.com/"

def web_page_by_nokogiri(url_web_page)
	return Nokogiri::HTML(open("#{url_web_page}"))
end

#La méthode suivante renvoie un hash avec le numéro des départements en clés et leurs noms en valeurs
def get_all_departements_names_and_numbers(page_of_all_departements)
	hash_of_departments_numbers_and_names = Hash.new
	page_of_all_departements.xpath("//tr/td/a").each do |department|
	department = department.text.split("|")
	department_name = department[1].gsub(" ", "")
	department_number = department[0].gsub(" ", "")
	hash_of_departments_numbers_and_names[department_number.to_i] = department_name
	end
	return hash_of_departments_numbers_and_names
end

#La méthode qui suit renvoie l'ensemble des noms des municipalités sous la forme d'un array
def get_all_towns_names(page_of_all_towns)
	list_of_towns_names = []	
	page_of_all_towns.xpath("//td/p/a").each do |town_name|
	list_of_towns_names.push(town_name.text.downcase!)
	end
	return list_of_towns_names
end

#La méthode qui suit renvoie l'adresse url de chaque ville sous la forme d'un array
def get_all_towns_url(page_of_all_towns)
	
	list_of_towns_url = []	
	page_of_all_towns.xpath("//td/p/a").each do |node|
	town_link = node["href"]
	town_link.slice!(0)
	town_link = "http://annuaire-des-mairies.com" + town_link
	list_of_towns_url.push(town_link)
	end
	return list_of_towns_url
end

#La méthode qui suit renvoie l'adresse mail d'une municapalité a partir de l'url
def get_the_email_of_a_townhal_from_its_webpage(page)
	email = page.css("td.style27")[5]
	email2 = email.css("p")
	email3 = email2.text
	return email3
end

#La méthode suivante renvoie la partie html d'un email type
def get_email_html(town_name)
    	content_type 'text/html; charset=UTF-8'
    	return  "Bonjour,<p>Je m'appelle Edouard, je suis élève dans une formation de code gratuite, ouverte à tous, sans restriction géographique, ni restriction de niveau. La formation s'appelle The Hacking Project (http://thehackingproject.org/). Nous apprenons l'informatique via la méthode du peer-learning : nous faisons des projets concrets qui nous sont assignés tous les jours, sur lesquel nous planchons en petites équipes autonomes. Le projet du jour est d'envoyer des emails à nos élus locaux pour qu'ils nous aident à faire de The Hacking Project un nouveau format d'éducation gratuite. Nous vous contactons pour vous parler du projet, et vous dire que vous pouvez ouvrir une cellule à #{town_name}, où vous pouvez former gratuitement 6 personnes (ou plus), qu'elles soient débutantes ou confirmées. Le modèle d'éducation de The Hacking Project n'a pas de limite en terme de nombre de moussaillons (c'est comme cela que l'on appelle les élèves), donc nous serions ravis de travailler avec #{town_name}.</p>"
end

#La méthode suivante recoit en paramètre un hash. Celui-ci doit contenir le nom des villes en clés et leurs adresses mails en valeurs associées. 
#La méthode envoie un mail type à chaque ville. Le nom de la ville destinataire apparait dans chaque mail.
def send_email(hash_of_towns)
	puts "Veuillez entrer votre adresse mail google"	
	id_google = gets
	puts "Veuillez entrer votre mot de passe"
	mdp_google = gets 
	gmail = Gmail.connect('#{id_google}','#{mdp_google}')
	hash_of_towns.each do |tow_name, tow_email|
		if tow_name != nil
			tow_email = tow_email.reverse
			tow_email.chop!
			tow_email = tow_email.reverse
			
			gmail.deliver do
  				to tow_email
  				subject "THP : une formation de développeur web dans votre commune"
  				body get_email_html(tow_name)
  			end
		end
		puts "Un email a été envoyé à la mairie de #{tow_name}"	
	end	
end

#Déclaration des principales variables globales
hash_of_departments_numbers_and_names = Hash.new
hash_of_towns_names_and_emails = Hash.new
array_of_departements_numbers = []
array_of_departments_names = []
hash_of_towns_names_and_emails_from_Google_Spreadsheet = Hash.new


puts "Appuyer sur entrer pour lancer le script"
a = gets

#Création d'un hash avec le numéro de chaque département en clé et son nom associé en valeur
hash_of_departments_numbers_and_names = get_all_departements_names_and_numbers(web_page_by_nokogiri(page_of_all_departements))
	array_of_departements_numbers = hash_of_departments_numbers_and_names.keys.sort
	array_of_departements_numbers.each do |number|
		puts " - #{number}   :  #{hash_of_departments_numbers_and_names[number]}" if number.to_s.length == 1
		puts " - #{number}  :  #{hash_of_departments_numbers_and_names[number]}" if number.to_s.length == 2
		puts " - #{number} :  #{hash_of_departments_numbers_and_names[number]}" if number.to_s.length ==3
	end	
	
	#L'utilisateur est invité à choisir un numéro de département
	print "\n Entrer le numéro d'un département : "
	user_choice_departement_number = gets
	puts "\n Création du Hash en cours..."

	#Génération du hash ayant pour clés les noms de chaque ville du département et comme valeurs leurs adresses emails respectives 
	department_name = hash_of_departments_numbers_and_names[user_choice_departement_number.to_i].downcase!.gsub(/[éèê]/, "e")
	department_web_page_url = page_of_all_departements+department_name+".html"
	array_of_all_department_towns = get_all_towns_names(web_page_by_nokogiri(department_web_page_url))
	user_choice_departement_number.chop!

	array_of_townhals_emails = []
	array_of_all_department_towns.each do |town_name|
		if town_name != nil
			town_name = town_name.to_s.gsub(" ", "-")
			townhal_web_page_url = page_of_all_departements + user_choice_departement_number + "/" + town_name + ".html"
			town_email = get_the_email_of_a_townhal_from_its_webpage(web_page_by_nokogiri(townhal_web_page_url))
			array_of_townhals_emails = array_of_townhals_emails.push(town_email)
			hash_of_towns_names_and_emails[town_name.capitalize!] = town_email.gsub(" ", "")
		end
	end
	
	puts "\p Un hash contenant l'ensemble des noms des villes du département choisi a été créé"

#La boucle suivante renvoie l'utilisateur au choix d'une fonction du script, jusqu'à ce qu'il choisisse 0
loop do
puts "\n\n Que voulez-vous faire?"
puts "\n Entrer 1 pour envoyer tous les noms et les adresses email des mairies du département dans un fichier json"
puts " Entrer 2 pour envoyer un email à toutes les mairies d'un département depuis le dernier fichier json créé"
puts " Entrer 3 pour envoyer tous les noms et les adresses email des mairies du département dans un fichier Google Spreadsheet"
puts " Entrer 4 pour envoyer un email à toutes les mairies d'un département depuis un fichier Google Spreadsheet"
puts " Entrer 0 pour quitter le script"
user_choice = gets
if user_choice.to_i == 0
	break

#Le bloc suivant crée un fichier json contenant un hash avec avec en clés les noms des communes du département et en valeurs leurs adresses email respectives 
elsif user_choice.to_i == 1
	f = File.new("#{department_name}.json", File::CREAT|File::TRUNC|File::RDWR, 0644)
	File.open("#{department_name}.json", 'w') do |f|
		f.write (hash_of_towns_names_and_emails.to_json)
	end
	puts "\n Un fichier json a été généré"

#Le bloc suivant extrait les noms des communes du départements et leurs adresses email respectives du fichier json créé préalablement
#Puis il envoie un email type à chaque commune
elsif user_choice.to_i == 2
	t_hash = Hash.new
	file = File.read("#{department_name}.json")
	datas = JSON.parse(file)
	datas.each do |t_name, t_email|
		t_hash[t_name] = t_email
	end
	send_email(t_hash)
  	
#Le bloc suivant envoie les noms des communes et leurs adresses email respectives dans un Google SpreadSheet
#Il est nécessaire d'entrer des tokens d'accès à un compte google et d'avoir créé un Google Spreadsheet
elsif user_choice.to_i == 3
	session = GoogleDrive::Session.from_config("config.json")
	ws = session.spreadsheet_by_key("15sHwa9hf6iYtI_FBrvOKNzA--VR_wVz9Xq3j1KcJ4qM").worksheets[0]
		
	compteur = 1
	hash_of_towns_names_and_emails.each do |town_name, townhal_email|
		ws[compteur, 1] = town_name
		ws[compteur, 2] = townhal_email
		compteur += 1
	end
	ws.save
	puts "\n Les données ont été envoyées dans un Google Spreadsheet"

#Le bloc suivant récupère les noms des communes et les adresses mails depuis un Google Spreadsheet rempli préalablement
elsif user_choice.to_i == 4
	puts "\n Récupération des données depuis le Google Spreadsheet"
	compteur = 0
	while compteur < hash_of_towns_names_and_emails.length
		session = GoogleDrive::Session.from_config("config.json")
		ws = session.spreadsheet_by_key("15sHwa9hf6iYtI_FBrvOKNzA--VR_wVz9Xq3j1KcJ4qM").worksheets[0]
		compteur += 1
		tw_mail = ws[compteur, 2]
		tw_mail = tw_mail.reverse
		tw_mail.chop!
		tw_mail = tw_mail.reverse
		hash_of_towns_names_and_emails_from_Google_Spreadsheet[ws[compteur, 1]] = tw_mail		
	end
	send_email(hash_of_towns_names_and_emails_from_Google_Spreadsheet)
end
end
