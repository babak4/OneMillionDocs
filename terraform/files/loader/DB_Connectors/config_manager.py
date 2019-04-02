from configparser import ConfigParser
import os

def get_db_config(db):

    project_root_path = os.getcwd()
    config_path = project_root_path + "/DB_Connectors/"

    parser = ConfigParser()
    parser.read(config_path + "config.ini")

    db_config = {}
    if parser.has_section(db):
        items = parser.items(db)
        for item in items:
            db_config[item[0]] = item[1]
    else:
        raise Exception("{} not found in config.ini".format(db))

    return db_config
