#!/bin/bash
while [ -n "$1" ]; do
  case "$1" in
  -a)
    JENKINS_NAME="$2"
    echo "Jenkins slave node name: $JENKINS_NAME"
    shift
    ;;
  -d)
    DELETE_PROJECT="true"
    ;;
  -n)
    JENKINS_NAMESPACE="$2"
    echo "Jenkins namespace in openshift: $JENKINS_NAMESPACE"
    shift
    ;;
  -p)
    JENKINS_SECRET="$2"
    echo "Found the -p option, with Jenkins secret"
    shift
    ;;
  -u)
    JENKINS_URL="$2"
    echo "jenkins Master URL $JENKINS_URL"
    shift
    ;;
  -y)
    FORCE="true"
    ;;
  -h) echo "-a Jenkins slave node name
-d Delete configs before creating
-h This Help
-n Jenkins namespace in openshift
-p Jenkins secret
-u Jenkins Master URL
-y Force apply
" ;;
  --)
    shift
    break
    ;;
  *)
    list="$list"" $1"
    ;;
  esac
  shift
done
if [ -n "$list" ]; then
  echo "$list is not commands or keys"
fi
if ! oc whoami 2>/dev/null; then
  echo "User not login"
  exit
fi

if [ -n "$DELETE_PROJECT" ]; then
  echo "Delete configs before creating"
  oc process -f jenkins-sl.yaml \
    -p JENKINS_NAMESPACE=$JENKINS_NAMESPACE \
    -p JENKINS_NAME=$JENKINS_NAME \
    -p JENKINS_SECRET=$JENKINS_SECRET \
    -p JENKINS_URL=$JENKINS_URL | oc delete -f - -n $JENKINS_NAMESPACE
fi
#######################################################
if [ -z "$JENKINS_NAMESPACE" ]; then
  JENKINS_NAMESPACE="ci"
fi
########################################################

check_project="$(oc get project $JENKINS_NAMESPACE 2>/dev/null | grep Active)"
if [ -z "$check_project" ]; then
  oc new-project $JENKINS_NAMESPACE
  JenkinsApply="yes"
else
  if [ "$FORCE" = "true" ]; then
    JenkinsApply="yes"
  else
    echo -n "Project " $JENKINS_NAMESPACE " exists. Continue? y-yes/n-no "
    read confirm
    if [ "$confirm" != "y" ]; then
      echo "Input <script name> <app-name> <jenkins-name>"
      JenkinsApply="no"
    else
      JenkinsApply="yes"
    fi
  fi
fi
###################################################################
if [ $JenkinsApply == "yes" ]; then
  check_scc="$(oc get scc 2>/dev/null | grep uid1000)"
  if [ -z "$check_scc" ]; then
    oc process -f scc-uid1000.yaml -p JENKINS_NAMESPACE=$JENKINS_NAMESPACE | oc apply -f - -n $JENKINS_NAMESPACE
  else
    oc adm policy add-scc-to-user uid1000 system:serviceaccount:$JENKINS_NAMESPACE:jenkins
  fi

  check_role="$(oc get clusterrole 2>/dev/null | grep jenkins-deployer)"
  if [ -z "$check_role" ]; then
    oc create -f clusterrole-jenkins-deployer.yaml
  else
    oc adm policy add-cluster-role-to-user jenkins-deployer system:serviceaccount:$JENKINS_NAMESPACE:jenkins
  fi

  oc process -f jenkins-sl.yaml \
    -p JENKINS_NAMESPACE=$JENKINS_NAMESPACE \
    -p JENKINS_NAME=$JENKINS_NAME \
    -p JENKINS_SECRET=$JENKINS_SECRET \
    -p JENKINS_URL=$JENKINS_URL | oc apply -f - -n $JENKINS_NAMESPACE
fi

# PROJECTS=($list)
# for APP_NAME in ${PROJECTS[*]}; do
#   echo "Starting role for $APP_NAME"
#   oc process -f jenkins-deploy-policy.yaml -p JENKINS_NAMESPACE=$JENKINS_NAMESPACE -p APP_NAME=$APP_NAME | oc apply -f - -n $APP_NAME
# done
