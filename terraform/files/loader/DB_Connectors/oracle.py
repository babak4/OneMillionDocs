import cx_Oracle, json
from DB_Connectors.config_manager import get_db_config
import threading

class OracleConnector:
    def __init__(self, logger, dop=1):
        
        self._logger = logger

        config = get_db_config("oracle")
        self._logger.info("Retrieved the configuartion for Oracle from config.ini")

        self._user = config['user']
        self._password = config['password']
        self.connectionString = config['host'] + ":" + config['port'] + "/" + config['database']
        
        self._logger.info("Connecting to Oracle on: " + self.connectionString)
        self._logger.debug("Username: " + self._user)
        
        self._collection_name = config['tablename']

        # if dop == 1:
        #     self.connection = cx_Oracle.connect(config['user'], config['password'], connectionString)
        #     self._logger.info("Connection established to Oracle on: " + connectionString)
        # else:
        #     # should we "acquire" a pool when starting a connection? or at the start of the process for eaxh thread?
        #     _pool = cx_Oracle.SessionPool(config['user'], config['password'], connectionString, min=1, max=dop, increment=1, threaded=True)
        #     self.connection = _pool.acquire()


    def single_thread_insert_docs(self, document_collection):

        connection = cx_Oracle.connect(self._user, self._password, self.connectionString)
        connection.autocommit = True
        
        self._logger.info("Connection established to Oracle on: " + self.connectionString)
        oracle_cursor = connection.cursor()
        insert_statement_str = "INSERT INTO {}(document) VALUES (:doc)".format(self._collection_name)

        self._logger.info("Inserting the documents into " + self._collection_name)

        for run_idx in range(len(document_collection)):
            oracle_cursor.execute(insert_statement_str, {"doc" : document_collection[run_idx][0]})

        self._logger.info("inserted " + str(len(document_collection)) + " collections into " + self._collection_name)

        oracle_cursor.close()
        connection.close()


    def insert_docs(self, document_collection_chunks):
        
        threads = []
        for chunk in document_collection_chunks:
            t = threading.Thread(target=self.single_thread_insert_docs, args=(chunk, ))
            t.start()
            threads.append(t)
        
        for thread in threads:
            thread.join()


    def truncate_collection(self):
        
        connection = cx_Oracle.connect(self._user, self._password, self.connectionString)
        connection.autocommit = True
        oracle_cursor = connection.cursor()

        oracle_cursor.execute("truncate table {}".format(self._collection_name))
        self._logger.info("Dropped the collection: " + self._collection_name)

        oracle_cursor.close()
        connection.close()
