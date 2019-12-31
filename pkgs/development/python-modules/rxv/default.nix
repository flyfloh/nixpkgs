{ lib
, buildPythonPackage
, fetchPypi
, defusedxml
, requests
}:

buildPythonPackage rec {
  pname = "rxv";
  version = "0.6.0";

  propagatedBuildInputs = [ defusedxml requests ];

  doCheck = false;

  src = fetchPypi {
    inherit pname version;
    sha256 = "aa1d707fb4f6d71581aca9a864fb03e62f001b32c835b72ddba5cfdb5c3a661f";
  };

  meta = with lib; {
    description = "Automation Library for Yamaha RX-V473, RX-V573, RX-V673, RX-V773 receivers";
    homepage = https://github.com/wuub/rxv;
    license = licenses.mit;
  };
}

