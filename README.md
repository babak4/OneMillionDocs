# One Million Docs
## Comparing speed of row-by-row JSON document insert operation 
## on MongoDB(4.0.6), PostgreSQL(11.2), and Oracle (18.3)

**Disclaimer**: This is NOT a benchmark test! 

### Abstract ###
To make one million single transactions (inserts) using JSON documents and compare the time it takes to carry out the task on each database/datastore.

### Note ###

This is an experiment based on (and not exactly the same as) a use-case that my company is dealing with, which is: numerous single JSON doc inserts in MongoDB (via large number of connections). Perhaps this is not a common use-case, although gathering high-frequency IOT data would resemble this workload.

This document:
* can not be used as an evidence that either database/data store is "better than the others", because:
    - it's only comparing one single specific "insert" scenario
    - it relies on different (Python) client libraries for each database/datastore which either one could be inefficient/buggy. Afterall, they are all developped by human beings!
* can not be used as an evidence that either database/data store is "better than the others" for insert operations, because it's testing only one type of insert operation: row-by-row (a.k.a. "slow-by-slow" in Oracle lingo).
* does not constitute a "good practice" example. As you can read below (see "Why row-by-row?") the process flow is inherently flawed.

### Why row-by-row? ###
Because I'm trying to use MongoDB (which is currently in production in our environment) as a basis for comparison. Our datastore is receiving a large number of documents from a "compute farm" comprised of thousands of VMs. Therefore the "autocommit" connection parameter for both PostgreSQL and Oracle is set to True, because each insert legitimately constitutes a transaction.

### The Environment ###
**Clients:**
* Python via (this) Jupyter Notebook
    * Python 3.6.6
    * PyMongo 3.7.2
    * psycopg 2.7.7
    * cx_oracle 7.1
    
**Servers/Guests:**
* Oracle Linux VirtualBox via Vagrant
    * At the time of the test using "ol7-latest" would lead to creation of Oracle Linux 7.6 boxes.
* Two cores
* Four GBs of RAM

**Host:**
* Macbook Pro Late 2013 (2.3 GHz i7 - 16GB 1600MHz DDR3)
* Running one VM/test at a time

### Test Data ##
Payload is made of JSON documents like this:

{<br/>
    &emsp;"_id":12,<br/>
    &emsp;"username": "C12",<br/>
    &emsp;"userclass":"C",<br/>
    &emsp;"userstring": "X97J1BBD6Q"<br/>
}

The "_id" field is explicitly referenced and generated because each document in MongoDB will automatically be allocated one.

Also the "_id" field is indexed in PostgreSQL/Oracle because MongoDB automatically indexes the field.

## 1. MongoDB ##
* The vagrant file for the MongoDB server VM can be found <a href="https://github.com/babak4/OneMillionDocs/blob/master/vagrant_boxes/mongoDB/Vagrantfile">here</a>.

**Note 1:** I have run the test without generation of the "_id" field (MongoDB automatically generates it), but the results did not show a meaningful difference. I have kept the "_id" field so that the payload across three databases/datastores is identical.

**Note 2:** Remember that every insert in mongo is inherently a transaction.

### Recorded Times ###
Run 1: Secs
Run 2: Secs
Run 3: Secs
Run 4: Secs
Run 5: Secs
Run 6: Secs
Run 7: Secs
Run 8: Secs
Run 9: Secs
Run 10: Secs

## 2. PostgreSQL ##
* Vagrant file for PostgreSQL 11.2 can be found <a href="https://github.com/babak4/OneMillionDocs/blob/master/vagrant_boxes/PostgreSQL/Vagrantfile">here</a>.
    * using default "postgres" database
    * DDL statement for creating the table/index can be found <a href="https://github.com/babak4/OneMillionDocs/blob/master/vagrant_boxes/PostgreSQL/scripts/DDL.sql">here</a>.

### Recorded Times ###
Run 1: 606 Secs<br/>
Run 2: 611 Secs<br/>
Run 3: 597 Secs<br/>
Run 4: 595 Secs<br/>
Run 5: 607 Secs<br/>
Run 6: 629 Secs<br/>
Run 7: 599 Secs<br/>
Run 8: 597 Secs<br/>
Run 9: 574 Secs<br/>
Run 10: 621 Secs<br/>

## 3. Oracle ##
* Vagrant file for Oracle 18.3 can be found <a href= "https://github.com/oracle/vagrant-boxes/tree/master/OracleDatabase/18.3.0">here</a>.
    * Oracle running on noarchivelog, no audit, 
    * DDL statement for creating the table/index can be found here

### Recorded Times ###
Run 1:   Secs<br/>
Run 2:   Secs<br/>
Run 3:   Secs<br/>
Run 4:   Secs<br/>
Run 5:   Secs<br/>
Run 6:   Secs<br/>
Run 7:   Secs<br/>
Run 8:   Secs<br/>
Run 9:   Secs<br/>
Run 10:   Secs<br/>
