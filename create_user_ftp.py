#!/usr/bin/python
# -*- coding: utf-8 -*-
# __author__ Philippe MALADJIAN (http://blogoflip.fr)
# __version__ 2.0

import os
import re
import hashlib
import time
import shutil
import stat
import ConfigParser
from bsddb import db

from optparse import OptionParser

# --- Variable global -------------
rootFtpDir ="/var/ftp"
rootFtpConf ="/etc/vsftpd"
userFtp = ""
# ---------------------------------

def createDir(dir):
	print "Création du répertoire " + dir
	try:
		os.makedirs(rootFtpDir + "/" + dir)
	except OSError:
		print "***[Warning] Erreur à la création du répertoire " + rootFtpDir + "/" + dir

def createUser(userFtp, levelStock):
	if levelStock != "0" and levelStock != "1":
		print "Niveau de détail du stock incorrecte"
		os._exit(1)
	else:
		if not userFtp:
			userFtp = raw_input('Taper le numéro de compte et le numéro d\'adresse de livraison (ex: 020005c01) : ')

		if re.compile('[^a-zA-Z0-9]').search(userFtp):
			print "Nom de compte invalide"
		else:
			if os.path.isdir(rootFtpDir + "/" + userFtp):
				print "Attention l'utilisateur existe déjà"
				os._exit(1)

			userFtp = userFtp.lower()

			createDir(userFtp + "/commandes")
			os.chmod(rootFtpDir + "/" + userFtp + "/commandes", 0770)
			os.chown(rootFtpDir + "/" + userFtp + "/commandes", 0, 50)
			createDir(userFtp + "/commandes/archives")
			os.chmod(rootFtpDir + "/" + userFtp + "/commandes/archives", 0770)
			os.chown(rootFtpDir + "/" + userFtp + "/commandes/archives", 0, 50)
			createDir(userFtp + "/tracking")
			os.chmod(rootFtpDir + "/" + userFtp + "/tracking", 0770)
			os.chown(rootFtpDir + "/" + userFtp + "/tracking", 0, 50)
			createDir(userFtp + "/bon_liv")
			os.chmod(rootFtpDir + "/" + userFtp + "/bon_liv", 0770)
			os.chown(rootFtpDir + "/" + userFtp + "/bon_liv", 0, 50)
			createDir(userFtp + "/maj_catalogue")
			createDir(userFtp + "/maj_stock")

			print "Création du fichier de configuration ftp"
			fichier = open(rootFtpConf + "/vsftpd_user_conf/" + userFtp, "w")
			fichier.write("local_root=" + userFtp + "\n")
			fichier.write("write_enable=yes" + "\n")
			fichier.write("anon_upload_enable=yes" + "\n")
			fichier.write("anon_mkdir_write_enable=no" + "\n")
			fichier.write("anon_other_write_enable=no" + "\n")
			fichier.write("local_umask=022" + "\n")
			fichier.write("anon_umask=022" + "\n")
			fichier.write("virtual_use_local_privs=no" + "\n")
			fichier.close()

			print "Création du fichier config.user"
			config = ConfigParser.RawConfigParser()
			config.add_section("default")
			config.set("default", "levelStock", levelStock)
			config.write(open(rootFtpConf + "/vsftpd_user_conf/" + userFtp + ".conf", "w"))

			print "Ajout du compte utilisateur au ftp"
			password = hashlib.md5(time.strftime('%j%H%M%S')).hexdigest()
			password = password[0:10]

			print "Génération du fichier db"
			logindb = db.DB()
			try:
				logindb.open(rootFtpConf + "/login.db", None, db.DB_HASH, db.DB_CREATE)
			except Exception, err:
				print "Erreur avec la connexion à la base !"
				print str(err)
				os._exit(1)

			try:
				logindb.put(userFtp, password)
			except Exception, err:
				print "Erreur pendant l'ajout du compte " + userFtp
				print str(err)
				os._exit(1)

			logindb.close()

			print "Montage du répertoire maj_catalogue"
			os.system("mount -r --bind /home/public/export/maj_catalogue " + rootFtpDir + "/" + userFtp + "/maj_catalogue")

			if levelStock == "1":
				print "Montage du répertoire maj_stock"
				os.system("mount -r --bind /home/public/export/maj_stock_det " + rootFtpDir + "/" + userFtp + "/maj_stock")
			else:
				print "Montage du répertoire maj_stock"
				os.system("mount -r --bind /home/public/export/maj_stock " + rootFtpDir + "/" + userFtp + "/maj_stock")

			print "+------------------------------+"
			print "| Compte créé avec succès      |"
			print "+------------------------------+"
			print "login : " + userFtp
			print "password : " + password

