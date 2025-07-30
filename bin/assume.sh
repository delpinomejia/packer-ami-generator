#!/bin/bash

AWS_PROFILE=terraform
ASSUME_ENV="$1"
shift

case $ASSUME_ENV in
dev)
	# Removed deprecated ARN
	TF_VAR_aws_account="development"
	;;
test)
	# Removed deprecated ARN
	TF_VAR_aws_account="testing"
	;;
prod)
	# Removed deprecated ARN
	TF_VAR_aws_account="production"
	;;
stg)
	# Removed deprecated ARN
	TF_VAR_aws_account="staging"
	;;
*)
	echo "Unknown assumed environment '$ASSUME_ENV': dev, test, stg or prod."
	exit 1
esac

ASSUME_CMD="$@"
if [ "x$ASSUME_CMD" == "x" ]
then
	echo "No command specified to run. $0 $ASSUME_ENV [command]"
	exit 1
fi

ASSUME_OUTPUT=$(aws sts assume-role --output json --role-arn ${ASSUME_ARN} --role-session-name ${ASSUME_ENV} --profile ${ASSUME_ENV})

if [ $? == 0 ]
then
	ACCESS_KEY=$(echo $ASSUME_OUTPUT | sed -n 's/.*"AccessKeyId": "\([^"]*\)".*/\1/p')
	SECRET_KEY=$(echo $ASSUME_OUTPUT | sed -n 's/.*"SecretAccessKey": "\([^"]*\)".*/\1/p')
	SESSION_TOKEN=$(echo $ASSUME_OUTPUT | sed -n 's/.*"SessionToken": "\([^"]*\)".*/\1/p')
	EXPIRATION=$(echo $ASSUME_OUTPUT | sed -n 's/.*"Expiration": "\([^"]*\)".*/\1/p')

    echo "Retrieved temp access key ${ACCESS_KEY} for role ${ASSUME_ENV}. Key will expire at ${EXPIRATION}"

    AWS_ACCESS_KEY_ID=${ACCESS_KEY} AWS_SECRET_ACCESS_KEY=${SECRET_KEY} AWS_SESSION_TOKEN=${SESSION_TOKEN} ${ASSUME_CMD}
fi
