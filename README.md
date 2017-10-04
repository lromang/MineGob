# MINEGOB 
![alt text][logo]
 
[logo]: https://github.com/lromang/MineGob/blob/master/images/miner.png
 
## Description
 
This repository contains multiple functions that allow any given user to mine, process and publish statistical information regarding the behaviour of the distinct datasets available at www.datos.gob.mx. The general pipeline goes as follows: 
 
* Extract dataset metadata from ckan
* Process metadata and extract statistical information regarding resources, datasets, and institutions.
* Integrate data with information extracted from google analytics. 
* Upload the data sets into a drive repository.
* Register transaction in Zendesk.
 
## Usage
 
In the following, we'll assume the user is located in the **src** directory. An empty **data** should be created at the same level as **src**.
 
 
### Extract dataset from CKAN
 
Simply execute (dependencies stated at the top of the file): 
 
```
./mine_ckan.py
```
 
the output dataset, **MAT.csv**, will be stored at **../data/MAT.csv**.
 
### Process metadata and Google Analytics integration
 
For this step you need to edit and execute **process.R**. Firstly, replace *AUTH* and *KEY* with your actual values
 
```
token <- Auth("AUTH.apps.googleusercontent.com",
              "KEY")
```
 
Secondly, after executing for the first time and authorizing the application, the following lines might be commented:
 
```
token <- Auth("AUTH.apps.googleusercontent.com",
              "KEY")
save(token, file="oauth_token")
load("oauth_token")
## Validatetoken
ValidateToken(token)
```
 
### Upload data sets into drive repository
 
Replace **path='....'** with actual path and execute:
 
```
./upload.py
```
 
### Register transaction in Zendesk
 
Edit **send_urls.R** replacing the following with actual values
 
```
    email   <- "mail@mail"
    admi    <- "user"
    idad    <- "123456"
    subid   <- "123456"
```
 
as well as `mail@mail:psswd` in **cl_curl**. Afterwards simply:
 
```
./send_urls.R
```
