class Janus < Formula
  desc "Run annotated shell scripts as concurrent, grouped, progress-tracked steps"
  homepage "https://github.com/antonjk/janus"
  url "https://github.com/antonjk/janus/archive/refs/tags/v1.0.1.tar.gz"
  sha256 "e482fed512f881c377376f043dc133eee0504870cc85ab10ad8ba5e2192ba094"
  license "MIT"

  # The janus runtime requires Bash 4+ (wait -n, etc.); macOS ships 3.2.
  depends_on "bash"
  # The standalone bundle resolves color via a `cprintf` on PATH (else plain text).
  # Depend on it so a Homebrew install has colored output out of the box.
  depends_on "antonjk/tap/cprintf"

  def install
    # Build the standalone single-file janus (runtime inlined; no include/ needed).
    system "make", "build"

    # Install the bundle, pointing its shebang at the Homebrew bash so the
    # Bash 4+ runtime requirement is satisfied regardless of the user's PATH.
    bash = Formula["bash"].opt_bin/"bash"
    inreplace "dist/janus", %r{\A#!.*\n}, "#!#{bash}\n"
    bin.install "dist/janus"

    # Man page (janus-run.1), with janus.1 as an alias for the installed command.
    man1.install "doc/janus-run.1"
    (man1/"janus.1").make_symlink "janus-run.1"
  end

  test do
    # An annotated script with one group and one step; run it through janus and
    # assert the step's status and output appear.
    (testpath/"demo.sh").write <<~'EOS'
      #!/usr/bin/env bash
      #@ group: smoke
          #@ step success=1: hello
          echo "janus works"
          #@ end
      #@ end
    EOS
    output = shell_output("#{bin}/janus #{testpath}/demo.sh 2>&1")
    assert_match "smoke", output
    assert_match "hello", output
    assert_match "janus works", output
  end
end
