class Cprintf < Formula
  desc "Printf with XML-style markup for terminal colors and text effects"
  homepage "https://github.com/antonjk/bash-cprintf"
  url "https://github.com/antonjk/bash-cprintf/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "9060cf85d18284402658eae92c47d6a1f971ea4a9d5f736783f6e9e9df35f39c"
  license "MIT"

  # cprintf uses associative arrays, namerefs, and ${var^^}; requires Bash 4+.
  depends_on "bash"

  def install
    # Build the full single-file cprintf (core + all optional CLI modules).
    system "make", "build"

    # Install the full build as `cprintf`, pointing its shebang at the Homebrew bash
    # so the Bash 4+ requirement holds regardless of the user's PATH.
    bash = Formula["bash"].opt_bin/"bash"
    inreplace "dist/cprintf-full", %r{\A#!.*\n}, "#!#{bash}\n"
    bin.install "dist/cprintf-full" => "cprintf"

    man1.install "doc/cprintf.1" if File.exist?("doc/cprintf.1")
  end

  test do
    # As a command: render markup and strip-compare the visible text.
    output = shell_output("#{bin}/cprintf '<fg:green>%s</fg>\\n' ok")
    assert_match "ok", output

    # As a sourced library: the cprintf function must be defined.
    (testpath/"lib.sh").write <<~EOS
      source #{bin}/cprintf
      declare -f cprintf >/dev/null && echo "fn-ok"
    EOS
    assert_match "fn-ok", shell_output("#{Formula["bash"].opt_bin}/bash #{testpath}/lib.sh")
  end
end
