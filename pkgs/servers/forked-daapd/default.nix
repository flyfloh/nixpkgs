{ stdenv,
  fetchFromGitHub,
  avahi,
  antlr3,
  autoconf,
  autoreconfHook,
  curl,
  ffmpeg,
  gawk,
  gettext,
  gnutls,
  gperf,
  json_c,
  minixml,
  openssl,
  libantlr3c,
  libconfuse,
  libevent,
  libgcrypt,
  libgpgerror,
  libplist,
  libsodium,
  libspotify,
  libunistring,
  libuv,
  libwebsockets,
  pkg-config,
  protobufc,
  pulseaudio,
  sqlite,
  zlib
}:

let
  version = "27.1";
  name = "forked-daapd";
in stdenv.mkDerivation {
  inherit name;

  src = fetchFromGitHub {
    repo = name;
    owner = "ejurgensen";
    rev = version;
    sha256 = "1sz30ba5p7cmfpgdcyxkcwavd4rh5lygmi66jqjxn0qjd9c6pdqp";
  };

  nativeBuildInputs = [ antlr3
                        autoconf
                        autoreconfHook
                        ffmpeg
                        gawk
                        gettext
                        gnutls
                        gperf
                        json_c
                        libantlr3c
                        libconfuse
                        libevent
                        libgcrypt
                        libgpgerror
                        libplist
                        libsodium
                        libunistring
                        libuv
                        libwebsockets
                        minixml
                        openssl
                        pkg-config
                        protobufc
                        pulseaudio
                        sqlite
                        zlib ];

  buildInputs = [ avahi curl libspotify ];

  configureFlags = [ "--enable-chromecast"
                     "--enable-lastfm"
                     "--enable-spotify"
                     "--with-pulseaudio"
                   ];

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    homepage = http://ejurgensen.github.io/forked-daapd;
    description = "Linux/FreeBSD DAAP (iTunes) and MPD media server with support for AirPlay devices (multiroom), Apple Remote (and compatibles), Chromecast, Spotify and internet radio.";
    license = licenses.gpl2;
    maintainers = with maintainers; [ flyfloh ];
  };
}
