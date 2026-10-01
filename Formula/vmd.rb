class Vmd < Formula
  desc "Markdown viewer for macOS: GFM, mermaid, KaTeX math, live reload, CLI"
  homepage "https://github.com/ewasserman/vmd"
  url "https://github.com/ewasserman/vmd/archive/refs/tags/v1.6.0.tar.gz"
  sha256 "c2cea169d50f56742de45822512e0db94868b1ca34ea3b311e82513222faed2e"
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

  def post_install
    lsregister = "/System/Library/Frameworks/CoreServices.framework/Frameworks/" \
                 "LaunchServices.framework/Support/lsregister"

    # On `brew upgrade` this runs while the previous version's keg is still on
    # disk (brew removes old kegs afterwards, or never with
    # HOMEBREW_NO_INSTALL_CLEANUP). Unregister those copies so Launch Services
    # only knows about this one. A user's default handler for markdown is
    # stored by bundle id, so it moves over to this version on its own.
    rack.subdirs.each do |keg|
      next if keg == prefix

      old_app = keg/"libexec/VMD.app"
      quiet_system lsregister, "-u", old_app if old_app.exist?
    end

    # Register the app (and its markdown document type) with Launch Services
    # so `vmd` and Finder's "Open With" find it immediately.
    system lsregister, "-f", "#{libexec}/VMD.app"
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
