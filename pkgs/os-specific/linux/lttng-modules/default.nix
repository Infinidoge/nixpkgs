{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation rec {
  pname = "lttng-modules-${kernel.version}";
  version = "2.13.15";

  src = fetchFromGitHub {
    owner = "lttng";
    repo = "lttng-modules";
    rev = "v${version}";
    hash = "sha256-cEiv1EjsEvyreRERrCGKKpJdA1IKvuyVmgA7S3EkEnU=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  hardeningDisable = [ "pic" ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-function-declaration";

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  installTargets = [ "modules_install" ];

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Linux kernel modules for LTTng tracing";
    homepage = "https://lttng.org/";
    license = with licenses; [
      lgpl21Only
      gpl2Only
      mit
    ];
    platforms = platforms.linux;
    maintainers = [ maintainers.bjornfor ];
    broken =
      (lib.versions.majorMinor kernel.modDirVersion) == "5.10"
      || (lib.versions.majorMinor kernel.modDirVersion) == "5.4";
  };
}
