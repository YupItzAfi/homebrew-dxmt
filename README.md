# YupItzAfi DXMT

## How do I install this formula?

_Please use an x86_64 Homebrew prefix to install this formula. This will not be required in the future_

Run the following:

```
brew trust yupitzafi/dxmt
brew tap yupitzafi/dxmt
brew install yupitzafi/dxmt/dxmt
```
Or, `brew install dxmt`

Currently there is no arm64 Windows DLLs provided by this formula.

## To install into Wine
Just copy the DLLs into `<wine>/lib/wine/`. If you installed with `--with-native-dlls`, also copy the DLLs from `system32` and `syswow64` to your WINEPREFIX.

For example:

if builtin DLLs (default):

`ditto $(brew --prefix dxmt)/libs/wine /Applications/Wine\ Devel.app/Contents/Resources/wine/lib/wine`

if native DLLs (in addition to above):

```
ditto $(brew --prefix dxmt)/libs/wine-native $WINEPREFIX/drive_c/windows
wine reg add HKCU\\Software\\Wine\\DllOverrides /v d3d10core /d native,builtin /f
wine reg add HKCU\\Software\\Wine\\DllOverrides /v d3d11 /d native,builtin /f
wine reg add HKCU\\Software\\Wine\\DllOverrides /v dxgi /d native,builtin /f
```

(Optionally) `wine reg add HKCU\\Software\\Wine\\DllOverrides /v d3d12 /d native,builtin /f`

If your wine installation supports `WINEDLLPATH_PREPEND` variable through a [patch](https://github.com/Gcenx/wine/commit/d27d20014bd184d13e0e76cfc87c398e53ba10aa), then you don't need to do the above copying and can just set the variable to `$(brew --prefix yupitzafi/dxmt/dxmt)` before running your wine program.

# Options

| Option               | Description                 |
| -------------------- | --------------------------- |
| `--with-nvapi`       | Enable NVAPI                |
| `--with-nvngx`       | Enable NVNGX                |
| `--with-d3d12`       | Enable experimental D3D12   |
| `--with-native-dlls` | Compile DLLs for WINEPREFIX |
| `--with-build-airconv-for-windows` | Compile airconv for Windows |
| `--with-dxmt-debug`  | Enable debug layers         |
| `--with-dxmt-native` | Compile .so instead of .dll |

P.S: These options are disabled by default.
# Issues/PRs

No need to create any PRs here. If there is an issue/request, please use the `Issues` tab.
Do note:
* Make sure you install the latest build and re-install DXMT by copying them and testing your program once more.
* Only put build related issues/ requests. If there is an issue (while using DXMT in Wine) found only by this package when using fresh prefix and fresh Wine install (i.e you don't get this issue in your own build or the build provided by DXMT), then report here.
* Don't post DXMT specific issues here (for example, a game shows black when running it). Make sure other programs using this DXMT work fine. If no program works when using this specific build, then report here. Otherwise report to [DXMT Discord](https://dxmt.report)
* No AI/LLM generated posts/ comments, nor assisted by them.
* If build fails, make sure you put full logs of the build (You can find them in `~/Library/Logs/Homebrew/dxmt`). Also put your `brew doctor` and `brew config` info in triple backticks (like this: \`\`\` Hi \`\`\`)
* Mention which wine version you're using, along with which options you used to build DXMT)

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
