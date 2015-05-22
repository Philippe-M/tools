export-images.sh : récupère des fichiers depuis phpwebgallery avec le nom de fichier contenue dans un csv. Gestion de la barre de progression.

create_user_ftp.py : gère les comptes utilisateur ftp pour vsftp

importedi-agp.py : scrupte un répertoire sur un ftp distant, si il y a un nouveau fichier ça le télécharge et envoie un mail à une liste de destinataire

retour-ligne.sh : lit une liste de ligne d'un fichier, concatène le résultat en ajoutant un ; et ajoute un retour à la ligne toute les 10 lignes.

extract-pdf.sh : extrait les images, textes et créé explose le pdf en autant de page qu'il contient

mail.sh : lit une liste de ligne dans un fichier pour les mettre sur 1 lignes en ajoutant un ; comme séparateur. Tout les 10 enregistrements une nouvelle ligne est créé.

mouvRename.sh : Liste le contenue d'un répertoire, recherche le nom du fichier sans l'extension dans un fichier csv et renomme ce fichier par une des colonnes du csv

convert_export.sh : Transforme un enregistrement sur deux lignes en une avec un séparateur
