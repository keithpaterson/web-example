# utility/config stuff that all handler scripts are likely to need
#

_build_dir=${_root_dir}/build
_deploy_dir=${_root_dir}/deploy
_compose_dir=${_deploy_dir}/docker-compose
_service_dir=${_root_dir}/service
_test_report_dir=${_root_dir}/.reports
_ui_dir=${_root_dir}/ui
_ui_framework=angular
_bin_dir=${_root_dir}/bin


_parse_common_args() {
    local _op=$1
    shift

    consumed=0

    case ${_op} in 
      -f|--framework|--ui-framework)
        _ui_framework=$1
        consumed=1
        shift
        ;;
      *)
        consumed=-1
        break
        ;;
    esac
    return $consumed
}

