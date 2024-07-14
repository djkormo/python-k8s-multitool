FROM python:3.11.9-alpine AS backend-builder

RUN apk --no-cache add gcc musl-dev curl bash

RUN pip install --upgrade pip

ADD app /app
RUN addgroup -S worker 
RUN adduser -D -h /home/worker -s /bin/bash worker -G worker

WORKDIR /home/worker

COPY --chown=worker:worker /app/requirements.txt requirements-minimal.txt

 # install packages as non root

USER worker

RUN pip install --no-cache-dir -r requirements-minimal.txt --no-warn-script-location --user -v

ENV PATH="/home/worker/.local/bin:${PATH}"

COPY --chown=worker:worker /app /home/worker/app 

RUN chmod u+x /home/worker/app/operator.bash


# Use a slim Python 3.11 image as the final base image
FROM python:3.11.9-alpine


RUN addgroup -S worker 
RUN adduser -D -h /home/worker -s /bin/bash worker -G worker

# Copy the built dependencies from the backend-builder stage
COPY --from=backend-builder /usr/local/lib/python3.11/site-packages/ /usr/local/lib/python3.11/site-packages/

# Copy binaries, e.x. kopf 
COPY --from=backend-builder /home/worker/.local/ /home/worker/.local/

ENV PATH="/home/worker/.local/bin:${PATH}"

# Set the working directory to /app

WORKDIR /home/worker

# Copy the application code from the backend-builder stage
COPY --from=backend-builder /home/worker/app /home/worker/app

RUN apk --no-cache add curl bash netcat-openbsd util-linux mc


USER worker

LABEL maintainer="Krzysztof Pudlowski <djkormo@gmail.com>" version="1.0.0"

# command to run 
#ENTRYPOINT ["/bin/bash", "-c", "/home/worker/app/operator.bash"]

#CMD ["python", "/home/worker/app/endless.py"]



