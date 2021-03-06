#!/bin/bash -ex
#
# Build AWS Lambda function ZIP file and upload to S3
# you need pip installed, and python, and awscli
#
# Usage: ./push-to-lambda S3BUCKET S3KEY
#
s3bucket=${1:?Specify target S3 bucket name}
s3key=${2:?Specify target S3 key}
target=s3://$s3bucket/$s3key

if ! type aws > /dev/null; then
	pip install awscli
fi

tmpdir=$(mktemp -d /tmp/lambda-XXXXXX)
zipfile=$tmpdir/lambda.zip

(cd $tmpdir; npm install aws-sdk; zip -r9 $zipfile node_modules)

# AWS Lambda function (with the right name)
rsync -va artifact_deploy_function.py $tmpdir/index.py
(cd $tmpdir; zip -r9 $zipfile index.py)

aws lambda update-function-code --region us-west-2 --function-name artifact_deploy_function --file file://$zipfile
# Clean up
rm -rf $tmpdir
