class Vmd < Formula
  desc "Markdown viewer for macOS: GFM, mermaid, KaTeX math, live reload, CLI"
  homepage "https://github.com/ewasserman/vmd"
  url "https://github.com/ewasserman/vmd/archive/refs/tags/v1.7.1.tar.gz"
  sha256 "3ae87904b5d4ae3e353c488da609ed9e0317ffd22cb464d7fd0f2a515d12d043"
  license "MIT"
  head "https://github.com/ewasserman/vmd.git", branch: "main"

  depends_on macos: :sonoma
  depends_on xcode: ["16.0", :build]

  def install
    # Built from source on the user's machine: no download quarantine, so the
    # ad-hoc-signed app runs without Apple notarization.
    system "make", "app", "SWIFT_FLAGS=--disable-sandbox", "VERSION=#{version}"
    libexec.install "dist/VMD.app"
    bin.install ".build/release/vmd"
  end

  def caveats
    <<~EOS
      VMD.app lives inside the Homebrew prefix:
        #{opt_libexec}/VMD.app

      The vmd CLI finds it there automatically. To also see it in
      Launchpad and Finder, link it into /Applications:
        ln -sf "#{opt_libexec}/VMD.app" /Applications/VMD.app

      Homebrew cannot register apps with macOS during install, so after
      installing or upgrading, run the CLI once:
        vmd -v
      Any vmd command registers this version of VMD.app with macOS, so
      Finder's "Open With" lists it and, if VMD is your default app for
      markdown, double-clicking a .md file opens this version.
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/vmd --help 2>&1", 64)
  end
end
