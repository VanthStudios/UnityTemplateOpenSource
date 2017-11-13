#! /bin/sh

# The scope of the script is running the build for the three major
# platform: Windows, Linux, OS X.
# Paramas: require to pass the env variable TRAVIS_REPO_SLUG so to get
# the name of the project and use it to name the executable file.
# Returns: if all steps are done successfully, then in the directory
# Build will be put a directory for each platform with inside the
# relative build. 

checkBuildStatus() {
    local exitCode=$1
    local platform=$2
    local logPath=$3

    if [ $exitCode -ne 0 ]
    then
	echo "$platform: exit during the build with code $exitCode. " \
	     "Log output:"
	cat $logPath
	exit $exitCode
    fi

    echo "$platform: done!"
}

if [ $# -ne 1 ]
then
    echo "The TRAVIS_REPO_SLUG env variable was not set as input!"
    exit 1
fi

project=$(echo $1 | cut -d '/' -f 2)

echo "Attempting to build $project for Windows"
/Applications/Unity/Unity.app/Contents/MacOS/Unity \
  -batchmode \
  -nographics \
  -silent-crashes \
  -logFile $(pwd)/unity.log \
  -projectPath $(pwd) \
  -buildWindowsPlayer "$(pwd)/Build/windows/$project.exe" \
  -quit

checkBuildStatus $? "Windows" $(pwd)/unity.log

echo "Attempting to build $project for OS X Universal"
/Applications/Unity/Unity.app/Contents/MacOS/Unity \
  -batchmode \
  -nographics \
  -silent-crashes \
  -logFile $(pwd)/unity.log \
  -projectPath $(pwd) \
  -buildOSXUniversalPlayer "$(pwd)/Build/osx/$project.app" \
  -quit

checkBuildStatus $? "OS X Universal" $(pwd)/unity.log

echo "Attempting to build $project for Linux Universal"
/Applications/Unity/Unity.app/Contents/MacOS/Unity \
  -batchmode \
  -nographics \
  -silent-crashes \
  -logFile $(pwd)/unity.log \
  -projectPath $(pwd) \
  -buildLinuxUniversalPlayer "$(pwd)/Build/linux/$project" \
  -quit

checkBuildStatus $? "Linux Universal" $(pwd)/unity.log

echo "Attempting to zip builds"
zip -r $(pwd)/Build/linux.zip $(pwd)/Build/linux/
zip -r $(pwd)/Build/osx.zip $(pwd)/Build/osx/
zip -r $(pwd)/Build/windows.zip $(pwd)/Build/windows/

echo "Done!"
