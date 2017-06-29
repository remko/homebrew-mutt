# Note: Mutt has a large number of non-upstream patches available for
# it, some of which conflict with each other. These patches are also
# not kept up-to-date when new versions of mutt (occasionally) come
# out.
#
# To reduce Homebrew's maintenance burden, new patches are not being
# accepted for this formula. We would be very happy to see members of
# the mutt community maintain a more comprehesive tap with better
# support for patches.

class Mutt < Formula
  desc "Mongrel of mail user agents (part elm, pine, mush, mh, etc.)"
  homepage "http://www.mutt.org/"
  url "https://bitbucket.org/mutt/mutt/downloads/mutt-1.6.0.tar.gz"
  mirror "ftp://ftp.mutt.org/pub/mutt/mutt-1.6.0.tar.gz"
  sha256 "29afb6238ab7a540c0e3a78ce25c970f975ab6c0f0bc9f919993aab772136c19"

  bottle do
    sha256 "1e27fac20a479746cf1383308734e2bdcbaac23b8036d0a685a8a4843f8c4221" => :el_capitan
    sha256 "4fccc940ea0d361347a56d990173b46ea8d1c33499dca4e3111538b91d1ceec9" => :yosemite
    sha256 "0726d3cca276a4f7db0e338e942c20394f4e78a02f1417f9b6d4fb440908ec65" => :mavericks
  end

  head do
    url "https://dev.mutt.org/hg/mutt#default", :using => :hg

    resource "html" do
      url "https://dev.mutt.org/doc/manual.html", :using => :nounzip
    end
  end

  option "with-debug", "Build with debug option enabled"
  option "with-s-lang", "Build against slang instead of ncurses"
  option "with-ignore-thread-patch", "Apply ignore-thread patch"
  option "with-confirm-attachment-patch", "Apply confirm attachment patch"
  option "with-trash-patch", "Apply trash folder patch"
  option "with-gmail-custom-search-patch", "Apply gmail custom search folder patch"
  option "with-gmail-labels-patch", "Apply gmail custom search folder patch"

  depends_on "autoconf" => :build
  depends_on "automake" => :build

  depends_on "openssl"
  depends_on "tokyo-cabinet"
  depends_on "gettext" => :optional
  depends_on "gpgme" => :optional
  depends_on "libidn" => :optional
  depends_on "s-lang" => :optional

  # original source for this went missing, patch sourced from Arch at
  # https://aur.archlinux.org/packages/mutt-ignore-thread/
  if build.with? "ignore-thread-patch"
    patch do
      url "https://gist.githubusercontent.com/mistydemeo/5522742/raw/1439cc157ab673dc8061784829eea267cd736624/ignore-thread-1.5.21.patch"
      sha256 "7290e2a5ac12cbf89d615efa38c1ada3b454cb642ecaf520c26e47e7a1c926be"
    end
  end

  if build.with? "confirm-attachment-patch"
    patch do
      url "https://gist.githubusercontent.com/tlvince/5741641/raw/c926ca307dc97727c2bd88a84dcb0d7ac3bb4bf5/mutt-attach.patch"
      sha256 "da2c9e54a5426019b84837faef18cc51e174108f07dc7ec15968ca732880cb14"
    end
  end

  if build.with? "trash-patch"
    patch do
      url "https://raw.githubusercontent.com/remko/homebrew-mutt/master/patches/mutt-trashfolder.diff"
      sha256 "06eefa35d87c41ea6ed05483364d3d28af7a766f10231ac742d8c7eaa61d0e70"
    end
  end

  if build.with? "gmail-custom-search-patch"
    patch do
      url "https://raw.githubusercontent.com/remko/homebrew-mutt/master/patches/mutt-gmail-custom-search.diff"
      sha256 "ad48cdbe897edf96ed70a3a64f0fa6bec38829b47c8dd523a0c33e87602cc11b"
    end
  end

  if build.with? "gmail-labels-patch"
    patch do
      url "https://raw.githubusercontent.com/remko/homebrew-mutt/master/patches/mutt-gmail-labels.diff"
      sha256 "9a32e35e3df40cb2ddb411cc96447624b33a02dcb475f42940676f74a0ab04e6"
    end
  end

  def install
    user_admin = Etc.getgrnam("admin").mem.include?(ENV["USER"])

    args = %W[
      --disable-dependency-tracking
      --disable-warnings
      --prefix=#{prefix}
      --with-ssl=#{Formula["openssl"].opt_prefix}
      --with-sasl
      --with-gss
      --enable-imap
      --enable-smtp
      --enable-pop
      --enable-hcache
      --with-tokyocabinet
      --enable-sidebar
    ]

    # This is just a trick to keep 'make install' from trying
    # to chgrp the mutt_dotlock file (which we can't do if
    # we're running as an unprivileged user)
    args << "--with-homespool=.mbox" unless user_admin

    args << "--disable-nls" if build.without? "gettext"
    args << "--enable-gpgme" if build.with? "gpgme"
    args << "--with-slang" if build.with? "s-lang"

    if build.with? "debug"
      args << "--enable-debug"
    else
      args << "--disable-debug"
    end

    system "./prepare", *args
    system "make"

    # This permits the `mutt_dotlock` file to be installed under a group
    # that isn't `mail`.
    # https://github.com/Homebrew/homebrew/issues/45400
    if user_admin
      inreplace "Makefile", /^DOTLOCK_GROUP =.*$/, "DOTLOCK_GROUP = admin"
    end

    system "make", "install"
    doc.install resource("html") if build.head?
  end

  test do
    system bin/"mutt", "-D"
  end
end
