import time
import os

def contador(duration=15):

    end_time = time.time() + duration
    while time.time() < end_time:
        # Performing a computation-intensive task
        _ = [os.urandom(1024) for _ in range(1000)]

contador(15)
