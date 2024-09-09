class Gnuddha < Formula
  desc "Meditation at home."
  homepage "https://github.com/CTC97/gnuddha"
  url "https://github.com/CTC97/gnuddha/archive/refs/tags/0.1.a.tar.gz"
  sha256 "c1865ae52219a431208756b4b36e78be6c6331eadf56e4934ccc8921f31ce3eb"
  version "0.1.0"

  depends_on "jq"
  depends_on "mpg123"
  depends_on "bc"

  def install
    bin.install "gnuddha.sh" => "gnuddha"
    (pkgshare/"b_frames").install Dir["b_frames/*"]
    pkgshare.install "dhamma.json", "bells-1-72261.mp3"
  end

  test do
    system "#{bin}/gnuddha -t 1 -c ipurple"
  end
end
