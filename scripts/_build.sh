using colors
using common_cfg

_build_config=

_os="darwin linux"
_darwin_arch="amd64"
_linux_arch="amd64"

_service=
_service_container=
_ui=
_ui_update=

run_build_usage() {
  echo "  where $(color -bold op) is:"
  echo
  echo "  $(color -lt_green clean): clean the bin folder"
  echo
  echo "  $(color -lt_green service) $(color -lt_yellow \[container\])"
  echo "    $(color -lt_yellow \<empty\>)   : build locallly"
  echo "    $(color -lt_yellow container) : build in a container"
  echo
  echo "  $(color -lt_green ui) $(color -lt_yellow \[params...\]): build the UI"
  echo "    $(color -lt_yellow -f \<react\|angular\>): specify the UI framework. $(color -lt_blue default: ${_ui_framework})" 
  echo
  echo "  $(color -lt_green all) $(color -lt_yellow \[params...\]): build both the service and the UI"
  echo
  echo "  use --dry-run to check what will happen"
}

run_build() {
  while [ $# -gt 0 ]; do
    _op=$1
    shift

    case ${_op} in
      -h|--help)
        _show_usage
        exit 1
        ;;
      clean)
        build_clean
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
      -u|update)
        _ui_update=true
        ;;
      -d|--docker|container)
        _service_container=true
        ;;
      -f|--framework|--ui-framework)
        _ui_framework=$1
        shift
        ;;
      -c|--config|--configuration)
        _build_config=$1
       shift
        ;;
      --dry-run)
        _show_info
        exit 0
        ;;
      --)
        break
        ;;
      *)
        echo "ERROR: unexpected parameter '$1'"
        exit 1
        ;;
    esac
  done

  [ -n "${_service}" ] && build_service $*
  [ -n "${_ui}" ] && build_ui
}

_show_info() {
  echo "$(color -bold Script)   : ${_script_dir}"
  echo "$(color -bold Root)     : ${_root_dir}"
  echo "$(color -bold Service)  : ${_service_dir}"
  echo "$(color -bold UI)       : ${_ui_dir}/${_ui_framework}"
  echo "$(color -bold Bin)      : ${_bin_dir}"
  for _o in ${_os}; do
    _arch=_${_o}_arch
    for _a in ${!_arch}; do
      echo "           -> ${_bin_dir}/${_o}/${_a}/"
    done
  done
  echo
  [ -n "${_service}" ] && echo "build service"
  [ -n "${_service_container}" ] && echo "      in a docker container"
  [ -n "${_ui}" ] && echo "build UI"
  echo
  echo "build arguments:"
  [ -n "${_ui_framework}" ] && echo "    fw: ${_ui_framework}"
  [ -n "${_build_config}" ] && echo "   cfg: ${_build_config}"
}

_make_bin_folders() {
  for _o in ${_os}; do
    _arch=_${_o}_arch
    for _a in ${!_arch}; do
      mkdir -p ${_bin_dir}/${_o}/${_a}/$1
    done
  done
}

build_clean() {
  rm -rf ${_bin_dir}/*
}

build_service() {
  if [ -n "${_service_container}" ]; then
    build_service_container
    return
  fi

  _make_bin_folders

  # no version for now
  cd ${_service_dir}
  for _o in ${_os}; do
    _arch=_${_o}_arch
    for _a in ${!_arch}; do
      echo "build service (${_o}/${_a})"
      GOOS=${_o} GOARCH=${_a} go build -o ${_bin_dir}/${_o}/${_a}/service $* ./entry/service/main.go
    done
  done
}

build_service_container() {
  echo "build service (${_ui_framework}) in a container"

  local _access="--ssh default"

  docker-compose -f ${_compose_dir}/service-${_ui_framework}.yaml build --no-cache ${_access}
}

build_ui() {
  _make_bin_folders html

  case ${_ui_framework} in
    vite|react|angular)
      _build_${_ui_framework}_ui
      return
      ;;
  esac

  echo "ERROR: unrecognized UI framework '${_ui_framework}'"
  exit 1
}

_build_vite_ui() {
  _build_react_ui
}

_build_react_ui() {
  cd ${_ui_dir}/react

  if ! command -v node > /dev/null 2>&1; then
    echo "ERROR: node is missing"
    return 2
  fi

  npm install --ignore-scripts
  npm run build

  if [ -n "${_ui_update}" ]; then
    _update_ui_folders
  fi
}

_build_angular_ui() {
  cd ${_ui_dir}/angular

  if ! command -v node > /dev/null 2>&1; then
    echo "ERROR: node is missing"
    return 2
  fi
  if ! command -v ng > /dev/null 2>&1; then
    echo "ERROR: angular is missing"
    return 2
  fi

  local _config=
  [ -n "${_build_config}" ] && _config="--configuration ${_build_config}"

  npm install --ignore-scripts
  ng build ${_config}

  if [ -n "${_ui_update}" ]; then
    #_update_ui_folders
    echo "ERROR: ui update not supported for angular"
    return 1
  fi
}

