import string, json, random
from random import shuffle

## Helper functions
def getUserString(size):
    return ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(size))

def getUserType(id):
    return chr(65 + (id%5))

def getUserID(id):
    return str(1000000 + id)

def generateUserData(id, size):
    return '{\"_id\":' + getUserID(id) + ', \"username\": \"' + getUserType(id) + getUserID(id) + '\", \"userclass\": \"' + getUserType(id) + '\", \"userstring\": \"' + getUserString(size) + '\" }'

def divideCollection(coll, no_of_chunks):

    chunks = []
    chunk_size = round(len(coll) / no_of_chunks)

    for chunk_idx in range(no_of_chunks):
        chunks.append(coll[chunk_idx * chunk_size: (chunk_idx + 1) * chunk_size])
        
    return chunks
    
class DocumentCollection:

    def __init__(self, logger, noc=1000000, size=100):
        
        self._logger = logger

        if noc > 1000000:
            self._logger.info("Setting the number of documents to 1,000,000 (maximum collection size).")
            noc = 1000000
        
        # id: 7 chars
        # username: 8 chars
        # user class: 1 char
        # userstring: 15
        # rest: 60 chars
        # total: 91 chars
        if size < 77:
            self._logger.info("Setting the payload size to minimum acceptable size.")
            size = 77

        self._number_of_collections = noc
        self._document_payload_size = size - 76
        self._document_collection = []

    def generate(self):
        self._logger.info("generating documents...")
        for i in range(self._number_of_collections):
            singleDoc = []
    
            docItem = generateUserData(i, self._document_payload_size)
            singleDoc.append(docItem)
            self._document_collection.append(singleDoc)   

        ## Shuffling documents
        shuffle(self._document_collection)
        self._logger.info(str(len(self._document_collection)) + " documents generated as test data!")
        return self._document_collection

    def printOne(self):
        if len(self._document_collection) != 0:
            print(self._document_collection[0])
        else:
            print("Object is not instantiated!")
    pass