import kr8s

for pod in kr8s.get("pods", namespace=kr8s.ALL):
    print(pod.metadata.namespace, pod.metadata.name)