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
  echo "deploy.sh [service|ui|all]"
  echo "   deploy the service, the ui, or both"
  echo "   for 'service' builds, add [container] to build in a container"
  echo "   for 'ui' builds, add [update] to update the ui container"
  echo
  echo "use --dry-run to check what will happen"
}

_show_info() {
  echo "Script   : ${_script_dir}"
  echo "Root     : ${_root_dir}"
  echo "Service  : ${_service_dir}"
  echo "UI       : ${_ui_dir}"
  echo
  [ -n "${_service}" ] && echo "deploy service"
  [ -n "${_ui}" ] && echo "deploy UI"
  echo
}

deploy_service() {
  echo "deploy service"

  kubectl service-info
}

deploy_ui() {
  echo "deploy UI"

  kubectl service-info
}

_service=
_ui=

while [ $# -gt 0 ]; do
  _op=$1
  shift

  case ${_op} in
    -h|--help)
      _show_usage
      exit 1
      ;;
    service)
      _service=true
      ;;
    ui)
      _ui=true
      ;;
    all)
      _service=true
      _ui=true
      ;;
    --dry-run)
      _show_info
      exit 0
      ;;
    *)
      echo "ERROR: unexpected parameter '$1'"
      _show_usage
      exit 1
      ;;
  esac
done

[ -n "${_service}" ] && deploy_service
[ -n "${_ui}" ] && deploy_ui

exit 0
