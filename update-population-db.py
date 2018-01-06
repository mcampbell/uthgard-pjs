#!/usr/bin/env python
'''Run through whatever log file and update the database with its values.  It
will check to see if this value is already there and insert if not.  Deleting
and inserting everything is kind of expensive and unnecessary.

Example log entries:

[2018-01-06T13:22:09-0500] Server Status � Online with 985 clients and 0 queued clients  �

[2017-12-28T19:26:28] <[Uth]Infobot>	 » Server Status » Online with 595 clients  «

In the old days we cared about queuing, but ... haha, not any more.
'''

import sqlite3
import argparse

########################################
def main():
    import re
    
    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--db', 
                        help='Name of the sqlite db file to use')
    parser.add_argument('-l', '--log', 
                        help='Name of the log file to parse for population figures',
                        type=argparse.FileType('r'))
    args = parser.parse_args()

    db_file = args.db if args.db else 'uthgard-population.db'
    conn = open_db(db_file)

    pop_re = re.compile(r'Server Status . Online with (\d+) clients')
    date_re = re.compile(r'\[(\d\d\d\d)-(\d\d)-(\d\d)T(\d\d):(\d\d):(\d\d)')
    try:
        for line in args.log:
            line = line.rstrip()
            
            m = pop_re.search(line)
            if m:
                pop = int(m.group(1))
                d_m = date_re.search(line)
                if d_m:
                    year = int(d_m.group(1))
                    month = int(d_m.group(2))
                    day = int(d_m.group(3))
                    hour = int(d_m.group(4))
                    minute = int(d_m.group(5))
                    second = int(d_m.group(6))
                    # print('{}-{}-{}:{}-{}-{}: {}'.format(year, month, day, hour, minute, second, pop))
                    upsert(conn, year, month, day, hour, minute, second, pop)
                else:
                    print('Could not parse date/time info from {}'.format(line))

            else:
                pass
#                print('{} did\'t parse for a population line'.format(line))

    finally:
        conn.commit()
        conn.close()
        
                    
########################################
def open_db(db_file):
    '''Open the sqlite file, try to create the table.  We can assume if the
    open works but the table creation fails, the table exists.
    '''
    conn = sqlite3.connect(db_file)
    conn.execute('''
    CREATE TABLE IF NOT EXISTS population(
        year       INT NOT NULL,
        month      INT NOT NULL,
        day        INT NOT NULL,
        hour       INT NOT NULL,
        minute     INT NOT NULL,
        second     INT NOT NULL,
        population INT NOT NULL)''')

    conn.execute('''
    CREATE INDEX IF NOT EXISTS ymdhms_idx 
    ON population(year, month, day)''')

    return conn

########################################
def upsert(conn, year, month, day, hour, minute, second, pop):
    vals = (year, month, day, hour, minute, second, pop)
    
    rows = conn.execute('''
    SELECT COUNT(*) 
    FROM population
    WHERE year = ? AND month = ? AND day = ?
    AND hour = ? AND minute = ? AND second = ?
    AND population = ?''', vals)
    for row in rows:
        count = int(row[0])
        if count == 0:
            conn.execute('''
            INSERT INTO population(year, month, day, 
            hour, minute, second, 
            population)
            VALUES (?, ?, ?, ?, ?, ?, ?)''', vals)

            print('+', end='', flush=True)
        else:
            print('.', end='', flush=True)
        

########################################

if __name__ == '__main__':
    main()
    print('\nDone.')
