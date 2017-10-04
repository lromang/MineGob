# MINEGOB 
![alt text][logo]

[logo]: https://github.com/lromang/MineGob/blob/master/images/miner.png

## Description

This repository contains multiple functions that allow any given user to mine, process and publish statistical information regarding the behaviour of the distinct datasets available at www.datos.gob.mx. The general pipeline goes as follows: 
 
* Extract dataset metadata from ckan
* Process the metadata and extract statistical information regarding resources, datasets, and institutions.
* Integrate data with information extracted from google analytics. 
* Upload the datasets into a drive repository.
* Register transaction in Zendesk.

## Usage


### Extract dataset from CKAN

If you are in the src directory, you must create a **../data** directory. Afterwards, simply execute (dependencies stated at the top of the file): 

```
./mine_ckan.py
```

the output datsets **MAT.csv** will be stored at **../data/MAT.csv**.