# +--------------------------------+
# | Supprime un compte utilisateur |
# | @userFtp : nom d'utilisateur   |
# +--------------------------------+
def deleteUser(userFtp):
	if userFtp == "":
		print "Précisez le nom d'utilisateur"
		os.exit(1)
	else:
		if os.path.isdir(rootFtpDir + "/" + userFtp):
			print "Démontage des répertoires"
			try:
				os.system("umount " + rootFtpDir + "/" + userFtp + "/maj_catalogue")
				os.system("umount " + rootFtpDir + "/" + userFtp + "/maj_stock")
			except Exception, err:
				print "Erreur pendant le démontage du répertoire"
				print str(err)
				os._exit(1)

			print "Suppression du répertoire " + rootFtpDir 
			try:
				shutil.rmtree(rootFtpDir + "/" + userFtp)
			except Exception, err:
				print "Erreur pendant la suppression du répertoire " + userFtp
				print str(err)
				os._exit(1)

			print "Suppression du fichier de configuration ftp"
			try:
				os.remove(rootFtpConf + "/vsftpd_user_conf/" + userFtp)
				os.remove(rootFtpConf + "/vsftpd_user_conf/" + userFtp + ".conf")
			except Exception, err:
				print "Erreur pendant la suppression du fichier de configuration " + userFtp
				print str(err)
				os._exit(1)

			print "Suppression du compte ftp"
			logindb = db.DB()
			try:
				logindb.open(rootFtpConf + "/login.db", None, db.DB_HASH, db.DB_CREATE)
			except Exception, err:
				print "Erreur avec la connexion à la base !"
				print str(err)
				os._exit(1)
			try:
				logindb.delete(userFtp)
			except Exception, err:
				print "Erreur pendant la suppression du compte " + userFtp + "de la base"
				print str(err)
				os._exit(1)
			try:
				logindb.close()
			except Exception, err:
				print "Erreur de connexion à la fermeture de la base : "
				print str(err)
				os._exit(1)
		else:
			print "L'utilisateur " + userFtp + " n'existe pas"

# +--------------------------------+
# | Liste des comptes utilisateurs |
# | présent dans rootFtpDir        |
# +--------------------------------+
def listUser():
	print "+--------------------------------+"
	print "| Comptes clients                |"
	print "+--------------------------------+"

	logindb = db.DB()
	try:
		logindb.open(rootFtpConf + "/login.db", None, db.DB_HASH, db.DB_DIRTY_READ)
	except Exception, err:
		print "Erreur de connexion avec la base : "
		print str(err)
		os._exit(1)

	# -------------------------
	# Utilisé pour le debug
	#cursor = logindb.cursor()
	#rec = cursor.first()

	#while rec:
	#	print rec
	#	rec = cursor.next()
	# -------------------------

	config = ConfigParser.ConfigParser()
	for user in logindb.keys():
		config.read(rootFtpConf + "/vsftpd_user_conf/" + user + ".conf")
		print "- " + user
		levelStock=config.get('default', 'levelStock')
		if levelStock == "1":
			print "  - Stock détaillé : oui"
		else:
			print "  - Stock détaillé : non"

	try:
		logindb.close()
	except Exception, err:
		print "Erreur de connexion à la fermeture de la base : "
		print str(err)
		os._exit(1)

# +-----------------------------+
# | Monter les répertoires des  |
# | clients                     |
# +-----------------------------+
def mountUser():
	logindb = db.DB()
	try:
		logindb.open(rootFtpConf + "/login.db", None, db.DB_HASH, db.DB_DIRTY_READ)
	except Exception, err:
		print "Erreur de connexion avec la base : "
		print str(err)
		os._exit(1)

	config = ConfigParser.ConfigParser()
	for user in logindb.keys():
		# Chargement du fichier de configuration utilisateur
		config.read(rootFtpConf + "/vsftpd_user_conf/" + user + ".conf")

		os.system("mount -r --bind /home/public/export/maj_catalogue " + rootFtpDir + "/" + user + "/maj_catalogue")

		if config.get('default', 'levelStock') == "1":
			os.system("mount -r --bind /home/public/export/maj_stock_det " + rootFtpDir + "/" + user + "/maj_stock")
		else:
			os.system("mount -r --bind /home/public/export/maj_stock " + rootFtpDir + "/" + user + "/maj_stock")
	try:
		logindb.close()
	except Exception, err:
		print "Erreur de connexion avec la base : "
		print str(err)
		os._exit(1)

# +-----------------------------+
# | Démonter les répertoires    |
# | des clients                 |
# +-----------------------------+
def umountUser():
	logindb = db.DB()
	try:
		logindb.open(rootFtpConf + "/login.db", None, db.DB_HASH, db.DB_DIRTY_READ)
	except Exception, err:
		print "Erreur de connexion avec la base : "
		print str(err)
		os._exit(1)

	for user in logindb.keys():
		os.system("umount " + rootFtpDir + "/" + user + "/maj_catalogue")
		os.system("umount " + rootFtpDir + "/" + user + "/maj_stock")
	try:
		logindb.close()
	except Exception, err:
		print "Erreur de connexion avec la base : "
		print str(err)
		os._exit(1)

def main():
	try:
		utilisation = "Utilisation : %prog [-asdlmu]"
		parser = OptionParser(utilisation)
		parser.add_option("-a", "--add", dest="createAccount", help="Ajouter un compte client", type="string", default=False)
		parser.add_option("-s", "--level", dest="levelStock", help="Niveau de détail du stock. 0 pour stock oui/non, 1 pour quantité en stock", type="string", default="0")
		parser.add_option("-d", "--del", dest="deleteAccount", help="Supprimer un compte client", type="string", default=False)
		parser.add_option("-l", "--list", action="store_true", dest="listAccount", help="Liste les comptes clients", default=False)
		parser.add_option("-m", "--mount", action="store_true", dest="mountUser", help="Monte les répertoires des utilisateurs", default=False)
		parser.add_option("-u", "--umount", action="store_true", dest="umountUser", help="Démonte les répertoires des utilisateurs", default=False)
		(options, args) = parser.parse_args()

		if options.createAccount:
			createUser(options.createAccount, options.levelStock)

		if options.deleteAccount:
			deleteUser(options.deleteAccount)

		if options.listAccount:
			listUser()

		if options.mountUser:
			mountUser()

		if options.umountUser:
			umountUser()

	except KeyboardInterrupt:
		print "\n"
		os._exit(0)

if __name__ == '__main__':
	main()
