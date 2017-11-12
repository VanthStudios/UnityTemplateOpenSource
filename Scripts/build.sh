#! /bin/sh

checkBuildStatus() {
    exitCode = $1
    platform = $2
    logPath = $3

    if [ $exitCode -ne 0 ]
    then
	echo "ERROR: Exit during the build for the $platform platform with code $exitCode. " \
	     "Log output:"
	cat $logPath
	return $exitCode
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

exitCode=checkBuildStatus $? "Windows" $(pwd)/unity.log
if [ $exitCode -ne 0 ]
then
    return $exitCode
fi

echo "Attempting to build $project for OS X"
/Applications/Unity/Unity.app/Contents/MacOS/Unity \
  -batchmode \
  -nographics \
  -silent-crashes \
  -logFile $(pwd)/unity.log \
  -projectPath $(pwd) \
  -buildOSXUniversalPlayer "$(pwd)/Build/osx/$project.app" \
  -quit

exitCode=checkBuildStatus $? "OS X Universal" $(pwd)/unity.log
if [ $exitCode -ne 0 ]
then
    return $exitCode
fi

echo "Attempting to build $project for Linux"
/Applications/Unity/Unity.app/Contents/MacOS/Unity \
  -batchmode \
  -nographics \
  -silent-crashes \
  -logFile $(pwd)/unity.log \
  -projectPath $(pwd) \
  -buildLinuxUniversalPlayer "$(pwd)/Build/linux/$project" \
  -quit

exitCode=checkBuildStatus $? "Linux Universal" $(pwd)/unity.log
if [ $exitCode -ne 0 ]
then
    return $exitCode
fi
