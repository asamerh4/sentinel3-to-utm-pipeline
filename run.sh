#!/bin/bash
./tools/sentinel-3/s3_utmtiler_taskgroupinfo_gen.sh > tasklist
#cat tasklist | jq
mesos-batch --master=$MESOS_MASTER:5050 --task_list=file:///root/tasklist --framework_name=$FRAMEWORK_NAME
