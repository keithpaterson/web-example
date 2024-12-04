using colors
using build
using common_cfg

run_test_usage() {
  echo "  where $(color -bold op) is:"
  echo
  echo "  $(color -lt_green \<empty\>): run unit tests"
  echo "  $(color -lt_green coverage): run unit tests and generate a coverage report"
  echo
  echo " coverage reports are found in ${_test_report_dir}"
}

run_test() {
  _op=$1
  shift

  case ${_op} in
    -h|--help)
      run_handler_usage test
      exit 1
      ;;
    ""|unit)
      _unit_tests $*
      ;;
    coverage)
      _generate_coverage $*
      ;;
    *)
      error "unexpected op $(color -bold '$1')"
      exit 1
      ;;
  esac
}

_unit_tests() {
  _run build service

  echo "Running unit tests..."
  mkdir -p ${_test_report_dir}
  _test_check_and_install_ginkgo
  ginkgo --tags testutils --repeat 1 -r --output-dir ${_test_report_dir} --json-report unit_tests.json $* ./... > ${_test_report_dir}/unit_tests.log 2>&1
  local _result=$?
  cat ${_test_report_dir}/unit_tests.log
  if [ ${_result} -ne 0 ]; then
      exit ${_result}
  fi
}

_generate_coverage() {
  _run build service

  echo "generating test coverage..."
  mkdir -p ${_test_report_dir}
  rm -f ${_test_report_dir}/coverage.raw.out ${_test_report_dir}/coverage.out
  go test --tags testutils --test.coverprofile ${_test_report_dir}/coverage.raw.out $* ./... | grep -v mocks 
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

