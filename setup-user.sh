#!/bin/bash

#curl --write-out "%{http_code}" --user "elastic:authenticapppoc" --silent --output /dev/null --insecure https://192.168.99.101:8120

HEADER_CONTENT_TYPE="Content-type: application/json"
LAST_RESPONSE_LOG="lastResponse.out"

ELASTIC_URL="https://localhost:9200"

if [[ ! -z "$1" ]]; then
    USERNAME=$1
fi

if [[ ! -z "$2" ]]; then
    PASSWORD=$2
fi

if [[ -z "$USERNAME" ]]; then
    (>&2 echo "ERROR: The username of the user to setup must be provided to use this script.")
    exit 1
fi

if [[ -z "$PASSWORD" ]]; then
    (>&2 echo "ERROR: Host password for user 'elastic' must be provided to use this script.")
    exit 1
fi

set_kibana_password()
{
    CONTENT=$1

    # SSL certificates at NCR are not signed by CA, so skip validation.
    CURL_OPTS="--max-time 30 --insecure"
    CURL_DATA_OPT="--data"

    echo "Setting kibana password..."

    HTTP_CODE=$(curl $CURL_OPTS -u "elastic:$PASSWORD" -X POST "$ELASTIC_URL/_xpack/security/user/kibana/_password" -w "%{http_code}" -H "$HEADER_CONTENT_TYPE" -o $LAST_RESPONSE_LOG -s \
	    "$CURL_DATA_OPT" "$CONTENT")

    if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "201" ]]; then
        echo "$ELASTIC_URL/_xpack/security/user/kibana/_password was successfully set..."
        return 0
    elif [[ "$HTTP_CODE" == "400" ]]; then
        (>&2 echo "ERROR: Kibana password could not be set.")
    elif [[ "$HTTP_CODE" == "401" ]]; then
        (>&2 echo "ERROR: Access authorization failed. Make sure the password is correct.")
    else
        (>&2 echo "ERROR: Failed to call elastic search. Make sure the URL is correct.")
    fi

    echo $HTTP_CODE
    return 1
}

create_user()
{
    CONTENT=$1

    CURL_OPTS="--max-time 30 --insecure"
    CURL_DATA_OPT="--data"

    echo "Creating user '$USERNAME'..."

    HTTP_CODE=$(curl $CURL_OPTS -u "elastic:$PASSWORD" -X PUT "$ELASTIC_URL/_xpack/security/user/$USERNAME" -w "%{http_code}" -H "$HEADER_CONTENT_TYPE" -o $LAST_RESPONSE_LOG -s \
	    "$CURL_DATA_OPT" "$CONTENT")

    if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "201" ]]; then
        echo "$ELASTIC_URL/_xpack/security/user/$USERNAME was successfully created..."
        return 0
    elif [[ "$HTTP_CODE" == "400" ]]; then
        (>&2 echo "ERROR: User '$USERNAME' could not be created.")
    elif [[ "$HTTP_CODE" == "401" ]]; then
        (>&2 echo "ERROR: Access authorization failed. Make sure the password is correct.")
    else
        (>&2 echo "ERROR: Failed to call elastic search. Make sure the URL is correct.")
    fi

    echo $HTTP_CODE
    return 1
}

create_index_tempate()
{
    CONTENT=$1

    CURL_OPTS="--max-time 30 --insecure"
    CURL_DATA_OPT="--data"

	echo "Creating elastic search index template ..."

    HTTP_CODE=$(curl $CURL_OPTS -u "$USERNAME:$PASSWORD" -X PUT "$ELASTIC_URL/_template/all-shards-replicas" -w "%{http_code}" -H "$HEADER_CONTENT_TYPE" -o $LAST_RESPONSE_LOG -s \
    "$CURL_DATA_OPT" "$CONTENT")

    if [[ "$HTTP_CODE" == "200" ]]; then
      echo "$ELASTIC_URL/_template/all-shards-replicas is successfully created..."
      return 0
    elif [[ "$HTTP_CODE" == "400" ]]; then
      echo "INFO: Index template all-shards-replicas could not be created"
    elif [[ "$HTTP_CODE" == "401" ]]; then
      (>&2 echo "ERROR: Failed to authorize access. Make sure the password is correct.")
    else
      (>&2 echo "ERROR: Failed to call elastic search. Make sure the URL is correct.")
    fi

    echo $HTTP_CODE
    return 1
}

setup_es()
{
    set_kibana_password '{ "password" : "'$PASSWORD'" }'
    if [[ "$?" != "0" ]]; then
        return 1
    fi
    create_user '{
        "enabled": true,
        "password": "'$PASSWORD'",
        "roles": ["superuser"]
    }'
    if [[ "$?" != "0" ]]; then
        return 1
    fi

    create_index_tempate '{
        "index_patterns": ["*"],
        "settings": {
            "index.number_of_shards": 1,
            "index.number_of_replicas": 0
        }
    }'
    if [[ "$?" != "0" ]]; then
        return 1
    fi

    return 0
}

display_status_message()
{
    if [[ "$1" == "0" ]]; then
        echo "----------------------------------------------Finished ES setup"
    else
        echo "----------------------------------------------Failed ES setup"
        return $1
    fi
}

#sleep 15
while true; do
    # See if elasticsearch is up
    echo "----------------------------------------------Checking elasticsearch"
    HTTP_CODE=$(curl --write-out "%{http_code}" --user "elastic:$PASSWORD" --silent --output /dev/null --insecure $ELASTIC_URL)
    if [[ "$HTTP_CODE" == "200" ]] || [[ "$HTTP_CODE" == "201" ]]; then
        echo "----------------------------------------------Starting user setup"
        setup_es
        display_status_message $?
        exit $?
    else
        sleep 3;
    fi
done
