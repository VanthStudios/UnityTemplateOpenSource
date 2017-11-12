#! /bin/sh

checkBuildStatus() {
    local exitCode=$1
    local platform=$2
    local logPath=$3

    if [ $exitCode -ne 0 ]
    then
	echo "ERROR: Exit during the build for the $platform platform with code $exitCode. " \
	     "Log output:"
	cat $logPath
	exit $exitCode
    fi
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

echo "Attempting to build $project for OS X"
/Applications/Unity/Unity.app/Contents/MacOS/Unity \
  -batchmode \
  -nographics \
  -silent-crashes \
  -logFile $(pwd)/unity.log \
  -projectPath $(pwd) \
  -buildOSXUniversalPlayer "$(pwd)/Build/osx/$project.app" \
  -quit

checkBuildStatus $? "OS X Universal" $(pwd)/unity.log

echo "Attempting to build $project for Linux"
/Applications/Unity/Unity.app/Contents/MacOS/Unity \
  -batchmode \
  -nographics \
  -silent-crashes \
  -logFile $(pwd)/unity.log \
  -projectPath $(pwd) \
  -buildLinuxUniversalPlayer "$(pwd)/Build/linux/$project" \
  -quit

checkBuildStatus $? "Linux Universal" $(pwd)/unity.log
