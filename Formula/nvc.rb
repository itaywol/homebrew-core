class Nvc < Formula
  desc "VHDL compiler and simulator"
  homepage "https://github.com/nickg/nvc"
  url "https://github.com/nickg/nvc/releases/download/r1.6.0/nvc-1.6.0.tar.gz"
  sha256 "1e93e461b53261254b123ed0a88ba72316ed61d9985bb4439a473bd08b81da88"
  license "GPL-3.0-or-later"

  bottle do
    sha256 arm64_monterey: "f062caad9512a3c0d4d6a98f279355882922e2994ca2eae6b948adcb337ccaac"
    sha256 arm64_big_sur:  "0b77a79a7970ac8b0d53b6527ab1f5ef0cc7982012d526b2538f9b2c5277491b"
    sha256 monterey:       "ceb5b84552da80889605d9ca8b887955029d146f03f530da8c550394f50122f1"
    sha256 big_sur:        "419611c66adec0332e11016ab6fa9b56ba116254fef1062a9d526a971dc3abba"
    sha256 catalina:       "12cc92837fa8206d53be4c4be56c7fb568bf976a28feb6a3f314c119a34c59ea"
  end

  head do
    url "https://github.com/nickg/nvc.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
  end

  depends_on "check" => :build
  depends_on "pkg-config" => :build
  depends_on "llvm"

  uses_from_macos "flex" => :build

  fails_with gcc: "5" # LLVM is built with GCC

  resource "homebrew-test" do
    url "https://github.com/suoto/vim-hdl-examples.git",
        revision: "fcb93c287c8e4af7cc30dc3e5758b12ee4f7ed9b"
  end

  def install
    system "./autogen.sh" if build.head?
    # Avoid hardcoding path to the `ld` shim.
    inreplace "configure", "\\\"$linker_path\\\"", "\\\"ld\\\"" if OS.linux?
    system "./configure", "--with-llvm=#{Formula["llvm"].opt_bin}/llvm-config",
                          "--prefix=#{prefix}",
                          "--with-system-cc=#{ENV.cc}",
                          "--enable-vhpi",
                          "--disable-silent-rules"
    ENV.deparallelize
    system "make", "V=1"
    system "make", "V=1", "install"
  end

  test do
    resource("homebrew-test").stage testpath
    system "#{bin}/nvc", "-a", "#{testpath}/basic_library/very_common_pkg.vhd"
  end
end
