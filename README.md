# sentinel3-to-utm-pipeline
pipeline for utm/mgrs tile gen

## detached pipeline run
```sh
docker run -d --net host \
  -e CPUS=1 \
  -e DISK=32 \
  -e DOCKER_IMAGE="asamerh4/sentinel3-to-utm:0e1bd51" \
  -e DOCKER_MEM="12G" \
  -e DOCKER_SWAP="12G" \
  -e MEM=4000 \
  -e SOURCE_BUCKET="sentinel3-rbt" \
  -e TARGET_BUCKET="sentinel3-tiles" \
  -e S3_PRODUCT_INFO_PREFIX="s3://sentinel3-rbt/products/" \
  -e UNIQUE_FILE="xfdumanifest.xml" \
  -e USERDATA_MTD_URL="localhost/user-data" \
  -e MESOS_MASTER=192.168.0.197 \
  -e FRAMEWORK_NAME=tiler001 \
asamerh4/sentinel3-to-utm-pipeline:584e2ed
```
