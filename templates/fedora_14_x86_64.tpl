<template>
  <name>Fedora 14 x86_64 with updates</name>
  <description>Fedora 14 and all of its released updates</description>
  <os>
    <name>Fedora</name>
    <arch>x86_64</arch>
    <version>14</version>
    <install type="url">
      <url>http://download.fedoraproject.org/pub/fedora/linux/releases/14/Fedora/x86_64/os/</url>
    </install>
  </os>
  <repositories>
    <repository name="updates">
      <url>http://download.fedoraproject.org/pub/fedora/linux/updates/14/x86_64/</url>
      <signed>false</signed>
    </repository>
  </repositories>
</template>
