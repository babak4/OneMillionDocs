import psycopg2, json
from DB_Connectors.config_manager import get_db_config
import threading

class PostgresqlConnector:

    def __init__(self, logger):

        self._logger = logger
        self._logger.info("Retrieved the configuartion for Postgresql from config.ini")

        config = get_db_config("postgresql")
        self._logger.info("Connection String: " + config['host'] + ":" + config['port'] + "/" + config['database'])
        self._config = config


    def single_thread_insert_docs(self, document_collection):
        connection = psycopg2.connect(database=self._config['database'], user=self._config['user'], password=self._config['password'], host=self._config['host'], port=self._config['port'])
        connection.autocommit = True

        self._collection_name = self._config['tablename']
        postgres_cursor = connection.cursor()
        self._logger.info("Inserting the documents into " + self._collection_name)

        for idx in range(len(document_collection)):
            try:
                postgres_cursor.execute("INSERT INTO " + self._collection_name + " VALUES (%s)", (document_collection[idx][0],))
            except psycopg2.IntegrityError as e:
                self._logger.error(e)

        self._logger.info("inserted " + str(len(document_collection)) + " collections into " + self._collection_name)
        
        postgres_cursor.close()
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
        connection = psycopg2.connect(database=self._config['database'], user=self._config['user'], password=self._config['password'], host=self._config['host'], port=self._config['port'])
        connection.autocommit = True
        self._collection_name = self._config['tablename']
        postgres_cursor = connection.cursor()
        postgres_cursor.execute("truncate table {}".format(self._collection_name))
        self._logger.info("Dropped the collection: " + self._collection_name)
        postgres_cursor.close()
        connection.close()
