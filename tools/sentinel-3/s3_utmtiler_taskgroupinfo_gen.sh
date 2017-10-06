#!/bin/bash

set -e

#Sentinel-3 UTM tiler (https://github.com/asamerh4/sentinel3-to-utm) TaskGroupInfo generator
#Author: Hubert Asamer 2017
#jq required

#Creates a TaskGroupInfo Object needed for 'mesos-batch' from a Sentinel-3 product UUID list

#ENV-VARS - START

# CPUS=                    -> CPUS reserved for one ingestion task (int)
# DISK=                    -> DISK space (in MB) needed for one ingestion task (int)
# DOCKER_IMAGE=""          -> Docker image name of Sentinel-3 S3 ingester (string)
# DOCKER_MEM=""            -> Docker engine parameter for ingester mem-setting (string)
# DOCKER_SWAP=""           -> Docker engine parameter for ingester mem-swap-setting (string)
# MEM=                     -> RAM (in MB) needed for one ingestion task (int)
# USERDATA_MTD_URL=""      -> Provide custom URL for fetching instance metadata (string)
# SOURCE_BUCKET=""         -> Source bucket of L1 products/frames (string)
# TARGET_BUCKET=""         -> Bucket where results are written to
# UNIQUE_FILE=""           -> Unique file pattern inside a single tile S3-folder (string)

#ENV-VARS - END

#JSON skeletons for TaskInfo mesos.proto
export TaskGroupInfo='{"tasks":[]}'
export resources='[{"name":"cpus","type":"SCALAR","scalar":{"value":'$CPUS'}},{"name":"mem","type":"SCALAR","scalar":{"value":'$MEM'}}]'
export command='{"shell": false,"environment":{"variables":[]}}'
export container='{"type":"DOCKER","docker":{"image":"","parameters":[{"key":"memory","value":"'$DOCKER_MEM'"},{"key":"memory-swap","value":"'$DOCKER_SWAP'"}]}}'

#query s3 and print TaskGroupInfo to stdout
aws --endpoint-url https://obs.eu-de.otc.t-systems.com s3api list-objects \
--max-items 1000000 \
--bucket $SOURCE_BUCKET \
--prefix frames \
--output json |
jq '[.Contents[].Key | select(. | contains("xfdumanifest.xml"))] | map( . as $o | split("/")|
{
  ("name"):("S3_"+.[1]+"_"+.[2]+"_"+.[3]+"_"+.[4]+"_"+.[5]),
  ("task_id"):(
    {
      ("value"):("tilr_S3_"+.[1]+"_"+.[2]+"_"+.[3]+"_"+.[4]+"_"+.[5])
    }),
  ("agent_id"):({"value": ""}),
  ("resources"):(env.resources | fromjson),
  ("command"): (env.command | fromjson |
    .environment.variables = 
    [
	  {"name":"USERDATA_MTD_URL","value":(env.USERDATA_MTD_URL)},
      {"name":"S3_INPUT_PRODUCT_PREFIX","value":("s3://"+env.SOURCE_BUCKET+"/"+$o | rtrimstr(env.UNIQUE_FILE))},
      {"name":"S3_OUTPUT_PRODUCT_PREFIX","value":("s3://"+env.TARGET_BUCKET+"/")},
      {"name":"S3_PRODUCT_INFO_PREFIX","value":(env.S3_PRODUCT_INFO_PREFIX)}
    ]
  ),
  ("container"):(env.container | fromjson | .docker.image = (env.DOCKER_IMAGE))
}
)' > hash.json

echo $TaskGroupInfo | jq --slurpfile hash hash.json '.tasks=$hash[0]'

rm hash.json
