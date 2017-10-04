#! /usr/bin/python
# coding: utf-8

from pydrive.auth import GoogleAuth
from pydrive.drive import GoogleDrive
import codecs
import time
import string
import pandas as ps

##------------------------------------------------
## AOUTH
##------------------------------------------------

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
## globals
printable = set(string.printable)
date  = time.strftime("%Y-%m-%dT%H:%M:%S")

##------------------------------------------------
## PUBLIC RESOURCES
##------------------------------------------------

## Read in data
mat = codecs.open("/home/luis/Documents/Work/Presidencia/MineGob/upload_adela/MAT.csv",
                  encoding='utf-8',
                  errors='ignore')
c   = mat.read()
## Encoding
## c         = filter(lambda x: x in printable, c)
## Print result
print("URL Descarga, Nombre")

## -------------
## XLSX
## -------------
title = "recursos_" + date +".xlsx"
## SAME FILE
file2   = drive.CreateFile({'title': title, 'id':'0B5p8KkRjjG4HVVlwc3RQLXlOeEU'})
content = file2.GetContentString()
file2.SetContentString(content.replace(content, c))
file2.Upload()
## DISTINCT
file1 = drive.CreateFile({'title': title,
                          'shareable':True,
                          'userPermission':[{'kind':'drive#permission',
                                             'type':'anyone',
                                             'value':'anyone',
                                             'role':'reader'}],
                          'mimeType':'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                          "parents":[{"kind":"drive#fileLink","id":"0Bw1YBQEbBwzDWWVkNmd1Wm9zb1E"}]
                      })
file1.SetContentString(c)
file1.Upload()

## Print results
print("https://drive.google.com/uc?export=download&id=" +
      file1['id'] +
      ", Recursos de datos" +
      date +
      "_xlsx.xslx")

## -------------
## CSV
## -------------
title = "recursos_" + date +".csv"
## SAME FILE
file2   = drive.CreateFile({'title': title, 'id':'0B5p8KkRjjG4HS1A0dkRBcmY2akE'})
content = file2.GetContentString()
file2.SetContentString(content.replace(content, c))
file2.Upload()
## DISTINCT
file1 = drive.CreateFile({'title': title,
                          'shareable':True,
                          'userPermission':[{'kind':'drive#permission',
                                             'type':'anyone',
                                             'value':'anyone',
                                             'role':'reader'}],
                          'mimeType':'text/csv',
                          "parents":[{"kind":"drive#fileLink","id":"0Bw1YBQEbBwzDWWVkNmd1Wm9zb1E"}]
                      })
file1.SetContentString(c)
file1.Upload()

## Print results
print("https://drive.google.com/uc?export=download&id=" +
      file1['id'] +
      ", Recursos de datos" +
      date +
      "_csv.csv")

##------------------------------------------------
## CONJUNTOS PUBLIC
##------------------------------------------------

## Lectura de datos
public_data  = codecs.open("/home/luis/Documents/Work/Presidencia/MineGob/upload_adela/public_data.csv",
                           encoding='utf-8',
                           errors='ignore')
c            = public_data.read()
## c            = filter(lambda x: x in printable, c)

## -------------
## CSV
## -------------
title = "conjunto_datos" + date +".csv"
## SAME FILE
file2   = drive.CreateFile({'title': title, 'id':'0B5p8KkRjjG4HSVJFdnZ5WnUyZUk'})
content = file2.GetContentString()
file2.SetContentString(content.replace(content, c))
file2.Upload()
## DISTINCT
file1 = drive.CreateFile({'title': title,
                          'shareable':True,
                          'userPermission':[{'kind':'drive#permission',
                                             'type':'anyone',
                                             'value':'anyone',
                                             'role':'reader'}],
                          'mimeType':'text/csv',
                          "parents":[{"kind":"drive#fileLink","id":"0Bw1YBQEbBwzDWWVkNmd1Wm9zb1E"}]
                      })
file1.SetContentString(c)
file1.Upload()

## Print results
print("https://drive.google.com/uc?export=download&id=" +
      file1['id'] +
      ", Conjuntos de datos" +
      date +
      "_csv.csv")


