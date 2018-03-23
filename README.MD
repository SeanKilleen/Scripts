# Sean's Scripts

A place for me to keep track of and version some fun helpful scripts that I've created or used. I'll try to provide attribution whenever something doesn't really come directly from me.

## Script Catalog
A tour of the scripts in this repo.
### BusinsessTrip.ps1
I sometimes go on business trips and before I do, I like to make sure I have all the latest packages, etc. especially so that I can copy them to Offline folders for use while on airplanes, etc.

For every repo in my repos folder, this script:

* Pulls all the latest branches from git / github
* Installs all of the nuget packages
* Installs all of the ruby gems
* Installs all of the npm packages
* Copyies the Nuget packages into my offline nuget folder, which will allow me to use them to create new apps while on planes etc.

It also logs the output to a CSV and the screen, because why not? 