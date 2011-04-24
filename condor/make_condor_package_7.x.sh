#!/bin/bash -x

if [ $# -ne 1 ]; then
    echo "Usage: $0 <release>"
    exit 1
fi

generate_tarball() {
    input="condor_src-$1-all-all.tar.gz"

    if [ ! -f $input ] ; then
	echo "$input is not a regular file";
	exit 1;
    fi

    echo "Processing $input"

    echo "...extracting $input"
    tar xzf $input

    cd condor-$1

    if [ ! -f BUILD-ID ] ; then
	build="UNKNOWN"
    else
	build=`cat BUILD-ID`
    fi

    echo "...recording BUILD-ID: $build"

    for f in \
	src/condor_mail \
	src/condor_vm-gahp/cygwin1.dll \
	src/condor_vm-gahp/mkisofs.exe \
	config/CONDOR_TEST_LRG \
	src/condor_tests/job_vmu_basic.sh \
	src/condor_tests/job_vmu_cdrom.run \
	src/condor_tests/job_vmu_cdrom.sh \
	src/condor_tests/job_vmu_ckpt.run \
	src/condor_tests/job_vmu_ckpt.sh \
	src/condor_tests/job_vmu_network.key \
	src/condor_tests/job_vmu_network.run \
	src/condor_tests/job_vmu_network.sh \
	src/condor_tests/job_vmu_basic.run \
	src/condor_tests/x_vm_utils.pm \
	src/condor_tests/x_param.vmware \
	src/condor_tests/x_vmware_test_vm.cmd \
	src/condor_tests/x_vmware_test_vm.tar.gz \
	src/condor_tests/x_vmware_configpostsrc \
	config/CONDOR_TEST_CNFDTL \
	src/condor_tests/job_ligo_x86-64-chkpttst.cmd \
	src/condor_tests/job_ligo_x86-64-chkpttst.run \
	src/condor_tests/x_job_ligo_x86-64-chkpttst.tar.gz \
	src/condor_tests/job_quill_basic.cmd \
	src/condor_tests/job_quill_basic.pl \
	src/condor_tests/job_quill_basic.run \
	src/condor_tests/x_job_quill_basic.template \
	src/condor_tests/x_job_quill_supw \
	src/condor_tests/x_param.quill \
	src/condor_tests/x_postgress_quill.conf \
	src/condor_tests/x_quill_buildperlmods.pl \
	src/condor_tests/x_quill_config_postsrc.template \
	src/condor_tests/x_quill_Expect-1.20.tar.gz \
	src/condor_tests/x_quill_IO-Tty-1.07.tar.gz \
	src/condor_tests/x_quill_pgsqlinstall.pl \
	src/condor_tests/x_quill_pgsqlstop.pl \
	src/condor_tests/x_quill_readline-5.2.tar.gz \
	src/condor_tests/x_quill_readlineinstall.pl;
    do
	echo "...removing $f";
	rm -r $f;
    done;

    # We can't remove the 'externals' directory under
    # cmake because it contains CMakeLists which are like Makefiles and
    # are part of the build directory structure.
    #echo "...removing all externals except 'man'"
    #mv externals/bundles/man externals/
    #rm -r externals/bundles/*
    #mv externals/man externals/bundles/

    echo "...creating condor-$1-$build-RH.tar.gz"
    cd ..
    tar czfsp condor-$1-$build-RH.tar.gz condor-$1

    echo "...cleaning up"
    rm -rf condor-$1
}

generate_spec() {
    cat <<\SPECEOF > $1
Summary: Condor: High Throughput Computing
Name: condor
Version: 7.6.0
Release: 3dcloud%{?dist}
License: ASL 2.0
Group: Applications/System
URL: http://www.cs.wisc.edu/condor/
# The upstream Condor source tarball contains some source that cannot
# be shipped as well as extraneous copies of packages the source
# depends on. Additionally, the upstream Condor source requires a
# click-through license. Once you have downloaded the source from:
#   http://parrot.cs.wisc.edu/v7.0.license.html
# you should process it with generate-tarball.sh:
#   ./generate-tarball.sh 7.0.4
# MD5Sum of upstream source:
#   06eec3ae274b66d233ad050a047f3c91  condor_src-7.0.0-all-all.tar.gz
#   b08743cfa2e87adbcda042896e8ef537  condor_src-7.0.2-all-all.tar.gz
#   5f326ad522b63eacf34c6c563cf46910  condor_src-7.0.4-all-all.tar.gz
#   73323100c5b2259f3b9c042fa05451e0  condor_src-7.0.5-all-all.tar.gz
#   a2dd96ea537b2c6d105b6c8dad563ddc  condor_src-7.2.0-all-all.tar.gz
#   edbac8267130ac0a0e016d0f113b4616  condor_src-7.2.1-all-all.tar.gz
#   6d9b0ef74d575623af11e396fa274174  condor_src-7.2.4-all-all.tar.gz
#   ee72b65fad02d21af0dc8f1aa5872110  condor_src-7.4.0-all-all.tar.gz
#   d4deeabbbce65980c085d8bea4c1018a  condor_src-7.4.1-all-all.tar.gz
#   4714086f58942b78cf03fef9ccb1117c  condor_src-7.4.2-all-all.tar.gz
# Note: The md5sum of each generated tarball may be different
Source0: condor-7.6.0-UNKNOWN-RH.tar.gz
#Source1: generate-tarball.sh
Patch0: condor_config.generic.patch
#Patch1: stdsoap2.h.patch.patch
Patch3: chkconfig_off.patch
Patch6: log_lock_run.patch
Patch7: only_dynamic_unstripped.patch
Patch8: have_dlopen.patch

BuildRoot: %(mktemp -ud %{_tmppath}/%{name}-%{version}-%{release}-XXXXXX)

BuildRequires: imake
BuildRequires: flex
BuildRequires: byacc
BuildRequires: pcre-devel
BuildRequires: postgresql-devel
BuildRequires: openssl-devel
BuildRequires: krb5-devel
BuildRequires: gsoap-devel >= 2.7.12-1
BuildRequires: libvirt-devel
BuildRequires: bind-utils
BuildRequires: m4
BuildRequires: autoconf
BuildRequires: classads-devel >= 1.0.4
BuildRequires: libX11-devel
BuildRequires: libdeltacloud-devel >= 0.6
BuildRequires: cmake

Requires: gsoap >= 2.7.12
Requires: mailx
Requires: python >= 2.2
Requires: tcsh

Requires(pre): shadow-utils

Requires(post):/sbin/chkconfig
Requires(preun):/sbin/chkconfig
Requires(preun):/sbin/service
Requires(postun):/sbin/service

Requires(post): policycoreutils-python

#Provides: user(condor) = 43
#Provides: group(condor) = 43

Obsoletes: condor-static < 7.2.0


%description
Condor is a specialized workload management system for
compute-intensive jobs. Like other full-featured batch systems, Condor
provides a job queueing mechanism, scheduling policy, priority scheme,
resource monitoring, and resource management. Users submit their
serial or parallel jobs to Condor, Condor places them into a queue,
chooses when and where to run the jobs based upon a policy, carefully
monitors their progress, and ultimately informs the user upon
completion.


#%package static
#Summary: Headers and libraries for interacting with Condor
#Group: Development/System
#Requires: %name = %version-%release
#
#
#%description static
#Headers and libraries for interacting with Condor and its components.


%package kbdd
Summary: Condor Keyboard Daemon
Group: Applications/System
Requires: %name = %version-%release
Requires: libX11

%description kbdd
The condor_kbdd monitors logged in X users for activity. It is only
useful on systems where no device (e.g. /dev/*) can be used to
determine console idle time.


%package vm-gahp
Summary: Condor's VM Gahp
Group: Applications/System
Requires: %name = %version-%release

%description vm-gahp
The condor_vm-gahp enables the Virtual Machine Universe feature of
Condor. The VM Universe uses libvirt to start and control VMs under
Condor's Startd.


%pre
getent group condor >/dev/null || groupadd -r condor
getent passwd condor >/dev/null || \
  useradd -r -g condor -d %_var/lib/condor -s /sbin/nologin \
    -c "Owner of Condor Daemons" condor
exit 0


%prep
%setup -q -n %{name}-%{version}

%patch0 -p1
#%patch1 -p1
%patch3 -p1
%patch6 -p1
#%patch7 -p1
%patch8 -p1

# fix errant execute permissions
find src -perm /a+x -type f -name "*.[Cch]" -exec chmod a-x {} \;


%build

cmake -DCMAKE_INSTALL_PREFIX=$RPM_BUILD_ROOT/usr -DHAVE_DLOPEN=1 .
make

(cd externals/bundles/man/current
tar fxvz man-current.tar.gz
cd man/man1
for i in `ls`; do
    gzip -9 $i
done
)

%install
make install

mkdir -p -m0755 "%{buildroot}"/%_sysconfdir/condor

# the default condor_config file is not architecture aware and thus
# sets the LIB directory to always be /usr/lib, we want to do better
# than that. this is, so far, the best place to do this
# specialization. we strip the "lib" or "lib64" part from _libdir and
# stick it in the LIB variable in the config.
#
# I commented this out because we just let the stuff go into /usr/lib
# now.
#
#LIB=$(echo %{?_libdir} | sed -e 's:/usr/\(.*\):\1:')
#if [ "$LIB" = "%_libdir" ]; then
  #echo "_libdir does not contain /usr, sed expression needs attention"
  #exit 1
#fi
#sed -e "s:^LIB\s*=.*:LIB = \$(RELEASE_DIR)/$LIB/condor:" \
  #src/condor_examples/condor_config.generic \
  #> %{buildroot}/%_sysconfdir/condor/condor_config

install -Dp -m0644 src/condor_examples/condor_config.generic %{buildroot}/%_sysconfdir/condor/condor_config
mkdir -p -m0755 "%{buildroot}"/%_var/lib/condor

cat > %{buildroot}/%_var/lib/condor/condor_config.local << EOF
CONDOR_DEVELOPERS = NONE
CONDOR_HOST = \$(FULL_HOSTNAME)
COLLECTOR_NAME = Personal Condor
START = TRUE
SUSPEND = FALSE
PREEMPT = FALSE
KILL = FALSE
DAEMON_LIST = COLLECTOR, MASTER, NEGOTIATOR, SCHEDD, STARTD
NEGOTIATOR_INTERVAL = 20
EOF

# this gets around a bug whose fix is not yet merged
#echo "TRUST_UID_DOMAIN = TRUE" >> $PREFIX/local_dir/condor_config.local
#
mkdir -p -m0755 "%{buildroot}"/%_var/run/condor
mkdir -p -m0755 "%{buildroot}"/%_var/log/condor
mkdir -p -m0755 "%{buildroot}"/%_var/lock/condor
mkdir -p -m0755 "%{buildroot}"/%_var/lib/condor
mkdir -p -m1777 "%{buildroot}"/%_var/lib/condor/execute
mkdir -p -m0755 "%{buildroot}"/%_var/lib/condor/spool

mkdir -p %buildroot/%_mandir
cp -r externals/bundles/man/current/man/* %buildroot/%_mandir

## install the lsb init script
install -Dp -m0755 src/condor_examples/condor.init %buildroot/%_initrddir/condor

install -Dp -m0755 src/condor_vm-gahp/libvirt_simple_script.awk %buildroot/%_libexecdir/condor/libvirt_simple_script.awk


# Remove some stuff in odd places..
rm -rf %{buildroot}/%_usr/include
rm -rf %{buildroot}/%_usr/examples
rm -rf %{buildroot}/%_usr/etc
rm -rf %{buildroot}/%_usr/DOC
rm -rf %{buildroot}/%_usr/src
rm %{buildroot}/%_usr/INSTALL
rm %{buildroot}/%_usr/LICENSE-2.0.txt
rm %{buildroot}/%_usr/README
rm %{buildroot}/%_usr/condor_configure
rm %{buildroot}/%_usr/condor_install

%clean
rm -rf %{buildroot}


%check
# This currently takes hours and can kill your machine...
#cd condor_tests
#make check-seralized


%files
%defattr(-,root,root,-)
%doc LICENSE-2.0.txt src/condor_release/examples
%_initrddir/condor
%dir %_sysconfdir/condor/
%config(noreplace) %_sysconfdir/condor/condor_config

%_bindir/condor_power
%_usr/lib/Chirp.jar
%_usr/lib/Condor.pm
%_usr/lib/CondorJavaInfo.class
%_usr/lib/CondorJavaWrapper.class
%_usr/lib/Execute.pm
%_usr/lib/FileLock.pm
%_usr/lib/condor_ssh_to_job_sshd_config_template
%_usr/lib/libchirp_client.a
%_usr/lib/libcondorapi.a
%_usr/lib/scimark2lib.jar
%_usr/lib/webservice/condorCollector.wsdl
%_usr/lib/webservice/condorSchedd.wsdl
%_libexecdir/condor_kflops
%_libexecdir/condor_mips
%_libexecdir/curl_plugin
%_libexecdir/data_plugin
%_libexecdir/bgp_available_partitions
%_libexecdir/bgp_back_partition
%_libexecdir/bgp_boot_partition
%_libexecdir/bgp_destroy_partition
%_libexecdir/bgp_generate_partition
%_libexecdir/bgp_query_work_loads
%_libexecdir/bgp_shutdown_partition
%_libexecdir/condor_chirp
%_libexecdir/condor_glexec_cleanup
%_libexecdir/condor_glexec_job_wrapper
%_libexecdir/condor_glexec_kill
%_libexecdir/condor_glexec_run
%_libexecdir/condor_glexec_setup
%_libexecdir/condor_glexec_update_proxy
%_libexecdir/condor_job_router
%_libexecdir/condor_limits_wrapper.sh
%_libexecdir/condor_rooster
%_libexecdir/condor_shared_port
%_libexecdir/condor_ssh
%_libexecdir/condor_ssh_to_job_shell_setup
%_libexecdir/condor_ssh_to_job_sshd_setup
%_libexecdir/condor_transferer
%_libexecdir/gridftp_wrapper.sh
%_libexecdir/libvirt_simple_script.awk
%_libexecdir/power_state
%_libexecdir/rsh
%_libexecdir/sshd.sh


%_sbindir/condor_vm-gahp-vmware
%_sbindir/cleanup_release
%_sbindir/condor_cleanup_local
%_sbindir/condor_cold_start
%_sbindir/condor_cold_stop
%_sbindir/condor_config_bind
%_sbindir/condor_configure
%_sbindir/condor_credd
%_sbindir/condor_install
%_sbindir/condor_install_local
%_sbindir/condor_lease_manager
%_sbindir/condor_local_start
%_sbindir/condor_local_stop
%_sbindir/condor_master_off
%_sbindir/condor_reconfig_schedd
%_sbindir/condor_set_shutdown
%_sbindir/condor_startd_factory
%_sbindir/filelock_midwife
%_sbindir/filelock_undertaker
%_sbindir/gidd_alloc
%_sbindir/install_release
%_sbindir/procd_ctl
%_sbindir/uniq_pid_command
%_sbindir/uniq_pid_midwife
%_sbindir/uniq_pid_undertaker

%_mandir/man1/condor_advertise.1.gz
%_mandir/man1/condor_check_userlogs.1.gz
%_mandir/man1/condor_chirp.1.gz
%_mandir/man1/condor_cod.1.gz
%_mandir/man1/condor_config_val.1.gz
%_mandir/man1/condor_dagman.1.gz
%_mandir/man1/condor_fetchlog.1.gz
%_mandir/man1/condor_findhost.1.gz
%_mandir/man1/condor_history.1.gz
%_mandir/man1/condor_hold.1.gz
%_mandir/man1/condor_load_history.1.gz
%_mandir/man1/condor_master.1.gz
%_mandir/man1/condor_off.1.gz
%_mandir/man1/condor_on.1.gz
%_mandir/man1/condor_preen.1.gz
%_mandir/man1/condor_prio.1.gz
%_mandir/man1/condor_q.1.gz
%_mandir/man1/condor_qedit.1.gz
%_mandir/man1/condor_reconfig.1.gz
%_mandir/man1/condor_release.1.gz
%_mandir/man1/condor_reschedule.1.gz
%_mandir/man1/condor_restart.1.gz
%_mandir/man1/condor_rm.1.gz
%_mandir/man1/condor_run.1.gz
%_mandir/man1/condor_stats.1.gz
%_mandir/man1/condor_status.1.gz
%_mandir/man1/condor_store_cred.1.gz
%_mandir/man1/condor_submit.1.gz
%_mandir/man1/condor_submit_dag.1.gz
%_mandir/man1/condor_transfer_data.1.gz
%_mandir/man1/condor_updates_stats.1.gz
%_mandir/man1/condor_userlog.1.gz
%_mandir/man1/condor_userprio.1.gz
%_mandir/man1/condor_vacate.1.gz
%_mandir/man1/condor_vacate_job.1.gz
%_mandir/man1/condor_version.1.gz
%_mandir/man1/condor_wait.1.gz
%_mandir/man1/condor_checkpoint.1.gz
%_mandir/man1/condor_cold_start.1.gz
%_mandir/man1/condor_cold_stop.1.gz
%_mandir/man1/condor_compile.1.gz
%_mandir/man1/condor_config_bind.1.gz
%_mandir/man1/condor_configure.1.gz
%_mandir/man1/condor_convert_history.1.gz
%_mandir/man1/condor_glidein.1.gz
%_mandir/man1/condor_master_off.1.gz
%_mandir/man1/condor_power.1.gz
%_mandir/man1/condor_reconfig_schedd.1.gz
%_mandir/man1/condor_router_history.1.gz
%_mandir/man1/condor_set_shutdown.1.gz
%_mandir/man1/condor_ssh_to_job.1.gz


# bin/condor is a link for checkpoint, reschedule, vacate
%_bindir/condor
#%_bindir/condor_load_history
%_bindir/condor_submit_dag
%_bindir/condor_prio
%_bindir/condor_transfer_data
%_bindir/condor_check_userlogs
%_bindir/condor_q
#%_libexecdir/condor/condor_transferer
%_bindir/condor_cod
%_bindir/condor_qedit
%_bindir/condor_userlog
%_bindir/condor_release
%_bindir/condor_userlog_job_counter
%_bindir/condor_config_val
%_bindir/condor_reschedule
%_bindir/condor_userprio
%_bindir/condor_gather_info
%_bindir/condor_dagman
%_bindir/condor_rm
%_bindir/condor_vacate
#%_bindir/condor_dump_history
%_bindir/condor_run
%_bindir/condor_router_history
%_bindir/condor_router_q
%_bindir/condor_router_rm
%_bindir/condor_vacate_job
%_bindir/condor_findhost
%_bindir/condor_stats
%_bindir/condor_version
%_bindir/condor_history
%_bindir/condor_status
%_bindir/condor_wait
%_bindir/condor_hold
%_bindir/condor_submit
%_bindir/condor_ssh_to_job
# sbin/condor is a link for master_off, off, on, reconfig,
# reconfig_schedd, restart
%_sbindir/condor_advertise
%_sbindir/condor_c-gahp
%_sbindir/condor_c-gahp_worker_thread
%_sbindir/deltacloud_gahp
%_sbindir/condor_collector
#%_sbindir/condor_dbmsd
%_sbindir/condor_fetchlog
%_sbindir/condor_had
%_sbindir/condor_init
%_sbindir/condor_master
%_sbindir/condor_negotiator
%_sbindir/condor_off
%_sbindir/condor_on
%_sbindir/condor_preen
%_sbindir/condor_procd
#%_sbindir/condor_quill
%_sbindir/condor_reconfig
%_sbindir/condor_replication
%_sbindir/condor_restart
%_sbindir/condor_root_switchboard
%_sbindir/condor_schedd
%_sbindir/condor_shadow
%_sbindir/condor_startd
%_sbindir/condor_starter
%_sbindir/condor_store_cred
%_sbindir/condor_transferd
%_sbindir/condor_updates_stats
%_sbindir/amazon_gahp
%_sbindir/condor_gridmanager
%config(noreplace) %_var/lib/condor/condor_config.local
%defattr(-,condor,condor,-)
%dir %_var/lib/condor/
%dir %_var/lib/condor/execute/
%dir %_var/log/condor/
%dir %_var/lib/condor/spool/
%dir %_var/lock/condor/
%dir %_var/run/condor/


#%files static
#%defattr(-,root,root,-)
#%doc LICENSE-2.0.txt
#%_libdir/libcondorapi.a
#%dir %_includedir/condor/
#%_includedir/condor/condor_constants.h
#%_includedir/condor/condor_event.h
#%_includedir/condor/condor_holdcodes.h
#%_includedir/condor/file_lock.h
#%_includedir/condor/user_log.c++.h
#%doc %_includedir/condor/user_log.README
#%dir %_usrsrc/chirp/
#%_usrsrc/chirp/chirp_client.c
#%_usrsrc/chirp/chirp_client.h
#%_usrsrc/chirp/chirp_protocol.h


%files kbdd
%defattr(-,root,root,-)
%doc LICENSE-2.0.txt NOTICE.txt
%_sbindir/condor_kbdd


%files vm-gahp
%defattr(-,root,root,-)
%doc LICENSE-2.0.txt NOTICE.txt
%_sbindir/condor_vm-gahp
%_sbindir/condor_vm_vmware.pl
%_libexecdir/condor/libvirt_simple_script.awk


%post -n condor
/sbin/chkconfig --add condor
/sbin/ldconfig
test -x /usr/sbin/selinuxenabled && /usr/sbin/selinuxenabled
if [ $? = 0 ]; then
   semanage fcontext -a -t unconfined_execmem_exec_t %_sbindir/condor_startd
   restorecon  %_sbindir/condor_startd
fi


%preun -n condor
if [ $1 = 0 ]; then
  /sbin/service condor stop >/dev/null 2>&1 || :
  /sbin/chkconfig --del condor
fi


%postun -n condor
if [ "$1" -ge "1" ]; then
  /sbin/service condor condrestart >/dev/null 2>&1 || :
fi
/sbin/ldconfig


%changelog
* Sun Apr 24 2011  <jclift@redhat.com> - 7.6.1-0
- Upgrade to work with 7.6.1 git development branch.

* Wed Jan 12 2011  <imain@redhat.com> - 7.5.6-1
- Upgrade to 7.5.6 release, redo build to use cmake.

* Wed Apr 21 2010  <matt@redhat> - 7.4.2-1
- Upgrade to 7.4.2 release

* Tue Jan  5 2010  <matt@redhat> - 7.4.1-1
- Upgrade to 7.4.1 release
- Upstreamed: guess_version_from_release_dir, fix_platform_check
- Security update (BZ549577)

* Fri Dec  4 2009  <matt@redhat> - 7.4.0-1
- Upgrade to 7.4.0 release
- Fixed POSTIN error (BZ540439)
- Removed NOTICE.txt source, now provided by upstream
- Removed no_rpmdb_query.patch, applied upstream
- Removed no_basename.patch, applied upstream
- Added only_dynamic_unstripped.patch to reduce build time
- Added guess_version_from_release_dir.patch, for previous
- Added fix_platform_check.patch
- Use new --with-platform, to avoid modification of make_final_tarballs
- Introduced vm-gahp package to hold libvirt deps

* Fri Aug 28 2009  <matt@redhat> - 7.2.4-1
- Upgrade to 7.2.4 release
- Removed gcc44_const.patch, accepted upstream
- New log, lock, run locations (BZ502175)
- Filtered innocuous semanage message

* Fri Aug 21 2009 Tomas Mraz <tmraz@redhat.com> - 7.2.1-3
- rebuilt with new openssl

* Fri Jul 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 7.2.1-2
- Rebuilt for https://fedoraproject.org/wiki/Fedora_12_Mass_Rebuild

* Mon Feb 25 2009  <matt@redhat> - 7.2.1-1
- Upgraded to 7.2.1 release
- Pruned changes accepted upstream from condor_config.generic.patch
- Removed Requires in favor of automatic dependencies on SONAMEs
- Added no_rmpdb_query.patch to avoid rpm -q during a build

* Tue Feb 24 2009 Fedora Release Engineering <rel-eng@lists.fedoraproject.org> - 7.2.0-5
- Rebuilt for https://fedoraproject.org/wiki/Fedora_11_Mass_Rebuild

* Thu Jan 15 2009 Tomas Mraz <tmraz@redhat.com> - 7.2.0-4
- rebuild with new openssl

* Mon Jan 14 2009  <matt@redhat> - 7.2.0-3
- Fixed regression: initscript was on by default, now off again

* Thu Jan  8 2009  <matt@redhat> - 7.2.0-2
- (Re)added CONDOR_DEVELOPERS=NONE to the default condor_config.local
- Added missing Obsoletes for condor-static (thanks Michael Schwendt)

* Wed Jan  7 2009  <matt@redhat> - 7.2.0-1
- Upgraded to 7.2.0 release
- Removed -static package
- Added Fedora specific buildid
- Enabled KBDD, daemon to monitor X usage on systems with only USB devs
- Updated install process

* Wed Oct  8 2008  <matt@redhat> - 7.0.5-1
- Rebased on 7.0.5, security update

* Wed Aug  6 2008  <mfarrellee@redhat> - 7.0.4-1
- Updated to 7.0.4 source
- Stopped using condor_configure in install step

* Tue Jun 10 2008  <mfarrellee@redhat> - 7.0.2-1
- Updated to 7.0.2 source
- Updated config, specifically HOSTALLOW_WRITE, for Personal Condor setup
- Added condor_config.generic

* Mon Apr  7 2008  <mfarrellee@redhat> - 7.0.0-8
- Modified init script to be off by default, resolves bz441279

* Fri Apr  4 2008  <mfarrellee@redhat> - 7.0.0-7
- Updated to handle changes in gsoap dependency

* Mon Feb 11 2008  <mfarrellee@redhat> - 7.0.0-6
- Added note about how to download the source
- Added generate-tarball.sh script

* Sun Feb 10 2008  <mfarrellee@redhat> - 7.0.0-5
- The gsoap package is compiled with --disable-namespaces, which means
  soap_set_namespaces is required after each soap_init. The
  gsoap_nonamespaces.patch handles this.

* Fri Feb  8 2008  <mfarrellee@redhat> - 7.0.0-4
- Added patch to detect GCC 4.3.0 on F9
- Added patch to detect GLIBC 2.7.90 on F9
- Added BuildRequires: autoconf to allow for regeneration of configure
  script after GCC 4.3.0 detection and GLIBC 2.7.90 patches are
  applied
- Condor + GCC 4.3.0 + -O2 results in an internal compiler error
  (BZ 432090), so -O2 is removed from optflags for the time
  being. Thanks to Mike Bonnet for the suggestion on how to filter
  -O2.

* Tue Jan 22 2008  <mfarrellee@redhat> - 7.0.0-3
- Update to UW's really-final source for Condor 7.0.0 stable series
  release. It is based on the 72173 build with minor changes to the
  configure.ac related to the SRB external version.
- In addition to removing externals from the UW tarball, the NTconfig
  directory was removed because it had not gone through IP audit.

* Tue Jan 22 2008  <mfarrellee@redhat> - 7.0.0-2
- Update to UW's final source for Condor 7.0.0 stable series release

* Thu Jan 10 2008  <mfarrellee@redhat> - 7.0.0-1
- Initial package of Condor's stable series under ASL 2.0
- is_clipped.patch replaced with --without-full-port option to configure
- zlib_is_soft.patch removed, outdated by configure.ac changes
- removed autoconf dependency needed for zlib_is_soft.patch

* Tue Dec  4 2007  <mfarrellee@redhat> - 6.9.5-2
- SELinux was stopping useradd in pre because files specified root as
  the group owner for /var/lib/condor, fixed, much thanks to Phil Knirsch

* Fri Nov 30 2007  <mfarrellee@redhat> - 6.9.5-1
- Fixed release tag
- Added gSOAP support and packaged WSDL files

* Thu Nov 29 2007  <mfarrellee@redhat> - 6.9.5-0.2
- Packaged LSB init script
- Changed pre to not create the condor user's home directory, it is
  now a directory owned by the package

* Thu Nov 29 2007  <mfarrellee@redhat> - 6.9.5-0.1
- Condor 6.9.5 release, the 7.0.0 stable series candidate
- Removed x86_64_no_multilib-200711091700cvs.patch, merged upstream
- Added patch to make zlib a soft requirement, which it should be
- Disabled use of smp_mflags because of make dependency issues
- Explicitly not packaging WSDL files until the SOAP APIs are available

* Tue Nov 20 2007  <mfarrellee@redhat> - 6.9.5-0.3.200711091700cvs
- Rebuild for repo inheritance update: dependencies are now pulled
  from RHEL 5 U1 before RH Application Stack

* Thu Nov 15 2007 <mfarrellee@redhat> - 6.9.5-0.2.200711091700cvs
- Added support for building on x86_64 without multilib packages
- Made the install section more flexible, reduced need for
  make_final_tarballs to be updated

* Fri Nov 9 2007 <mfarrellee@redhat> - 6.9.5-0.1.200711091700cvs
- Working source with new ASL 2.0 license

* Fri Nov 9 2007 <mfarrellee@redhat> - 6.9.5-0.1.200711091330cvs
- Source is now stamped ASL 2.0, as of Nov 9 2007 1:30PM Central
- Changed license to ASL 2.0
- Fixed find in prep to work if no files have bad permissions
- Changed the name of the LICENSE file to match was is now release in
  the source tarball

* Tue Nov 6 2007  <mfarrellee@redhat> - 6.9.5-0.1.rc
- Added m4 dependency not in RHEL 5.1's base
- Changed chmod a-x script to use find as more files appear to have
  improper execute bits set
- Added ?dist to Release:
- condor_privsep became condor_root_switchboard

* Tue Sep 11 2007  <mfarrellee@redhat> - 6.9.5-0.3.20070907cvs
- Instead of releasing libcondorapi.so, which is improperly created
  and poorly versioned, we release libcondorapi.a, which is apparently
  more widely used, in a -static package
- Instead of installing the stripped tarball, the unstripped is now
  installed, which gives a nice debuginfo package
- Found and fixed permissions problems on a number of src files,
  issue raised by rpmlint on the debuginfo package

* Mon Sep 10 2007  <mfarrellee@redhat> - 6.9.5-0.2.20070907cvs
- Updated pre section to create condor's home directory with adduser, and
  removed _var/lib/condor from files section
- Added doc LICENSE.TXT to all files sections
- Shortened lines longer than 80 characters in this spec (except the sed line)
- Changed install section so untar'ing a release can handle fedora7 or fedora8
- Simplified the site.def and config file updates (sed + mv over mv + sed + rm)
- Added a patch (fedora_rawhide_7.91-20070907cvs.patch) to support building on
  a fedora 7.91 (current Rawhide) release
- Moved the examples from /usr/share/doc/condor... into builddir and just
  marked them as documentation
- Added a number of dir directives to force all files to be listed, no implicit
  inclusion

* Fri Sep  7 2007  <mfarrellee@redhat> - 6.9.5-0.1.20070907cvs
- Initial release

SPECEOF
}

generate_config_patch() {
    cat <<\EOF > $1
--- a/src/condor_examples/condor_config.generic	2011-04-24 20:46:15.975908980 +1000
+++ b/src/condor_examples/condor_config.generic	2011-04-24 20:53:35.720199485 +1000
@@ -1,15 +1,35 @@
 ######################################################################
+######################################################################
+##                                                                  ##
+##  N O T I C E:                                                    ##
+##                                                                  ##
+##       Customization of this file should be done via the          ##
+##       LOCAL_CONFIG_FILE.                                         ##
+##                                                                  ##
+######################################################################
+######################################################################
+
+
+######################################################################
 ##
 ##  condor_config
 ##
 ##  This is the global configuration file for condor.  Any settings
-##  made here may potentially be overridden in the local configuration
-##  file.  KEEP THAT IN MIND!  To double-check that a variable is
-##  getting set from the configuration file that you expect, use
-##  condor_config_val -v <variable name>
+##  found here * * s h o u l d   b e   c u s t o m i z e d   i n
+##  t h e   l o c a l   c o n f i g u r a t i o n   f i l e. * *
+##
+##  The local configuration file is specified by LOCAL_CONFIG_FILE
+##  below.
+##
+##  For a basic configuration, you may only want to start by
+##  customizing CONDOR_ADMIN.
+##
+##  Note: To double-check where a configuration variable is set from
+##  you can use condor_config_val -v <variable name>,
+##  e.g. condor_config_val -v CONDOR_ADMIN.
 ##
 ##  The file is divided into four main parts:
-##  Part 1:  Settings you likely want to customize 
+##  Part 1:  Settings you likely want to customize
 ##  Part 2:  Settings you may want to customize
 ##  Part 3:  Settings that control the policy of when condor will
 ##           start and stop jobs on your machines
@@ -46,14 +66,11 @@
 ######################################################################
 ######################################################################
 
-##  What machine is your central manager?
-CONDOR_HOST	= central-manager-hostname.your.domain
-
 ##--------------------------------------------------------------------
 ##  Pathnames:
 ##--------------------------------------------------------------------
 ##  Where have you installed the bin, sbin and lib condor directories?   
-RELEASE_DIR		= /usr/local/condor
+RELEASE_DIR		= /usr
 
 ##  Where is the local condor directory for each host?  
 ##  This is where the local config file(s), logs and
@@ -932,9 +949,10 @@
 EXECUTE		= $(LOCAL_DIR)/execute
 BIN		= $(RELEASE_DIR)/bin
 LIB		= $(RELEASE_DIR)/lib
-INCLUDE		= $(RELEASE_DIR)/include
+INCLUDE		= $(RELEASE_DIR)/include/condor
 SBIN		= $(RELEASE_DIR)/sbin
-LIBEXEC		= $(RELEASE_DIR)/libexec
+LIBEXEC		= $(RELEASE_DIR)/libexec/condor
+SHARE		= $(RELEASE_DIR)/share/condor
 
 ## If you leave HISTORY undefined (comment it out), no history file
 ## will be created. 
@@ -1774,7 +1792,7 @@
 ## them here.  However, do not remove the existing entries, as Condor
 ## needs them.
 
-JAVA_CLASSPATH_DEFAULT = $(LIB) $(LIB)/scimark2lib.jar .
+JAVA_CLASSPATH_DEFAULT = $(SHARE) $(SHARE)/scimark2lib.jar .
 
 ##  JAVA_CLASSPATH_ARGUMENT describes the command-line parameter
 ##  used to introduce a new classpath:
EOF
}

generate_chkconfig_patch() {
    cat <<\EOF > $1
diff -ru condor-7.2.0/src/condor_examples/condor.init condor-7.2.0mf/src/condor_examples/condor.init
--- condor-7.2.0/src/condor_examples/condor.init	2008-12-19 14:10:08.000000000 -0600
+++ condor-7.2.0mf/src/condor_examples/condor.init	2009-01-13 19:31:15.000000000 -0600
@@ -2,7 +2,7 @@
 #
 # condor	This script allows for starting and stopping Condor.
 #
-# chkconfig: 2345 98 10
+# chkconfig: - 98 10
 # description: Condor is a high throughput computing batch processing
 # 	       platform.
 # processname: condor_master
EOF
}

generate_log_lock_patch() {
    cat <<\EOF > $1
diff --git a/src/condor_examples/condor_config.generic b/src/condor_examples/con
index 352f685..3f80b62 100644
--- a/src/condor_examples/condor_config.generic
+++ b/src/condor_examples/condor_config.generic
@@ -378,7 +378,7 @@
 ##  condor account, it's probably condor.  Otherwise, it's whatever
 ##  you've set in the CONDOR_IDS environment variable.  See the Admin
 ##  manual for details on this.
-LOCK		= $(LOG)
+LOCK		= /var/lock/condor
 
 ##  If you don't use a fully qualified name in your /etc/hosts file
 ##  (or NIS, etc.) for either your official hostname or as an alias,
@@ -878,15 +878,16 @@
 ######################################################################
 
 ##  Pathnames
-LOG		= $(LOCAL_DIR)/log
+LOG		= /var/log/condor
 SPOOL		= $(LOCAL_DIR)/spool
 EXECUTE		= $(LOCAL_DIR)/execute
 BIN		= $(RELEASE_DIR)/bin
 LIB		= $(RELEASE_DIR)/lib
 INCLUDE		= $(RELEASE_DIR)/include/condor
 SBIN		= $(RELEASE_DIR)/sbin
 LIBEXEC		= $(RELEASE_DIR)/libexec/condor
 SHARE		= $(RELEASE_DIR)/share/condor
+RUN		= /var/run/condor
 
 ## If you leave HISTORY undefined (comment it out), no history file
 ## will be created. 
@@ -1559,7 +1560,7 @@
 #     UNIX); the name will be something like:
 #         \\.\pipe\condor_procd
 #
-PROCD_ADDRESS = $(LOCK)/procd_pipe
+PROCD_ADDRESS = $(RUN)/procd_pipe
 
 # The procd currently uses a very simplistic logging system. Since this
 # log will not be rotated like other Condor logs, it is only recommended
EOF
}

generate_unstripped_patch() {
    cat <<\EOF > $1
--- condor-7.5.4/src/Imakefile.orig	2010-08-26 15:11:27.000000000 -0400
+++ condor-7.5.4/src/Imakefile	2010-09-02 09:15:45.380210866 -0400
@@ -615,10 +615,9 @@
 SHA1Constraint = --no-require-sha1
 #endif
 
-public: release all_tarballs
+public: release unstrip.tar
 	if test ! -d ../public; then mkdir ../public; fi
-	perl condor_scripts/make_final_tarballs --sys=$(SYSNAME) --platform=$(MFT_PLATFORM) --tarcmd="$(TAR_CMD)" --cpcmd="$(CP_CMD)" --target=../public
-	perl condor_scripts/make_native_packages.pl $(RPM_CMD)
+	perl condor_scripts/make_final_tarballs --sys=$(SYSNAME) --platform=$(MFT_PLATFORM) --tarcmd="$(TAR_CMD)" --cpcmd="$(CP_CMD)" --target=../public --linktype=unstripped-dynamic
 	perl condor_scripts/make_checksums --target=../public --md5sum="$(MD5SUM)" --sha1sum="$(SHA1SUM)" $(MD5Constraint) $(SHA1Constraint)
 
 #if HAVE_EXT_MAN
EOF
}

generate_have_dlopen_patch() {
    cat <<\EOF > $1
--- a/src/classad/CMakeLists.txt.orig	2011-04-24 17:31:06.000000000 +1000
+++ b/src/classad/CMakeLists.txt	2011-04-24 21:01:10.744775513 +1000
@@ -17,7 +17,7 @@
  ############################################################### 
 include_directories(${CMAKE_CURRENT_SOURCE_DIR})
 
-add_definitions(-DCLASSAD_DISTRIBUTION -DWANT_CLASSAD_NAMESPACE=1 )
+add_definitions(-DCLASSAD_DISTRIBUTION -DWANT_CLASSAD_NAMESPACE=1 -DHAVE_DLOPEN -DHAVE_DLFCN_H)
 
 # disable PCRE build unless dep added to externals.
 if(PCRE_FOUND)
EOF
}


# Create the Condor source tarball
ORIG_RPM_PATH=$HOME/rpmbuild
PATH_TO_CONDOR=$HOME/git_repos/condor
CONDOR_VERSION=`cd $PATH_TO_CONDOR ; grep 'set.VERSION' CMakeLists.txt | awk -F'"' '{print $2}'`
RELEASE="$1"

rm -rf /tmp/condor-$CONDOR_VERSION &&
mkdir -p /tmp/condor-$CONDOR_VERSION &&
cp -a $PATH_TO_CONDOR/* /tmp/condor-$CONDOR_VERSION &&
mkdir -p /tmp/condor-$CONDOR_VERSION/externals/bundles/man/current &&
cp $ORIG_RPM_PATH/SOURCES/man-current.tar.gz /tmp/condor-$CONDOR_VERSION/externals/bundles/man/current/

cd /tmp

tar -zcvf condor_src-$CONDOR_VERSION-all-all.tar.gz condor-$CONDOR_VERSION

generate_tarball $CONDOR_VERSION

# Set up the RPM build environment
mkdir -p $ORIG_RPM_PATH/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
cd $ORIG_RPM_PATH
generate_spec $ORIG_RPM_PATH/SPECS/condor.spec
cp /tmp/condor-$CONDOR_VERSION-UNKNOWN-RH.tar.gz $ORIG_RPM_PATH/SOURCES
generate_config_patch $ORIG_RPM_PATH/SOURCES/condor_config.generic.patch
generate_chkconfig_patch $ORIG_RPM_PATH/SOURCES/chkconfig_off.patch
generate_log_lock_patch $ORIG_RPM_PATH/SOURCES/log_lock_run.patch
generate_unstripped_patch $ORIG_RPM_PATH/SOURCES/only_dynamic_unstripped.patch
generate_have_dlopen_patch $ORIG_RPM_PATH/SOURCES/have_dlopen.patch

sed -i -e "s/^Version:.*/Version: $CONDOR_VERSION/" \
    -e "s/^Release:.*/Release: $RELEASE%{?dist}/" \
    -e "s/^Source0:.*/Source0: condor-$CONDOR_VERSION-UNKNOWN-RH.tar.gz/" \
    $ORIG_RPM_PATH/SPECS/condor.spec

# Build the binary Condor packages
rpmbuild -bb $ORIG_RPM_PATH/SPECS/condor.spec

