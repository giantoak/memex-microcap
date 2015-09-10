import json
from elasticsearch import Elasticsearch
import pandas as pd
import tangelo
import simplejson
from datetime import datetime
import urllib, urllib2
import numpy as np
from elasticsearch import Elasticsearch
import pprint
import statsmodels as sm
import requests
import sklearn as sk
from sklearn.neighbors import NearestNeighbors
import nltk
from textblob import TextBlob


def run(query=""):
        es = Elasticsearch(['es_url'])
        r=requests.get('https://www.quandl.com/api/v1/datasets/YAHOO/'+query+'.json')
        print r.json()
        microcap_feat=pd.read_csv('/path/to/microcap_features.csv')
        neigh = sk.neighbors.NearestNeighbors(5,1)
        microcap_feat=microcap_feat.dropna()
        X=microcap_feat.ix[:,1:]
        neigh.fit(X)
        pt=np.array(microcap_feat[microcap_feat['Symbol']==query])[0][1:]
        dist,ind=neigh.kneighbors(pt,5)
        nn=microcap_feat['Symbol'][ind[0]]
        nn2=map(lambda x: {'Symbol':x[0],'dist':x[1]},zip(list(nn), list(dist[0])))
        q={
          "size":5000,
          "query": {
            "query_string": {
                    "default_field": "body",
                    "query": "*"+query+"*"
                  }
          },
          "aggs": {
            "dates_with_holes": {
              "date_histogram": {
                "field": "postedTime",
                "interval": "day",
                "min_doc_count": 0
              }
            }
          }
        }
        
        res = es.search(body=q,index="memex-domains", doc_type='microcap')
        sentiment=[]
        for hit in res['hits']['hits']:
            sentiment.append({'date':hit['_source']['crawl_data']['postedTime'],'value':TextBlob(hit['_source']['crawl_data']['body']).sentiment.polarity})
   
        data=map(lambda x:{'date':str(x['key_as_string']),'value':x['doc_count']},res['aggregations']['dates_with_holes']['buckets'])
        return json.dumps({'yhoo':map(lambda x: {'Date':x[0],'Open':str(x[1]),'High':str(x[2]),'Low':str(x[3]),'Close':str(x[4]),'Volume':str(x[5])},r.json()['data']),\
         'sm':data,'nn':nn2,'sentiment':sentiment})

    