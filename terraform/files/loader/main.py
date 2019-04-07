#! /anaconda/bin/python
import sys, getopt, os, logging
from test_data import DocumentCollection
from DB_Manager import DB_Manager

def get_arguments (args):
        database = ""
        dop = 1
        iterations = 5
        message_size = 100
        message_count = 1000000
        upload_to_gcp = False
        gcp_bucket = None
        options, _ = getopt.getopt(args, "d:p:i:s:n:c", ["database=", "degree-of-parallelism=", "iterations=", "message-size", "number-of-messages="])
    
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
        
        l_message_size_ranges = [100, 250, 500, 1000, 2500, 5000, 10000]
        l_message_no_ranges = [1000, 2500, 5000, 10000, 25000, 50000, 10000]
        l_thread_ranges = [1, 2, 4, 8, 16, 24]

        test_count = 0
        test_count_total = len(l_message_no_ranges) * len(l_message_size_ranges) * len(l_thread_ranges)

        logger = logging.getLogger(__name__)
        logger.info("**** ************************* ****")
        logger.info("**** Starting a DB Insert Test ****")

        database, _, iterations, _, _, upload_to_gcp, gcp_bucket = get_arguments(sys.argv[1:])

        mydbHandler = DB_Manager(logger, database)
        for l_message_size in l_message_size_ranges:
                for l_message_no in l_message_no_ranges:
                        for l_threads in l_thread_ranges:
                                
                                test_count += 1
                                logger.info("DB: " + database + ", test " + str(test_count) + " of " + str(test_count_total))
                                logger.info("Size of Messages (chars): " + str(l_message_size))
                                logger.info("Number of Messages: " + str(l_message_no))
                                logger.info("Number of Threads: " + str(l_threads))
                                logger.info("Number of Iterations: " + str(iterations))

                                document_collection = DocumentCollection(logger, l_message_no, l_message_size)
                                document_collection = document_collection.generate()

                                mydbHandler.insert_documents(document_collection, l_threads, iterations)

        if upload_to_gcp:
                mydbHandler.upload_to_gcp(gcp_bucket)

        logger.info("**** Finished The DB Insert Test ****")
        os.system("sudo shutdown -h now")

if __name__ == "__main__":
        main()
