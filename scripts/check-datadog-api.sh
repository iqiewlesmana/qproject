set -xe
if [ $# -ne 2 ]; then
	echo -e "\n\nUsage: [name].sh [SSH_USERNAME] [ENV]\n\n"
	exit
fi

USERNAME=$1
ENV=$2
RESULT_FILE="/tmp/result"
SSH_CONFIG='/home/iqiewlesmana/Workspace/qproject/ssh-gcp.cfg'
PROJECTS=`gcloud projects list |grep $ENV | awk '{ print $1}'`

rm $RESULT_FILE
touch $RESULT_FILE

for PROJECT in $PROJECTS   #  <-- Note: Added "" quotes.
do
  echo "$PROJECT"
  echo "----------"
  echo "" >> $RESULT_FILE
  echo "$PROJECT" >> $RESULT_FILE
  echo "----------" >> $RESULT_FILE

  export GCE_PROJECT=$PROJECT
  export CLOUDSDK_CORE_PROJECT=$GCE_PROJECT

  #HOSTNAMES=`gcloud compute instances list --project=$PROJECT | awk '{ if(NR > 1) print $1 }'`
  HOSTNAMES=`gcloud --format="value(networkInterfaces[0].networkIP)" compute instances list`
  for HOSTNAME in $HOSTNAMES
  do
    echo $HOSTNAME>> $RESULT_FILE
    ssh -n -o ConnectTimeout=5 -F $SSH_CONFIG "$USERNAME@$HOSTNAME" 'echo -n "`hostname` "; cat /etc/datadog-agent/datadog.yaml | grep api_key' | awk '{print " v6 : " $3}'>> "$RESULT_FILE"
    ssh -n -o ConnectTimeout=5 -F $SSH_CONFIG "$USERNAME@$HOSTNAME" 'echo -n "`hostname` "; cat /etc/datadog-agent/datadog.yaml | grep api_key' | awk '{print $1 ": " $3}'>> "$RESULT_FILE"
    #echo "echo $HOSTNAMES | sed 's/\//\n/g'"
  # echo "${array[3]}"
  echo "."
  done
  echo ""
done