## -------------
## XLSX
## -------------
title = "conjunto_datos" + date +".xlsx"
## SAME FILE
file2   = drive.CreateFile({'title': title, 'id':'0B5p8KkRjjG4HQ3Rkdk5US0c4V3c'})
content = file2.GetContentString()
file2.SetContentString(content.replace(content, c))
file2.Upload()
## DISTINCT
file1 = drive.CreateFile({'title': title,
                          'shareable':True,
                          'userPermission':[{'kind':'drive#permission',
                                             'type':'anyone',
                                             'value':'anyone',
                                             'role':'reader'}],
                          'mimeType':'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                          "parents":[{"kind":"drive#fileLink","id":"0Bw1YBQEbBwzDWWVkNmd1Wm9zb1E"}]
                      })
file1.SetContentString(c)
file1.Upload()

## Print results
print("https://drive.google.com/uc?export=download&id=" +
      file1['id'] +
      ", Conjuntos de datos" +
      date +
      "_xlsx.xlsx")

##------------------------------------------------
## ANALYTICS PUBLIC
##------------------------------------------------

## Lectura de datos
resumen = codecs.open("/home/luis/Documents/Work/Presidencia/MineGob/upload_adela/datosgob_resum.csv",
                      encoding='utf-8',
                      errors='ignore')
c       = resumen.read()
## c       = filter(lambda x: x in printable, c)

## -------------
## CSV
## -------------
file2   = drive.CreateFile({'id':'0B5p8KkRjjG4HOHhwTHhwenBIUk0'})
content = file2.GetContentString()
file2.SetContentString(content.replace(content, c))
file2.Upload()

## Print results
print("https://drive.google.com/uc?export=download&id=" +
      file2['id'] +
      ", Feed de analytics DGM" +
      date +
      "_csv.csv")


## -------------
## XLSX
## -------------
title = "dgm_anlytics" + ".xlsx"
file2 = drive.CreateFile({'id':'0B5p8KkRjjG4HSE5qUmhrV3MtTk0'})
file2.SetContentString(c)
file2.Upload()

## Print results
print("https://drive.google.com/uc?export=download&id=" +
      file2['id'] +
      ", Feed de analytics DGM" +
      date +
      "_xlsx.xlsx")

##------------------------------------------------
## CONJUNTOS PUBLIC
##------------------------------------------------

## Lectura de datos
date_atencion = "201707"
f = codecs.open("/home/luis/Documents/Work/Presidencia/MineGob/data/atencion/" + \
                         date_atencion  + ".csv", encoding='utf-8',
                errors='ignore')
c            = f.read()

## -------------
## CSV
## -------------
title = "atencion_ciudadana_datos" + date +".csv"
## SAME FILE
file2   = drive.CreateFile({'title': title, 'id':'0B5p8KkRjjG4HZ1NDb19zQk5tMVE'})
content = file2.GetContentString()
file2.SetContentString(content.replace(content, c))
file2.Upload()
## DISTINCT
file1  = drive.CreateFile({'title': title,
                          'shareable':True,
                          'userPermission':[{'kind':'drive#permission',
                                             'type':'anyone',
                                             'value':'anyone',
                                             'role':'reader'}],
                          'mimeType':'text/csv',
                          "parents":[{"kind":"drive#fileLink","id":"0Bw1YBQEbBwzDWWVkNmd1Wm9zb1E"}]
                      })
file1.SetContentString(c)
file1.Upload()

## Print results
print("https://drive.google.com/uc?export=download&id=" +
      file1['id'] +
      ", Concentrado de peticiones al C. Presidente - " +
      date +
      "_csv.csv")


## -------------
## XLSX
## -------------
title = "atencion_ciudadana_datos" + date +".xlsx"
## SAME FILE
file2   = drive.CreateFile({'title': title, 'id':'0B5p8KkRjjG4HaFkxdFRCT2ZPSWs'})
content = file2.GetContentString()
file2.SetContentString(content.replace(content, c))
file2.Upload()
## DISTINCT
file1 = drive.CreateFile({'title': title,
                          'shareable':True,
                          'userPermission':[{'kind':'drive#permission',
                                             'type':'anyone',
                                             'value':'anyone',
                                             'role':'reader'}],
                          'mimeType':'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                          "parents":[{"kind":"drive#fileLink","id":"0Bw1YBQEbBwzDWWVkNmd1Wm9zb1E"}]
                      })
file1.SetContentString(c)
file1.Upload()

## Print results
print("https://drive.google.com/uc?export=download&id=" +
      file1['id'] +
      ", Concentrado de peticiones al C. Presidente - " +
      date +
      "_xlsx.xlsx")
