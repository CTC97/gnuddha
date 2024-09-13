class Gnuddha < Formula
  desc "Meditation UI in your favorite bash terminal. Homebrew distribution coming soon! "
  homepage ""
  url "https://github.com/CTC97/gnuddha/archive/refs/tags/0.1.e.tar.gz"
  sha256 "726b73a026aee06dad970bf64031c8ac0df61c2344350643cf7e5a22c17f0e84"
  license ""

  depends_on "jq"
  depends_on "bc"
  depends_on "mpg123"
  depends_on "curl"

  def install
    bin.install "gnuddha.sh" => "gnuddha"
    (share/"sprites").install Dir["sprites/*"]
  end

  test do
    system "false"
  end
end