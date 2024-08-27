#!/usr/bin/env bash

_script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
_root_dir=$( cd -- "${_script_dir}/../.." &> /dev/null && pwd )
_build_dir=${_root_dir}/build
_deploy_dir=${_root_dir}/deploy
_compose_dir=${_deploy_dir}/docker-compose
_service_dir=${_root_dir}/service
_ui_dir=${_root_dir}/ui
_bin_dir=${_root_dir}/bin

_os="darwin linux"
_darwin_arch="amd64"
_linux_arch="amd64"

_show_usage() {
  echo "build [service|ui|all]"
  echo "   build the site, the ui, or both"
  echo "   for 'service' builds, add [-d] to build in a container"
  echo "   for 'ui' builds, add [-u] to update the ui container"
  echo
  echo "build clean"
  echo "   clean the bin folder"
  echo
  echo "use --dry-run to check what will happen"
}

_show_info() {
  echo "Script   : ${_script_dir}"
  echo "Root     : ${_root_dir}"
  echo "Service  : ${_service_dir}"
  echo "UI       : ${_ui_dir}"
  echo "Bin      : ${_bin_dir}"
  for _o in ${_os}; do
    _arch=_${_o}_arch
    for _a in ${!_arch}; do
      echo "           -> ${_bin_dir}/${_o}/${_a}/"
    done
  done
  echo
  [ -n "${_service}" ] && echo "build service"
  [ -n "${_ui}" ] && echo "build UI"
  [ -n "${_ui_update}" ] && echo "      and update the docker container"
  echo
}

_make_bin_folders() {
  for _o in ${_os}; do
    _arch=_${_o}_arch
    for _a in ${!_arch}; do
      mkdir -p ${_bin_dir}/${_o}/${_a}/$1
    done
  done
}

_update_ui_folders() {
  docker image build -t site -f ${_build_dir}/docker/ui.Dockerfile ${_root_dir}

  for _o in ${_os}; do
    _arch=_${_o}_arch
    for _a in ${!_arch}; do
      docker run --rm -v "${_bin_dir}/${_o}/${_a}/html":"/webkins_ui/mnt" ui
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
      GOOS=${_o} GOARCH=${_a} go build -o ${_bin_dir}/${_o}/${_a}/service ./entry/service/main.go
    done
  done
}

build_service_container() {
  local _access="--ssh default"

  docker-compose -f ${_compose_dir}/service.yaml build --no-cache ${_access}
}

build_ui() {
  _make_bin_folders html

  cd ${_ui_dir}
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

_service=
_service_container=
_ui=
_ui_update=

while [ $# -gt 0 ]; do
  case $1 in
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
      shift
      ;;
    ui)
      _ui=true
      shift
      ;;
    all)
      _service=true
      _ui=true
      shift
      ;;
    -u|update-ui)
      _ui_update=true
      shift
      ;;
    -d|--docker)
      _service_container=true
      shift
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

[ -n "${_service}" ] && build_service
[ -n "${_ui}" ] && build_ui

exit 0
