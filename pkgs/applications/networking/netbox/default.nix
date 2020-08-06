{ lib
, fetchFromGitHub
, python3
, python3Packages
}:

python3Packages.buildPythonApplication rec {
  pname = "netbox";
  version = "2.8.8";

  propagatedBuildInputs = with python3Packages; [ django
  #django-cacheops
django-cors-headers
#django-debug-toolbar
django-filter
#django-mptt
django-pglocks
#django-prometheus
#django-rq
#django-tables2
django_taggit
#django_taggit-serializer
#django-timezone-field
djangorestframework
#drf-yasg[validation]
gunicorn
jinja2
markdown
netaddr
pillow
#psycopg2-binary
pycryptodome
pyyaml
redis
svgwrite
];
  #checkInputs = with python3Packages; [ ];

  src = fetchFromGitHub {
    owner = "netbox-community";
    repo = pname;
    rev = "v${version}";
    sha256 = "099wyr1xp69q87n5j2as4aaf146b0jqij3vv4bpq9m5278gk9wp0";
  };

  # buildPhase = ''
  #   ${python3.interpreter} netbox/manage.py createsuperuser
  #   ${python3.interpreter} netbox/manage.py collectstatic --no-input
  # '';

  dontBuild = true;
  dontInstall = true;
  #doCheck = false;


  checkPhase = ''
    python netbox/manage.py test netbox/
  '';

  meta = with lib; {
    description = "IP address management (IPAM) and data center infrastructure management (DCIM) tool. ";
    homepage = "http://netbox.readthedocs.io/en/stable/";
    maintainers = with maintainers; [ flyfloh ];
    #license = licenses.apache2;
  };

}
