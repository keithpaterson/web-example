#!/usr/bin/env bash

_script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
_root_dir=$( cd -- "${_script_dir}/.." &> /dev/null && pwd )
_build_dir=${_root_dir}/build
_deploy_dir=${_root_dir}/deploy
_test_report_dir=${_root_dir}/.reports
_compose_dir=${_deploy_dir}/docker-compose
_service_dir=${_root_dir}/service
_ui_dir=${_root_dir}/ui

_show_usage() {
  echo "deploy.sh [--remove]"
  echo "   deploy the service"
  echo
  echo "   --remove:  remove the (deployed) service"
  echo "   --dry-run: check what will happen but don't run anything"
}

_show_info() {
  echo "Script   : ${_script_dir}"
  echo "Root     : ${_root_dir}"
  echo "Service  : ${_service_dir}"
  echo "UI       : ${_ui_dir}"
  echo
  [ -n "${_remove}" ] && echo "remove service" || echo "deploy service"
  echo
}

deploy_service() {
  echo "deploy service"

  kubectl cluster-info
  #kubectl create deployment webkins-svc --image=webkins
  kubectl apply -f ${_deploy_dir}/k8s/webkins.yaml
}

remove_service() {
  echo "remove service"
  kubectl delete -f ${_deploy_dir}/k8s/webkins.yaml
}

_remove=

while [ $# -gt 0 ]; do
  _op=$1
  shift

  case ${_op} in
    -h|--help)
      _show_usage
      exit 1
      ;;
    -r|--delete|--remove)
      _remove=true
      ;;
    --dry-run)
      _show_info
      exit 0
      ;;
    *)
      echo "ERROR: unexpected parameter '$_op'"
      _show_usage
      exit 1
      ;;
  esac
done

if [ -n "${_remove}" ]; then
  remove_service
else
  deploy_service
fi

echo
echo Finished

exit 0
