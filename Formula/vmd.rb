class Vmd < Formula
  desc "Markdown viewer for macOS: GFM, mermaid, KaTeX math, live reload, CLI"
  homepage "https://github.com/ewasserman/vmd"
  url "https://github.com/ewasserman/vmd/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "3fcbd84c9701ca9e5416423a58acdd4f5dec49428bee29c43e6819cf919f299e"
  license "MIT"
  head "https://github.com/ewasserman/vmd.git", branch: "main"

  depends_on macos: :sonoma
  depends_on xcode: ["16.0", :build]

  def install
    # Built from source on the user's machine: no download quarantine, so the
    # ad-hoc-signed app runs without Apple notarization.
    system "make", "app", "SWIFT_FLAGS=--disable-sandbox"
    libexec.install "dist/VMD.app"
    bin.install ".build/release/vmd"
  end

  def post_install
    # Register the app (and its markdown document type) with Launch Services
    # so `vmd` and Finder's "Open With" find it immediately.
    system "/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister",
           "-f", "#{libexec}/VMD.app"
  end

  def caveats
    <<~EOS
      VMD.app lives inside the Homebrew prefix:
        #{opt_libexec}/VMD.app

      The vmd CLI finds it there automatically. To also see it in
      Launchpad and Finder, link it into /Applications:
        ln -sf "#{opt_libexec}/VMD.app" /Applications/VMD.app
    EOS
  end

  test do
    assert_match "usage:", shell_output("#{bin}/vmd --help 2>&1", 64)
  end
end
