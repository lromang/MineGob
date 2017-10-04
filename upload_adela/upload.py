#! /usr/bin/python

from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
import codecs
import time
import string

gauth = GoogleAuth()

gauth.LoadCredentialsFile("mycreds.txt")
if gauth.credentials is None:
    ## Authenticate if they're not there
    gauth.LocalWebserverAuth()
elif gauth.access_token_expired:
    ## Refresh them if expired
    gauth.Refresh()
else:
    ## Initialize the saved creds
    gauth.Authorize()
## Save the current credentials to a file
gauth.SaveCredentialsFile("mycreds.txt")
## Drive
drive = GoogleDrive(gauth)

##------------------------------------------------
## Read MAT
##------------------------------------------------
mat = codecs.open("/home/luis/Documents/Work/Presidencia/MineGob/upload_adela/MAT.csv")
c   = mat.read()

printable = set(string.printable)
c         = filter(lambda x: x in printable, c)

## Upload file
title = "recursos_" + time.strftime("%Y-%m-%dT%H:%M:%S")+".csv"
file1 = drive.CreateFile({'title': title,
                          'shareable':True,
                          'userPermission':[{'kind':'drive#permission',
                                             'type':'anyone',
                                             'value':'anyone',
                                             'role':'reader'}],
                          'mimeType':'text/csv',
                          "parents":[{"kind":"drive#fileLink","id":"0B5p8KkRjjG4HYzBTbEIxWFdqZnM"}]
                      })
file1.SetContentString(c)
file1.Upload(param = {'convert':True})

##------------------------------------------------
## Read resumen
##------------------------------------------------
resumen = codecs.open("/home/luis/Documents/Work/Presidencia/MineGob/upload_adela/datosgob_resum.csv")
c       = resumen.read()
c       = filter(lambda x: x in printable, c)

## Update
file2   = drive.CreateFile({'id':'0B5p8KkRjjG4HOHhwTHhwenBIUk0'})
content = file2.GetContentString()
file2.SetContentString(content.replace(content, c))
file2.Upload()

## Download Link
print("https://drive.google.com/uc?export=download&id=0B5p8KkRjjG4HOHhwTHhwenBIUk0")

##------------------------------------------------
## Read red
##------------------------------------------------
redmx = codecs.open("/home/luis/Documents/Work/Presidencia/MineGob/upload_adela/redmx.csv")
c     = redmx.read()

printable = set(string.printable)
c         = filter(lambda x: x in printable, c)

## Upload file
file2   = drive.CreateFile({'id':'0B5p8KkRjjG4HbUkxSi15T01WMTQ'})
content = file2.GetContentString()
file2.SetContentString(content.replace(content, c))
file2.Upload()
print("https://drive.google.com/uc?export=download&id=0B5p8KkRjjG4HbUkxSi15T01WMTQ")
