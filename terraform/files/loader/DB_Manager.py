from datetime import datetime
import logging, os
import pandas as pd
from utilities import execute_and_time
from DB_Connectors import mongodb, oracle, postgresql
from test_data import divideCollection

def factory(logger, db, dop=1):
    if db.lower().find("mongo", 0, len(db)) != -1:
        connector = mongodb.MongoConnector(logger, dop)
    elif db.lower().find("oracle", 0, len(db)) != -1:
        connector = oracle.OracleConnector(logger, dop)
    elif db.lower().find("postgres", 0, len(db)) != -1:
        connector = postgresql.PostgresqlConnector(logger, dop)
    else:
        raise ValueError("Cannot conect to {}".format(db))
    return connector

def get_connection(logger, db, dop=1):
    logger.info("Initiating DB_Manager instance...")        
    connectionFactory = None
    try:
        connectionFactory = factory(logger, db, dop)
    except ValueError as ve:
        logger.error("Failed to initiating a DB_Manager instance...")        
        logger.error(ve)
    
    return connectionFactory


class DB_Manager:
    
    runMetadata_lables = ['run id', 'db_name', 'doc size', 'number of docs', 'number of threads']
    runResults_labels = ['run_id', 'iteration', 'time']

    def __init__(self, logger, db_name, dop=1):
        self._logger = logger
        self._run_id = datetime.now().strftime("%Y%m%d%H%M%S")

        self._db_name = db_name
        self._dop = dop
        self._runMetadata = pd.DataFrame(columns = DB_Manager.runMetadata_lables)
        self._runResults = pd.DataFrame(columns = DB_Manager.runResults_labels)
        self._runMetadata_file = "run_metadata_{}_{}_p{}.csv".format(self._run_id, self._db_name, self._dop)
        self._runResults_file = "run_results_{}_{}_p{}.csv".format(self._run_id, self._db_name, self._dop)

        self.db_instance = get_connection(logger, db_name, dop)
        self._logger.info("Initiated the connection to " + db_name)

    
    def insert_documents(self, document_collection, iterations=10):

        self._logger.info("Starting the insert runs...")
        self._runMetadata = self._runMetadata.append({'run id': self._run_id, 'db_name': self._db_name, 'doc size': len(document_collection[0]), 'number of docs': len(document_collection), 'number of threads': self._dop}, ignore_index=True)

        document_collection_chunks = divideCollection(document_collection, self._dop)

        for run_idx in range(iterations):
            self._logger.info("Starting Run# " +str(run_idx + 1))
            
            self.db_instance.truncate_collection()

            execution_time = execute_and_time(self.db_instance.insert_docs, (document_collection_chunks, ), "Storing " + str(len(document_collection)) + " documents in " + self._db_name, self._logger)
            self._runResults = self._runResults.append({'run_id': self._run_id, 'iteration': run_idx + 1, 'time':  execution_time}, ignore_index=True)

    def persist_results(self, upload_to_gcp=False, gcp_bucket=None):
        self._runMetadata.to_csv(self._runMetadata_file, index=False)
        self._logger.info("Stored the run metadata in run_metadata_{}.csv".format(self._runMetadata_file))

        self._runResults.to_csv(self._runResults_file, index=False)        
        self._logger.info("Stored the run results in {}".format(self._runResults_file))
        if upload_to_gcp:
            os.system("sudo gsutil cp {} gs://{}".format(self._runMetadata_file, gcp_bucket))
            os.system("sudo gsutil cp {} gs://{}".format(self._runResults_file, gcp_bucket))
