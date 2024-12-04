#!/usr/bin/env bash

_script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
_root_dir=$( cd -- "${_script_dir}/.." &> /dev/null && pwd )
_build_dir=${_root_dir}/build
_deploy_dir=${_root_dir}/deploy
_test_report_dir=${_root_dir}/.reports
_compose_dir=${_deploy_dir}/docker-compose
_service_dir=${_root_dir}/service
_ui_dir=${_root_dir}/ui
_ui_framework=react

# used for remove-all, could be used to validate framework naming
_all_frameworks="react angular"

_show_usage() {
  echo "deploy.sh [--remove] [--framework <react|angular>]"
  echo "   deploy the service"
  echo
  echo "   --remove:    remove the (deployed) service"
  echo "   --framework: specify the ui framework to use, default=${_ui_framework}"
  echo "   --dry-run:   check what will happen but don't run anything"
}

_show_info() {
  echo "Script   : ${_script_dir}"
  echo "Root     : ${_root_dir}"
  echo "Service  : ${_service_dir}"
  echo "UI       : ${_ui_dir}/${_ui_framework}"
  echo
  [ -n "${_remove}" ] && echo "remove service" || echo "deploy service"
  echo
}

deploy_service() {
  echo "deploy service (${_ui_framework})"

  kubectl cluster-info
  #kubectl create deployment webkins-svc --image=webkins
  kubectl apply -f ${_deploy_dir}/k8s/webkins-${_ui_framework}.yaml

  local _kube_port=$(kubectl describe svc nginx-ingress --namespace=nginx-ingress | grep NodePort | grep "http " | cut -w -f 3 | cut -d '/' -f 1)
  echo "Open the website using this url:"
  echo "  http://localhost:${_kube_port}"
}

remove_service() {
  echo "remove service (${_ui_framework})"
  if [ "${_ui_framework}" == "all" ]; then
    for f in ${_all_frameworks}; do
      echo "  -> $f"
      kubectl delete -f ${_deploy_dir}/k8s/webkins-${f}.yaml
    done
  else
    kubectl delete -f ${_deploy_dir}/k8s/webkins-${_ui_framework}.yaml
  fi
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
    -f|--framework|--ui-framework)
      _ui_framework=$1
      shift
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
