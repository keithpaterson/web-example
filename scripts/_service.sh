using colors
using common_cfg

_deploy_dir=${_root_dir}/deploy
_compose_dir=${_deploy_dir}/docker-compose

run_service_usage() {
  echo "  where $(color -bold op) is:"
  echo
  echo "  $(color -lt_green up): start the service container"
  echo "  $(color -lt_green down): stop the service container"
}

run_service() {
  local _cmd=

  while [ $# -gt 0 ]; do
    _op=$1
    shift

    case ${_op} in
      -h|--help)
        run_handler_usage service
        exit 1
        ;;
      up|start)
        _cmd="up -d"
        ;;
      down|stop)
        _cmd=down
        ;;
      *)
        _parse_common_args ${_op} $*
        local _consumed=$?
        if [ ${_consumed} -lt 0 ]; then
          error "unexpected op $(color -bold '$1')"
          exit 1
        fi
        shift ${_consumed}
        ;;
    esac
  done

  _exec_service ${_cmd}
}

_exec_service() {
  local _op=$1
  shift

  # double-check
  [ -n "${_op}" ] || return 1
  docker-compose -f ${_compose_dir}/service-${_ui_framework}.yaml ${_op} $*
}

