from platform import python_version
print(python_version())

import string
import random
from random import shuffle
import time
import json

## Helper functions
def getUserString():
    return ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(10))

def getUserType(id):
    return chr(65 + (id%5))

def execute_and_time(func, args, action):
    startTime = time.time()
    func(*args)
    endTime = time.time()

    print(action + " finished in " + str(round(endTime - startTime)) + " seconds.")

## Why a list of single-item lists? So that the collection can be used for batch inserts in Oracle, as well.    
def generate_1M_docs():
    for i in range(1000000):
        singleDoc = []
        docItem = '{\"_id\":' + str(i) + ', \"username\": \"' + getUserType(i) + str(i) + '\", \"userclass\": \"' + getUserType(i) + '\", \"userstring\": \"' + getUserString() + '\" }'
        singleDoc.append(docItem)
        oneMillionDocs.append(singleDoc)   
    
## Generation of test data
oneMillionDocs = []

execute_and_time(generate_1M_docs, (), "Generation of 1M documents")

## Shuffling documents
shuffle(oneMillionDocs)

import pymongo
pymongo.version

def mdb_inesrt_1M_docs(coll):
    for i in range(1000000):
        coll.insert_one(json.loads(oneMillionDocs[i][0]))
    
mclient = pymongo.MongoClient("mongodb://localhost:27017")
oneMillionDocDB = mclient["oneMillionDocDB"]
OMDcoll = oneMillionDocDB["oneMillionDocColl"]

## Inserting OneMillionDocs into MongoDB
for run_idx in range(10):
    print("Run: " +str(run_idx + 1))
    x = OMDcoll.delete_many({})
    print(x.deleted_count, " documents deleted.")
    execute_and_time(mdb_inesrt_1M_docs, (OMDcoll,), "Storing 1M documents in MongoDB")

mclient.close()
