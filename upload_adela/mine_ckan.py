#! /usr/bin/python

#### -----------------------------------------
#### Script for mining the contents of ckan
####
#### -----------------------------------------

##------------------------------
## Libraries
##------------------------------
import json, urllib, string
import pandas as pd

from socket import error as SocketError
import errno

##------------------------------
## Download list of datasets
##------------------------------
base         = "https://datos.gob.mx/busca/api/3/action/"
url_datasets = base + "package_list"
response     = urllib.urlopen(url_datasets)
all_datasets = json.loads(response.read())

## printable characters
printable = set(string.printable)

##------------------------------
## Download resources datasets
##------------------------------
## Dataset features.
conj_id    = []
conj_name  = []
conj_title = []
dep        = []
slug       = []
url_conj   = []
fecha_c    = []
fecha_m    = []
## Resource features.
res_name   = []
res_size   = []
res_desc   = []
res_id     = []
res_url    = []

########################################
# Add Features
########################################
k = 0
checkpoint = k
for i in all_datasets['result'][checkpoint:]:
    print k
    k = k + 1
    ## Obtain datasets.
    url_dataset = base + "package_search?q=" + i
    try:
        response    = urllib.urlopen(url_dataset)
        dataset     = json.loads(response.read())
    except SocketError as e:
        if e.errno != errno.ECONNRESET:
            raise
        pass
        ## For all resources.
    if len(dataset['result']['results']) > 0 :
        dataset_res = dataset['result']['results'][0]
        for resource in dataset_res['resources']:
            # Fill in datasets features
            conj_id.append(dataset_res['id'])  # Id del conjunto
            conj_name.append(dataset_res['name'])  # Nombre del conjunto
            conj_title.append(dataset_res['title'])  # Nombre del conjunto
            if dataset_res['organization'] is not None:
                dep.append(dataset_res['organization']['title']) # Dependencia
                slug.append(dataset_res['organization']['name']) # Slug
            else:
                dep.append('') # Dependencia
                slug.append('') # Slug
            url_conj.append(dataset_res['url'])  # URL del conjunto
            fecha_c.append(dataset_res['metadata_created']) # Metadata creation
            fecha_m.append(dataset_res['metadata_modified']) # Metadata modification
            # Fill in resources features
            res_name.append(resource['name'])
            res_id.append(resource['id'])
            res_size.append(resource['size'])
            res_desc.append(resource['description'])
            res_url.append(resource['url'])

########################################
# Create data table
########################################
d = {'slug'         :  slug,
     'dep'          :  dep,
     'conj'         :  conj_name,
     'conj_tit'     :  conj_title,
     'rec'          :  res_name,
     'fecha_m'      :  fecha_m,
     'fecha_c'      :  fecha_c,
     'rec_des'      :  res_desc,
     'rec_url'      :  res_url,
     'rec_id'       :  res_id,
     'conj_id'      :  conj_id}

## To DataFrame
mat = pd.DataFrame(data = d)

## Save results
mat.to_csv("./MAT.csv", encoding = "utf-8")
