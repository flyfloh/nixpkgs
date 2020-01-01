{ stdenv
, buildPythonPackage
, fetchPypi
, aiohttp
, async-timeout
, pytz
, xmltodict
}:

buildPythonPackage rec {
  pname = "PyMetno";
  version = "0.5.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "e532544495200210407e3d68f719c271435da6f3bfe696e708b1d5d603a21948";
  };

  doCheck = false;
  propagatedBuildInputs = [ aiohttp async-timeout pytz xmltodict ];

  #checkInputs = [ pytest pytestrunner netifaces asynctest virtualenv toml filelock ];

  meta = with stdenv.lib; {
    description = "A library to communicate with the met.no api";
    homepage = https://github.com/Danielhiversen/pyMetno/;
    license = licenses.mit;
    maintainers = with maintainers; [ elseym ];
  };
}

