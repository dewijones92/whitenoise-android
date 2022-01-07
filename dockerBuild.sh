#!/usr/bin/env bash
set -e;
set -x;
gradle_version="4.4"


function docker_run {
	set -x;
	set -e;
	docker run --rm -u gradle  -e ANDROID_HOME=$android_dir -v "$ANDROID_HOME":$android_dir -v gradle-cache:/home/gradle/.gradle\
		-v "$PWD":/home/gradle/project -w /home/gradle/project gradle:$gradle_version $@
}

export android_dir="/home/gradle/Android/Sdk"

docker_run keytool -genkey -v -keystore my-release-key.keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000

find | \grep -E "apk$|aab$" | xargs -d"\n" -n1 -t rm -rf;

docker_run "./gradlew assemble"

apk_path="./app/build/outputs/apk/release/app-release-unsigned.apk"
docker_run jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore $apk_path alias_name;
cp $apk_path ./release.apk
