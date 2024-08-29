#!/usr/bin/env bash

_script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
_root_dir=$( cd -- "${_script_dir}/../.." &> /dev/null && pwd )
_build_dir=${_root_dir}/build
_deploy_dir=${_root_dir}/deploy
_test_report_dir=${_root_dir}/.reports
_compose_dir=${_deploy_dir}/docker-compose
_service_dir=${_root_dir}/service
_ui_dir=${_root_dir}/ui
_bin_dir=${_root_dir}/bin

_os="darwin linux"
_darwin_arch="amd64"
_linux_arch="amd64"

_show_usage() {
  echo "build.sh [service|ui|all]"
  echo "   build the site, the ui, or both"
  echo "   for 'service' builds, add [-d] to build in a container"
  echo "   for 'ui' builds, add [-u] to update the ui container"
  echo
  echo "build.sh clean"
  echo "   clean the bin folder"
  echo
  echo "build.sh up|down"
  echo "   start/stop the service"
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
  [ -n "${_service_op}" ] && echo "service operation: ${_service_op}"
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
  docker image build -t ui-update -f ${_build_dir}/docker/ui.Dockerfile ${_root_dir}

  for _o in ${_os}; do
    _arch=_${_o}_arch
    for _a in ${!_arch}; do
      docker run --rm -v "${_bin_dir}/${_o}/${_a}/html":"/webkins_ui/mnt" ui-update
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

run_unit_tests() {
  [ -n "${_coverage}" ] && _generate_coverage || _unit_tests
}

_unit_tests() {
  echo "Running unit tests..."
  mkdir -p ${_test_report_dir}
  _test_check_and_install_ginkgo
  ginkgo --tags testutils --repeat 1 -r --output-dir ${_test_report_dir} --json-report unit_tests.json ./... > ${_test_report_dir}/unit_tests.log 2>&1
  local _result=$?
  cat ${_test_report_dir}/unit_tests.log
  if [ ${_result} -ne 0 ]; then
      exit ${_result}
  fi
}

_generate_coverage() {
  echo "generating test coverage..."
  mkdir -p ${_test_report_dir}
  rm -f ${_test_report_dir}/coverage.raw.out ${_test_report_dir}/coverage.out
  go test --tags testutils --test.coverprofile ${_test_report_dir}/coverage.raw.out ./... | grep -v mocks 
  local _result=$?

  # filter out mocks directories from coverage
  grep -vE 'mocks/|utility/test/' ${_test_report_dir}/coverage.raw.out > ${_test_report_dir}/coverage.out
  go tool cover -html=${_test_report_dir}/coverage.out -o ${_test_report_dir}/coverage.html
  if [ ${_result} -ne 0 ]; then
      exit ${_result}
  fi
}

_test_check_and_install_ginkgo() {
  if ! command -v ginkgo &> /dev/null; then
    echo install ginkgo
    go install github.com/onsi/ginkgo/v2/ginkgo
  fi
}

exec_service() {
  # double-check
  [ -n "${_service_op}" ] || return 1
  docker-compose -f ${_compose_dir}/service.yaml ${_service_op} $*
}

_service=
_service_container=
_ui=
_ui_update=
_unit_test=
_coverage=

_service_op=
_service_args=

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
    test*|unit-test*)
      _unit_test=true
      ;;
    coverage)
      _unit_test=true
      _coverage=true
      ;;
    all)
      _service=true
      _ui=true
      ;;
    up|start)
      _service_op=up
      _service_args="-d"
      ;;
    down|stop)
      _service_op=down
      ;;
    -u|update-ui)
      _ui_update=true
      ;;
    -d|--docker)
      _service_container=true
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
[ -n "${_unit_test}" ] && run_unit_tests

[ -n "${_service_op}" ] && exec_service ${_service_args}

exit 0
