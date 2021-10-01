{ stdenv
, lib
, fetchurl
, pkg-config
, libxml2
, gnome
, dconf
, nautilus
, glib
, gtk3
, gsettings-desktop-schemas
, vte
, gettext
, which
, libuuid
, vala
, desktop-file-utils
, itstool
, wrapGAppsHook
, pcre2
, libxslt
, docbook-xsl-nons
}:

stdenv.mkDerivation rec {
  pname = "gnome-terminal";
  version = "3.42.0";

  src = fetchurl {
    url = "mirror://gnome/sources/gnome-terminal/${lib.versions.majorMinor version}/${pname}-${version}.tar.xz";
    sha256 = "tQ6eVmQjDmyikLzziBKltl4LqsZqSG7iEIlM9nX3Lgs=";
  };

  nativeBuildInputs = [
    pkg-config
    gettext
    itstool
    which
    libxml2
    libxslt
    glib # for glib-compile-schemas
    docbook-xsl-nons
    vala
    desktop-file-utils
    wrapGAppsHook
    pcre2
  ];

  buildInputs = [
    glib
    gtk3
    gsettings-desktop-schemas
    vte
    libuuid
    dconf
    nautilus # For extension
  ];

  # Silly ./configure, it looks for dbus file from gnome-shell in the
  # installation tree of the package it is configuring.
  postPatch = ''
    substituteInPlace configure --replace '$(eval echo $(eval echo $(eval echo ''${dbusinterfacedir})))/org.gnome.ShellSearchProvider2.xml' "${gnome.gnome-shell}/share/dbus-1/interfaces/org.gnome.ShellSearchProvider2.xml"
    substituteInPlace src/Makefile.in --replace '$(dbusinterfacedir)/org.gnome.ShellSearchProvider2.xml' "${gnome.gnome-shell}/share/dbus-1/interfaces/org.gnome.ShellSearchProvider2.xml"
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gnome-terminal";
      attrPath = "gnome.gnome-terminal";
    };
  };

  enableParallelBuilding = true;

  meta = with lib; {
    description = "The GNOME Terminal Emulator";
    homepage = "https://wiki.gnome.org/Apps/Terminal";
    platforms = platforms.linux;
    license = licenses.gpl3Plus;
    maintainers = teams.gnome.members;
  };
}
