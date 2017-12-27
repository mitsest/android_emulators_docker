# Android emulators dockerfile

This docker container offers different android SDK version emulators(suitable for testing an android application).
You can create different emulator configuration files with little effort on  https://mitsest.github.io/avd_conf_generator/ (see below)

## Requirements

docker

Your host machine should support KVM (run kvm-ok to check), or the emulator will be too slow

## AVD Configuration (Optional)

If you want to test your app on another emulators' configuration than the ones provided inside avd_conf folder, I created the following tool:

https://mitsest.github.io/avd_conf_generator/

It will produce a zip file with the required configuration.
Extract its contents to avd_conf.
After that, avd_conf should contain one or more folders named after the avd names you picked, while using the tool.

The build script will take care of creating those emulators for you.

## Build container

```bash

docker build  . -t android_emulators \
              --build-arg nvidia_driver=nvidia-legacy-340xx-driver


### nvidia_driver
I usually run it on Debian Stretch, which uses nvidia-legacy-340xx-driver. So I pass nvidia_driver_version to the build command, in order for the container to be able to make use of the host's gpu.

If you'd rather use the open source drivers, or if you 're planning to not use the gpu at all, you can omit this argument.

## Run container

```bash
xhost +local:`docker inspect --format='{{ .Config.Hostname }}' android_emulators`

docker run --privileged --rm \
		-v /tmp/.X11-unix/:/tmp/.X11-unix/ \
		-v /dev/shm:/dev/shm \
		-e DISPLAY \
		-t android_emulators \
    'cd $ANDROID_HOME/tools && ./emulator @API_26 -gpu on -verbose'
```

Take extra note at the exported variable(avd_name).

If you have used the tool described above to produce your own emulator configuration,

change this to reflect the name you 've chosen.

Have fun and let me know if something went wrong!
