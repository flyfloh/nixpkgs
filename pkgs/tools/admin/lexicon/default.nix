{ lib
, python3Packages
, fetchFromGitHub
}:

with python3Packages;

buildPythonApplication rec {
  pname = "lexicon";
  version = "3.5.1";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "AnalogJ";
    repo = pname;
    rev = "v${version}";
    sha256 = "1if2aj727jc0bx1rib3fsaqa31pqlc2xc0v3nl9862al61p0svd5";
  };

  nativeBuildInputs = [
    poetry
  ];

  propagatedBuildInputs = [
    appdirs
    attrs
    beautifulsoup4
    boto3
    botocore
    cached-property
    certifi
    cffi
    chardet
    click
    cryptography
    defusedxml
    dnspython
    filelock
    future
    idna
    isodate
    jmespath
    localzone
    lxml
    #prompt-toolkit
    ptable
    pycparser
    pygments
    pynamecheap
    python-dateutil
    pytz
    pyyaml
    requests
    requests-file
    requests-toolbelt
    s3transfer
    six
    softlayer
    soupsieve
    suds-jurko
    tldextract
    transip
    urllib3
    wcwidth
    xmltodict
    zeep
  ];

  checkInputs = [
    mock
    pytest
    pytestcov
    pytest_xdist
    vcrpy
  ];

  checkPhase = ''
    pytest --ignore=lexicon/tests/providers/test_auto.py
  '';

  meta = with lib; {
    description = "Manipulate DNS records on various DNS providers in a standardized way";
    homepage = "https://github.com/AnalogJ/lexicon";
    maintainers = with maintainers; [ flyfloh ];
    license = licenses.mit;
  };
}
