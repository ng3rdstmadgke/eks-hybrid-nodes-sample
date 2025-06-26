import ray
import os
import time
from pprint import pprint

address = os.getenv("RAY_CLIENT_ADDR")
ray.init(address=address)

pprint(ray.cluster_resources())

@ray.remote(num_cpus=0.25)
def waiting(id):
    time.sleep(id)
    return id

if __name__ == "__main__":
    print(ray.get([waiting.remote(10) for x in range(5)]))
