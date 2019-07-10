# Note: Mutt has a large number of non-upstream patches available for
# it, some of which conflict with each other. These patches are also
# not kept up-to-date when new versions of mutt (occasionally) come
# out.
#
# To reduce Homebrew's maintenance burden, patches are not accepted
# for this formula. The NeoMutt project has a Homebrew tap for their
# patched version of Mutt: https://github.com/neomutt/homebrew-neomutt

class Mutt < Formula
  desc "Mongrel of mail user agents (part elm, pine, mush, mh, etc.)"
  homepage "http://www.mutt.org/"
  url "https://bitbucket.org/mutt/mutt/downloads/mutt-1.12.1.tar.gz"
  sha256 "01c565406ec4ffa85db90b45ece2260b25fac3646cc063bbc20a242c6ed4210c"
  revision 1

  bottle do
    sha256 "e0c20be9ff6d0ce29d610cb61ed92f35bfb3abe7a49c8927ecbf6aecad49d375" => :mojave
    sha256 "4ea37a2acfe5c0ea6ecc4ae5a0cf53db7a6ff7c9aef50ea971ea359e49160ec6" => :high_sierra
    sha256 "78f11d068e9732a78ee2dc6340876ec4b4d5e38a1123f636161ec03329ffc15d" => :sierra
  end

  head do
    url "https://gitlab.com/muttmua/mutt.git"

    resource "html" do
      url "https://muttmua.gitlab.io/mutt/manual-dev.html"
    end
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "gpgme"
  depends_on "openssl"
  depends_on "tokyo-cabinet"

  conflicts_with "tin",
    :because => "both install mmdf.5 and mbox.5 man pages"

  patch do
    url "https://raw.githubusercontent.com/remko/homebrew-mutt/master/patches/mutt-gmail-labels.diff"
    sha256 "86fecceaf03d836eb8a1c0b1149f6ee3d2b1f473061902e312f630b6eead2a4d"
  end

  # patch do
  #   url "https://raw.githubusercontent.com/remko/homebrew-mutt/master/patches/mutt-trashfolder.diff"
  #   sha256 "06eefa35d87c41ea6ed05483364d3d28af7a766f10231ac742d8c7eaa61d0e70"
  # end

  # patch do
  #   url "https://raw.githubusercontent.com/remko/homebrew-mutt/master/patches/mutt-gmail-custom-search.diff"
  #   sha256 "ad48cdbe897edf96ed70a3a64f0fa6bec38829b47c8dd523a0c33e87602cc11b"
  # end

  def install
    user_in_mail_group = Etc.getgrnam("mail").mem.include?(ENV["USER"])
    effective_group = Etc.getgrgid(Process.egid).name

    args = %W[
      --disable-dependency-tracking
      --disable-warnings
      --prefix=#{prefix}
      --enable-debug
      --enable-hcache
      --enable-imap
      --enable-pop
      --enable-sidebar
      --enable-smtp
      --with-gss
      --with-sasl
      --with-ssl=#{Formula["openssl"].opt_prefix}
      --with-tokyocabinet
      --enable-gpgme
    ]

    system "./prepare", *args
    system "make"

    # This permits the `mutt_dotlock` file to be installed under a group
    # that isn't `mail`.
    # https://github.com/Homebrew/homebrew/issues/45400
    unless user_in_mail_group
      inreplace "Makefile", /^DOTLOCK_GROUP =.*$/, "DOTLOCK_GROUP = #{effective_group}"
    end

    system "make", "install"
    doc.install resource("html") if build.head?
  end

  def caveats; <<~EOS
    mutt_dotlock(1) has been installed, but does not have the permissions lock
    spool files in /var/mail. To grant the necessary permissions, run

      sudo chgrp mail #{bin}/mutt_dotlock
      sudo chmod g+s #{bin}/mutt_dotlock

    Alternatively, you may configure `spoolfile` in your .muttrc to a file inside
    your home directory.
  EOS
  end

  test do
    system bin/"mutt", "-D"
    touch "foo"
    system bin/"mutt_dotlock", "foo"
    system bin/"mutt_dotlock", "-u", "foo"
  end
end
