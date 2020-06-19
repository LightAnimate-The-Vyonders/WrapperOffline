# Wrapper: Offline
After the announcement that GoAnimate Wrapper (a project by VisualPlugin/Windows81) would be shut down, Wrapper: Offline was created. Unlike the original project, Wrapper: Offline can not be shut down. You have the files all on your computer. This project is important for historical and archival purposes, as the ability to use this legacy editor and themes would be completely gone without it. Besides simply emulating the original Flash editor, Wrapper also adds some additional features, such as additional poses for Comedy World characters. And Wrapper: Offline will continue to get additional updates in the future.

## Running / Installation
To start Wrapper on Windows, open start_wrapper.bat. It'll automate most steps for you, maybe ask a question or two when starting it for the first time, and start Wrapper.
On your first run, you will likely need to right-click it and click "Run as Administrator". This allows it to properly install what it needs to run. After your initial run, you shouldn't need to do that again, you can start it as normal.
If you want to import videos and characters from the original Wrapper, open its folder and drag the "_SAVED" folder into Wrapper: Offline's "wrapper" folder. If you have already made any videos or characters, this will not work. Please only import on a clean install, or take the "_SAVED" folder in Offline out before dragging the old one in. If you want to import character IDs from the original LVM, you can paste `&original_asset_id=[ID HERE]` at the end of the link for the matching character creator.

## Troubleshooting
This project has been tested on Windows 10 Version 1909 with the included ungoogled-chromium and Firefox 75. Linux support is coming soon, and Chrome OS support is being considered. I do not have a Mac computer to test and configure for, but it should still be possible to run if you set up manually. Almost all browsers (as of writing) are based on Chrome or Firefox, so if you're using another browser, it should still work fine. If you try using Wrapper on a non-Chrome/Firefox based browser or a non-Windows OS, please let me know the results!

Flash Player (the program the editor and player run on) support ends at the end of 2020. If this date has already passed, it may be harder to run Wrapper, as browsers remove support for Flash completely. By default, Wrapper starts using an included version of Chrome that supports Flash. You can also look into projects like [Lightspark](http://lightspark.github.io/) and [ruffle](https://ruffle.rs/) that are attempting to recreate Flash.

If you're running 32-bit Linux, you will not be able to install Node.js. An older version that supports 32-bit *may* work, but this is untested.

If you're using Firefox, it will stop the asset files from working, saying that the HTTPS certificate is untrusted because it is self-signed. There is no away around this, and it is not a concern beyond annoyance, as nobody besides you can access it. To fix this, you can visit <https://localhost:4343> or open the page with the launcher, and add a security exception in Firefox. If you see a notice like this on a real website, *that* is a cause for concern, but you're just connecting to yourself.

If you're getting errors that prevent Node.js or http-server from running, they may have updated in a way that breaks Wrapper. There should be tested versions that are known to work in the utilities folder, and you can replace the installed versions with those. This is not recommended unless you are sure the latest versions are causing problems. If you know what version caused this issue, you should install the latest version that works instead.

If your issue is not listed here, please look at the contact section below.

## Contact / Bug Report / Feature Suggestion / Updates
You can join the [Discord server](https://discord.gg/Kf7BzSw). Joining the server is recommended, as there is pre-written answers to questions and a community to help you out. If you absolutely refuse to join the server, you can message benson#0411 on Discord or email mailbenson@protonmail.com to get in contact with me directly, but don't expect as quick of a response.

## Dependencies
This program relies on Flash, Node.js and http-server to work properly. SilentCMD is also used to suppress all the extra logging noise you'd only need for troubleshooting and development. These all have been included with the project (utilities folder) to ensure full offline operation and will be installed if missing. The "wrapper" folder and http-server have their own dependencies, but they are included as well.

## License
Most of this project is free/libre software[1] under the MIT license. You have the freedom to run, change, and share this as much as you want.
This includes:
  - Files in the "wrapper" folder
  - Batch files made for Wrapper: Offline
  - Node.js
  - http-server
  - SilentCMD

ungoogled-chromium is under the BSD 3-Clause license, which grants similar rights, but has some differences from MIT. If you wish to see these differences, compare the LICENSE file in the base wrapper-offline folder and the LICENSE file in utilities/ungoogled-chromium.

Flash Player (utilities folder) and GoAnimate's original assets (server folder) are proprietary and do not grant you these rights, but if they did, this project wouldn't need to exist.

While completely unnecessary, if you decide to use your freedom to change the software, it would be greatly appreciated if you sent it to me so I can implement it into the main program! With credit down here of course :)

## Credits
Original Wrapper credits:
| Name         | Contribution         |
| ------------ | -------------------- |
| Poley Magik  | Research, Big Clown  |
| Vyond        | Assets               |
| VisualPlugin | GoAnimate Wrapper    |
| Imageny      | Custom/Modded Assets |
No members of the original team have joined or worked on Offline.

Unaffiliated users will have (U) on their name, to show they aren't connected to the project but I feel still deserve credit for their things.
Wrapper: Offline credits:
| Name        | Contribution                    |
| ----------- | ------------------------------- |
| Benson      | Wrapper: Offline                |
| NathanTDA   | Logo, custom assets, server mod |
| vocatus (U) | Some of TronScript's batch code |

## Footnotes
[1] - See <https://www.gnu.org/philosophy/free-sw.html> for a better definition of free software.
