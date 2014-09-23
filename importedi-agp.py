#!/usr/bin/python
# -*- coding: utf-8 -*-

import ftplib as ftp
import os
import logging
import smtplib
import pdb
import time

from email.MIMEText import MIMEText

# --- Gestion des fichiers log ----
logger = logging.getLogger('root')
hdlr = logging.FileHandler('/var/log/importedi-agp.log')
formatter = logging.Formatter('%(asctime)s importtedi-agp : %(levelname)s : %(message)s')
hdlr.setFormatter(formatter)
logger.addHandler(hdlr)
logger.setLevel(logging.INFO)
# ---------------------------------

error = []
info = []

def connection(value=None):
	if value == None:
		return getattr(connection, 'value', None)
	else:
		connection.value = value
		return value

# Génération du mail pour l'envoie quand le transfert est ok
def sendMailInfo(destinataire, sujet, info):
	fromaddr = 'root@hilaire.fr'
	message = 'Les fichiers ci-dessous sont en attente : \n'
	i = 0
	while i < len(info):
		message = message + info[i] + '\n'
		i += 1

	mail = MIMEText(message)
	mail['From'] = fromaddr
	mail['Subject'] = sujet
	smtp = smtplib.SMTP()
	smtp.connect()
	for d in destinataire:
		mail['To'] = d
		smtp.sendmail(fromaddr, d, mail.as_string())
	smtp.close

# Génération du mail pour l'envoie du rapport d'erreur
def sendMailErreur(destinataire, sujet, error):
	fromaddr = 'root@hilaire.fr'
	message = 'Erreur pendant dans le transfert des fichiers avec les messages suivants : \n'
	i = 0
	while i < len(error):
		message = message + error[i] + '\n'
		i += 1

	mail = MIMEText(message)
	mail['From'] = fromaddr
	mail['Subject'] = sujet
	smtp = smtplib.SMTP()
	smtp.connect()
	for d in destinataire:
		mail['To'] = d
		smtp.sendmail(fromaddr, d, mail.as_string())
	smtp.close

def transfertHilaire():
	i = 0
	e = 0
	nbfic = 0
	fichier = ''
	#host = "ftp.atgpedi.net"
	host = "ftp1.atgpedi.net"
	mail_user = ['pmaladjian@hilaire.fr','cjoubert@hilaire.fr','cberthier@hilaire.fr','dberlingard@hilaire.fr']
	mail_admin = ['pmaladjian@hilaire.fr','ybouchek@hilaire.fr','cjoubert@hilaire.fr','cberthier@hilaire.fr','dberlingard@hilaire.fr','igerin@hilaire.fr']

	dirsrc = "/commandes"
	dirclt = "/home/public/edi/commande_client/agp/FIN/"
	user = "hilairesa"
	password = "5vkqVzQx"

	try:
		#pdb.set_trace()
		connection(ftp.FTP(host, user, password))
	except ftp.all_errors, err:
		logger.critical('Erreur de connexion à %s : %s', host, err)
		error.append('Erreur de connexion à ' + host + ' : ' + str(err))
		e += 1
	else:
		try:
			connection().cwd(dirsrc)
			logger.info('Connexion au serveur')
			info.append('Connexion au serveur')
		except ftp.all_errors, err:
			logger.critical('Erreur pendant le changement du répertoire %s : %s', dirsrc, err)
			error.append('Erreur pendant le changement de répertoire ' + dirsrc + ' : ' + str(err))
		else:
			try:
				listing = connection().nlst('*')
			except ftp.all_errors, err:
				if(str(err).split(' ')[0] != '450'):
					logger.critical('Pas de fichier à transférer : %s', err)
					error.append('Pas de fichier à transférer : ' + str(err))
					e += 1
			else:			
				for fichier in listing:
					f = open(dirclt+fichier, 'wb')
					try:
						connection().retrbinary('RETR ' + fichier, f.write)
					except ftp.error_perm, err:
						logger.critical('Erreur de téléchargement du fichier ' + fichier + ' : %s', err)
						error.append('Erreur de téléchargement du fichier ' + fichier + ' : ' + str(err))
						e += 1
						# Fermeture du fichier en cas d'erreur
						f.close
					else:
						logger.info('Téléchargement du fichier ' + fichier)
						info.append('Téléchargement du fichier ' + fichier)
						try:
							# Suppression du fichier du ftp
							connection().delete(fichier)
						except ftp.error_reply, err:
							logger.critical('Erreur de suppression du fichier ' + fichier + ' : %s', err)
							error.append('Erreur de suppression du fichier ' + fichier + ' : ' + str(err))
							e += 1						

						# Il y eu de fichiers de transférés
						nbfic += 1
					f.close
		connection().quit()

	if(nbfic > 0):
		sendMailInfo(mail_user, '[OK] - Récéption de commande EDI AGP', info)
	if(e > 0):
		sendMailErreur(mail_admin, '[ERREUR] - Récéption de commande EDI AGP', error)

def main():
	transfertHilaire()

if __name__ == '__main__':
    main()
