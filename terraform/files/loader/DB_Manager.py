from datetime import datetime
import logging, os
import pandas as pd
from utilities import execute_and_time
from DB_Connectors import mongodb, oracle, postgresql
from test_data import divideCollection

def factory(logger, db, dop=1):
    if db.lower().find("mongo", 0, len(db)) != -1:
        connector = mongodb.MongoConnector(logger)
    elif db.lower().find("oracle", 0, len(db)) != -1:
        connector = oracle.OracleConnector(logger)
    elif db.lower().find("postgres", 0, len(db)) != -1:
        connector = postgresql.PostgresqlConnector(logger)
    else:
        raise ValueError("Cannot conect to {}".format(db))
    return connector

def get_connection(logger, db):
    logger.info("Initiating DB_Manager instance...")        
    connectionFactory = None
    try:
        connectionFactory = factory(logger, db)
    except ValueError as ve:
        logger.error("Failed to initiating a DB_Manager instance...")        
        logger.error(ve)
    
    return connectionFactory


class DB_Manager:
    
    runResults_labels = ['run id', 'db_name', 'number of threads', 'doc size', 'number of docs', 'iteration', 'time']

    def __init__(self, logger, db_name):
        self._logger = logger
        self._run_id = datetime.now().strftime("%Y%m%d%H%M%S")
        self._db_name = db_name
        self._runResults = pd.DataFrame(columns = DB_Manager.runResults_labels)
        self._runResults_file = "run_results_{}_{}.csv".format(self._run_id, self._db_name)

        self.db_instance = get_connection(logger, db_name)
        self._logger.info("Initiated the connection to " + db_name)


    def insert_documents(self, document_collection, dop, iterations):

        self._logger.info("Starting the insert runs...")
        self._dop = dop

        document_collection_chunks = divideCollection(document_collection, self._dop)

        for run_idx in range(iterations):
            self._logger.info("Starting Run# " +str(run_idx + 1))
            
            self.db_instance.truncate_collection()

            execution_time = execute_and_time(self.db_instance.insert_docs, (document_collection_chunks, ), "Storing " + str(len(document_collection)) + " documents in " + self._db_name, self._logger)
            self._runResults = self._runResults.append({'run id': self._run_id, 'db_name': self._db_name, 'number of threads': self._dop, 'doc size': len(str(document_collection[0][0])), 'number of docs': len(document_collection), 'iteration': run_idx + 1, 'time':  execution_time}, ignore_index=True)
        
        self.persist_results()


    def persist_results(self):

        self._runResults.to_csv(self._runResults_file, index=False)        
        self._logger.info("Stored the run results in {}".format(self._runResults_file))

    
    def upload_to_gcp(self, gcp_bucket):
        upload_command = "sudo gsutil cp {} gs://{}".format(self._runResults_file, gcp_bucket)
        self._logger.info("Upload Command: {}".format(upload_command))
        os.system(upload_command)
