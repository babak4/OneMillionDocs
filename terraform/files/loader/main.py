#! /anaconda/bin/python
import sys, getopt
from test_data import DocumentCollection
from DB_Manager import DB_Manager
import logging

def get_arguments (args):
        database = ""
        dop = 1
        iterations = 5
        message_size = 100
        message_count = 1000000
        upload_to_gcp = False
        gcp_bucket = None
        options, arguments = getopt.getopt(args, "d:p:i:s:n:c", ["database=", "degree-of-parallelism=", "iterations=", "message-size", "number-of-messages="])
    
        for option, argument in options:
                if option in ("-d", "--database"):
                        database = argument
                elif option in ("-p", "--degree-of-parallelism"):
                        dop = int(argument)
                elif option in ("-i", "--iterations"):
                        iterations = int(argument)
                elif option in ("-s", "--message-size"):
                        message_size = int(argument)
                elif option in ("-n", "--number-of-messages"):
                        message_count = int(argument)
                elif option in ("-c", "--upload-results-to-gcp"):
                        upload_to_gcp = True
                        gcp_bucket = argument
        return (database, dop, iterations, message_size, message_count, upload_to_gcp, gcp_bucket)

def main():
        LOGGING_FORMAT="[%(asctime)s,  %(threadName)s,  %(levelname)s] %(message)s"
        logging.basicConfig(filename='db_load_test.log', filemode='a', level=logging.DEBUG, format=LOGGING_FORMAT)
        logger = logging.getLogger(__name__)
        logger.info("**** ************************* ****")
        logger.info("**** Starting a DB Insert Test ****")

        database, dop, iterations, message_size, message_count, upload_to_gcp, gcp_bucket = get_arguments(sys.argv[1:])

        for l_threads in [1, 2, 4, 8, 16, 24]:
                for l_message_size in [100, 250, 500, 1000, 2500, 5000, 10000]:
                        for l_message_no in [1000, 2500, 5000, 10000, 25000, 50000, 10000]:
                                logger.info("DB: " + database)
                                logger.info("Number of Threads: " + str(l_threads))
                                logger.info("Number of Iterations: " + str(iterations))
                                logger.info("Number of Messages: " + str(l_message_no))
                                logger.info("Size of Messages (chars): " + str(l_message_size))

                                document_collection = DocumentCollection(logger, message_count, message_size)
                                document_collection = document_collection.generate()

                                mydbHandler = DB_Manager(logger, database, dop)
                                mydbHandler.insert_documents(document_collection, iterations)
                                mydbHandler.persist_results(upload_to_gcp, gcp_bucket)
                                logger.info("**** Finished The DB Insert Test ****")

if __name__ == "__main__":
        main()
