#!/bin/bash

echo "Updating sdk libraries"
sdkmanager --verbose --update
yes | sdkmanager --licenses

for folder in avd_conf/*/; do
		avd_name=$(basename $folder)
		avd_ini_file=$(find $folder -name "$avd_name.ini")
		avd_config_ini_file=`find "$folder" -name 'config.ini'`

		# image.sysdir.1=system-images/android-21/google_apis/x86/
		pattern='image.sysdir.1='
		pattern_size=${#pattern}
		android_system_image=`grep $pattern $avd_config_ini_file`

		# system-images/android-21/google_apis/x86/
		system_image=${android_system_image:pattern_size}
		system_image_size=${#system_image}
		system_image_no_slash_at_end=${system_image:0:system_image_size-1}

		# system-images;android-21;google_apis;x86;
		android_system_image_sdkmanager_format="${system_image_no_slash_at_end//\//;}"

		printf "Downloading system image : $android_system_image_sdkmanager_format\n"
		sdkmanager --verbose $android_system_image_sdkmanager_format

		printf "Creating emulator...\n"
		echo no | avdmanager create avd --force --name $avd_name --package $android_system_image_sdkmanager_format
		printf "\n"

		mkdir -p $ANDROID_AVD_HOME/${avd_name}.avd && cp $avd_config_ini_file $ANDROID_AVD_HOME/${avd_name}.avd/config.ini
		cp $avd_ini_file $ANDROID_AVD_HOME/
done
