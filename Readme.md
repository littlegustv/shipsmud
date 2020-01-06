Follow the instructions <a href="https://haxeflixel.com/documentation/install-haxeflixel/" target="_blank">here</a>, to install haxe, haxelib and the relevent haxe libraries (openfl, lime, haxeflixel)

Then install the mphx library for network support:

 - haxelib git mphx https://github.com/galoyo/mphx.git
 
THIS IS FOR WINDOWS C++ BUILDS: Install Visual Studio Community 2017, adding the following components:
 - Under Workloads, check "Desktop development with C++"
 - Under Individual components, make sure "VC++ 2017 version 15.9 v14.16 latest v141 tools" is checked
 
**lime test windows** should now work without any other customization.

*For in-progress testing, I recommend **lime test neko** which is a faster build.  Executable files can be found in the 'exports/platform/bin/' directories, for testing multiple connections.*

#### Specific library versions (if needed):
 - lime: 7.2.1
 - openfl: 8.8.0
 - flixel: git [ https://github.com/littlegustv/flixel.git ]
 - flixel-ui: 2.3.2
 - flixel-addons: 2.7.3
 - mphx: git [ https://github.com/galoyo/mphx.git ]