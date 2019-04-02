import time, logging

def execute_and_time(func, args, action, logger):
    startTime = time.time()
    func(*args)
    endTime = time.time()

    execution_time = endTime - startTime
    logger.info(action + " finished in " + str(round(execution_time)) + " seconds.")
    return execution_time
