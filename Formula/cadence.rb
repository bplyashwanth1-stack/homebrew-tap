class Cadence < Formula
  desc "Synced, animated lyrics on the Mac lock screen for Spotify, Apple Music and YouTube"
  homepage "https://github.com/bplyashwanth1-stack/Cadence"
  url "https://github.com/bplyashwanth1-stack/Cadence/archive/refs/tags/v1.1.tar.gz"
  sha256 "d3a69c7be0baea16c276e34204db3428ddc70e41bd9d33d2f7d3a94cc16485b0"
  license "MIT"

  depends_on macos: :sonoma

  def install
    contents = prefix/"Cadence.app/Contents"
    (contents/"MacOS").mkpath
    (contents/"Resources/Fonts").mkpath
    cp "Info.plist", contents
    system "/usr/libexec/PlistBuddy", "-c", "Set :CFBundleShortVersionString #{version}", contents/"Info.plist"
    system "/usr/libexec/PlistBuddy", "-c", "Set :CFBundleVersion #{version}", contents/"Info.plist"
    cp Dir["Fonts/*.ttf"], contents/"Resources/Fonts"
    arch = Hardware::CPU.arm? ? "arm64" : "x86_64"
    system "swiftc", "-O", "-swift-version", "5", "-target", "#{arch}-apple-macos14.0",
           *Dir["Sources/*.swift"], "-o", contents/"MacOS/Cadence"
    system "codesign", "--force", "--sign", "-", prefix/"Cadence.app"
  end

  def caveats
    <<~EOS
      To put Cadence in your Applications folder (once; it stays current on upgrades), run:
        mkdir -p ~/Applications && ln -sfn #{opt_prefix}/Cadence.app ~/Applications/Cadence.app

      Then open Cadence from Applications. A 🎤 appears in the menu bar.
      After `brew upgrade cadence`, quit and reopen Cadence; macOS may ask for its permissions again.
    EOS
  end

  test do
    assert_path_exists prefix/"Cadence.app/Contents/MacOS/Cadence"
    assert_equal version.to_s,
      shell_output("/usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' #{prefix}/Cadence.app/Contents/Info.plist").strip
  end
end
