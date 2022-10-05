# Simple Python script to create the postdata JSON files.
# Chris Joakim, Microsoft, September 2021
#
import json
import os
import argparse

if __name__ == "__main__":

    parser = argparse.ArgumentParser()
    parser.add_argument("--count", type=int)
    args = parser.parse_args()

    postdata = dict()
    queries = list()
    postdata['database']  = 'dev'
    postdata['container'] = 'volcano'
    postdata['queries']   = queries
    
    q1 = dict()
    #q1['sql'] = "select * from c where c.pk = 'GUM:MAJ' offset 0 limit 3"
    q1['sql'] = "select * from c where c.Region = 'Kamchatka' offset 0 limit 3"
    q1['count'] = args.count
    q1['verbose'] = 'true'

    #q2 = dict()
    #q2['sql'] = "select * from c where c.pk = 'CLT:MBJ'"
    #q2['count'] = 2 
    #q2['verbose'] = 'false'

    queries.append(q1)
    #queries.append(q2)

    print(json.dumps(postdata, sort_keys=False, indent=2))
