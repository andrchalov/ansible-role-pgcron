#!/usr/bin/python3
# -*- coding: utf-8 -*-

import os
import os.path
import sys
import psycopg2
import psycopg2.extensions
import json
import time
import pprint
import select
import logging

PGHOST = os.environ.get('PGHOST', 'localhost')

LOGLEVEL = os.environ.get('LOGLEVEL', 'INFO')

numeric_level = getattr(logging, LOGLEVEL.upper(), None)
if not isinstance(numeric_level, int):
  raise ValueError('Invalid log level: %s' % loglevel)

logging.basicConfig(format = u'%(filename)s[LINE:%(lineno)d]# %(levelname)-8s [%(asctime)s]  %(message)s', level = numeric_level)

### FUNCTIONS ###

conn = psycopg2.connect(host=PGHOST)
conn.autocommit = True

cur = conn.cursor()

while 1:
  logging.debug(u'Run cron')
  cur.execute('SELECT pgcron.run()')
  resp = cur.fetchone()

  if resp and resp[0] == True:
    logging.debug(u'Sleep 1 sec')
    time.sleep(1)
    continue

  logging.debug(u'Sleep 30 sec')
  time.sleep(30)
