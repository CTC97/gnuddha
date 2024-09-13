class GNUddha < Formula
  desc "Meditation in your terminal."
  homepage "https://github.com/CTC97/gnuddha"
  url ""
  sha256 ""
  version "0.1.e"

  def install
    bin.install "gnuddha.sh"
    
    (share/"bash_package/text-files").install Dir["bash_package/sprites/*"]
  end

  # def post_install
  #   # Any post-install tasks if needed (optional)
  # end

  # test do
  #   system "#{bin}/bash.sh", "--version"
  # end
end
