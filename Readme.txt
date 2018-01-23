Bonjour!

Voici comment fonctionne mon script :

Tout d'abord, il récupère l'ensemble des noms des départements et leurs numéros sur la page principale de l'annuaire des mairies. Puis, il les affiche et demande à l'utiliateur de choisir un numéro de département. Il va alors récupérer les noms et les adresses emails de chaque commune de ce département et les stocker dans un hash.

Une fois le hash des noms de communes et de leurs emails générés, l'utilisateur est invité à choisir une des quatre fonctions du script. 

Premièrement, il peut stocker les noms des communes et leurs adresses emails dans un fichier json. 

Deuxièmement, le script peut récupérer les données stockées préalablement dans un fichier json et envoyer un mail type à chaque commune. Cette deuxième fonction suppose que la première ait été préalablement exécutée. Il n'est pas nécessaire d'entrer préalablement votre adresse mail google et votre mot de passe dans le script. Ils vous seront demandés pendant l'exécution.

Troisièmement, il peut envoyer les noms des communes et leurs adresses emails dans un Google SpreadSheet. Cette fonction suppose d'entrer des tokens d'un compte google pour accéder à l'API. Ils doivent être renseignés dans le fichier "config.json". Il faut aussi indiquer au script la clé d'accès au Google SpreadSheet aux ligne 165 et 182. 

Quatrièmement, le script peut récupérer les données stockées prélalablement dans un google SpreadSheet et envoyer un email type à chaque ville du département choisi.

Bonne lecture :)
