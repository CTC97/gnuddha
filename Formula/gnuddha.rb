class gnuddha < Formula
  desc "Meditation at home."
  homepage "https://github.com/CTC97/gnuddha"
  url "https://github.com/yourusername/yourrepository/archive/v1.0.0.tar.gz"
  sha256 "hash_of_your_tar_file"
  version "0.1.0"

  depends_on "jq"
  depends_on "mpg123"
  depends_on "bc"

  def install
    bin.install "gnuddha.sh"
    bin.install "dhamma.json"
    bin.install "bells-1-72261.mp3"
  end

  test do
    system "#{bin}/gnuddha.sh -t 1 -c ipurple", "-h"
  end
end
