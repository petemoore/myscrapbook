#!/bin/bash

TASK_ID="$(slug)"
cat << EOF | curl -v -H 'Content-Type: application/json' -X PUT --data-binary @- "http://localhost/queue/v1/task/${TASK_ID}"
{
  "provisionerId": "aws-provisioner-v1",
  "workerType": "gecko-1-b-linux",
  "schedulerId": "gecko-level-1",
  "retries": 5,
  "created": "$(date -u "+%Y-%m-%dT%H:%M:%S.000Z")",
  "deadline": "$(date -u -v +1H "+%Y-%m-%dT%H:%M:%S.000Z")",
  "expires": "$(date -u -v +24H "+%Y-%m-%dT%H:%M:%S.000Z")",
  "payload": {
    "maxRunTime": 10,
    "image": {
      "path": "public/image.tar.zst",
      "type": "task-image",
      "taskId": "Pr9OcxSqQlOjbytRDpHd2g"
    },
    "command": [
      "sleep",
      "60",
    ]
  },
  "metadata": {
    "owner": "pmoore@mozilla.com",
    "source": "https://hg.mozilla.org/",
    "description": "Pete test",
    "name": "pete-test"
  }
}
EOF

echo $TASK_ID
