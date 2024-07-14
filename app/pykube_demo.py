
import pykube

api = pykube.HTTPClient(pykube.KubeConfig.from_file())
for node in pykube.Node.objects(api):
    print(node.name)

