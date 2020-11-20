{ lib, fetchPypi, buildPythonPackage, pythonOlder, setuptools_scm
, filelock, requests, requests-file, idna, pytest
, responses
}:

buildPythonPackage rec {
  pname   = "tldextract";
  version = "3.0.2";

  disabled = pythonOlder "3.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "f188eab8c90ff935f3fa49d9228049cd7f37fb47105c3f15f8e6dd6f6e25924a";
  };

  propagatedBuildInputs = [ filelock requests requests-file idna ];
  checkInputs = [ pytest responses ];
  nativeBuildInputs = [ setuptools_scm ];

  meta = {
    homepage = "https://github.com/john-kurkowski/tldextract";
    description = "Accurately separate the TLD from the registered domain and subdomains of a URL, using the Public Suffix List.";
    license = lib.licenses.bsd3;
  };

}
