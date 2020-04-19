{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.forked-daapd;

  boolToString = b: if b then "true" else "false";
  boolToYes = b: if b then "yes" else "no";
  listToStrings = l: builtins.concatStringsSep " " (map (x: "\"${toString x}\",") l);

  configFile = pkgs.writeText "forked-daapd.conf" ''
    general {
      uid = "${ cfg.user }"
      db_path = "${ cfg.home }/songs3.db"
      cache_path = "${ cfg.home }/cache.db"
      logfile = "${ cfg.home }/forked-daapd.log"
      loglevel = "${cfg.loglevel}"
      websocket_port = ${builtins.toString cfg.websocketPort}
      ipv6 = ${boolToYes cfg.ipv6}
      admin_password = "${cfg.adminPassword}"
      trusted_networks = { ${ listToStrings cfg.trustedNetworks } }
      cache_daap_threshold = ${builtins.toString cfg.cacheDaapThreshold }
      speaker_autoselect = ${ boolToYes cfg.speakerAutoselect }
      high_resolution_clock = ${ boolToYes cfg.highResolutionClock }
    }

    library {
      name = "${ cfg.library.name }"
      port = ${builtins.toString cfg.library.port}
      directories = { ${ listToStrings cfg.library.directories } }
      follow_symlinks = ${ boolToString cfg.library.followSymlinks }
      podcasts = { ${ listToStrings cfg.library.podcasts } }
      audiobooks = { ${ listToStrings cfg.library.audiobooks } }
      compilations = { ${ listToStrings cfg.library.compilations } }
      compilation_artist = "${ cfg.library.compilationArtist }"
      hide_singles = ${ boolToString cfg.library.hideSingles }
      radio_playlists = ${ boolToString cfg.library.radioPlaylists }
      artwork_basenames = { ${ listToStrings cfg.library.artworkBasenames } }
      artwork_individual = ${ boolToString cfg.library.artworkIndividual }
      filetypes_ignore = { ${ listToStrings cfg.library.filetypesIgnore } }
      filepath_ignore = { ${ listToStrings cfg.library.filepathIgnore } }
      filescan_disable = ${ boolToString cfg.library.filescanDisable }
      itunes_overrides = ${ boolToString cfg.library.itunesOverrides }
      itunes_smartpl = ${ boolToString cfg.library.itunesSmartpl }
      no_decode = { ${ listToStrings cfg.library.noDecode } }
      force_decode = { ${ listToStrings cfg.library.forceDecode } }
      pipe_autostart = ${ boolToString cfg.library.pipeAutostart }
      rating_updates = ${ boolToString cfg.library.ratingUpdates }
      allow_modifying_stored_playlists = ${ boolToString cfg.library.allowModifyingStoredPlaylists }
      default_playlist_directory = "${ cfg.library.defaultPlaylistDirectory }"
    }

    audio {
      nickname = "${ cfg.audio.nickname }"
      type = "${ cfg.audio.type }"
      server = "${ cfg.audio.server }"
      card = "${ cfg.audio.card }"
      mixer = "${ cfg.audio.mixer }"
      mixer_device = "${ cfg.audio.mixerDevice }"
      sync_disable = ${ boolToString cfg.audio.syncDisable }
      offset_ms = ${ builtins.toString cfg.audio.offsetMs }
      adjust_period_seconds = ${ builtins.toString cfg.audio.adjustPeriodSeconds }
    }

    airplay_shared {
      control_port = ${ builtins.toString cfg.airplay.controlPort }
      timing_port = ${ builtins.toString cfg.airplay.timingPort }
    }

    streaming {
      sample_rate = ${ builtins.toString cfg.streaming.sampleRate }
      bit_rate = ${ builtins.toString cfg.streaming.bitRate }
    }

    ${ cfg.extraOptions }
    '';

in {
  options = {

    services.forked-daapd = {
      enable = mkEnableOption "";

      user = mkOption {
        type = types.str;
        default = "daapd";
        description = "User account under which forked-daapd runs.";
      };

      home = mkOption {
        type = types.path;
        default = "/var/lib/forked-daapd";
        description = ''
          The directory where forked-daapd will create files.
          Make sure it is writable.
        '';
      };

      virtualHost = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Name of the nginx virtualhost to use and setup. If null, do not setup any virtualhost.
        '';
      };

      adminPassword = mkOption {
        type = types.str;
        default = "";
        description = ''
          Admin password for the web interface
          Note that access to the web interface from computers in
          "trusted_network" (see below) does not require password
        '';
      };

      websocketPort = mkOption {
        type = types.int;
        default = 3688;
        description = ''
          Websocket port for the web interface.
        '';
      };

      trustedNetworks = mkOption {
        type = types.listOf types.str;
        default = [ "localhost" "192.168" "fd" ];
        description = ''
          Sets who is allowed to connect without authorisation. This applies to
          client types like Remotes, DAAP clients (iTunes) and to the web
          interface. Options are "any", "localhost" or the prefix to one or
          more ipv4/6 networks. The default is { "localhost", "192.168", "fd" }
        '';
      };

      ipv6 = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Enable/disable IPv6
        '';
      };

      cacheDaapThreshold = mkOption {
        type = types.int;
        default = 1000;
        description = ''
          DAAP requests that take longer than this threshold (in msec) get their
          replies cached for next time. Set to 0 to disable caching.
        '';
      };

      speakerAutoselect = mkOption {
        type = types.bool;
        default = true;
        description = ''
          When starting playback, autoselect speaker (if none of the previously
          selected speakers/outputs are available)
        '';
      };

      highResolutionClock = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Most modern systems have a high-resolution clock, but if you are on an
          unusual platform and experience audio drop-outs, you can try changing
          this option
        '';
      };

      library = {

        name = mkOption {
          type = types.str;
          default = "My Music on %h";
          description = ''
            Name of the library as displayed by the clients (%h: hostname). If you
            change the name after pairing with Remote you may have to re-pair.
          '';
        };

        port = mkOption {
          type = types.int;
          default = 3689;
          description = ''
            The port on which forked-daapd will listen
          '';
        };

        password = mkOption {
          type = types.str;
          default = "";
          description = ''
            Password for the library. Optional.
          '';
        };

        directories = mkOption {
          type = types.listOf types.path;
          default = [];
          description = "List of directories to index";
        };

        followSymlinks = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Follow symlinks. Default: true.
          '';
        };

        podcasts = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            Directories containing podcasts
            For each directory that is indexed the path is matched against these
            names. If there is a match all items in the directory are marked as
            podcasts. Eg. if you index /srv/music, and your podcasts are in
            /srv/music/Podcasts, you can set this to "/Podcasts".
            (changing this setting only takes effect after rescan, see the README)
          '';
        };

        audiobooks = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            Directories containing audiobooks
            For each directory that is indexed the path is matched against these
            names. If there is a match all items in the directory are marked as
            audiobooks. Eg. if you index /srv/music, and your audiobooks are in
            /srv/music/audiobooks, you can set this to "/audiobooks".
            (changing this setting only takes effect after rescan, see the README)
          '';
        };

        compilations = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            Directories containing compilations (eg soundtracks)
            For each directory that is indexed the path is matched against these
            names. If there is a match all items in the directory are marked as
            compilations. Eg. if you index /srv/music, and your compilations are in
            /srv/music/compilations, you can set this to "/compilations".
            (changing this setting only takes effect after rescan, see the README)
          '';
        };

        compilationArtist = mkOption {
          type = types.str;
          default = "Various Artists";
          description = ''
            Compilations usually have many artists, and sometimes no album artist.
            If you don't want every artist to be listed in artist views, you can
            set a single name which will be used for all compilation tracks
            without an album artist, and for all tracks in the compilation
            directories.
            (changing this setting only takes effect after rescan, see the README)
          '';
        };

        hideSingles = mkOption {
          type = types.bool;
          default = false;
          description = ''
            If your album and artist lists are cluttered, you can choose to hide
            albums and artists with only one track. The tracks will still be
            visible in other lists, e.g. songs and playlists. This setting
            currently only works in some remotes.
          '';
        };

        radioPlaylists = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Internet streams in your playlists will by default be shown in the
            "Radio" library, like iTunes does. However, some clients (like
            TunesRemote+) won't show the "Radio" library. If you would also like
            to have them shown like normal playlists, you can enable this option.
          '';
        };

        artworkBasenames = mkOption {
          type = types.listOf types.str;
          default = [ "artwork" "cover" "Folder" ];
          description = ''
            Artwork file names (without file type extension)
            forked-daapd will look for jpg and png files with these base names
          '';
        };

        artworkIndividual = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enable searching for artwork corresponding to each individual media
            file instead of only looking for album artwork. This is disabled by
            default to reduce cache size.
          '';
        };

        filetypesIgnore = mkOption {
          type = types.listOf types.str;
          default = [ ".db" ".ini" ".db-journal" ".pdf" ".metadata" ];
          description = ''
            File types the scanner should ignore
            Non-audio files will never be added to the database, but here you
            can prevent the scanner from even probing them. This might improve
            scan time. By default .db, .ini, .db-journal, .pdf and .metadata are
            ignored.
          '';
        };

        filepathIgnore = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            File paths the scanner should ignore
            If you want to exclude files on a more advanced basis you can enter
            one or more POSIX regular expressions, and any file with a matching
            path will be ignored.
          '';
        };

        filescanDisable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Disable startup file scanning
            When forked-daapd starts it will do an initial file scan of your
            library (and then watch it for changes). If you are sure your library
            never changes while forked-daapd is not running, you can disable the
            initial file scan and save some system ressources. Disabling this scan
            may lead to forked-daapd's database coming out of sync with the
            library. If that happens read the instructions in the README on how
            to trigger a rescan.
          '';
        };

        itunesOverrides = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Should iTunes metadata override ours?
          '';
        };

        itunesSmartpl = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Should we import the content of iTunes smart playlists?
          '';
        };

        noDecode = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            Decoding options for DAAP clients
            Since iTunes has native support for mpeg, mp4a, mp4v, alac and wav,
            such files will be sent as they are. Any other formats will be decoded
            to raw wav. If forked-daapd detects a non-iTunes DAAP client, it is
            assumed to only support mpeg and wav, other formats will be decoded.
            Here you can change when to decode. Note that these settings have no
            effect on AirPlay.
            Formats: mp4a, mp4v, mpeg, alac, flac, mpc, ogg, wma, wmal, wmav, aif, wav
            Formats that should never be decoded
          '';
        };

        forceDecode = mkOption {
          type = types.listOf types.str;
          default = [];
          description = ''
            Decoding options for DAAP clients
            Since iTunes has native support for mpeg, mp4a, mp4v, alac and wav,
            such files will be sent as they are. Any other formats will be decoded
            to raw wav. If forked-daapd detects a non-iTunes DAAP client, it is
            assumed to only support mpeg and wav, other formats will be decoded.
            Here you can change when to decode. Note that these settings have no
            effect on AirPlay.
            Formats: mp4a, mp4v, mpeg, alac, flac, mpc, ogg, wma, wmal, wmav, aif, wav
            Formats that should always be decoded
          '';
        };

        pipeAutostart = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Watch named pipes in the library for data and autostart playback when
            there is data to be read. To exclude specific pipes from watching,
            consider using the above _ignore options.
          '';
        };

        ratingUpdates = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enable automatic rating updates
            If enabled, rating is automatically updated after a song has either been
            played or skipped (only skipping to the next song is taken into account).
            The calculation is taken from the beets plugin "mpdstats" (see
            https://beets.readthedocs.io/en/latest/plugins/mpdstats.html).
            It consist of calculating a stable rating based only on the play- and
            skipcount and a rolling rating based on the current rating and the action
            (played or skipped). Both results are combined with a mix-factor of 0.75:
            new rating = 0.75 * stable rating + 0.25 * rolling rating)
          '';
        };

        allowModifyingStoredPlaylists = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Allows creating, deleting and modifying m3u playlists in the library directories.
            Only supported by the player web interface and some mpd clients
            Defaults to being disabled.
          '';
        };

        defaultPlaylistDirectory = mkOption {
          type = types.str;
          default = "";
          description = ''
            A directory in one of the library directories that will be used as the default
            playlist directory. forked-dapd creates new playlists in this directory if only
            a playlist name is provided (requires "allow_modify_stored_playlists" set to true).
          '';
        };
      };

      audio = {

        nickname = mkOption {
          type = types.str;
          default = "Computer";
          description = ''
            Name - used in the speaker list in Remote
          '';
        };

        type = mkOption {
          type = types.str;
          default = "alsa";
          description = ''
            Type of the output (alsa, pulseaudio, dummy or disabled)
          '';
        };

        server = mkOption {
          type = types.str;
          default = "";
          description = ''
            For pulseaudio output, an optional server hostname or IP can be
            specified (e.g. "localhost"). If not set, connection is made via local
            socket.
          '';
        };

        card = mkOption {
          type = types.str;
          default = "default";
          description = ''
            Audio PCM device name for local audio output - ALSA only
          '';
        };

        mixer = mkOption {
          type = types.str;
          default = "";
          description = ''
            Mixer channel to use for volume control - ALSA only
            If not set, PCM will be used if available, otherwise Master.
          '';
        };

        mixerDevice = mkOption {
          type = types.str;
          default = "";
          description = ''
            Mixer device to use for volume control - ALSA only
            If not set, the value for "card" will be used.
          '';
        };

        syncDisable = mkOption {
          type = types.bool;
          default = false;
          description = ''
            Enable or disable audio resampling to keep local audio in sync with
            e.g. Airplay. This feature relies on accurate ALSA measurements of
            delay, and some devices don't provide that. If that is the case you
            are better off disabling the feature.
          '';
        };

        offsetMs = mkOption {
          type = types.int;
          default = 0;
          description = ''
            Here you can adjust when local audio is started relative to other
            speakers, e.g. Airplay. Negative values correspond to moving local
            audio ahead, positive correspond to delaying it. The unit is
            milliseconds. The offset must be between -1000 and 1000 (+/- 1 sec).
          '';
        };

        adjustPeriodSeconds = mkOption {
          type = types.int;
          default = 100;
          description = ''
            To calculate what and if resampling is required, local audio delay is
            measured each second. After a period the collected measurements are
            used to estimate drift and latency, which determines if corrections
            are required. This setting sets the length of that period in seconds.
          '';
        };

      };

      openFirewall = mkOption {
        type = types.bool;
        default = true;
        description = "Open ports in the firewall";
      };

      loglevel = mkOption {
        type = types.str;
        default = "log";
        description = ''
          Verbosity of log
          Available levels: fatal, log, warning, info, debug, spam
        '';
      };

      airplay = {

        controlPort = mkOption {
          type = types.int;
          default = 5014;
          description = ''
            UDP ports used when airplay devices make connections back to forked-daapd
            (choosing specific ports may be helpful when running forked-daapd behind a firewall)
          '';
        };

        timingPort = mkOption {
          type = types.int;
          default = 5015;
          description = ''
            UDP ports used when airplay devices make connections back to forked-daapd
            (choosing specific ports may be helpful when running forked-daapd behind a firewall)
          '';
        };
      };


      streaming = {
        sampleRate = mkOption {
          type = types.int;
          default = 44100;
          description = "Sample rate, typically 44100 or 48000";
        };

        bitRate = mkOption {
          type = types.int;
          default = 192;
          description = ''
            Set the MP3 streaming bit rate (in kbps)
            valid options: 64 / 96 / 128 / 192 / 320
          '';
        };
      };

      extraOptions = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Additional forked-daapd settings.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.forked-daapd = {
      description = "DAAP/DACP (iTunes), RSP and MPD server, supports AirPlay and Remote";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = ''
          ${pkgs.forked-daapd}/bin/forked-daapd -f -c ${configFile}
        '';
        Restart = "always";
        User = "daapd";
        UMask = "0022";
      };
    };

    services.avahi = {
      enable = true;
      publish.enable = true;
      publish.userServices = true;
      openFirewall = true;
    };

    services.nginx = mkIf (cfg.virtualHost != null) {
      enable = true;
      recommendedProxySettings = true;
      virtualHosts.${cfg.virtualHost} = {
        locations."/".proxyPass = "http://localhost:${toString cfg.library.port}";
      };
    };

    networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.websocketPort cfg.library.port ];
    networking.firewall.allowedUDPPorts = mkIf cfg.openFirewall [ cfg.airplay.controlPort cfg.airplay.timingPort ];

    users.users.daapd = {
      description = "forked-daapd service user";
      name = cfg.user;
      home = cfg.home;
      createHome = true;
      isSystemUser = true;
    };
  };
}
