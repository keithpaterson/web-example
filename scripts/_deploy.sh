using colors
using common_cfg

run_deploy_usage() {
  echo "  where $(color -bold op) is:"
  echo
  echo "  $(color -lt_green --remove):    remove the (deployed) service"
  echo "  $(color -lt_green --framework): specify the ui framework to use, default=${_ui_framework}"
  echo "  $(color -lt_green --dry-run):   check what will happen but don't run anything"
}

run_deploy() {
  local _remove=

  while [ $# -gt 0 ]; do
    _op=$1
    shift

    case ${_op} in
      -h|--help)
        run_handler_usage deploy
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
        _parse_common_args ${_op} $*
        local _consumed=$?
        if [ ${_consumed} -lt 0 ]; then
          urror "unexpected parameter $(color -bold '${_op}')"
          exit 1
        fi
        shift ${_consumed}
        ;;
    esac
  done

  if [ -n "${_remove}" ]; then
    remove_service
  else
    deploy_service
  fi
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
  local _all_frameworks="react angular"

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

