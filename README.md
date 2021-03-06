# One Million Docs
## Comparing speed of row-by-row JSON document insert operation 
## on MongoDB(4.0.6), PostgreSQL(11.2), and Oracle (18.3)

Babak Tourani (babak4@gmail.com)<br/>
May 2019

**Disclaimer**: This is NOT a benchmark test! 

### Abstract ###
To make one million single transactions (inserts) using JSON documents and compare the time it takes to carry out the task on each database/datastore.

You can use the <a href="https://github.com/babak4/OneMillionDocs/blob/master/OneMillionDocs.ipynb">Jupyter Notebook in this repository</a> to re-run the tests.

### TL;DR ###
Oracle can handle the workload described in this test, faster than MongoDB.

**Update (08-MAY-19)**:
- Adding new invocation method. Run using the following command:
    ". /tmp/run_test_suite.sh [postgres|oracle|mongo]"
- The test script would run a suite of tests on the requested DB, using a range of message sizes, message numbers, and connection numbers.
    - Range of message sizes: 100, 250, 500, 1000, 2500, 5000, 10000 (Bytes)
    - Range of message numbers (per insert iteration): 1000, 2500, 5000, 10000, 25000, 50000, 100000
    - Range of number of connections: 1, 2, 4, 8, 16, 24
- The test results will be stored in a csv and can be uploaded to a GCP bucket.
- The test suite script runs the ~/OneMillionDocs/main.py application which can be invoked independently using the following options:
    - -d, --database - options are the same as above
    - -p, --degree-of-parallelism - Default value: 1 (i.e. inserting using a single connection)
    - -i, --iterations - How many times a test for a combination of (message size, message number, number of connections) is carried out. Default value: 5
    - -s, --message-size - Default value: 100 (Bytes)
    - -n, --number-of-messages - Default value: 1,000,000 (hence, "OneMillionDocs")
    - -c, --upload-results-to-gcp - accepts bucket name. No default values; i.e. will not attempt to upload the results into GCP bucket unless explicitly mentioned.
- The ~/OneMillionDocs/main.py (and therefore the test suite script) will shutdown the server after the test.

**Update (02-APR-19)**:
- Adding a stand-alone Python application (See terraform/files/loader)
- Adding GCP Terraform implementation (based on a custom CentOS7/Python3.7.2 image) which runs the tests (using the Python app) *locally* inside the DB nodes.

**Update (16-FEB-19)**: Kafka (single node broker with ZERO configuration changes compared to the <a href="https://kafka.apache.org/quickstart">Apache Kafka Quickstart Guide</a> proved to be 3X faster than any of the other data stores. Details coming up, soon.

### Note ###
This is an experiment based on (and not exactly the same as) a use-case that my company is dealing with, which is: numerous single JSON doc inserts in MongoDB (via large number of connections). Perhaps this is not a common use-case, although gathering high-frequency IOT data would resemble this workload.

This document:
* can not be used as an evidence that either database/data store is "better than the others", because:
    - it's only comparing one single specific "insert" scenario
    - it relies on different (Python) client libraries for each database/datastore which either one could be inefficient/buggy. Afterall, they are all developped by human beings!
* can not be used as an evidence that either database/data store is "better than the others" for insert operations, because it's testing only one type of insert operation: row-by-row (a.k.a. "slow-by-slow" in Oracle lingo).
* does not constitute a "good practice" example, whether in terms of patterns used (if any) in writing the Python code, or how a Jupyter Notebook is used, or even with regards to efficiency of dealing with such workload. It merely aims to gather information regarding the speed of the insert operation.

### Why row-by-row? ###
Because I'm trying to use MongoDB (which is currently in production in our environment) as a basis for comparison. Our datastore is receiving a large number of documents from a "compute farm" comprised of thousands of VMs. Therefore the "autocommit" connection parameter for both PostgreSQL and Oracle is set to True, because each insert legitimately constitutes a transaction.

### The Environment ###
**Clients:**
* Python via (this) Jupyter Notebook
    * Python 3.6.6 (3.7.2 on GCP instances)
    * PyMongo 3.7.2
    * psycopg 2.7.7
    * cx_oracle 7.1
    
**Servers/Guests:**
* Local: Oracle Linux VirtualBox via Vagrant
    * At the time of the test using "ol7-latest" would lead to creation of Oracle Linux 7.6 boxes.
    * Two cores
    * Four GBs of RAM
* GCP: n1-standard-4 instances with centos-7-v20190326 image and Python 3.7.2 (referenced as "packer-1553992517" in Terraform scripts)

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

### Recorded Times###
Run 1: 467 Secs<br/>
Run 2: 523 Secs<br/>
Run 3: 541 Secs<br/>
Run 4: 489 Secs<br/>
Run 5: 462 Secs<br/>
Run 6: 483 Secs<br/>
Run 7: 476 Secs<br/>
Run 8: 487 Secs<br/>
Run 9: 521 Secs<br/>
Run 10: 456 Secs<br/>

Avg: 490 Secs

## 2. PostgreSQL ##
* Vagrant file for PostgreSQL 11.2 can be found <a href="https://github.com/babak4/OneMillionDocs/blob/master/vagrant_boxes/PostgreSQL/Vagrantfile">here</a>.
    * using default "postgres" database
    * DDL statement for creating the table/index can be found <a href="https://github.com/babak4/OneMillionDocs/blob/master/vagrant_boxes/PostgreSQL/scripts/DDL.sql">here</a>.

### Recorded Times###
Run 1: 590 Secs<br/>
Run 2: 610 Secs<br/>
Run 3: 659 Secs<br/>
Run 4: 648 Secs<br/>
Run 5: 668 Secs<br/>
Run 6: 645 Secs<br/>
Run 7: 590 Secs<br/>
Run 8: 636 Secs<br/>
Run 9: 582 Secs<br/>
Run 10: 566 Secs<br/>

Avg: 619 Secs

## 3. Oracle ##
* Vagrant file for Oracle 18.3 can be found <a href="https://github.com/oracle/vagrant-boxes/tree/master/OracleDatabase/18.3.0">here</a>.
    * Oracle running on noarchivelog, with the following changed parameters:
        * sga_max_size = 2G
        * sga_target = 1152M
        * pga_aggregate_limit = 2G
        * pga_aggregate_target = 384M
    * DDL statement for creating the table/index can be found <a href="https://github.com/babak4/OneMillionDocs/blob/master/vagrant_boxes/Oracle/DDL.sql">here</a>.

### Recorded Times ###
Run 1: 499 Secs<br/>
Run 2: 509 Secs<br/>
Run 3: 510 Secs<br/>
Run 4: 459 Secs<br/>
Run 5: 428 Secs<br/>
Run 6: 433 Secs<br/>
Run 7: 455 Secs<br/>
Run 8: 407 Secs<br/>
Run 9: 471 Secs<br/>
Run 10: 449 Secs<br/>

Avg: 462 Secs

## Summary of results ##

Inserting 1M documents, row-by-row

<table>
    <tr>
        <td><b>Database/Datastore</b></td><td><b>Avg Time Over 10 Runs (Secs)</b></td>
    </tr>
    <tr>
        <td>Oracle 18c (18.3.0)</td><td>462</td>
    </tr>
    <tr>
        <td>MongoDB (4.0.6)</td><td>490</td>
    </tr>
    <tr>
        <td>PostgreSQL 11.2</td><td>619</td>
    </tr>
</table>

### WIP ###
* Multithreaded row-by-row insert comparison
* Bulk Inserts comparison
