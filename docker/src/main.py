#!/usr/bin/python3
# -*- coding: utf-8 -*-

import psycopg2
import logging
import sys
import os
import time

logger = logging.getLogger("main")

logging.basicConfig(stream=sys.stdout, level=os.getenv('LOGLEVEL', 'INFO'))

conn = psycopg2.connect("")
conn.autocommit = True

curs = conn.cursor()

while True:
  logging.debug(u'Fetching new job')
  curs.execute('SELECT pgcron.run()')
  resp = curs.fetchone()

  if resp and resp[0] == True:
    logging.debug(u'Sleep 1 sec')
    time.sleep(1)
    continue

  logging.debug(u'Sleep 30 sec')
  time.sleep(30)
