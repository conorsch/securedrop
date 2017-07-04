import os

from redis import Redis
from rq import Queue


if os.environ.get('SECUREDROP_ENV') == 'test':
    queue_name = 'test'
else:
    queue_name = 'default'

redis_server = os.environ.get('SECUREDROP_REDIS_SERVER', 'localhost')

# `srm` can take a long time on large files, so allow it run for up to an hour
q = Queue(name=queue_name,
          connection=Redis(host=redis_server),
          default_timeout=3600)


def enqueue(*args, **kwargs):
    return q.enqueue(*args, **kwargs)
