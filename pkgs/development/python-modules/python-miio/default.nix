{ stdenv
, buildPythonPackage
, fetchPypi
, appdirs
, click
, construct
, cryptography
, zeroconf
, attrs
, pytz
, tqdm
, netifaces
}:

buildPythonPackage rec {
  pname = "python-miio";
  version = "0.4.8";

  src = fetchPypi {
    inherit pname version;
    sha256 = "19423b3386b23d2e0fc94a8f6a358bcfbb44eed05376e33fd434d26d168bd18c";
  };

  doCheck = false;
  propagatedBuildInputs = [ appdirs click construct cryptography zeroconf attrs pytz tqdm netifaces ];

  #checkInputs = [ pytest pytestrunner netifaces asynctest virtualenv toml filelock ];

  meta = with stdenv.lib; {
    description = "Python library for interfacing with Xiaomi smart appliances";
    homepage = https://github.com/rytilahti/python-miio;
    license = licenses.gpl3;
    maintainers = with maintainers; [ elseym ];
  };
}

