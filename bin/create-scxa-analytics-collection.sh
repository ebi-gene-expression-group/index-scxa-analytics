#!/usr/bin/env bash
SCHEMA_VERSION=6

set -e

# on developers environment export SOLR_HOST_PORT and export SOLR_COLLECTION before running
HOST=${SOLR_HOST:-"localhost:8983"}
COLLECTION=${SOLR_COLLECTION:-"scxa-analytics-v$SCHEMA_VERSION"}
NUM_SHARDS=${SOLR_NUM_SHARDS:-1}
REPLICATES=${SOLR_REPLICATES:-1}
MAX_SHARDS_PER_NODE=${SOLR_MAX_SHARDS_PER_NODE:-1}

printf "\n\nCreating collection $COLLECTION on $HOST"
curl "http://$HOST/solr/admin/collections?action=CREATE&name=$COLLECTION&numShards=$NUM_SHARDS&replicationFactor=$REPLICATES&maxShardsPerNode=$MAX_SHARDS_PER_NODE"

# Set this value to whatever is needed, it doesn’t really matter with current Lucene versions
# https://issues.apache.org/jira/browse/SOLR-4586
MAX_BOOLEAN_CLAUSES=100000000
printf "\n\nRaising value of maxBooleanClauses to $MAX_BOOLEAN_CLAUSES."
curl "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d "
{
  "set-property": {
    "query.maxBooleanClauses" : ${MAX_BOOLEAN_CLAUSES}
  }
}"

# Disable hard and soft auto-commits, we’ll do that explicitly when convenient
curl "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoCommit.maxTime":-1
  }
}'

curl "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoCommit.maxDocs":-1
  }
}'

curl "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoSoftCommit.maxTime":-1
  }
}'

curl "http://$HOST/solr/$COLLECTION/config" -H 'Content-type:application/json' -d '{
  "set-property": {
    "updateHandler.autoSoftCommit.maxDocs":-1
  }
}'
