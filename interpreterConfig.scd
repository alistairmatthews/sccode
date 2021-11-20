//This file does general configuration stuff

//Classes are in the ~/code/sccode/classes folder

//Check the include paths
LanguageConfig.includePaths;

//Make sure this location is included in the config
(
LanguageConfig.addIncludePath("~/code/sccode/classes");
LanguageConfig.store();
//Now recompile the library - CTRL + SHIFT + L
//Emacs = C-c C-l
)

//Select the ASIO driver when you boot the server
//Otherwise the MME driver is selected and latency is too slow.
//Only execute this block on Windows
(
o = Server.default.options;
o.device = "ASIO : Focusrite USB ASIO";
Server.default.reboot;
)

//How to stop and start the server in code
Server.default.quit;
Server.default.boot;
