# Sensory TrulyHandsfree WakeWord Engine


## About the Project

This [project][] provides plug-in keyword spotting for the
[Alexa AVS sample app][alexa] Raspberry Pi project, using
[Sensory's][sensory] [TrulyHandsfree][thf] technology. It includes
speaker-independent recognizers for the phrase "Alexa".

## License

The [TrulyHandsfree][thf] library is provided for non-commercial
development use only. See [LICENSE.txt](LICENSE.txt) for details.

The *libsnsr.a* library is time-limited: code linked
against it will stop working when the library expires. The library included
in this repository will, at all times, have an expiration date that is at
least 120 days in the future. To continue development after a library has
expired, pull the latest update from the repository and re-link.

Please contact [Sensory Sales][sales] if you wish to use this code in a product.
We have solutions available for a large number of architectures,
including low-power DSP ports suitable for continuous listening on
battery-powered devices. Sensory also offers additional technologies, such
as enrolled speaker-specific triggers and speaker verification.


## Getting Started

This project is a plug-in for the [Alexa AVS sample app][alexa] project.
Please follow the build and configuration instructions for that project.

## Performance

The *models/* subdirectory contains recognition models of different sizes.
The larger models provide better performance but require more CPU resources.
The table below provides details.

Model | Size MiB | FR % | FA / day | MIPS |Pi 2 CPU % |Pi 3 CPU %
------|:--------:|:----:|:--------:|-----:|--------:|---------:
spot-alexa-rpi-20500.snsr|0.3|10.5 &plusmn; 2.1|6.6 &plusmn; 1| 34 | 5.1| 2.8
spot-alexa-rpi-21000.snsr|1.1|10.2 &plusmn; 2.1|4.5 &plusmn; 1| 90 |17.7| 8.1
spot-alexa-rpi-31000.snsr|2.0|10.6 &plusmn; 2.1|3.7 &plusmn; 1|168 |33.2|14.0

**Key:**

  * Size: The file size of the keyword spotter model in Mebibytes.
    This is also an estimate of the runtime RAM requirement.
  * FR: False Reject percentage. This is the fraction of times the correct
    wakeword is not recognized.
  * FA: False Accept frequency. The number of times per day the system
    mistakenly reports a spot of the wakeword.
  * Pi 2 CPU %: [Raspberry Pi 2 model B][2B] CPU resource usage
    expressed as a percentage of real-time.
    50% is half of one CPU core: Such a recognizer
    processes audio at twice the rate it arrives from the microphone.
  * Pi 3 CPU %: [Raspberry Pi 3 model B][3B] CPU resource usage.

**Test methodology:**

  * Measured on data independent from those used for development.
  * More than 1400 utterances were evaluated, each of these in 24 different
    noise conditions (six different noise types, four [SNR][] levels).
  * Includes over-the-air tests of physical devices in an anechoic chamber.
  * Results reported in the table above were measured at 12 [dBA] SNR.
  * In typical use the SNR is around 15 dBA. A better signal-to-noise ratio
    results in better performance; the reported results are therefore
   conservative.

## Frequently Asked Questions

1. How do I report a problem with this plug-in?
    * Open a [GitHub issue][issue] and include detail on how to
      trigger the unexpected behavior.

1. The library license key has expired. How do I extend it?
    * In *samples/wakeWordAgent/sensory/alexa-rpi/*, issue these commands:
        ```bash
        git reset --hard
        git pull
        ./bin/license.sh; # accept license agreement
        cp ./lib/libsnsr.a ../../ext/lib/
        cp ./include/snsr.h ../../ext/include/
        cp ./models/*.snsr ../../ext/resources/
        cp ./models/spot-alexa-rpi-31000.snsr ../../ext/resources/spot-alexa-rpi.snsr
        cd ../../src
        make
        ./wakeWordAgent -e sensory
        ```

1. What can I do to address audio recording problems?
    * The project uses [ALSA][] for audio recording. It will open a
      capture session from the default audio device, and record 16-bit signed
      integers at 16 kHz.
    * There is an example [/etc/asound.conf][alsacfg] included in the
      *config/* subdirectory in this repository.  This file configures ALSA
      to use the USB microphone as the default input source, and the analog
      audio jack as the default output.  We recommend that you use this
      configuration as a starting point for your audio routing.
    * Verify that your audio configuration is suitable by running this
      command to make a ten second long audio recording:
      `arecord -d 10 -f S16_LE -r 16000 test.wav`
    * Listen to the test recording and verify that it is clear:
      `aplay test.wav`
    * If the recording volume is low, experiment with adjusting the recording
      levels using `alsamixer`. Run `sudo alsactl store` to make these
      settings permanent.

1. Which ARM architectures are supported?
    * The `libsnsr.a` TrulyHandsfree library is compiled for ARMv7, and will
      use NEON instructions on the Rasperry Pi 2 and 3.
    * The Raspberry Pi 1 and Raspberry Pi Zero use an ARM1176JZF-S CPU,
      which supports ARMv6 instructions only. These are not supported in
      this plug-in.


## Change Log

#### 5.0.0-avs.4 - 2017-02-06
* Changed
    - `snsrNew()` validates *snsr.h* version.
    - `snsrStreamFromAudioDevice()` tries to recover from
      `snd_pcm_readi()` errors.
    - Larger ALSA capture buffer.
* Fixed
    - `snsrRun()` and `snsrForEach()` return `SNSR_RC_ERROR` when
      the `SnsrCallback` function returned `SNSR_RC_INTERRUPTED`.

#### 5.0.0-avs.3 - 2017-02-01
* Fixed
    - Handling of zero ALSA reads. This addresses spurious end-of-stream
      errors during audio capture.
    - `Push iteration limit exceeded` errors, which stopped the
      WakeWord Engine 74.5 hours after the last "Alexa" spot.

#### 5.0.0-avs.2 - 2017-01-26
* Added
    - Change log section in README.md.
* Fixed
    - Reporting of ALSA errors.
    - Handling of short ALSA reads. This addresses spurious
      end-of-stream errors during audio capture.
    - `Push iteration limit exceeded` errors, which occasionally stopped the
      the WakeWord Engine after it had been running for a couple of days.

#### 5.0.0-avs.1 - 2016-09-12
* Added
    - Initial release.

---------
*Copyright &copy; 2016-2017 Sensory, Inc. http://sensory.com/*

[alexa]:   https://github.com/alexa/alexa-avs-sample-app

[sensory]: http://sensory.com/
[sales]:   http://www.sensory.com/support/contact/us-sales/
[thf]:     http://www.sensory.com/products/technologies/trulyhandsfree/
[project]: https://github.com/sensory/alexa-rpi
[issue]:   https://github.com/sensory/alexa-rpi/issues

[dBA]:     https://en.wikipedia.org/wiki/A-weighting
[SNR]:     https://en.wikipedia.org/wiki/Signal-to-noise_ratio
[2B]:      https://www.raspberrypi.org/products/raspberry-pi-2-model-b/
[3B]:      https://www.raspberrypi.org/products/raspberry-pi-3-model-b/
[rj]:      https://www.raspberrypi.org/downloads/raspbian/
[ALSA]:    http://www.alsa-project.org/
[alsamix]: http://askubuntu.com/questions/50067/howto-save-alsamixer-settings
[alsacfg]: http://www.alsa-project.org/main/index.php/Asoundrc
