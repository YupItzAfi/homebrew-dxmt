class Dxmt < Formula
  desc "Metal-based implementation of D3D11 and D3D10 for macOS / Wine"
  homepage "https://github.com/3Shain/dxmt"
  license "MIT" # TODO: Update to LGPL-2.1-or-later next release
  head "https://github.com/3Shain/dxmt.git", branch: "main"

  stable do
    url "https://github.com/3Shain/dxmt.git",
      tag:      "v0.80",
      revision: "589adb780354b461645b29999cefaf533594ee99"
    on_sonoma do
      # TODO: Remove next version bump
      patch do
        url "https://github.com/3Shain/dxmt/commit/75bd4da5d19057df0659ba9d38395b85ba7cbbeb.patch?full_index=1"
        sha256 "679467ad4fc39cf77799ae61811af77ed9e643fe75785cedc4d57bbf3a0fe859"
        type :backport
      end
    end
  end

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  keg_only "wine DLLs/SO's shouldn't be in Homebrew prefix"

  option "with-nvapi", "Enable NVAPI support"
  option "with-nvngx", "Enable NVNGX support"
  option "with-d3d12", "Enable the experimental D3D12 backend (HEAD only)"
  option "with-native-dlls", "Build native DLLs instead of Wine builtin DLLs"

  option "with-build-airconv-for-windows", "Compile airconv to be used in Windows"
  option "with-dxmt-debug", "Enable debug layers"
  option "with-dxmt-native", "Compile DXMT Native instead of Wine DLLs"
  # option "with-tests", "Enable tests (enable to use \"brew test\")"

  depends_on xcode: :build

  depends_on "llvm@15" => :build
  depends_on macos: :sonoma
  depends_on "meson" => :build
  depends_on "mingw-w64" => :build
  depends_on "ninja" => :build

  # TODO: Remove `head` next version. Keep contents.
  if DevelopmentTools.clang_build_version <= 1500 && build.head?
    # Residency Set is not supported until Xcode 16.1
    odie "Required features not supported by compiler! Please upgrade to Xcode 16.1 and macOS 14.5 or later"
  end

  resource "wine@8" do
    url "https://github.com/3Shain/wine/releases/download/v8.16-3shain/wine.tar.gz"
    sha256 "289c7f19e270a3d3d0a6fdb07691b176c70a0795f6811e5255cba82425de4f10"
  end

  # resource "llvm-mingw" do
  #   url "https://github.com/mstorsjo/llvm-mingw/releases/download/20260616/llvm-mingw-20260616-ucrt-macos-universal.tar.xz"
  #   sha256 "2cab02a2e964bd4aae981150a45985d07c657cfa8d244959eb9e2dcc5eedd7b1"
  # end

  def install
    (buildpath/"toolchains/wine").install resource("wine@8")
    # (buildpath/"toolchains/llvm-mingw").install resource("llvm-mingw")
    # ENV.prepend_path "PATH", buildpath/"toolchains/llvm-mingw/bin"
    args = [
      "-Dwine_install_path=toolchains/wine",
    ]

    args << "-Denable_d3d12=#{build.with?("d3d12")}" if build.head?
    args << "-Dwine_builtin_dll=#{!build.with?("native-dlls")}"
    args << "-Dbuild_airconv_for_windows=#{build.with?("build-airconv-for-windows")}"
    args << "-Ddxmt_debug=#{build.with?("dxmt-debug")}"
    args << "-Ddxmt_native=#{build.with?("dxmt-native")}"
    # args << "-Denable_tests=#{build.with?("tests")}"

    %w[32 64].each do |arch|
      ohai "Building #{arch}-bit #{build.with?("native-dlls") ? "native" : "builtin"} DLLs..."
      if arch == "64"
        args << "-Denable_nvapi=#{build.with?("nvapi")}"
        args << "-Denable_nvngx=#{build.with?("nvngx")}"
      end

      system "meson", "setup", "--cross-file", "build-win#{arch}.txt",
                               "build_#{arch}", *args, *std_meson_args
      system "meson", "install", "-C", "build_#{arch}", "--strip"
    end
    rm buildpath.glob(prefix/"**/*.a")
  end

  test do
    ENV["WINEDLLPATH"] = prefix.to_s
    ENV["WINEPREFIX"] = (testpath/".wine").to_s
    fl = %w[d3d10core d3d11 dxgi]

    fl << "d3d12" if build.with?("d3d12")
    system "wineboot", "-u"

    if build.with?("native-dlls")
      cp_r prefix/"system32", WINEPREFIX/"drive_c/windows/system32"
      cp_r prefix/"syswow64", WINEPREFIX/"drive_c/windows/syswow64"
      fl.each do |d3d|
        system "wine", "reg", "add", "HKCU\\Software\\Wine\\DllOverrides",
                                        "/v", d3d.to_s, "/d", "native,builtin", "/f"
      end
    end
    # TODO: Find / make test program to use here for d3d10, d3d11 and d3d12.
  end
end
