{ buildNpmPackage, fetchurl, lib, makeWrapper, pnpm }:

buildNpmPackage {
  pname = "dsh";
  version = "0.1.5-rc.1";

  src = fetchurl {
    url = "https://registry.npmjs.org/@deepseek-ai/dsh/-/dsh-0.1.5-rc.1.tgz";
    hash = "sha512-rmNmzQCg3oIc1z8xH7izRSOuy1TNzq+/NILyfM+7e8DKOyV+yBtg47WEsqR2SiIe1ATec3L/rUa1YhIcfQ2XEg==";
  };

  npmDepsHash = "sha256-Mb/uxfY6R86k2RvAo1zKI4lCI8Ee4kdC3NRteUIfU5M=";

  dontNpmBuild = true;

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    sed -i '/"@deepseek-ai\/dsh-experimental-code-runtime-python"/d' package.json
    cp ${./package-lock.json} package-lock.json
  '';

  postInstall = ''
    wrapProgram $out/bin/dsh --prefix PATH : ${lib.makeBinPath [ pnpm ]}
  '';

  meta = {
    description = "DeepSeek Harness agent CLI";
    homepage = "https://github.com/deepseek-ai/deepseek-harness";
    license = lib.licenses.bsd3;
    mainProgram = "dsh";
    platforms = lib.platforms.all;
  };
}
