define tomcat::instance_dirs($instance_dir, $owner, $group, $mode) {

    $filename = "${instance_dir}/${title}"

    file { $filename:
        ensure => directory,
        owner  => $owner,
        group  => $group,
        mode   => $mode,
    }
}
