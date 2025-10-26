class Mxp < Formula
  desc "Pipe content between terminal and Emacs buffers"
  homepage "https://github.com/agzam/emacs-piper"
  url "https://github.com/agzam/emacs-piper.git",
      branch: "main"
  license "MIT"
  version "0.4.0"
  head "https://github.com/agzam/emacs-piper.git", branch: "main"

  depends_on "emacs"

  def install
    bin.install "mxp"
  end

  def caveats
    <<~EOS
      mxp requires an Emacs daemon to be running.
      Start the daemon with:
        emacs --daemon

      Or add to your shell config:
        if ! pgrep -x "emacs" > /dev/null; then
          emacs --daemon
        fi
    EOS
  end

  test do
    # Test that the script runs and shows version
    assert_match "mxp v0.4.0", shell_output("#{bin}/mxp --version")
  end
end
