#!/usr/bin/env bash
set -e;
set -x;


function docker_run {
	set -x;
	set -e;
	docker run --rm -u gradle  -e ANDROID_HOME=$android_dir -v "$ANDROID_HOME":$android_dir -v gradle-cache:/home/gradle/.gradle\
		-v "$PWD":/home/gradle/project -w /home/gradle/project gradle:4.4 $@
}

export android_dir="/home/gradle/Android/Sdk"

docker_run keytool -genkey -v -keystore my-release-key.keystore -alias alias_name -keyalg RSA -keysize 2048 -validity 10000

find | \grep -E "apk$|aab$" | xargs -d"\n" -n1 -t rm -rf;

docker_run "./gradlew assemble"

docker_run jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore my-release-key.keystore ./app/build/outputs/apk/release/app-release-unsigned.apk alias_name;
