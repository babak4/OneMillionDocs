import pymongo, json
from DB_Connectors.config_manager import get_db_config
import threading

class MongoConnector:
    def __init__(self, logger):
        self._logger = logger
        config = get_db_config("mongodb")
        self._logger.info("Retrieved the configuartion for MongoDB from config.ini")

        connectionString = "mongodb://@@@" + config['host'] + ":" + config['port']
        connectionString += "/" + config['database']
        
        self._logger.info("Connection String: " + connectionString.replace("@@@", ""))
        self._database = config['database']
        self._collection_name = config['tablename']

        if config['user'] != "" and config['password'] != "":
            self._connectionString = connectionString.replace("@@@", config['user'] + ':' + config['password'] + "@")
            self._connectionString += "?authSource=oneMillionDocDB"
            self._logger.info("Connecting via user: " + config['user'])
        else:
            self._connectionString = connectionString.replace("@@@", "")


    def single_thread_insert_docs(self, document_collection):
        _connection = pymongo.MongoClient(self._connectionString)
        _database = _connection[self._database]

        collection = _database[self._collection_name]

        self._logger.info("Inserting the documents into " + self._collection_name)
        for idx in range(len(document_collection)):
            collection.insert_one(json.loads(document_collection[idx][0]))
        self._logger.info("inserted " + str(len(document_collection)) + " documents into " + self._collection_name)

        _connection.close()

    def insert_docs(self, document_collection_chunks):
        threads = []
        for chunk in document_collection_chunks:
            t = threading.Thread(target=self.single_thread_insert_docs, args=(chunk, ))
            t.start()
            threads.append(t)
        
        for thread in threads:
            thread.join()


    def truncate_collection(self):

        _connection = pymongo.MongoClient(self._connectionString)
        _database = _connection[self._database]

        if self._collection_name in _database.list_collection_names():
            collection = _database[self._collection_name]
            collection.drop()
            self._logger.info("Dropped the collection: " + self._collection_name)
        else:
            self._logger.info("The collection " + self._collection_name + " does not exist yet.")
        
        _connection.close()

